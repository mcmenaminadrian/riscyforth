#Basic primatives we need to get anything done

		.align 3

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

  		          CODEHEADER GETNEXTLINE, TYPE, 0x01
      		      POP a2
                la a0, INPUT_BUFFER
                MARKINPUTBUFFER INPUT_BUFFER        #ensure buffer starts 'empty'
                addi a1, zero, BUFFERLEN
        		    call fgets
		            PUSH a2                             #length of input
    		        PUSH a0                             #address of input
        		    tail NEXT

                CODEHEADER OK, GETNEXTLINE, 0x01
                la a0, Ok_msg
                call puts
                POP a0
                POP a1
                bne a1, zero, nothing_entered
                PUSH a0
                j ok_over
  nothing_entered:
                PUSH zero
  ok_over:
                tail NEXT

                CODEHEADER TOKENIZE, OK, 0x01
                POP a0                              #start of buffer
                bne a0, zero, tokenize_have_data    #nothing here so leave
                tail NEXT
  tokenize_have_data:
                la a1, INPUT_BUFFER
                addi a1, a1, BUFFERLEN              #a1 points beyond the buffer end
                blt a0, a1, tokenize_inside_range
                PUSH zero
                tail NEXT                           #we started our search after the buffer end
  tokenize_inside_range:
                mv t0, a0                           #t0 tracks start of token, t1 the end
                mv t1, zero
                ori t2, t0, 0x20                    #t2 space
                ori t3, t0, 0x0A                    #t3 CR
  tokenize_look_for_start:
                lw t4, 0(t0)
                beq t4, t2, tokenize_keep_going
                bne t4, t3, tokenize_found_start
                PUSH zero                           #got nothing
                tail NEXT
  tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, tokenize_look_for_start
                push zero
                tail NEXT                           #got nothing
  tokenize_found_start:
                mv t1, t0
  tokenize_advance_search:
                addi t1, t1, 1
                bltu t1, a1, tokenize_end_token
                lw t4, 0(t1)
                beq t4, t2, tokenize_end_token
                beq t4, t3, tokenize_end_token
                j tokenize_advance_search
  tokenize_end_token:
                mv t2, t0
                addi t5, zero, 0x61                 #lowercase a
                addi t6, zero, 0x7A                 #lowercase z
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
                beq t2, t1, tokenize_finished_sanitization
                j tokenize_sanity_test
  tokenize_finished_sanitization:
                addi t1, t1, -1
                sw t0, TOKEN_START, t2
                sw t1, TOKEN_END, t2
                addi t2, zero, 1
                PUSH t2                           #indicate TOKEN_ values are valid
                tail NEXT


		            CODEHEADER SEARCH, TOKENIZE, 0x01
                POP a0
                beq a0, zero, search_no_token     
                addi t0, zero, 1
                bne a0, t0, search_bad_pop
                sw t0, TOKEN_START, t1            #token values are valid
                sw t1, TOKEN_END, t2
                j search_continue
  search_no_token:
                PUSH zero
                tail NEXT
  search_bad_pop:
                li t0, 0xFFFFFFFF
                PUSH a0                           #restore bad POP
                PUSH t0
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
                add a2, a2, -1
                beq a2, zero, search_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_loop_through_token
                
  search_tokens_do_not_match:
                lw t3, 8(t3)                      #read the pointer to the next TIL command
                beq t3, zero, search_exhausted    #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                lw t3, 4(t3)
                PUSH t3                           #store word address on the stack
                tail NEXT

  search_exhausted:
                PUSH zero
                tail NEXT



                CODEHEADER EXECUTEIMM, SEARCH, 0x01
                POP a0                              #what have got
                bne zero, a0, test_exhausted          #if something here go to next test
                addi a0, a0, 1
                PUSH a0                             #nothing to do, return 1
                tail NEXT
  test_exhausted:
                li t0, 0xFFFFFFFF
                bne a0, t0, do_it                   #have something to do
                PUSH t0                             #bad token return -1
  do_it:
                jalr ra, a0, 0
                tail NEXT

                CODEHEADER CLEARSTACK, EXECUTEIMM, 0x01
                POP a0
  check_token_count:
                beq a0, zero, cleared_out           #no tokens details to clear
                POP zero                            #clear token details
                POP zero
                addi a0, a0, -1
                j check_token_count
  cleared_out:
                tail NEXT


#Update this to point to the last (first) entry
  .equ           dictionary, TIL_CLEARSTACK
          
