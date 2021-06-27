

		CODEHEADER TRUE, COLON, 0x01
		j gt_true

		CODEHEADER GT, TRUE, 0x01
		ld t1, 0(sp)
		ld t0, 8(sp)
		addi sp, sp, 16
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
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		j gt_test

		CODEHEADER FALSE, LT, 0x01
		j gt_false

		CODEHEADER EQUALS, FALSE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		bne t0, t1, gt_false
		j gt_true

		CODEHEADER AND, EQUALS, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		and t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT

		CODEHEADER OR, AND, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		or t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT
		
		CODEHEADER XOR, OR, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		xor t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT

		CODEHEADER NOT, XOR, 0x01
		ld t0, 0(sp)
		not t1, t0
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER IF, NOT, 0x01
		#just a place holder
		tail NEXT

		CODEHEADER THEN, IF, 0x01
		tail NEXT


		CODEHEADER ELSE, THEN, 0x01
		tail NEXT

		

#		CONDITIONAL STACK - v3 (RV64I)
#		==============================
#		8 bytes - write point
#		8 bytes - counter
#     		8 bytes - high tide 
#		--- stack entry ---
#		8 bytes - then address
#		8 bytes - else address
#		8 bytes - flag: ...|else|then|
#     		8 bytes - then count 
#		8 bytes - else count



  ifelse_func_create:
		#write out an IF block for this code
		#followed by an ELSE block
		#ELSE block may never be used but
		#writing it this way means we have a fixed address
		#a0 returns address at which we start writing
		addi sp, sp, -40
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		ld s1, 0(a0)		#base address
		ld s2, -8(a1)		#current index address for writing (high tide)

		li s0, CONDITIONALBLK	#size of block
		mul s3, s2, s0		#multiply by index
		addi s2, s2, 1		#increment index
		sw s2, -8(a1)		#store incremented index
		add s1, s1, s3		#start address in s1
		mv s2, s1		#copy to s2
		#write out address where code begins
		addi s1, s1, 8
		sd s1, 0(s2)
		#now the code
		#fetch condition off the stack
		#(write out) ld t0, 0(sp)
		li s3, 0x12383
		sw s3, 8(s2)
		#addi sp, sp, 8
		li s3, 0x810113
		sw s3, 12(s2)
		#beq t0, zero, +16
		li s3, 0x28863
		sw s3, 16(s2)
		#now in true path
		#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 20(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 24(s2)
		li s3, 0x28067
		sw s3, 28(s2)
		#now in the then/else path
		#simplest/default case, skip one instruction
		#addi s7, s7, 8
		li s3, 0x8B8B93
		sw s3, 32(s2)
		#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 36(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 40(s2)
		li s3, 0x28067
		sw s3, 44(s2)

		#now ELSE block
		mv s1, s2
		addi s1, s1, 56
		sd s1, 48(s2)		#WA for this else
		#addi s7, s7, 8		#default is skip 1 instruction
		li s3, 0x8B8B93
		sw s3, 56(s2)
		#register based jump to NEXT
		la s0, NEXT
		li s4, 0xFFFFF000
		and s3, s0, s4
		ori s3, s3, 0x2B7
		sw s3, 60(s2)
		li s3, 0xFFF
		and s4, s0, s3
		slli s3, s4, 20
		li s1, 0x28293
		or s3, s3, s1
		sw s3, 64(s2)
		li s3, 0x28067
		sw s3, 68(s2)

		#update the stack
		ld s0, 0(a0)		#s0 - holds base address we are writing to
		mv s1, a0		#s1 - holds address at very bottom of the stack
		mv a0, s2		#a0 - now holds the return the address we need
		ld s2, 0(a1)		#s2 - holds index
		#calculate where to write stack entry
		li s3, -CONDITIONALSTK	#s3 - stack entry size
		mul s4, s3, s2		#s4 - offset to this stack entry
		add s1, s4, s1		#s1 adjusted for offset
		addi s1, s1, -24	#s1 adjusted for counter and high tide
		#s1 now holds the bottom address for stack entry
		#now calculate then and else
		li s3, CONDITIONALBLK
		#this has to be at the high tide mark
		ld s2, -8(a1)		#s2 has high tide
		addi s2, s2, -1		#correct to zero start
		mul s4, s3, s2		#s4 has offset in the code block
		add s4, s4, s0		#s4 now has start address of code block
		sd s4, 0(s1)		#THEN address written
		add s4, s4, 0x30	#ELSE address ...
		sd s4, -8(s1)		#...written
		#update the counter
		ld s2, 0(a1)
		addi s2, s2, 1
		sd s2, 0(a1)
		#zero the rest of the stack
		sd zero, -16(s1)	#FLAG
		sd zero, -24(s1)	#THEN count
		sd zero, -32(s1)	#ELSE count

		#now return
		ld s4, 32(sp)
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 40
		ret


  increment_current_skip:

		addi sp, sp, -48
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		sd s5, 40(sp)
		mv s0, a0
		addi s0, s0, -24	#top of the stack entries
		ld s1, 0(a1)		#current index 
		li s2, -CONDITIONALSTK
		addi s1, s1, -1		#rebase to zero
		mul s3, s2, s1		#calculate raw offset
		add s3, s3, s0		#and add to get actual address
		PUSH ra
		call get_flag_mode
		POP ra
		mv s2, a0
		#test for else mode
		beqz a2, incrementing_then_offset
		addi s3, s3, -32	#point to else counter
		j incrementing_skip_increment
  incrementing_then_offset:
		add s3, s3, -24		#point to then counter
  incrementing_skip_increment:
		ld s0, 0(s3)
		addi s0, s0, 1
		sd s0, 0(s3)
		ld s5, 40(sp)
		ld s4, 32(sp)
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 48
		ret
		

  get_increments:
		#sum increments for current and return in a0
		#a1 returns else increments
		#a2 returns then increments
		addi sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)

		mv s0, a0
		add s0, s0, -24		#s0 now pointing to bottom of stack
		ld s1, 0(a1)
		li s2, -CONDITIONALSTK
		addi s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0
		ld s1, -32(s3)		#else count
		mv a2, s1
		add s0, zero, s1
		ld s1, -24(s3)		#then count
		mv a1, s1
		add s0, s0, s1
		mv a0, s0
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret

  clean_conditional_stack:
		#zero out the top of the conditional stack
		addi sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		mv s0, a0
		add s0, s0, -12
		ld s1, 0(a1)
		li s2, -CONDITIONALSTK
		add s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0
		#now zero the lot
		sd zero, 0(s3)
		sd zero, -8(s3)
		sd zero, -16(s3)
		sd zero, -24(s3)
		sd zero, -32(s3)
		#store the decremented counter
		sd s1, 0(a1)
		#return the decemented counter
		mv a0, s1
		#wind up
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret

  get_conditional_addresses:
		#a0 returns IF
		#a1 returns ELSE
		addi sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		mv s0, a0
		add s0, s0, -24
		lw s1, 0(a1)
		li s2, -CONDITIONALSTK
		add s1, s1, -1
		mul s3, s2, s1
		add s3, s3, s0		#s3 has the address of the block
		#now grab the needed
		ld a0, 0(s3)
		ld a1, -8(s3)
		#unwind stack
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret	
		
		
