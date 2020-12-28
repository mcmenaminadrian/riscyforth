#    TIL for RISC-V
#    Copyright Adrian McMenamin <adrianmcmenamin@gmail.com>, 2020
#    Licensed under GPL v2 

  
#    TIL for RISC-V
#    Copyright Adrian McMenamin <adrianmcmenamin@gmail.com>, 2020
#    Licensed under GPL v2 

  
  .equ BOTTOM_CALLSTACK, 0xAFFFFFFF
  .equ BOTTOM_DATASTACK, 0x9FFFFFFF
  .equ DICTIONARY,       0x70000
  
  
  .global __start
  .text
  .align 2
  __start:   
      #s10 holds callstack pointer
      #s11 holds datastack pointer 
      li s10, BOTTOM_CALLSTACK
      li s11, BOTTOM_DATASTACK
      #s9 holds the dictionary pointer
      lui s9, DICTIONARY
      
      #s8 holds instruction address
      #s7 holds word address
      #s6 holds the code address
      
      
  colon:
      sw s8, 0(s10)
      addi s10, x0, -4
      or s8, x0, s7
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
      
  
