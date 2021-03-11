#Basic primatives we need to get anything done

.balign 8

  dictionary_top:
		            CODEEND GETSTDIN, 0x01
    		        GETIN
        		    PUSH a0
            		tail NEXT

		            CODEHEADER TYPE, GETSTDIN, 0x01
                WRITECR
                WRITECHAR 0x0A
         		    WRITECHAR 0x3E                      #> prompt
          			tail NEXT

  		          CODEHEADER GETNEXTLINE_IMM, TYPE, 0x01
                #Fetch a line for immediate execution
                #Leaves length (top) and address on stack
      		      POP a2
                la a0, INPUT_BUFFER
                MARKINPUTBUFFER INPUT_BUFFER        #ensure buffer starts 'empty'
                addi a1, zero, BUFFERLEN
        		    call fgets
                addi t0, zero, 1
                sub a2, a4, a0                      #a2 to hold length
                bgeu a2, t0, getnextline_imm_input
                tail NEXT                           #no input
  getnextline_imm_input:
                sw a0, INPUT_START, t0
                add a1, a0, a2                      #a2 has the end of input
                sw a1, INPUT_END, t0
                tail NEXT
          

                CODEHEADER OK, GETNEXTLINE_IMM, 0x01
                #TODO: need to redirect to not ok if bad status
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


                CODEHEADER TOKENIZE_IMM, OK, 0x01       
                #puts 1 on stack if system variables
                #TOKEN_START and TOKEN_END hold valid values
                lw a1, INPUT_END
                lw a0, INPUT_START
                addi t0, a0, 1                              #account for minimal input
                bltu t0, a1, tokenize_have_data             #buffer has data
  tokenize_all_over:
                tail NEXT
  tokenize_have_data:
                mv t0, a0                           #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                    #t2 space
                addi t3, zero, 0x0A                    #t3 CR
  tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, tokenize_keep_going
                bne t4, t3, tokenize_found_start
                j tokenize_all_over
  tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, tokenize_look_for_start
                j tokenize_all_over                 #got nothing
  tokenize_found_start:
                mv t1, t0                           #t1 to track end of token
  tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, tokenize_end_token
                beq t4, t3, tokenize_end_token
                j tokenize_advance_search
  tokenize_end_token:
                sw t1, INPUT_START, t5              #update the end point for subsequent searches
                addi t1, t1, -1                     # space or NL not part of token
                mv t2, t0
                addi t5, zero, 0x61                 #lowercase a
                addi t6, zero, 0x7B                 #lowercase z + 1
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
                la s8, WA_SEARCH                  #hit search directly now
                li t2, 1
                PUSH t2                           #indicate TOKEN_ values are valid
                call RUN

                

		            CODEHEADER SEARCH, TOKENIZE_IMM, 0x01
                POP a0
                beq a0, zero, search_no_token     
                addi t0, zero, 1
                bne a0, t0, search_bad_pop
                lw t0, TOKEN_START                        #token values are valid
                lw t1, TOKEN_END
                j search_continue
  search_no_token:
                addi t0, zero, 2                      #should never get here - so warn if we do
                sw t0, OKSTATUS, t1
                tail NEXT
  search_bad_pop:
                addi t0, zero, 2
                sw t0, OKSTATUS, t1
                PUSH a0                           #restore bad POP
                tail NEXT
  search_continue:
                sub t2, t1, t0
                addi t2, t2, 1                    #t2 has length of token
                la t3, dictionary
  search_next_in_dictionary:
                lb t4, 12(t3)
                bne t4, t2, search_tokens_do_not_match
                add a0, t3, 16                    #a0 now points into the name in the dictionary
                mv a1, t0                         #a1 points to the name in the buffer
                mv a2, t2                         #a2 checks how far we've gone 

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
                lw t3, 8(t3)                      #read the pointer to the next TIL command
                beq t3, zero, search_exhausted    #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                addi t3, t3, 4                    #address that points to the code
                PUSH t3                           #store word address on the call stack
                tail EXECUTE

  search_exhausted:
                lw t2, CURRENT_BASE
                li t3, 16
                beq t2, t3, search_check_hex
                li t3, 8
                bne t2, t3, search_assume_decimal
                j search_check_octal              #go to octal code
  search_assume_decimal:
                j search_setup_decimal
                nop
  search_check_octal:
                li t2, 8
                li t5, 48
                li t6, 55
                j search_octal_decimal_join
  search_setup_decimal:
                li t2, 10                         #assume we are decimal - trust but verify
                li t5, 48                         #ascii 0
                li t6, 57
  search_octal_decimal_join:
                mv a7, zero                       #a7 will hold the number
                sub t3, t1, t0                    #t3 holds radix power needed
                mv a4, t0                         #a4 points to first digit
  search_leading_zero_check:
                lb t4, 0(a4)                      #look at this
                beq t4, t5, search_increment_octdec #is it zero?
                j search_literal
  search_increment_octdec:
                beq t3, zero, search_literal      #output 0 if nothing else
                addi a4, a4, 1                    
                addi t3, t3, -1
                j search_leading_zero_check       #if leading zero addvance
  search_check_hex:
                                                  #must begin with 0X
                lb a0, 0(t0)
                li t5, 48
                beq a0, t5, search_test_X
                j search_failed
  search_test_X:
                lb a0, 1(t0)
                li t6, 88                         #X
                beq a0, t6, search_build_hex
                j search_failed
  search_build_hex:
                li t6, 57
                li a1, 65
                li a2, 71                         #G
                sub t3, t1, t0
                add t3, t3, -2
                mv a7, t4
                mul t4, t3, t2
                bne t4, zero, search_hex
                li t4, 1
  search_hex:
                mv a3, t0
                mv a4, zero                       #a4 holds value to push
                addi a3, a3, 2
                bgeu t1, a3, search_hex_continue
                j search_failed
  search_hex_continue:
                lb a5, 0(a3)
                bgeu a5, t5, search_check_9_less
                j search_failed
  search_check_9_less:
                bltu a5, t6, search_hex_stackup_num
                beq a5, t6, search_hex_stackup_num
                bltu a5, a2, search_hex_check_A
                j search_failed
  search_hex_check_A:
                bgeu a5, a1, search_hex_stackup_alpha
                j search_failed
  search_hex_stackup_num:
                addi a5, a5, -48                    #map 0 -> 0
                mul a5, a5, t4
                j search_hex_decrement
  search_hex_stackup_alpha:
                addi a5, a5, -55                    #map A -> 10
                mul a5, a5, t4
  search_hex_decrement:
                add a4, a4, a5
                add a7, a7, -1
                bne a7, zero, search_reset_hex_factor
                li t4, 1
                j search_next_hex_char
  search_reset_hex_factor:
                mul t4, a7, t2
  search_next_hex_char:
                addi a3, a3, 1
                blt t1, a3, search_hex_push_it
                j search_hex_continue
  search_hex_push_it:
                PUSH a4                         #save number on stack
                la t0, WA_TOKENIZE_IMM          #keep tokenizing
                PUSH t0
                tail EXECUTE
                nop
  search_literal:
                bltu t6, t4, search_literal_fail  #digit above max range
                bge t4, t5, search_octdec_continue #digit in range
  search_literal_fail:
                j search_failed
  search_octdec_continue:
                sub t4, t4, t5                    #reduce to number
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
                PUSH a7
                la t0, WA_TOKENIZE_IMM
                PUSH t0
                tail EXECUTE

  search_failed:
                la t0, NotOk_msg
                addi t1, zero, 24                   #error message is 24 chars long 
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                lw a1, 0(t0)
                la t1, TOKEN_END
                lw a2, 0(t1)
                sub a2, a2, a1
                addi a2, a2, 1
                call write                          #output error message
                addi t0, zero, 1
                sw t0, OKSTATUS, t1
                tail NEXT


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

                CODEHEADER OLSEMI, BINARY, 0x0
                la s7, outer_loop
                j NEXT

                CODEHEADER DOT, OLSEMI, 0x01
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
                

.include "integer.S"


#Update this to point to the last (first) entry
          
