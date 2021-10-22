#Simple integer calculations

                CODEHEADER ADD, DOT, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                add t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER MUL, ADD, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                mul t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER DIV, MUL, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                div t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ SUB, -, DIV, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                sub t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER PLUSONE, 1+, -, 0x01
		ld t0, 0(sp)
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER PLUS2, PLUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, 2
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER MINUS1, PLUS2, 0x01
		ld t0, 0(sp)
                addi t0, t0, -1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER MINUS2, MINUS1, 0x01
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

                CODEHEADER SLMOD, MOD, 0x01
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

                CODEHEADER MIN, ABS, 0x01
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

