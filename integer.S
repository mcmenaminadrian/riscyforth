#Simple integer calculations

                CODEHEADER ADD, 1, 0x01
                POP a0
                POP a1
                add t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER MULTIPLY, ADD, 0x01
                POP a0
                POP a1
                mul t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER DIVIDE, MULTIPLY, 0x01
                POP a1
                POP a0
                div t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER SUBTRACT, DIVIDE, 0x01
                POP a1
                POP a0
                sub t0, a0, a1
                tail NEXT


#Update this to point to the last (first) entry

.equ           dictionary, TIL_SUBTRACT

