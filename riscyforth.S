#####################################################################################
#           RISCYFORTH                                                              #
#           TIL for RISC-V                                                          #
#           Copyright (c) Adrian McMenamin <adrianmcmenamin@gmail.com> 2020 - 2024  #
#           Licensed for resuse under version 2 of the GPL or any later version     #
#                                                                                   #
#           As per the terms of the GPL no warranty is offered for this code        #
#####################################################################################

.include "./riscylib/riscyvar.S"

   .bss
   .comm SOURCEID, ADDRWIDTH
   .comm NEWWORDENTRY, ADDRWIDTH
   .comm OKSTATUS, ADDRWIDTH
   .comm CALLSTACK, BIGSPACE
   .comm STACK, BIGSPACE
   .comm VARIABLES, BIGSPACE
   .comm CONSTANTS, BIGSPACE
   .comm TOP_VARS, ADDRWIDTH
   .comm BOTTOM_VARS, ADDRWIDTH
   .comm TOP_CONS, ADDRWIDTH
   .comm BOTTOM_CONS, ADDRWIDTH
   .comm inputfileptr, ADDRWIDTH
   .comm DECIDESTACKP, ADDRWIDTH
   .comm DECIDESTACKB, ADDRWIDTH
   .comm VARIABLEFLAG, ADDRWIDTH
   .comm datamanagement, ADDRWIDTH
   .comm recycleallot, ADDRWIDTH
   .comm recyclewatermark, ADDRWIDTH
   .comm dataspace, ADDRWIDTH
   .comm INDOES, ADDRWIDTH
   .comm INPPONE, ADDRWIDTH
   .comm PICTUREDN, 0x10
   .comm INEVAL, ADDRWIDTH
   .comm RESUME_AFTER_EVAL, ADDRWIDTH
   .comm termios, 64
   .comm oldtermios, 64
   .comm CYCLESTART, ADDRWIDTH
   .comm CYCLECOUNT, ADDRWIDTH
   .comm CYCLEPINGS, ADDRWIDTH
   .comm INPUT_START_RESTART, ADDRWIDTH
   .comm INPUT_DISPLACE_RESTART, ADDRWIDTH

   .data
   welcome_msg:   	.asciz "RISCYFORTH - Copyright Adrian McMenamin 2020 - 2024"
   riscy_forth0:  	.asciz "*******************************************************************************"
   riscy_forth1:  	.asciz "RISCYFORTH is a FORTH for RISC-V devices."
   riscy_forth3:	.asciz "==============================================================================="
   riscy_forth4:  	.asciz "RISCYFORTH is licenced under version 2 of the GNU General Public Licence or"
   riscy_forth4a:	.asciz "any later version at your discretion."
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
		# handle initial options
		ld a0, 0(sp)					# argc
		ld a1, 8(sp)					# points to first argv element
		call initriscyforth
                la s10, STACK + BIGSPACE - STACKOFFSET
                la s9, CALLSTACK + BIGSPACE - STACKOFFSET
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
    .include "newmemalloc.S"
    .balign 8
    .include "memory.S"
    .balign 8
    .include "utilities.S"
    .balign 8
    .include "termioscode.S"
