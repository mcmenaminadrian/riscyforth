

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





  if_func_create:
		#create 128 byte block of code
		addi sp, sp, -40
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)
		la s0, ifspace
		lw s1, 0(s0)
		la s0, ifindex
		lw s2, 0(s0)
		addi s2, s2, 1		#increment index
		sw s2, 0(s0)
		addi s2, s2, -1
		li s0, 0x30
		mul s3, s2, s0
		add s1, s1, s3		#s1 now contains word address
		mv s2, s1		#s2 writing address
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
		#now return
		mv a0, s2
		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		addi sp, sp, 40
		ret


			
