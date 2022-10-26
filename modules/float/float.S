.include "../../macros.S"
.section .bss
    .comm NEXTMOD, 8

.section .data
	stdoutopener:	.asciz "w"

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

	CODEHEADER FSIN, DFALIGN, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call sin
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FCOS, FSIN, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call cos
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FTAN, FCOS, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call tan
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADERZ FFETCH, F@, FTAN, 0x01
	#(addr -- n)
	ld a0, 0(sp)
	fld fa0, 0(a0)
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FLITERAL, FFETCH, 0x01
	#do nothing in interpretation
	#extender code is what works here
	#(--)
	TAILMOD t1 

  extender_fliteral:
	#(n --)
	call getCreateWritePoint
	la t2, WA__FLITERAL
	sd t2, 0(a0)
	fld fa0, 0(sp)
	fsd fa0, 8(a0)
	addi sp, sp, 8
	addi a0, a0, 16
	call setCreateWritePoint
	call getOuterLoopTokenize
	mv s7, a0
	fence.i
	TAILMOD t1

	CODEHEADER _FLITERAL, FLITERAL, 0x0
	#(-- n)
	fld fa0, 0(s7)
	addi sp, sp, -8
	fsd fa0, 0(sp)
	addi s7, s7, 8
	TAILMOD t1

	CODEHEADER FALOG, _FLITERAL, 0x01
	#(n -- n)
	li a0, 10
	fcvt.d.l fa0, a0
	fld fa1, 0(sp)
	call pow
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FLOG, FALOG, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call log10
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FLN, FLOG, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call log
	fsd fa0, 0(sp)
	TAILMOD t1
	
	CODEHEADER FLOG2, FLN, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call log2
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FLNP1, FLOG2, 0x01
	#(n -- n) ln(1 + x)
	fld fa0, 0(sp)
	call log1p
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FABS, FLNP1, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	fabs.d fa1, fa0
	fsd fa1, 0(sp)
	TAILMOD t1

	CODEHEADER FACOS, FABS, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call acos
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FACOSH, FACOS, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call acosh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FASIN, FACOSH, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call asin
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FASINH, FASIN, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call asinh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FATAN, FASINH, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call atan
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FATAN2, FATAN, 0x01
	#(y x -- n)
	fld fa0, 8(sp)
	fld fa1, 0(sp)
	addi sp, sp, 8
	call atan2
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FATANH, FATAN2, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call atanh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FCBRT, FATANH, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call cbrt
	fsd fa0, 0(sp)
	TAILMOD t1
	
	CODEHEADER FEXP, FCBRT, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call exp
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FEXPM1, FEXP, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call expm1
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FSQRT, FEXPM1, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	fsqrt.d fa1, fa0
	fsd fa1, 0(sp)
	TAILMOD t1

	CODEHEADER FMAX, FSQRT, 0x01
	#(y x -- n)
	fld fa0, 8(sp)
	fld fa1, 0(sp)
	addi sp, sp, 8
	fmax.d fa2, fa0, fa1
	fsd fa2, 0(sp)
	TAILMOD t1

	CODEHEADER FMIN, FMAX, 0x01
	#(y x -- n)
	fld fa0, 8(sp)
	fld fa1, 0(sp)
	addi sp, sp, 8
	fmin.d fa2, fa0, fa1
	fsd fa2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FTOD, F>D, FMIN, 0x01
	#(f -- n n)
	fld fa0, 0(sp)
	call convertDoubleToLongLong
	beqz a0, ftod_done
	addi sp, sp, -8
	ld a1, 0(a0)
	ld a2, 8(a0)
	sd a1, 8(sp)
	sd a2, 0(sp)
	call free
  ftod_done:
	TAILMOD t1
	
	CODEHEADERZ DTOF, D>F, FTOD, 0x01
	ld a0, 0(sp)
	ld a1, 8(sp)
	call convert128BitsToDouble
	addi sp, sp, 8
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADERZ FTOS, F>S, DTOF, 0x01
	#(f -- n)
	fld fa0, 0(sp)
	fcvt.l.d a0, fa0
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER DFLOATS, FTOS, 0x01
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

	CODEHEADERZ FDOT, F., FPLUS, 0x01
	#(r --)
	ld a0, 0(sp)					#load number to process
	addi sp, sp, 8					#adjust stack
	li a1, 10					#set radix to 10
	call getFloatingPointStringDouble		#call C code
  float_output:
	PUSH a0
	li a0, 1
	la a1, stdoutopener
	call fdopen
	mv a1, a0
	ld a0, 0(sp)
	PUSH a1
	call fputs
	POP a0
	call fflush
	POP a0
	call free					#free malloc'ed memory
	TAILMOD t1

	CODEHEADERZ FEDOT, FE., FDOT, 0x01
	fld f0, 0(sp)
	addi sp, sp, 8
	call getFloatingPointEngineeringString
	j float_output

	CODEHEADER FDUP, FEDOT, 0x01
	#(n -- n n)
	fld f0, 0(sp)
	addi sp, sp, -8
	fsd f0, 0(sp)
	TAILMOD t1

	CODEHEADER FDROP, FDUP, 0x01
	#(n --)
	addi sp, sp, 8
	TAILMOD t1

	CODEHEADER ROOT2, FDROP, 0x01
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
	la a0, WA_FLITERAL
	la a1, extender_fliteral
	call  setExtenders
	call setFPAvailable
	POP ra
	fence.i
	ret

.section .init_array
.balign 8
.8byte starter_float
