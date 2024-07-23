#Various termios focused code utilities for use
#by other parts of Riscyforth
#Copyright (c) Adrian McMenamin, 2022
#Licensed under version 2 of the GNU GPL

#see include/uapi/asm-generic/termbits.h in Linux kernel distro
.equ 	TCSANOW, 0
.equ	TCSADRAIN, 1
.equ	TCSAFLUSH, 2

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
.equ	ECHOE, 0x00010
.equ	ICANON, 0x00002
.equ	IEXTEN, 0x08000
.equ	ISIG, 0x00001
.equ	CSIZE, 0x00000030
.equ	PARENB, 0x00000100


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

#IXON ON
  ixon_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		lwu a3, 0(a2)
		li a4, IXON
		or a4, a4, ICRNL
		or a5, a4, a3
		sw a5, 0(a2)
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

#ISIG ON
  isig_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ISIG
		lwu a3, 12(a2)
		li a4, ISIG
		or a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#OPOST ON
  opost_termios_on:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		lwu a3, 4(a2)
		li a4, OPOST
		or a5, a4, a3
		sw a5, 4(a2)
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

  reset_raw_termios:
		PUSH ra
		call copy_termios_structure		
		call icanon_termios_on
		call echo_termios_on
		call echoe_termios_on
		call isig_termios_on
		call ixon_termios_on
		call opost_termios_on
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

#IXON OFF
  ixon_termios_off:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		lwu a3, 0(a2)
		li a4, IXON
		or a4, a4, ICRNL
		not a4, a4
		and a5, a4, a3
		sw a3, 0(a2)
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

#ISIG_OFF
  isig_termios_off:
		PUSH ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		#set ISIG off
		lwu a3, 12(a2)
		li a4, ISIG
		not a4, a4
		and a5, a4, a3
		sw a5, 12(a2)
		call tcsetattr
		POP ra
		ret

#OPOST OFF
  opost_termios_off:
		push ra
		li a0, 0
		li a1, TCSADRAIN
		la a2, termios
		lwu a3, 4(a2)
		li a4, OPOST
		not a4, a4
		and a5, a4, a3
		sw a5, 4(a2)
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

  set_lflag_raw:
		li t0, ECHO
		li t1, ICANON
		or t0, t0, t1
		li t1, IEXTEN
		or t0, t0, t1
		li t1, ISIG
		or t0, t0, t1
		not t0, t0
		lwu a3, 12(a2)
		and a3, a3, t0
		sw a3, 12(a2)
		ret

  set_iflag_raw:
		li t0, BRKINT
		li t1, ICRNL
		or t0, t0, t1
		li t1, INPCK
		or t0, t0, t1
		li t1, ISTRIP
		or t0, t0, t1
		li t1, IXON
		or t0, t0, t1
		not t0, t0
		lwu a3, 0(a2)
		and a3, a3, t0
	 	sw a3, 0(a2)
		ret

  set_oflag_raw:
		li t0, OPOST
		not t0, t0
		lwu a3, 4(a2)
		and a3, a3, t0
		sw a3, 4(a2)
		ret

  set_cflag_raw:
		li t0, CSIZE
		li t1, PARENB
		or t0, t0, t1
		not t0, t0
		lwu a3, 8(a2)
		and a3, a3, t0
		sw a3, 8(a2)
		ret

  set_cflag_raw2:
		li t0, CS8
		sw a3, 8(a2)
		or a3, a3, t0
		sw a3, 8(a2)
		ret


  singlechar_raw_termios:
		PUSH ra
		call get_termios
		la a2, termios
		call set_lflag_raw
		call set_iflag_raw
		call set_oflag_raw
		call set_cflag_raw
		call set_cflag_raw2
		li a0, 0
		li a1, TCSAFLUSH
		call tcsetattr
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
		li a2, 4			#handle escapes
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
