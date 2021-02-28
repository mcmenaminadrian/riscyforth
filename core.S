#         RISCYFORTH dictionary
###############################

.balign 8
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
  OLSEMI:
                addi s9, s9, -8
                la t0, outer_loop
                sw t0, 0(s9)

  NEXT:
                lw s8, 0(s9)
                addi s9, s9, 8
                lw s10, 0(s8)                       #s10 holds code address now
                addi s8, s8, 4                       #get next word address into s8
                addi s9, s9, -8
                sw s8, 0(s9)                        #back on the stack
 RUN:
                mv t0, s10
                addi s10, s10, 4
                jalr zero, t0, 0 
 EXECUTE:                                           #execute the next command on the stack
                lw s8, 0(s9)
                addi s9, s9, 8
                lw t0, 0(s8)
                jalr zero, t0, 0
                

#s9 <- instruction stack (off the stack)
#s8 <- instruction register
#s10 <-word address register

