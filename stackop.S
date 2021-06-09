#Stack operations


                CODEHEADER SWAP, BYE, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		sw t1, 0(sp)
		sw t0, 8(sp)
                tail NEXT

                CODEHEADER ROT, SWAP, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		lw t2, 16(sp)
		sw t1, 16(sp)
		sw t0, 8(sp)
		sw t2, 0(sp)
                tail NEXT

                CODEHEADER DROP, ROT, 0x01
                POP t0
                tail NEXT

                CODEHEADER NIP, DROP, 0x01
		lw t0, 0(sp)
		sw t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER OVER, NIP, 0x01
		lw t1, 8(sp)
		addi sp, sp, -8
		sw t1, 0(sp)
                tail NEXT

                CODEHEADER TUCK, OVER, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		sw t0, 8(sp)
		sw t1, 0(sp)
		addi sp, sp, -8
		sw t0, 0(sp)
                tail NEXT

                CODEHEADER BACKROT, TUCK, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		lw t2, 16(sp)
		sw t0, 16(sp)
		sw t2, 8(sp)
		sw t1, 0(sp)
                tail NEXT

                CODEHEADER PICK, BACKROT, 0x01
		lw t0, 0(sp)
                POP t0
                li t1, STACKOFFSET
                mul t2, t0, t1
                add t3, sp, t2
                lw t0, 0(t3)
		sw t0, 0(sp)
                tail NEXT

                CODEHEADER ROLL, PICK, 0x01
                POP t0
                li t1, STACKOFFSET
                mul t2, t0, t1
                add t3, sp, t2
                lw t1, 0(t3)
  roll_replace:
                beq t0, zero, roll_place_selected
                lw t2, -STACKOFFSET(t3)
                sw t2, 0(t3)
                addi t3, t3, -STACKOFFSET
                add t0, t0, -1
                j roll_replace
  roll_place_selected:
                sw t1, 0(sp)
                tail NEXT

                CODEHEADER DROP2, ROLL, 0x01
                COLON DROP2
                .4byte WA_DROP
                .4byte WA_DROP
                .4byte WA_SEMI

                CODEHEADER NIP2, DROP2, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		sw t1, 24(sp)
		sw t0, 16(sp)
		addi sp, sp, 16
                tail NEXT

                CODEHEADER DUP2, NIP2, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		addi sp, sp, -16
		sw t1, 8(sp)
		sw t0, 0(sp)
                tail NEXT

                CODEHEADER OVER2, DUP2, 0x01
		lw t2, 16(sp)
		lw t3, 24(sp)
		addi sp, sp, -16
		sw t3, 8(sp)
		sw t2, 0(sp)
                tail NEXT

                CODEHEADER TUCK2, OVER2, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		lw t2, 16(sp)
		lw t3, 24(sp)
		sw t1, 24(sp)
		sw t0, 16(sp)
		sw t3, 8(sp)
		sw t2, 0(sp)
		addi sp, sp, -16
		sw t1, 8(sp)
		sw t0, 0(sp)
                tail NEXT

                CODEHEADER SWAP2, TUCK2, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		lw t2, 16(sp)
		lw t3, 24(sp)
		sw t1, 24(sp)
		sw t0, 16(sp)
		sw t3, 8(sp)
		sw t2, 0(sp)
                tail NEXT

                CODEHEADER ROT2, SWAP2, 0x01
		lw t0, 0(sp)
		lw t1, 8(sp)
		lw t2, 16(sp)
		lw t3, 24(sp)
		lw t4, 32(sp)
		lw t5, 40(sp)
		sw t3, 40(sp)
		sw t2, 32(sp)
		sw t1, 24(sp)
		sw t0, 16(sp)
		sw t4, 8(sp)
		sw t5, 0(sp)
                tail NEXT


                CODEHEADER DUP, ROT2, 0x01
		lw t0, 0(sp)
		addi sp, sp, -8
		sw t0, 0(sp)
                tail NEXT
