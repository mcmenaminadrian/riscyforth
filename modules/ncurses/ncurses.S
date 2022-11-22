# ncurses module
# copyright, Adrian McMenamin, (c) 2022
# reuse licensed under V2 of the GNU GPL
  .include "../../macros.S"
  .section .bss
    .comm NEXTMOD, 8
    .comm LOCAL_INPUT_START, 8
    .comm LOCAL_INPUT_END, 8
    .comm STDSCR, 8

  .section .text
  .balign 8

	CODEEND INITSCR, 0x01
	#(--)
	call initscr
	la t0, STDSCR			#store stdscr
	sd a0, 0(t0)
	TAILMOD t1

	CODEHEADER PRINTW, INITSCR, 0x01
	#(addr --)
	ld a0, 0(sp)
	addi sp, sp, 8
	call printw
	TAILMOD t1

	CODEHEADER GETCH, PRINTW, 0x01
	#(--)
	call getch
	TAILMOD t1

	CODEHEADER REFRESH, GETCH, 0x01
	#(-- n)
	call refresh
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER GETSTDSCR, REFRESH, 0x01
	#(-- n)
	la a0, STDSCR
	ld a1, 0(a0)
	addi sp, sp, -8
	sd a1, 0(sp)
	TAILMOD t1

	CODEHEADER NOECHO, GETSTDSCR, 0x01
	#(--)
	call noecho
	TAILMOD t1

	CODEHEADER RAW, NOECHO, 0x01
	#(--)
	call raw
	TAILMOD t1

	CODEHEADER KEYPADSTD, RAW, 0x01
	#(--)
	la t0, STDSCR
	ld a0, 0(t0)
	li a1, 0x01		#TRUE
	call keypad
	TAILMOD t1

	CODEHEADER KEYPAD, KEYPADSTD, 0x01
	#(n n --)
	ld a0, 8(sp)
	ld a1, 0(sp)
	addi sp, sp, 16
	call keypad
	TAILMOD t1

	CODEHEADER ATTRON, KEYPAD, 0x01
	#(n --)
	POP a0
	call attron
	TAILMOD t1

	CODEHEADER ATTROFF, ATTRON, 0x01
	#(n --)
	POP a0
	call attroff
	TAILMOD t1

	CODEHEADER PRINTWFMT, ATTROFF, 0x01
	#(addr n --)
	ld a0, 8(sp)
	ld a1, 0(sp)
	addi sp, sp, 16
	call printw
	TAILMOD t1
	
	CODEHEADER ENDWIN, PRINTWFMT, 0x01
	#(--)
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
