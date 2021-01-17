#     RISCYFORTH macros

.equ STACKWINDUP, 0x208

.macro PUSH register
        addi sp, sp, -8
        sw  \register, 0(sp)
.endm

.macro POP register
        lw \register, 0(sp)
        addi sp, sp, 8
.endm

.macro PUSHRS register
        addi s11, s11, -4
        sw  \register, 0(s11)
.endm

.macro POPRS register
        lw \register, 0(s11)
        addi s11, s11, 4
.endm

.macro PUSHI
        addi s11, s11, -4
        sw s8, 0(s11)
.endm

.macro POPI
      lw s8, 0(s11)
      addi s11, s11, 4
.endm

.macro CODEHEADER Name, PrevName, flags
        .align 3
        .word  \flags
start_\Name:
        .byte beg_\Name - next_\Name
        .align 3
beg_\Name:
        .asciz "\Name"
next_\Name:
        .align 3
        .word start_\PrevName
\Name:  .word . + 4
        .align 3
.endm

.macro DONEXT
        lw s8, 0(s7)
        addi s7, s7, 4
        la t0, RUN
        jalr x0, t0, 0
.endm


.macro CODEEND Name, PrevName, flags
        .align 3
        .word  \flags
start_\Name:
        .byte beg_\Name - next_\Name
        .align 3
beg_\Name:
        .asciz "\Name"
next_\Name:
        .align 3
        .word 0x0
\Name:  .word . + 4
        .align 3



.macro WRITECR
  addi a0, x0, 1
  addi a1, x0, 0x0D
  PUSH a1
  mv a1, sp
  addi a2, x0, 1
  call write
  POP x0
.endm

.macro WRITECHAR char
  addi a1, x0, \char
  addi a0, x0, 1
  PUSH a1
  mv a1, sp
  addi a2, x0, 1
  call write
  POP x0
.endm

.macro writeSTRING stringAddr, length
  add a1, x0, \stringAddr
  add a0, x0, \length
  call write
.endm

.macro PRINT string
  la a0, \string
  call puts
.endm

.macro GETSTDIN
    mv a0, x0
    la a1, stdinopen
    call fdopen
.endm

.macro WINDSTACK
    addi sp, sp, -STACKWINDUP
.endm

.macro UNWINSTACK
    addi sp, sp, STACKWINDUP
.endm
