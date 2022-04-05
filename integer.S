#Simple integer calculations

                CODEHEADERZ PLUS, +, DOT, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                add t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ TIMES, *, PLUS, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
                mul t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ DIV, /, TIMES, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                div t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ MINUS, -, DIV, 0x01
		ld a1, 0(sp)
		ld a0, 8(sp)
                sub t0, a0, a1
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ PLUS1, 1+, MINUS, 0x01
		ld t0, 0(sp)
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ PLUS2, 2+, PLUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, 2
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ MINUS1, 1-, PLUS2, 0x01
		ld t0, 0(sp)
                addi t0, t0, -1
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ MINUS2, 2-, MINUS1, 0x01
		ld t0, 0(sp)
                addi t0, t0, -2
		sd t0, 0(sp)
                tail NEXT

                CODEHEADERZ UNDERPLUS, +UNDER, MINUS2, 0x01
                ld t0, 0(sp)
		ld t1, 8(sp)
		ld t2, 16(sp)
		add t0, t0, t2
		sd t1, 16(sp)
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADER MOD, UNDERPLUS, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		beqz t0, mod_zero
		div t2, t1, t0
		mul t3, t2, t0
		sub t0, t1, t3
  mod_zero:
		sd t0, 8(sp)
		addi sp, sp, 8
                tail NEXT

                CODEHEADERZ SLMOD, /MOD, MOD, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		bnez t0, slash_mod_continue
		sd zero, 8(sp)
		sd zero, 0(sp)
		tail NEXT
  slash_mod_continue:
                div t2, t1, t0
                mul t3, t2, t0
                sub t0, t1, t3
		sd t0, 8(sp)
		sd t2, 0(sp)
                tail NEXT

		CODEHEADERZ FMDIVMOD, FM/MOD, SLMOD, 0x01
		#(d n -- n n)
		ld t0, 0(sp)		#divisor
		ld t1, 8(sp)		#high part dividend
		ld t2, 16(sp)		#low part dividend
		addi sp, sp, 8
		bnez t1, fmdivmod_wide
  fmdivmod_simple:
		rem t3, t2, t0
		div t4, t2, t0
		sd t3, 8(sp)
		sd t4, 0(sp)
		tail NEXT
  fmdivmod_wide:
		bgez t1, fmdivmod_positive
		#negative calculation
		neg t1, t1
		#only care about the remainder on upper part
		rem t3, t1, t0
		beqz t3, fmdivmod_simple
		mv a0, t3
		mv a1, t2
		mv a2, t0
		call long_division_signed
		beqz a7, fmdiv_fail
		sd a1, 8(sp)
		neg a0, a0
		sd a0, 0(sp)
		tail NEXT
  fmdivmod_positive:
		#only care about the remainder on upper part
		rem t3, t1, t0
		beqz t3, fmdivmod_simple
		mv a0, t3
		mv a1, t2
		mv a2, t0
		call long_division_signed
		beqz a7, fmdiv_fail
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT
  fmdiv_fail:
		sd zero, 8(sp)
		sd zero, 0(sp)
		tail NEXT

		CODEHEADERZ SMDIVREM, SM/REM, FMDIVMOD, 0x01
		#(d n -- n n)
		ld t0, 0(sp)		#divisor
		ld t1, 8(sp)		#high part dividend
		ld t2, 16(sp)		#low part dividend
		addi sp, sp, 8
		bnez t1, smdivmod_wide
  smdivmod_simple:
		rem t3, t2, t0
		div t4, t2, t0
		srli t5, t0, 1
		bgt t5, t3, smdivmod_simple_done
		addi t4, t4, 1
  smdivmod_simple_done:
		sd t3, 8(sp)
		sd t4, 0(sp)
		tail NEXT
  smdivmod_wide:
		bgez t1, smdivmod_positive
		#negative calculation
		neg t1, t1
		#only care about the remainder on upper part
		rem t3, t1, t0
		beqz t3, smdivmod_simple
		mv a0, t3
		mv a1, t2
		mv a2, t0
		PUSH t0
		call long_division_signed
		POP t0
		beqz a7, fmdiv_fail
		srli t1, t0, 1
		bgt t1, a1, smdivmod_wide_complete
		addi a0, a0, 1
  smdivmod_wide_complete:
		sd a1, 8(sp)
		neg a0, a0
		sd a0, 0(sp)
		tail NEXT
  smdivmod_positive:
		#only care about the remainder on upper part
		rem t3, t1, t0
		beqz t3, smdivmod_simple
		mv a0, t3
		mv a1, t2
		mv a2, t0
		PUSH t0
		call long_division_signed
		POP t0
		beqz a7, fmdiv_fail
		srli t1, t0, 1
		bgt t1, a1, smdivmod_positive_complete
		addi a0, a0, 1
  smdivmod_positive_complete:
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT

		CODEHEADER WITHIN, SMDIVREM, 0x01
		#test, low, high
		ld t2, 0(sp)
		ld t1, 8(sp)
		ld t0, 16(sp)		#number being tested
		addi sp, sp, 16
		beq t1, t2, within_fail
		beq t0, t1, within_fail
		beq t0, t2, within_fail
		blt t1, t2, within_continue
		mv t3, t2
		mv t2, t1
		mv t1, t3
  within_continue:
		blt t0, t1, within_fail
		bgt t2, t0, within_true
  within_fail:
		sd zero, 0(sp)
		tail NEXT
  within_true:
		li a0, -1
		sd a0, 0(sp)
		tail NEXT	
		

                CODEHEADER NEGATE, WITHIN, 0x01
		ld t0, 0(sp)
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
		sd t0, 0(sp)
                tail NEXT

		CODEHEADERZ STOD, S>D, NEGATE, 0x01
		#(n -- d)
		ld t0, 0(sp)
		addi sp, sp, -8
		bgez t0, stod_simple
		#negative number
		li t1, -1
		sd t1, 0(sp)
		tail NEXT
  stod_simple:
		sd zero, 0(sp)
		tail NEXT
		

                CODEHEADER ABS, STOD, 0x01
		ld t0, 0(sp)
                li t1, 0x8000000000000000
                or t2, t0, t1
                beq t2, zero, abs_return_value
                li t1, -1
                xor t0, t0, t1
                addi t0, t0, 1
  abs_return_value:
		sd t0, 0(sp)
                tail NEXT

		CODEHEADERZ TONUMBER, >NUMBER, ABS, 0x01
		#(ud c-addr u -- ud c-addr u)
		ld t0, 0(sp) 			#length of string
		ld t1, 8(sp)			#address of string
		ld t2, 16(sp)			#number to add to
		mv t6, zero
		la t3, CURRENT_BASE
		ld t3, 0(t3)			#base
		#establish the range of characters
		li t4, 0x0A
		li a0, 0x30
		bgt t3, t4, tonumber_letter_base
		add a1, a0, t3
		j tonumber_process_start
  tonumber_letter_base:
		addi a1, t3, 0x36
  tonumber_process_start:
		li a2, 0x40			#impermissibles
		li a3, 0x3A
		mv a4, zero			#count of converted characters
  tonumber_read:
		lbu t5, 0(t1)
		blt t5, a0, tonumber_done	#less than 0
		bgt t5, a1, tonumber_done	#greater than max
		blt t5, a3, tonumber_continue
		ble t5, a2, tonumber_done	#impermissible
  tonumber_continue:
		mul t6, t6, t3
		blt t5, a3, tonumber_digit
		addi t5, t5, -55
		j tonumber_sum
  tonumber_digit:
		add t5, t5, -48
  tonumber_sum:
		add t6, t6, t5
		addi a4, a4, 1
		addi t1, t1, 1
		addi t0, t0, -1
		beqz t0, tonumber_done
		j tonumber_read
  tonumber_done:
		add t6, t6, t2
		sd t6, 16(sp)
		sd t1, 8(sp)
		sd t0, 0(sp)
		tail NEXT

		CODEHEADERZ NUMSTART, \<\#, TONUMBER, 0x01
		#(--)
		#start pictured numeric output conversion
		li t0, 1
		la t1, PICTUREDN
		sd t0, 0(t1)
		sd zero, 8(t1)		#count to zero
		tail NEXT

		CODEHEADERZ NUM, \#, NUMSTART, 0x01
		#( u -- u )
		la t0, PICTUREDN		#t0 has address of PICTUREDN var
		ld t1, 0(t0)			
		beqz t1, num_done		#we are not in pictured number mode
		ld a0, 8(t0)			#a0 has count in PAD 
		ld t1, 0(sp)			#t1 has number
		bgez t1, num_positive
		neg t1, t1			#have to work with positive numbers
  num_positive:
		la t2, CURRENT_BASE		#t2 has BASE
		ld t2, 0(t2)
		div t3, t1, t2			
		mul t4, t2, t3			
		sub t5, t1, t4			#t5 has remainder
		li t6, 10
		bge t5, t6, num_use_letters
		#remainder is <10
		addi t5, t5, 0x30
		j num_pass_to_pad
  num_use_letters:
		addi t5, t5, 0x37
  num_pass_to_pad:
		la a1, SCRATCH_PAD
		add a2, a1, a0
		sb t5, 0(a2)			#store char
		addi a0, a0, 1
		sd a0, 8(t0)			#increment PAD writing point
		sd t3, 0(sp)			#pass what's left back to the stack
  num_done:
		tail NEXT

		CODEHEADERZ NUMS, \#S, NUM, 0x01
		#( u -- 0)
		la t0, PICTUREDN		#t0 has address of PICTUREDN var
		ld t1, 0(t0)			
		beqz t1, num_done		#we are not in pictured number mode
		ld a0, 8(t0)			#a0 has count in PAD 
  nums_keep_going:
		ld t1, 0(sp)			#t1 has number
		bgez t1, nums_positive
		neg t1, t1			#have to work with positive numbers
  nums_positive:
		la t2, CURRENT_BASE		#t2 has BASE
		ld t2, 0(t2)
		div t3, t1, t2			
		mul t4, t2, t3			
		sub t5, t1, t4			#t5 has remainder
		li t6, 10
		bge t5, t6, nums_use_letters
		#remainder is <10
		addi t5, t5, 0x30
		j nums_pass_to_pad
  nums_use_letters:
		addi t5, t5, 0x37
  nums_pass_to_pad:
		la a1, SCRATCH_PAD
		add a2, a1, a0
		sb t5, 0(a2)			#store char
		addi a0, a0, 1
		sd a0, 8(t0)			#increment PAD writing point
		sd t3, 0(sp)			#pass what's left back to the stack
		beqz t3, num_done
		j nums_keep_going

		CODEHEADERZ NUMEND, \#\>, NUMS, 0x01
		#( xd -- c-addr u )
		#reverse stored string
		addi sp, sp, STACKOFFSET	#drop xd as per standard
		la t0, PICTUREDN
		ld t1, 0(t0)
		beqz t1, num_done
		ld a0, 8(t0)
		li t2, 1
		mv a3, a0
		ble a0, t2, numend_end
		addi a0, a0, -1
		la a1, SCRATCH_PAD
		add a0, a0, a1
  numend_keep_on:
		lbu t4, 0(a0)
		lbu t5, 0(a1)
		sb t4, 0(a1)
		sb t5, 0(a0)
		addi a0, a0, -1
		addi a1, a1, 1
		ble a0, a1, numend_end
		j numend_keep_on
  numend_end:
		#write address and length to the stack
		addi sp, sp, -16
		la t4, SCRATCH_PAD
		sd t4, 8(sp)
		sd a3, 0(sp)
		sd zero, 0(t0)
		sd zero, 8(t0)
		tail NEXT

		CODEHEADER SIGN, NUMEND, 0x01
		#(n --)
		POP t5
		la t0, PICTUREDN
		ld t1, 0(t0)
		beqz t1, num_done
		bltz t5, sign_neg
		tail NEXT
  sign_neg:
		ld a0, 8(t0)
		li t3, 0x2D		#-
		la t4, SCRATCH_PAD
		add t4, t4, a0
		sb t3, 0(t4)
		addi a0, a0, 1
		sd a0, 8(t0)
		tail NEXT
		
		CODEHEADER HOLDS, SIGN, 0x01
		#(c-addr u --)
		ld t5, 0(sp)
		ld t6, 8(sp)
		addi sp, sp, 16
		la t0, PICTUREDN
		ld t1, 0(t0)
		beqz t1, num_done
		ld a0, 8(t0)
		la t2, SCRATCH_PAD
		add t3, t2, a0
		add a0, a0, t5
		add t1, t5, t6
		addi t1, t1, -1
  holds_loop:
		beqz t5, holds_done
		lb t2, 0(t1)
		sb t2, 0(t3)
		addi t3, t3, 1
		addi t1, t1, -1
		addi t5, t5, -1
		j holds_loop
  holds_done:
		sd a0, 8(t0)
		tail NEXT
		
		CODEHEADER HOLD, HOLDS, 0x01
		#(char --)
		POP t5
		la t0, PICTUREDN
		ld t1, 0(t0)
		beqz t1, num_done
		ld a0, 8(t0)
		la t2, SCRATCH_PAD
		add t3, t2, a0
		sb t5, 0(t3)
		addi a0, a0, 1
		sd a0, 8(t0)
		tail NEXT

                CODEHEADER MIN, HOLD, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
                blt t0, t1, min_return_first	
                tail NEXT
  min_return_first:
		sd t0, 0(sp)
                tail NEXT

                CODEHEADER MAX, MIN, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
                bge t0, t1, max_return_first
                tail NEXT
  max_return_first:
		sd t0, 0(sp)
                tail NEXT

		CODEHEADERZ UDOTR, U.R, MAX, 0x01
		#(u n --)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		li t2, 1
		bgt t0, t2, udotr_field_exists
		#0 or 1 field - just call UD
		addi sp, sp, -8
		sd t1, 0(sp)
		tail UD
  udotr_field_exists:
		#limit the width
		li t2, SYSTEMAREA
		ble t0, t2, udotr_field_size_good
		mv t0, t2
  udotr_field_size_good:
		bnez t1, udotr_not_zero
		#number is 0 - simple case
		la t2, SCRATCH_PAD
		li t4, 0x20
		addi t3, t0, -1
  udotr_write_space:
		beqz t3, udotr_write_zero
		sb t4, 0(t2)
		addi t2, t2, 1
		addi t3, t3, -1
		j udotr_write_space
  udotr_write_zero:
		li t4, 0x30
		sb t4, 0(t2)
		la t2, SCRATCH_PAD
		WRITESTRINGR t2, t0
		tail NEXT
  udotr_not_zero:
		#now base conversion etc
		la t2, CURRENT_BASE
		ld t2, 0(t2)
		li a0, 0x30		#0
		li a1, 0x37		#offset 0
		mv a2, zero		#characters written
		li a4, 10		#do we need to use offset?
		#use EXPANDED_BUFFER as temporary storage
		la t3, EXPANDED_BUFFER
  udotr_generate_characters:
		remu t4, t1, t2
		divu t1, t1, t2
		bgeu t4, a4, udotr_bigger_remainder
		add t6, t4, a0
		j udotr_paste_in
  udotr_bigger_remainder:
		add t6, t4, a1
  udotr_paste_in:
		sb t6, 0(t3)
		addi t3, t3, 1
		addi a2, a2, 1
		bnez t1, udotr_generate_characters
		#now pad buffer if needed
		sub t5, t0, a2
		la t2, SCRATCH_PAD
		blez t5, udotr_output_number
		li t1, 0x20
  udotr_pad_pad:
		sb t1, 0(t2)
		addi t2, t2, 1
		addi t5, t5, -1
		bgtz t5, udotr_pad_pad
  udotr_output_number:
		la t3, EXPANDED_BUFFER
		add t4, t3, a2
		addi t4, t4, -1
  udotr_pick_next_digit:
		lb t5, 0(t4)
		sb t5, 0(t2)
		addi t2, t2, 1
		addi t4, t4, -1
		bge t4, t3, udotr_pick_next_digit
		ble a2, t0, udotr_final_output
		mv t0, a2
  udotr_final_output:
		la t1, SCRATCH_PAD
		WRITESTRINGR t1, t0
		tail NEXT

		CODEHEADERZ UD, U., UDOTR, 0x01
		#(u --)
		ld t0, 0(sp)
		blez t0, ud_neg_to_unsigned
		#just let . handle it
  ud_dot:
		tail DOT
  ud_neg_to_unsigned:
		la t1, CURRENT_BASE
		li a3, 10
		ld t1, 0(t1)
		bne a3, t1, ud_dot
		#harder bit
		li a0, 0x30	#0
		li a1, 0x37	#'0' for numbers greater than 9
		mv a2, zero	#characters written
  		addi sp, sp, 8
		la t2, SCRATCH_PAD
		mv t5, t2
  ud_generate_characters:
		remu t3, t0, t1
		divu t0, t0, t1
		bgeu t3, a3, ud_bigger_remainder
		add t4, t3, a0
		j ud_paste_in
  ud_bigger_remainder:
		add t4, t3, a1
  ud_paste_in:
		sb t4, 0(t2)
		addi t2, t2, 1
		addi a2, a2, 1
		bne t0, zero, ud_generate_characters
		#now reverse the order
		mv t0, t5
		mv t1, t2
		addi t1, t1, -1
  ud_reverse:
		bgeu t0, t1, ud_reverse_done
		lb t3, 0(t0)
		lb t4, 0(t1)
		sb t3, 0(t1)
		sb t4, 0(t0)
		addi t0, t0, 1
		addi t1, t1, -1
		j ud_reverse
  ud_reverse_done:
		li t4, 0x20	#space
		sb t4, 0(t2)
		addi a2, a2, 1
		WRITESTRINGR t5, a2 
		tail NEXT

		CODEHEADERZ UMDIVMOD, UM/MOD, UD, 0x01
		#(ud u -- u u)
		ld a2, 0(sp)		#divisor
		ld a0, 8(sp)		#upper part of ud
		ld a1, 16(sp)		#lower part of ud
		remu a0, a0, a2
		call long_division_unsigned
		addi sp, sp, 8
		beqz a7, umdivmod_failed
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT
  umdivmod_failed:
		sd zero, 8(sp)
		sd zero, 0(sp)
		tail NEXT

		CODEHEADERZ MTIMES, M*, UMDIVMOD, 0x01
		#(n n -- d)
		ld t0, 0(sp)
		ld t1, 8(sp)
		mulh a0, t0, t1
		mul a1, t0, t1
		#now manipulate to get the sign right
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT

		CODEHEADERZ UMTIMES, UM*, MTIMES, 0x01
		#(u u -- d)
		ld t0, 0(sp)
		ld t1, 8(sp)
		mulhu a0, t0, t1
		mul a1, t0, t1
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT
		
		CODEHEADERZ UMORE, U>, UMTIMES, 0x01
		#(u u -- flag)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
		bleu t1, t0, uless_fail
		li t2, -1
		sd t2, 0(sp)
		tail NEXT

		CODEHEADERZ ULESS, U<, UMORE, 0x01
		#(u u -- flag)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
		bgeu t1, t0, uless_fail
		li t2, -1
		sd t2, 0(sp)
		tail NEXT
  uless_fail:
		sd zero, 0(sp)
		tail NEXT

                CODEHEADER BYE, ULESS, 0x01
                PRINT riscy_forth0
                PRINT riscy_forthQ
                PRINT riscy_forth0
                tail exit

#calculate double muliplication of unsigned numbers
  multiple_bit_calculate_unsigned:
		#a0 and a1 are the factors
		#returns lower part in a0
		#upper part in a1

		#use s registers for invariants
		addi sp, sp, -24
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s4, 16(sp)
		mv s0, a0			#invariant - multiplier
		mv s1, a1			#invariant - multiplicand
		li s4, 63			#max bit count

		#use a registers for calculation, t registers as scratchpads
		li a0, 0	#carry
		li a1, 1	#bit in multiplier
		li a2, 1	#bit in multiplicand
		li a3, 0	#bit count in multiplier
		li a4, 0	#bit count in multiplicand
		li a6, 0	#lower part of answer
		li a7, 0	#upper part of answer

  umstar_column_multiply:
		and t0, a1, s0
		bnez t0, umstar_test_multiplicand_bit
		# multiplier bit is 0
		# check carry bit
		beqz a0, umstar_increment_multiplicator_bit	#no carry - do nothing
		li a0, 0
		j umstar_one_no_carry
  umstar_test_multiplicand_bit:
		and t1, a2, s1
		bnez t1, umstar_both_bits_one			#1 result
		beqz a0, umstar_increment_multiplicand_bit	#0 result and no carry
		li a0, 0					#0 result with carry
  umstar_one_no_carry:
		#need to add 1 to the value here
		add t2, a3, a4
		bgtu t2, s4, umstar_one_no_carry_higher_word
		li t3, 1
		sll t3, t3, t2
		and t4, a6, t3
		beqz t4, umstar_lower_word_enter_one
		#value is already 1 so, set to zero and set carry bit
		not t4, t3
		and a6, a6, t4
		li a0, 1
		j umstar_increment_multiplicand_bit
  umstar_lower_word_enter_one:
		or a6, a6, t3
		j umstar_increment_multiplicand_bit
  umstar_one_no_carry_higher_word:
		sub t2, t2, s4
		addi t2, t2, -1
		#then code as above but different register
		li t3, 1
		sll t3, t3, t2
		and t4, a7, t3
		beqz t4, umstar_upper_word_enter_one
		#value is already 1 so, set to zero and set carry bit
		not t4, t3
		and a7, a7, t4
		li a0, 1
		j umstar_increment_multiplicand_bit
  umstar_upper_word_enter_one:
		or a7, a7, t3
		j umstar_increment_multiplicand_bit
  umstar_both_bits_one:
		beqz a0, umstar_one_no_carry		#1 result and no carry set
		#1 result with carry set - so actually adding 10
		#so just increment muliplicand
		j umstar_increment_multiplicand_bit

  umstar_increment_multiplicand_bit:
		addi a4, a4, 1
		slli a2, a2, 1
		bgtu a2, s1, umstar_test_carry_bit_on_increment
		bleu a4, s4, umstar_column_multiply
  umstar_test_carry_bit_on_increment:
		#carry bit?
		beqz a0, umstar_increment_multiplicator_bit
		#have a carry bit left over
		li a0, 0
		j umstar_one_no_carry
  umstar_increment_multiplicator_bit:
		addi a3, a3, 1
		slli a1, a1, 1
		bgtu a1, s0, umstar_prepare_answer
		bgtu a3, s4, umstar_prepare_answer
		li a4, 0
		li a2, 1
		j umstar_column_multiply
  umstar_prepare_answer:
		#unwind stack
		ld s0, 0(sp)
		ld s1, 8(sp)
		ld s4, 16(sp)
		sd a7, 24(sp)
		sd a6, 32(sp)
		mv a0, a7			#put answers in registers also
		mv a1, a6
		addi sp, sp, 24
		ret	

#calculate double muliplication of signed numbers

multiple_bit_calculate_signed:
		#a0 and a1 are the factors
		#a2 sign of answer
		#returns upper part in a0
		#lower part in a1

		#use s registers for invariants
		addi sp, sp, -32
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s4, 24(sp)
		mv s0, a0			#invariant - multiplier
		mv s1, a1			#invariant - multiplicand
		mv s2, a2			#invariant - sign of answer
		li s4, 63			#max bit count

		#use a registers for calculation, t registers as scratchpads
		li a0, 0	#carry
		li a1, 1	#bit in multiplier
		li a2, 1	#bit in multiplicand
		li a3, 0	#bit count in multiplier
		li a4, 0	#bit count in multiplicand
		li a6, 0	#lower part of answer
		li a7, 0	#upper part of answer

  mstar_column_multiply:
		and t0, a1, s0
		bnez t0, mstar_test_multiplicand_bit
		# multiplier bit is 0
		# check carry bit
		beqz a0, mstar_increment_multiplicator_bit	#no carry - do nothing
		li a0, 0
		j mstar_one_no_carry
  mstar_test_multiplicand_bit:
		and t1, a2, s1
		bnez t1, mstar_both_bits_one			#1 result
		beqz a0, mstar_increment_multiplicand_bit	#0 result and no carry
		li a0, 0					#0 result with carry
  mstar_one_no_carry:
		#need to add 1 to the value here
		add t2, a3, a4
		bgt t2, s4, mstar_one_no_carry_higher_word
		li t3, 1
		sll t3, t3, t2
		and t4, a6, t3
		beqz t4, mstar_lower_word_enter_one
		#value is already 1 so, set to zero and set carry bit
		not t4, t3
		and a6, a6, t4
		li a0, 1
		j mstar_increment_multiplicand_bit
  mstar_lower_word_enter_one:
		or a6, a6, t3
		j mstar_increment_multiplicand_bit
  mstar_one_no_carry_higher_word:
		sub t2, t2, s4
		addi t2, t2, -1
		#then code as above but different register
		li t3, 1
		sll t3, t3, t2
		and t4, a7, t3
		beqz t4, mstar_upper_word_enter_one
		#value is already 1 so, set to zero and set carry bit
		not t4, t3
		and a7, a7, t4
		li a0, 1
		j mstar_increment_multiplicand_bit
  mstar_upper_word_enter_one:
		or a7, a7, t3
		j mstar_increment_multiplicand_bit
  mstar_both_bits_one:
		beqz a0, mstar_one_no_carry		#1 result and no carry set
		#1 result with carry set - so actually adding 10
		#so just increment muliplicand
		j mstar_increment_multiplicand_bit

  mstar_increment_multiplicand_bit:
		addi a4, a4, 1
		slli a2, a2, 1
		bgt a2, s1, mstar_test_carry_bit_on_increment
		ble a4, s4, mstar_column_multiply
  mstar_test_carry_bit_on_increment:
		#carry bit?
		beqz a0, mstar_increment_multiplicator_bit
		#have a carry bit left over
		li a0, 0
		j mstar_one_no_carry
  mstar_increment_multiplicator_bit:
		addi a3, a3, 1
		slli a1, a1, 1
		bgt a1, s0, mstar_prepare_answer
		bgt a3, s4, mstar_prepare_answer
		li a4, 0
		li a2, 1
		j mstar_column_multiply
  mstar_prepare_answer:
		#set sign if needed
		beqz s2, mstar_unwind_stack
		neg a6, a6
		#manage issue of upper part as zero
		beqz a7, mstar_twos_complement_zero_manage
		neg a7, a7
		j mstar_unwind_stack
  mstar_twos_complement_zero_manage:
		li a7, -1
  mstar_unwind_stack:		
		#unwind stack
		ld s0, 0(sp)
		ld s1, 8(sp)
		ld s2, 16(sp)
		ld s4, 24(sp)
		sd a7, 32(sp)
		sd a6, 40(sp)
		mv a0, a7			#put answers in registers also
		mv a1, a6
		addi sp, sp, 32
		ret	
		
		
		
