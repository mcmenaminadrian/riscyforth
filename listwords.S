#Run through the dictionary listing all words flagged for use

                CODEHEADER WORDLIST, DUP, 0x01
                la t0, dictionary
  wordlist_fetch:
                lw t1, 0(t0)
		lw t2, 0(t1)
                beq t2, zero, wordlist_get_next             #flag is zero, not for printing
                lw t2, INSTWIDTH3(t1)                       #length of name
                addi t1, t1, INSTWIDTH4                     #address of characters for name
                PUSH t0
                WRITESTRINGR t1, t2
                WRITECHAR 0x20
                WRITECHAR 0x20
                POP t0
  wordlist_get_next:
								lw t1, 0(t0)
                lw t1, INSTWIDTH2(t1)                       	#next pointer
                beq t1, zero, wordlist_finished
		lw t1, 0(t0)
		addi t1, t1, INSTWIDTH2
                mv t0, t1
                j wordlist_fetch
  wordlist_finished:
                tail NEXT


                CODEHEADER VARIABLE, WORDLIST, 0x01
                #create a variable in the variable dictionary
                #first get the name and check it's not already present
		#variable stack grows downwards but each entry in forwards direction
		#
              	lw a1, INPUT_END
                lw a0, INPUT_START
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, variable_have_data       #buffer has data
  variable_all_over:
                tail NEXT
  variable_have_data:
                mv t0, a0                             #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                   #t2 space
                addi t3, zero, 0x0A                   #t3 CR
  variable_look_for_start:
                lbu t4, 0(t0)
                beq t4, t2, variable_keep_going
                bne t4, t3, variable_found_start
                j variable_all_over
  variable_keep_going:
                addi t0, t0, 1
                bltu t0, a1, variable_look_for_start
                j variable_all_over                   #got nothing
  variable_found_start:
		#variable name must start with a letter
		addi a3, zero, 0x41									  #A
		bge t4, a3, variable_good_start
		#start with a bad character - report error
  variable_gone_bad:
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
  variable_good_start:
                mv t1, t0                             #t1 to track end of token
  variable_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, variable_end_token
                lbu t4, 0(t1)
                beq t4, t2, variable_end_token
                beq t4, t3, variable_end_token
                j variable_advance_search
  variable_end_token:
                sw t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
                addi t5, zero, 0x61                   #lowercase a
                addi t6, zero, 0x7B                   #lowercase z + 1
  variable_sanity_test:
                lbu t4, 0(t2)
                blt t4, t5, variable_next_sane
                blt t4, t6, variable_sanitize
                j variable_next_sane
  variable_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  variable_next_sane:
                addi t2, t2, 1
                blt t1, t2, variable_finished_sanitization
                j variable_sanity_test
  variable_finished_sanitization:
                sw t0, TOKEN_START, t2
                sw t1, TOKEN_END, t2
		#now check this is not a keyword or a number
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
		li t3, NAMEMAXLEN
		bge t3, t2, variable_length_good
		j variable_gone_bad
  variable_length_good:
                la t4, dictionary
                lw t3, 0(t4)
  variable_next_in_dictionary:
                lbu t4, 12(t3)
                bne t4, t2, variable_tokens_do_not_match
                add a0, t3, 16                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 
  variable_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, variable_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, variable_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j variable_loop_through_token
  variable_tokens_do_not_match:
                lw t3, 8(t3)                          #read the pointer to the next TIL command
                beq t3, zero, variable_search_scan_variable_stack        #at the end of the dictionary
                j variable_next_in_dictionary

  variable_tokens_matched:
		j variable_gone_bad

 #enable update of existing variable
  variable_search_scan_variable_stack:
                #now scan for a variable name
		la t4, BOTTOM_VARS
		la t0, TOP_VARS
                lw t2, 0(t4)
		lw t3, 0(t0)
  		addi t3, t3, -0x20
		bne t2, t3, variable_consider_update
		j variable_search_var_no_match	      #no variables have been defined yet
  variable_consider_update:
                lw t0, TOKEN_START                    #token values are valid
                lw t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                lw t3, 0(t4)
		li a1, 36
		add t3, t3, a1
  variable_search_var_next_check:
		lw t4, 0(t3)
		li a1, 0xFFFFFFFF
		and t4, t4, a1
		li a3, 0xdeadbeef
		beq t4, a3, variable_search_var_next_in_dictionary
		j variable_gone_bad
  variable_search_var_next_in_dictionary:
                lw t4, -4(t3)
		#compare lengths
                bne t4, t2, variable_search_var_tokens_do_not_match
                add a0, t3, -5                        #a0 now points into the name in the var stack
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  variable_search_var_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, variable_search_var_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, variable_search_var_tokens_matched
                addi a0, a0, -1
                addi a1, a1, 1
                j variable_search_var_loop_through_token

  variable_search_var_tokens_do_not_match:
                add t3, t3, 36                        #advance up the var stack
		la t4, TOP_VARS
		lw t4, 0(t4)
		bge t3, t4, variable_search_var_no_match
                j search_var_next_check

  variable_search_var_tokens_matched:
		#update the value
		POP t0
		sw t0, -32(t3)
		tail NEXT
		
  variable_search_var_no_match:
                lw t0, TOKEN_START                    #reset t2
                lw t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
		la t1, BOTTOM_VARS
		lw t3, 0(t1)
		lw t4, 0(t3)
		beq zero, t4, variable_empty_space
		j variable_gone_bad			#error in var stack
  variable_empty_space:
		li t1, 0xdeadbeef			#mark in use
		sw t1, 0(t3)
		sw t2, -INSTWIDTH(t3)			#length - stack grows down
		mv t4, t3
		addi t3, t3, -(INSTWIDTH + 1)
		mv a3, t2
  variable_write_out_name:
		#reset a1
                mv a1, t0
  variable_loop_write_out_name:
		lbu t5, 0(a1)
		sb t5, 0(t3)
		addi t3, t3, -1
		addi a1, a1, 1
		addi a3, a3, -1
		bne a3, zero, variable_loop_write_out_name
		addi t4, t4, -(NAMEMAXLEN + INSTWIDTH2)
		POP t0
		sw t0, 0(t4)
		#update bottom pointer
		la t1, BOTTOM_VARS
		lw t3, 0(t1)
		addi t3, t3, -36
		sw t3, 0(t1)
		tail NEXT
								
 


