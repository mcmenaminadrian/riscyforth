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
		li a1, 3		#counter - starts at 3 to account for IF itself
		la a2, WA__IF		# looking for this
		la a3, WA_THEN		#index incrementer
		la t6, WA__WHILE	#looking for this
		la t5, WA__REPEAT	#alternative increment
		li a5, 512		# max track back (4KB)
		mv a6, t1		# search point
		addi a6, a6, -24
  transitions_else_search_back:
		ld a4, 0(a6)
		beq a4, a3, transitions_else_search_back_inc_index
		beq a4, a2, transitions_else_search_back_dec_index
		beq a4, t6, transitions_else_search_back_dec_index
		beq a4, t5, transitions_else_search_back_inc_index
  transitions_else_search_back_retreat:
		addi a1, a1, 1
		beq a1, a5, trackback_failed_else
		addi a6, a6, -8
		j transitions_else_search_back
  transitions_else_search_back_inc_index:
		addi a0, a0, 1
		j transitions_else_search_back_retreat
  transitions_else_search_back_dec_index:
		beqz a0, transitions_else_fix_jump
		addi a0, a0, -1
		j transitions_else_search_back_retreat
  transitions_else_fix_jump:
		addi a1, a1, 1
		sd a1, 8(a6)		#insert jump
		#now update write point
		addi t1, t1, 16
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
		li a1, 1		#counter - starts at 2 (may be ELSE)
		la a2, WA__IF		# looking for this
		la t6, WA__WHILE	# also looking for this
		la a7, WA__ELSE		# or this
		la a3, WA_THEN		#index incrementer
		la t5, WA__REPEAT	#also this 
		li a5, 512		# max track back (4KB)
		mv a6, t1		# search point
		addi a6, a6, -8
  transitions_then_search_back:
		ld a4, 0(a6)
		beq a4, a3, transitions_then_search_back_inc_index
		beq a4, a2, transitions_then_search_back_dec_index
		beq a4, a7, transitions_then_search_back_else_found
		beq a4, t6, transitions_then_search_back_dec_index
		beq a5, t5, transitions_then_search_back_inc_index
  transitions_then_search_back_retreat:
		addi a1, a1, 1
		beq a1, a5, trackback_failed_if
		addi a6, a6, -8
		j transitions_then_search_back
  transitions_then_search_back_inc_index:
		addi a0, a0, 1
		j transitions_then_search_back_retreat
  transitions_then_search_back_else_found:
		beqz a0, transitions_then_else_jump
		j transitions_then_search_back_retreat
  transitions_then_else_jump:
		sd a1, 8(a6)		#insert jump
		addi a1, a1, -1
		j transitions_then_search_back_retreat
  transitions_then_search_back_dec_index:
		beqz a0, transitions_then_fix_jump
		addi a0, a0, -1
		j transitions_then_search_back_retreat
  transitions_then_fix_jump:
		sd a1, 16(a6)		#insert jump
		#now update write point
  transitions_then_exit:
		addi t1, t1, 8
		sd t1, 0(t0)
		tail search_create_leave

  transitions_until_out:
		#look for WA_BEGIN
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		sd zero, 8(t1)
		li a0, 0
		li a1, -1
		la a2, WA_BEGIN
		la a3, WA__UNTIL
		la a7, WA__AGAIN	# also an incrementer
  transitions_search_back_common:
		li a5, 512
		mv a6, t1
  transitions_until_search_back:
		addi a6, a6, -8
		ld a4, 0(a6)
		beq a4, a3, transitions_until_search_back_inc_index
		beq a4, a2, transitions_until_search_back_dec_index
		beq a4, a7, transitions_until_search_back_inc_index
  transitions_until_retreat:
		addi a1, a1, -1
		beq a1, a5, trackback_failed
		j transitions_until_search_back
  transitions_until_search_back_inc_index:
		addi a0, a0, 1
		j transitions_until_retreat
  transitions_until_search_back_dec_index:
		beqz a0, transitions_until_fix_jump	#found what we want
		addi a0, a0, -1
		j transitions_until_retreat
  transitions_until_fix_jump:
		sd a1, 8(t1)
		addi t1, t1, 16
		sd t1, 0(t0)
		tail search_create_leave

  transitions_again_out:
		#look for WA_BEGIN
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)
		li a0, 0
		li a1, -1
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
		li a1, -1
		la a2, WA_BEGIN
		la a3, WA__REPEAT
		la a7, WA__UNTIL
		la t5, WA__AGAIN
		la t6, WA__WHILE
		li a5, 512
		mv a6, t1
  transitions_repeat_search_back:
		addi a6, a6, -8
		ld a4, 0(a6)
		beq a4, a3, transitions_repeat_inc
		beq a4, a2, transitions_repeat_dec
		beq a4, a7, transitions_repeat_inc
		beq a4, t5, transitions_repeat_inc
		beq a4, t6, transitions_repeat_while
  transitions_repeat_retreat:
		addi a1, a1, -1
		beq a1, a5, trackback_failed
		j transitions_repeat_search_back
  transitions_repeat_while:
		bnez a0, transitions_repeat_retreat
		sub t4, zero, a1
		addi t4, t4, 1
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
		
