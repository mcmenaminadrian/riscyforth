#   Riscyforth
#   TIL for RISC-V
#   Copyright Adrian McMenamin <adrianmcmenamin@gmail.com>, 2020
#   This code is for experimental purposes only
#
#   Licensed under version 2 of the GNU GPL


  .equ BOTTOM_CALLSTACK, 0xA1000    #4K Callstack
  .equ BOTTOM_DATASTACK, 0xA0000    #4K Datastack
  .equ DICTIONARY,       0x70000    #Command dictionary
  .equ REALSTACK,        0xA2000    #4K real stack





  .text

  .align 3
  .global _start
    _start:
    loadup:
      li s10, BOTTOM_CALLSTACK      #s10 callstack
      li s11, BOTTOM_DATASTACK      #s11 datastack
      li s9, DICTIONARY             #s9  dictionary
      li sp, REALSTACK
      la s8, semi                   #s8 word address
      la s7, semi + 4               #s7 instruction address
                                    #s6 code address
      
  colon:
      addi s10, s10, -4
      sw s7, 0(s10)
      or s7, x0, s8                
      j next
  
  semi:
      .word . + 4
      lw s8, 0(s10)
      addi s10, s10, 4
  next:
      lw s8, 0(s7)
      addi s7, s7, 4
  run:
      lw s6, 0(s8)
      addi s8, s8, 4
      jalr x0, s6, 0
