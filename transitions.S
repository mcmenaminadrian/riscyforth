#Copyright Adrian McMenamin, 2021
#Licenced under the GPL v2

#transitions.S - handle various nested conditional transitions

#IF FLAG CODE
  #returns value of ifflag in a0
  get_iffmode:
		add sp, sp, -8
		sd s0, 0(sp)
		la s0, ifflag
		ld a0, 0(s0)
		ld s0, 0(sp)
		add sp, sp, 8
		ret

  decrement_iffmode:
		add sp, sp, -8
		sd s0, 0(sp)
		la s0, ifflag
		ld a0, 0(s0)
		add a0, a0, -1
		sd a0, 0(s0)
		ld s0, 0(sp)
		add sp, sp, 8
		ret

  increment_iffmode:
		add sp, sp, -8
		sd s0, 0(sp)
		la s0, ifflag
		ld a0, 0(s0)
		add a0, a0, 1
		sd a0, 0(s0)
		ld s0, 0(sp)
		add sp, sp, 8
		ret

#ELSE-THEN FLAG CODE

  set_flag_mode_on:
		#a0 contains bits to set on
		add sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)

		la s0, DECIDESTACKP
		ld s0, 0(s0)
		ld s2, 0(s0)
		li s1, -40		#size of stack entry
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, -32	#to else mode adjusted for hightide
		add s2, s3, s0		#s2 has address
		ld s1, 0(s2)
		or a0, s1, a0		#set the bits
		sd a0, 0(s2)		#a0 also returns new state

		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret
		
  set_flag_mode_off:
		#a0 has bits to turn off
		add sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)

		la s0, DECIDESTACKP
		ld s0, 0(s0)
		li s1, -40		#size of stack entry
		ld s2, 0(s0)
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, -32	#to else mode adjusted for hightide
		add s2, s3, s0		#s2 has address
		not s1, a0
		ld s3, 0(s2)
		and a0, s3, s1		# flag &=(!a0)
		sd a0, 0(s2)		#a0 returns new state 

		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret

  get_flag_mode:
		add sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		
		la s0, DECIDESTACKP
		ld s0, 0(s0)
		li s1, -40		#size of stack entry
		ld s2, 0(s0)
		addi s2, s2, -1		#offset for multiply
		mul s3, s2, s1
		addi s3, s3, -32	#to flag adjusted for hightide
		add s2, s3, s0		#s2 has address
		ld a0, 0(s2)		#a0 returns unaltered state
		mv a1, zero
		mv a2, zero
		li s0, 0x02
		and s1, s0, a0
		beqz s1, test_flag_mode_then
		li a2, 1		#ELSE
 		j get_flag_mode_leave
  test_flag_mode_then:
		li s0, 0x01
		and s1, s0, a0
		beqz s1, get_flag_mode_leave
		li a1, 1		#THEN
  get_flag_mode_leave:		
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 32
		ret

  transition_bump_else:
			#increment else by value of a2
			#a0 holds DECIDESTACKB value
			#a1 holds DECIDESTACKP value
			
			TRANSITION_PROLOGUE
			mv s0, a0
			ld s0, 0(s0)
			ld s1, 0(a1)
			mv s2, a2
			li s3, 8
			mul s2, s2, s3		#4 bytes per instruction

			addi s1, s1, -1		#correct to zero start
			li s3, CONDITIONALBLK
			mul s4, s3, s1
			add s5, s4, s0		#s5 points to block
			#now prepare the change
			lw s1, 56(s5)		#we update the addi s7,s7,8
			andi s2, s2, 0x3FF
			li s3, 0xFFFFF
			and s1, s1, s3
			slli s4, s2, 20
			or s3, s1, s4
			sw s3, 56(s5)
			TRANSITION_EPILOGUE
			ret
			
  transition_bump_then:
			#increment then by value of a2
			#a0 holds DECIDESTACKB value
			#a1 holds DECIDESTACKP value
			
			TRANSITION_PROLOGUE
			mv s0, a0
			ld s0, 0(s0)
			ld s1, 0(a1)
			mv s2, a2
			li s3, 8
			mul s2, s2, s3		#8 bytes per instruction (address)

			addi s1, s1, -1		#correct to zero start
			li s3, CONDITIONALBLK
			mul s4, s3, s1
			add s5, s4, s0		#s5 points to block
			#now prepare the change
			lw s1, 32(s5)		#update the addi s7,s7,8
			andi s2, s2, 0x3FF
			li s3, 0xFFFFF
			and s1, s1, s3
			slli s4, s2, 20
			or s3, s1, s4
			sw s3, 32(s5)
			TRANSITION_EPILOGUE
			ret

  transition_bump_base_address:
			TRANSITION_PROLOGUE
			mv s0, a0
			ld s1, 0(s0)
			ld s2, -16(s0)		#high tide
			li s3, CONDITIONALBLK
			mul s4, s3, s2
			add s5, s1, s4
			sd s5, 0(s0)
			#zero everything else
			sd zero, -8(s0)
			sd zero, -16(s0)
			sd zero, -24(s0)
			sd zero, -32(s0)
			sd zero, -40(s0)
			sd zero, -48(s0)
			sd zero, -56(s0)
			TRANSITION_EPILOGUE
			ret			


  transition_then_else:
			TRANSITION_PROLOGUE
			#we are implementing jumps in the layer above
			#but first we need to test there is one!
			call get_iffmode
			add a0, a0, -1
			bnez a0, transition_then_else_valid
			#we are in a bad nesting
			tail general_bad_nesting		#see below
  transition_then_else_valid:
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a0
			SETUP_CONDITIONAL_CALL
			call clean_conditional_stack
			call decrement_iffmode
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_else
  transition_output_else:
			li a0, 0xFF
			call set_flag_mode_off
			li a0, 0x02
			call set_flag_mode_on
			TRANSITION_EPILOGUE
			#now drop the created else into the stream
			SETUP_CONDITIONAL_CALL
			call get_conditional_addresses
			mv t3, a1
			tail search_create_inscribe
			
			

  transition_if_else:
			#setup a standard else
			TRANSITION_PROLOGUE
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a1
			li s1, 1
			beq s0, s1, leave_if_else	#if only 1 instruction nothing needed
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_then	#we bump then as in simple IF ... ELSE
  leave_if_else:
			tail transition_output_else


  transition_if_while:
			call output_while
	
  transition_if_then:
			#standard then
			TRANSITION_PROLOGUE
			#test we are in a valid conditional
			call get_iffmode
			bnez a0, transition_if_then_valid
			#bad conditional
  general_bad_nesting:
			TRANSITION_EPILOGUE
			tail search_create_bad_ifmode
  transition_if_then_valid:
			#good conditional - at least we hope so
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a1
			li s1, 1
			beq s0, s1, leave_if_then	#only one instruction - nothing to do
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_then
  leave_if_then:
			call decrement_iffmode
			bnez a0, continue_leave_if_then
			SETUP_CONDITIONAL_CALL
			call transition_bump_base_address
			j leave_if_then_over
  continue_leave_if_then:
			#in nested conditionals - so have to keep counting
			call increment_iffmode		#reverse decrement as we are still counting
			li a0, 0x01			#then mode
			call set_flag_mode_on
  leave_if_then_over:
			TRANSITION_EPILOGUE
			tail search_create_inscribe

  transition_then_while:
			call output_while

  transition_then_then:
			TRANSITION_PROLOGUE
			#as above - we are implementing jumps in the layer above
			#but first we need to test there is one!
			call get_iffmode
			add a0, a0, -1
			bnez a0, transition_then_then_valid
			#we are in a bad nesting
			tail general_bad_nesting
  transition_then_then_valid:
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a0
			SETUP_CONDITIONAL_CALL
			call clean_conditional_stack
			call decrement_iffmode
			call get_flag_mode			#should we increase then or else
			beqz a2, transition_then_then_bump_then
			SETUP_CONDITIONAL_CALL
			call get_increments
			add s0, s0, a2
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_else
			tail leave_if_then
  transition_then_then_bump_then:
			SETUP_CONDITIONAL_CALL
			call get_increments
			add s0, s0, a2
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_then
			tail leave_if_then

  transition_else_then:
			TRANSITION_PROLOGUE
			#test we are in a valid conditional
			call get_iffmode
			bnez a0, transition_else_then_valid
			tail general_bad_nesting
  transition_else_then_valid:
			#this is standard else ... then sequence
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a2		#s0 now has what we need to add (else count)
			li s1, 1
			beq s0, s1, transition_else_then_inc_done #no need to adjust
			#update the increment
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_bump_else
  transition_else_then_inc_done:
			call decrement_iffmode
			bnez a0, transition_else_then_layer_prep
			#leave cleanly
			SETUP_CONDITIONAL_CALL
			call transition_bump_base_address
			j transition_else_then_leave
  transition_else_then_layer_prep:
			call increment_iffmode		#reverse decrement
			#we have to switch modes now
			li a0, 0xFF
			call set_flag_mode_off
			li a0, 0x01
			call set_flag_mode_on
  transition_else_then_leave:
			TRANSITION_EPILOGUE
			tail search_create_inscribe


  output_while:
		#a0 has WA__WHILE
                addi sp, sp, -88
                sd ra, 80(sp)
		sd s9, 72(sp)
                sd s8, 64(sp)
                sd s7, 56(sp)
                sd s6, 48(sp)
                sd s5, 40(sp)
                sd s4, 32(sp)
                sd s3, 24(sp)
                sd s2, 16(sp)
                sd s1, 8(sp)
                sd s0, 0(sp)

                la s3, createwritepoint
                ld s3, 0(s3)
                sd a0, 0(s3)				#write out WA__WHILE


                #now search for WA_BEGIN
                li s0, 0x200                            #max depth of search backwards
                li s1, -8				#account for offset too
                li s2, 8
                la s5, WA_BEGIN
                mv s6, s3
                mv s7, zero
                la s8, WA__WHILE
		la s9, WA__END
  while_check_begin:
                addi s3, s3, -8
                ld s4, 0(s3)
		beq s4, s9, while_skip_loop
                bne s4, s8, while_keep_checking
  while_skip_loop:
                addi s7, s7, 1
                j while_check_next
  while_keep_checking:
                beq s5, s4, while_found_begin
  while_check_next:
                add s1, s1, -8
                add s2, s2, 8
                blt s2, s0, while_check_begin
                #we have failed
                mv a0, zero
                j real_end_of_while
  while_found_begin:
                beqz s7, while_correct_begin
                addi s7, s7, -1                         #skip an inner loop
                j while_check_next
  while_correct_begin:
                sd s1, 8(s6)                            #write out offset
                la s0, createwritepoint
                addi s6, s6, 16
                sd s6, 0(s0)
                #now - are we in a conditional?
                call get_iffmode
                beqz a0, almost_end_of_while
                SETUP_CONDITIONAL_CALL
                call increment_current_skip             #we have to account for the literal (skip) if in a conditional
  almost_end_of_while:
                li a0, 1
  real_end_of_while:
                ld s0, 0(sp)
                ld s1, 8(sp)
                ld s2, 16(sp)
                ld s3, 24(sp)
                ld s4, 32(sp)
                ld s5, 40(sp)
                ld s6, 48(sp)
                ld s7, 56(sp)
                ld s8, 64(sp)
		ld s9, 72(sp)
                ld ra, 80(sp)
                addi sp, sp, 88
                ret
			

					
