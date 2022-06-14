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

	CODEHEADERZ TWOCONSTANT, 2CONSTANT, DABS, 0x01
	#( x1 x2 "<spaces>name --)
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
	li a5, 0x200	#0x200 for a 2constant
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

	CODEHEADERZ DD, D., DMINUS, 0x01
	#(d -- )
	ld t0, 8(sp)
	ld t1, 0(sp)
	addi sp, sp, 16
	li t2, 0x8000000000000000
	and t3, t2, t1
	PUSH t3		#save for later use
	beqz t3, dd_positive
	#handling a negative number
	li t2, -1	
	xor t3, t2, t0
	xor t4, t2, t1
	addi t5, t3, 1
	bgtu t5, t3, dd_negate_nooverflow
	addi t4, t4, 1
  dd_negate_nooverflow:
	mv t0, t5	#lo
	mv t1, t4	#hi
  dd_positive:
	la t2, SCRATCH_PAD
	la t3, CURRENT_BASE
	ld t3, 0(t3)	#base
	li t5, 10	#for rebasing
	li a0, 0x30	#0
	li a1, 0x37	#0 rebased for bases > 10
	li t4, 0	#count
  dd_generate_characters_hi:
	beqz t1, dd_process_lo	#don't want a leading 0
	remu a2, t1, t3
	divu t1, t1, t3
	bgeu a2, t5, dd_bigger_remainder_hi
	add t6, a2, a0
	call dd_paste_in
	j dd_generate_characters_hi
  dd_bigger_remainder_hi:
	add t6, a2, a1
	call dd_paste_in
	j dd_generate_characters_hi
  dd_process_lo:
	remu a2, t0, t3
	divu t0, t0, t3
	bgeu a2, t5, dd_bigger_remainder_lo
	add t6, a2, a0
	call dd_paste_in
	j dd_check_lo_exhausted
  dd_bigger_remainder_lo:
	add t6, a2, a1
	call dd_paste_in
  dd_check_lo_exhausted:
	bnez t0, dd_process_lo
	#now output string
	#adding minus sign if needed
	POP t0
	beqz t0, dd_reverse
	call dd_paste_minus
  dd_reverse:
	la t0, SCRATCH_PAD
	mv t5, t0
	mv t6, t2
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
	li t4, 0x20 #space for padding
	sb t4, 0(t6)
	addi t4, t4, 0
	WRITESTRINGR t5, t4
	TAILMOD t1
  dd_paste_minus:
	li t6, 45
  dd_paste_in:
	#t6 has character
	sb t6, 0(t2)
	addi t4, t4, 1
	addi t2, t2, 1
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
	

	CODEHEADERZ DPLUS, D+, DZEROLESS, 0x01
	#(d1 d2 -- d3)
	ld t0, 24(sp)	#lo
	ld t1, 16(sp)	#hi
	ld t2, 8(sp)	#lo
	ld t3, 0(sp)	#hi
	addi sp, sp, 16
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

	CODEHEADERZ DTOS, D>S, DULESS, 0x01
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
	call getDictionary
	POP a1
	sd a0, 0(a1)	#update lead word
	la a0, DTOS	#new end of dictionary
	addi a0, a0, -56
	call setDictionary	#return new tail of dictionary to caller
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
.8byte starter

