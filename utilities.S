#utility (shared) code for riscyforth
#copyright (c) Adrian McMenamin, 2021
#Licenced for reuse under the terms of the GNU GPL v2
#No warranty is offered


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
  utility_find_string_test_start:
			lbu s2, 0(a0)
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
  utility_found_string_failed:
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
			ret

  #a0 has start
  #a1 has end
  #a2 has length
  #a3 returns 0 on success
  utility_check_dictionary_match:
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			li a3, 1
			# check we don't exceed max length - in which case we fail anyway
			li s0, NAMEMAXLEN
			bgt a2, s0, utility_check_dictionary_match_done
			#now scan dictionary
			la s0, dictionary
			ld s1, 0(s0)
  utility_check_dictionary_match_check_word:
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
			
			
				
		
