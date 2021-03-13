#Simple integer calculations

                CODEHEADER ADD, DOT, 0x01
                POP a0
                POP a1
                add t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER MUL, ADD, 0x01
                POP a0
                POP a1
                mul t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER DIV, MUL, 0x01
                POP a1
                POP a0
                div t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER SUB, DIV, 0x01
                POP a1
                POP a0
                sub t0, a0, a1
                PUSH t0
                tail NEXT

                CODEHEADER Q, SUB, 0x01
                PRINT riscy_forth0
                PRINT riscy_forthQ
                PRINT riscy_forth0
                tail exit



