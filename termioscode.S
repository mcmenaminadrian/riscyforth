#Various termios focused code utilities for use
#by other parts of Riscyforth
#Copyright (c) Adrian McMenamin, 2022
#Licensed under version 2 of the GNU GPL

#INITIALIZE termios
  init_termios:
		PUSH ra
		li a0, 0
		la a1, termios
		call tcgetattr
		POP ra
		ret

#ICANON on, ECHOE on
  reset_termios:
		PUSH ra
		li a0, 0
		li a1, 0
		la a2, termios
		#set ICANON, ECHO and ECHOE
		lwu a3, 12(a2)
		li a4, 0x32
		or a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#return single character, no echo
  singlechar_termios:
		PUSH ra
		li a0, 0
		li a1, 0
		la a2, termios
		lwu a3, 12(a2)
		#ICONAN, ECHO off
		li a4, 0xFFFFFFED
		and a5, a3, a4
		sw a5, 12(a2)
		call tcsetattr
		#now get character - returned in a0
		li a0, 0
		la a1, SCRATCH_PAD
		li a7, 63
		ecall
		lb a0, 0(a1)
		POP ra
		ret
		
		
		
