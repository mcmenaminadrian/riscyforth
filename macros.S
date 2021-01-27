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
        nop
TIL_\Name:
        .4byte  \flags
        .4byte  \Name
length_ASCII_\Name:
        .4byte ptr_\PrevName - beg_\Name
beg_\Name:
        .ascii "\Name"
ptr_\PrevName:
        .4byte TIL_\PrevName
        .balign 8
\Name: 
.endm

.macro DONEXT
        lw s8, 0(s7)
        addi s7, s7, 4
        la t0, RUN
        jalr x0, t0, 0
.endm


.macro CODEEND Name, flags
        nop
TIL_\Name:
        .4byte  \flags
        .4byte  \Name
length_ASCII_\Name:
        .4byte ptr_NULL - beg_\Name
beg_\Name:
        .ascii "\Name"
ptr_NULL:
        .4byte 0x0
        .balign 8 
\Name:
.endm


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

.macro GETIN
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
