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
	
		CODEHEADER EXCLAIM, EXECUTE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		sd t1, 0(t0)
		tail NEXT	

		CODEHEADER ABORT, EXCLAIM, 0x01
		la s7, outer_loop_ok
		tail NEXT


