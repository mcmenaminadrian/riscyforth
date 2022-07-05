.include "../../macros.S"
.section .bss
    .comm NEXTMOD, 8


.section .text
.balign 8

	CODEEND DFALIGN, 0x01
	#(--)
	TAILMOD t1

	CODEHEADER DFALIGNED, DFALIGN, 0x01
	#(addr -- df-addr)
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
	POP ra
	fence.i
	ret

.section .init_array
.balign 8
.8byte starter_float
