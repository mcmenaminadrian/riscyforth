#     RISCYFORTH macros


.equ  OUTREG,  0x404
.equ  NAMELEN, 0x07

.macro pushdata register
        addi s11, s11, -4
        sw  \register, 0(x11)
.endm

.macro popdata register
        lw \register, 0(x11)
        addi s11, s11, 4
.endm

.macro pushcall register
        addi s10, s10, -4
        sw  \register, 0(x10)
.endm

.macro popcall register
        lw \register, 0(x10)
        addi s10, s10, 4
.endm

.macro output stringaddr, stringlen
        pushdata t3
        la t3, \stringaddr
        pushdata t4
        la t4, \stringlen
        pushdata t2
loopoutout:
        beq x0, t4, endoutput
        lb t2, 0(t3)
        csrw OUTREG, t2
        addi t3, t3, 1
        addi t4, t4, -1
        j loopoutput
endoutput
        popdata t2
        popdata t4
        popdata t3
.endm

.macro codeheader Name, PrevName
start_\Name:
        .byte beg_\Name - end_\Name
beg_\Name:
        .ascii "\Name\0\0"
end_\Name:
        .align 3
next_\Name:
        .word start_\PrevName
\Name:  .word + 4
.endm

.macro DONEXT
        lw s8, 0(s7)
        addi s7, s7, 4
        la t0, RUN
        jalr x0, t0, 0
.endm

