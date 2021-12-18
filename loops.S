# offset for jumping
		.equ CREATEOFFSET,	40


		CODEHEADER EMIT, CONSTANT, 0x01
		li a0, 1
		mv a1, sp
		li a2, 1
		call write
		POP zero
		tail NEXT

		CODEHEADER _J, EMIT, 0x0
		ld t0, 24(s10)
		PUSH t0
		tail NEXT

		CODEHEADER _I, _J, 0x0
		ld t0, 0(s10)
		PUSH t0
		tail NEXT

		CODEHEADER _LEAVE, _I, 0x0
		addi s10, s10, 24		#unloop first
		la t0, WA__LOOP
		la t1, WA__PLUSLOOP
		la t3, WA__DO
		la t6, WA__QDO
		mv t4, zero
  leave_load_secondary:
		ld t2, 0(s7)
		beq t2, t6, leave_inc
		bne t2, t3, leave_test
  leave_inc:
		addi t4, t4, 1			#account for nested loops
		j leave_move_on
  leave_test:
		beq t2, t0, leave_maybe_leave
		beq t2, t1, leave_maybe_leave
  leave_move_on:
		addi s7, s7, 8
		j leave_load_secondary
  leave_maybe_leave:
		beqz t4, leave_leave
		addi t4, t4, -1
		j leave_move_on
  leave_leave:
		addi s7, s7, 8			#take us past loop
		tail NEXT

		CODEHEADER _UNLOOP, _LEAVE, 0x0
		addi s10, s10, 24
		tail NEXT

		CODEHEADER _PLUSLOOP, _UNLOOP, 0x0
		ld t3, 0(sp)
		addi sp, sp, 8
		ld t0, 0(s10)
		add t0, t0, t3
		ld t1, 8(s10)			#limit
		bge t0, t1, loop_over
		ld s7, 16(s10)			#return point
		sd t0, 0(s10)
		tail NEXT

		CODEHEADER _MINUSLOOP, _PLUSLOOP, 0x0
		#non-standard word
		#(x --)
		ld t3, 0(sp)
		addi sp, sp, 8
		ld t0, 0(s10)
		add t0, t0, t3
		# decrement on this path
		ld t1, 8(s10)
		bge t1, t0, loop_over		#reverse check
		ld s7, 16(s10)
		sd t0, 0(s10)
		tail NEXT

		CODEHEADER _LOOP, _MINUSLOOP, 0x0
		ld t0, 0(s10)			#current value
		addi t0, t0, 1
		ld t1, 8(s10)			#limit
		bge t0, t1, loop_over
		ld s7, 16(s10)			#return point
		sd t0, 0(s10)
		tail NEXT
  loop_over:
		addi s10, s10, 24
		tail NEXT
		
		CODEHEADER _DO, _LOOP, 0x0
		ld t0, 0(sp)			#start value
		ld t1, 8(sp)			#limit
		addi sp, sp, 16
  _do_loop:
		addi s10, s10, -24
		addi s7, s7, 8
		sd s7, 16(s10)
		sd t1, 8(s10)
		sd t0, 0(s10)
		tail NEXT

		#loop words that do nothing in immediate mode
		CODEHEADER J, _DO, 0x01
		tail NEXT

		CODEHEADER _QDO, J, 0x0
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		beq t0, t1, _qdo_no_loop
		addi s10, s10, -24
		addi s7, s7, 8
		sd s7, 16(s10)
		sd t1, 8(s10)
		sd t0, 0(s10)
		tail NEXT
  _qdo_no_loop:	
		ld s7, 0(s7)
		tail NEXT

		CODEHEADERZ QDO, ?DO, _QDO, 0x01
		tail NEXT

		CODEHEADER I, QDO, 0x01
		tail NEXT

		CODEHEADER LEAVE, I, 0x01
		tail NEXT
		
		CODEHEADER UNLOOP, LEAVE, 0x01
		tail NEXT

		CODEHEADERZ PLUSLOOP, +LOOP, UNLOOP, 0x01
		tail NEXT

		CODEHEADERZ MINUSLOOP, -LOOP, PLUSLOOP, 0x01
		tail NEXT

		CODEHEADER LOOP, MINUSLOOP, 0x01
		tail NEXT

		CODEHEADER DO, LOOP, 0x01
		tail NEXT

		CODEHEADER BEGIN, DO, 0x01
		tail NEXT			#BEGIN and UNTIL do nothing in immediate mode

		CODEHEADER UNTIL, BEGIN, 0x01
		tail NEXT

		CODEHEADER _UNTIL, UNTIL, 0x0	#subsitituted in compiled
		POP t0
		bnez t0, end_of_until
		ld s7, 0(s7)
		tail NEXT
  end_of_until:
		add s7, s7, 8
		tail NEXT

		CODEHEADER AGAIN, _UNTIL, 0x01
		tail NEXT			#do nothing in immediatre mode

		CODEHEADER _AGAIN, AGAIN, 0x0
		ld s7, 0(s7)
		tail NEXT

		CODEHEADER REPEAT, _AGAIN, 0x01
		tail NEXT

		CODEHEADER _REPEAT, REPEAT, 0x0
		ld s7, 0(s7)			#similar to _UNTIL but jump back is unconditional
		tail NEXT

		CODEHEADER CR, _REPEAT, 0x01
		WRITECHAR 0x0A
		tail NEXT

		CODEHEADER SPACE, CR, 0x01
		WRITECHAR 0x20
		tail NEXT

		CODEHEADER RDROP, SPACE, 0x01
		addi s9, s9, STACKOFFSET
		tail NEXT

		CODEHEADERZ TWORDROP, 2RDROP, RDROP, 0x01
		addi s9, s9, (2 * STACKOFFSET)
		tail NEXT

		CODEHEADERZ RFETCH, R@, TWORDROP, 0x01	#R@
		ld t0, 0(s9)
		PUSH t0
		tail NEXT

		CODEHEADERZ TWORFETCH, 2R@, RFETCH, 0x01	#2R@
		ld t0, 0(s9)
		ld t1, STACKOFFSET(s9)
		addi sp, sp, -16
		sd t1, 8(sp)
		sd t0, 0(sp) 
		tail NEXT

		CODEHEADERZ TOR2, 2>R, TWORFETCH, 0x01  #2>R
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		add s9, s9, -(STACKOFFSET * 2)
		sd t1, STACKOFFSET(s9)
		sd t0, 0(s9)
		tail NEXT

		CODEHEADERZ TOR, >R, TOR2, 0x01 #>R
		POP t0
		addi s9, s9, -STACKOFFSET
		sd t0, 0(s9)
		tail NEXT

		CODEHEADERZ RFROM, R>, TOR, 0x01 #R>
		ld t0, 0(s9)
		PUSH t0
		addi s9, s9, STACKOFFSET
		tail NEXT

		CODEHEADERZ STORE, !, RFROM, 0x01		#!
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		sd t1, 0(t0)
		tail NEXT

		CODEHEADER SPACES, STORE, 0x01
		ld a0, 0(sp)	#how many spaces
		sd s0, 0(sp)
		mv s0, a0
  spaces_go:
		beq s0, zero,  spaces_done
		WRITECHAR 0x20
		addi s0, s0, -1
		j spaces_go
  spaces_done:
		POP s0		#honour ABI
		tail NEXT

		CODEHEADERZ COLON, :, SPACES, 0x01
		#SHIFT TO COMPILE MODE
		#WRITE OUT FLAGS
		#WRITE OUT PTR
		#WRITE OUT PTR

		la t0, CREATEFLAG
		li t1, 0x01
		sd t1, 0(t0)				#set MODE to 1 (compile)
		la t1, newdictionary
		ld t3, 0(t1)
		li t2, 0x31				#49 for COLON word
		sd t2, 0(t3)				#flag
		addi t2, t3, 0x38			#word address of new word
		sd t2, 8(t3)
		la t0, dictionary
		ld t1, 0(t0)
		sd t1, 16(t3)				#words address of previous word
		sd zero, 24(t3)				#zero length
		li t2, 0XFFFFFFFFFFFFFFFF		#now fill in name space
		sd t2, 32(t3)
		sd t2, 40(t3)
		sd t2, 48(t3)
		#now read in the name
		PUSH t3		

                ld a1, INPUT_END
                ld a0, INPUT_START
                addi t0, a0, 1                        	#account for minimal input
                bltu t0, a1, colon_tokenize_have_data   #buffer has data
  colon_tokenize_all_over:
                j colon_fail
  colon_tokenize_have_data:
                mv t0, a0                             	#t0 tracks start of token, t1 the end
                li t2, 0x20                   		#t2 space
                li t3, 0x0A                   		#t3 CR
  colon_tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, colon_tokenize_keep_going
                bne t4, t3, colon_tokenize_found_start
                j colon_tokenize_all_over
  colon_tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, colon_tokenize_look_for_start
                j colon_tokenize_all_over                   #got nothing
  colon_tokenize_found_start:
                mv t1, t0                             #t1 to track end of token
  colon_tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, colon_tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, colon_tokenize_end_token
                beq t4, t3, colon_tokenize_end_token
                j colon_tokenize_advance_search
  colon_tokenize_end_token:
                sd t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
                li t5, 0x61                   #lowercase a
                li t6, 0x7B                   #lowercase z + 1
  colon_tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, colon_tokenize_next_sane
                blt t4, t6, colon_tokenize_sanitize
                j colon_tokenize_next_sane
  colon_tokenize_sanitize:
                li t3, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  colon_tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, colon_tokenize_finished_sanitization
                j colon_tokenize_sanity_test
  colon_tokenize_finished_sanitization:
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
		POP t3
		sub t4, t1, t0
		addi t4, t4, 1				#add 1 to get length
		sd t4, 24(t3)				#write out length
		addi t1, t3, 32
  colon_write_out_name:
		lb t5, 0(t0)
		sb t5, 0(t1)
		addi t4, t4, -1
		beqz t4, colon_name_written
		addi t0, t0, 1
		addi t1, t1, 1
		j colon_write_out_name
  colon_name_written:
		mv a0, t3
		addi a0, a0, 56
		mv a1, a0
		addi a1, a1, 40
		la a2, NEXT
		call utility_do_colon
		#ensure we are aligned
		li t4, 7
		and t5, a0, t4
		beqz t5, colon_finish
		li t4, 8
		sub t6, t4, t5
		add a0, a0, t6
  colon_finish:
		la t3, createwritepoint
		sd a0, 0(t3)
		tail NEXT

  colon_fail:
		la t0, CREATEFLAG
		sd zero, 0(t0)				#set MODE to 0 (no compile)
		POP zero
		PRINT bad_colon
		tail NEXT
