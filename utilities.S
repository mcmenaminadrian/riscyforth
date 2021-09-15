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
			ret
			
				
  #a0 holds start of name
  #a1 holds length of name
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
			la s0, CREATEFLAG
			li s1, 0x01
			sd s1, 0(s0)				#set MODE to 1 (compile)
			la s1, newdictionary
			ld s3, 0(s1)
			li s2, 0x01
			sd s2, 0(s3)				#flag
			addi s2, s3, 0x38			#word address of new word
			sd s2, 8(s3)
			la s0, dictionary
			ld s1, 0(s0)
			sd s1, 16(s3)				#words address of previous word
			sd zero, 24(s3)				#zero length
			li s2, 0XFFFFFFFFFFFFFFFF		#now fill in name space
			sd s2, 32(s3)
			sd s2, 40(s3)
			sd s2, 48(s3)
			addi s4, s3, 32
  utility_write_header_write_out_name:
			lb s5, 0(a0)
			sb s5, 0(s4)
			addi a1, a1, -1
			beqz a1, utility_write_header_name_written
			addi a0, a0, 1
			addi s4, s4, 1
			j utility_write_header_write_out_name
  utility_write_header_name_written:
			add a0, s3, 56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			addi sp, sp, 56
			ret
			
			

  #a0 holds address to start writing
  #a1 holds number
  utility_write_number_to_stack:
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
			li s0, 0xFF810113
			sw s0, 44(a0)						#add sp, sp, -8
			li s0, 0x513023
			sw s0, 48(a0)						#sd t0, 0(sp)
			addi a0, a0, 52
			ld ra, 0(sp)
			ld s0, 8(sp)
			ld s1, 16(sp)
			ld s2, 24(sp)
			ld s3, 32(sp)
			ld s4, 40(sp)
			ld s5, 48(sp)
			addi sp, sp, 56
			ret
