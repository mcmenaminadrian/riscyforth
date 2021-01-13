#         RISCYFORTH dictionary
###############################

.align 3


  fetch_line:
#get the file pointers for stdin, stdout
                or a0, x0, x0
                la a1, stdinopen
                call fdopen
                pushdata a0
                ori a0, x0, 1
                la a1, stdoutopen
                call fdopen
                pushdata a0
#now get a line
  next_line:    popdata a1
                popdata a0
                pushdata a0
                pushdata a1
                mv a2, a0
                la a0, input_buffer
                la a1, buffer_len
                jal fgets
#a2 now holds number of characters
#a0 holds buffer address
                add a2, a2, a0
                add a2, a2, -1
                mv t0, a0
                or t4, x0, x0 #t4 flags end of line
                ori t2, x0, 0x20
                ori t3, x0, 0x0D
  check_start:
                lb t1, 0(t0)
                beq t1, t3, next_line
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
                sub t5, t0, t6
                la a0, token_is
                pushdata t5
                pushdata t3
                pushdata t4
                pushdata t6
                jal printf
                popdata t6
                popdata t4
                popdata t3
                popdata t5
                la a0, 1
                mv a1, t6
                mv a2, t5
                pushdata t4
                pushdata t0
                pushdata t3
                pushdata t2
                jal write
                popdata t2
                popdata t3
                popdata t0
                popdata t4
                popdata a1
                pushdata a1
                mv a0, t3
                pushdata t4
                pushdata t0
                pushdata t3
                pushdata t2
                jal putc
                popdata t2
                popdata t3
                popdata t0
                popdata t4
                bne t4, x0, next_line
                addi t0, t0, 1
                j check_start


