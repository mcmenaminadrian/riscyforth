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
	ld t1, 8(sp)
	ld t0, 0(sp)
	addi sp, sp, 8
	li t5, 0x7FFFFFFFFFFFFFFF
	and t4, t1, t5
	li t3, 0x8000000000000000
	beqz t4, dtos_in_range
	and t4, t1, t3
	beqz t4, dtos_outofrange_positive
  dtos_outofrange_negative:
	sd t3, 0(sp)
	j dtos_done
  dtos_outofrange_positive:
	sd t5, 0(sp)
	j dtos_done
  dtos_in_range:
	and t2, t3, t0
	beqz t2, dtos_really_in_range
	and t1, t1, t3
	beqz t1, dtos_outofrange_positive
	j dtos_outofrange_negative
  dtos_really_in_range:
	and t1, t1, t3
	beqz t1, dtos_done
	or t0, t0, t3
  dtos_done:
	j dabs_done
 
	

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
	ret



.section .init_array
.balign 8
.8byte starter

