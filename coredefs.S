# Copyright Adrian McMenamin, 2021
# Resuse licensed under version 2 of the GNU GPL
# Words from the Forth standard core not defined somewhere else

		
		CODEHEADER _ABORTCOMM, LOAD, 0x0                
		#compiled ABORTCOMM
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
		tail NEXT

		CODEHEADER ABORTCOMM, _ABORTCOMM, 0x01
		#Print in a string
		#first of all, get the address and length of the string
		la t5, INPUT_END
		ld t5, 0(t5)		#absolute end of string
		li t3, 0
		la t6, INPUT_START
		ld t4, 0(t6)
		li t1, 0x22		#"
  abort_check_next:
		lb t0, 0(t4)
		beq t0, t1, abort_prep_imm_syscall
		addi t3, t3, 1
		add t4, t4, 1
		blt t4, t5, abort_check_next
		la t0, String_err
		li t1, 18		#length of error message
		WRITESTRINGR t0, t1
		la s7, outer_loop_ok
		tail NEXT
  abort_prep_imm_syscall:
		ld t4, 0(t6)
		addi t2, t3, 1
		add t1, t4, t2
		sd t1, 0(t6)
		WRITESTRINGR t4, t3
		la s7, outer_loop_ok
		tail NEXT

		CODEHEADER EXECUTE, ABORTCOMM, 0x01
		#Code will crash system if used badly!
		POP s8
		tail RUN

		CODEHEADER TICK, EXECUTE, 0x01
		#Parse the input
		#Sanitize it first
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
		lb t4, 0(t0)
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
		lb t4, 0(t1)
		beq t4, t2, tick_end_token
		beq t4, t3, tick_end_token
		j tick_advance_search
  tick_end_token:
		sd t1, INPUT_START, t5
		addi t1, t1, -1				#space or CR not part of token
		mv t2, t0
		sub a0, t1, t0				# will be 0 if token is of length 1 etc
		bnez a0, tick_length_two_or_more
		j tick_fix_up_single
  tick_length_two_or_more:
		li a1, 1
		bne a0, a1, tick_length_three_or_more
		j tick_fix_up_length_two
  tick_length_three_or_more:
		li a1, 5
		bne a0, a1, tick_prepare_sanity_test
		j tick_fix_up_length_six
  tick_fix_up_length_two:
  tick_prepare_sanity_test:
  tick_fix_up_length_six:
		#look up the command
		
	
		CODEHEADER EXCLAIM, TICK, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		sd t1, 0(t0)
		tail NEXT	

		CODEHEADER ABORT, EXCLAIM, 0x01
		la s7, outer_loop_ok
		tail NEXT


  tick_fix_up_single:
		mv a0, t0
		la a2, EXPANDED_BUFFER
		mv a3, a2

