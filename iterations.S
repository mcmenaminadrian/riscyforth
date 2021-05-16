#specialist functions for conditionals

  add_if_depth:
		add sp, sp, -40
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)

		la s0, DECIDESTACKP
		lw s1, 0(s0)
		lw s2, 0(s1)
		li s3, 4
		mul s3, s2, s3
		sub s4, s1, s3
		lw s3, 0(s4)
		addi s3, s3, 1
		sw s3, 0(s4)
		sw s3, conditionalhightide, s0

		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		add sp, sp, 40
		ret


  get_if_depth:
		add sp, sp, -40
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)

		la s0, DECIDESTACKP
		lw s1, 0(s0)
		lw s2, 0(s1)
		li s3, 4
		mul s3, s2, s3
		sub s4, s1, s3
		lw a1, 0(s4)			#a1 returns commands to be jumped
		mv a0, s2			#a0 return depth
		la s0, DECIDESTACKB
		lw s1, 0(s0)
		lw s2, 0(s1)
		mv a3, s2			#a3 returns start of conditional block
	
		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		add sp, sp, 40
		ret

 wind_back_if_depth:
		add sp, sp, -40
		sw s0, 0(sp)
		sw s1, 8(sp)
		sw s2, 16(sp)
		sw s3, 24(sp)
		sw s4, 32(sp)

		la s0, DECIDESTACKP
		lw s1, 0(s0)
		lw s2, 0(s1)
		mv s3, s2
		addi s3, s3, -1
		sw s3, 0(s1)
		li s3, 4
		mul s3, s2, s3
		sub s1, s1, s3
		#have to cascade this down
		lw s2, 0(s1)
		sw zero, 0(s1)
		lw s0, 0(s0)
  wind_back_cascade:
		addi s1, s1, 4
		beq s1, s0, wind_back_check_finish
		addi s2, s2, -1
		lw s3, 0(s1)
		add s2, s3, s2
		sw s2, 0(s1)
		j wind_back_cascade
		
		
  wind_back_check_finish:
		la s0, ifflag
		lw s0, 0(s0)
		beqz s0, wind_back_update_base_pointer
		j wind_back_leave
  wind_back_update_base_pointer:
		la s0, conditionalhightide
		lw s0, 0(s0)
		la s1, DECIDESTACKB
		lw s1, 0(s1)
		lw s4, 0(s1)
		li s2, 0x30
		mul s3, s2, s0
		add s4, s4, s3
		sw s4, 0(s1)

  wind_back_leave:
		lw s4, 32(sp)
		lw s3, 24(sp)
		lw s2, 16(sp)
		lw s1, 8(sp)
		lw s0, 0(sp)
		add sp, sp, 40
		ret
