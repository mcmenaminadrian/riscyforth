# experimental double module
.include "../macros.S"
.section .bss
    .comm NEXTMOD, 8

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
	xor t0, t0, t3
  dabs_done:
	la t1, NEXTMOD
	ld t1, 0(t1)
	jr t1

	CODEHEADERZ DTOS, D>S, DABS, 0x01
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
	la t1, NEXTMOD		
	ld t1, 0(t1)
	jr t1
  dtos_negative_underflow:
	sd t2, 0(sp)
	la t1, NEXTMOD		
	ld t1, 0(t1)
	jr t1
  dtos_positive:
	bnez t1, dtos_positive_overflow
	and t4, t2, t0
	bnez t4, dtos_positive_overflow
	sd t0, 0(sp)		#simple positive - done
	la t1, NEXTMOD		
	ld t1, 0(t1)
	jr t1
  dtos_positive_overflow:
	li t0, 0x7FFFFFFFFFFFFFFF
	sd t0, 0(sp)		#max positive
	la t1, NEXTMOD		
	ld t1, 0(t1)
	jr t1

 
	

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

