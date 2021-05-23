#Copyright Adrian McMenamin, 2021
#Licenced under the GPL v2

#transitions.S - handle various nested conditional transitions

  .macro TRANSITION_PROLOGUE
			addi sp, sp, -56
			sw s0, 0(sp)
			sw s1, 8(sp)
			sw s2, 16(sp)
			sw s3, 24(sp)
			sw s4, 32(sp)
			sw s5, 40(sp)
			sw s6, 48(sp)
  .endm

  .macro TRANSITION_EPILOGUE
			lw s6, 48(sp)
			lw s5, 40(sp)
			lw s4, 32(sp)
			lw s3, 24(sp)
			lw s2, 16(sp)
			lw s1, 8(sp)
			lw s0, 0(sp)
			addi sp, sp, 56
  .endm

  .macro SETUP_CONDITIONAL_CALL
			la a0, DECIDESTACKB
			lw a0, 0(a0)
			la a2, DECIDESTACKP
			lw a1, 0(a2)
  .endm

  transition_bump_else:
			#increment else by value of a2
			#a0 holds DECIDESTACKB value
			#a1 holds DECIDESTACKP value
			
			TRANSITION_PROLOGUE
			mv s0, a0
			lw s1, 0(a1)
			mv a1, s1
			lw s1, 0(a1)
			mv s2, a2

			addi s1, s1, -1		#correct to zero start
			li s3, CONDITIONALBLK
			mul s4, s3, s1
			add s5, s4, s0		#s5 points to block
			#now prepare the change
			lw s1, 48(s5)
			andi s2, s2, 0x3FF
			li s3, 0xFFFFF
			and s1, s1, s3
			slli s4, s2, s0
			or s3, s1, s4
			sw s3, 28(s5)
			TRANSITION_EPILOGUE
			ret
			
  transition_bump_then:
			#increment then by value of a2
			#a0 holds DECIDESTACKB value
			#a1 holds DECIDESTACKP value
			
			TRANSITION_PROLOGUE
			mv s0, a0
			lw s1, 0(a1)
			mv a1, s1
			lw s1, 0(a1)
			mv s2, a2

			addi s1, s1, -1		#correct to zero start
			li s3, CONDITIONALBLK
			mul s4, s3, s1
			add s5, s4, s0		#s5 points to block
			#now prepare the change
			lw s1, 48(s5)
			andi s2, s2, 0x3FF
			li s3, 0xFFFFF
			and s1, s1, s3
			slli s4, s2, s0
			or s3, s1, s4
			sw s3, 48(s5)
			TRANSITION_EPILOGUE
			ret

  transition_bump_base_address:
			TRANSITION_PROLOGUE
			mv s0, a0
			lw s1, 0(s0)
			lw s2, 8(s0)		#high tide
			li s3, CONDITIONALBLK
			mul s4, s3, s2
			add s5, s1, s4
			sw s5, 0(s0)
			#zero everything else
			sw zero, 4(s0)
			sw zero, 8(s0)
			sw zero, 12(s0)
			sw zero, 16(s0)
			sw zero, 20(s0)
			sw zero, 24(s0)
			sw zero, 28(s0)
			TRANSITION_EPILOGUE
			ret			


  transition_then_else:
			TRANSITION_PROLOGUE
			#we are implementing jumps in the layer above
			#but first we need to test there is one!
			call get_iffmode
			add a0, a0, -1
			bnez a0, transition_then_else_upperlayer_exists
			#we are in a bad nesting
			TRANSITION_EPILOGUE
			tail search_create_bad_ifmode
  transition_then_else_upperlayer_exists:
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a0
			SETUP_CONDITIONAL_CALL
			call clean_conditional_stack
			call decriment_iffmode
			SETUP_CONDITIONAL_CALL
			mv a2, s0
  transition_setup_else:
			call transition_bump_else
  transition_output_else:
			li a0, 0xFF
			call set_flag_mode_off
			li a0, 0x02
			call set_flag_mode_on
			TRANSITION_EPILOGUE
			#now stock the created else into the stream
			SETUP_CONDITIONAL_CALL
			call get_conditional_addresses
			mv t3, a1
			tail search_create_continue_inscription
			
			

  transition_if_else
			#setup a standard else
			TRANSITION_PROLOGUE
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a2
			li s1, 1
			beq s0, s1, leave_if_else	#if only 1 instruction nothing needed
			SETUP_CONDITIONAL_CALL
			mv a2, s0
			call transition_setup_else
  leave_if_else:
			call transition_output_else


	
  transition_ifthen:
			#standard then
			TRANSISTION_PROLOGUE
			SETUP_CONDITIONAL_CALL
			call get_increments
			mv s0, a2
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
			j finish_leave_if_then
  continue_leave_if_then:
			SETUP_CONDITIONAL_CALL
			call clean_conditional_stack
  finish_leave_if_then:
			TRANSITION_EPILOGUE
			ret
					
