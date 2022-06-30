# experimental double module
.include "../macros.S"
#.include "../riscylib/riscyvar.S"
.section .bss
    .comm NEXTMOD, 8
    .comm LOCAL_INPUT_START, 8
    .comm LOCAL_INPUT_END, 8


#.extern INPUT_START
.section .text
.balign 8
	CODEEND DABS, 0x01
	#(d -- d)
	ld t0, 8(sp)	#low
	ld t1, 0(sp)	#hi
	li t2, 0x8000000000000000
	and t3, t2, t1
	beqz t3, dabs_done	#not a negative number
	li t3, -1
	xor t4, t0, t3	#low
	xor t5, t1, t3	#hi
	addi t6, t4, 1	#low
	bgt t6, t4, dabs_store	#no overflow
	addi t5, t5, 1
  dabs_store:
	sd t6, 8(sp)
	sd t5, 0(sp)
  dabs_done:
	la t1, NEXTMOD
	ld t1, 0(t1)
	jr t1

	CODEHEADERZ TWOLITERAL, 2LITERAL, DABS, 0x01
	#Compile time: (x1 x2 --)
	#Run time: (-- x1 x2)
	#but actually this does nothing!
	TAILMOD t1

  extender_2literal:
	#this is compile time code
	call getCreateWritePoint
	la t2, WA__TWOLITERAL
	sd t2, 0(a0)
	ld t1, 8(sp)
	sd t1, 8(a0)
	ld t0, 0(sp)
	sd t0, 16(a0)
	addi sp, sp, 16
	addi a0, a0, 24
	call setCreateWritePoint
	call getOuterLoopTokenize
	mv s7, a0
	fence.i
	TAILMOD t1
	
 	CODEHEADERZ _TWOLITERAL _2LITERAL, TWOLITERAL, 0x0
	#this is runtime code
	ld t0, 0(s7)
	ld t1, 8(s7)
	addi sp, sp, -16
	sd t0, 8(sp)
	sd t1, 0(sp)
	addi s7, s7, 16
	TAILMOD t1

	CODEHEADER TO, _TWOLITERAL, 0x01
	#surplants standard TO
	#(x1 x2 "spaces<name>--) or (x1 "spaces<name>"--)
	call getInputStart
	PUSH a0
	call getInputEnd
	mv a1, a0
	POP a0
	addi t0, a0, 1
	bltu t0, a1, to2_have_data
  to2_bail:
	TAILMOD t1		#nothing, so bail
  to2_have_data:
	#sanitize
	call lib_sanitize_string
	#now check for string
	li t0, 0x20	#space
	li t1, 0x0A	#CR
	lb t2, 0(a0)
  to2_check_start:
	beq t2, t0, to2_advance
	beq t2, t1, to2_gone
	j to2_check_end
  to2_advance:
	addi a0, a0, 1
	bgt a0, a1, to2_gone
	j to2_check_start
  to2_check_end:
	mv a1, a0
  to2_move_on:
	addi a1, a1, 1
	lb t2, 0(a1)
	beq t2, t0, to2_found_end
	beq t2, t1, to2_found_end
	j to2_move_on
  to2_found_end:
	sub a2, a1, a0
	addi a1, a1, -1
	call lib_check_dictionary
	beqz a0, to2_bail
	li t0, 0x04
	beq a1, t0, to2_old_to
	li t0, 0x204
	beq a1, to, to2_new_to
	#not a match, so bail
	j to2_bail
  to2_old_to:
	ld t0, 0(sp)
	addi sp, sp, 8
	sd t0, 24(a2)
	j to2_bail
	

	CODEHEADERZ TWOVALUE, 2VALUE, _TWOLITERAL, 0x01
	#(x1 x2 "<spaces>name" --)
	li a5, 0x204			#204 for double value
	PUSH a5
	j twoconstant_common_code

	CODEHEADERZ TWOCONSTANT, 2CONSTANT, TWOVALUE, 0x01
	#( x1 x2 "<spaces>name" --)
	li a5, 0x200	#0x200 for a 2CONSTANT
	PUSH a5
  twoconstant_common_code:
	call getInputStart		#a0 has INPUT_START
	la t0, LOCAL_INPUT_START
	sd a0, 0(t0)
	call getInputEnd
	la t0, LOCAL_INPUT_END
	sd a0, 0(t0)
	li a0, 0x61	#a
	li a1, 0x7B	#z + 1
	li a2, 0x20	#space/xor
	la t0, LOCAL_INPUT_START
	ld t1, 0(t0)
	la t2, LOCAL_INPUT_END
	ld t3, 0(t2)
  twoconstant_look_for_start:
	bgt t1, t3, twoconstant_out
	lb t4, 0(t1)
	bne t4, a2, twoconstant_ready_to_sanitize
	addi t1, t1, 1
	j twoconstant_look_for_start
  twoconstant_ready_to_sanitize:
	sd t1, 0(t0)
	j twoconstant_jump_start_sanitize
  twoconstant_sanitize_load:
	bgt t1, t3, twoconstant_sanitize_done
	lb t4, 0(t1)
	beq t4, a2, twoconstant_sanitize_done
  twoconstant_jump_start_sanitize:
	blt t4, a0, twoconstant_sanitize_advance
	blt t4, a1, twoconstant_sanitize_process
  twoconstant_sanitize_advance:
	addi t1, t1, 1
	j twoconstant_sanitize_load
  twoconstant_sanitize_process:
	xor t4, t4, a2
	sb t4, 0(t1)
	j twoconstant_sanitize_advance
  twoconstant_sanitize_check_started:
	beqz a3, twoconstant_sanitize_advance
  twoconstant_sanitize_done:
	#start in a0
	ld a0, 0(t0)
	#end in a1
	ld a1, 0(t2)
	addi sp, sp, -16
	addi a1, a1, -1
	sd a0, 8(sp)
	sd a1, 0(sp)
	mv a0, a1
	call setInputStart
	ld a1, 0(sp)
	ld a0, 8(sp)
	#length in a2
	sub a2, a1, a0
	PUSH a2
	mv a0, a2
	addi a0, a0, 1
	call incrementInputDisplace
	ld a2, 0(sp)		#length
	ld a1, 8(sp)		#end
	ld a0, 16(sp)		#start
	addi sp, sp, 24
	#now write out header for new function that will return value
	mv a1, a2
	POP a5
	call lib_write_function_header
	la a3, NEXTMOD		#set the call up
	ld a3, 0(a3)
	ld a2, 8(sp)
	ld a1, 0(sp)
	call double_two_constant_code
	#and get out
	#now check if we are 8 bit aligned on writing address
	li t0, 0x07
	li t2, 0x08
	and t1, a0, t0
	beqz t1, twoconstant_done
	sub t3, t2, t1
	add a0, a0, t3
  twoconstant_done:
	PUSH a0
	call setCreateWritePoint
	call getNewDictionary
	call setDictionary
	POP a0
	call setNewDictionary
  twoconstant_out:
	addi sp, sp, 16		#fix stack
	TAILMOD t1


	#have to write out D= by hand as cannot access expansions here
	#CODEHEADERZ DEQUAL, D=, TWOCONSTANT, 0x01
	#(xd1 xd2 -- flag)
  TIL_DEQUAL:
	.8byte 0x01	#flags
  WA_DEQUAL:
	.8byte DEQUAL
  ptr_TWOCONSTANT:
	.8byte TIL_TWOCONSTANT
  length_ASCII_DEQUAL:
	.8byte 0x02
  beg_DEQUAL:
	.ascii "D="
  end_DEQUAL:
	.fill 22, 1, 0xFF
  DEQUAL:
	ld t0, 24(sp)
	ld t1, 16(sp)
	ld t2, 8(sp)
	ld t3, 0(sp)
	addi sp, sp, 24
	li t4, 0
	bne t0, t2, dequal_done
	bne t1, t3, dequal_done
	li t4, -1
  dequal_done:
	sd t4, 0(sp)
	TAILMOD t1

	#another one with = sign
	#CODEHEADERZ DZEROEQUAL, D0=, DEQUAL, 0x01
	#(d -- flag)
  TIL_DZEROEQUAL:
	.8byte 0x01
  WA_DZEROEQUAL:
	.8byte DZEROEQUAL
  ptr_DEQUAL:
	.8byte TIL_DEQUAL
  length_ASCII_DZEROEQUAL:
	.8byte 0x03
  beg_DZEROEQUAL:
	.ascii "D0="
  end_DZEROEQUAL:
	.fill 21, 1, 0xFF
  DZEROEQUAL:
	ld t0, 0(sp)
	ld t1, 8(sp)
	li t2, 0
	addi sp, sp, 8
	bnez t0, dzeroequal_done
	bnez t1, dzeroequal_done
	li t2, -1
  dzeroequal_done:
	sd t2, 0(sp)
	TAILMOD t1

	CODEHEADER DMAX, DZEROEQUAL, 0x01
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	addi sp, sp, 16
	bgt t3, t1, dmax_second
	bgt t1, t3, dmax_first
	#hi parts equal
	bgtu t2, t0, dmax_second
  dmax_first:
	TAILMOD t1
  dmax_second:
	sd t2, 8(sp)
	sd t3, 0(sp)
	TAILMOD t1

	CODEHEADER DMIN, DMAX, 0x01
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	addi sp, sp, 16
	blt t3, t1, dmin_second
	blt t1, t3, dmin_first
	#hi parts equal
	bgtu t0, t2, dmin_second
  dmin_first:
	TAILMOD t1
  dmin_second:
	sd t2, 8(sp)
	sd t3, 0(sp)
	TAILMOD t1

	CODEHEADERZ DMINUS, D-, DMIN, 0x01
	#(d1 d2 -- d3)
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	addi sp, sp, 16
	sub t4, t0, t2
	bleu t4, t0, dminus_nooverflow
	addi t3, t3, 1
  dminus_nooverflow:
	sub t5, t1, t3
	sd t4, 8(sp)
	sd t5, 0(sp)
	TAILMOD t1

	CODEHEADERZ DDOTR, D.R, DMINUS, 0x01
	#(d n --)
	call getScratchPad
	PUSH a0
	call getCurrentBase
	mv t3, a0	#t3 - CURRENT_BASE
	ld t2, 0(sp)	#t2 - SCRATCH_PAD
	ld a6, 8(sp)	#a6 - field width
	ld t0, 24(sp)	#t0 - lo
	ld t1, 16(sp)	#t1 - hi
	addi sp, sp, 32
	li t4, 0x8000000000000000
	and t5, t4, t1
	PUSH t2		#scratch_pad saved
	PUSH t5		#save for later use
	beqz t5, ddotr_positive
	#handling a negative number
	li t5, -1
	xor t4, t5, t0
	xor t6, t5, t1
	addi a0, t4, 1
	bgtu a0, t3, ddotr_negate_nooverflow
	addi a1, t6, 1
  ddotr_negate_nooverflow:
	mv t0, a0	#lo
	mv t1, a1	#hi
  ddotr_positive:
	li t5, 10	#for rebasing
	li a0, 0x30	#0
	li a1, 0x37	#0 rebased for bases > 10
	li t4, 0	#count
	bnez t1, ddotr_wide_setup
	#simplest case - lo cell only
	addi sp, sp, 8	#can't be negative
  ddotr_generate_characters_simple:
	remu a2, t0, t3
	divu t0, t0, t3
	bgeu a2, t5, ddotr_simple_remainder
	add t6, a2, a0
	call dd_paste_in
	beqz t0, ddotr_reverse	#0
	j ddotr_generate_characters_simple
  ddotr_simple_remainder:
	add t6, a2, a1
	call dd_paste_in
	j ddotr_generate_characters_simple
  ddotr_wide_setup:
	#preserve numbers for character mapping
	addi sp, sp, -16
	sd a0, 0(sp)
	sd a1, 8(sp)
  ddotr_wide:
	#general case both cells
	remu a0, t1, t3
	mv a2, t3
	mv a1, t0
	call dd_long_division_unsigned
	beqz a7, ddotr_reverse
	mv t0, a0
	mv t6, a1
	bgeu t6, t5, ddotr_wide_remainder
	ld a0, 0(sp)
	add t6, t6, a0
	call dd_paste_in
  ddotr_update_double:
	divu t1, t1, t3
	bnez t1, ddotr_wide
	beqz t0, ddotr_reverse_setup
	j ddotr_wide
  ddotr_wide_remainder:
	ld a1, 8(sp)
	add t6, t6, a1
	call dd_paste_in
  ddotr_reverse_setup:
	addi sp, sp, 16		#drop storage
 	#process sign
	POP t0
	beqz t0, ddotr_reverse
	call dd_paste_minus
  ddotr_reverse:
	POP t0		#SCRATCH_PAD
	mv t5, t0
	mv t6, t2
	sub a5, t2, t0	#length
	bgeu a5, a6, dd_ddotr_join
	#inject spaces
	sub a5, a6, a5
	li t6, 0x020
  ddotr_pad:
	call dd_paste_in
	addi a5, a5, -1
	bnez a5, ddotr_pad
	mv a5, a6
	j dd_ddotr_join

	CODEHEADERZ DD, D., DDOTR, 0x01
	#(d -- )
	call getScratchPad
	PUSH a0
	call getCurrentBase
	mv t3, a0	#t3 - CURRENT_BASE
	ld t2, 0(sp)	#t2 - SCRATCH_PAD
	ld t0, 16(sp)	#t0 - lo
	ld t1, 8(sp)	#t1 - hi
	addi sp, sp, 24
	li t4, 0x8000000000000000
	and t5, t4, t1
	PUSH t2		#scratch_pad saved
	PUSH t5		#save for later use
	beqz t5, dd_positive
	#handling a negative number
	li t5, -1
	xor t4, t5, t0
	xor t6, t5, t1
	addi a0, t4, 1
	bgt a0, t4, dd_negate_nooverflow
	addi t6, t6, 1
  dd_negate_nooverflow:
	mv t0, a0	#lo
	mv t1, t6	#hi
  dd_positive:
	li t5, 10	#for rebasing
	li a0, 0x30	#0
	li a1, 0x37	#0 rebased for bases > 10
	li t4, 0	#count
	bnez t1, dd_wide_setup
	#simplest case - lo cell only
  dd_generate_characters_simple:
	remu a2, t0, t3
	divu t0, t0, t3
	bgeu a2, t5, dd_simple_remainder
	add t6, a2, a0
	call dd_paste_in
	beqz t0, dd_prepare_reverse	#0
	j dd_generate_characters_simple
  dd_simple_remainder:
	add t6, a2, a1
	call dd_paste_in
	j dd_generate_characters_simple
  dd_wide_setup:
	#preserve numbers for character mapping
	addi sp, sp, -16
	sd a0, 0(sp)
	sd a1, 8(sp)
  dd_wide:
	#general case both cells
	remu a0, t1, t3
	mv a2, t3
	mv a1, t0
	call dd_long_division_unsigned
	beqz a7, dd_reverse
	mv t0, a0
	mv t6, a1
	bgeu t6, t5, dd_wide_remainder
	ld a0, 0(sp)
	add t6, t6, a0
	call dd_paste_in
  dd_update_double:
	divu t1, t1, t3
	bnez t1, dd_wide
	beqz t0, dd_reverse_setup
	j dd_wide
  dd_wide_remainder:
	ld a1, 8(sp)
	add t6, t6, a1
	call dd_paste_in
	j dd_update_double
  dd_reverse_setup:
	addi sp, sp, 16		#drop storage
  dd_prepare_reverse:
 	#process sign
	POP t0
	beqz t0, dd_reverse
	call dd_paste_minus
  dd_reverse:
	POP t0		#SCRATCH_PAD
	mv t5, t0
	mv t6, t2
	sub a5, t2, t0	#length
  dd_ddotr_join:
	addi t2, t2, -1
  dd_reverse_loop:
	bgeu t0, t2, dd_reverse_done
	lb t1, 0(t0)
	lb t3, 0(t2)
	sb t1, 0(t2)
	sb t3, 0(t0)
	addi t0, t0, 1
	addi t2, t2, -1
	j dd_reverse_loop
  dd_reverse_done:
	WRITESTRINGR t5, a5
	WRITECHAR 0x20	#pad with space
	TAILMOD t1
  dd_paste_minus:
	li t6, 45
  dd_paste_in:
	#t6 has character
	sb t6, 0(t2)
	addi t4, t4, 1
	addi t2, t2, 1
	ret

  dd_long_division_unsigned:
  #a0 - remainder
  #a1 - dividend
  #a2 - divisor
  #OUTPUT
  #a0 quotient
  #a1 remainder
  #a7 1 if answer valid
	li a7, 0
	#check validity
	beqz a2, dd_long_division_unsigned_quit
	#get extra registers
	addi sp, sp, -56
	sd s0, 0(sp)
	sd s1, 8(sp)
	sd s2, 16(sp)
	sd s3, 24(sp)
	sd s4, 32(sp)
	sd s5, 40(sp)
	sd s6, 48(sp)
	mv s0, a0
	mv s1, a1
	mv s2, a2
	li a7, 1
	#set up the calculation
	li s3, 0x8000000000000000
	li a3, 63
	li a0, 0
	li a1, 0
  dd_long_division_unsigned_calculate:
	and s4, s1, s3
	srl s5, s4, a3		#just want the bit
	slli s0, s0, 1
	add s0, s0, s5
	divu s5, s0, s2
	beqz s5, dd_long_division_unsigned_advance
	sll s6, s5, a3
	or a0, a0, s6
	remu s0, s0, s2
  dd_long_division_unsigned_advance:
	srli s3, s3, 1
	beqz s3, dd_long_division_unsigned_done
	addi a3, a3, -1
	j dd_long_division_unsigned_calculate
  dd_long_division_unsigned_done:
	mv a1, s0
	ld s0, 0(sp)
	ld s1, 8(sp)
	ld s2, 16(sp)
	ld s3, 24(sp)
	ld s4, 32(sp)
	ld s5, 40(sp)
	ld s6, 48(sp)
	addi sp, sp, 56
  dd_long_division_unsigned_quit:
	ret

	CODEHEADERZ DZEROLESS, D0<, DD, 0x01
	#(d -- flag)
	ld t0, 0(sp)
	addi sp, sp, 8
	li t1, 0x8000000000000000
	and t2, t0, t1
	li t3, 0	#flag
	beqz t2, dzeroless_done
	li t3, -1
  dzeroless_done:
	sd t3, 0(sp)
	TAILMOD t1

	CODEHEADERZ MTIMESDIV, M*/, DZEROLESS, 0x01
	#(d n1 n2 -- d)
	ld t0, 0(sp)	#n2
	ld t1, 8(sp)    #n1
	ld t2, 16(sp)	#hi
	ld t3, 24(sp)	#lo
	addi sp, sp, 16
	#get sign for multiplication
	li a0, 0	#positive sign required
	bgez t1, mtimesdiv_check_double_sign
	li a0, 1	#negative sign required
  mtimesdiv_check_double_sign:
	bgez t2, mtimesdiv_begin_calculation
	addi a0, a0, -1
  mtimesdiv_begin_calculation:
	#produce intermediate first
	mulhsu t4, t1, t3
	mul t3, t3, t1
	mulh t5, t1, t2
	mul t2, t2, t1
	add t2, t2, t4
	#handle sign issue
	bnez t5, mtimesdiv_got_long_form
	beqz a0, mtimesdiv_got_long_form
	li t5, -1
  mtimesdiv_got_long_form:
	#intermediate is now (hi)t5-t2-t3(lo)
	#now implement long division
	mv a0, t5
	mv a1, t2
	mv a2, t0
	mv a3, t5
	mv a4, t3
	call mtimesdiv_very_long_division
	sd a1, 8(sp)
	sd a0, 0(sp)
	TAILMOD t1
  mtimesdiv_very_long_division:
  #a0 - hiword
  #a1 - dividend hi
  #a4 - dividend lo
  #a2 - divisor
  #a3 - hi word (for sign)
  #OUTPUT
  #a0 quotient -hi
  #a1 quotient - lo
  #a7 1 if answer valid
	li a7, 0
	#check validity
	beqz a2, mtimesdiv_long_division_signed_quit
	#get extra registers
	addi sp, sp, -56
	sd s0, 0(sp)
	sd s1, 8(sp)
	sd s2, 16(sp)
	sd s3, 24(sp)
	sd s4, 32(sp)
	sd s5, 40(sp)
	sd s6, 48(sp)
	mv s0, a0	#s0 - hiword - later remainder
	mv s1, a1	#s1 - dividend in
	mv s2, a2	#s2 - divisor in
	li a7, 1
	li a6, 0 	#sign - 0 for positive
	#calculate sign
	li s3, 0x8000000000000000
	and s4, a3, s3
	srli s4, s4, 63
	and s5, a2, s3
	srli s5, s5, 63
	xor a6, s4, s5
	beqz a6, mtimesdiv_long_division_setup
	#want everything to be positive
	and s6, s3, s2
	beqz s6, mtimesdiv_correct_dividend
	li s6, -1
	xor s2, s2, s6
	addi s2, s2, 1
	j mtimesdiv_long_division_setup
  mtimesdiv_correct_dividend:
	li s6, -1
	xor s5, a4, s6
	xor a1, s1, s6
	xor a0, s0, s6
	addi a4, s5, 1
	bgtu a4, s5, mtimesdiv_long_division_setup_full
  mtimesdiv_correct_upper:
	addi s1, a1, 1
	bgtu s1, a1, mtimesdiv_long_division_half_full
	addi s0, a0, 1
	j mtimesdiv_long_division_setup
  mtimesdiv_long_division_setup_full:
	mv s1, a1
  mtimesdiv_long_division_setup_half_full:
	mv s0, a0
  mtimesdiv_long_division_setup:
	#set up the calculation
	rem s0, s0, s2
	li a3, 63
	li a0, 0
	li a1, 0
  mtimesdiv_long_division_signed_calculate:
	and s4, s1, s3
	srl s5, s4, a3		#just want the bit
	slli s0, s0, 1
	add s0, s0, s5
  mtimesdiv_long_division_signed_unsigned:
	divu s5, s0, s2
  mtimesdiv_long_division_signed_continue:
	sll s6, s5, a3
	or a0, a0, s6
  mtimesdiv_long_division_signed_rem_unsigned:
	remu s0, s0, s2
  mtimesdiv_long_division_signed_advance:
	srli s3, s3, 1
	beqz s3, mtimesdiv_long_division_signed_done
	addi a3, a3, -1
	j mtimesdiv_long_division_signed_calculate
  mtimesdiv_long_division_signed_done:
        # have now calculated hi quotient - in a0
	# now repeat
	mv s1, a4
	PUSH a0
	li s3, 0x8000000000000000
	li a3, 63
	li a0, 0
	li a1, 0
  very_long_division_calculate:
	and s4, s1, s3
	srl s5, s4, a3		#just want the bit
	slli s0, s0, 1
	add s0, s0, s5
  very_long_division_unsigned:
	divu s5, s0, s2
  very_long_division_continue:
	beqz s5, very_long_division_advance
	sll s6, s5, a3
	or a0, a0, s6
  very_long_division_remainder_unsigned:
	remu s0, s0, s2
  very_long_division_advance:
	srli s3, s3, 1
	beqz s3, very_long_division_done
	addi a3, a3, -1
	j very_long_division_calculate
  very_long_division_done:
	mv a1, a0
	POP a0
	beqz a6, mtimesdiv_long_division_signed_leave
  mtimesdiv_negate:
	li s1, -1
	xor s2, a1, s1
	xor a0, a0, s1
	addi a1, s2, 1
	bgtu a1, s2, mtimesdiv_long_division_signed_leave
	addi a0, a0, 1
  mtimesdiv_long_division_signed_leave:
	ld s0, 0(sp)
	ld s1, 8(sp)
	ld s2, 16(sp)
	ld s3, 24(sp)
	ld s4, 32(sp)
	ld s5, 40(sp)
	ld s6, 48(sp)
	addi sp, sp, 56
  mtimesdiv_long_division_signed_quit:
	ret
	
	CODEHEADERZ MPLUS, M+, MTIMESDIV, 0x01
	#(d n -- d)
	ld t2, 0(sp)	#lo
	li t3, 0	#hi - zero
	ld t1, 8(sp)	#hi
	ld t0, 16(sp)	#lo
	addi sp, sp, 8
	bltz t2, mplus_process_negative
	j dplus_mplus_join
  mplus_process_negative:
	#sign extend
	li t3, -1
	j dplus_mplus_join
	
	CODEHEADERZ DPLUS, D+, MPLUS, 0x01
	#(d1 d2 -- d3)
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	addi sp, sp, 16
  dplus_mplus_join:
	add t4, t0, t2
	blt t4, t0, dplus_do_overflow
	blt t4, t2, dplus_do_overflow
	j dplus_past_overflow
  dplus_do_overflow:
	addi t3, t3, 1
  dplus_past_overflow:
	add t5, t3, t1
	sd t4, 8(sp)
	sd t5, 0(sp)
	TAILMOD t1

	CODEHEADER DNEGATE, DPLUS, 0x01
	#(d -- d)
	ld t0, 8(sp)	#lo
	ld t1, 0(sp)	#hi
	li t2, -1
	xor t3, t2, t0
	xor t4, t2, t1
	addi t5, t3, 1
	bgtu t5, t3, dnegate_nooverflow
	addi t4, t4, 1
  dnegate_nooverflow:
	sd t4, 0(sp)
	sd t5, 8(sp)
	TAILMOD t1

	CODEHEADERZ DTWOTIMES, D2*, DNEGATE, 0x1
	#(d -- d)
	ld t0, 8(sp)	#lo
	ld t1, 0(sp)	#hi
	li t2, 0x8000000000000000
	and t3, t0, t2	#test for carry
	slli t0, t0, 1
	slli t1, t1, 1
	beqz t3, dtwotimes_nooverflow
	addi t1, t1, 1
  dtwotimes_nooverflow:
	sd t0, 8(sp)
	sd t1, 0(sp)
	la t1, NEXTMOD
	ld t1, 0(t1)
	jr t1

	CODEHEADERZ DTWODIV, D2/, DTWOTIMES, 0x01
	#(d -- d)
	ld t0, 8(sp)	#lo
	ld t1, 0(sp)	#hi
	li t2, 0x1
	and t3, t1, t2	#will there be carry?
	li t4, 2
	div t5, t1, t4
	srli t0, t0, 1
	beqz t3, dtwodiv_nooverflow
	li t6, 0x8000000000000000	#handle carry
	or t0, t0, t6
  dtwodiv_nooverflow:
	sd t0, 8(sp)
	sd t5, 0(sp)
	TAILMOD t1

	CODEHEADERZ DLESS, D<, DTWODIV, 0x01
	#(d d -- flag)
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	li t4, 0	#flag
	bgt t1, t3, dless_done
	bne t1, t3, dless_pass
	bge t0, t2, dless_done
  dless_pass:
	li t4, -1
  dless_done:
	addi sp, sp, 24
	sd t4, 0(sp)
	TAILMOD t1
	
	CODEHEADERZ DULESS, DU<, DLESS, 0x01
	#(ud ud -- flag)
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	li t4, 0
	bgtu t1, t3, duless_done
	bne t1, t3, duless_pass
	bgeu t0, t2, duless_done
  duless_pass:
	li t4, -1
  duless_done:
	addi sp, sp, 24
	sd t4, 0(sp)
	TAILMOD t1

	CODEHEADERZ TWOROT, 2ROT, DULESS, 0x01
	#(x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2)
	ld t6, 0(sp)
	ld t5, 8(sp)
	ld t4, 16(sp)
	ld t3, 24(sp)
	ld t2, 32(sp)
	ld t1, 40(sp)
	sd t1, 8(sp)
	sd t2, 0(sp)
	sd t6, 16(sp)
	sd t5, 24(sp)
	sd t4, 32(sp)
	sd t3, 40(sp)
	TAILMOD t1

	CODEHEADERZ DTOS, D>S, TWOROT, 0x01
	#(d -- n)
	ld t1, 0(sp)		#higher range
	ld t0, 8(sp)
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


  starter_double:
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
	call getDictionary
	POP a1
	sd a0, 0(a1)	#update lead word
	la a0, DTOS	#new end of dictionary
	addi a0, a0, -56
	call setDictionary	#return new tail of dictionary to caller
	#setup extension writing
	la a0, WA_TWOLITERAL
	la a1, extender_2literal
	call  setExtenders
	POP ra
	fence.i
	ret

 #a0 address to start writing
 #a1 low part of number to write
 #a2 high part of number to write
 #a3 next address
  double_two_constant_code:
	li t0, 0x297
	sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
	li t0, 0x202B303
	sw t0, 4(a0)						#ld t1, 32(t0)
	li t0, 0x282B383
	sw t0, 8(a0)						#ld t2, 40(t0)
	li t0, 0xFF010113
	sw t0, 12(a0)						#addi sp, sp, -16
	li t0, 0x613423
	sw t0, 16(a0)						#sd t1, 8(sp)
	li t0, 0x713023
	sw t0, 20(a0)						#sd t2, 0(sp)
	#now jump to next
	li t0, 0x302B303
	sw t0, 24(a0)						#ld t1, 48(t0)
	li t0, 0x30067
	sw t0, 28(a0)						#jr t1
	sd a2, 32(a0)						#hi						
	sd a1, 40(a0)						#low
	sd a3, 48(a0)						#NEXT
	addi a0, a0, 56
	fence.i
	ret


.section .init_array
.balign 8
.8byte starter_double

