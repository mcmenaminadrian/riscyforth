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

.equ	BRKINT, 0x002
.equ	ICRNL, 0x100
.equ	INPCK, 0x010
.equ	ISTRIP, 0x020
.equ	IXON, 0x0400
.equ	OPOST, 0x01
.equ	CS8, 0x00000030
.equ	ECHO, 0x00008
.equ	ICANON, 0x00002
.equ	IEXTEN, 0x08000
.equ	ISIG, 0x00001


#INITIALIZE termios structure
  copy_termios_structure:
		PUSH ra
		li a0, 0
		la a1, termios
		call tcgetattr
		POP ra
		ret

#SAVE OLD TERMIOS
  save_termios_structure:
		PUSH ra
		li a0, 0
		la a1, oldtermios
		call tcgetattr
		POP ra
		ret

#RESTORE OLD TERMIOS
  restore_saved_termios:
		PUSH ra
		li a0, 0
		li a1, TCSANOW
		la a2, oldtermios
		call tcsetattr
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


# true raw mode - single char no echo
  rawmode_termios:
		PUSH ra
		call load_termios
		# set t0 to ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
		li t0, BRKINT
		li t5, ICRNL
		or t0, t0, t5
		li t5, INPCK
		or t0, t0, t5
		li t5, ISTRIP
		or t0, t0, t5
		li t5, IXON
		or t0, t0, t5
		not t0, t0
		# set t1 to ~(OPOST)
		li t1, OPOST
		not t1, t1
		# set t2 to CS8
		li t2, CS8
		# set t3 to ~(ECHO | ICANON | IEXTEN | ISIG)
		li t3, ECHO
		li t5, ICANON
		or t3, t3, t5
		li t5, IEXTEN
		or t3, t3, t5
		li t5, ISIG
		or t3, t3, t5
		not t3, t3
		# now edit local termios structure
		la t4, termios
		lwu t5, 0(t4)
		and t5, t5, t0
		sw t5, 0(t4)
		lwu t5, 4(t4)
		and t5, t5, t1
		sw t5, 4(t4)
		lwu t5, 8(t4)
		or t5, t5, t2
		sw t5, 8(t4)
		lwu t5, 12(t4)
		and t5, t5, t3
		sw t5, 12(t4)
		li a0, 0
		li a1, TCSANOW
		la a2, termios
		call tcsetattr
		POP ra
		ret

  rawmode_termios_key:
		#ensure we are NOT in O_NONBLOCK
		PUSH ra
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
   
# return single character, no echo
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

 load_termios:
		PUSH ra
		call copy_termios_structure
		la a0, termios
		POP ra
		ret
