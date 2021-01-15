#         RISCYFORTH dictionary
###############################

.align 3
  getstdin:     mv a0, x0
                la a1, stdinopen
                call fdopen
                pushdata a0
  next_line:
                popdata a2
                pushdata a2
                addi sp, sp, -0x200
                mv a0, sp
                addi a1, x0, 0x1F0
                jal fgets #a0 buffer address a2 number of characters
                add a2, a2, a0
                add a2, a2, -1 #a2 points to end of line
                mv t0, a0
                mv t4, x0 #t4 flag: end of line
                ori t2, x0, 0x20 #space
                ori t3, x0, 0x0A #LF
  check_start:
                lb t1, 0(t0)
                bne t1, t3, further_check
                addi sp, sp, 0x200
                j next_line
  further_check:                
                bne t1, t2, advance_start
                addi t0, t0, 1
                j check_start
  advance_start:
                mv t6, t0 #t6 marks start of token
  move_along:
                addi t0, t0, 1
                beq a2, t0, end_of_line
                lb t1, 0(t0)
                beq t1, t3, end_of_line
                beq t1, t2, tokenize
                j move_along
  end_of_line:  ori t4, x0, 1

  tokenize:     
                sub t5, t0, t6  #t5 length of token
                ori a0, x0, 1
                la a1, token_is
                la a2, token_is_len
                pushdata t5
                pushdata t3
                pushdata t4
                pushdata t6
                jal write
                popdata t6
                popdata t4
                popdata t3
                popdata t5
                ori a0, x0, 1
                mv a1, t6
                mv a2, t5
                pushdata t4
                pushdata t0
                pushdata t3
                pushdata t2
                jal write
                writeCR
                writeCHAR 0x0A
                popdata t2
                popdata t3
                popdata t0
                popdata t4
                beq t4, x0, keep_parsing
                addi sp, sp, 0x200
                j next_line
keep_parsing:   addi t0, t0, 1
                j check_start


