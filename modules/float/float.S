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

	CODEHEADERZ FD, F., FPLUS, 0x01
	#(r --)
	#t1 holds sign
	#t3 holds exponent
	#t4 holds mantissa
	ld t0, 0(sp)			#load from stack
	addi sp, sp, -64		#adjust stack
	sd s1, 0(sp)			#store registers
	sd s2, 8(sp)
	sd s3, 16(sp)
	sd s4, 24(sp)
	sd s5, 32(sp)
	sd s6, 40(sp)
	sd ra, 48(sp)			#store to through system call
	sd t0, 56(sp)
	#use s1 - s6 for calculation
	li a0, 1024			#allocate 1K for scratchpad
	call malloc
	beqz a0, fd_malloc_failed
	mv s1, a0			#store scratchpad address in s1
	ld t0, 56(sp)			#restore number we are trying to analyze
	beqz t0, fd_output_zero		#degenerate case of 0
	li t1, -1			#test for all bits on
	beq t0, t1, fd_output_neg_inf	#negative infinity
	srli t1, t1, 1			#turn off first bit
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
	li a1, 64			#loop to zero memory setup
  fd_init_memory:
	sd zero, 0(s1)			#store zero
	addi s1, s1, 8			#move ahead
	addi a1, a1, -1			#decrement loop counter
	bnez a1, fd_init_memory		#loop
	mv s1, a0			#store scratchpad address in s1 again
	li s4, 52			#for bit mask calculation
	beqz t4, fd_found_lowest_bit	#handle case of 0 mantissa
	li s3, 1			#ready for bitmask
  fd_test_mantissa_bit:
	and s5, t4, s3			#mask mantissa
	bnez s5, fd_found_lowest_bit	#found the smallest bit
	addi s4, s4, -1			#count lowest bit
	slli s3, s3, 1			#shift bit mask to left
	j fd_test_mantissa_bit		#loop - no need to check overrun here
  fd_found_lowest_bit:
	#s4 has bit count
	#how many zeros?
	bltz t4, fd_calculate_negative	#is the exponent negative?
	#positive cases
	li s2, 52
	bgt t3, s2, fd_positive_bigger	#more than 52 bits
	#handle simplest case
	srl s2, t3, s4			#shift right
	li t0, 1			#to set bit on
	sub s3, s2, s4			#how many bits are on
	addi s3, s3, 1			#set the next one to 1
	sll t0, t0, s3			#shift mask to left
	or s2, s2, t0			#turn bit on
	ld t0, 504(s1)			#load lowest eight bytes
	or t0, t0, s2			#copy bit in
	sd t0, 504(s1)			#store result
	j fd_done
  fd_positive_bigger:
	li s2, 8
	div s3, s4, s2			#how many bytes
	rem s5, s4, s2			#how many bits
	li s6, 512
	sub s6, s6, s3			#reset base
	addi s6, s6, -1			#and we start on the next byte
	#now match the bits
	li t5, 52			#count this down
	li t6, 1
	addi s5, s5, -1			#adjust for starting at zero
	lb s3, 0(s6)
  fd_positive_mark_out_bits:
	and t2, t4, t6			#get the bit
	beqz t2, fd_move_to_next_bit	#bit is zero
	li a3, 1			#single bit on
	sll a3, a3, s5			#mask correct bit
	or s3, s3, a3			#turn bit on
  fd_move_to_next_bit:
	addi s5, s5, 1			#increment bit index
	bne s5, s2, fd_keep_on		#test if we need new byte
	sb s3, 0(s6)			#moving on to new byte so store
	addi s6, s6, -1			#new byte
	lb s3, 0(s6)			#load byte
	li s5, 0			#set bit index to zero
  fd_keep_on:
	addi t5, t5, -1			#count down
	bgez t5, fd_keep_moving		#have we gone below zero?
	li a3, 1			#mark final bit as zero
	sll a3, a3, s5
	or s3, s3, a3			#turn bit on
	sb s3, 0(s6)			#store byte
	j fd_done			#finished
  fd_keep_moving:
	slli t6, t6, 1			#mask one bit to left
	j fd_positive_mark_out_bits	#loop back
	




  fd_done:
	mv a0, s1
	call free
	ld s1, 0(sp)
	ld s2, 8(sp)
	ld s3, 16(sp)
	ld s4, 24(sp)
	ld s5, 32(sp)
	ld s6, 40(sp)
	ld ra, 48(sp)
	addi sp, sp, 64
	

	TAILMOD t1

	CODEHEADER ROOT2, FD, 0x01
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


 divide_by_ten:
	#input
	# a0 - power
	# a1 - mantissa
	# returns
	# a1 - 0 on success, something else on failure
	# a0 - pointer to buffer containing characters - must be FREEd by caller
	addi sp, sp, -96
	sd a0, 0(sp)				#save registers
	sd a1, 8(sp)
	sd s3, 16(sp)
	sd s4, 24(sp)
	sd s5, 32(sp)
	sd s6, 40(sp)
	sd s7, 48(sp)
	sd s8, 56(sp)
	sd s9, 64(sp)
	sd s10, 72(sp)
	sd s11, 80(sp)
	sd ra, 88(sp)
	li a0, 1024				#allocate 1K for buffer
	call malloc				#call
	li a1, 1				#failure by default
	beqz a0, clean_up_divide_start
	mv s2, a0				#s2 stores buffer address
	ld a0, 0(sp)				#store s0 and s1
	ld a2, 8(sp)				#and swap in values
	sd s0, 0(sp)
	sd s1, 8(sp)
	mv s1, a0				#s1 holds power
	mv s2, a2				#s2 mantissa
	li t1, 128				#this many stores needed
	mv t2, a0				#use temp pointer into buffer
  divide_by_ten_clean:
	sd zero, 0(t2)				#store 0
	addi t1, t1, -1
	beqz t1, divide_by_ten_buffer_clean	#done cleaning
	addi t2, t2, 8				#next 64 bits along
	j divide_by_ten_clean			#loop back
  divide_by_ten_clean:
	#calculate how long the number is
	#first adjust mantissa
	srli s2, s2, 1
	li t0, 0x8000000000000000
	or s2, s2, t0				#turn on bit for 1
	li s3, 1				#bit on
	li s4, 0				#how far left
  divide_by_ten_find_length:
	sll s5, s3, s4				#shift left
	and s6, s2, s5
	bnez s6, divide_by_ten_got_length	#found length
	addi s4, s4, 1				#check next bit along
	j divide_by_ten_find_length
  divide_by_ten_got_length:
	li s3, 63
	sub s3, s3, s4				#s3 holds maximum bit right
	#now do the division
	li a3, 10				#constant
	li s4, 1				#bit marker
	li s5, 63				#shift
	li s6, 0				#dividend
	li t0, 512
	addi a2, a0, t0				#pointer to half way into buffer
  divide_by_ten_shift:
	sll s7, s4, s5				
	and s8, s7, s2				#is bit 0 or 1
	slli s6, s6, 1				#shift left
	beqz s8, divide_by_ten_shift_divide	#0 so no adding 1
	ori s6, s6, 1				#or in 1
  divide_by_ten_shift_divide:
	div s7, s6, a3
	bnez s7, divide_by_ten_multiple		#got a result
	addi s5, s5, -1
	bgt s3, s5, divide_by_ten_zeros_only	#only zeros left
	j divide_by_ten_shift
  divide_by_ten_zeros_only:
	beqz s6, divide_by_ten_all_zeros	#everything is zero
	
	
	
	
	
	


	
	
	



  clean_up_divide:
	ld s1, 0(sp)			#save registers
	ld s2, 8(sp)
  clean_up_divide_start:
	ld s3, 16(sp)
	ld s4, 24(sp)
	ld s5, 32(sp)
	ld s6, 40(sp)
	ld s7, 48(sp)
	ld s8, 56(sp)
	ld s9, 64(sp)
	ld s10, 72(sp)
	ld s11, 80(sp)
	ld ra, 88(sp)
	addi sp, sp, 96
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
