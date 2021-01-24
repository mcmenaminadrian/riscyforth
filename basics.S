#Basic primatives we need to get anything done

		.align 3

  dictionary:
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
          		  WINDSTACK
		            mv a0, sp
    		        addi a1, x0, STACKWINDUP - 0x08
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
                mv t4, x0                           #t4 flags end of line
                mv t5, x0                           #t5 counts tokens found
                ori t2, t0, 0x20                    #t2 space
                ori t3, t0, 0x0A                    #t3 CR
                mv a2, x0                           #a2 flag we have found anything
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
                ori t4, x0, 1                       #set flag for end of line
  end_of_token:
                addi t5, t5, 1
                beq a2, x0, done
                PUSH t6                             #start of token on to stack
                addi t6, t0, -1
                PUSH t6                             #end of token on to stack
                beq t4, x0, check_start
  done:         PUSH t5
                tail NEXT

		            CODEHEADER SEARCH, TOKENIZE, 0x01
                ###################################
                # Expect to find tokens on stack  #
                # COUNTOFTOKENS                  #
                # ENDOFTOKEN                      #
                # STARTOFTOKEN                    #
                # ENDOFTOKEN                      #
                # etc                             #
                ###################################
                POP a0
                beq a0, x0, all_done                #no tokens left
  search_token:
                POP t2                              #t2 has end of token
                POP t1                              #t1 has start of token
                sub t0, a2, a1
                addi t0, t0, 1                      #t0 has length of token on stack
                la t3, dictionary                   #t3 points to start of dictionary
                                                    #ignoring flag word for now
  dict_next:
                lb t4, 4(t3)                        #t4 stored word length
                bne t4, t0, next_word               #current dictionary entry not the same length
                add t2, t3, 8                       #t2 bow points to start of name in dictionary
                mv t6, x0                           #use t6 as index
  token_match_loop:
                add t0, t1, t6                      #t0 now points into stacked token
                add t2, t2, t6
                PUSH t6
                lb t5, 0(t0)
                lb t6, 0(t2)                        #t5 and t6 hold characters
                bne t5, t6, tokens_not_matched
                POP t6
                addi t6, t6, 1                      #increment t6
                blt t4, t6, tokens_matched          #t6 now bigger than length so tokens match
                j token_match_loop
  tokens_not_matched:
                POP t6
  next_word:
                nop
  tokens_matched:
                nop

                

                
  
  
  
  
  all_done:
                PUSH x0
                tail NEXT


