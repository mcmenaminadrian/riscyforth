#Stack operations


                CODEHEADER SWAP, MS, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		sd t1, 0(sp)
		sd t0, 8(sp)
                tail NEXT

                CODEHEADER ROT, SWAP, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		sd t1, 16(sp)
		sd t0, 8(sp)
		sd t2, 0(sp)
                tail NEXT

                CODEHEADER DROP, ROT, 0x01
                addi sp, sp, 8
                tail NEXT

                CODEHEADER NIP, DROP, 0x01
		ld t0, 0(sp)
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER OVER, NIP, 0x01
		ld t1, 8(sp)
		addi sp, sp, -8
		sd t1, 0(sp)
                tail NEXT

                CODEHEADER TUCK, OVER, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		sd t0, 8(sp)
		sd t1, 0(sp)
		addi sp, sp, -8
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ BACKROT, -ROT, TUCK, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		sd t0, 16(sp)
		sd t2, 8(sp)
		sd t1, 0(sp)
                tail NEXT

                CODEHEADER PICK, BACKROT, 0x01
		ld t0, 0(sp)
		addi t0, t0, 1
                li t1, STACKOFFSET
                mul t2, t0, t1
                add t3, sp, t2
                ld t0, 0(t3)
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER ROLL, PICK, 0x01
                POP t0
                li t1, STACKOFFSET
                mul t2, t0, t1
                add t3, sp, t2
                ld t1, 0(t3)
  roll_replace:
                beq t0, zero, roll_place_selected
                ld t2, -STACKOFFSET(t3)
                sd t2, 0(t3)
                addi t3, t3, -STACKOFFSET
                add t0, t0, -1
                j roll_replace
  roll_place_selected:
                sd t1, 0(sp)
                tail NEXT

/*                CODEHEADERZ DROP2, 2DROP, ROLL, 0x01
                COLON DROP2
                .8byte WA_DROP
                .8byte WA_DROP
                .8byte WA_SEMI
*/
		CODEHEADERZ DROP2, 2DROP, ROLL, 0x01
		addi sp, sp, 16
		tail NEXT

		CODEHEADERZ SPGET, SP@, DROP2, 0x01
		# ( --- addr)
		mv a0, sp		#stack pointer before we do this operation
		addi sp, sp, -8
		sd a0, 0(sp)
		tail NEXT

		CODEHEADERZ SPSET, SP!, SPGET, 0x01
		# stack pointer reset!
		#(addr --- ?)
		ld a0, 0(sp)
		mv sp, a0
		tail NEXT

		CODEHEADERZ RPGET, RP@, SPSET, 0x01
		#( -- addr)
		addi sp, sp, -8
		sd s9, 0(sp)
		tail NEXT

		CODEHEADERZ RPSET, RP!, RPGET, 0x01
		# resets R stack
		# (addr ---)
		ld a0, 0(sp)
		addi sp, sp, 8
		mv s9, a0
		tail NEXT

		CODEHEADER SQUARE, RPSET, 0x01
		ld t0, 0(sp)
		mul t1, t0, t0
		sd t1, 0(sp)
		tail NEXT

		CODEHEADER CUBE, SQUARE, 0x01
		ld t0, 0(sp)
		mul t1, t0, t0
		mul t1, t0, t1
		sd t1, 0(sp)
		tail NEXT

                CODEHEADERZ NIP2, 2NIP, CUBE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		addi sp, sp, 16
                tail NEXT

		CODEHEADERZ QDUP, ?DUP, NIP2, 0x01
		#(x -- 0 | xx)
		ld t0, 0(sp)
		beqz t0, qdup_zero
		addi sp, sp, -8
		sd t0, 0(sp)
  qdup_zero:
		tail NEXT

                CODEHEADERZ DUP2,  2DUP, QDUP, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, -16
		sd t1, 8(sp)
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ OVER2, 2OVER, DUP2, 0x01
		ld t2, 16(sp)
		ld t3, 24(sp)
		addi sp, sp, -16
		sd t3, 8(sp)
		sd t2, 0(sp)
                tail NEXT

                CODEHEADERZ TUCK2, 2TUCK, OVER2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		ld t3, 24(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		sd t3, 8(sp)
		sd t2, 0(sp)
		addi sp, sp, -16
		sd t1, 8(sp)
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ SWAP2, 2SWAP, TUCK2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		ld t3, 24(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		sd t3, 8(sp)
		sd t2, 0(sp)
                tail NEXT

                CODEHEADERZ ROT2, 2ROT, SWAP2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		ld t3, 24(sp)
		ld t4, 32(sp)
		ld t5, 40(sp)
		sd t3, 40(sp)
		sd t2, 32(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		sd t5, 8(sp)
		sd t4, 0(sp)
                tail NEXT


                CODEHEADER DUP, ROT2, 0x01
		ld t0, 0(sp)
		addi sp, sp, -8
		sd t0, 0(sp)
                tail NEXT
