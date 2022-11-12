#utility (shared) code for riscyforth
#copyright (c) Adrian McMenamin, 2021
#Licenced for reuse under the terms of the GNU GPL v2
#No warranty is offered


  #INPUT
  #a0 - remainder
  #a1 - dividend
  #a2 - divisor
  #OUTPUT
  #a0 quotient
  #a1 remainder
  #a7 1 if answer valid
  long_division_unsigned:
			mv t0, a0
			mv t1, a1
			mv t2, a2
			li a7, 0
			#check validity
			beqz a2, long_division_unsigned_done
			li a7, 1
			#set up the calculation
			li t3, 0x8000000000000000
			li a3, 63
			li a0, 0
			li a1, 0
  long_division_unsigned_calculate:
			and t4, t1, t3
			srl t5, t4, a3		#just want the bit
			slli t0, t0, 1
			add t0, t0, t5
			divu t5, t0, t2
			beqz t5, long_division_unsigned_advance
			sll t6, t5, a3
			or a0, a0, t6
			remu t0, t0, t2
  long_division_unsigned_advance:
			srli t3, t3, 1
			beqz t3, long_division_unsigned_done
			addi a3, a3, -1
			j long_division_unsigned_calculate
  long_division_unsigned_done:
			mv a1, t0
			ret



  #INPUT
  #a0 - remainder
  #a1 - dividend
  #a2 - divisor
  #a3 - high word (for sign)
  #OUTPUT
  #a0 quotient
  #a1 remainder
  #a7 1 if answer valid
  long_division_signed:
			mv t0, a0	#remainder
			mv t1, a1	#dividend
			mv t2, a2	#divisor
			li a7, 0	#validity
			li a6, 0	#sign (0 for positive)
			beqz a2, long_division_out	#no division by zero
			#calculate sign
			li t3, 0x8000000000000000
			and a4, a3, t3
			srli a4, a4, 63
			and a5, a2, t3
			srli a5, a5, 63
			xor a6, a4, a5
			li a7, 1
			#set up the calculation
			li t3, 0x8000000000000000
			li a3, 63
			li a0, 0
			li a1, 0
  long_division_calculate:
			and t4, t1, t3
			srl t5, t4, a3		#just want the bit
			slli t0, t0, 1
			add t0, t0, t5
			beqz a6, long_division_signed_unsigned
			div t5, t0, t2
			j long_division_continue
  long_division_signed_unsigned:
			divu t5, t0, t2
  long_division_continue:
			beqz t5, long_division_advance
			sll t6, t5, a3
			or a0, a0, t6
			beqz a6, long_division_signed_rem_unsigned
			rem t0, t0, t2
			j long_division_advance
  long_division_signed_rem_unsigned:
			remu t0, t0, t2
  long_division_advance:
			srli t3, t3, 1
			beqz t3, long_division_done
			addi a3, a3, -1
			j long_division_calculate
  long_division_done:
			#correct sign
			li t3, 0x8000000000000000
			and a4, a0, t3
			srli a4, a4, 63
			xor a5, a4, a6
			beqz a5, long_division_leave
			neg a0, a0
  long_division_leave:
			mv a1, t0
  long_division_out:
			ret

  #INPUT 
  #a0 - address to copy to
  #a1 - length to copy
  #a2 - address to copy from
  #OUTPUT
  #a0 - copy count
  utility_copy_counted_string:
			mv t0, a0
			mv t1, a1
			mv t2, a2
			li a0, 0
			sd t1, 0(t0)
			addi t0, t0, 8
  utility_copy_counted_copy:
			lb t3, 0(t2)
			sb t3, 0(t0)
			addi a0, a0, 1
			beq a0, t1, utility_copy_counted_done
			addi t2, t2, 1
			addi t0, t0, 1
			j utility_copy_counted_copy
  utility_copy_counted_done:
			ret


  #INPUT
  #a0 start of search
  #a1 delimiter
  #OUTPUT
  #a0 start of string
  #a1 length
  utility_parse_string:
			li a7, 512	#max length
			mv a6, a0
			add a6, a6, a7
			mv t0, a0
			mv t1, a1
			li a1, 0
  utility_parse_string_look_for_open:
			lb t2, 0(t0)
			addi t0, t0, 1
			bgt t0, a6, utility_parse_string_done
			beq t2, t1, utility_parse_string_open
			j utility_parse_string_look_for_open
  utility_parse_string_open:
			lb t2, 0(t0)
			bne t2, t1, utility_parse_string_opened
			addi t0, t0, 1
			bgt t0, a6, utility_parse_string_done
			j utility_parse_string_open
  utility_parse_string_opened:
			mv a0, t0
  utility_parse_string_look_for_close:
			addi t0, t0, 1
			bgt t0, a6, utility_parse_string_done
			lb t2, 0(t0)
			bne t2, t1, utility_parse_string_look_for_close
			#now reached the end
			sub a1, t0, a0
  utility_parse_string_done:
			ret

  #INPUT
  #a0 - start of search
  #a1 - max search point
  #OUTPUT
  #a0 - start of string
  #a1 - end of string
  #a2 - length of string
  utility_find_string:
			addi sp, sp, -40
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			#setup limiting characters
			li s0, 0x20		#space
			li s1, 0x0A		#CR
			#test at start
			li a3, 1
			sub a4, a1, a0
			bgt a4, a3, utility_find_string_test_start
			lbu s2, 0(a0)
			bne s2, s1, utility_find_string_test_startA
			j utility_find_string_failed
  utility_find_string_test_start:
			lbu s2, 0(a0)
  utility_find_string_test_startA:
			beq s2, s0, utility_find_string_advance
			bne s2, s1, utility_find_string_found_start
  utility_find_string_advance:
			addi a0, a0, 1
			bgt a0, a1, utility_find_string_failed
			j utility_find_string_test_start
  utility_find_string_found_start:
			#a0 holds start point
			mv s3, a0
			addi s3, s3, 1
  utility_find_string_test_end:
			lbu s2, 0(s3)
			beq s2, s0, utility_find_string_found_end
			beq s2, s1, utility_find_string_found_end
			addi s3, s3, 1
			bgt s3, a1, utility_find_string_found_end
			j utility_find_string_test_end
  utility_find_string_found_end:
			sub a2, s3, a0
			mv a1, s3
  utility_find_string_end:
			ld s3, 32(sp)
			ld s2, 24(sp)
			ld s1, 16(sp)
			ld s0, 8(sp)
			ld ra, 0(sp)
			addi sp, sp, 40
			ret
  utility_find_string_failed:
			mv a0, zero
			mv a1, zero
			mv a2, zero
			j utility_find_string_end


  #a0 has start
  #a1 has end
  utility_sanitize_string:
			addi sp, sp, -48
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			li s0, 0x61		#a
			li s1, 0x7B		#z + 1
			li s4, 0x20		#for XOR
			mv s2, a0
  utility_sanitize_test:
			lbu s3, 0(s2)
			blt s3, s0, utility_sanitize_advance
			blt s3, s1, utility_sanitize_process
  utility_sanitize_advance:
			addi s2, s2, 1
			bgt s2, a1, utility_sanitize_done
			j utility_sanitize_test
  utility_sanitize_process:
			xor s3, s3, s4
			sb s3, 0(s2)
			j utility_sanitize_advance
  utility_sanitize_done:
			ld s4, 40(sp)
			ld s3, 32(sp)
			ld s2, 24(sp)
			ld s1, 16(sp)
			ld s0, 8(sp)
			ld ra, 0(sp)
			addi sp, sp, 48
			ret


  #a0 has start
  #a1 has end
  #a2 returns length
  utility_expand_word:
			#returns expanded word if required
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			mv s0, a2
			bleu a0, a1, utility_expand_word_size_fine
			add a1, a0, a2
  utility_expand_word_size_fine:
			addi s0, s0, -1
			beqz s0, utility_expand_word_test1
			li s1, 3
			li s2, 5
			blt s0, s1, utility_expand_word_test2
			blt s0, s2, utility_expand_complete
			beq s0, s2, utility_expand_word_test6
			li s2, 7
			beq s0, s2, utility_expand_word_test8
			j utility_expand_complete
  utility_expand_word_test1:
			call utility_expand_one
			j utility_expand_complete
  utility_expand_word_test2:
			li s1, 1
			bne s0, s1, utility_expand_word_test3
			call utility_expand_two
			j utility_expand_complete
  utility_expand_word_test3:
			#should only get here if length is 3
			call utility_expand_three
			j utility_expand_complete
  utility_expand_word_test6:
			call utility_expand_six
			j utility_expand_complete
  utility_expand_word_test8:
			call utility_expand_eight
			j utility_expand_complete
   utility_expand_complete:
			ld s5, 48(sp)
			ld s4, 40(sp)
			ld s3, 32(sp)
			ld s2, 24(sp)
			ld s1, 16(sp)
			ld s0, 8(sp)
			ld ra, 0(sp)
			addi sp, sp, 56
			ret


  utility_expand_one:
			la a2, EXPANDED_BUFFER
			mv a3, a2
			lbu t1, 0(a0)
			li t2, 0x3B
			beq t2, t1, utility_expand_semi
			li t2, 0x3D
			beq t2, t1, utility_expand_equals
			li t2, 0x27
			beq t2, t1, utility_expand_tick
			li t2, 0x2C
			beq t2, t1, utility_expand_comma
			sub a2, a1, a0
			ret
  utility_expand_semi:
			PUSH ra
			call do_fix_up_semi
			POP ra
			j utility_expand_done
  utility_expand_equals:
			PUSH ra
			call do_fix_up_equals
			POP ra
			j utility_expand_done
  utility_expand_tick:
			PUSH ra
			call do_fix_up_tick
			POP ra
			j utility_expand_done
  utility_expand_comma:
			PUSH ra
			call do_fix_up_comma
			POP ra

  utility_expand_done:
			mv a0, a3
			mv a1, a2
			sub a2, a1, a0
			addi a2, a2, 1
			ret

  utility_expand_two:
			la a2, EXPANDED_BUFFER 		#store expanded token
			mv a3, a2
			lbu t1, 0(a0)
			li t2, 0x30			#0
			beq t1, t2, utility_expand_two_beginzero
			li t2, 0x2E			#.
			beq t1, t2, utility_expand_two_begindot
			li t2, 0x3E			#>
			beq t1, t2, utility_expand_two_begingt
			li t2, 0x3C			#<
			beq t1, t2, utility_expand_two_beginlt
			PUSH t1
			andi t1, t1, 0x5F		#character based tests all in here
			li t2, 0x43
			beq t1, t2, utility_expand_two_beginC
			li t2, 0x53
			beq t1, t2, utility_expand_two_beginS
			POP t1
  utility_expand_two_bail:
			sub a2, a1, a0
			ret
  utility_expand_two_finished:
			j utility_expand_done

  utility_expand_two_begindot:
			lbu t1, 1(a0)
			li t2, 0x22			#"
			bne t1, t2, utility_expand_two_bail
			PUSH ra
                	call fix_up_encsq
			POP ra
  utility_expand_two_begindot_done:
			j utility_expand_two_finished
		
  utility_expand_two_beginzero:
			lbu t1, 1(a0)
			li t2, 0x3D			#=
			bne t1, t2, utility_expand_two_bail
			PUSH ra
                	call fix_up_zeroequal
			POP ra
			j utility_expand_done
  utility_expand_two_begingt:
			lbu t1, 1(a0)
			li t2, 0x3D			#=
			bne t1, t2, utility_expand_two_bail
			PUSH ra
                	call fix_up_gteq
			POP ra
			j utility_expand_done
  utility_expand_two_beginlt:
			lbu t1, 1(a0)
			li t2, 0x3D			#=
			bne t1, t2, utility_expand_two_bail
			PUSH ra
                	call fix_up_lteq
			POP ra
			j utility_expand_done
  utility_expand_two_beginC:
			sb t1, 0(a2)
			addi sp, sp, 8
			lbu t1, 1(a0)
			li t2, 0x2C
			bne t1, t2, tick_length_two_cq
			PUSH ra
			call fix_up_ccomma		#,
			POP ra
			j utility_expand_done
  utility_expand_two_cq:
			li t2, 0x22			#"
			bne t1, t2, utility_expand_two_bail
			PUSH ra
			call fix_up_cq
			POP ra
			j utility_expand_done
  utility_expand_two_c_done:
			j utility_expand_two_finished


  utility_expand_two_beginS:
			sb t1, 0(a2)
			addi sp, sp, 8
			lbu t1, 1(a0)
			li t2, 0x22			#"
			bne t1, t2, utility_expand_two_bail
			PUSH ra
			call fix_up_squote
			POP ra
			j utility_expand_done
 utility_expand_three:
			#expand ['] --> BRACKETTICK
			la a2, EXPANDED_BUFFER
			mv a3, a2
			lbu t1, 0(a0)
			li t2, 0x5B		#[
			bne t1, t2, utility_expand_three_done
			lbu t1, 1(a0)
			li t2, 0x27		#'
			bne t1, t2, utility_expand_three_done
			lbu t1, 2(a0)
			li t2, 0x5D		#]
			bne t1, t2, utility_expand_three_done
			PUSH ra
			call fix_up_brackettick
			POP ra
			j utility_expand_done
  utility_expand_three_done:
			sub a2, a1, a0
			ret
  utility_expand_six:
			#expand the following
			# ABORT" --> ABORTCOMM
			la a2, EXPANDED_BUFFER
			mv a3, a2
			lbu t1, 5(a0)
			li t2, 0x22		 #"
			bne t1, t2, utilities_expand_six_done
			PUSH ra
			call fix_up_acomma
			POP ra
			j utility_expand_done
  utilities_expand_six_done:
			sub a2, a1, a0
			ret
  utility_expand_eight:
			#expand COMPILE, --> COMPILECOMMA
			#COMPILE: 0x43 0x4F 0x4D 0x50 0x49 0x4C 0x45
			#COMMA: 0x43 0x4F 0x4D 0x4D 0x41
			la a2, EXPANDED_BUFFER
			mv a3, a2
			li t2, 0x43		#C
			lbu t1, 0(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x4F		#O
			lbu t1, 1(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x4D		#M
			lbu t1, 2(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x50		#P
			lbu t1, 3(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x49		#I
			lbu t1, 4(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x4C		#L
			lbu t1, 5(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x45		#E
			lbu t1, 6(a0)
			andi t1, t1, 0x5F
			bne t1, t2, utilities_expand_six_done
			li t2, 0x2C		#,
			lbu t1, 11(a0)
			bne t1, t2, tix_up_six_done
			PUSH ra
			call fix_up_compilecomma
			POP ra
			j utility_expand_done
  #a0 has start
  #a1 has end
  #a2 has length
  #a3 returns 1 on success
  #a4 holds address
  utility_check_dictionary_match:
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			call utility_expand_word
			li a3, 1
			# check we don't exceed max length - in which case we fail anyway
			li s0, NAMEMAXLEN
			bgt a2, s0, utility_check_dictionary_match_done
			#now scan dictionary
			la s0, dictionary
			ld s1, 0(s0)
  utility_check_dictionary_match_check_word:
			mv a4, s1
			ld s2, 24(s1)		#check length
			bne s2, a2, utility_check_dictionary_match_nomatch
			addi s3, s1, 32		#s3 now points at name in dictionary
			mv s4, a0		#s4 points to the token
  utility_check_dictionary_match_loop:
			lbu s0, 0(s4)
			lbu s5, 0(s3)
			bne s0, s5, utility_check_dictionary_match_nomatch
			addi s2, s2, -1
			beqz s2, utility_check_dictionary_match_done		#failed
			addi s4, s4, 1
			addi s3, s3, 1
			j utility_check_dictionary_match_loop
  utility_check_dictionary_match_nomatch:
			ld s1, 16(s1)
			bnez s1, utility_check_dictionary_match_check_word
			li a3, 0						#success
  utility_check_dictionary_match_done:
			ld s5, 48(sp)
			ld s4, 40(sp)
			ld s3, 32(sp)
			ld s2, 24(sp)
			ld s1, 16(sp)
			ld s0, 8(sp)
			ld ra, 0(sp)
			addi sp, sp, 56
			ret
  #a0 holds address to start writing
  #a1 holds address of function
  utility_write_out_call_function:
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			mv s1, a1
			srli s1, s1, 32
			slli s1, s1, 20
			li s0, 0x293
			or s0, s0, s1
			sw s0, 0(a0)						#addi t0, zero, [upper 32 of fuction address]
			li s0, 0x2029293
			sw s0, 4(a0)						#slli t0, t0, 32
			#now lower 32 bit bits
			mv s1, a1
			li s2, 0xFFFFF000
			and s1, s1, s2						#upper 20 bits of lower 32
			li s2, 0x337
			or s0, s1, s2
			sw s0, 8(a0)						#lui t1, [bits 12 - 31]
			li s0, 0x2031313
			sw s0, 12(a0)						#slli t1, t1, 0x20
			li s0, 0x2035313
			sw s0, 16(a0)						#srli t1, t1, 0x20 (zero out upper 32 bits)
			mv s1, a1
			li s2, 0xFFF
			and s0, s1, s2						#lower 12 bits only
			srli s1, s0, 11						#s1 has twelveth bit only
			li s2, 0x7FF
			and s0, s0, s2						#s0 has the lower 11 bits
			li s4, 0x393
			slli s1, s1, 20
			or s4, s4, s1
			sw s4, 20(a0)						#addi t2, zero, [0 or 1]
			li s4, 0xB39393
			sw s4, 24(a0)						#slli t2, t2, 11
			li s4, 0x7282B3
			sw s4, 28(a0)						#add t0, t0, t2
			li s4, 0x393
			slli s0, s0, 20
			or s4, s4, s0
			sw s4, 32(a0)						#addi t2, zero, [lower 11 bits]
			li s4, 0x7282B3
			sw s4, 36(a0)						#add t0, t0, t2
			li s4, 0x6282B3
			sw s4, 40(a0)						#add t0, t0, t1
			li s0, 0x28067
			sw s0, 44(a0)						#jalr zero, 0(t0)
			addi a0, a0, 48
			ld ra, 0(sp)
			ld s0, 8(sp)
			ld s1, 16(sp)
			ld s2, 24(sp)
			ld s3, 32(sp)
			ld s4, 40(sp)
			ld s5, 48(sp)
			addi sp, sp, 56
			fence.i
			ret
			
				
  #a0 holds start of name
  #a1 holds length of name
  #a5 holds value of header
  #a0 returns write point
  utility_write_function_header:
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			la s1, newdictionary
			ld s3, 0(s1)
			mv s2, a5
			sd s2, 0(s3)				#flag
			addi s2, s3, 0x38			#word address of new word
			sd s2, 8(s3)
			la s0, dictionary
			ld s1, 0(s0)
			sd s1, 16(s3)				#words address of previous word
			sd a1, 24(s3)				#length
			li s2, 0XFFFFFFFFFFFFFFFF		#now fill in name space
			sd s2, 32(s3)
			sd s2, 40(s3)
			sd s2, 48(s3)
			addi s4, s3, 32
  utility_write_header_write_out_name:
			lbu s5, 0(a0)
			sb s5, 0(s4)
			addi a1, a1, -1
			beqz a1, utility_write_header_name_written
			addi a0, a0, 1
			addi s4, s4, 1
			j utility_write_header_write_out_name
  utility_write_header_name_written:
			add a0, s3, 56
			ld ra, 0(sp)
			ld s0, 8(sp)
			ld s1, 16(sp)
			ld s2, 24(sp)
			ld s3, 32(sp)
			ld s4, 40(sp)
			ld s5, 48(sp)
			addi sp, sp, 56
			fence.i
			ret
  utility_constant_code:
			#a0 holds address to start writing
			#a1 holds number
			#a2 holds NEXT address
			li t0, 0x297
			sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
			li t0, 0x182B303
			sw t0, 4(a0)						#ld t1, 24(t0)
			li t0, 0xFF810113
			sw t0, 8(a0)						#addi sp, sp, -8
			li t0, 0x613023
			sw t0, 12(a0)						#sd t1, 0(sp)
			#now jump to next
			li t0, 0x202B303
			sw t0, 16(a0)						#ld t1, 32(t0)
			li t0, 0x30067
			sw t0, 20(a0)						#jr t1
			sd a1, 24(a0)
			sd a2, 32(a0)
			addi a0, a0, 40
			fence.i
			ret
  utility_jump_next:
			#a0 holds address to write to
			#a2 holds NEXT address
			li t0, 0x297
			sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
			li t0, 0xC2B303
			sw t0, 4(a0)						#ld t1, 12(t0)
			li t0, 0x30067
			sw t0, 8(a0)						#jr t1
			sd a2, 12(a0)
			addi a0, a0, 20
			fence.i
			ret
  utility_do_colon:
			#a0 holds address to start writing
			#a1 holds number for s7
			#a2 holds NEXT address
			li t0, 0x297
			sw t0, 0(a0)						#aui t0, 0
			li t0, 0xFF8C8C93
			sw t0, 4(a0)						#addi s9, s9, -8,
			li t0, 0x017cb023	
			sw t0, 8(a0)						#sd s7, 0(s9)
			li t0, 0x182BB83
			sw t0, 12(a0)						#ld s7, 24(t0)
			#now jump to next
			li t0, 0x202B303
			sw t0, 16(a0)						#ld t1, 32(t0)
			li t0, 0x30067
			sw t0, 20(a0)						#jr t1
			sd a1, 24(a0)
			sd a2, 32(a0)
			addi a0, a0, 40
			fence.i
			ret

			#COMPILE ONLY WORDS
			CODEHEADER _COMPSEMI, INCLUDE, 0x0
			tail search_create_test_postpone_semi

			CODEHEADER _COMPUNTIL, _COMPSEMI, 0x0a
			#(x --)
			POP t0
			beqz t0, _comp_until_look_begin
			tail NEXT
  _comp_until_look_begin:
			li t0, 0
			la t1, WA_BEGIN
			la t2, WA__UNTIL
			la t3, WA__AGAIN
			la a0, WA__COMPAGAIN
			la a1, WA__COMPUNTIL
			mv t4, s7
  _comp_until_look_back:
			addi t4, t4, -8
			ld t5, -8(t4)
			beq t5, t1, _comp_until_test_begin
			beq t5, t2, _comp_until_inc_index
			beq t5, t3, _comp_until_inc_index
			beq a0, t5, _comp_until_inc_index
			beq a1, t5, _comp_until_inc_index
			j _comp_until_look_back
  _comp_until_inc_index:
			addi t0, t0, 1
			j _comp_until_look_back
  _comp_until_test_begin:
		 	beqz t0, _comp_until_prime_jump
			addi t0, t0, -1
			j _comp_until_look_back
  _comp_until_prime_jump:
			mv s7, t4
			tail NEXT
			CODEHEADER _COMPAGAIN, _COMPUNTIL, 0x0
			#(--)
			li t0, 0
			la t1, WA_BEGIN
			la t2, WA__AGAIN
			la t3, WA__UNTIL
			la t4, WA__COMPAGAIN
			la t5, WA__COMPUNTIL
			mv t6, s7
  _comp_again_look_back:
			addi t6, t6, -8
			ld a0, -8(t6)
			beq t6, t1, _comp_again_test_begin
			beq t6, t2, _comp_again_inc_index
			beq t6, t3, _comp_again_inc_index
			beq t6, t4, _comp_again_inc_index
			beq t6, t5, _comp_again_inc_index
			j _comp_again_look_back
  _comp_again_inc_index:
			addi t0, t0, 1
			j _comp_again_look_back
  _comp_again_test_begin:
		 	beqz t0, _comp_again_prime_jump
			addi t0, t0, -1
			j _comp_again_look_back
  _comp_again_prime_jump:
			mv s7, t6
			tail NEXT
  
			CODEHEADER _COMPREPEAT, _COMPAGAIN, 0x0
			j _comp_until_look_begin
			CODEHEADER _COMPTHEN, _COMPREPEAT, 0x0
			#(--)			
			#Look for an IF or WHILE and update
			#Could be writing nonsense - but not if we've been POSTPONE'd and then
			#made IMMEDIATE
			la t0, createwritepoint
			ld t1, 0(t0)
			addi t1, t1, -8
			tail transitions_then_out_postpone
			CODEHEADER _COMPELSE, _COMPTHEN, 0x0
			#(--)
			la t3, WA__ELSE
			j transitions_else_out
			CODEHEADER _COMPIF, _COMPELSE, 0x0
			#(--)
			la t3, WA__IF
			tail transitions_if_out
			CODEHEADER _COMPMINUSLOOP, _COMPIF, 0x0
			la t3, WA__MINUSLOOP
			tail transitions_loop_out
			CODEHEADER _COMPPLUSLOOP, _COMPMINUSLOOP, 0x0
			la t3, WA__PLUSLOOP
			tail transitions_loop_out
			CODEHEADER _COMPLOOP, _COMPPLUSLOOP, 0x0
			la t3, WA__LOOP
			tail transitions_loop_out
			CODEHEADER _COMPQDO, _COMPLOOP, 0x0
			la t3, WA__QDO
			tail transitions_do_out
			CODEHEADER _COMPDO, _COMPQDO, 0x0
			la t3, WA__DO
			tail transitions_do_out
			CODEHEADER _COMPACTIONOF, _COMPDO, 0x0
			la t3, WA__ACTIONOF
			tail embed_defer
			CODEHEADER _COMPCHAR, _COMPACTIONOF, 0x0
			la t3, WA__CHAR
			tail embed_tick
			CODEHEADER _COMPBRACKETCHAR, _COMPCHAR, 0x0
			la t3, WA__BRACKETCHAR
			tail embed_tick
			CODEHEADER _LITERALCOMP, _COMPBRACKETCHAR, 0x0
			POP a2
			la t3, WA_LITERALNUMB
			tail search_create_literal_out
			CODEHEADER _DOESCOMP, _LITERALCOMP, 0x0
			la t3, WA_DOES_
			tail search_create_keep_does_
			CODEHEADER _ABORTCOMP, _DOESCOMP, 0x0
			la t3, WA__ABORTCOMM
			addi a5, a5, 4
			tail embed_encsq
			CODEHEADER _DOTQCOMP, _ABORTCOMP, 0x0
			la t3, WA__DOTQ
			tail embed_encsq
			CODEHEADER _SQCOMP, _DOTQCOMP, 0x0
			la t3, WA__SQ
			tail embed_sq
			CODEHEADER _CQCOMP, _SQCOMP, 0x0
			la t3, WA__CQ
			tail embed_sq
			CODEHEADER _TICKCOMP, _CQCOMP, 0x0
			la t3, WA__TICK
			tail embed_tick
			CODEHEADER _MARKERCOMP, _TICKCOMP, 0x0
			la t3, WA__MARKER
			tail embed_marker
			CODEHEADER _COMPCOMPCOMMA, _MARKERCOMP, 0x0
			POP t3
			tail postpone_output_normal
			CODEHEADER _COMPIS, _COMPCOMPCOMMA, 0x0
			la t3, WA__IS
			tail embed_tick
			CODEHEADER _COMPPPONE, _COMPIS, 0x0
			#write out embedded word address
			ld t0, 0(s7)
			addi s7, s7, 8
			la t1, createwritepoint
			ld t2, 0(t1)
			sd t0, 0(t2)
			addi t2, t2, 8
			sd t2, 0(t1)
			tail NEXT
			CODEHEADER _NUMBER, _COMPPPONE, 0x0
			#(-- x)
			ld t0, 0(s7)			#how many bytes?
			mv t6, t0			#copy to t6
			addi s7, s7, 8
			mv a0, s7			#a0 points to start of string
			add a3, a0, t0			#a3 points to end
			li t1, 7
			and t2, t1, t0
			beqz t2, _number_aligned
			li t3, 8
			sub t4, t3, t2
			add t6, t6, t4
  _number_aligned:
			add s7, s7, t6
			call func_test_hex
			PUSH a2
			tail NEXT
			CODEHEADER _COMPWHILE, _NUMBER, 0x0
			la t3, WA__WHILE
			tail transitions_while_out
			CODEHEADER _COMPTO, _COMPWHILE, 0x0
			la t3, WA__TO
			tail embed_to
  utility_process_postpone:
			#find word
			#find token
			#compile in
			PUSH ra
			call utility_find_string
			bnez a0, utility_process_postpone_found
			la a5, INPPONE
			li a6, 1
			sd a6, 0(a5)
			POP ra
			ret
  utility_process_postpone_found:
			la a5, INPUT_START
			add a6, a0, a2
			sd a6, 0(a5)
			la a5, INPPONE
			sd zero, 0(a5)	
			call utility_sanitize_string
			call utility_check_dictionary_match
			bnez a3, utility_process_postpone_found_matched
			#not a dictionary word - is it a number?
			j utility_postpone_process_number
  utility_process_postpone_found_matched:
			addi a4, a4, 8
			#now check if we have compiling behaviour
			#WA_COLON
			la a5, WA_COLON
			bne a4, a5, postpone_check_literal
			#COLON compiling behaviour generates error!
			la t0, CREATEFLAG
			sd zero, 0(t0)
			addi sp, sp, 8
			tail search_failed
  postpone_check_literal:
			la a5, WA_LITERAL
			bne a4, a5, postpone_check_does
			la a4, WA__LITERALCOMP
			j postpone_output_normal
  postpone_check_does:
			la a5, WA_DOES_
			bne a4, a5, postpone_allowed
			la a4, WA__DOESCOMP
			j postpone_output_normal
  postpone_allowed:
			la a5, WA_ABORTCOMM
			bne a4, a5, postpone_encsq
			la a4, WA__ABORTCOMP
			j postpone_output_normal
  postpone_encsq:
			la a5, WA_DOTQ
			bne a4, a5, postpone_search_sq
			la a4, WA__DOTQCOMP
			j postpone_output_normal
  postpone_search_sq:
			la a5, WA_SQ
			bne a4, a5, postpone_search_cq
			la a4, WA__SQCOMP
			j postpone_output_normal
  postpone_search_cq:
			la a5, WA_CQ
			bne a4, a5, postpone_search_marker
			la a4, WA__CQCOMP
			j postpone_output_normal
  postpone_search_marker:
			la a5, WA_MARKER
			bne a4, a5, postpone_search_tick
			la a4, WA__MARKERCOMP
			j postpone_output_normal
  postpone_search_tick:
			la a5, WA_TICK
			bne a4, a5, postpone_search_brackettick
			la a4, WA__TICKCOMP
			j postpone_output_normal
  postpone_search_brackettick:
			la a5, WA_BRACKETTICK
			bne a4, a5, postpone_search_compilecomma
			la a4, WA__TICKCOMP
			j postpone_output_normal
  postpone_search_compilecomma:
			la a5, WA_COMPILECOMMA
			bne a4, a5, postpone_search_is
			la a4, WA__COMPCOMPCOMMA
			j postpone_output_normal
  postpone_search_is:
			la a5, WA_IS
			bne a4, a5, postpone_search_to
			la a4, WA__COMPIS
			j postpone_output_normal
  postpone_search_to:
			la a5, WA_TO
			bne a4, a5, postpone_search_bracketchar
			la a4, WA__COMPTO
			j postpone_output_normal
  postpone_search_bracketchar:
			la a5, WA_BRACKETCHAR
			bne a4, a5, postpone_search_char
			la a4, WA__COMPBRACKETCHAR
			j postpone_output_normal
  postpone_search_char:
			la a5, WA_CHAR
			bne a4, a5, postpone_search_actionof
			la a4, WA__COMPCHAR
			j postpone_output_normal
  postpone_search_actionof:
			la a5, WA_ACTIONOF
			bne a4, a5, postpone_search_again
			la a4, WA__COMPACTIONOF
			j postpone_output_normal
  postpone_search_again:
			la a5, WA_AGAIN
			bne a4, a5, postpone_search_until
			la a4, WA__COMPAGAIN
			j postpone_output_normal
  postpone_search_until:
			la a5, WA_UNTIL
			bne a4, a5, postpone_search_do
			la a4, WA__COMPUNTIL
			j postpone_output_normal
  postpone_search_do:
			la a5, WA_DO
			bne a4, a5, postpone_search_qdo
			la a4, WA__COMPDO
			j postpone_output_normal
  postpone_search_qdo:
			la a5, WA_QDO
			bne a4, a5, postpone_search_loop
			la a4, WA__COMPQDO
			j postpone_output_normal
  postpone_search_loop:
			la a5, WA_LOOP
			bne a4, a5, postpone_search_plusloop
			la a4, WA__COMPLOOP
			j postpone_output_normal
  postpone_search_plusloop:
			la a5, WA_PLUSLOOP
			bne a4, a5, postpone_search_minusloop
			la a4, WA__COMPPLUSLOOP
			j postpone_output_normal
  postpone_search_minusloop:
			la a5, WA_MINUSLOOP
			bne a4, a5, postpone_search_unloop
			la a4, WA__COMPMINUSLOOP
			j postpone_output_normal
  postpone_search_unloop:
			la a5, WA_UNLOOP
			bne a4, a5, postpone_search_leave
			la a4, WA__UNLOOP
			j postpone_output_normal
  postpone_search_leave:
			la a5, WA_LEAVE
			bne a4, a5, postpone_search_recurse
			la a4, WA__LEAVE
			j postpone_output_normal
  postpone_search_recurse:
			la a5, WA_RECURSE
			bne a4, a5, postpone_search_i
			la t0, newdictionary
			ld t1, 0(t0)
			addi a5, t1, 0x8
			j postpone_output_normal
  postpone_search_i:
			la a5, WA_I
			bne a5, a4, postpone_search_j
			la a4, WA__I
			j postpone_output_normal
  postpone_search_j:
			la a5, WA_J
			bne a5, a4, postpone_search_exit
			la a4, WA__J
			j postpone_output_normal
  postpone_search_exit:
			la a5, WA_EXIT
			bne a5, a4, postpone_search_if
			la a4, WA__EXIT
			j postpone_output_normal
  postpone_search_if:
			la a5, WA_IF
			bne a5, a4, postpone_search_else
			la a4, WA__COMPIF
			j postpone_output_normal
  postpone_search_else:
			la a5, WA_ELSE
			bne a5, a4, postpone_search_of
			la a4, WA__COMPELSE
			j postpone_output_normal
  postpone_search_of:
			la a5, WA_OF
			bne a5, a4, postpone_search_then
			la a4, WA__OF
			j postpone_output_normal
  postpone_search_then:
			la a5, WA_THEN
			bne a5, a4, postpone_search_while
			la a4, WA__COMPTHEN
			j postpone_output_normal
  postpone_search_while:
			la a5, WA_WHILE
			bne a5, a4, postpone_search_repeat
			la a4, WA__COMPWHILE
			j postpone_output_normal
  postpone_search_repeat:
			la a5, WA_REPEAT
			bne a5, a4, postpone_search_semi
			la a4, WA__COMPREPEAT
			j postpone_output_normal
  postpone_search_semi:
			la a5, WA_SEMI
			bne a5, a4, postpone_search_no_matches
			la a4, WA__COMPSEMI
			j postpone_output_normal
  postpone_search_no_matches:
			#is the word IMMEDIATE?
			ld t0, -8(a4)
			li t1, 0x100
			and t2, t0, t1
			bnez t2, postpone_output_normal
			#so here we need to write out our special postpone word and 
			#embed the token
			la t0, createwritepoint
			ld t1, 0(t0)
			la t4, WA__COMPPPONE
			sd t4, 0(t1)
			addi t1, t1, 8
			sd t1, 0(t0)
			
  postpone_output_normal:
			mv t3, a4
			POP ra
			ret
  utility_postpone_process_number:
			#not special compile words but still have some checking to do
			addi sp, sp, 8		#not returning
			la t3, WA__NUMBER
			la t0, createwritepoint
			ld t1, 0(t0)
			sd t3, 0(t1)
			addi t1, t1, 8
			sd t1, 0(t0)
			sd a2, 0(t1)
			addi t1, t1, 8
  utility_postpone_process_number_write:
			lbu t3, 0(a0)
			sb t3, 0(t1)
			addi t1, t1, 1
			addi a0, a0, 1
			addi a2, a2, -1
			beqz a2, utility_postpone_process_number_done
			j utility_postpone_process_number_write
  utility_postpone_process_number_done:
			#check alignment
			li t3, 7
			and t4, t3, t1
			beqz t4, utility_postpone_process_number_clear
			li t5, 8
			sub t6, t5, t4
			add t1, t1, t6
  utility_postpone_process_number_clear:
			sd t1, 0(t0)
			tail search_create_leave
#string match function
#a0 - address of one string
#a1 - address of second string
#a2 - max count
#returns: a3 is zero on match
  utility_stringsmatch:
			mv t0, a0
			mv t1, a1
			mv t2, a2
			li a3, 1		#fails unless explicity set to 0
  utility_stringsmatch_nextround:
			bnez t2, utility_stringsmatch_loadchars
			mv a3, zero
			ret
  utility_stringsmatch_loadchars:
			lb t4, 0(t0)
			lb t5, 0(t1)
			beq t4, t5, utility_stringsmatch_continue
			ret
  utility_stringsmatch_continue:
			addi t0, t0, 1
			addi t1, t1, 1
			addi t2, t2, -1
			j utility_stringsmatch_nextround
#ENVIONMENT? answers
  utility_enviroq_countedstrings:
			li t0, -1
  utility_truth:
			addi sp, sp, -16
			sd t0, 8(sp)
			li t1, -1
			sd t1, 0(sp)
			tail NEXT
  utility_enviroq_hold:
  utility_enviroq_pad:
			li t0, SYSTEMAREA
			j utility_truth
  utility_enviroq_aub:
			li t0, 64
			j utility_truth
  utility_enviroq_floored:
			li t0, -1
			j utility_truth
  utility_enviroq_maxchar:
			li t0, 0xFF
			j utility_truth
  utility_enviroq_maxd:
  utility_enviroq_maxn:
			li t0, 0x7FFFFFFFFFFFFFFF
			j utility_truth
  utility_enviroq_maxu:
  utility_enviroq_maxud:
			li t0, 0xFFFFFFFFFFFFFFFF
			j utility_truth
  utility_enviroq_rsc:
  utility_enviroq_stackcells:
			li t0, 0x20000
			j utility_truth
