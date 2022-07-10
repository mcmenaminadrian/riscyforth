.include "../../macros.S"
.section .bss
    .comm NEXTMOD, 8


.section .text
.balign 8

	CODEEND DFALIGN, 0x01
	#(--)
	call getDataspacePtr
	li t0, 0x07
	and t1, a0, t0
	beqz t1, dfalign_done
	li t2, 0x08
	sub t3, t2, t1
	add a0, a0, t3
	call setDataspacePtr
  dfalign_done:
	TAILMOD t1

	CODEHEADER DFLOATS, DFALIGN, 0x01
	#(n -- n)
	TAILMOD t1
	

	CODEHEADER DFALIGNED, DFLOATS, 0x01
	#(addr -- df-addr)
	ld t0, 0(sp)
	li t1, 0x07
	and t2, t1, t0
	beqz t2, dfaligned_done
	li t3, 0x08
	sub t4, t3, t2
	add t5, t4, t0
	sd t5, 0(sp)
  dfaligned_done:
	TAILMOD t1


 starter_float:
	PUSH ra
	call getNextAddress	#get the address for tail return
	la t0, NEXTMOD
	sd a0, 0(t0)		#store the tail return address
	la a0, DFALIGN
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
	call getDictionary
	POP a1
	sd a0, 0(a1)	#update lead word
	la a0, DFALIGNED	#new end of dictionary
	addi a0, a0, -56
	call setDictionary	#return new tail of dictionary to caller
	#setup extension writing
#	la a0, WA_TWOLITERAL
#	la a1, extender_2literal
#	call  setExtenders
	call setFPAvailable
	POP ra
	fence.i
	ret

.section .init_array
.balign 8
.8byte starter_float
