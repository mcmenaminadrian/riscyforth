##############################
# Facility and timining words#
##############################

#The Riscyforth projection is
#copyright, Adrian McMenamin, 2020 - 2021
#Licensed under version 2 of the GNU GPL

.balign 8

		#get date the date and time from rtc
		CODEHEADERZ TIME_DATE, TIME&DATE, BYE, 0x01

		tail NEXT

		#sleep for u milliseconds
		CODEHEADER MS, TIME_DATE, 0x01
		#(u --)
		ld t0, 0(sp)
		addi sp, sp, -8
		li t1, 1000
		mul a0, t1, t0
		call usleep
		tail NEXT
		

