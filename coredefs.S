# Copyright Adrian McMenamin, 2021 - 2022
# Resuse licensed under version 2 of the GNU GPL
# Words from the Forth standard core not defined somewhere else

		
		CODEHEADER _ABORTCOMM, ALLOCATE, 0x0
		#(ba -- b)
		#compiled ABORTCOMM
		ld t0, 0(sp)
		addi sp, sp, 8
		bnez t0, abortcomm_abort
		ld t0, 0(s7)
		li t1, 7
		and t2, t0, t1
		beqz t2, abort_advance
		li t3, 8
		sub t4, t3, t2
		add t0, t0, t4
  abort_advance:
		addi s7, s7, 8
		add s7, s7, t0
		tail NEXT
  abortcomm_abort:
                ld a0, 0(s7)
                mv a1, s7
                add s7, s7, a0
                li t0, 7
                and t1, s7, t0
                beqz t1, abortcomm_compiled_readyoutput
                li t2, 8
                sub t2, t2, t1
                add s7, s7, t2
  abortcomm_compiled_readyoutput:
                addi s7, s7, 8
                addi a1, a1, 8
                mv a2, a0
                li a0, 1
                li a7, 64
                ecall                   #make system call
		WRITECR
		la s7, outer_loop_ok
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail NEXT

		CODEHEADER STATE, _ABORTCOMM, 0x01
		#(-- addr)
		la t0, CREATEFLAG
		addi sp, sp, -8
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER _BRACKETCHAR, STATE, 0x0
		#("spaces<name>" --) at interpretation
		#(-- char) at runtime
		#compiled version
		ld a2, 0(s7)
		add s7, s7, 8
		mv a0, s7
		add s7, s7, a2
		li t0, 7
		and t1, s7, t0
		beqz t1, _bracketchar_adjustment_over
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  _bracketchar_adjustment_over:
		j bracketchar_completion
		tail NEXT

		CODEHEADERZ BRACKETCHAR, [CHAR], _BRACKETCHAR, 0x01
		#("spaces<name>" --) at interpretation
		#(-- char) at runtime
		#places first char of name on stack
		ld a0, INPUT_START
		ld a1, INPUT_END
		call utility_find_string
		beqz a0, bracketchar_error
		#a0 has start, a1 has end + 1, a2 has length
		sd a1, INPUT_START, t5
  bracketchar_completion:
		lb t0, 0(a0)
		addi sp, sp, -8
		sd t0, 0(sp)
		tail NEXT
  bracketchar_error:
		tail variable_gone_bad

		CODEHEADER CASE, BRACKETCHAR, 0x01
		#( -- )
		tail NEXT

		CODEHEADER ENDOF, CASE, 0x01
		tail NEXT

		CODEHEADER _OF, ENDOF, 0x00
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
		beq t0, t1, _of_execute
		#did not match so advance until we hit ENDOF
		la t0, WA_ENDOF
  _of_keep_looking:
		ld t1, 0(s7)
		addi s7, s7, 8
		beq t0, t1, _of_execute
		j _of_keep_looking
  _of_execute:
		tail NEXT

		CODEHEADER OF, _OF, 0x01
		#do nothing in immediate mode
		tail NEXT

		CODEHEADER ENDCASE, OF, 0x01
		addi sp, sp, STACKOFFSET
		tail NEXT

		CODEHEADERZ ZERONE, 0<>, ENDCASE, 0x01
		#(x -- flag)
		ld t0, 0(sp)
		bnez t0, zerone_not_zero
		sd zero, 0(sp)
		tail NEXT
  zerone_not_zero:
		li t0, -1
		sd t0, 0(sp)
		tail NEXT

		CODEHEADERZ ZEROMORE, 0>, ZERONE, 0x01
		#(n -- flag)
		ld t0, 0(sp)
		bgt t0, zero, zerone_not_zero		#see above
		sd zero, 0(sp)
		tail NEXT

		CODEHEADERZ TWOFETCH, 2@, ZEROMORE, 0x01
		#(addr -- x1 x2)
		ld t0, 0(sp)
		ld t1, 0(t0)
		ld t2, 8(t0)
		sd t2, 0(sp)
		addi sp, sp, -8
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER SEQ, TWOFETCH, 0x01
		# expanded to/from S\"
		# does nothing in interpretation
		tail NEXT

		CODEHEADER _SEQ, SEQ, 0x0
		#( -- c-addr u)
		ld t0, 0(s7)
		ld t1, 8(s7)
		mv t2, s7
		addi t2, t2, 16
		addi sp, sp, -16
		sd t2, 8(sp)
		sd t1, 0(sp)
		mv s7, t0
		tail NEXT
	

		CODEHEADERZ TIMESDIV, */,  SEQ, 0x01
		#(n1 n2 n3 -- n4)
		# n1 * n2 -> d, d / n3 -> n4
		ld a0, 0(sp)			#n3 - divisor
		ld a1, 8(sp)			#n2
		ld a2, 16(sp)			#n1
		addi sp, sp, 16			#
		beqz a2, timesdiv_zero_div	#no division by zero
		mulh t0, a1, a2
		mul t1, a1, a2
		rem t4, t0, a0
		mv a1, t1
		mv a2, a0
		mv a0, t0
		mv a3, t0
		call long_division_signed
		beqz a7, timesdiv_zero_div	#failure
		sd a0, 0(sp)
		tail NEXT
  timesdiv_zero_div:
		sd zero, 0(sp)
		tail NEXT

		CODEHEADERZ RESTOREINPUT, RESTORE-INPUT, TIMESDIV, 0x0
		#(xn...x1 n --- flag)
		#current this just empties the stack and posts TRUE flag
		ld t0, 0(sp)
		li t1, -8
		mul t0, t0, t1
		add sp, sp, t0
		li t0, 0xFFFFFFFFFFFFFFFF
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER REFILL, RESTOREINPUT, 0x0
		#(-- flag)
		#current just puts -1 (TRUE) on the stack
		li t0, 0xFFFFFFFFFFFFFFFF
		addi sp, sp, -8
		sd t0, 0(sp)
		tail NEXT

		CODEHEADERZ PARSENAME, PARSE-NAME, REFILL, 0x01
		#( "<spaces>name<space>" -- c-addr u )
		la t0, INPUT_START
		ld a0, 0(t0)
		addi a1, a0, 512
		call utility_find_string
		addi sp, sp, -16
		sd a0, 8(sp)
		sd a2, 0(sp)
		la t0, INPUT_START
		addi a1, a1, 1
		sd a1, 0(t0)
		tail NEXT

		CODEHEADER PARSE, PARSENAME, 0x01
		#char "ccc<char>" -- c-addr u
		ld t0, 0(sp)
		la t1, INPUT_START
		ld t1, 0(t1)
		li t2, 0x20
		li t3, 0x0A
		addi a0, t1, 512
		mv a6, zero
		mv a7, zero
  parse_look_for_start:
		lb t4, 0(t1)
		addi t1, t1, 1
		bgt t1, a0, parse_done
		beq t4, t2, parse_look_for_start
		beq t4, t3, parse_look_for_start
		mv a1, t1
		addi a1, a1, -1
  parse_look_for_end:
		beq t4, t0, parse_finished
		addi t1, t1, 1
		bgt t1, a0, parse_finished
		lb t4, 0(t1)
		j parse_look_for_end
  parse_finished:
		sub a7, t1, a1
		mv a6, a1
		la t1, INPUT_START
		add t2, a7, a6
		addi t2, t2, 1
		sd t2, 0(t1)
  parse_done:
		sd a6, 0(sp)
		addi sp, sp, -8
		sd a7, 0(sp)
		tail NEXT

		CODEHEADER WORD, PARSE, 0x01
		#char "<chars>ccc<char> -- c-addr
		ld a1, 0(sp)
		la a0, INPUT_START
		ld a0, 0(a0)
		call utility_parse_string
		la t0, INPUT_START
		add t1, a0, a1
		addi t1, t1, 1
		sd t1, 0(t0)
		mv a2, a0
		la a0, SCRATCH_PAD
		call utility_copy_counted_string
		la t0, SCRATCH_PAD
		sd t0, 0(sp)
		tail NEXT

		CODEHEADERZ ZEROLESS, 0<, WORD, 0x01
		#(n -- flag)
		ld t0, 0(sp)
		bltz t0, zeroless_true
		sd zero, 0(sp)
		tail NEXT
  zeroless_true:
		li t1, -1
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER ZEROEQUAL, ZEROLESS, 0x01
		#(n -- flag)
		ld t0, 0(sp)
		beqz t0, zeroless_true
		sd zero, 0(sp)
		tail NEXT

		CODEHEADERZ TWOTIMES, 2*, ZEROEQUAL, 0x01
		#(x -- x)
		li t0, 2
		ld t1, 0(sp)
		mul t2, t1, t0
		sd t2, 0(sp)
		tail NEXT

		CODEHEADERZ TWODIV, 2/, TWOTIMES, 0x01
		#(x -- x)
		ld t0, 0(sp)
		srai t1, t0, 1
		sd t1, 0(sp)
		tail NEXT

		CODEHEADERZ TWOSTORE, 2!, TWODIV, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		addi sp, sp, 24
		sd t1, 0(t0)
		sd t2, 8(t0)
		tail NEXT

		CODEHEADERZ TIMESDIVMOD, */MOD, TWOSTORE, 0x01
		#(n1 n2 n3 -- n4 n5)
		#same code as DIVMOD - but with remainder stored
		ld a0, 0(sp)			#n3
		ld a1, 8(sp)			#n2
		ld a2, 16(sp)			#n1
		addi sp, sp, 24			#slow call, so just make stack manip clear
		li t0, 0x8000000000000000
		and t1, a2, t0
		and t2, a1, t0
		PUSH a0
		mv a0, a2
		xor a2, t1, t2
		beqz a2, timesdivmod_call_multiply
		li a2, 1
  timesdivmod_call_multiply:
		addi sp, sp, -16			#needed for call
		call multiple_bit_calculate_signed
		#a1 has lower part, a0 has upper
		#get rid of stack
		addi sp, sp, 16
		#now division time
		POP a2
		rem t0, a0, a2
		mv a0, t0
		call long_division_signed
		addi sp, sp, -16
		beqz a7, timesdivmod_fail
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT
  timesdivmod_fail:
		sd zero, 8(sp)
		sd zero, 0(sp)
		tail NEXT

		CODEHEADER PAGE, TIMESDIVMOD, 0x01
		#(--)
		#Clear the screen go home, reset all settings
		# \e[2J\ec
		addi sp, sp, -56
		li t0, 0x63
		sd t0, 40(sp)
		li t0, 0x1B
		sd t0, 32(sp)
		li t0, 0x4A
		sd t0, 24(sp)
		li t0, 0x32
		sd t0, 16(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x90
		sd t0, 48(sp)
		j DISPLAY

		CODEHEADER YELLOW, PAGE, 0x01
		#Yellow foreground text
		#\e[33m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER WHITE, YELLOW, 0x01
		#Normal white on black text
		#\e[37m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x37
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY
		

		CODEHEADER RED, WHITE, 0x01
		#red text
		#\e[31m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x31
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY


		CODEHEADER GREEN, RED, 0x01
		#green text
		#\e[32m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x32
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BLUE, GREEN, 0x01
		#blue text
		#\e[34m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x34
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER MAGENTA, BLUE, 0x01
		#magenta text
		#\e[35m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x35
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER CYAN, MAGENTA, 0x01
		#cyan text
		#\e[36m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x36
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BYELLOW, CYAN, 0x01
		#Yellow background
		#\e[43m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x33
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BWHITE, BYELLOW, 0x01
		#white background
		#\e[47m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x37
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY
		

		CODEHEADER BRED, BWHITE, 0x01
		#red background
		#\e[41m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x31
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY


		CODEHEADER BGREEN, BRED, 0x01
		#green background
		#\e[42m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x32
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BBLUE, BGREEN, 0x01
		#blue background
		#\e[44m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x34
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BMAGENTA, BBLUE, 0x01
		#magenta background
		#\e[45m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x35
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BCYAN, BMAGENTA, 0x01
		#cyan background
		#\e[46m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x36
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BLACK, BCYAN, 0x01
		#black text
		#\e[30m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x33
		sd t0, 16(sp)
		li t0, 0x30
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY


		CODEHEADER BBLACK, BLACK, 0x01
		#black background
		#\e[40m
		addi sp, sp, -48
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x34
		sd t0, 16(sp)
		li t0, 0x30
		sd t0, 24(sp)
		li t0, 0x6D
		sd t0, 32(sp)
		li t0, 0x90
		sd t0, 40(sp)
		j DISPLAY

		CODEHEADER BRIGHT, BBLACK, 0x01
		#bright
		#\e[1m
		addi sp, sp, -40
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x31
		sd t0, 16(sp)
		li t0, 0x6D
		sd t0, 24(sp)
		li t0, 0x90
		sd t0, 32(sp)
		j DISPLAY

		CODEHEADER RESET, BRIGHT, 0x01
		#reset display attributes
		#\e[0m
		addi sp, sp, -40
		li t0, 0x1B
		sd t0, 0(sp)
		li t0, 0x5B
		sd t0, 8(sp)
		li t0, 0x30
		sd t0, 16(sp)
		li t0, 0x6D
		sd t0, 24(sp)
		li t0, 0x90
		sd t0, 32(sp)
		j DISPLAY

		CODEHEADER ABORTCOMM, RESET, 0x01
		#does nothing in interpretration mode
		tail NEXT

		CODEHEADER RECURSE, ABORTCOMM, 0x01
		#does nothing on interpretation
		#compilation handled in search_create
		tail NEXT

		CODEHEADER PAD, RECURSE, 0x01
		la t0, SCRATCH_PAD
		PUSH t0
		tail NEXT

		CODEHEADER FILL, PAD, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		beqz t1, fill_done
		ld t2, 16(sp)
  fill_fill:
		sb t0, 0(t2)
		addi t2, t2, 1
		addi t1, t1, -1
		bnez t1, fill_fill
  fill_done:
		addi sp, sp, 24
		tail NEXT

		CODEHEADER ERASE, FILL, 0x01
		ld t0, 0(sp)
		beqz t0, erase_done
		ld t1, 8(sp)
  erase_erase:
		sb zero, 0(t1)
		addi t1, t1, 1
		addi t0, t0, -1
		bnez t0, erase_erase
  erase_done:
		addi sp, sp, 16
		tail NEXT

		CODEHEADERZ PLUSSTORE, +!, ERASE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		ld t2, 0(t0)
		add t2, t1, t2
		sd t2, 0(t0)
		tail NEXT

		CODEHEADER LSHIFT, PLUSSTORE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		li t2, 64
		addi sp, sp, 8
		bge t0, t2, lshift_set_zero
		sll t1, t1, t0
		sd t1, 0(sp)
		tail NEXT
  lshift_set_zero:
		sd zero, 0(sp)
		tail NEXT

		CODEHEADER RSHIFT, LSHIFT, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		li t2, 64
		addi sp, sp, 8
		bge t0, t2, lshift_set_zero
		srl t1, t1, t0
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER _WHILE, RSHIFT, 0x0
		ld t0, 0(sp)
		addi sp, sp, 8
		beqz t0, _while_finished
		addi s7, s7, 16		#true path
		tail NEXT
  _while_finished:
		ld t0, 0(s7)
		beqz t0, _while_then
  _while_continuation:
		mv s7, t0
		tail NEXT
  _while_then:
		ld t0, 8(s7)
		bnez t0, _while_continuation
  _while_failed:
		tail trackback_failed

		CODEHEADER WHILE, _WHILE, 0x01
		#Do nothing in immediate mode
		tail NEXT
		
		CODEHEADER MOVE, WHILE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		addi sp, sp, 24
		bnez t0, move_do
  move_done:
		tail NEXT
  move_do:
		lbu t3, 0(t2)
		sb t3, 0(t1)
		addi t0, t0, -1
		beqz t0, move_done
		addi t2, t2, 1
		addi t1, t1, 1
		j move_do

		CODEHEADER SOURCE, MOVE, 0x01
		la t0, INPUT_BUFFER
		mv t1, zero
		li t2, 0x0A
		li t6, BUFFERLEN
		mv t3, zero
  source_load_next:
		add t5, t3, t0
		lbu t4, 0(t5)
		beq t4, t2, source_end_reached
		beqz t4, source_end_reached
		addi t3, t3, 1
		bge t3, t6, source_end_reached
		j source_load_next
  source_end_reached:
		addi sp, sp, -16
		sd t0, 8(sp)
		sd t3, 0(sp)
		tail NEXT
		
		CODEHEADER EXECUTE, SOURCE, 0x01
		#(xt --)
		#Code will crash system if used badly!
		POP s8
		tail RUN

		CODEHEADER _TICK, EXECUTE, 0x0
		#get length
		ld a0, 0(s7)
		mv a1, s7
		addi s7, s7, 8
		add s7, s7, a0
		li t0, 7
		and t1, s7, t0
		beqz t1, _tick_adjustment_over
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  _tick_adjustment_over:
		#now rejoin TICK
		add t0, a1, 8
		add t1, a0, t0
		tail tick_process_found_token

		CODEHEADER TICK, _TICK, 0x01
		#Parse the input
		#Sanitize it first
		call tick_start_looking
		j tick_process_found_token
		
		#code that follows is subroutine to accommodate compiled code too
  tick_start_looking:
		la a0, INPUT_START
		la a1, INPUT_END
		ld a0, 0(a0)
		ld a1, 0(a1)
		add t0, a0, 1
		bltu t0, a1, tick_have_data
		tail search_failed			#bail
  tick_have_data:
		mv t0, a0
		li t2, 0x020
		li t3, 0x0A
  tick_look_for_start:
		lbu t4, 0(t0)
		beq t4, t2, tick_keep_going
		bne t4, t3, tick_found_start
		tail search_failed
  tick_keep_going:
		add t0, t0, 1
		bltu t0, a1, tick_look_for_start
		tail search_failed
  tick_found_start:
		mv t1, t0
  tick_advance_search:
		addi t1, t1, 1
		bgeu t1, a1, tick_end_token
		lbu t4, 0(t1)
		beq t4, t2, tick_end_token
		beq t4, t3, tick_end_token
		j tick_advance_search
  tick_end_token:
		sd t1, INPUT_START, t5
		ret

  tick_process_found_token:
		la a7, tick_finished_sanitization
		addi t1, t1, -1				#space or CR not part of token
		mv t2, t0
		sub a0, t1, t0				#will be 0 if token is of length 1 etc
		bnez a0, tick_length_two_or_more
		call tick_fix_up_single
		j tick_prepare_sanity_test		#can skip the other tests for length
  tick_length_two_or_more:
		li a1, 1
		bne a0, a1, tick_length_three_or_more
		call tick_fix_up_length_two
		j tick_prepare_sanity_test
  tick_length_three_or_more:
		li a1, 2
		bne a0, a1, tick_length_six_or_more
		call tick_fix_up_length_three
		j tick_prepare_sanity_test
  tick_length_six_or_more:
		li a1, 5
		bne a0, a1, tick_length_eight_or_more
		call tick_fix_up_length_six
		j tick_prepare_sanity_test
  tick_length_eight_or_more:
		li a1, 7
		bne a0, a1, tick_prepare_sanity_test
		call tick_fix_up_length_eight
  tick_prepare_sanity_test:
		li t3, 0x5F
		addi t5, zero, 0x61
		addi t6, zero, 0x7B
  tick_sanity_test:
		lbu t4, 0(t2)
		blt t4, t5, tick_next_sane
		blt t4, t6, tick_sanitize
		j tick_next_sane
  tick_sanitize:
		and t4, t4, t3
		sb t4, 0(t2)
  tick_next_sane:
		addi t2, t2, 1
		blt t1, t2, tick_finished_sanitization
		j tick_sanity_test
  tick_finished_sanitization:
		#look up the command
		sub t2, t1, t0
		addi t2, t2, 1
		la t4, dictionary
		ld t3, 0(t4)
  tick_next_in_dictionary:
		lbu t4, 24(t3)
		bne t4, t2, tick_tokens_do_not_match
		add a0, t3, 32
		mv a1, t0
		mv a2, t2
  tick_loop_through_token:
		lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, tick_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, tick_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j tick_loop_through_token
  tick_tokens_do_not_match:
		ld t3, 16(t3)
		beqz t3, tick_exhausted
		j tick_next_in_dictionary
  tick_tokens_matched:
		addi t3, t3, 8
		PUSH t3
		tail NEXT
  tick_exhausted:
		tail search_failed

		CODEHEADER BRACKETTICK, TICK, 0x01
		#really not an immediate word!
		tail TICK

		CODEHEADERZ CFETCH, C@, BRACKETTICK, 0x01
		ld t0, 0(sp)
		lbu t1, 0(t0)
		sd t1, 0(sp)
		tail NEXT

		CODEHEADERZ CSTORE, C!, CFETCH, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		sb t1, 0(t0)
		tail NEXT

		CODEHEADERZ DOTR, .R, CSTORE, 0x01
		#(n1 n2 --)
		#field width is n2
		#use scratch pad to store result
		ld t0, 8(sp)
		la t1, CURRENT_BASE
		ld t1, 0(t1)
		ld t2, 0(sp)
		addi sp, sp, 16
		la t3, SCRATCH_PAD
		#base conversion
		mv a0, zero
		mv a1, zero
		bge t0, zero, dotr_positive
		li a0, 1		#negative
		li a1, 1
		neg t0, t0
  dotr_positive:
		mv a3, t3
		li a2, 0x3A		#ascii 9 + 1
		mv a4, t0
  dotr_calculate:
		div a5, a4, t1
		mul a6, a5, t1
		sub a7, a4, a6		#digit we need
		mv a4, a5		
		addi a7, a7, 0x30	#0x30 = 0 ascii
		blt a7, a2, dotr_adddigit
		addi a7, a7, 7		#rebase digit
  dotr_adddigit:
		sb a7, 0(a3)
		addi a3, a3, 1
		addi a1, a1, 1
		bnez a4, dotr_calculate
		#calculation finished - do we need to flush right?
		bge a1, t2, dotr_output
		sub t4, t2, a1
  dotr_spaces:
		PUSH a0
		PUSH a1
		WRITECHAR 0x20
		POP a1
		POP a0
		addi t4, t4, -1
		bnez t4, dotr_spaces
  dotr_output:
		#negative sign?
		beqz a0, dotr_nonegative
		PUSH a0
		PUSH a1
		WRITECHAR 0x2D
		POP a1
		POP a0
		addi a1, a1, -1
  dotr_nonegative:
		mv t4, a1
		addi t4, t4, -1
		add t5, t3, t4
		mv t6, t3
		#now reverse
  dotr_reverse:
		ble t5, t6, dotr_reversal_done
		lb a2, 0(t5)
		lb a3, 0(t6)
		sb a3, 0(t5)
		sb a2, 0(t6)
		addi t6, t6, 1
		addi t5, t5, -1
		j dotr_reverse
  dotr_reversal_done:
		mv a2, a1
		WRITESTRINGR t3, a2
		tail NEXT

		CODEHEADER COUNT, DOTR, 0x01
		#(addr1 -- addr2 u)
		ld t0, 0(sp)
		ld t1, 0(t0)
		addi t0, t0, ADDRWIDTH
		sd t0, 0(sp)
		addi sp, sp, -STACKOFFSET
		sd t1, 0(sp)
		tail NEXT
		
		CODEHEADER _EXIT, COUNT, 0x0
		# just call SEMI
		tail SEMI

		CODEHEADER EXIT, _EXIT, 0x01
		tail NEXT				#do nothing in immediate mode

		CODEHEADER IMMEDIATE, EXIT, 0x01
		#( -- )
		#find the word at the bottom of the dictionary and mark it as immediate
		la t0, dictionary
		ld t1, 0(t0)
		ld t2, 0(t1)
		li a0, 0x100
		or t2, t2, a0
		sd t2, 0(t1)
		fence.i
		tail NEXT

		CODEHEADER _CHAR, IMMEDIATE, 0x0
		#get length
		ld a0, 0(s7)
		mv a1, s7
		addi s7, s7, ADDRWIDTH
		add s7, s7, a0
		li t0, 7
		and t1, s7, t0
		beqz t1, _char_done_adjustment
		li t2, ADDRWIDTH
		sub t2, t2, t1
		add s7, s7, t2
  _char_done_adjustment:
		addi a1, a1, ADDRWIDTH
		lbu t0, 0(a1)
		PUSH t0
		tail NEXT

		CODEHEADERZ BRACKET, [, _CHAR, 0x101
		#no stack action - go into immediate mode
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail NEXT

		CODEHEADERZ RIGHTBRACKET, ], BRACKET, 0x101
		la t0, CREATEFLAG
		li t1, 1
		sd t1, 0(t0)
		tail NEXT

		CODEHEADER COMPILECOMMA, RIGHTBRACKET, 0x01
		#does nothing in interpretation
		#( -- )
		tail NEXT

		CODEHEADER POSTPONE, COMPILECOMMA, 0x01
		#see search_create for compile code
		tail NEXT

		CODEHEADERZ P, (, POSTPONE, 0x101
		# look for the closing bracket - this is an immediate word
		la t0, INPUT_START
		la t1, INPUT_END
		ld t2, 0(t0)
		ld t3, 0(t1)
		li t4, 0x29		#)
  paren_look:
		lbu t5, 0(t2)
		beq t4, t5, paren_closed
		addi t2, t2, 1
		bgt t2, t3, paren_ended
		j paren_look
  paren_closed:
		addi t2, t2, 1
  paren_ended:
		sd t2, 0(t0)
		tail NEXT
  
		CODEHEADER CHAR, P, 0x01
		#reuse old code for interpreter mode
		call tick_start_looking
		lbu t1, 0(t0)
		PUSH t1
		tail NEXT

		CODEHEADER QUIT, CHAR, 0x01
		#(?? --)
		#currently restarts interpreter which is not quite correct
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail main

		CODEHEADER BASE, QUIT, 0x01
		la t0, CURRENT_BASE
		PUSH t0
		tail NEXT

		CODEHEADERZ FETCH, @,  BASE, 0x01
		ld t0, 0(sp)
		ld t1, 0(t0)
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER BL, FETCH, 0x01
		li t0, 0x20
		PUSH t0
		tail NEXT

		CODEHEADER DEPTH, BL, 0x01
		la t0, STACKTOP
		ld t1, 0(t0)
		sub t2, t1, sp
		srai t3, t2, 3
		PUSH t3
		tail NEXT

		CODEHEADER _ACTIONOF, DEPTH, 0x00
		#( -- xt)
		#compiled version
		ld a2, 0(s7)		#length
		mv a1, a0
		addi s7, s7, 8
		mv a0, s7
		add s7, s7, a2
		li t0, 7
		and t1, s7, t0
		beqz t1, _actionof_adjustment_over
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  _actionof_adjustment_over:
		j actionof_completion

		CODEHEADERZ ACTIONOF,  ACTION-OF, _ACTIONOF, 0x01
		#("name" -- xt)
		#parse name
		#in interpreter mode here
		# look for the string
		ld a0, INPUT_START
		ld a1, INPUT_END
		call utility_find_string
		beqz a0, actionof_error
		#a0 has start, a1 has end + 1, a2 has length
		sd a1, INPUT_START, t5
		call utility_sanitize_string
  actionof_completion:
		call utility_check_dictionary_match
		beqz a3, actionof_error
		ld t0, 160(a4)
		addi sp, sp, -8
		sd t0, 0(sp)
		tail NEXT
  actionof_error:
		tail variable_gone_bad

		CODEHEADER FIND, ACTIONOF, 0x01
		#(caddr -- caddr 0 | xt 1 | xt -1)
		#Counted string caddr
		# 0 for unfound, 1 for immediate, -1 for otherwise
		ld t0, 0(sp)
		ld a2, 0(t0)		# count
		addi sp, sp, -STACKOFFSET
		addi a0, t0, ADDRWIDTH
		add a1, a0, a2
		call utility_check_dictionary_match
		beqz a3, find_failed
		addi a4, a4, ADDRWIDTH
		sd a4, 8(sp)
		#have a word - is it immediate?
		li t2, 0x100
		ld t3, -8(a4)
		and t4, t2, t3
		beqz t4, find_ordinary
		li t6, 1
		sd t6, 0(sp)
		tail NEXT
  find_ordinary:
		li t6, -1
		sd t6, 0(sp)
  		tail NEXT
  find_failed:
		sd zero, 0(sp)
		tail NEXT

		CODEHEADER ABORT, FIND, 0x01
		la s7, outer_loop_ok
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail NEXT


  tick_fix_up_single:
		mv a0, t0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x3B
		beq t2, t1, tix_up_semi
		li t2, 0x3D
		beq t2, t1, tix_up_equals
		li t2, 0x27
		beq t2, t1, tix_up_tick
		li t2, 0x2C
		beq t2, t1, tix_up_comma
		j tix_up_finished
  tix_up_semi:
		call do_fix_up_semi
		j tix_up_done
  tix_up_equals:
		call do_fix_up_equals
		j tix_up_done
  tix_up_tick:
		call do_fix_up_tick
		j tix_up_done
  tix_up_comma:
		call do_fix_up_comma
		j tix_up_done

  tix_up_done:
		mv t0, a3
		mv t1, a2
		jr a7

  tix_up_finished:
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret

  tick_fix_up_length_two:
		mv a0, t0
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x30			#0
		beq t1, t2, tick_length_two_beginzero
		li t2, 0x2E			#.
		beq t1, t2, tick_length_two_begindot
		li t2, 0x3E			#>
		beq t1, t2, tick_length_two_begingt
		li t2, 0x3C			#<
		beq t1, t2, tick_length_two_beginlt
		PUSH t1
		andi t1, t1, 0x5F		#character based tests all in here
		li t2, 0x43
		beq t1, t2, tick_length_two_beginC
		li t2, 0x53
		beq t1, t2, tick_length_two_beginS
		POP t1
  tix_up_length_two_finished:
		j tix_up_finished

  tick_length_two_begindot:
		lbu t1, 1(a0)
		li t2, 0x22			#"
		bne t1, t2, tick_length_two_begindot_done
                call fix_up_encsq
		j tix_up_done
  tick_length_two_begindot_done:
		j tix_up_length_two_finished
		
  tick_length_two_beginzero:
		lbu t1, 1(a0)
		li t2, 0x3D			#=
		bne t1, t2, tick_length_two_begindot_done
                call fix_up_zeroequal
		j tix_up_done

  tick_length_two_begingt:
		lbu t1, 1(a0)
		li t2, 0x3D			#=
		bne t1, t2, tick_length_two_begindot_done
                call fix_up_gteq
		j tix_up_done

  tick_length_two_beginlt:
		lbu t1, 1(a0)
		li t2, 0x3D			#=
		bne t1, t2, tick_length_two_begindot_done
                call fix_up_lteq
		j tix_up_done

  tick_length_two_beginC:
		sb t1, 0(a2)
		addi sp, sp, 8
		lbu t1, 1(a0)
		li t2, 0x2C
		bne t1, t2, tick_length_two_cq
		call fix_up_ccomma		#,
		j tix_up_done
  tick_length_two_cq:
		li t2, 0x22			#"
		bne t1, t2, tick_length_two_c_done
		call fix_up_cq
		j tix_up_done
  tick_length_two_c_done:
		j tix_up_length_two_finished


  tick_length_two_beginS:
		sb t1, 0(a2)
		addi sp, sp, 8
		lbu t1, 1(a0)
		li t2, 0x22			#"
		bne t1, t2, tick_length_two_c_done
		call fix_up_squote
		j tix_up_done

  tick_fix_up_length_three:
		#expand ['] --> BRACKETTICK
		#expand S\" --> SEQ
		mv a0, t0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
                li t3, 0xDF             #to fix to upper case
                and t4, t1, t3
                li t2, 0x53             #S
                bne t4, t2, tick_fix_up_check_bracket
                lbu t1, 1(a0)
                li t2, 0x5C             #\
                bne t1, t2, tix_up_six_done
		lbu t1, 2(a0)
                li t2, 0x22
                bne t1, t2, tix_up_six_done
                call fix_up_seq
                j tix_up_done

  tick_fix_up_check_bracket:
		li t2, 0x5B		#[
		bne t1, t2, tix_up_six_done
		lbu t1, 1(a0)
		li t2, 0x27		#'
		bne t1, t2, tix_up_six_done
		lbu t1, 2(a0)
		li t2, 0x5D		#]
		bne t1, t2, tix_up_six_done
		call fix_up_brackettick
		j tix_up_done

  tick_fix_up_length_eight:
		#expand COMPILE, --> COMPILECOMMA
		#COMPILE: 0x43 0x4F 0x4D 0x50 0x49 0x4C 0x45
		#COMMA: 0x43 0x4F 0x4D 0x4D 0x41
		mv a0, t0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		li t2, 0x43		#C
		lbu t1, 0(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x4F		#O
		lbu t1, 1(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x4D		#M
		lbu t1, 2(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x50		#P
		lbu t1, 3(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x49		#I
		lbu t1, 4(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x4C		#L
		lbu t1, 5(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x45		#E
		lbu t1, 6(a0)
		andi t1, t1, 0x5F
		bne t1, t2, tix_up_six_done
		li t2, 0x2C		#,
		lbu t1, 11(a0)
		bne t1, t2, tix_up_six_done
		call fix_up_compilecomma
		j tix_up_done

  tick_fix_up_length_six:
		#expand the following
		# ABORT" --> ABORTCOMM
		mv a0, t0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		lbu t1, 5(a0)
		li t2, 0x22		 #"
		bne t1, t2, tix_up_six_done
		call fix_up_acomma
		j tix_up_done
  tix_up_six_done:
		j tix_up_finished

