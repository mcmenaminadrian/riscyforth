#Simple integer calculations

                CODEHEADERZ PLUS, +, DOT, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                add t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ TIMES, *, PLUS, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                mul t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ DIV, /, TIMES, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                div t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ MINUS, -, DIV, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                sub t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ PLUS1, 1+, MINUS, 0x01
		ld t0, 0(sp)
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ PLUS2, 2+, PLUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, 2
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ MINUS1, 1-, PLUS2, 0x01
		ld t0, 0(sp)
                addi t0, t0, -1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ MINUS2, 2-, MINUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, -2
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER UNDERPLUS, MINUS2, 0x01
                ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		add t0, t0, t2
		sd t1, 16(sp)
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER MOD, UNDERPLUS, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		beqz t0, mod_zero
		div t2, t1, t0
		mul t3, t2, t0
		sub t0, t1, t3
  mod_zero:
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ SLMOD, /MOD, MOD, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		bnez t0, slash_mod_continue
		sd zero, 8(sp)
		sd zero, 0(sp)
		tail NEXT
  slash_mod_continue:
                div t2, t1, t0
                mul t3, t2, t0
                sub t0, t1, t3
		sd t0, 8(sp)
		sd t2, 0(sp)
                tail NEXT

		CODEHEADER WITHIN, SLMOD, 0x01
		#test, low, high
		ld t2, 0(sp)
		ld t1, 8(sp)
		ld t0, 16(sp)		#number being tested
		addi sp, sp, 16
		beq t1, t2, within_fail
		beq t0, t1, within_fail
		beq t0, t2, within_fail
		blt t1, t2, within_continue
		mv t3, t2
		mv t2, t1
		mv t1, t3
  within_continue:
		blt t0, t1, within_fail
		bgt t2, t0, within_true
  within_fail:
		sd zero, 0(sp)
		tail NEXT
  within_true:
		li a0, -1
		sd a0, 0(sp)
		tail NEXT	
		

                CODEHEADER NEGATE, WITHIN, 0x01
		ld t0, 0(sp)
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER ABS, NEGATE, 0x01
		ld t0, 0(sp)
                li t1, 0x8000000000000000
                or t2, t0, t1
                beq t2, zero, abs_return_value
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
  abs_return_value:
		sd t0, 0(sp)
                tail NEXT

		CODEHEADERZ NUMSTART, \<\#, ABS, 0x01
		#(--)
		#start pictured numeric output conversion
		li t0, 1
		la t1, PICTUREDN
		sd t0, 0(t1)
		sd zero, 8(t1)		#count to zero
		tail NEXT

		CODEHEADERZ NUM, \#, NUMSTART, 0x01
		#( u -- u )
		la t0, PICTUREDN		#t0 has address of PICTUREDN var
		ld t1, 0(t0)			
		beqz t1, num_done		#we are not in pictured number mode
		ld a0, 8(t0)			#a0 has count in PAD 
		ld t1, 0(sp)			#t1 has number
		la t2, CURRENT_BASE		#t2 has BASE
		ld t2, 0(t2)
		div t3, t1, t2			
		mul t4, t2, t3			
		sub t5, t1, t4			#t5 has remainder
		li t6, 10
		bge t5, t6, num_use_letters
		#remainder is <10
		addi t5, t5, 0x30
		j num_pass_to_pad
  num_use_letters:
		addi t5, t5, 0x37
  num_pass_to_pad:
		la a1, SCRATCH_PAD
		add a2, a1, a0
		sb t5, 0(a2)			#store char
		addi a0, a0, 1
		sd a0, 8(t0)			#increment PAD writing point
		sd t3, 0(sp)			#pass what's left back to the stack
  num_done:
		tail NEXT

		CODEHEADERZ NUMS, \#S, NUM, 0x01
		#( u -- 0)
		la t0, PICTUREDN		#t0 has address of PICTUREDN var
		ld t1, 0(t0)			
		beqz t1, num_done		#we are not in pictured number mode
		ld a0, 8(t0)			#a0 has count in PAD 
  nums_keep_going:
		ld t1, 0(sp)			#t1 has number
		la t2, CURRENT_BASE		#t2 has BASE
		ld t2, 0(t2)
		div t3, t1, t2			
		mul t4, t2, t3			
		sub t5, t1, t4			#t5 has remainder
		li t6, 10
		bge t5, t6, nums_use_letters
		#remainder is <10
		addi t5, t5, 0x30
		j nums_pass_to_pad
  nums_use_letters:
		addi t5, t5, 0x37
  nums_pass_to_pad:
		la a1, SCRATCH_PAD
		add a2, a1, a0
		sb t5, 0(a2)			#store char
		addi a0, a0, 1
		sd a0, 8(t0)			#increment PAD writing point
		sd t3, 0(sp)			#pass what's left back to the stack
		beqz t3, num_done
		j nums_keep_going

		CODEHEADERZ NUMEND, \#\>, NUMS, 0x01
		#now reverse
		la t0, PICTUREDN
		ld t1, 0(t0)
		beqz t1, num_done
		ld a0, 8(t0)
		li t2, 1
		mv a3, a0
		ble a0, t2, numend_end
		addi a0, a0, -1
		la a1, SCRATCH_PAD
		add a0, a0, a1
  numend_keep_on:
		lbu t4, 0(a0)
		lbu t5, 0(a1)
		sb t4, 0(a1)
		sb t5, 0(a0)
		addi a0, a0, -1
		addi a1, a1, 1
		ble a0, a1, numend_end
		j numend_keep_on
  numend_end:
		#now write the whole thing out again
		#prefixing with length
		la t4, SCRATCH_PAD
		mv t2, a3
  numend_end_final_write:
		add t5, t4, t2
		lbu t6, 0(t5)
		sb t6, 8(t5)
		beqz t2, numend_out
		add t2, t2, -1
		j numend_end_final_write
  numend_out:
		sd a3, 0(t4)
		sd zero, 0(t0)
		sd zero, 8(t0)
		tail NEXT 

                CODEHEADER MIN, NUMEND, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
                blt t0, t1, min_return_first	
                tail NEXT
  min_return_first:
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER MAX, MIN, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
                bge t0, t1, max_return_first
                tail NEXT
  max_return_first:
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER BYE, MAX, 0x01
                PRINT riscy_forth0
                PRINT riscy_forthQ
                PRINT riscy_forth0
                tail exit

