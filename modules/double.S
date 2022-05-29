# experimental double module
.include "../macros.S"
#.include "../riscylib/riscyvar.S"
.section .bss
    .comm NEXTMOD, 8
    .comm LOCAL_INPUT_START, 8
    .comm LOCAL_INPUT_END, 8


.extern INPUT_START
.section .text
.balign 8
	CODEEND DABS, 0x01
	#(d -- d)
	ld t1, 8(sp)
	ld t0, 0(sp)
	li t2, 0x8000000000000000
	and t3, t2, t1
	beqz t3, dabs_done
	li t3, -1
	xor t1, t1, t3
	xor t2, t0, t3
	addi t2, t2, 1
	bnez t0, dabs_store
	addi t1, t1, 1
  dabs_store:
	sd t1, 8(sp)
	sd t2, 0(sp)
  dabs_done:
	la t1, NEXTMOD
	ld t1, 0(t1)
	jr t1

	CODEHEADERZ TWOCONSTANT, 2CONSTANT, DABS, 0x01
	#( x1 x2 "<spaces>name --)
	li a5, 0x200	#0x200 for a 2constant
	ld t1, 8(sp)
	ld t0, 0(sp)
	call getInputStart		#a0 has INPUT_START
	la t0, LOCAL_INPUT_START
	sd a0, 0(t0)
	sd a0, 8(sp)
	call getInputEnd
	la t0, LOCAL_INPUT_END
	sd a0, 0(t0)
	sd a0, 0(sp)
	li a0, 0x61	#a
	li a1, 0x7B	#z + 1
	li a2, 0x20	#space/xor
	li a3, 0	#have we started
	la t0, LOCAL_INPUT_START
	ld t1, 0(t0)
	la t2, LOCAL_INPUT_END
	ld t3, 0(t2)
  twoconstant_sanitize_load:
	bgt t1, t3, twoconstant_sanitize_done
	lb t4, 0(t1)
	beq t4, a3, twoconstant_check_started
	li a3, 1	#started
	blt t4, a0, twoconstant_sanitize_advance
	li t5, 0xFFF
	blt t4, a1, twoconstant_sanitize_process
  twoconstant_sanitize_advance:
	addi t1, t1, 1
	j twoconstant_sanitize_load
  twoconstant_sanitize_process:
	li t5, 0xFFFF
	xor t4, t4, a2
	li t5, 0xFFFFF
	sb t4, 0(t1)
	j twoconstant_sanitize_advance
  twoconstant_sanitize_check_started:
	beqz a3, twoconstant_sanitize_advance
  twoconstant_sanitize_done:
	TAILMOD t1

	CODEHEADERZ DPLUS, D+, TWOCONSTANT, 0x01
	#(d1 d2 -- d3)
	ld t0, 24(sp)
	ld t1, 16(sp)
	ld t2, 8(sp)
	ld t3, 0(sp)
	addi sp, sp, 16
	li t4, 0xFFFFFFFFFFFFFFFF
	sub t5, t4, t3
	bgt t3, t5, dplus_past_overflow
	addi t0, t0, 1
  dplus_past_overflow:
	add t4, t0, t2
	add t5, t1, t3
	sd t4, 8(sp)
	sd t5, 0(sp)
	TAILMOD t1

	CODEHEADERZ DTOS, D>S, DPLUS, 0x01
	#(d -- n)
	ld t1, 8(sp)		#higher range
	ld t0, 0(sp)
	addi sp, sp, 8
	li t2, 0x8000000000000000
	and t3, t2, t1
	beqz t3, dtos_positive
	#have negative number
	li t4, 0xFFFFFFFFFFFFFFFF
	bne t4, t1, dtos_negative_underflow
	and t5, t0, t2
	beqz t5, dtos_negative_underflow
	add t6, t4, t0
	addi t6, t6, 1
	sd t6, 0(sp)		#simple negative
	TAILMOD t1		#use macro to replicate dabs_done above
  dtos_negative_underflow:
	sd t2, 0(sp)
	TAILMOD t1
  dtos_positive:
	bnez t1, dtos_positive_overflow
	and t4, t2, t0
	bnez t4, dtos_positive_overflow
	sd t0, 0(sp)		#simple positive - done
	TAILMOD t1
  dtos_positive_overflow:
	li t0, 0x7FFFFFFFFFFFFFFF
	sd t0, 0(sp)		#max positive
	TAILMOD t1


  starter:
	PUSH ra
	call getNextAddress	#get the address for tail return
	la t0, NEXTMOD
	sd a0, 0(t0)		#store the tail return address
	la a0, DABS
	addi a0, a0, -56
	PUSH a0
	li t3, 0xFFFFFFFFFFFFF000
	and a0, a0, t3
	li a1, 0x100
	li a2, 0x7	#rw permissions
	call mprotect
	POP a0
	addi a1, a0, 16
	PUSH a1
	call getDictionaryAddress
	POP a1
	sd a0, 0(a1)	#update lead word
	la a0, DTOS	#new end of dictionary
	addi a0, a0, -56
	call setDictionaryAddress	#return new tail of dictionary to caller
	POP ra
	fence.i
	ret



.section .init_array
.balign 8
.8byte starter

