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
  #a3 returns 0 on success
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

  utility_process_postpone:
			#find word
			#find token
			#compile in
			#TODO: Handle multi-line entry
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
			la a5, WA__LITERALCOMP
			j postpone_output_normal
  postpone_check_does:
			la a5, WA_DOES_
			bne a4, a5, postpone_allowed
			la a5, WA__DOESCOMP
			j postpone_output_normal
  postpone_allowed:
			la a5, WA_ABORTCOMM
			bne a4, a5. postpone_encsq
			la a5, WA__ABORTCOMP
			j postpone_output_normal
  postpone_encsq:
			la a5, WA_DOTQ
			bne a4, a5, postpone_search_sq
			la a5, WA__DOTQCOMP
			j postpone_output_normal
  postpone_search_sq:
			la a5, WA_SQ
			bne a4, a5, postpone_search_cq
			la a5, WA__SQCOMP
			j postpone_output_normal
  postpone_search_cq:
			la a5, WA_CQ
			bne a4, a5, postpone_search_tick
			la a5, WA__CQCOMP
			j postpone_output_normal
  postpone_search_tick:
			la a5, WA_TICK
			bne a4, a5, postpone_search_brackettick
			la a5, WA__TICKCOMP
			j postpone_output_normal
  postpone_search_brackettick:
			la a5, WA_BRACKETTICK
			bne a4, a5, postpone_search_compilecomma
			la a5, WA__TICKCOMP
			j postpone_output_normal
  postpone_search_compilecomma:
			la a5, WA_COMPILCOMMA
			bne a4, a5, postpone_search_is
			la a5, WA__COMPCOMPCOMMA
			j postpone_output_normal
  postpone_search_is:
			la a5, WA_IS
			bne a4, a5, postpone_search_to
			la a5, WA__COMPIS
			j postpone_output_normal
  postpone_search_is:
			la a5, WA_TO
			bne a4, a5, postpone_search_bracketchar
			la a5, WA__COMPTO
			j postpone_output_normal
  postpone_search_bracketchar:
			la a5, WA_BRACKETCHAR
			bne a4, a5, postpone_search_char
			la a5, WA__COMPBRACKETCHAR
			j postpone_output_normal
  postpone_search_char:
			la a5, WA_CHAR
			bne a4, a5, postpone_search_actionof
			la a5, WA__COMPCHAR
			j postpone_output_normal
  postpone_search_actionof:
			la a5, WA_ACTIONOF
			bne a4, a5, postpone_search_again
			la a5, WA__COMPACTIONOF
			j postpone_output_normal
  postpone_search_again:
			la a5, WA_AGAIN
			bne a4, a5, postpone_search_until
			la a5, WA__COMPAGAIN
			j postpone_output_normal
  postpone_search_until:
			la a5, WA_UNTIL
			bne a4, a5, postpone_search_do
			la a5, WA__COMPUNTIL
			j postpone_output_normal
  postpone_search_do:
			la a5, WA_DO
			bne a4, a5, postpone_search_qdo
			la a5, WA__COMPDO
			j postpone_output_normal
  postpone_search_qdo:
			la a5, WA_QDO
			bne a4, a5, postpone_search_loop
			la a5, WA__COMPQDO
			j postpone_output_normal
  postpone_search_loop:
			la a5, WA_LOOP
			bne a4, a5, postpone_search_plusloop
			la a5, WA__COMPLOOP
			j postpone_output_normal
  postpone_search_plusloop:
			la a5, WA_PLUSLOOP
			bne a4, a5, postpone_search_minusloop
			la a5, WA__COMPPLUSLOOP
			j postpone_output_normal
  postpone_search_minusloop:
			la a5, WA_MINUSLOOP
			bne a4, a5, postpone_search_unloop
			la a5, WA__COMPMINUSLOOP
			j postpone_output_normal
  postpone_search_unloop:
			la a5, WA_UNLOOP
			bne a4, a5, postpone_search_leave
			la a5, WA__UNLOOP
			j postpone_output_normal
  postpone_search_leave:
			la a5, WA_LEAVE
			bne a4, a5, postpone_search_recurse
			la a5, WA__LEAVE
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
			bne a5, a5, postpone_search_j
			la a5, WA__I
			j postpone_output_normal
  postpone_search_j:
			la a5, WA_J
			bne a5, a5, postpone_search_exit
			la a5, WA__J
			j postpone_output_normal
  postpone_search_exit:
			la a5, WA_EXIT
			bne a5, a5, postpone_search_if
			la a5, WA__EXIT
			j postpone_output_normal
  postpone_search_if:
			la a5, WA_IF
			bne a5, a5, postpone_search_else
			la a5, WA__COMPIF
			j postpone_output_normal
  postpone_search_else:
			la a5, WA_ELSE
			bne a5, a5, postpone_search_of
			la a5, WA__COMPELSE
			j postpone_output_normal
  postpone_search_of:
			la a5, WA_OF
			bne a5, a5, postpone_search_then
			la a5, WA__OF
			j postpone_output_normal
  postpone_search_then:
			la a5, WA_THEN
			bne a5, a5, postpone_search_while
			la a5, WA__COMPTHEN
			j postpone_output_normal
  postpone_search_while:
			la a5, WA_WHILE
			bne a5, a5, postpone_search_repeat
			la a5, WA__COMPWHILE
			j postpone_output_normal
  postpone_search_repeat:
			la a5, WA_REPEAT
			bne a5, a5, postpone_output_normal_ext
			la a5, WA__COMPREPEAT
#			j postpone_output_normal
			
  postpone_output_normal:
			mv t3, a4
			POP ra
			ret

  postpone_output_normal_ext:
			#not special compile words but still have some checking to do

  postpone_output_normal_ext:
			#not a word with a special compiling word
			mv t3, a4
			POP ra
			#but we have other tests to do

			#COMPILE ONLY WORDS
			CODEND __COMPUNIT, 0x0
			la t3, WA__UNTIL
			tail transitions_until_out

			CODEND __COMPAGAIN, 0x0
			la t3, WA__AGAIN
			tail transitions_again_out

			CODEND __COMPREPEAT, 0x0
			la t3, WA__REPEAT
			tail transitions_repeat_out

			CODEND __COMPWHILE, 0x0
			la t3, WA__WHILE
			tail transitions_while_out

			CODEND __COMPTHEN, 0x0
			la t3, WA__THEN
			tail transitions_then_out

			CODEND __COMPELSE, 0x0
			la t3, WA__ELSE
			tail transitions_else_out

			CODEND __COMPIF, 0x0
			la t3, WA__IF
			tail transitions_if_out

			CODEND __COMPMINUSLOOP, 0x0
			la t3, WA__MINUSLOOP
			tail transitions_loop_out

			CODEND __COMPPLUSLOOP, 0x0
			la t3, WA__PLUSLOOP
			tail transitions_loop_out

			CODEND __COMPLOOP, 0x0
			la t3, WA__LOOP
			tail transitions_loop_out

			CODEND __COMPQDO, 0x0
			la t3, WA__QDO
			tail transitions_do_out

			CODEND __COMPDO, 0x0
			la t3, WA__DO
			tail transitions_do_out

			CODEND __COMPACTIONOF, 0x0
			la t3, WA__ACTIONOF
			tail embed_defer

			CODEND __COMPCHAR, 0x0
			la t3, WA__CHAR
			tail embed_tick

			CODEND __COMPBRACKETCHAR, 0x0
			la t3, WA__BRACKETCHAR
			tail embed_to

			CODEEND _LITERALCOMP, 0x0
			POP a2
			tail search_create_number_on_stack

			CODEEND _DOESCOMP, 0x0
			la t3, WA_DOES_
			tail search_create_keep_does_

			CODEND _ABORTCOMP, 0x0
			la t3, WA__ABORTCOMM
			addi a5, a5, 4
			tail embed_encsq

			CODEEND _DOTQCOMP, 0x0
			la t3, WA__DOTQ
			tail embed_encsq

			CODEEND _SQCOMP, 0x0
			la t3, WA__SQ
			tail embed_sq

			CODEEND _CQCOMP, 0x0
			la t3, WA__CQ
			tail embed_sq

			CODEEND _TICKCOMP, 0x0
			la t3, WA__TICK
			tail embed_tick

			CODEEND _COMPCOMPCOMMA, 0x0
			ld t3, 0(sp)
			addi sp, sp, 8
			tail postpone_output_normal

			CODEND __COMPIS, 0x0
			la t3, WA__IS
			tail embed_tick

			CODEND __COMPTO, 0x0
			la t3, WA__TO
			tail embed_to
