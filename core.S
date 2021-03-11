#         RISCYFORTH dictionary
###############################
                #s9 as RS
                #s8 as WA
                #s7 as I
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
                sw zero, OKSTATUS, t0

                sw zero, TOKEN_START, t0
                sw zero, TOKEN_END, t0
                addi t1, zero, 10                   #decimal as start-up base
                sw t1, CURRENT_BASE, t0
  
                la s7, outer_loop                   #set instruction register to start of outer loop

  NEXT:
                lw s8, 0(s7)                        #word address register takes content of next secondary
                addi s7, s7, 4                      #next secondary along
  
  RUN:
                lw t0, 0(s8)                        #extract first instruction address of primative
                addi s8, s8, 4                      #increment WA
                jalr zero, t0, 0                    #run the code    

 EXECUTE:                                           #execute the next command on the stack
               la s7, outer_loop_tokenize
               POP s8
               j RUN

#s9 <- instruction stack (off the stack)
#s8 <- instruction register
#s10 <-word address register

