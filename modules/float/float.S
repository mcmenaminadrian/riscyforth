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

	CODEHEADERZ FDIV, F/, DFLOATS, 0x01
	#(r r -- r)
	fld f0, 0(sp)
	fld f1, 8(sp)
	addi sp, sp, 8
	fdiv.d f2, f1, f0
	fsd f2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FMINUS, F-, FDIV, 0x01
	#(r r -- r)
	fld f0, 0(sp)
	fld f1, 8(sp)
	addi sp, sp, 8
	fsub.d f2, f1, f0
	fsd f2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FTIMES, F*, FMINUS, 0x01
	#(r r -- r)
	fld f0, 0(sp)
	fld f1, 8(sp)
	addi sp, sp, 8
	fmul.d f2, f0, f1
	fsd f2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FPLUS, F+, FTIMES, 0x01
	#(r r -- r)
	fld f0, 0(sp)
	fld f1, 8(sp)
	addi sp, sp, 8
	fadd.d f2, f0, f1
	fsd f2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FD, F., FTIMES, 0x01
	#(r --)
	ld t0, 0(sp)			#load from stack
	addi sp, sp, 8			#adjust stack
	beqz t0, fd_output_zero		#degenerate case of 0
	li t1, -1			#test for all bits on
	beq t0, t1, fd_output_neg_inf	#negative infinity
	srli t1, 1			#turn off first bit
	beq t0, t1, fd_output_inf	#positive infinity
	li t1, 0			#use t1 to hold sign, default is positive
	bgez t0, fd_get_exponent	#negative number?
	li t1, 1			#set for negative number
  fd_get_exponent:
	li t2, 0x7FF0000000000000	#mask for exponent
	and t3, t0, t2			#extract exponent
	srli t3, t3, 52			#power down to 0
	addi t3, t3, -1023		#normalise
	li t2, 0xFFFFFFFFFFFFF		#bit mask for mantissa
	and t4, t0, t2			#mantissa only
	#now covert base 2 exponent to base 10


	TAILMOD t1
	

	CODEHEADER ROOT2, FPLUS, 0x01
	#(--r)
	#Square root of two approximated to 1.4142135623730951
	li t0, 0x3FF6A09E667F3BCD
	addi sp, sp, -8
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER GOLDENRATIO, ROOT2, 0x01
	#(-- r)
	#Golden ratio approximated to 1.618033988749895
	li t0, 0x3FF9E3779B97F4A8
	addi sp, sp, -8
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER E, GOLDENRATIO, 0x01
	#(-- r)
	#e approximated to 2.718281828459045
	li t0, 0x4005BF0A8B145769
	addi sp, sp, -8
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER PI, E, 0x01
	#(-- r)
	#PI approximated to 3.141592653589793
	li t0, 0x400921FB54442D18
	addi sp, sp, -8
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER DFALIGNED, PI, 0x01
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
