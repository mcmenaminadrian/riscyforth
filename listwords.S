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

		CODEHEADER _MARKER, WORDS, 0x0
		#("<spaces>name" ---)
		#compiled version of marker
		ld t0, 0(s7)					#length
		mv a0, s7
		addi a0, a0, ADDRWIDTH
		mv a1, a0
		add a1, a1, t0
		mv s7, a1					#now move s7 on to next aligned address
		addi s7, s7, 1
		li t1, 7
		and t2, s7, t1
		beqz t2, _marker_ready_to_join
		li t3, 8
		sub t4, t3, t2
		add s7, t4, s7
  _marker_ready_to_join:
		bnez t0, marker_join_here
		tail NEXT


		CODEHEADER MARKER, _MARKER, 0x01
		#("<spaces>name" ---)
		ld a0, INPUT_START
		ld a1, INPUT_END
		addi t0, a0, 1
		bltu t0, a1, marker_have_data
	        tail NEXT
  marker_have_data:
		call utility_find_string
		beq a2, zero, marker_done
		addi t0, a1, 1
		sd t0, INPUT_START, t1		#update interpretation point
  marker_join_here:
		call utility_sanitize_string
		#a0 has start a1 has end
		mv t0, a1
		sub t1, t0, a0		#t1 has length
		la t2, dictionary
		ld t3, 0(t2)
  marker_next_in_dictionary:
		lb t4, 24(t3)
		bne t4, t1, marker_tokens_do_not_match
		add a3, t3, 32
		mv a4, a0
		mv a5, t1
  marker_loop_through_token:
		lb t5, 0(a3)
		lb t6, 0(a4)
		bne t5, t6, marker_tokens_do_not_match
		addi a5, a5, -1
		beq a5, zero, marker_tokens_matched
		addi a3, a3, 1
		addi a4, a4, 1
		j marker_loop_through_token
  marker_tokens_do_not_match:
		ld t3, 16(t3)
		beq t3, zero, marker_done
		j marker_next_in_dictionary
  marker_tokens_matched:
		ld t3, 16(t3)
		sd t3, 0(t2)		#update dictionary
  marker_done:
		tail NEXT

		CODEHEADER EVALUATE, MARKER, 0x01
		#(i * x addr u -- j * x)
		li t0, 1					#mark we are in an evaluation
		sd t0, INEVAL, t2
		la t0, SOURCEID
		li t1, -1
		sd t1, 0(t0)					#set SOURCE-ID
		sd s7, RESUME_AFTER_EVAL, t0
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		#set the INPUT and OUTPUT and pass control
		la a0, INPUT_START				# get restart point
		ld a1, 0(a0)
		add a2, a1, t0					# advance
		sd a2, INPUT_START_RESTART, t3			# save for future reuse
		la a3, INPUT_DISPLACE
		ld a4, 0(a3)
		addi a4, a4, 2
		add a4, a4, t0
		sd a4, INPUT_DISPLACE_RESTART, t3		# save for reuse
		sd t1, INPUT_BUFFER_STRING, t3
		sd t1, INPUT_START, t3
		add t0, t0, t1
		sd t0, INPUT_END, t3
		sd zero, INPUT_DISPLACE, t3
		la s7, outer_loop_tokenize
		tail NEXT

		CODEHEADERZ ENVIROQ, ENVIRONMENT?, EVALUATE, 0x01
		#(c-addr u -- false | i * x true)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		li t2, eq_csLen
		bne t2, t0, enviroq_hold
		mv a0, t1
		la a1, eq_countedstrings
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_hold
		tail utility_enviroq_countedstrings
  enviroq_hold:
		li t2, eq_holdLen
		bne t2, t0, enviroq_pad
		mv a0, t1
		la a1, eq_hold
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_pad
		tail utility_enviroq_hold
  enviroq_pad:
		li t2, eq_padLen
		bne t2, t0, enviroq_aub
		mv a0, t1
		la a1, eq_pad
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_aub
		tail utility_enviroq_pad
  enviroq_aub:
		li t2, eq_aubLen
		bne t2, t0, enviroq_floored
		mv a0, t1
		la a1, eq_addressunitbits
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_floored
		tail utility_enviroq_aub
  enviroq_floored:
		li t2, eq_flooredLen
		bne t2, t0, enviroq_maxchar
		mv a0, t1
		la a1, eq_floored
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_maxchar
		tail utility_enviroq_floored
  enviroq_maxchar:
		li t2, eq_maxcharLen
		bne t2, t0, enviroq_maxd
		mv a0, t1
		la a1, eq_maxchar
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_maxd
		tail utility_enviroq_maxchar
  enviroq_maxd:
		li t2, eq_maxdLen
		bne t2, t0, enviroq_maxn
		mv a0, t1
		la a1, eq_maxd
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_maxn
		tail utility_enviroq_maxd
  enviroq_maxn:
		li t2, eq_maxnLen
		bne t2, t0, enviroq_maxu
		mv a0, t1
		la a1, eq_maxn
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_maxu
		tail utility_enviroq_maxn
  enviroq_maxu:
		li t2, eq_maxuLen
		bne t2, t0, enviroq_maxud
		mv a0, t1
		la a1, eq_maxu
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_maxud
		tail utility_enviroq_maxu
  enviroq_maxud:
		li t2, eq_maxudLen
		bne t2, t0, enviroq_rsc
		mv a0, t1
		la a1, eq_maxud
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_rsc
		tail utility_enviroq_maxud
  enviroq_rsc:
		li t2, eq_rscLen
		bne t2, t0, enviroq_sc
		mv a0, t1
		la a1, eq_returnstackcells
		mv a2, t0
		call utility_stringsmatch
		mv t0, a2
		mv t1, a0
		bnez a3, enviroq_sc
		tail utility_enviroq_rsc
  enviroq_sc:
		li t2, eq_scLen
		bne t2, t0, enviroq_false
		mv a0, t1
		la a1, eq_stackcells
		mv a2, t0
		call utility_stringsmatch
		#mv t0, a2	unneeded at present
		#mv t1, a0
		bnez a3, enviroq_false
		tail utility_enviroq_stackcells
  enviroq_false:
		addi sp, sp, -8
		sd zero, 0(sp)
  enviroq_next:
		tail NEXT

		CODEHEADER LITERAL, ENVIROQ, 0x01
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
		addi sp, sp, 16
		tail NEXT
  type_continue:
		ld t1, 8(sp)
		WRITESTRINGR t1, t0
		addi sp, sp, 16
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
		la a2, NEXT
		call utility_constant_code
		#now check if we are 8 bit aligned on writing address
		li t0, 0x07
		li t2, 0x08
		and t1, a1, t0
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
