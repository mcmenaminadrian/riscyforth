#    RISCYFORTH macros

.equ STACKWINDUP, 0x208

.macro PUSH register
        addi sp, sp, -8
        sd  \register, 0(sp)
.endm

.macro POP register
        ld \register, 0(sp)
        addi sp, sp, 8
.endm

.macro PUSHRS register
        addi s11, s11, -8
        sd  \register, 0(s11)
.endm

.macro POPRS register
        ld \register, 0(s11)
        addi s11, s11, 8
.endm

.macro PUSHI
        addi s11, s11, -8
        sd s8, 0(s11)
.endm

.macro POPI
      ld s8, 0(s11)
      addi s11, s11, 4
.endm

.macro COLON Name
      addi s9, s9, -STACKOFFSET
      sd s7, 0(s9)
      la s8, COLON_\Name
      mv s7, s8
      tail NEXT
COLON_\Name:
.endm


.macro CODEHEADER Name, PrevName, flags
.balign 8
TIL_\Name:
        .8byte  \flags
WA_\Name:
        .8byte  \Name
ptr_\PrevName:
        .8byte TIL_\PrevName
length_ASCII_\Name:
        .8byte (end_\Name - beg_\Name)
beg_\Name:
        .ascii "\Name"
end_\Name:
        .fill (24 - (end_\Name - beg_\Name)), 1, 0xFF
\Name: 
.endm

.macro CODEEND Name, flags
.balign 8
TIL_\Name:
        .8byte  \flags
WA_\Name:
        .8byte  \Name
ptr_NULL:
        .8byte 0x0
length_ASCII_\Name:
        .8byte end_\Name - beg_\Name
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
    sd t1, 0(t0)
.endm

.macro TRANSITION_PROLOGUE
			addi sp, sp, -56
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			sd s5, 40(sp)
			sd s6, 48(sp)
  .endm

  .macro TRANSITION_EPILOGUE
			ld s6, 48(sp)
			ld s5, 40(sp)
			ld s4, 32(sp)
			ld s3, 24(sp)
			ld s2, 16(sp)
			ld s1, 8(sp)
			ld s0, 0(sp)
			addi sp, sp, 56
  .endm

  .macro SETUP_CONDITIONAL_CALL
			la a0, DECIDESTACKB
			ld a0, 0(a0)
			la a2, DECIDESTACKP
			ld a1, 0(a2)
  .endm

