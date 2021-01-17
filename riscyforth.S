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
                la a0, riscy_forth0
                jal puts
                la a0, riscy_forth0
                jal puts
                la a0, welcome_msg
                jal puts
                j launchRISCYFORTH

  


   .include "macros.S"
   .include "dictionary.S"


   .data
   input_scanfs: .asciz "%s"
   input_buffer: .ascii "                                                                                                                                                                                                                                                                                                                "
   .equ buffer_len, . - input_buffer    #guard against buffer over write

   welcome_msg: .asciz  "WELCOME TO RISCYFORTH - Copyright Adrian McMenamin 2020 - 2021"
   riscy_forth0: .asciz "*******************************************************************************"
   riscy_forth1: .asciz "RISCYFORTH is a threaded interpreted language closely based on FORTH."
   riscy_forth2: .asciz "Currently we are running in EXECUTE mode and anything you type will"
   riscy_forth3: .asciz "be executed as each line is entered."
   riscy_forth4: .asciz "RISCYFORTH is licenced under version 2 of the GNU General Public Licence."
   riscy_forth5: .asciz "See https://github.com/mcmenaminadrian/riscyforth.git"
   token_is:    .asciz "TOKEN IS: "
   .equ token_is_len, . - token_is
   stdinopen:   .asciz "r"
   stdoutopen:  .asciz "w"


