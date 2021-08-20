#Basic primatives we need to get anything done

.balign 8

  dictionary_top:

	        CODEEND TYPEPROMPT,  0x01
                WRITECR
                WRITECHAR 0x0A
                WRITECHAR 0x3E                          #> prompt
                tail NEXT

  	        CODEHEADER GETNEXTLINE_IMM, TYPEPROMPT, 0x0
                #Fetch a line for immediate execution
                MARKINPUTBUFFER INPUT_BUFFER            #ensure buffer starts 'empty'
  getnextline_imm_entry:
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
                sd a1, INPUT_START, t0
                add a1, a1, a2                          #a2 has the end of input
                sd a1, INPUT_END, t0
		tail NEXT

		CODEHEADER GETLINE, GETNEXTLINE_IMM, 0x01
		#Fetch a line - not available for tokenization
		mv a0, zero
		la a1, INPUT_BUFFER
		li a2, BUFFERLEN
		li a7, 63
		ecall
		PUSH a1				#where text can be found
		PUSH a0				#length of inputted text
		la a0, INPUT_BUFFER		#ensure no tokenization
		sd a0, INPUT_START, t0
		sd a0, INPUT_END, t0
		tail NEXT

		CODEHEADER DROPINPUT, GETLINE, 0x01
		#stop input line being processed
		la t0, INPUT_END
		ld t0, 0(t0)
		la t1, INPUT_START
		sd t0, 0(t1)
		tail NEXT
          
                CODEHEADER OK, DROPINPUT, 0x00
                la a0, OKSTATUS
		ld a0, 0(a0)
                bne a0, zero, ok_not_ok
                la a0, Ok_msg
                call puts
                tail NEXT
  ok_not_ok:
                addi t0, zero, 1
                bne a0, t0, ok_serious_issue_possibly
                sd zero, OKSTATUS, t0
                tail NEXT
  ok_serious_issue_possibly:
                la a0, Error_msg
                call puts
                sd zero, OKSTATUS, t0
                tail NEXT


                CODEHEADER TOKENIZE_IMM, OK, 0x0       
                #puts 1 on stack if system variables
                #TOKEN_START and TOKEN_END hold valid values
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, tokenize_normal
		la t0, LOADLINESETUP
		ld t0, 0(t0)
		bnez t0, tokenize_normal
  pull_in_another:
		jal load_get_next_line		      #suck in a line
  tokenize_normal:
                la a1, INPUT_END
		ld a1, 0(a1)
                la a0, INPUT_START
		ld a0, 0(a0)
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, tokenize_have_data       #buffer has data
  tokenize_all_over:
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, tokenize_really_all_over
		la t0, LOADLINESETUP
		sd zero, 0(t0)
  tokenize_really_all_over:
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
                sd t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
		sub a0, t1, t0			      #a0 has length of token - 1
		bnez a0, tokenize_test_length_two
		li a0, 0x41			      #A
		li a1, 0x5A			      #Z
		li a2, 0x61			      #a
		li a3, 0X7A			      #z
		lb a4, 0(t0)
		blt a4, a0, tokenize_fix_up_single
		bltu a4, a0, tokenize_prepare_sanity_test
		blt a4, a2, tokenize_fix_up_single
		bltu a4, a3, tokenize_prepare_sanity_test
		j tokenize_fix_up_single
  tokenize_test_length_two:
		li a1, 1			      #test if input is of length 2
		bne a0, a1, tokenize_test_length_six
		PUSH t0
		jal fix_up_length_two
		j tokenize_prepare_sanity_test
  tokenize_fix_up_single:
		PUSH t0
		jal fix_up_input		      #one character token so check for expansion
		j tokenize_prepare_sanity_test
  tokenize_test_length_six:
		li a1, 5
		bne a0, a1, tokenize_prepare_sanity_test
		PUSH t0
		jal fix_up_length_six
		
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
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
                la s8, WA_SEARCH                      #hit search directly now
                li t2, 1
                PUSH t2                               #indicate TOKEN_ values are valid
                tail RUN


		CODEHEADER SEARCH, TOKENIZE_IMM, 0x0
                POP a0
                beq a0, zero, search_no_token     
                li t0, 1
                bne a0, t0, search_bad_pop
                la t0, TOKEN_START                    #token values are valid
		ld t0, 0(t0)
                la t1, TOKEN_END
		ld t1, 0(t1)
		la t2, CREATEFLAG
		ld t2, 0(t2)
		beq t2, zero, search_continue	      #we are in immediate mode
                j search_create_continue
  search_no_token:
                li t0, 2                      #should never get here - so warn if we do
                sd t0, OKSTATUS, t1
                tail NEXT
  search_bad_pop:
                li t0, 2
                sd t0, OKSTATUS, t1
                PUSH a0                               #restore bad POP
                tail NEXT
  search_continue:
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                ld t3, 0(t4)
  search_next_in_dictionary:
                lb t4, 24(t3)
                bne t4, t2, search_tokens_do_not_match
                add a0, t3, 32                        #a0 now points into the name in the dictionary
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
                ld t3, 16(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_exhausted        #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                addi t3, t3, 8                        #address that points to the code
                PUSH t3                               #store word address on the call stack
                tail EXE

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
                ld t2, CURRENT_BASE
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
                tail EXE
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
                tail EXE

  search_failed:
                la t0, NotOk_msg
                addi t1, zero, 24                     #error message is 24 chars long 
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                ld a1, 0(t0)
                la t1, TOKEN_END
                ld a2, 0(t1)
                sub a2, a2, a1
                addi a2, a2, 1
                call write                            #output error message
                addi t0, zero, 1
                sd t0, OKSTATUS, t1
                tail NEXT
  search_scan_variable_stack:
                #now scan for a variable name
                ld t0, TOKEN_START                    #token values are valid
                ld t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, BOTTOM_VARS
                ld t3, 0(t4)
		li a1, 48
		add t3, t3, a1
  search_var_next_check:
		ld t4, 0(t3)
		li a3, 0xbaadcafe
		beq t4, a3, search_var_next_in_dictionary
		j search_failed
  search_var_next_in_dictionary:
                ld t4, -8(t3)
		#compare lengths
                bne t4, t2, search_var_tokens_do_not_match
                add a0, t3, -9                        #a0 now points into the name in the var stack
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
                add t3, t3, 48                        #advance up the var stack
		la t4, TOP_VARS
		ld t4, 0(t4)
		bgt t3, t4, search_var_no_match
                j search_var_next_check

  search_var_tokens_matched:
		#put variable value on the stack
		ld t4, -32(t3)
		PUSH t4
		j search_var_reentry
  search_var_no_match:
		j search_failed


                CODEHEADER DECIMAL, SEARCH, 0x01
		li t1, 10
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER HEX, DECIMAL, 0x01
		li t1, 16
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER OCTAL, HEX, 0x01
		li t1, 8
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER BINARY, OCTAL, 0x01
		li t1, 2
                sd t1, CURRENT_BASE, t0
                tail NEXT

                #semi for outer loop
		CODEHEADER OLSEMI, BINARY, 0x0
		la t1, INFILELOAD
		ld t0, 0(t1)
		bnez t0, olsemi_fileload
                la s7, outer_loop
                tail NEXT
  olsemi_fileload:
		#loading a file
		la s7, outer_loop_tokenize
		tail NEXT
		
		#semi for the rest of us
                CODEHEADER SEMI, OLSEMI, 0x0
                ld s7, 0(s9)
                addi s9, s9, STACKOFFSET
                tail NEXT

		CODEHEADER _ENCSQ, SEMI, 0x00
		#compiled ENCSQ
		ld a0, 0(s7)
		mv a1, s7
		add s7, s7, a0
		li t0, 7
		and t1, s7, t0
		beqz t1, encsq_compiled_readyoutput
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  encsq_compiled_readyoutput:
		addi s7, s7, 8
		addi a1, a1, 8
		mv a2, a0
		li a0, 1
		li a7, 64
		ecall			#make system call
		tail NEXT

		CODEHEADER ENCSQ, _ENCSQ, 0x01
		#Print in a string
		#first of all, get the address and length of the string
		la t5, INPUT_END
		ld t5, 0(t5)		#absolute end of string
		li t3, 0
		la t6, INPUT_START
		ld t4, 0(t6)
		li t1, 0x22		#"
  encsq_check_next:
		lb t0, 0(t4)
		beq t0, t1, encsq_prep_imm_syscall
		addi t3, t3, 1
		add t4, t4, 1
		blt t4, t5, encsq_check_next
		la t0, String_err
		li t1, 18		#length of error message
		WRITESTRINGR t0, t1
		tail NEXT
  encsq_prep_imm_syscall:
		ld t4, 0(t6)
		addi t2, t3, 1
		add t1, t4, t2
		sd t1, 0(t6)
		WRITESTRINGR t4, t3
		tail NEXT

		CODEHEADER COMMENT, ENCSQ, 0x01
		#the line is now done
		la t0, INPUT_START
		la t1, INPUT_END
		ld t2, 0(t1)
		sd t2, 0(t0)
		tail NEXT
		
                CODEHEADER DOT, COMMENT, 0x01
                ld t0, CURRENT_BASE
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
                li t0, 1
                li t1, 63
  dot_test_against_shift:
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dot_start_binary  #past any trailing zeros - so start output
                sub t1, t1, t0
                beq t1, zero, dot_last_and_out
                j dot_test_against_shift
  dot_start_binary:
		addi sp, sp, -32
		sd a2, 24(sp)
		sd t0, 16(sp)
		sd t1, 8(sp)
		sd t3, 0(sp)
                WRITECHAR 0x31                #output 1
  dot_start_pop:
		ld t3, 0(sp)
		ld t1, 8(sp)
		ld t0, 16(sp)
		ld a2, 24(sp)
		addi sp, sp, 32
  dot_shift_and_test:
                sub t1, t1, t0
                beq t1, zero, dot_last_and_out
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dot_start_binary
		addi sp, sp, -32
		sd a2, 24(sp)
		sd t0, 16(sp)
		sd t1, 8(sp)
		sd t3, 0(sp)
                WRITECHAR 0x030		#output 0
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

  fix_up_length_six:
		#expand the following
		# ABORT" --> ABORTCOMM
		POP a0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		lbu t1, 5(a0)
		li t2, 0x22		 #"
		bne t1, t2, fix_up_six_done
		call fix_up_comma
		j fix_up_done
  fix_up_six_done:
		j fix_up_finished
		

  fix_up_length_two:
                #code to expand, if needed, two character input
                #SUPPORTED EXPANSIONS
		# 1+  --> PLUS1
		# 1-  --> MINUS1
		# 2+  --> PLUS2
		# 2-  --> MINUS2
		# ."  --> ENCSQ
		# R@  --> RFETCH
		# >R  --> TOR
		# C!  --> CSTORE
		# C@  --> CFETCH
		POP a0				#unexpanded token address
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x31			#1
		beq t1, t2, length_two_begin1
		li t2, 0x2E			#.
		beq t1, t2, length_two_begindot
		li t2, 0x32			#2
		beq t1, t2, length_two_begin2
		li t2, 0x3E			#>
		beq t1, t2, length_two_beginGT
		PUSH t1
		andi t1, t1, 0x5F		#character based tests all in here
		li t2, 0x52
		beq t1, t2, length_two_beginR
		li t2, 0x43
		beq t1, t2, length_two_beginC
		POP t1
		
		
  fix_up_length_two_finished:
		j fix_up_finished

  length_two_begin1:
		lbu t1, 1(a0)
		li t2, 0x2B			#+
		bne t1, t2, length_two_test_minus1
		call fix_up_plus1
		j fix_up_done
  length_two_test_minus1:
		li t2, 0x2D			#-
		bne t1, t2, length_two_plusminus_done
		call fix_up_minus1
		j fix_up_done
  length_two_plusminus_done:
		j fix_up_length_two_finished

  length_two_begindot:
		lbu t1, 1(a0)
		li t2, 0x22			#"
		bne t1, t2, length_two_begindot_done
                call fix_up_encsq
		j fix_up_done
  length_two_begindot_done:
		j fix_up_length_two_finished
		
  length_two_begin2:
		lbu t1, 1(a0)
		li t2, 0x2B			#+
		bne t1, t2, length_two_testminus2
		call fix_up_plus2
		j fix_up_done
  length_two_testminus2:
		li t2, 0x2D			#-
		bne t1, t2, length_two_begin2_done
		call fix_up_minus2
		j fix_up_done
  length_two_begin2_done:
		j fix_up_length_two_finished

  length_two_beginR:
		sb t1, 0(a2)
		addi sp, sp, 8			#drop the pushed character
		lbu t1, 1(a0)
		li t2, 0x40			#@
		bne t1, t2, length_two_test_rfrom
		call fix_up_rfetch
		j fix_up_done
  length_two_test_rfrom:
		li t2, 0x3E			#>
		bne t1, t2, length_two_r_done
		call fix_up_rfrom
		j fix_up_done
  length_two_r_done:
		j fix_up_length_two_finished

  length_two_beginC:
		sb t1, 0(a2)
		addi sp, sp, 8
		lbu t1, 1(a0)
		li t2, 0x21			#!
		bne t1, t2, length_two_c_fetch
		call fix_up_cstore
		j fix_up_done
  length_two_c_fetch:
		li t2, 0x40			#@
		bne t1, t2, length_two_c_done
		call fix_up_cfetch
		j fix_up_done
  length_two_c_done:
		j fix_up_length_two_finished


  length_two_beginGT:
		lbu t1, 1(a0)
		andi t1, t1, 0x5F
		li t2, 0x52			#R
		bne t1, t2, length_two_GT_done
		call fix_up_tor
		j fix_up_done
  length_two_GT_done:
		j fix_up_length_two_finished  

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
		# (  --> OBRACKET
		# )  --> CBRACKET
		# \  --> COMMENT
		# !  --> EXCLAIM
		# '  --> TICK
		POP a0				#unexpanded token address
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
  fix_up_start:
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x3A
		beq t2, t1, fix_up_colon
		li t2, 0x2E
		beq t2, t1, fix_up_dot
		li t2, 0x3B
		beq t2, t1, fix_up_semi
		li t2, 0x2B
		beq t2, t1, fix_up_add
		li t2, 0x2D
		beq t2, t1, fix_up_sub
		li t2, 0x2A
		beq t2, t1, fix_up_mul
		li t2, 0x2F
		beq t2, t1, fix_up_div
		li t2, 0x21
		beq t2, t1, fix_up_store
		li t2, 0x3E
		beq t2, t1, fix_up_gt
		li t2, 0x3C
		beq t2, t1, fix_up_lt
		li t2, 0x3D
		beq t2, t1, fix_up_equals
		li t2, 0x28
		beq t2, t1, fix_up_obracket
		li t2, 0x29
		beq t2, t1, fix_up_cbracket
		li t2, 0x5C
		beq t2, t1, fix_up_comment
		li t2, 0x21
		beq t2, t1, fix_up_exclaim
		li t2, 0x27
		beq t2, t1, fix_up_tick
		j fix_up_finished

  fix_up_colon:
		call do_fix_up_colon
		j fix_up_done
  fix_up_dot:
		call do_fix_up_dot
		j fix_up_done
  fix_up_semi:
		call do_fix_up_semi
		j fix_up_done
  fix_up_add:
		call do_fix_up_add
		j fix_up_done
  fix_up_sub:
		call do_fix_up_sub
		j fix_up_done
  fix_up_mul:
		call do_fix_up_mul
		j fix_up_done
  fix_up_div:
		call do_fix_up_div
		j fix_up_done
  fix_up_store:
		call do_fix_up_store
		j fix_up_done
  fix_up_gt:
		call do_fix_up_gt
		j fix_up_done
  fix_up_lt:
		call do_fix_up_lt
		j fix_up_done
  fix_up_equals:
		call do_fix_up_equals
		j fix_up_done
  fix_up_obracket:
		call do_fix_up_obracket
		j fix_up_done
  fix_up_cbracket:
		call do_fix_up_cbracket
		j fix_up_done
  fix_up_comment:
		call do_fix_up_comment
		j fix_up_done
  fix_up_exclaim:
		call do_fix_up_exclaim
		j fix_up_done
  fix_up_tick:
		call do_fix_up_tick
		j fix_up_done
		
  fix_up_done:
		mv t0, a3
		mv t1, a2	
                j tokenize_finished_sanitization 

  fix_up_finished:
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret


  fix_up_comma:
		#copy 0 - 5 then expand "
		lb t3, 0(a0)
		andi t3, t3, 0x5F
		sb t3, 0(a2)
		lb t3, 1(a0)
		andi t3, t3, 0x5F
		sb t3, 1(a2)
		lb t3, 2(a0)
		andi t3, t3, 0x5F
		sb t3, 2(a2)
		lb t3, 3(a0)
		andi t3, t3, 0x5F
		sb t3, 3(a2)
		lb t3, 4(a0)
		andi t3, t3, 0x5F
		sb t3, 4(a2)
		li t3, 0x43
		sb t3, 5(a2)
		li t3, 0x4F
		sb t3, 6(a2)
		li t3, 0x4D4D
		sh t3, 7(a2)
		addi a2, a2, 8
		ret

  do_fix_up_colon:
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
		ret

  do_fix_up_dot:
		li t3, 0x44
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x54
		sb t3, 2(a2)
		addi a2, a2, 2
		ret

  do_fix_up_semi:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x4D
		sb t3, 2(a2)
		li t3, 0x49
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  do_fix_up_add:
		li t3, 0x41
		sb t3, 0(a2)
		li t3, 0x44
		sb t3, 1(a2)
		li t3, 0x44
		sb t3, 2(a2)
		addi a2, a2, 2
		ret
	
  do_fix_up_sub:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x55
		sb t3, 1(a2)
		li t3, 0x42
		sb t3, 2(a2)
		addi a2, a2, 2
		ret
	
  do_fix_up_mul:
		li t3, 0x4D
		sb t3, 0(a2)
		li t3, 0x55
		sb t3, 1(a2)
		li t3, 0x4C
		sb t3, 2(a2)
		addi a2, a2, 2
		ret
	
  do_fix_up_div:
		li t3, 0x44
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x56
		sb t3, 2(a2)
		addi a2, a2, 2
		ret

  do_fix_up_store:
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
		ret

  do_fix_up_gt:
		li t3, 0x47
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  do_fix_up_lt:
		li t3, 0x4C
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  do_fix_up_equals:
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
		ret

  do_fix_up_obracket:
		li t3, 0x4F
		sb t3, 0(a2)
  fix_up_bracket:
		li t3, 0x42
		sb t3, 1(a2)
		li t3, 0x52
		sb t3, 2(a2)
		li t3, 0x41
		sb t3, 3(a2)
		li t3, 0x43
		sb t3, 4(a2)
		li t3, 0x4B
		sb t3, 5(a2)
		li t3, 0x45
		sb t3, 6(a2)
		li t3, 0x54
		sb t3, 7(a2)
		addi a2, a2, 7
		ret

  do_fix_up_cbracket:
		li t3, 0x43
		sb t3, 0(a2)
		j fix_up_bracket

  fix_up_encsq:
		li t3, 0x45
		sb t3, 0(a2)
		li t3, 0x4E
		sb t3, 1(a2)
		li t3, 0x43
		sb t3, 2(a2)
		li t3, 0x53
		sb t3, 3(a2)
		li t3, 0x51
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  do_fix_up_comment:
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, keep_fixing_up_comment
		j pull_in_another		      #suck in a line
  keep_fixing_up_comment:
		li t3, 0x43
		sb t3, 0(a2)	
		li t3, 0x4F
		sb t3, 1(a2)	
		li t3, 0x4D
		sb t3, 2(a2)	
		li t3, 0x4D
		sb t3, 3(a2)	
		li t3, 0x45
		sb t3, 4(a2)	
		li t3, 0x4E
		sb t3, 5(a2)	
		li t3, 0x54
		sb t3, 6(a2)
		addi a2, a2, 6
		ret

  do_fix_up_exclaim:
		li t3, 0x45
		sb t3, 0(a2)
		li t3, 0x58
		sb t3, 1(a2)
		li t3, 0x43
		sb t3, 2(a2)
		li t3, 0x4C
		sb t3, 3(a2)
		li t3, 0x41
		sb t3, 4(a2)
		li t3, 0x49
		sb t3, 5(a2)
		li t3, 0x4D
		sb t3, 6(a2)
		addi a2, a2, 6
		ret
 
  do_fix_up_tick:
  		li t3, 0x54
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x43
		sb t3, 2(a2)
		li t3, 0x4B
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  fix_up_plus1:
		li t3, 0x50
		sb t3, 0(a2)
		li t3, 0x4C
		sb t3, 1(a2)
		li t3, 0x55
		sb t3, 2(a2)
		li t3, 0x53
		sb t3, 3(a2)
		li t3, 0x31
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  fix_up_minus1:
		li t3, 0x4D
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x4E
		sb t3, 2(a2)
		li t3, 0x55
		sb t3, 3(a2)
		li t3, 0x53
		sb t3, 4(a2)
		li t3, 0x31
		sb t3, 5(a2)
		addi a2, a2, 5
		ret

  fix_up_plus2:
		li t3, 0x50
		sb t3, 0(a2)
		li t3, 0x4C
		sb t3, 1(a2)
		li t3, 0x55
		sb t3, 2(a2)
		li t3, 0x53
		sb t3, 3(a2)
		li t3, 0x32
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  fix_up_minus2:
		li t3, 0x4D
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x4E
		sb t3, 2(a2)
		li t3, 0x55
		sb t3, 3(a2)
		li t3, 0x53
		sb t3, 4(a2)
		li t3, 0x32
		sb t3, 5(a2)
		addi a2, a2, 5
		ret

  fix_up_rfetch:
		li t3, 0x46
		sb t3, 1(a2)
		li t3, 0x45
		sb t3, 2(a2)
		li t3, 0x54
		sb t3, 3(a2)
		li t3, 0x43
		sb t3, 4(a2)
		li t3, 0x48
		sb t3, 5(a2)
		addi a2, a2, 5
		ret

  fix_up_rfrom:
		li t3, 0x46
		sb t3, 1(a2)
		li t3, 0x52
		sb t3, 2(a2)
		li t3, 0x4F
		sb t3, 3(a2)
		li t3, 0x4D
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  fix_up_tor:
		li t3, 0x54
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x52
		sb t3, 2(a2)
		addi a2, a2, 2
		ret

  fix_up_cstore:
		li t3, 0x53
		sb t3, 1(a2)
		li t3, 0x54
		sb t3, 2(a2)
		li t3, 0x4F
		sb t3, 3(a2)
		li t3, 0x52
		sb t3, 4(a2)
		li t3, 0x45
		sb t3, 5(a2)
		addi a2, a2, 5
		ret

  fix_up_cfetch:
		li t3, 0x46
		sb t3, 1(a2)
		li t3, 0x45
		sb t3, 2(a2)
		li t3, 0x54
		sb t3, 3(a2)
		li t3, 0x43
		sb t3, 4(a2)
		li t3, 0x48
		sb t3, 5(a2)
		addi a2, a2, 5
		ret
		
.include "integer.S"
.include "stackop.S"
.include "listwords.S"
.include "loops.S"

