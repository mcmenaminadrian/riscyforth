

		CODEHEADER TRUE, COLON, 0x01
		j gt_true

		CODEHEADER GT, TRUE, 0x01
		POP t1
		POP t0
  gt_test:
		bgt t0, t1, gt_true
  gt_false:
		PUSH zero
		tail NEXT
  gt_true:	
		li t0, -1
		PUSH t0
		tail NEXT

		CODEHEADER LT, GT, 0x01
		POP t0
		POP t1
		j gt_test

		CODEHEADER FALSE, LT, 0x01
		j gt_false

		CODEHEADER EQUALS, FALSE, 0x01
		POP t0
		POP t1
		bne t0, t1, gt_false
		j gt_true
		
		CODEHEADER IF, EQUALS, 0x01
		#just a place holder
		tail NEXT

		CODEHEADER THEN, IF, 0x01
		tail NEXT


		CODEHEADER ELSE, THEN, 0x01
		tail NEXT

#IF FLAG CODE
  #returns value of ifflag in a0
  get_iffmode:
		add sp, sp, -8
		sw s0, 0(sp)
		la s0, ifflag
		lw a0, 0(s0)
		lw s0, 0(sp)
		add sp, sp, 8
		ret

  decriment_iffmode:
		add sp, sp, -8
		sw s0, 0(sp)
		la s0, ifflag
		lw a0, 0(s0)
		add a0, a0, -1
		sw a0, 0(s0)
		lw s0, 0(sp)
		add sp, sp, 8
		ret

  increment_iffmode:
		add sp, sp, -8
		sw s0, 0(sp)
		la s0, ifflag
		lw a0, 0(s0)
		add a0, a0, 1
		sw a0, 0(s0)
		lw s0, 0(sp)
		add sp, sp, 8
		ret

#ELSE-THEN FLAG CODE

  set_flag_mode_on:
		#a0 contains bits to set on
		add sp, sp, -24
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 20(sp)

		la s0, DECIDESTACKP
		li s1, 0x14		#size of stack entry
		lw s2, 0(s0)
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, 4		#to else mode adjusted for hightide
		add s2, s3, s0		#s2 has address
		lw s1, 0(s2)
		or a0, s1, a0		#set the bits
		sw a0, 0(s2)		#a0 also returns new state

		lw s3, 20(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 24
		ret
		
  set_flag_mode_off:
		#a0 has bits to turn off
		add sp, sp, -24
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 20(sp)

		la s0, DECIDESTACKP
		li s1, 0x14		#size of stack entry
		lw s2, 0(s0)
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, 4		#to else mode adjusted for hightide
		add s2, s3, s0		#s2 has address
		not s1, a0
		lw s3, 0(s2)
		and a0, s3, s1		# flag &=(!a0)
		sw a0, 0(s2)		#a0 returns new state 

		lw s3, 20(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 24
		ret

  get_flag_mode:
		add sp, sp, -24
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 20(sp)
		
		la s0, DECIDESTACKP
		li s1, 0x14		#size of stack entry
		lw s2, 0(s0)
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, 4		#to else mode adjusted for hightide
		add s2, s3, s0		#s2 has address
		lw a0, 0(s2)		#a0 returns unaltered state
		
		lw s3, 20(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 24
		ret
		

#		CONDITIONAL STACK - v2
#		======================
#		4 bytes - write point
#		4 bytes - counter
#     		4 bytes - high tide 
#		--- stack entry ---
#		4 bytes - then address
#		4 bytes - else address
#		4 bytes - flag: ...|else|then|
#     		4 bytes - then count 
#		4 bytes - else count



  ifelse_func_create:
		#write out an IF block for this code
		#followed by an ELSE block
		#ELSE block may never be used but
		#writing it this way means we have a fixed address
		#a0 returns address at which we start writing
		addi sp, sp, -40
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)
		lw s1, 0(a0)		#base address
		lw s2, 0(a1)		#current index address
		mv a1, s2
		lw s2, 0(a1)

		li s0, CONDITIONALBLK	#size of block
		mul s3, s2, s0		#multiply by index
		addi s2, s2, 1		#increment index
		sw s2, 0(a1)		#store incremented index
		sw s2, 4(a1)		#and in high tide		
		add s1, s1, s3		#start address in s1
		mv s2, s1		#copy to s2
		#write out address where code begins
		addi s1, s1, 4
		sw s1, 0(s2)
		#now the code
		#write out lw t0, 0(sp)
		li s3, 0x12283
		sw s3, 4(s2)
		#addi sp, sp, 8
		li s3, 0x810113
		sw s3, 8(s2)
		#beq t0, zero, +16
		li s3, 0x28863
		sw s3, 12(s2)
		#now in true path
		#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 16(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 20(s2)
		li s3, 0x28067
		sw s3, 24(s2)
		#now in the then/else path
		#simplest/default case, skip one instruction
		#addi s7, s7, 4
		li s3, 0x4B8B93
		sw s3, 28(s2)
		#register based jump to NEXT
	#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 32(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 36(s2)
		li s3, 0x28067
		sw s3, 40(s2)

		#now ELSE block
		mv s1, s2
		addi s1, s1, 4
		sw s1, 44(s2)		#WA for this else
		#addi s7, s7, 1		#default is skip 1
		li s3, 0x4B8B93
		sw s3, 48(s2)
		#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 52(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 56(s2)
		li s3, 0x28067
		sw s3, 60(s2)

		#update the stack
		sw s0, s2		#s0 - base address
		lw s1, 0(a1)
		lw s2, 0(s1)		#s2 counter		
		sw s2, 8(a0)		#update hightide
		#where are we on the stack
		li s1, 0x14		#each stack entry is 20 bytes
		mul s3, s1, s2
		addi s3, s3, -8		#adjust for first entry being offset 0 bytes - and for first 12 bytes
		lw s1, 0(a0)
		add s3, s1, s3		#s3 points to start of stack entry
		sw s0, 0(s3)
		addi s1, s0, 44
		sw s1, 4(s3)		#addresses written
		sw zero, 8(s3)		#zero out counts
		sw zero, 12(s3)
		sw zero, 16(s3)
		
		#now return
		mv a0, s2
		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 40
		ret


  increment_current_skip:

		addi sp, sp, -48
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)
		sw s5, 40(sp)

		lw s0, 0(a0)
		addi s0, s0, 12
		lw s1, 0(a1)		#current index address
		mv a1, s1
		lw s1, 0(a1)		#now current index
		li s2, CONDITIONALSTK
		addi s1, s1, -1		#rebase to zero
		mul s3, s2, s1		#calculate raw offset
		add s3, s3, s0		#and add to get actual address
		call get_flag_mode
		mv s2, a0
		#test for else mode
		li s4, 0x02
		and s5, s3, s2
		beqz, incrementing_then_offset
		addi s3, s3, 0x10	#point to else counter
		j incrementing_skip_increment
  incrementing_then_offset:
		add s3, s3, 0x0C	#point to then counter
  incrementing_skip_increment:
		lw s0, 0(s3)
		addi s0, s0, 1
		sw s0, 0(s3)
		
		lw s5, 40(sp)
		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 48
		ret
		

  get_increments:
		#sum increments for current and retrun in a0
		#a1 returns else increments
		#a2 returns then increments
		addi sp, sp, -32
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)

		lw s0, 0(a0)
		add s0, s0, 12
		lw s1, 0(a1)
		mv a1, s1
		lw s1, 0(a1)
		li s2, CONDITIONALSTK
		addi s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0
		lw s1, 16(s3)		#else count
		mv a1, s1
		add s0, zero, s1
		lw s1, 12(s3)		#then count
		mv a2, s1
		add s0, s0, s1
		mv a0, s0

		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 32
		ret

  clean_conditional_stack:
		#zero out the top of the conditional stack
		addi sp, sp, -32
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		lw s0, 0(a0)
		add s0, s0, 12
		lw s1, 0(a1)
		mv a1, s1
		lw s1, 0(a1)
		li s2, CONDITIONALSTK
		add s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0
		#now zero the lot
		sw zero, 0(s3)
		sw zero, 4(s3)
		sw zero, 8(s3)
		sw zero, 12(s3)
		sw zero, 16(s3)
		#store the decremented counter
		sw s1, 0(a1)
		#return the decemented counter
		mv a0, s1
		#wind up
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 32
		ret

  get_conditional_addresses:
		#a0 returns IF
		#a1 returns ELSE
		addi sp, sp, -32
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		add s0, s0, 12
		lw s1, 0(a1)
		mv a1, s1
		lw s1, 0(a1)
		li s2, CONDITIONALSTK
		add s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0		#s3 has the address of the block
		#now grab the needed
		lw a0, 0(s3)
		lw a1, 4(s3)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 32
		ret	
		
		