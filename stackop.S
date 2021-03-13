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


                CODEHEADER DUP, PICK, 0x01
                POP t0
                PUSH t0
                PUSH t0                     #duplicate stack
                tail NEXT
