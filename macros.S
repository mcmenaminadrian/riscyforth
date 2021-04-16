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

.macro COLON Name
      addi s9, s9, -STACKOFFSET
      sw s7, 0(s9)
      la s8, COLON_\Name
      mv s7, s8
      tail NEXT
COLON_\Name:
.endm


.macro CODEHEADER Name, PrevName, flags
.balign 8
TIL_\Name:
        .4byte  \flags
WA_\Name:
        .4byte  \Name
ptr_\PrevName:
        .4byte TIL_\PrevName
length_ASCII_\Name:
        .4byte (end_\Name - beg_\Name)
beg_\Name:
        .ascii "\Name"
end_\Name:
        .fill (24 - (end_\Name - beg_\Name)), 1, 0xFF
\Name: 
.endm

.macro CODEEND Name, flags
.balign 8
TIL_\Name:
        .4byte  \flags
WA_\Name:
        .4byte  \Name
ptr_NULL:
        .4byte 0x0
length_ASCII_\Name:
        .4byte end_\Name - beg_\Name
beg_\Name:
        .ascii "\Name"
end_\Name:
        .fill (24 - (end_\Name - beg_\Name)), 1, 0xFF
\Name:
.endm


.macro WRITECR
  addi a0, zero, 1
  addi a1, zero, 0x0D
  PUSH a1
  mv a1, sp
  addi a2, zero, 1
  addi a7, zero, 64
  ecall
  POP zero
.endm

.macro WRITECHAR char
  addi a1, zero, \char
  addi a0, zero, 1
  PUSH a1
  mv a1, sp
  addi a2, zero , 1
  addi a7, zero, 64
  ecall
  POP zero
.endm

.macro WRITESTRINGR stringReg, lenReg
  li a0, 1
  mv a1, \stringReg
  mv a2, \lenReg
  addi a7, zero, 64
  ecall
.endm


.macro PRINT string
  la a0, \string
  call puts
.endm

.macro GETIN
    mv a0, zero
    la a1, stdinopen
    call fdopen
.endm

.macro WINDSTACK
    addi sp, sp, -STACKWINDUP
.endm

.macro UNWINSTACK
    addi sp, sp, STACKWINDUP
.endm

.macro MARKINPUTBUFFER, ADDRESS
    la t0, \ADDRESS
    addi t1, zero, 0x0A
    sw t1, 0(t0)
.endm
