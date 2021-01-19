#Basic primatives we need to get anything done

		.align 3

		            CODEHEADER GETSTDIN, PROMPT, 0x01
    		        GETSTDIN
        		    PUSH a0
            		j NEXT

		            CODEHEADER PROMPT, GETNEXTLINE, 0x0
    		        WRITECHAR 0xFE
        		    WRITECHAR 58
           			j NEXT

  		          CODEHEADER GETNEXTLINE, OK, 0x01
      		      POP a2
          		  WINDSTACK
		            mv a0, sp
    		        addi a1, x0, STACKWINDUP - 0x08
        		    call fgets
		            PUSH a2                             #length of input
    		        PUSH a0                             #address (on stack) of input
        		    j NEXT

                CODEHEADER OK, TOKENIZE, 0x01
                la a0, ok_msg
                call puts
                j NEXT

                CODEHEADER TOKENIZE, PARSE, 0x01
                POP a0                              #start of buffer
                POP a1                              #length of buffer
                add a1, a1, a0                      
                add a1, a1, -1                      #a1 points to the end of the input
                mv t0, a0
                mv t4, x0                           #t4 flags end of line
                mv t5, x0                           #t5 counts tokens found
                ori t2, t0, 0x20                    #t2 space
                ori t3, t0, 0x0A                    #t3 CR
                mv t7, x0                           #t7 flag we have found anything
  check_start:
                lb t1, 0(t0)
                bne t1, t3, no_token
                bne t1, t2, advance_start
                add t0, t0, 1
                j check_start
  advance_start:
                addi t7, t7, 1
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
                beq t7, x0, done
                PUSH t6                             #start of token on to stack
                addi t6, t6, -1
                PUSH t6                             #end of token on to stack
                beq t4, x0, check_start
  done:         PUSH t5
                j NEXT

		            CODEHEADER PARSENEXT, SEARCH, 0x01
                POP a0
                beq a0, x0, all_done                #no tokens left
                POP a1
                POP a2
                addi a0, a0, -1
                PUSH a0                             #updated count on stack
                PUSH a1
                PUSH a2                             #reverse start/end
                j NEXT
  all_done:
                PUSH x0
                j NEXT

                CODEHEADER SEARCH, 

    #restructure below - Search needs to be a primative
    #so this should end here, with values stored on stack


  tokenize:                                       #saving
                PUSH t4                           #end of line flag
                PUSH a1                           #end of line address
                PUSH t6                           #start of token
                PUSH t0                           #end of token
                jal Search
                POP t0                            #did search find anything?
                beq t0, x0, bad_token
                jal Execute                       #worked so execute
                POP t0                            
                POP t6
                POP a1
                POP t4
                j delim_chars

  no_token:
                la a0, Ok_msg
                call puts
                UNWINDSTACK
                j Next

  bad_token:
                POP t1                            #end of token
                POP t0                            #start of token  
                POP x0
                POP x0
                PUSH t0
                PUSH t1
                j NOTOK
                UNWINDSTACK
                j Next






