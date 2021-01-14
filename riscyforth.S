#####################################################################################
#           RISCYFORTH                                                              #
#           TIL for RISC-V                                                          #
#           Copyright (c) Adrian McMenamin <adrianmcmenamin@gmail.com> 2020, 2021   #
#           Licensed for resuse under version 2 of the GPL                          #
#                                                                                   #
#           Please note this is experimental code only                              #
#####################################################################################


  .equ          CALLSTACK,    0x21000
  .equ          DICTIONARY,   0x1F000



  .text
  .align 3
  .globl main
  main:

                la s10, CALLSTACK
                la a0, welcome_msg
                jal puts
                j getstdin

  


   .include "macros.S"
   .include "dictionary.S"


   .data
   input_scanfs: .asciz "%s"
   input_buffer: .ascii "                                                                                                                                                                                                                                                                                                                "
   .equ buffer_len, . - input_buffer    #guard against buffer over write

   welcome_msg: .asciz "WELCOME TO RISCYFORTH - Copyright Adrian McMenamin 2020 - 2021"
   token_is:    .asciz "TOKEN IS: "
   .equ token_is_len, . - token_is
   stdinopen:   .asciz "r"
   stdoutopen:  .asciz "w"


