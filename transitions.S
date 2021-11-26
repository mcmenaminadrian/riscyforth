#Copyright Adrian McMenamin, 2021
#Licenced under the GPL v2

#transitions.S - handle various nested conditional transitions

  #handle new conditional code
  trackback_failed_if:
		PRINT badif
  trackback_failed:
		tail search_create_bad_ifmode

  trackback_failed_else:
		PRINT badelse
		tail search_create_bad_ifmode

  transitions_if_out:
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1)		#ELSE offset stored here
		sd zero, 16(t1)		#THEN offset stored here
		addi t1, t1, 24
		sd t1, 0(t0)
		tail search_create_leave

  transitions_else_out:
		# first write out the else
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1)
		# now search for the IF (or WHILE)
		li a0, 0		#must be zero to write
		la a2, WA__IF		# looking for this
		la a3, WA_THEN		#index incrementer
		la t6, WA__WHILE	#looking for this
		la t5, WA__REPEAT	#alternative increment
		mv a6, t1		# search point
		addi a6, a6, -8
		li a4, -4096
		add a5, a6, a4		# max track back (4KB)
  transitions_else_search_back:
		ld a4, 0(a6)
		beq a4, a3, transitions_else_search_back_inc_index
		beq a4, a2, transitions_else_search_back_dec_index
		beq a4, t6, transitions_else_search_back_dec_index
		beq a4, t5, transitions_else_search_back_inc_index
  transitions_else_search_back_retreat:
		addi a6, a6, -8
		beq a6, a5, trackback_failed_if
		j transitions_else_search_back
  transitions_else_search_back_inc_index:
		addi a0, a0, 1
		j transitions_else_search_back_retreat
  transitions_else_search_back_dec_index:
		beqz a0, transitions_else_fix_jump
		addi a0, a0, -1
		j transitions_else_search_back_retreat
  transitions_else_fix_jump:
		addi t1, t1, 16
		sd t1, 8(a6)		#insert jump
		#now update write point
		sd t1, 0(t0)
		tail search_create_leave

  transitions_then_out:
		#sole task is to update indices for IF and ELSE
		# but we need to know where we are starting from
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		# now search for the IF
		li a0, 0		#must be zero to write
		la a2, WA__IF		# looking for this
		la t6, WA__WHILE	# also looking for this
		la a7, WA__ELSE		# or this
		la a3, WA_THEN		#index incrementer
		la t5, WA__REPEAT	#also this 
		mv a6, t1		# search point
		addi a6, a6, -8
		li a4, -4096
		add a5, a6, a4		# max track back (4KB)
  transitions_then_search_back:
		ld a4, 0(a6)
		beq a4, a3, transitions_then_search_back_inc_index
		beq a4, a2, transitions_then_search_back_dec_index
		beq a4, a7, transitions_then_search_back_else_found
		beq a4, t6, transitions_then_search_back_dec_index
		beq a5, t5, transitions_then_search_back_inc_index
  transitions_then_search_back_retreat:
		addi a6, a6, -8
		beq a6, a5, trackback_failed_if
		j transitions_then_search_back
  transitions_then_search_back_inc_index:
		addi a0, a0, 1
		j transitions_then_search_back_retreat
  transitions_then_search_back_else_found:
		beqz a0, transitions_then_else_jump
		j transitions_then_search_back_retreat
  transitions_then_else_jump:
		addi t1, t1, 8
		sd t1, 8(a6)		#insert jump
		addi t1, t1, -8
		j transitions_then_search_back_retreat
  transitions_then_search_back_dec_index:
		beqz a0, transitions_then_fix_jump
		addi a0, a0, -1
		j transitions_then_search_back_retreat
  transitions_then_fix_jump:
		addi t1, t1, 8
		sd t1, 16(a6)		#insert jump
		#now update write point
  transitions_then_exit:
		sd t1, 0(t0)
		tail search_create_leave

  transitions_until_out:
		#look for WA_BEGIN
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1)
		li a0, 0
		la a2, WA_BEGIN
		la a3, WA__UNTIL
		la a7, WA__AGAIN	# also an incrementer
  transitions_search_back_common:
		mv a6, t1
		addi a6, a6, -8
		li a4, -4096
		add a5, a6, a4		# max track back (4KB)
  transitions_until_search_back:
		addi a6, a6, -8
		ld a4, 0(a6)
		beq a4, a3, transitions_until_search_back_inc_index
		beq a4, a2, transitions_until_search_back_dec_index
		beq a4, a7, transitions_until_search_back_inc_index
  transitions_until_retreat:
		beq a6, a5, trackback_failed
		j transitions_until_search_back
  transitions_until_search_back_inc_index:
		addi a0, a0, 1
		j transitions_until_retreat
  transitions_until_search_back_dec_index:
		beqz a0, transitions_until_fix_jump	#found what we want
		addi a0, a0, -1
		j transitions_until_retreat
  transitions_until_fix_jump:
		addi a6, a6, 8
		sd a6, 8(t1)
		addi t1, t1, 16
		sd t1, 0(t0)
		tail search_create_leave

  transitions_again_out:
		#look for WA_BEGIN
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		li a0, 0
		la a2, WA_BEGIN
		la a3, WA__AGAIN
		la a7, WA__UNTIL	# also an incrementer
		j transitions_search_back_common

  transitions_while_out:
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1) 		#else equivalent
		sd zero, 16(t1)		#then equivalent
		addi t1, t1, 24
		sd t1, 0(t0)
		tail search_create_leave


  transitions_repeat_out:
		#look for WA_BEGIN
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1)
		li a0, 0
		la a2, WA_BEGIN
		la a3, WA__REPEAT
		la a7, WA__UNTIL
		la t5, WA__AGAIN
		la t6, WA__WHILE
		mv a6, t1
		addi a6, a6, -8
		li a4, -4096
		add a5, a6, a4
  transitions_repeat_search_back:
		addi a6, a6, -8
		ld a4, 0(a6)
		beq a4, a3, transitions_repeat_inc
		beq a4, a2, transitions_repeat_dec
		beq a4, a7, transitions_repeat_inc
		beq a4, t5, transitions_repeat_inc
		beq a4, t6, transitions_repeat_while
  transitions_repeat_retreat:
		beq a6, a5, trackback_failed
		j transitions_repeat_search_back
  transitions_repeat_while:
		bnez a0, transitions_repeat_retreat
		addi t4, t1, 16
		sd t4, 8(a6)
		j transitions_repeat_retreat
  transitions_repeat_inc:
		addi a0, a0, 1
		j transitions_repeat_retreat
  transitions_repeat_dec:
		beqz a0, transitions_repeat_fix_jump	#found what we want
		addi a0, a0, -1
		j transitions_repeat_retreat
  transitions_repeat_fix_jump:
		j transitions_until_fix_jump

  transitions_do_out:
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1) 		#jump if needed
		addi t1, t1, 16
		sd t1, 0(t0)
		tail search_create_leave

  transitions_loop_out:
		#look for WA__DO and WA__QDO
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)		#write word
		la a2, WA__QDO
		la a3, WA__DO
		la a4, WA__LOOP
		la a7, WA__PLUSLOOP
		li a1, 0
		mv a6, t1
		li a0, -4096
		add a5, a6, a0
  transitions_loop_trackback:
		addi a6, a6, -8
		beq a6, a5, trackback_failed
		ld a0, 0(a6)
		beq a0, a4, transitions_loop_inc
		beq a0, a7, transitions_loop_inc
		beq a0, a3, transitions_loop_dec
		beq a0, a2, transitions_loop_dec
		j transitions_loop_trackback
  transitions_loop_inc:
		addi a1, a1, 1
		j transitions_loop_trackback
  transitions_loop_dec:
		beqz a1, transitions_loop_exit
		addi a1, a1, -1
		j transitions_loop_trackback
  transitions_loop_exit:
		addi t2, t1, 8
		sd t2, 8(a6)
		addi t1, t1, 8
		sd t1, 0(t0)
		tail search_create_leave
