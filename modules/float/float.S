.include "../../macros.S"
.section .bss
    .comm NEXTMOD, 8
    .comm FLPRECISION, 8

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

	CODEHEADER FALIGN, DFALIGN, 0x01
	tail DFALIGN

	CODEHEADER FALIGNED, FALIGN, 0x01
	tail DFALIGNED

	CODEHEADER SFALIGN, FALIGNED, 0x0
	tail DFALIGN

	CODEHEADER SFALIGNED, SFALIGN, 0x0
	tail DFALIGNED

	CODEHEADERZ DFFIELDCOLON, DFFIELD:, SFALIGNED, 0x01
	#(n "<spaces>name" -- n)
	#create new word with name that returns data address
	li a5, 0x401			#badge for this type of function
	PUSH a5
	call getInputStart		#start of input
	PUSH a0
	call getInputEnd		#a0 has end
	li t0, 0x61			#a
	li t1, 0x7B			#z + 1
	li t2, 0x20			#space or XOR to UC
	POP a1				#restore start
  dffield_look_for_start:
	bgt a1, a0, dffield_done
	lb t3, 0(a1)			#read in char
	bne t3, t2, dffield_sanitize	#past the spaces
	addi a1, a1, 1
	j dffield_look_for_start	#or loop back
  dffield_sanitize:
	mv a2, a1			#store start
  dffield_sanitize_test:
	blt t3, t0, dffield_sanitize_next
	blt t3, t1, dffield_sanitize_this
  dffield_sanitize_next:
	addi a1, a1, 1
	bgt a1, a0, dffield_sanitize_done
	lb t3, 0(a1)
	ble t3, t2, dffield_sanitize_done
	j dffield_sanitize_test
  dffield_sanitize_this:
	xor t4, t3, t2			#convert to UC
	sb t4, 0(a1)
	j dffield_sanitize_next 
  dffield_sanitize_done:
	#now update the input
	addi sp, sp, -24
	sd a2, 0(sp)			#start
	sd a1, 8(sp)			#end (+1)
	sub a3, a1, a2
	sd a3, 16(sp)			#length
	mv a0, a1
	call setInputStartIncrement
	ld a0, 0(sp)
	ld a1, 16(sp)
	ld a5, 24(sp)
	call lib_write_function_header 	#sets a0
	la a1, NEXTMOD
	ld a1, 0(a1)
	addi sp, sp, 32			#reset stack
	ld a2, 0(sp)			#jump we want
	call set_up_field_jump
  float_write_alignment:
	#check we are aligned
	li t0, 0x07
	li t2, 0x08
	and t1, a0, t0
	beqz t1, dffield_finish
	sub t3, t2, t1
	add a0, a0, t3
  dffield_finish:
	PUSH a0
	call setCreateWritePoint
	call getNewDictionary
	call setDictionary
	POP a0
	call setNewDictionary
	ld a0, 0(sp)
	addi a0, a0, 8
	sd a0, 0(sp)
  dffield_done:
	TAILMOD t1

	CODEHEADERZ SFFIELDCOLON, SFIELD:, DFFIELDCOLON, 0
	tail DFFIELDCOLON

	CODEHEADERZ DFLOATPLUS, DFLOAT+, SFFIELDCOLON, 0x01
	#(addr --- addr)
	ld t0, 0(sp)
	li t1, 8
	add t2, t0, t1
	sd t2, 0(sp)
	TAILMOD t1

	CODEHEADERZ FLOATPLUS, FLOAT+, DFLOATPLUS, 0x01
	tail DFLOATPLUS

	CODEHEADERZ SFLOATPLUS, SFLOAT+, FLOATPLUS, 0
	tail DFLOATPLUS

	CODEHEADERZ DFSTORE, DF!, SFLOATPLUS, 0x01
	#(n addr --)
	ld t0, 0(sp)
	fld ft0, 8(sp)
	addi sp, sp, 16
	fsd ft0, 0(t0)
	TAILMOD t1

	CODEHEADERZ FSTORE, F!, DFSTORE, 0x01
	tail DFSTORE

	CODEHEADERZ SFSTORE, SF!, FSTORE, 0x0
	tail DFSTORE

	CODEHEADER FCONSTANT, SFSTORE, 0x01
	#(n "<spaces>name" -->
	li a5, 0x202			#0x202 for a float constant
	PUSH a5
  fconstant_common_code:
	call getInputStart		#a0 has start on return
	PUSH a0
	call getInputEnd		#a0 has end
	li t0, 0x61			#a
	li t1, 0x7B			#z + 1
	li t2, 0x20			#space or XOR to UC
	POP a1				#restore start
  fconstant_look_for_start:
	bgt a1, a0, dffield_done	#bail out
	lb t3, 0(a1)			#read in char
	bne t3, t2, fconstant_sanitize	#past the spaces
	addi a1, a1, 1
	j fconstant_look_for_start	#or loop back
  fconstant_sanitize:
	mv a2, a1			#store start
  fconstant_sanitize_test:
	blt t3, t0, fconstant_sanitize_next
	blt t3, t1, fconstant_sanitize_this
  fconstant_sanitize_next:
	addi a1, a1, 1
	bgt a1, a0, fconstant_sanitize_done
	lb t3, 0(a1)
	ble t3, t2, fconstant_sanitize_done
	j fconstant_sanitize_test
  fconstant_sanitize_this:
	xor t4, t3, t2			#convert to UC
	sb t4, 0(a1)
	j fconstant_sanitize_next 
  fconstant_sanitize_done:
	#now update the input
	addi sp, sp, -24
	sd a2, 0(sp)			#start
	sd a1, 8(sp)			#end (+1)
	sub a3, a1, a2
	sd a3, 16(sp)			#length
	mv a0, a1
	call setInputStartIncrement
	ld a0, 0(sp)
	ld a1, 16(sp)
	ld a5, 24(sp)
	call lib_write_function_header 	#sets a0
	la a1, NEXTMOD
	ld a1, 0(a1)
	fld fa0, 32(sp) 
	addi sp, sp, 40			#reset stack
	call float_constant_code
	j float_write_alignment		#reuse dffield code

	CODEHEADER FDEPTH, FCONSTANT, 0x01
	#(-- n)
	#no float stack (for now?) so just the same as DEPTH (for now?)
	la t0, STACKTOP
	ld t1, 0(t0)
	sub t2, t1, sp
	srai t3, t2, 3
	PUSH t3
	TAILMOD t1

	CODEHEADER FVARIABLE, FDEPTH, 0x01
	#("<spaces>name" --)
	#create new word with name that returns data address
	li a5, 0x408			#badge for this type of function
	PUSH a5
	call getInputStart		#start of input
	PUSH a0
	call getInputEnd		#a0 has end
	li t0, 0x61			#a
	li t1, 0x7B			#z + 1
	li t2, 0x20			#space or XOR to UC
	POP a1				#restore start
  fvariable_look_for_start:
	bgt a1, a0, fvariable_done
	lb t3, 0(a1)			#read in char
	bne t3, t2, fvariable_sanitize	#past the spaces
	addi a1, a1, 1
	j fvariable_look_for_start	#or loop back
  fvariable_sanitize:
	mv a2, a1			#store start
  fvariable_sanitize_test:
	blt t3, t0, fvariable_sanitize_next
	blt t3, t1, fvariable_sanitize_this
  fvariable_sanitize_next:
	addi a1, a1, 1
	bgt a1, a0, fvariable_sanitize_done
	lb t3, 0(a1)
	ble t3, t2, fvariable_sanitize_done
	j fvariable_sanitize_test
  fvariable_sanitize_this:
	xor t4, t3, t2			#convert to UC
	sb t4, 0(a1)
	j fvariable_sanitize_next
  fvariable_sanitize_done:
	addi sp, sp, -24
	sd a2, 0(sp)			#start
	sd a1, 8(sp)			#end + 1
	sub a3, a1, a2
	sd a3, 16(sp)			#length
	mv a0, a1
	call setInputStartIncrement	#update input point
	ld a0, 0(sp)
	ld a1, 16(sp)
	ld a5, 24(sp)
	call lib_write_function_header 	#sets a0
	call float_data_address_code
	li t0, 0x07			#check write alignment
	li t2, 0x08
	and t1, a1, t0
	and t1, a0, t0
	beqz t1, fvariable_out
	sub t3, t2, t1
	add a0, a0, t3
  fvariable_out:
	sd a0, 0(sp)			#just write over stack as we don't need old values
	call setCreateWritePoint
	call getNewDictionary
	call setDictionary
	ld a0, 0(sp)
	call setNewDictionary
	addi sp, sp, 32
	TAILMOD t1
  fvariable_done:
	addi sp, sp, 8
	TAILMOD t1			#failure

	CODEHEADER FVALUE, FVARIABLE, 0x01
	#(n "<spaces>name" --)
	li a5, 0x04				#same as integer VALUE
	PUSH a5
	j fconstant_common_code

	CODEHEADERZ STOF, S>F, FVALUE, 0x01
	#(n -- r)
	ld t0, 0(sp)
	fcvt.d.l ft0, t0
	fsd ft0, 0(sp)
	TAILMOD t1

	CODEHEADERZ TOFLOAT, >FLOAT, STOF, 0x01
	#(addr u -- r true  | false)
	li a0, 48
	call malloc
	beqz a0, tofloat_failed
	#process string
	li t0, -1				#string of blanks (TRUE)
	li t1, 0x20				#space
	li t2, 0x2C				#comma
	li t3, 0x65				#e (lc)
	mv a1, a0
	ld a2, 0(sp)				#count
	ld a3, 8(sp)				#address
  tofloat_gatherinput:
	beqz a2, tofloat_testoutput
	lb a4, 0(a3)				#read byte
	beq a4, t1, tofloat_nextread
	li t0, 0
	beq a4, t2, tofloat_nextread
	bne a4, t3, tofloat_continue
	xor a4, a4, t1				#convert e to E
  tofloat_continue:
	sb a4, 0(a1)
	sb t1, 1(a1)				#always lead with a space
  	addi a1, a1, 1
  tofloat_nextread:
	addi a2, a2, -1
	addi a3, a3, 1
	j tofloat_gatherinput
  tofloat_testoutput:
	beqz t0, tofloat_realinput
	li t4, 0x30
	sb t4, 0(a0)
	li t3, 0x2E
	sb t3, 1(a0)
	sb t4, 2(a0)				#write out 0.0
	sb t1, 3(a0)
  tofloat_realinput:
	sd a0, 0(sp)				#write a0 over stack stuff
	call scan_floats
	bnez a1, tofloat_noparse
	ld t0, 0(sp)				#for freeing
	sd a0, 8(sp)
	li t1, -1				#store TRUE
	sd t1, 0(sp)				#store result
	mv a0, t0
	call free
	TAILMOD t1
  tofloat_noparse:
	ld a0, 0(sp)				#for freeing
	call free
  tofloat_failed:
	addi sp, sp, 8
	sd zero, 0(sp)				#FALSE 
	TAILMOD t1

	CODEHEADERZ FSDOT, FS., TOFLOAT, 0x01
	#(n -- )
	fld fa0, 0(sp)
	addi sp, sp, 8
	la t0, FLPRECISION
	ld a0, 0(t0)
	call getFloatingPointScientificString
	j float_output

	CODEHEADERZ FFIELDCOLON, FFIELD:, FSDOT, 0x01
	#just call code for double
	tail DFFIELDCOLON

	CODEHEADER FSIN, FFIELDCOLON, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call sin
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADERZ DFFETCH, DF@, FSIN, 0x01
	#(addr -- n)
	ld t0, 0(sp)
	fld ft0, 0(t0)
	fsd ft0, 0(sp)
	TAILMOD t1

	CODEHEADERZ SFFETCH, SF@, DFFETCH, 0
	tail DFFETCH

	CODEHEADER FCOS, SFFETCH, 0x01
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

	CODEHEADERZ FPROXIMATE, F~, FFETCH, 0x01
	#(r r r -- flag)
	fld fa3, 0(sp)			#value determines type of test
	fld fa2, 8(sp)
	fld fa1, 16(sp)
	addi sp, sp, 16
	fmv.x.d t0, fa3
	beqz t0, fproximate_strict_equality	#check for 0
	li t1, 0x8000000000000000
	fsub.d ft0, fa1, fa2
	fabs.d ft1, ft0				#get absolute difference for later use
	xor t2, t0, t1
	beqz t2, fproxumate_strict_equality	#check for -0
	or t2, t0, t1				#checking if negative
	beq t2, t0, fproximate_close
	#now checking 'relatively close'
	fabs.d ft3, fa3
	fabs.d ft4, fa1
	fabs.d ft5, fa2
	fadd.d ft6, ft4, ft5			#sum of absolutes
	fmul.d ft7, ft6, ft3			#producr of absolutes
	flt.d a0, ft1, ft7
	bnez a0, fproximate_true
	j fproximate_false
  fproximate_close:
	flt.d a0, ft1, fa3
	bnez a0, fproximate_true
	j fproximate_false
  fproximate_strict_equality:
	feq.d a0, fa2, fa1
	bnez a0, fproximate_true
  fproximate_false:
	sd zero, 0(sp)
	j fproximate_done
  fproximate_true:
	li t0, -1
	sd t0, 0(sp)
  fproximate_done:
	TAILMOD t1

	CODEHEADER REPRESENT, FPROXIMATE, 0x01
	#(r addr u -- n flag flag)
	fld fa0, 16(sp)
	ld a0, 8(sp)
	ld a1, 0(sp)
	call getFloatingPointRepresent
	beqz a0, represent_fail
	ld t0, 0(a0)
	beqz t0, represent_continue
	li t0, -1		#TRUTH = -1
  represent_continue:
	ld t1, 8(a0)
	sd t1, 16(sp)
	sd t0, 8(sp)
	li t0, -1
	sd t0, 0(sp)
	call free		#free returned structure
	TAILMOD t1
  represent_fail:
	sd zero, 0(sp)		#failure
	sd zero, 8(sp)
	sd zero, 16(sp)
	TAILMOD t1

	CODEHEADERZ FZERO, 0.0, REPRESENT, 0x0
	#("0.0" -- n)
	#helper to ensure we get correct IEEE754 0
	addi sp, sp, -8
	sd zero, 0(sp)
	TAILMOD t1

	CODEHEADER FLITERAL, FZERO, 0x01
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

	CODEHEADER FCOSH, FABS, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call cosh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FSINH, FCOSH, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call sinh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FTANH, FSINH, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call tanh
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FNEGATE, FTANH, 0x01
	#(n -- n)
	fld ft0, 0(sp)
	fneg.d ft1, ft0
	fsd ft1, 0(sp)
	TAILMOD t1

	CODEHEADER FSWAP, FNEGATE, 0x01
	#(r1 r2 -- r2 r1)
	fld ft0, 0(sp)
	fld ft1, 8(sp)
	fsd ft0, 8(sp)
	fsd ft1, 0(sp)
	TAILMOD t1

	CODEHEADER FACOS, FSWAP, 0x01
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

	CODEHEADER FLOATS, DFLOATS, 0x01
	tail DFLOATS

	CODEHEADER SFLOATS, FLOATS, 0x0
	tail DFLOATS

	CODEHEADERZ FSTARSTAR, F**, SFLOATS, 0x01
	#(n n -- n)
	fld fa0, 8(sp)
	fld fa1, 0(sp)
	call pow
	addi sp, sp, 8
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADERZ FDIV, F/, FSTARSTAR, 0x01
	#(r r -- r)
	fld f0, 0(sp)
	fld f1, 8(sp)
	addi sp, sp, 8
	fdiv.d f2, f1, f0
	fsd f2, 0(sp)
	TAILMOD t1

	CODEHEADER FROT, FDIV, 0x1
	#(r1 r2 r3 -- r2 r3 r1)
	fld ft0, 16(sp)
	fld ft1, 8(sp)
	fld ft2, 0(sp)
	fsd ft0, 0(sp)
	fsd ft2, 8(sp)
	fsd ft1, 16(sp)
	TAILMOD t1

	CODEHEADER FOVER, FROT, 0x01
	#(r1 r2 -- r1 r2 r1)
	fld ft0, 8(sp)
	addi sp, sp, -8
	fsd ft0, 0(sp)
	TAILMOD t1

	CODEHEADERZ FMINUS, F-, FOVER, 0x01
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
	la t0, FLPRECISION
	ld a2, 0(t0)
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
	fld fa0, 0(sp)
	addi sp, sp, 8
	la t0, FLPRECISION
	ld a0, 0(t0)
	call getFloatingPointEngineeringString
	j float_output

	CODEHEADER FLOOR, FEDOT, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call floor
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FTRUNC, FLOOR, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call trunc
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FROUND, FTRUNC, 0x01
	#(n -- n)
	fld fa0, 0(sp)
	call round
	fsd fa0, 0(sp)
	TAILMOD t1

	CODEHEADER FDUP, FROUND, 0x01
	#(n -- n n)
	fld f0, 0(sp)
	addi sp, sp, -8
	fsd f0, 0(sp)
	TAILMOD t1

	CODEHEADER FSINCOS, FDUP, 0x01
	#(n -- n n)
	fld fa0, 0(sp)
	call sin
	fld ft0, 0(sp)
	fsd fa0, 0(sp)
	fmv.d fa0, ft0
	call cos
	addi sp, sp, -8
	fsd fa0, 0(sp)
	TAILMOD t1
	
	CODEHEADER FDROP, FSINCOS, 0x01
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

	CODEHEADER PRECISION, PI, 0x01
	la a0, FLPRECISION
	ld a1, 0(a0)
	addi sp, sp, -8
	sd a1, 0(sp)
	TAILMOD t1

	CODEHEADERZ SETFLPRECISION, SET-PRECISION, PRECISION, 0x01
	la a0, FLPRECISION
	ld a1, 0(sp)
	sd a1, 0(a0)
	addi sp, sp, 8
	TAILMOD t1

	CODEHEADER DFALIGNED, SETFLPRECISION, 0x01
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

  set_up_field_jump:
	#get here with a2 holding jump
	#a0 holding write address
	#a1 holding return address
	li t0, 0x297
	sw t0, 0(a0)			#auipc t0, 0 (mv t0, pc)
	li t0, 0x382b303			
	sw t0, 4(a0)			#ld t1, 56(t0) 
	li t0, 0x13383
	sw t0, 8(a0)			#ld t2, 0(sp)
	li t0, 0x730e33
	sw t0, 12(a0)			#add t3, t1, t2
	li t0, 0x700e93
	sw t0, 16(a0)			#li t4, 0x7
	li t0, 0x800f13
	sw t0, 20(a0)			#li t5, 0x8
	li t0, 0x1DE7fB3
	sw t0, 24(a0)			#and t6, t3, t4
	li t0, 0xF8663
	sw t0, 28(a0)			#beqz t6, +12
	li t0, 0x41FF0533
	sw t0, 32(a0)			#sub a0, t5, t6
	li t0, 0xAE0E33
	sw t0, 36(a0)			#add t3, t3, a0
	li t0, 0x1C13023
	sw t0, 40(a0)			#sd t3, 0(sp)
	li t0, 0x402B303
	sw t0, 44(a0)			#ld t1, (offset == 64)
	li t0, 0x30067
	sw t0, 48(a0)			#jr t1
	sw a2, 56(a0)			#store offset
	sw a1, 64(a0)			#store return
	addi a0, a0, 72
	fence.i 
	ret

  float_constant_code:
	#get here with fa0 holding float
	#a0 holding write address
	#a1 holding return address
	li t0, 0x297
	sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
	li t0, 0x182B303
	sw t0, 4(a0)						#ld t1, 24(t0)
	li t0, 0xFF810113
	sw t0, 8(a0)						#addi sp, sp, -8
	li t0, 0x613023
	sw t0, 12(a0)						#sd t1, 0(sp)
	#now jump to next
	li t0, 0x202B303
	sw t0, 16(a0)						#ld t1, 32(t0)
	li t0, 0x30067
	sw t0, 20(a0)						#jr t1
	fsd fa0, 24(a0)
	sd a1, 32(a0)
	addi a0, a0, 40
	fence.i
	ret

  float_data_address_code:
	addi sp, sp, -16
	sd a0, 0(sp)
	sd ra, 8(sp)
	call getDataspacePtr
	li t0, 0x07						#checking we are aligned
	and t2, a0, t0
	beqz t2, float_data_address_code_allocate
	li t1, 0x08
	sub t4, t1, t2
	add a0, a0, t4
  float_data_address_code_allocate:
	addi a0, a0, 8
	call setDataspacePtr
	addi a2, a0, -8
	POP a0
	la a1, NEXTMOD
	ld a1, 0(a1)
	li t0, 0x297
	sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
	li t0, 0x182B303
	sw t0, 4(a0)						#ld t1, 24(t0)
	li t0, 0xFF810113
	sw t0, 8(a0)						#addi sp, sp, -8
	li t0, 0x613023
	sw t0, 12(a0)						#sd t1, 0(sp)
	#now jump to next
	li t0, 0x202B303
	sw t0, 16(a0)						#ld t1, 32(t0)
	li t0, 0x30067
	sw t0, 20(a0)						#jr t1
	sd a2, 24(a0)
	sd a1, 32(a0)
	addi a0, a0, 40
	fence.i
	POP ra
	ret
	
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
	#set default precision to 5
	la a0, FLPRECISION
	li a1, 5
	sd a1, 0(a0) 
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
