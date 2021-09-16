#Run through the dictionary listing all words flagged for use

                CODEHEADER WORDS, DUP, 0x01
                la t0, dictionary
  wordlist_fetch:
                ld t1, 0(t0)
		ld t2, 0(t1)
                beq t2, zero, wordlist_get_next 	       	#flag is zero, not for printing
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

		CODEHEADER LITERALNUMB, WORDS, 0x0
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

		CODEHEADER _VARIN, LITERALADDR, 0x0
		ld t0, VARIABLEFLAG
		beq zero, t0, varin_normal_start
		sd zero, VARIABLEFLAG, t0
		addi s7, s7, 32
		tail NEXT

		CODEHEADER VARIN, _VARIN, 0x0
		#Look for a variable
		#and place its value on the stack if it exists
		#also handle variable creation update in create mode
		
  varin_normal_start:
		mv t3, s7
		ld t0, 0(s7)				#t0 nw holds the length
		beq t0, zero, varin_failed_zero_length
		addi s7, s7, 32				#name length and name itself
		j varin_scan_stack
  varin_failed_zero_length:
		PRINT zerolen_varin
		WRITECR
		tail NEXT
  varin_failed:
		mv t0, s7
		addi t0, t0, -32
		ld t1, 0(t0)
		addi t0, t0, 1
		WRITESTRINGR t0, t1
		WRITECR
		PRINT failed_varin
		tail NEXT

		CODEHEADER TYPE, VARIN, 0x01
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
		
		CODEHEADER DISPLAY, TIB, 0x01
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

                CODEHEADER VARIABLE, DISPLAY, 0x01
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, variable_have_data
		tail NEXT				#nothing to parse
  variable_have_data:
		call utility_find_string
		beqz a0, variable_gone_bad
		#now have a0 with start, a1 with end, a2 with length
		mv t0, a1
		add t0, t0, 1
		sd t1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
  variable_finished_sanitization:
		la t4, INPUT_START
		addi t5, a1, 1
		sd t5, 0(t4)
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, variable_gone_bad
  variable_create_name:
		#write out a word with the variable name that will return the address
		#get the address we'll return
		mv a1, a2
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
		fence.i
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
