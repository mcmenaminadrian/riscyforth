#Stack operations


                CODEHEADER SWAP, BYE, 0x01
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
                POP t0
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

                CODEHEADER BACKROT, TUCK, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		sd t0, 16(sp)
		sd t2, 8(sp)
		sd t1, 0(sp)
                tail NEXT

                CODEHEADER PICK, BACKROT, 0x01
		ld t0, 0(sp)
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

                CODEHEADER DROP2, ROLL, 0x01
                COLON DROP2
                .8byte WA_DROP
                .8byte WA_DROP
                .8byte WA_SEMI

                CODEHEADER NIP2, DROP2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		addi sp, sp, 16
                tail NEXT

                CODEHEADER DUP2, NIP2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, -16
		sd t1, 8(sp)
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER OVER2, DUP2, 0x01
		ld t2, 16(sp)
		ld t3, 24(sp)
		addi sp, sp, -16
		sd t3, 8(sp)
		sd t2, 0(sp)
                tail NEXT

                CODEHEADER TUCK2, OVER2, 0x01
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

                CODEHEADER SWAP2, TUCK2, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		ld t3, 24(sp)
		sd t1, 24(sp)
		sd t0, 16(sp)
		sd t3, 8(sp)
		sd t2, 0(sp)
                tail NEXT

                CODEHEADER ROT2, SWAP2, 0x01
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
		sd t4, 8(sp)
		sd t5, 0(sp)
                tail NEXT


                CODEHEADER DUP, ROT2, 0x01
		ld t0, 0(sp)
		addi sp, sp, -8
		sd t0, 0(sp)
                tail NEXT
