#####################################################################################
#           RISCYFORTH                                                              #
#           TIL for RISC-V                                                          #
#           Copyright (c) Adrian McMenamin <adrianmcmenamin@gmail.com> 2020, 2021   #
#           Licensed for resuse under version 2 of the GPL                          #
#                                                                                   #
#           As per the terms of the GPL no warranty is offered for this code        #
#####################################################################################


  .equ          SYSTEMAREA,   	0x100          	#for variables
  .equ          BUFFERLEN,    	0x200
  .equ          STACKOFFSET,   	0x08
  .equ		ADDRWIDTH,	0x08
  .equ          INSTWIDTH,     	0x04
  .equ          INSTWIDTH2,    	0x08
  .equ          INSTWIDTH3,    	0x0C
  .equ          INSTWIDTH4,    	0x10
  .equ          NAMEMAXLEN,    	0x18
  .equ		BIGSPACE,      	0x100000
  .equ		CONDITIONALBLK, 0x48		#size of if/else block
  .equ		CONDITIONALSTK, 0x28		#size of conditional stack entry




  .text
  .align 3
  .globl main
  _start:
  main:
                nop
                la t4, (VARIABLES + 0xFFFDC)
                la t3, BOTTOM_VARS
                sw t4, 0(t3)
                la t1, TOP_VARS
		addi t4, t4, 0x20
                sw t4, 0(t1)
                la s10, STACK + 0x7FFF8
                la s9, CALLSTACK + 0x7FFF8
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, riscy_forth0
                call puts
                la a0, welcome_msg
                call puts
                j launchRISCYFORTH

  


    .include "macros.S"
    .balign 8
    .include "core.S"
    .balign 8
    .include "basics.S"
    .balign 8
    .include "outerloop.S"
    .balign 8
    .include "transitions.S"
    .balign 8
    .include "search_create.S"
    .balign 8
    .include "decision.S"

   .bss
   .common INPUT_BUFFER, BUFFERLEN, 8
   .common EXPANDED_BUFFER, BUFFERLEN, 8
   .common SCRATCH_PAD, SYSTEMAREA, 8
   .common NEWWORDENTRY, 0x08, 0x08
   .common CREATEFLAG, 0x08, 0x08
   .common OKSTATUS, 0x08, 0x08
   .common TOKEN_START, 0x08, 0x08
   .common TOKEN_END, 0x08, 0x08
   .common CURRENT_BASE, 0x08, 0x08
   .common INPUT_START, 0x08, 0x08
   .common INPUT_END, 0x08, 0x08
   .common CALLSTACK, 0x80000, 0x08
   .common STACK, 0x80000, 0x08
   .common VARIABLES, BIGSPACE, 0x08
   .common TOP_VARS, 0x08, 0x08
   .common BOTTOM_VARS, 0x08, 0x08
   .common dictionary, 0x08, 0x08 
   .common newdictionary, 0x08, 0x08
   .common inputfileptr, 0x08, 0x08
   .common createwritepoint, 0x08, 0x08
   .common ifflag, 0x08, 0x08
   .common DECIDESTACKP, 0x08, 0x08
   .common DECIDESTACKB, 0x08, 0x08

   .data
   welcome_msg:   .asciz  "WELCOME TO RISCYFORTH - Copyright Adrian McMenamin 2020 - 2021"
   riscy_forth0:  .asciz "*******************************************************************************"
   riscy_forth1:  .asciz "RISCYFORTH is a threaded interpreted language closely based on FORTH."
   riscy_forth2:  .asciz "Currently we are running in EXECUTE mode and anything you type will"
   riscy_forth3:  .asciz "be executed as each line is entered."
   riscy_forth4:  .asciz "RISCYFORTH is licenced under version 2 of the GNU General Public Licence."
   riscy_forth5:  .asciz "See https://github.com/mcmenaminadrian/riscyforth.git"
   riscy_forthQ:  .asciz "Exiting RISCYFORTH."
   Ok_msg:        .asciz "OK"
   NotOk_msg:     .ascii "Input fails with token: "
   .equ NOK_LEN,  24
   bad_colon:	  .asciz "COLON command failed: please use a key word for your new command."
   zerolen_varin: .asciz "Could not read variable (or command) - zero length?"
   failed_varin:  .asciz "Failed to read variable"
   Error_msg:     .asciz "INTERPRETER FAILURE! System may be unstable."
   stdinopen:     .asciz "r"
   stdoutopen:    .asciz "w"
   decimalout:    .asciz "%lld "
   hexout:        .asciz "%#llX "
   octalout:      .asciz "%lloo "


