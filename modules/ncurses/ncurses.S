# ncurses module
# copyright, Adrian McMenamin, (c) 2022
# reuse licensed under V2 of the GNU GPL
  .include "../../macros.S"
  .section .bss
    .comm NEXTMOD, 8
    .comm LOCAL_INPUT_START, 8
    .comm LOCAL_INPUT_END, 8

  .section .text
  .balign 8

	CODEEND INITSCR, 0x01
	call initscr
	TAILMOD t1

	CODEHEADER GETCH, INITSCR, 0x01
	call getch
	TAILMOD t1

	CODEHEADER REFRESH, GETCH, 0x01
	call refresh
	TAILMOD t1

	CODEHEADER ENDWIN, REFRESH, 0x01
	call endwin
	TAILMOD t1


  #initialisation code for this module
  starter_ncurses:
	PUSH ra
	call getNextAddress	#get the address for tail return
	la t0, NEXTMOD
	sd a0, 0(t0)		#store the tail return address
	la a0, INITSCR		#get address of this module
	addi a0, a0, -56
	PUSH a0
	li t3, 0xFFFFFFFFFFFFF000
	and a0, a0, t3
	li a1, 0x100
	li a2, 0x7	#rw permissions
	call mprotect
	POP a0
	addi a1, a0, 16
	PUSH a1
	call getDictionary
	POP a1
	sd a0, 0(a1)	#update lead word
	la a0, ENDWIN	#new end of dictionary
	addi a0, a0, -56
	call setDictionary	#return new tail of dictionary to caller
	#setup extension writing - commented out for now
#	la a0, WA_TWOLITERAL
#	la a1, extender_2literal
#	call  setExtenders
#	la a0, WA_TO
#	la a1, extender_2to
#	call setExtenders
	POP ra
	fence.i
	ret

.section .init_array
.balign 8
.8byte starter_ncurses
