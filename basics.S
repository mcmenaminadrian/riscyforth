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
    		        PUSH a0                             #address (on stack) of input
        		    tail NEXT

                CODEHEADER OK, GETNEXTLINE, 0x01
                la a0, Ok_msg
                call puts
                tail NEXT

                CODEHEADER TOKENIZE, OK, 0x01
                POP a0                              #start of buffer
                POP a1                              #length of buffer
                add a1, a1, a0                      
                add a1, a1, -1                      #a1 points to the end of the input
                mv t0, a0
                mv t4, zero                         #t4 flags end of line
                mv t5, zero                         #t5 counts tokens found
                ori t2, t0, 0x20                    #t2 space
                ori t3, t0, 0x0A                    #t3 CR
                mv a2, zero                         #a2 flag we have found anything
  check_start:
                lb t1, 0(t0)
                beq t1, t3, end_of_line
                bne t1, t2, advance_start
                add t0, t0, 1
                j check_start
  advance_start:
                addi a2, a2, 1
                mv t6, t0                           #t6 marks start of token
  move_along:
                addi t0, t0, 1
                beq a1, t0, end_of_line             #reached end of input
                lb t1, 0(t0)
                beq t1, t3, end_of_line             #reached a CR
                beq t1, t2, end_of_token            #reached a space
                j move_along
  end_of_line:
                ori t4, zero, 1                       #set flag for end of line
  end_of_token:
                addi t5, t5, 1
                beq a2, zero, done
                PUSH t6                             #start of token on to stack
                addi t6, t0, -1
                PUSH t6                             #end of token on to stack
                beq t4, zero, check_start
  done:         PUSH t5
                tail NEXT

		            CODEHEADER SEARCH, TOKENIZE, 0x01
                ###########################################
                # Expect to find tokens details on stack  #
                # COUNTOFTOKENS                           #
                # ENDOFTOKEN                              #
                # STARTOFTOKEN                            #
                # ENDOFTOKEN                              #
                # etc                                     #
                ###########################################
                POP a0
                beq a0, zero, exhausted_line        #no tokens left
  search_token:
                POP t2                              #t2 has end of token
                POP t1                              #t1 has start of token

                sub t0, t2, t1
                addi t0, t0, 1                      #t0 has length of token on stack
                PUSH t1                             #save start
                PUSH t0                             #save length
                la t3, dictionary                   #t3 points to start of dictionary
                PUSH t3                             #save search point
  dict_next:
                lb t4, 12(t3)                       #t4 stored word length
                bne t4, t0, tokens_not_matched      #current dictionary entry not the same length
                add t2, t3, 16                      #t2 now points to start of name in dictionary

  token_match_loop:
                addi t1, t1, 1                      #t0 now points into stacked token
                addi t2, t2, 1
                lb t5, 0(t1)
                lb t6, 0(t2)                        #t5 and t6 hold characters
                bne t5, t6, tokens_not_matched
                addi t0, t0, -1
                beq t0, zero, tokens_matched
                j token_match_loop

  tokens_not_matched:
                POP t3
                POP t0
                POP t1
                lw t3, 8(t3)                        #read the pointer to the next TIL command
                beq t3, zero, all_done
                j dict_next                         #keep going
                
  tokens_matched:
                POP t3                              #we need this but not next two
                POP zero
                POP zero
                lw t3, 4(t3)
                PUSH t3                             #code address on the stack
                tail NEXT
  
  all_done:
                li t0, 0xFFFFFFFF
                PUSH t0                             #nothing
                tail NEXT

  exhausted_line:
                PUSH zero
                tail NEXT                           #line all used up

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
                POP zero
                POP zero
                addi a0, a0, -1
                j check_token_count
  cleared_out:
                tail NEXT


#Update this to point to the last (first) entry
  .equ           dictionary, TIL_EXECUTEIMM
          
