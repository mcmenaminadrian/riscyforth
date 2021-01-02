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
      addi s11, s11, -4
      la t3, intro_msg
      sw t3, 0(s11)
      addi s11, s11, -4
      la t3, len_intro_msg
      sw t3, 0(s11)
      la t3, cheat
      jalr x0, t3, 0

  colon:
      addi s10, s10, -4
      sw s7, 0(s10)
      or s7, x0, s8
      la t1, next
      jalr x0, t1, 0
  
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

  OUTPUTTEXT:
      .byte 10
      .ascii "OUTPUT"
      .word OUTPUTTEXT
      .align 3
      .word + 4
cheat:
      la t4, next
      lw t1, 0(s11)
      addi s11, s11, 4  #length
      lw t2, 0(s11)
      addi s11, s11, 4  #pointer to text
oloops:     
      beq x0, t1, oloope
      lb t3, 0(t2)
      csrw 0x404, t3
      addi t2, t2, 1
      addi t1, t1, -1
      j oloops
oloope:
      jalr x0, t4, 0



.data

intro_msg: .ascii "Welcome to RISCYFORTH\n"
.equ len_intro_msg, . - intro_msg
