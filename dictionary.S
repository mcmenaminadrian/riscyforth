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
                j getstdin

#s8 -   Instruction register (I)
#s9 -   Word Address (WA)
#s10 -  Code Address (CA)
#s11 -  Return Stack (RS)

  COLON:
               PUSHI
               mv s8, s9
               j NEXT

  SEMI:       
              .word SEMIaddr
              .align 3
  SEMIaddr:
              POPI

  NEXT:
              lw s8, 0(s9)
              add s9, s9, 4

  RUN:
              lw s10, 0(s9)
              addi s9, s9, 4
              jalr x0, s10, 0

  EXECUTE:
              POP s10
              j RUN

                

DICTIONARY:
            CODEHEADER OuterLoop, GetStdIn, 0x0
            .word Prompt
            .word GetStdIn
            .word GetNextLine




  tokenize:     
                sub t5, t0, t6  #t5 length of token
                ori a0, x0, 1
                la a1, token_is
                la a2, token_is_len
                PUSH t5
                PUSH t3
                PUSH t4
                PUSH t6
                jal write
                POP t6
                POP t4
                POP t3
                POP t5
                ori a0, x0, 1
                mv a1, t6
                mv a2, t5
                PUSH t4
                PUSH t0
                PUSH t3
                PUSH t2
                jal write
                WRITECR
                WRITECHAR 0x0A
                POP t2
                POP t3
                POP t0
                POP t4
                beq t4, x0, keep_parsing
                addi sp, sp, 0x200
                j next_line
keep_parsing:   addi t0, t0, 1
                j check_start


