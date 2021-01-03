#####################################################################################
#           RISCYFORTH                                                              #
#           TIL for RISC-V                                                          #
#           Copyright (c) Adrian McMenamin <adrianmcmenamin@gmail.com> 2020, 2021   #
#           Licensed for resuse under version 2 of the GPL                          #
#                                                                                   #
#           Please note this is experimental code only                              #
#####################################################################################


  .equ          CALLSTACK,    0xA1000
  .equ          DATASTACK,    0xA0000
  .equ          DICTIONARY,   0x70000



  .text
  .align 3
  .global _start


  _start:
                la s10, CALLSTACK
                la s11, DATASTACK
                la s9,  DICTIONARY
                la t0, STARTUP
                jalr x0, t0, 0

   .include "macros.S"
   .include "dictionary.S"


   .data
   arith_msg: .ascii "RESULT IS: "
   .equ len_arith_msg, . - arith_msg

