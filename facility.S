##############################
# Facility and timining words#
##############################

#The Riscyforth projection is
#copyright, Adrian McMenamin, 2020 - 2021
#Licensed under version 2 of the GNU GPL

.balign 8

		#get date the date and time
		CODEHEADERZ TIME_DATE, TIME&DATE, BYE, 0x01
		#( -- n n n n n n)
		#create space on the stack
		addi sp, sp, -80
        	sd s0, 72(sp)
        	addi s0,sp,80
        	addi a5,s0,-32
        	li a1,0
        	mv a0,a5
        	call gettimeofday
		#a1 returns with pointer to Unix epoch time
		ld t0, 0(a1)
		ld s0, 72(sp)
		addi sp, sp, 32
		#get the clock time
		li a0, 86400		#seconds per day
		div t1, t0, a0		#t1 number of whole days that have elapsed
		mul t2, t1, a0
		sub t3, t0, t2		#t3 has number of seconds into this day
		li a1, 60
		div t4, t3, a1		#t4 number of whole minutes that have elapsed
		mul t2, t4, a1
		sub t2, t3, t2		#t2 seconds of minute
		sd t2, 40(sp)		#on to stack
		div t2, t4, a1		#t2 number of whole hours that have elapsed
		mul t5, t2, a1
		sub t6, t4, t5
		sd t6, 32(sp)		#store minutes
		sd t2, 24(sp)		#store hours
		#now the date portion
		#now store month lengths on the stack
		addi sp, sp, -12
		li a0, 31
		li a1, 30
		li a2, 28
		sb a0, 0(sp)		#JANUARY
		sb a2, 1(sp)
		sb a0, 2(sp)
		sb a1, 3(sp)
		sb a0, 4(sp)
		sb a1, 5(sp)
		sb a0, 6(sp)
		sb a0, 7(sp)
		sb a1, 8(sp)
		sb a0, 9(sp)
		sb a1, 10(sp)
		sb a0, 11(sp)		#DECEMBER
		mv a0, sp		#a0 points to top of month lengths
		li a1, 1970		#start of Unix epoch
		li a2, 365
		li a3, 366
		li a4, 4
		#NB we are assuming this code won't be running in 2100 - so will ignore century rule
		#using t1 from above for number of whole days
  time_date_count_down_years:
		div t0, a1, a4
		mul t2, t0, a4
		sub t3, a1, t2
		beqz t3, time_date_leapyear
		bgeu a2, t1, time_date_year_reached
		sub t1, t1, a2
		addi a1, a1, 1
		j time_date_count_down_years
  time_date_leapyear:
		bgeu a3, t1, time_date_year_reached_leap
		sub t1, t1, a3
		addi a1, a1, 1
		j time_date_count_down_years
  time_date_year_reached_leap:
		li a0, 29
		sb a0, 1(sp)
  time_date_year_reached:
		#a1 now has the year
		#t1 has the excess days
		addi t1, t1, 1		#count from 1, not zero
		#store the year
		sd a1, 12(sp)
		li a0, 0		#month counter
  time_date_count_down_months:
		mv a1, sp
		add a1, a1, a0
		lb a2, 0(a1)
		add a0, a0, 1
		bgeu a2, t1, time_date_month_reached
		sub t1, t1, a2
		j time_date_count_down_months
  time_date_month_reached:
		sd a0, 20(sp)
		sd t1, 28(sp)
		addi sp, sp, 12
		tail NEXT

		CODEHEADERZ Q, ?, TIME_DATE, 0x01
		#(addr --)
		ld t0, 0(sp)
		ld t1, 0(t0)
		sd t1, 0(sp)
		tail DOT

		CODEHEADER DEBUGIN, Q, 0x1
		#(--)
		#debug word
		la t0, CYCLESTART
		rdcycle t1
		sd t1, 0(t0)
		tail NEXT
		
		CODEHEADER DEBUGOUT, DEBUGIN, 0x1
		#(--)
		#debug word
		rdcycle t0
		la t1, CYCLESTART
		ld t2, 0(t1)
		bgt t0, t2, debugout_normal
		li t3, -1
		sub t4, t3, t2
		add t4, t4, t0
		j debugout_sum
  debugout_normal:
		sub t4, t0, t2
  debugout_sum:
		la t5, CYCLECOUNT
		ld t0, 0(t5)
		add t1, t0, t4
		sd t1, 0(t5)
		la t6, CYCLEPINGS
		ld t2, 0(t6)
		addi t2, t2, 1
		sd t2, 0(t6)
		tail NEXT

		CODEHEADER DEBUGRESULTS, DEBUGOUT, 0x1
		#(-- n n n)
		la t0, CYCLECOUNT
		la t1, CYCLEPINGS
		ld t2, 0(t0)
		ld t3, 0(t1)
		div t4, t2, t3
		addi sp, sp, -24
		sd t2, 0(sp)
		sd t3, 8(sp)
		sd t4, 16(sp)
		sd zero, 0(t0)
		sd zero, 0(t1)
		la t2, CYCLESTART
		sd zero, 0(t2)
		tail NEXT

		#sleep for u milliseconds
		CODEHEADER MS, DEBUGRESULTS, 0x01
		#(u --)
		ld t0, 0(sp)
		addi sp, sp, 8
		li t1, 1000
		mul a0, t1, t0
		call usleep
		tail NEXT
		

