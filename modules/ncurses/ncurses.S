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

	CODEHEADER CLEAR, INITSCR, 0x01
	#( -- )
	call clear
	TAILMOD t1

	CODEHEADER NODELAYONSTD, CLEAR, 0x01
	#(-- n)
	mv a0, zero
	call timeout
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER NODELAYOFFSTD, NODELAYONSTD, 0x01
	#(-- n)
	li a0, -1
	call timeout
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER NEWWIN, NODELAYOFFSTD, 0x01
	#(height, width, starty, startx -- win)
	ld a0, 24(sp)
	ld a1, 16(sp)
	ld a2, 8(sp)
	ld a3, 0(sp)
	call newwin
	addi sp, sp, 24
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER WREFRESH, NEWWIN, 0x01
	#(n --)
	ld a0, 0(sp)
	addi sp, sp, 8
	call wrefresh
	TAILMOD t1

	CODEHEADER DELWIN, WREFRESH, 0x01
	#(n --)
	ld a0, 0(sp)
	addi sp, sp, 8
	call delwin
	TAILMOD t1

	CODEHEADER CURS_SET, DELWIN, 0x01
	#(n --_
	ld a0, 0(sp)
	addi sp, sp, 8
	call curs_set
	TAILMOD t1

	CODEHEADER CURS_INVIS, CURS_SET, 0x01
	#(--)
	li a0, 0
	call curs_set
	TAILMOD t1

	CODEHEADER CURS_NORMAL, CURS_INVIS, 0x01
	#(--)
	li a0, 1
	call curs_set
	TAILMOD t1

	CODEHEADER CURS_VVIS, CURS_NORMAL, 0x01
	li a0, 2
	call curs_set
	TAILMOD t1 

	CODEHEADER DEF_PROG_MODE, CURS_VVIS, 0x01
	#(--)
	call def_prog_mode
	TAILMOD t1

	CODEHEADER RESET_PROG_MODE, DEF_PROG_MODE, 0x01
	#(--)
	call reset_prog_mode
	TAILMOD t1

	CODEHEADER COLOR_BLACK, RESET_PROG_MODE, 0x01
	#(-- n)
	li a0, 0
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_RED, COLOR_BLACK, 0x01
	#(-- n)
	li a0, 1
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_GREEN, COLOR_RED, 0x01
	#(-- n)
	li a0, 2
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_YELLOW, COLOR_GREEN, 0x01
	#(-- n)
	li a0, 3
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_BLUE, COLOR_YELLOW, 0x01
	#(-- n)
	li a0, 4
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_MAGENTA, COLOR_BLUE, 0x01
	#(-- n)
	li a0, 5
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_CYAN, COLOR_MAGENTA, 0x01
	#(-- n)
	li a0, 6
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER COLOR_WHITE, COLOR_CYAN, 0x01
	#(-- n)
	li a0, 7
	addi sp, sp, -8
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER START_COLOR, COLOR_WHITE, 0x01
	#(--)
	call start_color
	TAILMOD t1

	CODEHEADER KEY_F, START_COLOR, 0x01
	#(n -- n)
	ld t0, 0(sp)
	addi t0, t0, 264
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER INIT_PAIR, KEY_F, 0x01
	#(num, colf, colb -- n)
	ld a0, 16(sp)
	ld a1, 8(sp)
	ld a2, 0(sp)
	li t0, 1
	addi t1, a0, 8
	sll t2, t0, t1
	addi sp, sp, 16
	sd t2, 0(sp)
	call init_pair
	TAILMOD t1

	CODEHEADER COLOR_PAIR, INIT_PAIR, 0x01
	#(n -- n)
	ld t0, 0(sp)
	li t1, 8
	sll t2, t0, t1
	sd t2, 0(sp)
	TAILMOD t1

	CODEHEADER INIT_COLOR, COLOR_PAIR, 0x01
	#(n n n n ---)
	ld a0, 24(sp)
	ld a1, 16(sp)
	ld a2, 8(sp)
	ld a3, 0(sp)
	call init_color
	TAILMOD t1

	CODEHEADER MOVESTD, INIT_COLOR, 0x01
	#(row col --)
	ld a0, 8(sp)
	ld a1, 0(sp)
	addi sp, sp, 16
	call move
	TAILMOD t1

	CODEHEADER MVWADDCH, MOVESTD, 0x01
	#(n n n c --)
	ld a0, 24(sp)
	ld a1, 16(sp)
	ld a2, 8(sp)
	ld a3, 0(sp)
	call mvwaddch
	TAILMOD t1

	CODEHEADER ADDCH, MVWADDCH, 0x01
	#(c --)
	ld a0, 0(sp)
	addi sp, sp, 8
	call addch
	TAILMOD t1

	CODEHEADER MVADDCH, ADDCH, 0x01
	#(row col c --)
	ld a0, 16(sp)
	ld a1, 8(sp)
	ld a2, 0(sp)
	addi sp, sp, 24
	call mvaddch
	TAILMOD t1

  printw_cnt_percent:
	#enter here with t0 as length
	#and t1 as pointer
	#returns t2 as count
	li t2, 0			#count of %
	li t3, 0x25			#%
	li t5, 0			#was previous char %?
  printw_cnt_test:
	beqz t0, printw_cnt_done
	lb t4, 0(t1)
	bne t3, t4, printw_cnt_adv_zero	#not a %
	bnez t5, printw_cnt_adv_zero_match
	addi t2, t2, 1
	li t5, 1			#enable %%
	j printw_cnt_adv
  printw_cnt_adv_zero_match:
	addi t2, t2, -1
  printw_cnt_adv_zero:
	li t5, 0
  printw_cnt_adv:
	addi t0, t0, -1
	addi t1, t1, 1
	j printw_cnt_test		#loop back
  printw_cnt_done:
	ret

	# MVPRINTW and PRINTW handle Forth counted strings now
	CODEHEADER MVPRINTW, MVADDCH, 0x01
	#([var n] row col addr n --)
	#process string first
	ld t0, 0(sp)
	ld t1, 8(sp)
	call printw_cnt_percent
	mv a1, t2			#store cnt for now
	#get null terminated string
	ld t0, 0(sp)
	ld t1, 8(sp)
	call null_terminate_string
	#set up the definite params
	mv a2, a0
	mv t0, a1
	ld a0, 24(sp)
	ld a1, 16(sp)
	bnez t0, mvprintw_complex
	#simplest case
	call mvprintw
	addi sp, sp, 32
	ret
  mvprintw_complex:
	mv t1, t0			#for later stack adjustment
	ld a3, 32(sp)	
	addi t0, t0, -1
	beqz t0, mvprintw_setcall
	ld a4, 40(sp)
	addi t0, t0, -1
	beqz t0, mvprintw_setcall
	ld a5, 48(sp)
	addi t0, t0, -1
	beqz t0, mvprintw_setcall
	ld a6, 56(sp)
	addi t0, t0, -1
	beqz t0, mvprintw_setcall
	ld a7, 64(sp)
	addi t0, t0, -1
	beqz t0, mvprintw_setcall
	#now loop and stick this stuff on an adjusted stack
	#maximum number of parameters is going to be 64!
	mv t2, sp	#keep track of old stack pointer
	addi sp, sp, -448	#new stack pointer
	addi t2, t2, 72	#where next 
	mv t3, sp	#use this to track storage point
  mvprintw_stack_loop:
	ld t4, 0(t2)
	sd t4, 0(t3)
	addi t0, t0, -1
	beqz t0, mvprintw_docall
	addi t2, t2, 8
	addi t3, t3, 8
	j mvprintw_stack_loop
  mvprintw_setcall:
	#calculate stack extension required
	li t3, -512
	slli t1, t1, 3	#multiply by 8
	add t2, t1, t3
	add sp, sp, t2
  mvprintw_docall:
	call mvprintw
	addi sp, sp, 512	#fix up stack
	TAILMOD t1

	CODEHEADER PRINTW, MVPRINTW, 0x01
	#([var n] addr n --)
	#complex printw, printwstronly deals with simplest case
	#first load counted string and parse for %
	ld t0, 0(sp)			#length
	ld t1, 8(sp)			#string ptr
	call printw_cnt_percent
	bnez t2, printw_handle_complex
	tail PRINTWSTRONLY		#no inserts
  printw_handle_complex:
	mv a1, t2			#preserve count
	#next null terminate the string
	ld t0, 0(sp)
	ld t1, 8(sp)
	call null_terminate_string	#a0 now points to string
	mv t0, a1			#use this to countdown
	mv t1, t0			#use this to calculate stack adjustment
	ld a1, 16(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a2, 24(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a3, 32(sp)	
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a4, 40(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a5, 48(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a6, 56(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	ld a7, 64(sp)
	addi t0, t0, -1
	beqz t0, printw_setcall
	#now loop and stick this stuff on an adjusted stack
	#maximum number of parameters is going to be 64!
	mv t2, sp	#keep track of old stack pointer
	addi sp, sp, -448	#new stack pointer
	addi t2, t2, 72	#where next 
	mv t3, sp	#use this to track storage point
  printw_stack_loop:
	ld t4, 0(t2)
	sd t4, 0(t3)
	addi t0, t0, -1
	beqz t0, printw_docall
	addi t2, t2, 8
	addi t3, t3, 8
	j printw_stack_loop
  printw_setcall:
	#calculate stack extension required
	li t3, -512
	slli t1, t1, 3	#multiply by 8
	add t2, t1, t3
	add sp, sp, t2
  printw_docall:
	call printw
	addi sp, sp, 512	#fix up stack
	TAILMOD t1

  null_terminate_string:
	#t0 has length
	#t1 has address
	#returns SCRATCH_PAD address in a0
	#now copy to buffer and null terminate
	la t2, SCRATCH_PAD
	mv a0, t2
  printw_loop:
	beqz t0, printw_call
	lb t3, 0(t1)
	sb t3, 0(t2)
	addi t1, t1, 1
	addi t2, t2, 1
	addi t0, t0, -1
	j printw_loop
  printw_call:
	sb zero, 0(t2)
	ret

	CODEHEADER PRINTWSTRONLY, PRINTW, 0x0
	#(addr n --)
	ld t0, 0(sp)
	ld t1, 8(sp)
	addi sp, sp, 16
	call null_terminate_string
	call printw
	TAILMOD t1

	CODEHEADER GETCH, PRINTWSTRONLY, 0x01
	#(-- c)
	call getch
	addi sp, sp, -8
	sd a0, 0(sp)
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

	CODEHEADER CBREAK, NOECHO, 0x01
	#(--)
	call cbreak
	TAILMOD t1

	CODEHEADER RAW, CBREAK, 0x01
	#(--)
	call raw
	TAILMOD t1

	CODEHEADER HALFDELAY, RAW, 0x01
	#(n -- n)
	ld a0, 0(sp)
	call halfdelay
	sd a0, 0(sp)
	TAILMOD t1

	CODEHEADER KEYPADSTD, HALFDELAY, 0x01
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

	CODEHEADER NORMALON, KEYPAD, 0x01
	#(--)
	mv a0, zero
	call attron
	TAILMOD t1

	CODEHEADER NORMALOFF, NORMALON, 0x01
	#(--)
	#does nothing
	TAILMOD t1

	CODEHEADER STANDOUTON, NORMALOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 16
	call attron
	TAILMOD t1

	CODEHEADER STANDOUTOFF, STANDOUTON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 16
	call attroff
	TAILMOD t1

	CODEHEADER UNDERLINEON, STANDOUTOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 17
	call attron
	TAILMOD t1

	CODEHEADER UNDERLINEOFF, UNDERLINEON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 17
	call attroff
	TAILMOD t1

	CODEHEADER REVERSEON, UNDERLINEOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 18
	call attron
	TAILMOD t1

	CODEHEADER REVERSEOFF, REVERSEON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 18
	call attroff
	TAILMOD t1

	CODEHEADER BLINKON, REVERSEOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 19
	call attron
	TAILMOD t1

	CODEHEADER BLINKOFF, BLINKON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 19
	call attroff
	TAILMOD t1

	CODEHEADER DIMON, BLINKOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 20
	call attron
	TAILMOD t1

	CODEHEADER DIMOFF, DIMON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 20
	call attroff
	TAILMOD t1

	CODEHEADER BOLDON, DIMOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 21
	call attron
	TAILMOD t1

	CODEHEADER BOLDOFF, BOLDON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 21
	call attroff
	TAILMOD t1

	CODEHEADER PROTECTON, BOLDOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 24
	call attron
	TAILMOD t1

	CODEHEADER PROTECTOFF, PROTECTON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 24
	call attroff
	TAILMOD t1

	CODEHEADER INVISON, PROTECTOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 25
	call attron
	TAILMOD t1

	CODEHEADER INVISOFF, INVISON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 25
	call attroff
	TAILMOD t1

	CODEHEADER ALTCHARSETON, INVISOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 22
	call attron
	TAILMOD t1

	CODEHEADER ALTCHARSETOFF, ALTCHARSETON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 22
	call attroff
	TAILMOD t1

	CODEHEADER CHARTEXTON, ALTCHARSETOFF, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 8
	addi a0, a0, -1
	call attron
	TAILMOD t1

	CODEHEADER CHARTEXTOFF, CHARTEXTON, 0x01
	#(--)
	li a0, 1
	slli a0, a0, 8
	addi a0, a0, -1
	call attroff
	TAILMOD t1

	CODEHEADER A_NORMAL, CHARTEXTOFF, 0x01
	#(-- n)
	addi sp, sp, -8
	sd zero, 0(sp)
	TAILMOD t1

	CODEHEADER A_CHARTEXT, A_NORMAL, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 7
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_COLOR, A_CHARTEXT, 0x01
	#(--n)
	addi sp, sp, -1
	li t0, 1
	slli t0, t0, 8
	addi t0, t0, -1
	slli t0, t0, 8
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_STANDOUT, A_COLOR, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 16
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_UNDERLINE, A_STANDOUT, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 17
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_REVERSE, A_UNDERLINE, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 18
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_BLINK, A_REVERSE, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 19
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_DIM, A_BLINK, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 20
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_BOLD, A_DIM, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 21
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_ALTCHARSET, A_BOLD, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 22
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_INVIS, A_ALTCHARSET, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 23
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_PROTECT, A_INVIS, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 24
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_HORIZONTAL, A_PROTECT, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 25
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_LEFT, A_HORIZONTAL, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 26
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_LOW, A_LEFT, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 27
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_RIGHT, A_LOW, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 28
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_TOP, A_RIGHT, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 29
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER A_VERTICAL, A_TOP, 0x01
	#(--n)
	addi sp, sp, -8
	li t0, 1
	slli t0, t0, 30
	sd t0, 0(sp)
	TAILMOD t1

	CODEHEADER ATTRON, A_VERTICAL, 0x01
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
