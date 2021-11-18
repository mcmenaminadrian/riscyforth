# riscyforth is licenced under GPL v2
# copyright, Adrian McMenamin, 2021
# search-create - search for word addresses when we are in create mode


  search_create_continue:
	        sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                ld t3, 0(t4)
  search_create_next_in_dictionary:
                lbu t4, 24(t3)
                bne t4, t2, search_create_tokens_do_not_match
                add a0, t3, 32                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_create_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, search_create_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_create_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_create_loop_through_token

  search_create_tokens_do_not_match:
                ld t3, 16(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_create_exhausted        #at the end of the dictionary
                j search_create_next_in_dictionary

  search_create_tokens_matched:
                addi t3, t3, 8                        #address that points to the code
		#if this is just a comment we don't care - get to the next CR
		la t0, WA_COMMENT
		bne t3, t0, search_create_check_bracket
		j search_create_dispose_of_comment
  search_create_check_bracket:
		la t0, WA_BRACKET
		bne t3, t0, search_create_check_paren
		la s7, outer_loop_tokenize
		tail bracket_go	
  search_create_check_paren:
		la t0, WA_P				#open bracket
		bne t3, t0, search_create_check_colon
		la s7, outer_loop_tokenize
		#read ahead until we hit a closing parenthesis
		tail paren_go	
  search_create_check_colon:
		#now check it is allowed
		la t0, WA_COLON			      #cannot nest definitions
		bne t3, t0, search_create_literal
		la t0, CREATEFLAG
		sd zero, 0(t0)
  search_create_report_error:
		tail search_failed		      #report error
  search_create_literal:
		la t0, WA_LITERAL
		bne t3, t0, search_create_does_
		ld a2, 0(sp)
		addi sp, sp, 8
		tail search_create_number_on_stack   #write out a literal
  search_create_does_:
		la t0, WA_DOES_
		bne t3, t0, search_create_allowed
		#write out DOES_ word address and tidy up
		#emulating SEMI
  search_create_keep_does_:				#rejoin here	
		la t0, createwritepoint
		ld t1, 0(t0)
		la t5, INDOES
		ld t6, 0(t5)
		bnez t6, search_create_continue_indoes
		sd t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 8
		#set INDOES to 1
		li t6, 1
		sd t6, 0(t5)
  search_create_continue_indoes:
		#now copy out the following text until we hit semi
		la a0, INPUT_START
		ld a1, 0(a0)
		la t5, INPUT_END
		ld t6, 0(t5)
		li a2, 59				#;
		li a7, 10				#\n
  search_create_does_copy:
		lbu a3, 0(a1)
		sb a3, 0(t1)
		addi t1, t1, 1
		addi a1, a1, 1
		beq a3, a7, search_create_does_keep_on
		beq a3, a2, search_create_does_copy_done		
		bgt a1, t6, search_create_does_keep_on
		j search_create_does_copy
  search_create_does_copy_done:
		li a3, 0x0A
		sb a3, 0(t1)
		addi t1, t1, 1
		sd a1, 0(a0)
		#check alignment for writing
		li t5, 0x07
		and t6, t1, t5
		beqz t6, search_create_does_update_wp
		li t4, 0x08
		sub t5, t4, t6
		add t1, t1, t5
  search_create_does_update_wp:
		sd t1, 0(t0)
		la t0, CREATEFLAG
		sd zero, 0(t0)			      #back to immediate execution
		la t0, newdictionary
		la t2, dictionary
		ld t3, 0(t0)			      #load address of new word
		sd t3, 0(t2)			      #store address of new word as start for dictionary
		sd t1, 0(t0)			      #update address we will writenext word to
		la s7, outer_loop_tokenize
		fence.i 				#ensure cache coherency
		la t0, INDOES
		sd zero, 0(t0)				#we're done with DOES so reset flag
		tail NEXT
  search_create_does_keep_on:
		#update write point
		sd t1, 0(t0)
		la t3, INFILELOAD
		ld t4, 0(t3)
		beqz t4, search_create_does_outer_loop
		la s7, outer_loop_tokenize		#pull in next line from file
		la t0, LOADLINESETUP
		sd zero, 0(t0)
		tail NEXT
  search_create_does_outer_loop:
		la s7, outer_loop			#not done with does so require more input
		tail NEXT
	
  search_create_allowed:
		#handle in the same way as printed strings generally
		la t0, WA_ABORTCOMM
		bne t3, t0, search_encsq
                la t3, WA__ABORTCOMM
		add a5, a5, 4			      #clear the command
		tail embed_encsq
  search_encsq:
		#test for DOTQ (ie string printing)
		la t0, WA_DOTQ
		bne t3, t0, search_tick
		#substitute WA__DOTQ
		la t3, WA__DOTQ
		#jump to code that will count string and embed length and literal
		tail embed_encsq
  search_tick:
		la t0, WA_TICK
		bne t3, t0, search_is
		#substitute WA__TICK
		la t3, WA__TICK
		tail embed_tick
  search_is:
		la t0, WA_IS
		bne t3, t0, search_to
		#subsitute WA__IS
		la t3, WA__IS
		tail embed_tick
  search_to:
	 	la t0, WA_TO
		bne t3, t0, search_char
		#substitute WA__TO
		la t3, WA__TO
		tail embed_to
  search_char:
		la t0, WA_CHAR
		bne t3, t0, search_wa_again
		la t3, WA__CHAR
		tail embed_tick
  search_wa_again:
		#test for AGAIN
		la t0, WA_AGAIN
		bne t3, t0, search_wa_until
		#insert three instruction simple loop back
		la t3, WA__AGAIN			#substitute
		j search_create_inscribe
  search_wa_until:
		#test for UNTIL
		la t0, WA_UNTIL
		bne t3, t0, search_loop_replace_do
		#insert three instruction simple loop back
		la t3, WA__UNTIL			#substitute
		j search_create_inscribe
  search_loop_replace_do:
		la t0, WA_DO
		bne t3, t0, search_loop_replace_loop
		la t3, WA__DO
		j search_create_inscribe
  search_loop_replace_loop:
		la t0, WA_LOOP
		bne t3, t0, search_loop_replace_plusloop
		la t3, WA__LOOP
		j search_create_inscribe
  search_loop_replace_plusloop:
		la t0, WA_PLUSLOOP
		bne t3, t0, search_loop_replace_unloop
		la t3, WA__PLUSLOOP
		j search_create_inscribe
  search_loop_replace_unloop:
		la t0, WA_UNLOOP
		bne t3, t0, search_loop_replace_leave
		la t3, WA__UNLOOP
		j search_create_inscribe
  search_loop_replace_leave:
		la t0, WA_LEAVE
		bne t3, t0, search_loop_replace_recurse
		la t3, WA__LEAVE
		j search_create_inscribe
  search_loop_replace_recurse:
		la t0, WA_RECURSE
		bne t3, t0, search_loop_replace_i
		la t0, newdictionary
		ld t1, 0(t0)
		addi t3, t1, 0x8
		j search_create_inscribe				#t3 has address of word to drop in	
  search_loop_replace_i:
		la t0, WA_I
		bne t3, t0, search_loop_replace_j
		la t3, WA__I
		j search_create_inscribe
  search_loop_replace_j:
		la t0, WA_J
		bne t3, t0, search_replace_exit
		la t3, WA__J
		j search_create_inscribe
  search_replace_exit:
		la t0, WA_EXIT
		bne t3, t0, search_create_test_conditionals
		la t3, WA__EXIT
		j search_create_inscribe
  search_create_test_conditionals:
		la t0, WA_WHILE
		bne t3, t0, search_create_test_if
		la t3, WA__WHILE
		j search_create_while_out
		#test for conditionals
  search_create_test_if:
		la t0, WA_IF
		bne t3, t0, search_create_test_else
  search_create_in_if:
		#if code
		la t3, WA__IF
		j search_create_if_out
  search_create_test_else:
		la t0, WA_ELSE
		bne t0, t3, search_create_test_repeat
		la t3, WA__ELSE
		j search_create_else_out
  search_create_test_repeat:
		la t0, WA_REPEAT
		bne t0, t3, search_create_test_then
		#are we in if mode
		call get_iffmode
		beqz a0, search_create_bad_ifmode
		call get_flag_mode
		bnez a0, search_create_test_repeat_state
		la a0, WA__REPEAT				#write out _REPEAT
		tail transition_if_repeat
  search_create_test_repeat_state:
		#test for then->repeat
		beqz a1, search_create_test_else_repeat
		la a0, WA__REPEAT
		tail transition_then_repeat
  search_create_test_else_repeat:
		beqz a2, search_create_bad_ifmode
		tail transition_else_then
  search_create_test_then:
		la t0, WA_THEN
		bne t0, t3, search_create_inscribe
		#are we in if mode
		call get_iffmode
		beqz a0, search_create_bad_ifmode
		call get_flag_mode
		bnez a0, search_create_test_then_state
		tail transition_if_then
  search_create_test_then_state:
		#test for then->then
		beqz a1, search_create_test_else_then
		tail transition_then_then
  search_create_test_else_then:
		beqz a2, search_create_bad_ifmode	#bad state
		tail transition_else_then
  search_create_bad_ifmode:
		#error
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail search_failed

  search_create_inscribe:
		#update the depth of the current skip if needed
		call get_iffmode
		beqz a0, search_create_continue_test_until
		SETUP_CONDITIONAL_CALL
		call increment_current_skip
  search_create_continue_test_until:
		#test for special case
		la t0, WA__UNTIL
		beq t0, t3, search_create_add_until_backcount
		la t0, WA__AGAIN
		bne t0, t3, search_create_continue_inscription
  search_create_add_until_backcount:
		#setup call to write additional WA__UNTIL stuff
		mv a0, t3
		call compile_in_until
		bnez a0, search_create_leave
		j search_create_bad_ifmode
  search_create_continue_inscription:
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 8
		sd t1, 0(t0)
		#now test for base changes
		#and if present update base to ensure input recognised
		la t0, WA_HEX
		bne t3, t0, search_create_test_decimal
		li t1, 16
		sd t1, CURRENT_BASE, t0
		j search_create_leave
  search_create_test_decimal:
		la t0, WA_DECIMAL
		bne t3, t0, search_create_test_octal
		li t1, 10
		sd t1, CURRENT_BASE, t0
		j search_create_leave
  search_create_test_octal:
		la t0, WA_OCTAL
		bne t3, t0, search_create_test_binary
		li t1, 8
		sd t1, CURRENT_BASE, t0
		j search_create_leave
  search_create_test_binary:
		la t0, WA_BINARY
		bne t3, t0, search_create_test_semi
		li t1, 2
		sd t1, CURRENT_BASE, t0
		j search_create_leave
  search_create_test_semi:
		la t0, WA_SEMI			      #are we finished with create?
		bne t3, t0, search_create_leave
		#tidy up create as we are done
		sd zero, MULTILINE, a0
		la t0, CREATEFLAG
		sd zero, 0(t0)			      #back to immediate execution
		li t0, 0x07
		and t0, t0, t1
		beq t0, zero, search_create_address_aligned_ok #already aligned
		addi t1, t1, 0x08
		li t0, 0xFFFFFFFFFFFFFFF8
		and t1, t1, t0			      #ensure alignment
  search_create_address_aligned_ok:
		la t0, newdictionary
		la t2, dictionary
		ld t3, 0(t0)			      #load address of new word
		sd t3, 0(t2)			      #store address of new word as start for dictionary
		sd t1, 0(t0)			      #update address we will writenext word to
  search_create_leave:
		la s7, outer_loop_tokenize
		fence.i 				      #ensure cache coherency
                tail NEXT

  search_create_exhausted:
		#test for variable etc
		mv a4, t0
		lbu t4, 0(a4)
		li a5, 0x23
		#test for address #
		beq t4, a5, search_create_read_address
		li a5, 0x3A 				#:
		#if not a number then a fail 
		bleu t4, a5, search_create_handle_number
		j variable_gone_bad
  search_create_handle_number:
		ld t2, CURRENT_BASE
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
		sd zero, 0(t0)
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

  search_create_read_address:
		#hash at first address
		#then check numbers
		
		ld t2, CURRENT_BASE
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
		sd zero, 0(t0)
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
		ld t1, 0(t0)
		sd t3, 0(t1)			      #write out word address in definition
		sd a2, 8(t1)
		addi t1, t1, 16
		sd t1, 0(t0)
		la s7, outer_loop_tokenize
		#update the depth of the current skip if needed
		call get_iffmode
		beqz a0, search_create_literal_go
		SETUP_CONDITIONAL_CALL
		call increment_current_skip
		SETUP_CONDITIONAL_CALL
		call increment_current_skip
  search_create_literal_go:
		fence.i
		tail NEXT

		#now number processing functions
		#a0 address [in]
		#a1 valid [out]
		#a2 result [out]
		#a3 end of token [in]
		#a4 base (set in fuction)
  func_test_hex:
		add sp, sp, -96
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		sd s5, 40(sp)
		sd s6, 48(sp)
		sd s7, 56(sp)
		sd s8, 64(sp)
		sd s9, 72(sp)
		sd s10, 80(sp)
		sd s11, 88(sp)
		mv a1, zero
		mv a2, zero
		li a4, 16
		
  func_check_hex:
                lbu s4, 0(a0)
                li s5, 48                             #check number begins with 0X
                beq s4, s5, func_test_X
                j func_return_hex					#failed
  func_test_X:
                lbu s4, 1(a0)
		and s4, s4, 0x5F
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
                lbu s10, 0(s4)
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
                lbu s10, 0(s4)
                j func_hex
  func_hex_push_it:
		li a1, 1
		mv a2, s7

  func_return_hex:
		#common return for all number funcs
		ld s11, 88(sp)
		ld s10, 80(sp)
		ld s9, 72(sp)
		ld s8, 64(sp)
		ld s7, 56(sp)
		ld s6, 48(sp)
		ld s5, 40(sp)
		ld s4, 32(sp)
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 96
		ret		


func_test_octal:
		add sp, sp, -96
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		sd s5, 40(sp)
		sd s6, 48(sp)
		sd s7, 56(sp)
		sd s8, 64(sp)
		sd s9, 72(sp)
		sd s10, 80(sp)
		sd s11, 88(sp)
		mv a1, zero
		mv a2, zero
		li a4, 8

		li s5, 48
		li s6, 55
		j func_octdec_join
		
 
  func_test_decimal:
		add sp, sp, -96
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		sd s5, 40(sp)
		sd s6, 48(sp)
		sd s7, 56(sp)
		sd s8, 64(sp)
		sd s9, 72(sp)
		sd s10, 80(sp)
		sd s11, 88(sp)
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
		lbu s9, 0(s4)
		li s8, 45
		bne s9, s8, func_octdec_leading_zero_check
		bne s3, zero, func_minus_more_than_nothing
		j func_return_hex		#failed
  func_minus_more_than_nothing:
		li s10, -1
		addi s3, s3, -1
		addi s4, s4, 1
  func_octdec_leading_zero_check:
		lbu s9, 0(s4)
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
		lbu s9, 0(s4)
		j func_literal
  func_push_octdec:
		beq s10, zero, func_not_minus
		xori s7, s7, -1
		addi s7, s7, 1
  func_not_minus:
		li a1, 1
		mv a2, s7
		j func_return_hex		#success
  embed_to:
  embed_tick:
		#embed string - but don't process it in any way
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)				#write out word address
		PUSH t1					# save for later
		#find length
		call tick_start_looking
		#t0 has start of token
		#t1 has end of token
		addi t1, t1, -1
		mv t2, t0
		mv t3, t1
		sub a0, t3, t2
		addi a0, a0, 1
		POP t1
		sd a0, 8(t1)				#write out length
		addi t1, t1, 16				#prepare to embed
		mv a2, a0
		mv a3, t0
		mv a5, t1
  tick_embed_code:
		beqz a2, tick_embed_check_alignment
		lbu a4, 0(a3)
		sb a4, 0(a5)
		addi a2, a2, -1
		addi a5, a5, 1
		addi a3, a3, 1
		j tick_embed_code
  tick_embed_check_alignment:
		#need to ensure alignment of output maintained
		#a1 holds length
		mv a1, a0
		li a0, 0x07
		li a2, 0x08
		and a3, a1, a0
		sub a3, a2, a3
		add a1, a1, a3
		add t1, t1, a1
		la a0, createwritepoint
		sd t1, 0(a0)				#advance writepoint
		call get_iffmode			#handle conditionals
		beqz a0, embed_tick_done
		#increment the conditionals
		addi a1, a1, 16				#command and length
		srli a5, a1, 3
  embed_tick_skiploop:
		SETUP_CONDITIONAL_CALL
		call increment_current_skip
		addi a5, a5, -1
		beq a5, zero, embed_tick_done
		j embed_tick_skiploop
  embed_tick_done:
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT

  embed_encsq:
		#embed string - after we count how long it is
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      	#write out word address in definition
		#now get length
		mv t0, a5
		addi t0, t0, 3			      	#pass the opening "
		mv a0, t0
		li a1, 0
		li a2, 0x201				#max length
		li t2, 0x22				#"
  embed_encsq_check_next:
		lbu a3, 0(a0)
		beq a3, t2, embed_encsq_gotlength
		addi a0, a0, 1
		addi a1, a1, 1
		blt a1, a2, embed_encsq_check_next
		la t0, String_err
		li t1, 18
		WRITESTRINGR t0, t1
		WRITECR
		tail NEXT				#failed
  embed_encsq_gotlength:
		#write out the length
		sd a1, 8(t1)
		addi t1, t1, 16				#prepare to embed the string
		#t0 points to the start of the string in buffer
		#a1 holds its length
		#t1 the write point
		mv a2, a1				#countdown
		mv a3, t0
  embed_encsq_embed:
		beqz a2, embed_encsq_checkalignment
		lbu a4, 0(a3)
		sb a4, 0(t1)
		addi a2, a2, -1
		addi a3, a3, 1
		addi t1, t1, 1
		j embed_encsq_embed
  embed_encsq_checkalignment:
		#need to ensure alignment of output maintained
		#a1 holds length
		li a0, 0x07
		li a2, 0x08
		la t1, INPUT_START
		ld t0, 0(t1)
		add t0, t0, a1
		addi t0, t0, 2				#account for "
		sd t0, 0(t1)
		and t0, a1, a0
		beqz t0, embed_encsq_alignmentadjusted
		sub t2, a2, t0
		add a1, a1, t2
  embed_encsq_alignmentadjusted:
		addi a1, a1, 16				#account for length too
		la t1, createwritepoint
		ld t0, 0(t1)
		add t0, t0, a1
		sd t0, 0(t1)
		call get_iffmode
		beqz a0, embed_encsq_done
		#increment the conditionals
		srli a5, a1, 3
  embed_encsq_skiploop:
		SETUP_CONDITIONAL_CALL
		call increment_current_skip
		addi a5, a5, -1
		beq a5, zero, embed_encsq_done
		j embed_encsq_skiploop
  embed_encsq_done:
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT


  search_create_dispose_of_comment:
		#this code just takes us beyond the current comment
		#no need to write out a comment word - just delay execution for nothing
		#only need to check if we are in MULTILINE
		la t0, MULTILINE
		ld t1, 0(t0)
		la t0, INPUT_START
		la t2, INPUT_END
		ld t3, 0(t2)
		bnez t1, search_create_move_through_comment
  search_create_comment_done:
		sd t3, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT
  search_create_move_through_comment:
		#we are in MULTILINE mode - so search for next CR
		li t4, 10
		ld t1, 0(t0)
  search_create_keep_processing_comment:
		beq t1, t3, search_create_comment_done
		lb t5, 0(t1)
		addi t1, t1, 1
		bne t4, t5, search_create_keep_processing_comment
		sd t1, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT
