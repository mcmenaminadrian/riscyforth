#   Riscyforth
#   TIL for RISC-V
#   Copyright Adrian McMenamin <adrianmcmenamin@gmail.com>, 2020
#   This code is for experimental purposes only
#
#   Licensed under version 2 of the GNU GPL


  .equ BOTTOM_CALLSTACK, 0xB0000    #4K Callstack
  .equ BOTTOM_DATASTACK, 0xA0000    #4K Datastack
  .equ DICTIONARY,       0x70000    #Command dictionary


  .text

  .align 2
  .global _start
    _start:
      nop
    loadup:
      li s10, BOTTOM_CALLSTACK      #s10 callstack
      li s11, BOTTOM_DATASTACK      #s11 datastack
      li s9, DICTIONARY            #s9  dictionary
      
      
  colon:
      addi s10, s10, -4
      sw s8, 0(s10)
      or s8, x0, s7               #s7 word address
      jal x0, next
  
  semi:
      .word semi
      lw s8, 0(s10)
      addi s10, x0, 4
  next:
      lw s7, 0(s8)
      addi s8, x0, 4
  run:
      lw s6, 0(s7)
      addi s7, x0, 4
      jalr x0, s7, 0
