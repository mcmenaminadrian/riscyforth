#Stack operations


                CODEHEADER SWAP, BYE, 0x01
                POP t0
                POP t1
                PUSH t0
                PUSH t1
                tail NEXT

                CODEHEADER ROT, SWAP, 0x01
                POP t0
                POP t1
                POP t2
                PUSH t1
                PUSH t0
                PUSH t2
                tail NEXT

                CODEHEADER DROP, ROT, 0x01
                POP t0
                tail NEXT

                CODEHEADER NIP, DROP, 0x01
                POP t0
                POP t1
                PUSH t0
                tail NEXT

                CODEHEADER OVER, NIP, 0x01
                POP t0
                POP t1
                PUSH t1
                PUSH t0
                PUSH t1
                tail NEXT

                CODEHEADER TUCK, OVER, 0x01
                POP t0
                POP t1
                PUSH t0
                PUSH t1
                PUSH t0
                tail NEXT

                CODEHEADER BACKROT, TUCK, 0x01
                POP t0
                POP t1
                POP t2
                PUSH t0
                PUSH t2
                PUSH t1
                tail NEXT

                CODEHEADER PICK, BACKROT, 0x01
                POP t0
                li t1, STACKOFFSET
                mul t2, t0, t1
                add t3, sp, t2
                lw t0, 0(t3)
                PUSH t0
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
                POP t0
                POP t1
                POP t2
                POP t3
                PUSH t1
                PUSH t0
                tail NEXT

                CODEHEADER DUP2, NIP2, 0x01
                POP t0
                POP t1
                PUSH t1
                PUSH t0
                PUSH t1
                PUSH t0
                tail NEXT

                CODEHEADER OVER2, DUP2, 0x01
                POP t0
                POP t1
                POP t2
                POP t3
                PUSH t3
                PUSH t2
                PUSH t1
                PUSH t0
                PUSH t3
                PUSH t2
                tail NEXT

                CODEHEADER TUCK2, OVER2, 0x01
                POP t0
                POP t1
                POP t2
                POP t3
                PUSH t1
                PUSH t0
                PUSH t3
                PUSH t2
                PUSH t1
                PUSH t0
                tail NEXT

                CODEHEADER SWAP2, TUCK2, 0x01
                POP t0
                POP t1
                POP t2
                POP t3
                PUSH t1
                PUSH t0
                PUSH t3
                PUSH t2
                tail NEXT

                CODEHEADER ROT2, SWAP2, 0x01
                POP t0
                POP t1
                POP t2
                POP t3
                POP t4
                POP t5
                PUSH t3
                PUSH t2
                PUSH t1
                PUSH t0
                PUSH t4
                PUSH t5
                tail NEXT


                CODEHEADER DUP, ROT2, 0x01
                POP t0
                PUSH t0
                PUSH t0                     #duplicate stack
                tail NEXT
