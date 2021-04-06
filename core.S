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
                #clear variables stack
                la t1, TOP_VARS
                lw t2, 0(t1)
                li t3, 0x100000
  clean_var_stack:
                sw zero, 0(t2)
                addi t2, t2, -4
                addi t3, t3, -4
                bne zero, t3, clean_var_stack
                

                la t1, NEWWORDS
                sw t1, NEWWORDENTRY, t0
                sw zero, OKSTATUS, t0
                sw zero, CREATEFLAG, t0
                la t1, TIL_VARIABLE                   #start search from here
                sw t1, dictionary, t0

                sw zero, TOKEN_START, t0
                sw zero, TOKEN_END, t0
                addi t1, zero, 10                   #decimal as start-up base
                sw t1, CURRENT_BASE, t0
  
                la s7, outer_loop                   #set instruction register to start of outer loop

  NEXT:
                lw s8, 0(s7)                        #word address register takes content of next secondary
                addi s7, s7, INSTWIDTH              #next secondary along
  
  RUN:
                lw t0, 0(s8)                        #extract first instruction address of primative
                addi s8, s8, INSTWIDTH              #increment WA
                jalr zero, t0, 0                    #run the code    

 EXECUTE:                                           #execute the next command on the stack
               la s7, outer_loop_tokenize
               POP s8
               j RUN


