#         RISCYFORTH dictionary
###############################

.align 3

  launchRISCYFORTH:
                PRINT riscy_forth0
                PRINT riscy_forth1
                PRINT riscy_forth2
                PRINT riscy_forth3
                PRINT riscy_forth4
                PRINT riscy_forth5
                PRINT riscy_forth0
                PRINT riscy_forth0
                WRITECR
                WRITECHAR 0x0A
                WRITECR
                WRITECHAR 0x0A
                WRITECR
                WRITECHAR 0x0A

                sw zero, TOKEN_START, t0
                sw zero, TOKEN_END, t0
                addi t1, zero, 10                   #decimal as start-up base
                sw t1, CURRENT_BASE, t0
                add s9, s9, -8
                la s10, outer_loop
                lw s7, 0(s10)
                sw s7, 0(s9)
                add s9, s9, -8


  NEXT:         
                add s9, s9, 8
                lw s8, 0(s9)
                jalr x0, s8, 0
                addi s10, s10, 4
                lw s7, 0(s10)
                sw s7, 0(s9)
                add s9, s9, -8
                j NEXT

                

#s8 -   Instruction register (I)
#s9 -   Word Address (WA)
#s10 -  Code Address (CA)
#s11 -  Return Stack (RS)

#  COLON:
#               PUSHI
#               mv s8, s9
#               j NEXT
#
#  SEMI:       
#              .4byte SEMIaddr
#  SEMIaddr:
#              POPI
#
#  NEXT:
#              lw s8, 0(s9)
#              add s9, s9, 4
#
#  RUN:
#              lw s10, 0(s9)
#              addi s9, s9, 4
#              jalr x0, s10, 0

#  EXECUTE:
#              POP s10
#              j RUN

                

