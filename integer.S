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

                CODEHEADER SUB, DIV, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                sub t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER PLUS1, SUB, 0x01
		ld t0, 0(sp)
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER MINUS1, PLUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, -1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER UNDERPLUS, MINUS1, 0x01
                POP t0
                POP t1
                POP t2
                add t0, t0, t2
                PUSH t1
                PUSH t0
                tail NEXT

                CODEHEADER MOD, UNDERPLUS, 0x01
                POP t0
                POP t1
                beq t0, zero, mod_zero
                div t2, t1, t0
                mul t3, t2, t0
                sub t0, t1, t3
  mod_zero:
                PUSH t0
                tail NEXT

                CODEHEADER SLASH_MOD, MOD, 0x01
                POP t0
                POP t1
                bne t0, zero, slash_mod_continue
                PUSH zero
                PUSH zero
                tail NEXT
  slash_mod_continue:
                div t2, t1, t0
                mul t3, t2, t0
                sub t0, t1, t3
                PUSH t0
                PUSH t2
                tail NEXT

                CODEHEADER NEGATE, SLASH_MOD, 0x01
                POP t0
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
                PUSH t0
                tail NEXT

                CODEHEADER ABS, NEGATE, 0x01
                POP t0
                li t1, 0x8000000000000000
                or t2, t0, t1
                beq t2, zero, abs_return_value
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
  abs_return_value:
                PUSH t0
                tail NEXT

                CODEHEADER MIN, ABS, 0x01
                POP t0
                POP t1
                blt t0, t1, min_return_first
                PUSH t1
                tail NEXT
  min_return_first:
                PUSH t0
                tail NEXT

                CODEHEADER MAX, MIN, 0x01
                POP t0
                POP t1
                bge t0, t1, max_return_first
                PUSH t1
                tail NEXT
  max_return_first:
                PUSH t0
                tail NEXT

                CODEHEADER BYE, MAX, 0x01
                PRINT riscy_forth0
                PRINT riscy_forthQ
                PRINT riscy_forth0
                tail exit

