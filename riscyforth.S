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
  .equ		BIGSPACE,      	0x100000	#1MB
  .equ		BIGGERSPACE,    0x200000	#2MB
  .equ		CONDITIONALBLK, 180		#size of if/else block
  .equ		CONDITIONALSTK, 0x28		#size of conditional stack entry
  .equ		DATASPACEMAN, 	0x14000		#to manage memory allocation lists
  .equ		PAGESIZE,	0x1000



   .bss
   .comm INPUT_BUFFER, BUFFERLEN
   .comm EXPANDED_BUFFER, BUFFERLEN
   .comm SCRATCH_PAD, SYSTEMAREA
   .comm NEWWORDENTRY, ADDRWIDTH
   .comm CREATEFLAG, ADDRWIDTH
   .comm OKSTATUS, ADDRWIDTH
   .comm TOKEN_START, ADDRWIDTH
   .comm TOKEN_END, ADDRWIDTH
   .comm CURRENT_BASE, ADDRWIDTH
   .comm INPUT_START, ADDRWIDTH
   .comm INPUT_END, ADDRWIDTH
   .comm CALLSTACK, BIGSPACE
   .comm STACK, BIGSPACE
   .comm VARIABLES, BIGSPACE
   .comm CONSTANTS, BIGSPACE
   .comm TOP_VARS, ADDRWIDTH
   .comm BOTTOM_VARS, ADDRWIDTH
   .comm TOP_CONS, ADDRWIDTH
   .comm BOTTOM_CONS, ADDRWIDTH
   .comm dictionary, ADDRWIDTH 
   .comm newdictionary, ADDRWIDTH
   .comm inputfileptr, ADDRWIDTH
   .comm createwritepoint, ADDRWIDTH
   .comm DECIDESTACKP, ADDRWIDTH
   .comm DECIDESTACKB, ADDRWIDTH
   .comm VARIABLEFLAG, ADDRWIDTH
   .comm INFILELOAD, ADDRWIDTH
   .comm LOADLINESETUP, ADDRWIDTH
   .comm LOADINGFILE, ADDRWIDTH
   .comm FILEMEMORYADDR, ADDRWIDTH
   .comm STACKTOP, ADDRWIDTH
   .comm datamanagement, ADDRWIDTH
   .comm recycleallot, ADDRWIDTH
   .comm recyclewatermark, ADDRWIDTH
   .comm dataspace, ADDRWIDTH
   .comm dataspaceptr, ADDRWIDTH
   .comm INDOES, ADDRWIDTH
   .comm INPPONE, ADDRWIDTH
   .comm MULTILINE, ADDRWIDTH
   .comm PICTUREDN, 0x10
   #for debugging
   .comm CYCLESTART, ADDRWIDTH
   .comm CYCLECOUNT, ADDRWIDTH
   .comm CYCLEPINGS, ADDRWIDTH


   .data
   welcome_msg:   	.asciz "RISCYFORTH - Copyright Adrian McMenamin 2020 - 2022"
   riscy_forth0:  	.asciz "*******************************************************************************"
   riscy_forth1:  	.asciz "RISCYFORTH is a FORTH for RISC-V devices."
   riscy_forth2:  	.asciz "To see supported words type 'WORDS'."
   riscy_forth3:	.asciz "==============================================================================="
   riscy_forth4:  	.asciz "RISCYFORTH is licenced under version 2 of the GNU General Public Licence."
   riscy_forth5:  	.asciz "See https://github.com/mcmenaminadrian/riscyforth.git"
   riscy_forthQ:  	.asciz "Exiting RISCYFORTH."
   Ok_msg:        	.asciz "OK"
   NotOk_msg:     	.ascii "Input fails with token: "
   .equ NOK_LEN,  24
   bad_colon:	  	.asciz "COLON command failed: please use a key word for your new command."
   zerolen_varin: 	.asciz "Could not read variable (or command) - zero length?"
   failed_varin:  	.asciz "Failed to read variable"
   Error_msg:     	.asciz "INTERPRETER FAILURE! System may be unstable."
   String_err:    	.asciz "ERROR: bad string."
   stdinopen:     	.asciz "r"
   stdoutopen:    	.asciz "w"
   decimalout:    	.asciz "%lld "
   hexout:        	.asciz "%#llX "
   octalout:      	.asciz "%lloo "
   badif:		.asciz "Bad IF"
   badelse:		.asciz "Bad ELSE"
   #ENVIRONMENT? strings
   eq_countedstrings:	.ascii "/COUNTED-STRING"
   .set eq_csLen, .-eq_countedstrings
   eq_hold:		.ascii "/HOLD"
   .set eq_holdLen, .-eq_hold
   eq_pad:		.ascii "/PAD"
   .set eq_padLen, .-eq_pad
   eq_addressunitbits:	.ascii "ADDRESS-UNIT-BITS"
   .set eq_aubLen, .-eq_addressunitbits
   eq_floored:		.ascii "FLOORED"
   .set eq_flooredLen, .-eq_floored
   eq_maxchar:		.ascii "MAX-CHAR"
   .set eq_maxcharLen, .-eq_maxchar
   eq_maxd:		.ascii "MAX-D"
   .set eq_maxdLen, .-eq_maxd
   eq_maxn:		.ascii "MAX-N"
   .set eq_maxnLen, .-eq_maxn
   eq_maxu:		.ascii "MAX-U"
   .set eq_maxuLen, .-eq_maxu
   eq_maxud:		.ascii "MAX-UD"
   .set eq_maxudLen, .-eq_maxud
   eq_returnstackcells:	.ascii "RETURN-STACK_CELLS"
   .set eq_rscLen, .-eq_returnstackcells
   eq_stackcells:	.ascii "STACK-CELLS"
   .set eq_scLen, .-eq_stackcells


  .text
  .align 3
  .globl main
  _start:
  main:
                la s10, STACK + BIGSPACE - STACKOFFSET
                la s9, CALLSTACK + BIGSPACE - STACKOFFSET
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
    .balign 8
    .include "load.S"
    .balign 8
    .include "coredefs.S"
    .balign 8
    .include "constant.S"
    .balign 8
    .include "memoryallocator.S"
    .balign 8
    .include "memory.S"
    .balign 8
    .include "utilities.S"
