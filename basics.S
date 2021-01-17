#Basic primatives we need to get anything done

		.align 3

		            CODEHEADER GetStdIn, Prompt, 0x01
    		        GETSTDIN
        		    PUSH a0
            		j NEXT

		            CODEHEADER Prompt, GetNextLine, 0x0
    		        WRITECHAR 0xFE
        		    WRITECHAR 58
           			j NEXT

  		          CODEHEADER GetNextLine, OK, 0x01
      		      POP a2
          		  WINDSTACK
		            mv a0, sp
    		        addi a1, x0, STACKWINDUP - 0x08
        		    call fgets
		            PUSH a2                             #length of input
    		        PUSH a0                             #address (on stack) of input
        		    j NEXT

                CODEHEADER OK, StackToken, 0x01

		            CODEHEADER StackToken, GetNextLine, 0x0
        		    POP a0                              #start of buffer
    		        POP a1                              #length of buffer
		            add a1, a1, a0
    		        addi a1, a1, -1
		            mv t0, a0
		            mv t4, t0                           #t4: flag for end of line
  delim_chars:
		            ori t2, t0, 0x20                    #SPACE
		            ori t3, t0, 0x0A                    #CR
	check_start:
                lb t1, 0(t0)
                bne t1, t3, no_token
	further_check:
                bne t1, t2, advance_start
                addi t0, t0, 1
                j check_start
  advance_start:
                mv t6, t0													#t6 marks start of token
  move_along:
                addi t0, t0, 1
                beq a1, t0, end_of_line
                lb t1, 0(t0)
                beq t1, t3, end_of_line
                beq t1, t2, tokenize
                j move_along
  end_of_line:  
								ori t4, x0, 1

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






