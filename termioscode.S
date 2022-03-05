#Various termios focused code utilities for use
#by other parts of Riscyforth
#Copyright (c) Adrian McMenamin, 2022
#Licensed under version 2 of the GNU GPL

#see include/uapi/asm-generic/termbits.h in Linux kernel distro
.equ 	TCSANOW, 0
.equ	TCSADRAIN, 1

#offsets to the c_cc[] array
.equ	VTIME_OFFSET, 22
.equ	VMIN_OFFSET, 23

#INITIALIZE termios structure
  copy_termios_structure:
		PUSH ra
		li a0, 0
		la a1, termios
		call tcgetattr
		POP ra
		ret

#ICANON on
  icanon_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSANOW
		la a2, termios
		#set ICANON
		lwu a3, 12(a2)
		li a4, 0x2
		or a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#ECHO ON
  echo_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ECHO
		lwu a3, 12(a2)
		li a4, 10
		or a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#ECHOE ON
  echoe_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ECHOE
		lwu a3, 12(a2)
		li a4, 20
		or a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

  reset_termios:
		PUSH ra
		call copy_termios_structure		
		call icanon_termios_on
		call echo_termios_on
		call echoe_termios_on
		POP ra
		ret

#ICANON OFF
  icanon_termios_off:
		PUSH ra
		li a0, 0
		li a1, TCSANOW
		la a2, termios
		#set ICANON off
		lwu a3, 12(a2)
		li a4, 0x2
		not a4, a4
		and a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#ECHO OFF
  echo_termios_off:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ECHO off
		lwu a3, 12(a2)
		li a4, 10
		not a4, a4
		and a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#ECHOE OFF
  echoe_termios_off:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ECHO off
		lwu a3, 12(a2)
		li a4, 20
		not a4, a4
		and a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#NO POLLING
  nopolling_termios:
		PUSH ra
		li a0, 0
		li a1, TCSANOW
		la a2, termios
		li t0, 1
		sb t0, VMIN_OFFSET(a2)
		sb zero, VTIME_OFFSET(a2)
		call tcsetattr
		POP ra
		ret

   
#return single character, no echo
  singlechar_termios:
		PUSH ra
		call echoe_termios_off
		call echo_termios_off
		call nopolling_termios
		call icanon_termios_off
		call get_termios
		#ensure we are NOT in O_NONBLOCK
		li a0, 0
		li a1, 3			#F_GETFL
		call fcntl
		mv a2, a0
		PUSH a0
		li a0, 0
		li a1, 4			#F_SETFL
		li t0, 0x4000 			#O_NONBLOCK
		not t0, t0
		and a2, a2, t0
		call fcntl
		#now get character - returned in a0
		li a0, 0
		la a1, SCRATCH_PAD
		call read
		lb t0, 0(a1)
		li a0, 0
		li a1, 4			#F_SETFL
		POP a2
		PUSH t0
		call fcntl
		POP a0
		POP ra
		ret

  get_termios:
		PUSH ra
		call copy_termios_structure
		la a0, termios
		lwu a1, 12(a0)
		POP ra
		ret
