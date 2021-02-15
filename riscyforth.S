#####################################################################################
#           RISCYFORTH                                                              #
#           TIL for RISC-V                                                          #
#           Copyright (c) Adrian McMenamin <adrianmcmenamin@gmail.com> 2020, 2021   #
#           Licensed for resuse under version 2 of the GPL                          #
#                                                                                   #
#           Please note this is experimental code only                              #
#####################################################################################


  .equ          SYSTEMAREA,   0x100          #for variables
  .equ          BUFFERLEN,    0x200




  .text
  .align 3
  .globl main
  main:
                nop
                nop
                la s10, CALLSTACK
                la s9, STACKBASE
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, welcome_msg
                call puts
                j launchRISCYFORTH

  


    .include "macros.S"
    .balign 8
    .include "core.S"
    .balign 8
    .include "basics.S"
    .balign 8
    .include "outerloop.S"

   .bss
   .common INPUT_BUFFER, BUFFERLEN, 8
   .common SCRATCH_PAD, SYSTEMAREA, 8
   .common TOKEN_START, 0x04, 0x04
   .common TOKEN_END, 0x04, 0x04
   .common CURRENT_BASE, 0x04, 0x04
   .common INPUT_START, 0x04, 0x04
   .common INPUT_END, 0x04, 0x04
   .common CALLSTACK, 0x80000, 0x08
   .common STACKBASE, 0x80000, 0x08

   .data
   welcome_msg:   .asciz  "WELCOME TO RISCYFORTH - Copyright Adrian McMenamin 2020 - 2021"
   riscy_forth0:  .asciz "*******************************************************************************"
   riscy_forth1:  .asciz "RISCYFORTH is a threaded interpreted language closely based on FORTH."
   riscy_forth2:  .asciz "Currently we are running in EXECUTE mode and anything you type will"
   riscy_forth3:  .asciz "be executed as each line is entered."
   riscy_forth4:  .asciz "RISCYFORTH is licenced under version 2 of the GNU General Public Licence."
   riscy_forth5:  .asciz "See https://github.com/mcmenaminadrian/riscyforth.git"
   Ok_msg:        .asciz "OK"
   NotOk_msg:     .ascii "Input fails with token: "
   .equ NOK_LEN,  24
   Error_msg:     .asciz "INTERPRETER FAILURE! System may be unstable."
   stdinopen:     .asciz "r"
   stdoutopen:    .asciz "w"
   decimalout:    .asciz "%u"
   hexout:        .asciz "%#X"
   octalout:      .asciz "%uo"


