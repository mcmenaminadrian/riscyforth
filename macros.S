#     RISCYFORTH macros


.equ  OUTREG,  0x404
.equ  NAMELEN, 0x07

.macro pushdata register
        addi sp, sp, -8
        sw  \register, 0(sp)
.endm

.macro popdata register
        lw \register, 0(sp)
        addi sp, sp, 8
.endm

.macro pushcall register
        addi s10, s10, -4
        sw  \register, 0(s10)
.endm

.macro popcall register
        lw \register, 0(s10)
        addi s10, s10, 4
.endm

.macro codeheader Name, PrevName
        .align 3
start_\Name:
        .byte beg_\Name - end_\Name
beg_\Name:
        .ascii "\Name\0"
end_\Name:
next_\Name:
        .align 3
        .word start_\PrevName
\Name:  .word . + 4

.endm

.macro DONEXT
        lw s8, 0(s7)
        addi s7, s7, 4
        la t0, RUN
        jalr x0, t0, 0
.endm

.macro writeCR
  addi a0, x0, 1
  addi a1, x0, 0x0D
  pushdata a1
  mv a1, sp
  addi a2, x0, 1
  jal write
  popdata x0
.endm

.macro writeCHAR char
  addi a1, x0, \char
  addi a0, x0, 1
  pushdata a1
  mv a1, sp
  addi a2, x0, 1
  jal write
  popdata x0
.endm

.macro writeSTRING stringAddr, length
  add a1, x0, \stringAddr
  add a0, x0, \length
  jal write
.endm

.macro PRINT string
  la a0, \string
  jal puts
.endm

