#         RISCYFORTH dictionary
###############################

.align 3


fetch_line:
                la t0, input_buffer
  fetch_char:   pushdata t0
                jal getchar
                popdata t0
                sb a0, 0(t0)
                pushdata t0
                pushdata a0
                jal puts
                popdata a0
                popdata t0
                la t1, 0x0D
                beq a0, t1, line_out
                addi t0, t0, 1
                la t2, buffer_len - 1
                bne t0, t2, fetch_char
                sb t1, 1(t0)
  line_out:     la a0, line_msg
                jal printf
                la a0, input_buffer
                jal printf
                j fetch_line


