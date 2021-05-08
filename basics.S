#Basic primatives we need to get anything done

.balign 8

  dictionary_top:

	        CODEEND TYPE,  0x01
                WRITECR
                WRITECHAR 0x0A
                WRITECHAR 0x3E                          #> prompt
                tail NEXT

  	        CODEHEADER GETNEXTLINE_IMM, TYPE, 0x0
                #Fetch a line for immediate execution
                MARKINPUTBUFFER INPUT_BUFFER            #ensure buffer starts 'empty'
		mv a0, zero
		la a1, INPUT_BUFFER
		li a2, BUFFERLEN
		li a7, 63
		ecall
		li t0, 1
                mv a2, a0                          #a2 to hold length
                bgeu a2, t0, getnextline_imm_input
                tail NEXT                               #no input
  getnextline_imm_input:
                sw a1, INPUT_START, t0
                add a1, a1, a2                          #a2 has the end of input
                sw a1, INPUT_END, t0
		tail NEXT
          

                CODEHEADER OK, GETNEXTLINE_IMM, 0x00
                lw a0, OKSTATUS
                bne a0, zero, ok_not_ok
                la a0, Ok_msg
                call puts
                tail NEXT
  ok_not_ok:
                addi t0, zero, 1
                bne a0, t0, ok_serious_issue_possibly
                sw zero, OKSTATUS, t0
                tail NEXT
  ok_serious_issue_possibly:
                la a0, Error_msg
                call puts
                sw zero, OKSTATUS, t0
                tail NEXT


                CODEHEADER TOKENIZE_IMM, OK, 0x0       
                #puts 1 on stack if system variables
                #TOKEN_START and TOKEN_END hold valid values
                lw a1, INPUT_END
                lw a0, INPUT_START
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, tokenize_have_data       #buffer has data
  tokenize_all_over:
                tail NEXT
  tokenize_have_data:
                mv t0, a0                             #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                   #t2 space
                addi t3, zero, 0x0A                   #t3 CR
  tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, tokenize_keep_going
                bne t4, t3, tokenize_found_start
                j tokenize_all_over
  tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, tokenize_look_for_start
                j tokenize_all_over                   #got nothing
  tokenize_found_start:
                mv t1, t0                             #t1 to track end of token
  tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, tokenize_end_token
                beq t4, t3, tokenize_end_token
                j tokenize_advance_search
  tokenize_end_token:
                sw t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
		bne t0, t1, tokenize_prepare_sanity_test
		PUSH t0
		jal fix_up_input		      #one character token so check for expansion
		
  tokenize_prepare_sanity_test:
                addi t5, zero, 0x61                   #lowercase a
                addi t6, zero, 0x7B                   #lowercase z + 1
  tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, tokenize_next_sane
                blt t4, t6, tokenize_sanitize
                j tokenize_next_sane
  tokenize_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, tokenize_finished_sanitization
                j tokenize_sanity_test
  tokenize_finished_sanitization:
                sw t0, TOKEN_START, t2
                sw t1, TOKEN_END, t2
                la s8, WA_SEARCH                      #hit search directly now
                li t2, 1
                PUSH t2                               #indicate TOKEN_ values are valid
                tail RUN


		CODEHEADER SEARCH, TOKENIZE_IMM, 0x0
                POP a0
                beq a0, zero, search_no_token     
                addi t0, zero, 1
                bne a0, t0, search_bad_pop
                lw t0, TOKEN_START                    #token values are valid
                lw t1, TOKEN_END
		la t2, CREATEFLAG
		lw t2, 0(t2)
		beq t2, zero, search_continue	      #we are in immediate mode
                j search_create_continue
  search_no_token:
                addi t0, zero, 2                      #should never get here - so warn if we do
                sw t0, OKSTATUS, t1
                tail NEXT
  search_bad_pop:
                addi t0, zero, 2
                sw t0, OKSTATUS, t1
                PUSH a0                               #restore bad POP
                tail NEXT
  search_continue:
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                lw t3, 0(t4)
  search_next_in_dictionary:
                lb t4, 12(t3)
                bne t4, t2, search_tokens_do_not_match
                add a0, t3, 16                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_loop_through_token
                
  search_tokens_do_not_match:
                lw t3, 8(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_exhausted        #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                addi t3, t3, 4                        #address that points to the code
                PUSH t3                               #store word address on the call stack
                tail EXECUTE

  search_exhausted:
                #test if this is a variable (alpha first char)
                mv a4, t0
                li a5, 0x3A
                lb t4, 0(a4)
                bge t4, a5, search_check_variables
                j search_check_numbers
  search_check_variables:
                j search_scan_variable_stack
  search_check_numbers:
                lw t2, CURRENT_BASE
                li t3, 16
                beq t2, t3, search_check_hex
                li t3, 8
                bne t2, t3, search_assume_decimal
                j search_check_octal                  #go to octal code
  search_assume_decimal:
                j search_setup_decimal
                nop
  search_check_octal:
                li t2, 8
                li t5, 48
                li t6, 55
                j search_octal_decimal_join
  search_setup_decimal:
                li t2, 10                             #assume we are decimal - trust but verify
                li t5, 48                             #ascii 0
                li t6, 57
  search_octal_decimal_join:
                mv a6, zero
                mv a7, zero                           #a7 will hold the number
                sub t3, t1, t0                        #t3 holds radix power needed
                mv a4, t0                             #a4 points to first digit
                lb t4, 0(a4)
                li a5, 45
                bne t4, a5, search_leading_zero_check
                bne t3, zero, search_minus_more_than_nothing
                j search_failed
  search_minus_more_than_nothing:
                addi a6, zero, -1
                addi t3, t3, -1
                addi a4, a4, 1
  search_leading_zero_check:
                lb t4, 0(a4)                          #look at this
                beq t4, t5, search_increment_octdec   #is it zero?
                j search_literal
  search_increment_octdec:
                beq t3, zero, search_literal          #output 0 if nothing else
                addi a4, a4, 1                    
                addi t3, t3, -1
                j search_leading_zero_check           #if leading zero addvance
  search_check_hex:
                lb t4, 0(t0)
                li t5, 48                             #check number begins with 0X
                beq t4, t5, search_test_X
                j search_failed
  search_test_X:
                lb t4, 1(t0)
                li t6, 88                             #X
                beq t4, t6, search_build_hex
                j search_failed
  search_build_hex:
                sub t3, t1, t0
                add t3, t3, -2
                bge t3, zero, search_hex_entry_likely
                j search_failed
  search_hex_entry_likely:
                mv a4, t0                             
                addi a4, a4, 2                        #get a4 to point to first numeral
                li t6, 58                             #: (1 > 9 in ascii)
                li a1, 65
                li a2, 71                             #G
                mv a7, zero                           #total goes in a7
  search_leading_zero_hex:
                lb t4, 0(a4)
                beq t3, zero, search_hex
                beq t4, t5, search_increment_hex      #looking for end of trailing zeros
                j search_hex
  search_increment_hex:
                addi a4, a4, 1
                addi t3, t3, -1
                j search_leading_zero_hex
  search_hex:
                bge t4, a2, search_hex_fail             #too big
                bge t4, a1, search_hex_letter           #A - F
                bge t4, t6, search_hex_fail             #too big
                bge t4, t5, search_hex_number           #0 -9
  search_hex_fail:
                j search_failed
                
  search_hex_letter:
                addi t4, t4, -55
                j search_hex_multi
  search_hex_number:
                addi t4, t4, -48
  search_hex_multi:
                beq t4, zero, search_add_in_hex
                beq t3, zero, search_add_in_hex
                mv a5, t3
  search_hex_multiple:
                mul t4, t4, t2
                addi a5, a5, -1
                bne a5, zero, search_hex_multiple
  search_add_in_hex:
                add a7, a7, t4
                beq t3, zero, search_hex_push_it
                add t3, t3, -1
                add a4, a4, 1
                lb t4, 0(a4)
                j search_hex
  search_hex_push_it:
                PUSH a7                               #save number on stack
                la t0, WA_TOKENIZE_IMM                #keep tokenizing
                PUSH t0
                tail EXECUTE
                nop
  search_literal:
                bltu t6, t4, search_literal_fail      #digit above max range
                bge t4, t5, search_octdec_continue    #digit in range
  search_literal_fail:
                j search_failed
  search_octdec_continue:
                sub t4, t4, t5                        #reduce to number
                beq t4, zero, search_add_in_octdec
                beq t3, zero, search_add_in_octdec
                mv a5, t3
  search_octdec_multiple:
                mul t4, t4, t2
                addi a5, a5, -1
                bne a5, zero, search_octdec_multiple
  search_add_in_octdec:
                add a7, a7, t4
                beq t3, zero, search_push_octdec
                addi t3, t3, -1
                addi a4, a4, 1
                lb t4, 0(a4)
                j search_literal
  search_push_octdec:
                beq a6, zero, search_not_minus        #not a negative number
                xori a7, a7, -1                       #is a negative
                addi a7, a7, 1
  search_not_minus:
                PUSH a7
  search_var_reentry:
                la t0, WA_TOKENIZE_IMM
                PUSH t0
                tail EXECUTE

  search_failed:
                la t0, NotOk_msg
                addi t1, zero, 24                     #error message is 24 chars long 
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                lw a1, 0(t0)
                la t1, TOKEN_END
                lw a2, 0(t1)
                sub a2, a2, a1
                addi a2, a2, 1
                call write                            #output error message
                addi t0, zero, 1
                sw t0, OKSTATUS, t1
                tail NEXT
  search_scan_variable_stack:
                #now scan for a variable name
                lw t0, TOKEN_START                    #token values are valid
                lw t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, BOTTOM_VARS
                lw t3, 0(t4)
		li a1, 36
		add t3, t3, a1
  search_var_next_check:
		lw t4, 0(t3)
		li a1, 0xFFFFFFFF
		and t4, t4, a1
		li a3, 0xdeadbeef
		beq t4, a3, search_var_next_in_dictionary
		j search_failed
  search_var_next_in_dictionary:
                lw t4, -4(t3)
		#compare lengths
                bne t4, t2, search_var_tokens_do_not_match
                add a0, t3, -5                        #a0 now points into the name in the var stack
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_var_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_var_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_var_tokens_matched
                addi a0, a0, -1
                addi a1, a1, 1
                j search_var_loop_through_token

  search_var_tokens_do_not_match:
                add t3, t3, 36                        #advance up the var stack
		la t4, TOP_VARS
		lw t4, 0(t4)
		bge t3, t4, search_var_no_match
                j search_var_next_check

  search_var_tokens_matched:
		#put variable value on the stack
		lw t4, -32(t3)
		PUSH t4
		j search_var_reentry
  search_var_no_match:
		j search_failed


                CODEHEADER DECIMAL, SEARCH, 0x01
                addi t1, zero, 10
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER HEX, DECIMAL, 0x01
                addi t1, zero, 16
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER OCTAL, HEX, 0x01
                addi t1, zero, 8
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER BINARY, OCTAL, 0x01
                addi t1, zero, 2
                sw t1, CURRENT_BASE, t0
                tail NEXT

                #semi for outer loop
		CODEHEADER OLSEMI, BINARY, 0x0
                la s7, outer_loop
                tail NEXT
		
		#semi for the rest of us
                CODEHEADER SEMI, OLSEMI, 0x01
                lw s7, 0(s9)
                addi s9, s9, STACKOFFSET
                tail NEXT

                CODEHEADER DOT, SEMI, 0x01
                lw t0, CURRENT_BASE
                POP a2                            #get item on stack
                la a0, SCRATCH_PAD                #sprintf uses this
                addi t1, zero, 16
                beq t0, t1, ps_format_hex
                addi t1, zero, 8
                beq t0, t1, ps_format_octal
                addi t1, zero, 2
                beq t0, t1, ps_format_binary
                la a1, decimalout
                j dot_output
  ps_format_hex:
                la a1, hexout
                j dot_output
  ps_format_octal:
                la a1, octalout
                j dot_output
  dot_output:
                addi a3, zero, 3
                call sprintf
                la t0, SCRATCH_PAD
                mv t1, a0
                WRITESTRINGR t0, t1
                tail NEXT
  ps_format_binary:                             #binary output not supported by sprintf, so do it ourselves
                addi t0, zero, 1
                addi t1, zero, 31
  dot_test_against_shift:
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dot_start_binary  #past any trailing zeros - so start output
                sub t1, t1, t0
                beq t1, zero, dot_last_and_out
                j dot_test_against_shift
  dot_start_binary:
                PUSH a2
                PUSH t0
                PUSH t1
                PUSH t3
                WRITECHAR 0x31                #output 1
  dot_start_pop:
                POP t3
                POP t1
                POP t0
                POP a2
  dot_shift_and_test:
                sub t1, t1, t0
                beq t1, zero, dot_last_and_out
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dot_start_binary
                PUSH a2                     #got a zero so output that
                PUSH t0
                PUSH t1
                PUSH t3
                WRITECHAR 0x030
                j dot_start_pop
  dot_last_and_out:
                and a0, a2, t0
                beq a0, zero, dot_zero_and_out
                WRITECHAR 0x31
                j dot_output_b_and_space
  dot_zero_and_out:
                WRITECHAR 0x30
  dot_output_b_and_space:
                WRITECHAR 0x62            #b
                WRITECHAR 0x20            #space
                j NEXT

  fix_up_input:
		#code to expand standard FORTH commands
		#to things we can use in RISC-V assembly
		#CURRENT EXPANSIONS
		# .  --> DOT
		# ;  --> SEMI
		# +  --> ADD
		# -  --> SUB
		# *  --> MUL
		# /  --> DIV
		# :  --> COLON
		# !  --> STORE
		# >  --> GT
                # <  --> LT
                # =  --> EQUALS
		POP a0				#unexpanded token address
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
  fix_up_start:
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)

  fix_up_colon:
		li t2, 0x3A
		bne t2, t1, fix_up_dot
		li t3, 0x43
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x4C
		sb t3, 2(a2)
		li t3, 0x4F
		sb t3, 3(a2)
		li t3, 0x4E
		sb t3, 4(a2)
		addi a2, a2, 4
		j fix_up_done

  fix_up_dot:
		li t2, 0x2E
		bne t2, t1, fix_up_semi
		li t3, 0x44
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x54
		sb t3, 2(a2)
		addi a2, a2, 2
		j fix_up_done
  fix_up_semi:
		li t2, 0x3B
		bne t2, t1, fix_up_add
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x4D
		sb t3, 2(a2)
		li t3, 0x49
		sb t3, 3(a2)
		addi a2, a2, 3
		j fix_up_done

  fix_up_add:
		li t2, 0x2B
		bne t2, t1, fix_up_sub
		li t3, 0x41
		sb t3, 0(a2)
		li t3, 0x44
		sb t3, 1(a2)
		li t3, 0x44
		sb t3, 2(a2)
		addi a2, a2, 2
		j fix_up_done
		
  fix_up_sub:
		li t2, 0x2D
		bne t2, t1, fix_up_mul
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x55
		sb t3, 1(a2)
		li t3, 0x42
		sb t3, 2(a2)
		addi a2, a2, 2
		j fix_up_done
		
  fix_up_mul:
		li t2, 0x2A
		bne t2, t1, fix_up_div
		li t3, 0x4D
		sb t3, 0(a2)
		li t3, 0x55
		sb t3, 1(a2)
		li t3, 0x4C
		sb t3, 2(a2)
		addi a2, a2, 2
		j fix_up_done
		
  fix_up_div:
		li t2, 0x2F
		bne t2, t1, fix_up_store
		li t3, 0x44
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x56
		sb t3, 2(a2)
		addi a2, a2, 2
		j fix_up_done

  fix_up_store:
		li t2, 0x21
		bne t2, t1, fix_up_gt
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		li t3, 0x4F
		sb t3, 2(a2)
		li t3, 0x52
		sb t3, 3(a2)
		li t3, 0x45
		sb t3, 4(a2)
		addi a2, a2, 4
		j fix_up_done

  fix_up_gt:
		li t2, 0x3E
		bne t2, t1, fix_up_lt
		li t3, 0x47
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		addi a2, a2, 1
		j fix_up_done 

  fix_up_lt:
		li t2, 0x3C
		bne t2, t1, fix_up_equals
		li t3, 0x4C
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		addi a2, a2, 1
		j fix_up_done

  fix_up_equals:
		li t2, 0x3D
		bne t2, t1, fix_up_finished
		li t3, 0x45
		sb t3, 0(a2)
		li t3, 0x51
		sb t3, 1(a2)
		li t3, 0x55
		sb t3, 2(a2)
		li t3, 0x41
		sb t3, 3(a2)
		li t3, 0x4C
		sb t3, 4(a2)
		li t3, 0x53
		sb t3, 5(a2)
		addi a2, a2, 5
		j fix_up_done


  fix_up_finished:
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret

  fix_up_done:
		mv t0, a3
		mv t1, a2	
                j tokenize_finished_sanitization 

.include "integer.S"
.include "stackop.S"
.include "listwords.S"
.include "loops.S"




          
