#Run through the dictionary listing all words flagged for use

                CODEHEADER WORDS, DUP, 0x01
                la t0, dictionary
  wordlist_fetch:
                ld t1, 0(t0)
		ld t2, 0(t1)
		li t3, 1
		and t2, t2, t3
                beqz t2, wordlist_get_next	 	       	#flag is zero, not for printing
                ld t2, 24(t1)		                       	#length of name
                addi t1, t1, 32		                     	#address of characters for name
                PUSH t0
                WRITESTRINGR t1, t2
                WRITECHAR 0x20
                WRITECHAR 0x20
                POP t0
  wordlist_get_next:
		ld t1, 0(t0)
                ld t1, 16(t1)		                       	#next pointer
                beq t1, zero, wordlist_finished
		ld t1, 0(t0)
		addi t1, t1, 16
                mv t0, t1
                j wordlist_fetch
  wordlist_finished:
                tail NEXT

		CODEHEADER LITERAL, WORDS, 0x01
		#does nothing in interpretation mode
		#(x --) : compile time - compiler will take number from stack via literalnumb
		tail NEXT

		CODEHEADER LITERALNUMB, LITERAL, 0x0
		#read in a number - next in the secondary
		#store it on the stack and move on
		ld t0, 0(s7)
		addi sp, sp, -8
		sd t0, 0(sp)
		addi s7, s7, ADDRWIDTH
		tail NEXT

		CODEHEADER LITERALADDR, LITERALNUMB, 0x0
		#read in an address from the secondary
		#then get the contents of that address
		#and place those on the stack
		ld t0, 0(s7)
		ld t1, 0(t0)
		addi sp, sp, -8
		sd t1, 0(sp)
		addi s7, s7, ADDRWIDTH
		tail NEXT

		CODEHEADER TYPE, LITERALADDR, 0x01
		ld t0, 0(sp)
		bnez t0, type_continue
		tail NEXT
  type_continue:
		ld t1, 8(sp)
		WRITESTRINGR t1, t0
		tail NEXT

		CODEHEADER TIB, TYPE, 0x01
		#return address of input buffer
		la t0, INPUT_BUFFER
		PUSH t0
		tail NEXT
		
		CODEHEADERZ DOTS, .S, TIB, 0x01
		# display contents of stack (tools word)
		# ( -- )
		# from DEPTH
		la t0, STACKTOP
                ld t1, 0(t0)
                sub t2, t1, sp
                srai t3, t2, 3
                #t3 now has the depth of the stack
		#display as number
		blez t3, dots_done
		#copy the stack
		mv t0, t3
		mv t1, sp
  dots_copying_stack:
		addi sp, sp, -8
		ld t2, 0(t1)
		sd t2, 0(sp)
		addi t0, t0, -1
		beqz t0, dots_display
		addi t1, t1, 8
		j dots_copying_stack
  dots_display:
		addi s10, s10, -8
		sd t3, 0(s10)
  dots_output:
		ld t0, CURRENT_BASE
                POP a2                            #get item on stack
                la a0, SCRATCH_PAD                #sprintf uses this
                addi t1, zero, 16
                beq t0, t1, dots_ps_format_hex
                addi t1, zero, 8
                beq t0, t1, dots_ps_format_octal
                addi t1, zero, 2
                beq t0, t1, dots_ps_format_binary
                la a1, decimalout
                j dots_dot_output
  dots_ps_format_hex:
                la a1, hexout
                j dots_dot_output
  dots_ps_format_octal:
                la a1, octalout
                j dots_dot_output
  dots_dot_output:
                addi a3, zero, 3
                call sprintf
                la t0, SCRATCH_PAD
                mv t1, a0
                WRITESTRINGR t0, t1
                j dots_loop_output
  dots_ps_format_binary:                             #binary output not supported by sprintf, so do it ourselves
                li t0, 1
                li t1, 63
  dots_dot_test_against_shift:
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dots_dot_start_binary  #past any trailing zeros - so start output
                sub t1, t1, t0
                beq t1, zero, dots_dot_last_and_out
                j dots_dot_test_against_shift
  dots_dot_start_binary:
		addi sp, sp, -32
		sd a2, 24(sp)
		sd t0, 16(sp)
		sd t1, 8(sp)
		sd t3, 0(sp)
                WRITECHAR 0x31                #output 1
  dots_dot_start_pop:
		ld t3, 0(sp)
		ld t1, 8(sp)
		ld t0, 16(sp)
		ld a2, 24(sp)
		addi sp, sp, 32
  dots_dot_shift_and_test:
                sub t1, t1, t0
                beq t1, zero, dots_dot_last_and_out
                sll t3, t0, t1
                and a0, a2, t3
                bne a0, zero, dots_dot_start_binary
		addi sp, sp, -32
		sd a2, 24(sp)
		sd t0, 16(sp)
		sd t1, 8(sp)
		sd t3, 0(sp)
                WRITECHAR 0x030		#output 0
                j dots_dot_start_pop
  dots_dot_last_and_out:
                and a0, a2, t0
                beq a0, zero, dots_dot_zero_and_out
                WRITECHAR 0x31
                j dots_dot_output_b_and_space
  dots_dot_zero_and_out:
                WRITECHAR 0x30
  dots_dot_output_b_and_space:
                WRITECHAR 0x62            #b
		WRITECHAR 0x20
  dots_loop_output:
		ld a7, 0(s10)
		addi a7, a7, -1
		beqz a7, dots_cr_out
		sd a7, 0(s10)
		WRITECHAR 0x2C
		WRITECHAR 0x20
		j dots_output
  dots_cr_out:
		addi s10, s10, 8
		WRITECHAR 0x0A
  dots_done:
		tail NEXT

		CODEHEADER DISPLAY, DOTS, 0x01
		la t0, SCRATCH_PAD
		mv t1, zero
		mv t3, sp
		li t4, 0x80
  display_fetch_from_stack:
		lb t5, 0(t3)
		addi t3, t3, STACKOFFSET
		and t6, t5, t4
		bne t6, zero, display_data_collected
		sb t5, 0(t0)
		addi t0, t0, 1
		addi t1, t1, 1
		j display_fetch_from_stack
  display_data_collected:
		mv sp, t3
		la t0, SCRATCH_PAD
		WRITESTRINGR t0, t1
		tail NEXT

		CODEHEADERZ BUFFERCOLON, BUFFER:, DISPLAY, 0x01
		#(u "<spaces>name" --)
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, buffercolon_have_data
		tail NEXT				#nothing to parse
  buffercolon_have_data:
		#now test we are aligned
		call utility_find_string
		beqz a0, variable_gone_bad
		#now have a0 with start, a1 with end+1, a2 with length
		sd a1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, variable_gone_bad
		#write out a word with the variable name that will return the address
		#get the address we'll return
		mv a1, a2
		li a5, 0x08				#8 for a variable
		call utility_write_function_header
		la a3, dataspaceptr
		ld a1, 0(a3)
		#check alignment
		li t0, 0x07
		li t2, 0x08
		and t1, a1, t0
		beqz t1, buffercolon_advance_alloc
		sub t3, t2, t1
		add a1, a1, t3
  buffercolon_advance_alloc:
		ld t2, 0(sp)
		addi sp, sp, 8
		j variable_advance_alloc

                CODEHEADER VARIABLE, BUFFERCOLON, 0x01
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, variable_have_data
		tail NEXT				#nothing to parse
  variable_have_data:
		call utility_find_string
		beqz a0, variable_gone_bad
		#now have a0 with start, a1 with end+1, a2 with length
		sd a1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, variable_gone_bad
		#write out a word with the variable name that will return the address
		#get the address we'll return
		mv a1, a2
		li a5, 0x08				#8 for a variable
		call utility_write_function_header
		la a3, dataspaceptr
		ld a1, 0(a3)
		#check alignment
		li t0, 0x07
		li t2, 0x08
		and t1, a1, t0
		beqz t1, variable_advance_alloc
		sub t3, t2, t1
		add a1, a1, t3
  variable_advance_alloc:
		add a4, a1, t2
		sd a4, 0(a3)
		call utility_write_number_to_stack
		#and get out
		la a1, NEXT
		call utility_write_out_call_function
		#now check if we are 8 bit aligned on writing address
		and t1, a0, t0
		beqz t1, variable_done
		sub t3, t2, t1
		add a0, a0, t3
  variable_done:
		la t4, createwritepoint
		sd a0, 0(t4)
		la t0, newdictionary
		la t1, dictionary
		ld t2, 0(t0)
		sd t2, 0(t1)
		sd a0, 0(t0)			      #update address we will writenext word to
		tail NEXT						#and out
		

		
  variable_gone_bad:
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
