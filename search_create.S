# riscyforth is licenced under GPL v2
# copyright, Adrian McMenamin, 2021
# search-create - search for word addresses when we are in create mode


  search_create_continue:
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                lw t3, 0(t4)
  search_create_next_in_dictionary:
                lb t4, 12(t3)
                bne t4, t2, search_create_tokens_do_not_match
                add a0, t3, 16                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_create_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_create_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_create_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_create_loop_through_token

  search_create_tokens_do_not_match:
                lw t3, 8(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_create_exhausted        #at the end of the dictionary
                j search_create_next_in_dictionary

  search_create_tokens_matched:
                addi t3, t3, 4                        #address that points to the code
		#now check it is allowed
		la t0, WA_COLON			      #cannot nest definitions
		bne t3, t0, search_create_allowed
		la t0, CREATEFLAG
		sw zero, 0(t0)
		tail search_failed		      #report error
  search_create_allowed:
		#test for conditionals
		la t0, WA_IF
		bne t3, t0, search_create_test_then
		#if code
		la t0, ifflag
		li t1, 1
		sw t1, 0(t0)				#activate ifflag
		#now write out the test code
		la a0, DECIDESTACKB
		lw a0, 0(a0)
		la a2, DECIDESTACKP
		lw a1, 0(a2)
		#write out a new zero for depth
		li t0, 4
		mul t0, t0, a1
		add a2, a2, t0
		sw zero, 0(a2)
		call if_func_create
		mv t3, a0 
		j search_create_inscribe
  search_create_test_then:
		la t0, WA_THEN
		#are we in if mode
		bne t3, t0, search_create_test_else
		#TODO: then code
		#are we in if mode
		la t0, ifflag
		lw t0, 0(t0)
		bnez t0, search_create_then_ifmode
		tail search_failed
  search_create_then_ifmode:
		#read depth
		la t0, DECIDESTACKP
		lw t1, 0(t0)
		li t2, 4
		mul t3, t2, t1
		add t2, t0, t3
		lw t1, 0(t2)
		li t0, 1
		bne t0, t1, search_create_then_adjust_jump
		#path to skip 1 instruction - default
		#wind down the offset now
		sw zero, 0(t2)
		la t0, DECIDESTACKP
		lw t1, 0(t0)
		addi t1, t1, -1
		sw t1, 0(t0)
		j search_create_continue_inscription
  search_create_then_adjust_jump:
		#adjust skip number
		la t0, DECIDESTACKP
		lw t2, 0(t0)			#t2 holds index
		mv t3, t2
		addi t3, t3, -1
		sw t3, 0(t0)			#decrease stored index
		li t3, 4
		mul t3, t3, t2
		add t0, t3, t0
		lw t3, 0(t0)			#t3 holds depth
		sw zero, 0(t0)
		li t0, 4
		mul t3, t0, t3			#offset needed in bytes
		andi t3, t3, 0x3FF		#ready to insert
		la t0, DECIDESTACKB
		lw t0, 0(t0)
		li t1, 0x30
		addi t2, t2, -1
		mul t1, t2, t1			#base of code
		addi t1, t1, 28
		li t0, 0xB8B93
		slli t3, t3, 20
		or t0, t3, t0
		sw t0, 0(t1)
		j search_create_continue_inscription 
  search_create_test_else:
		la t0, WA_ELSE
		#TODO: else code
  search_create_inscribe:
		#update the depth of the current skip
		la t0, ifflag
		lw t0, 0(t0)
		beqz t0, search_create_continue_inscription
		la t0, DECIDESTACKP
		lw t1, 0(t0)
		li t2, 4
		mul t1, t2, t1
		add t0, t0, t1
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)				#increment and store
		
  search_create_continue_inscription:
		la t0, createwritepoint
		lw t1, 0(t0)
		sw t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 4
		sw t1, 0(t0)
		la t0, WA_SEMI			      #are we finished with create?
		bne t3, t0, search_create_leave
		#tidy up create as we are done
		la t0, CREATEFLAG
		sw zero, 0(t0)			      #back to immediate execution
		li t0, 0x07
		and t0, t0, t1
		beq t0, zero, search_create_address_aligned_ok #already aligned
		addi t1, t1, 0x08
		li t0, 0xFFFFFFF8
		and t1, t1, t0			      #ensure alignment
  search_create_address_aligned_ok:
		la t0, newdictionary
		la t2, dictionary
		lw t3, 0(t0)			      #load address of new word
		sw t3, 0(t2)			      #store address of new word as start for dictionary
		sw t1, 0(t0)			      #update address we will writenext word to
  search_create_leave:
		la s7, outer_loop_tokenize
                tail NEXT

  search_create_exhausted:
		#test for variable etc
		mv a4, t0
		lb t4, 0(a4)
		li a5, 0x23
		#test for address #
		beq t4, a5, search_create_read_address
		li a5, 0x3A 				#:
		# have to treat as a variable
		bge t4, a5, search_create_assign_variable
		#assume we have a number
		lw t2, CURRENT_BASE
		li t3, 16
		beq t2, t3, search_create_check_hex
		li t3, 8
		bne t2, t3, search_create_check_decimal
		j search_create_check_octal

  search_create_check_hex:
		#function call
		#a0 - start address [in]
		#a1 - valid [out]
		#a2 - result [out]
		#a3 - end address [in]
		mv a0, t0
		mv a3, t1
		call func_test_hex
  search_create_test_func_result:
		li t2, 1
		beq a1, t2, search_create_number_on_stack
		la t0, CREATEFLAG
		sw zero, 0(t0)
		tail search_failed

  search_create_check_decimal:
		mv a0, t0
		mv a3, t1
		call func_test_decimal
		j search_create_test_func_result

  search_create_check_octal:
		mv a0, t0
		mv a3, t1
		call func_test_octal
		j search_create_test_func_result

  search_create_assign_variable:
		#word address for VARIN function
		#then write out would-be variable name (up to 24 chars)
		la t3, WA_VARIN
		la a0, createwritepoint
		lw a1, 0(a0)
		sw t3, 0(a1)			      #write out word address in definition
		addi a1, a1, 4
		sw a1, 0(a0)
		#write out var name
		#t0 holds start
		#t1 holds end
		#t2 holds length
		mv a2, t2
		mv a3, t0
		#write out length
		sw a2, 0(a1)
		addi a1, a1, 4
  search_create_raw_var_name:
		lb t5, 0(a3)
		sb t5, 0(a1)
		addi a1, a1, 1
		addi a3, a3, 1
		addi a2, a2, -1
		bne a2, zero, search_create_raw_var_name
		li a2, 24
		sub a2, a2, t2
		li t5, 0x0A
  search_create_ff_var_name:
		sb t5, 0(a1)
		addi a1, a1, 1
		addi a2, a2, -1
		bne a2, zero, search_create_ff_var_name
		#update createwritepoint and bail
		la t0, createwritepoint
		sw a1, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT

  search_create_read_address:
		#hash at first address
		#then check numbers
		
		lw t2, CURRENT_BASE
		addi t0, t0, 1
		li t3, 16
		beq t2, t3, search_create_check_hex_address
		li t3, 8
		bne t2, t3, search_create_check_decimal_address
		j search_create_check_octal_address


  search_create_check_hex_address:
		#function call
		#a0 - start address [in]
		#a1 - valid [out]
		#a2 - result [out]
		#a3 - end of token [in]
		mv a0, t0
		mv a3, t1
		call func_test_hex
  search_create_test_func_result_address:
		li t2, 1
		beq a1, t2, search_create_address_on_stack
		la t0, CREATEFLAG
		sw zero, 0(t0)
		tail search_failed

  search_create_check_decimal_address:
		mv a0, t0
		call func_test_decimal
		j search_create_test_func_result_address

  search_create_check_octal_address:
		mv a0, t0
		call func_test_octal
		j search_create_test_func_result_address

  search_create_number_on_stack:
		la t3, WA_LITERALNUMB
		j search_create_literal_out
  search_create_address_on_stack:
		la t3, WA_LITERALADDR

  search_create_literal_out:		
		la t0, createwritepoint
		lw t1, 0(t0)
		sw t3, 0(t1)			      #write out word address in definition
		sw a2, 4(t1)
		addi t1, t1, 8
		sw t1, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT

		#now number processing functions
		#a0 address [in]
		#a1 valid [out]
		#a2 result [out]
		#a3 end of token [in]
		#a4 base (set in fuction)
  func_test_hex:
		PUSH s0
		PUSH s1
		PUSH s2
		PUSH s3
		PUSH s4
		PUSH s5
		PUSH s6
		PUSH s7
		PUSH s8
		PUSH s9
		PUSH s10
		PUSH s11
		mv a1, zero
		mv a2, zero
		li a4, 16
		
  func_check_hex:
                lb s4, 0(a0)
                li s5, 48                             #check number begins with 0X
                beq s4, s5, func_test_X
                j func_return_hex					#failed
  func_test_X:
                lb s4, 1(a0)
                li s6, 88                             #X
                beq s4, s6, func_build_hex
                j func_return_hex
  func_build_hex:
                sub s3, a3, a0
                add s3, s3, -2
                bge s3, zero, func_hex_entry_likely
                j func_return_hex
  func_hex_entry_likely:
                mv s4, a0 
                addi s4, s4, 2                        #get s4 to point to first numeral
                li s6, 58                             #: (1 > 9 in ascii)
                li s1, 65			      #A
                li s2, 71                             #G
                mv s7, zero                           #total goes in a7
  func_leading_zero_hex:
                lb s10, 0(s4)
                beq s3, zero, func_hex
                beq s10, s5, func_increment_hex      #looking for end of trailing zeros
                j func_hex
  func_increment_hex:
                addi s4, s4, 1
                addi s3, s3, -1
                j func_leading_zero_hex
  func_hex:
                bge s10, s2, func_hex_fail             #too big
                bge s10, s1, func_hex_letter           #A - F
                bge s10, s6, func_hex_fail             #too big
                bge s10, s5, func_hex_number           #0 -9
  func_hex_fail:
                j func_return_hex

  func_hex_letter:
                addi s10, s10, -55
                j func_hex_multi
  func_hex_number:
                addi s10, s10, -48
  func_hex_multi:
                beq s10, zero, func_add_in_hex
                beq s3, zero, func_add_in_hex
                mv s5, s3
  func_hex_multiple:
                mul s10, s10, a4
                addi s5, s5, -1
                bne s5, zero, func_hex_multiple
		
  func_add_in_hex:
                add s7, s7, s10
                beq s3, zero, func_hex_push_it
                add s3, s3, -1
                add s4, s4, 1
                lb s10, 0(s4)
                j func_hex
  func_hex_push_it:
		li a1, 1
		mv a2, s7

  func_return_hex:
		#common return for all number funcs
		POP s11
		POP s10
		POP s9
		POP s8
		POP s7
		POP s6
		POP s5
		POP s4
		POP s3
		POP s2
		POP s1
		POP s0
		ret		


func_test_octal:
		PUSH s0
		PUSH s1
		PUSH s2
		PUSH s3
		PUSH s4
		PUSH s5
		PUSH s6
		PUSH s7
		PUSH s8
		PUSH s9
		PUSH s10
		PUSH s11
		mv a1, zero
		mv a2, zero
		li a4, 8

		li s5, 48
		li s6, 55
		j func_octdec_join
		
 
  func_test_decimal:
		PUSH s0
		PUSH s1
		PUSH s2
		PUSH s3
		PUSH s4
		PUSH s5
		PUSH s6
		PUSH s7
		PUSH s8
		PUSH s9
		PUSH s10
		PUSH s11
		mv a1, zero
		mv a2, zero
		li a4, 10

		li s5, 48
		li s6, 57

  func_octdec_join:				#common octal decimal code
		mv s7, zero
		mv s10, zero
		mv s11, zero
		sub s3, a3, a0
		mv s4, a0
		lb s9, 0(s4)
		li s8, 45
		bne s9, s8, func_octdec_leading_zero_check
		bne s3, zero, func_minus_more_than_nothing
		j func_return_hex		#failed
  func_minus_more_than_nothing:
		li s10, -1
		addi s3, s3, -1
		addi s4, s4, 1
  func_octdec_leading_zero_check:
		lb s9, 0(s4)
		beq s9, s5, func_increment_octdec
		j func_literal
  func_increment_octdec:
		beq s3, zero, func_literal	#output a zero if we are last character
		addi s4, s4, 1
		addi s3, s3, -1
		j func_octdec_leading_zero_check
  func_literal:
		bltu s6, s9, func_literal_fail
		bge s9, s5, func_octdec_continue
  func_literal_fail:
		j func_return_hex
  func_octdec_continue:
		sub s9, s9, s5
		beq s9, zero, func_add_in_octdec
		beq s3, zero, func_add_in_octdec
		mv s8, s3
  func_octdec_multiple:
		mul s9, s9, a4
		add s8, s8, -1
		bne s8, zero, func_octdec_multiple
  func_add_in_octdec:
		add s7, s7, s9
		beq s3, zero, func_push_octdec
		addi s3, s3, -1
		addi s4, s4, 1
		lb s9, 0(s4)
		j func_literal
  func_push_octdec:
		beq s10, zero, func_not_minus
		xori s7, s7, -1
		addi s7, s7, 1
  func_not_minus:
		li a1, 1
		mv a2, s7
		j func_return_hex		#success


  varin_scan_stack:
		#come here with t3 pointing to the word with length
		lw t2, 0(t3)			#t2 holds length
		mv t0, t3
		addi t0, t0, 4			#t0 now points to name
		la t4, BOTTOM_VARS
		lw t3, 0(t4)
		addi t3, t3, 36
  varin_next_check:
		lw t4, 0(t3)
		li a1, 0xFFFFFFFF
		and t4, t4, a1
		li a3, 0xdeadbeef
		beq t4, a3, varin_next_in_dictionary
		j varin_failed
  varin_next_in_dictionary:
		lw t4, -4(t3)
		#compare lengths
		bne t4, t2, varin_tokens_do_not_match
                add a0, t3, -5                        #a0 now points into the name in the var stack
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  varin_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, varin_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, varin_tokens_matched
                addi a0, a0, -1
                addi a1, a1, 1
                j varin_loop_through_token
  varin_tokens_do_not_match:
                add t3, t3, 36                        #advance up the var stack
                la t4, TOP_VARS
                lw t4, 0(t4)
                bge t3, t4, varin_no_match
                j varin_next_check

  varin_tokens_matched:
                #put variable value on the stack
                lw t4, -32(t3)
                PUSH t4
                tail NEXT
  varin_no_match:
                j varin_failed

	
		
