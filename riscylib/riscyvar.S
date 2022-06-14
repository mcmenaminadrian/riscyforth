#RISCYVAR.S - header file for shared library in RISCYFORTH
#Copyright (c) 2022 Adrian McMenamin, <adrianmcmenamin@gmail.com>
#Licenced for resuse under the terms of version 2 of the GNU GPL
#No warranties are are offered

#ifndef RISCY_VAR
#define RISCY_VAR


# Macros etc 

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

# extern variables for a BSS section 


.extern INPUT_BUFFER
.extern EXPANDED_BUFFER
.extern dictionary
.extern newdictionary
.extern createwritepoint
.extern TOKEN_START
.extern TOKEN_END
.extern INPUT_START
.extern INPUT_END
.extern LOADLINESETUP
.extern INFILELOAD
.extern FILEMEMORYADDR
.extern LOADINGFILE
.extern MULTILINE
.extern PULLINANOTHER
.extern SCRATCH_PAD
.extern CURRENT_BASE

#endif
