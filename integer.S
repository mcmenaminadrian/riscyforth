#Simple integer calculations

                CODEHEADER ADD, 1
                POP a0
                POP a1
                add t0, a0, a1
                PUSH t0
                j NEXT

                CODEHEADER MULTIPLY, ADD
                POP a0
                POP a1
                mul t0, a0, a1
                PUSH t0
                j NEXT

                CODEHEADER DIVIDE, MULTIPLY
                POP a1
                POP a0
                div t0, a0, a1
                PUSH t0
                j NEXT

                CODEHEADER SUBTRACT, DIVIDE
                POP a1
                POP a0
                sub t0, a0, a1
                j NEXT


#Update this to point to the last (first) entry

.equ           dictionary, TIL_SUBTRACT

