.include "riscyvar.S"
.include "../macros.S"


.section .bss
   .comm INPUT_BUFFER, BUFFERLEN
   .comm EXPANDED_BUFFER, BUFFERLEN
   .comm createwritepoint, ADDRWIDTH
   .comm newdictionary, ADDRWIDTH
   .comm dictionary, ADDRWIDTH
   .comm INPUT_START, ADDRWIDTH
   .comm INPUT_END, ADDRWIDTH
   .comm TOKEN_START, ADDRWIDTH
   .comm TOKEN_END, ADDRWIDTH
   .comm LOADINGFILE, ADDRWIDTH
   .comm FILEMEMORYADDR, ADDRWIDTH
   .comm LOADLINESETUP, ADDRWIDTH
   .comm INFILELOAD, ADDRWIDTH
   .comm MULTILINE, ADDRWIDTH
   .comm PULLINANOTHER, ADDRWIDTH

.section .text

 .globl do_fix_up_semi
 do_fix_up_semi:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x4D
		sb t3, 2(a2)
		li t3, 0x49
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  .globl do_fix_up_equals
  do_fix_up_equals:
		li t3, 0x45
		sb t3, 0(a2)
		li t3, 0x51
		sb t3, 1(a2)
		li t3, 0x55
		sb t3, 2(a2)
		li t3, 0x41
		sb t3, 3(a2)
		li t3, 0x4C
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  .globl do_fix_up_tick
  do_fix_up_tick:
  		li t3, 0x54
		sb t3, 0(a2)
		li t3, 0x49
		sb t3, 1(a2)
		li t3, 0x43
		sb t3, 2(a2)
		li t3, 0x4B
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  .globl do_fix_up_comma
  do_fix_up_comma:
		li t3, 0x43
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x4D
		sb t3, 2(a2)
		sb t3, 3(a2)
		li t3, 0x41
		sb t3, 4(a2)
		addi a2, a2, 4
		ret

  do_fix_up_comment:
		la t1, MULTILINE
		ld t2, 0(t1)
		bnez t2, keep_fixing_up_comment
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, keep_fixing_up_comment
		#pull in another line
		la t0, PULLINANOTHER
		ld t1, 0(t0)
		jr t1
  keep_fixing_up_comment:
		ret

  .globl fix_up_input
  fix_up_input:
		#code to expand standard FORTH commands
		#to things we can use in RISC-V assembly
		#CURRENT EXPANSIONS
		# ;  --> SEMI
                # =  --> EQUALS
		# '  --> TICK
		# ,  --> COMMA
		ld t1, 0(sp)
		ld a0, 8(sp)			#unexpanded token address
		addi sp, sp, 16			#fix up stack so return address at top
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x3B
		beq t2, t1, fix_up_semi
		li t2, 0x3D
		beq t2, t1, fix_up_equals
		li t2, 0x27
		beq t2, t1, fix_up_tick
		li t2, 0x2C
		beq t2, t1, fix_up_comma
		li t2, 0x5C
		beq t2, t1, fix_up_comment
		j fix_up_finished

  fix_up_semi:
		call do_fix_up_semi
		tail fix_up_done
  fix_up_equals:
		call do_fix_up_equals
		tail fix_up_done
  fix_up_comment:
		call do_fix_up_comment
		ld ra, 0(sp)		# address of tokenize_finished_sanitization
		addi sp, sp, 8		# restore stack pointer
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret			#no expansion
  fix_up_tick:
		call do_fix_up_tick
		j fix_up_done
  fix_up_comma:
		call do_fix_up_comma
		j fix_up_done

  .globl fix_up_done		
  fix_up_done:
		POP ra
		mv t0, a3
		mv t1, a2	
                ret		# call tokenize_finished_sanitization

  fix_up_finished:
		addi sp, sp, 8
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret

  .globl fix_up_acomma
  fix_up_acomma:
		#copy 0 - 5 then expand "
		lb t3, 0(a0)
		andi t3, t3, 0x5F
		sb t3, 0(a2)
		lb t3, 1(a0)
		andi t3, t3, 0x5F
		sb t3, 1(a2)
		lb t3, 2(a0)
		andi t3, t3, 0x5F
		sb t3, 2(a2)
		lb t3, 3(a0)
		andi t3, t3, 0x5F
		sb t3, 3(a2)
		lb t3, 4(a0)
		andi t3, t3, 0x5F
		sb t3, 4(a2)
		li t3, 0x43
		sb t3, 5(a2)
		li t3, 0x4F
		sb t3, 6(a2)
		li t3, 0x4D4D
		sh t3, 7(a2)
		addi a2, a2, 8
		ret

  .globl fix_up_encsq
  fix_up_encsq:				#DOTQ called encsq for historical (!) reasons
		li t3, 0x44
		sb t3, 0(a2)
		li t3, 0x4F
		sb t3, 1(a2)
		li t3, 0x54
		sb t3, 2(a2)
		li t3, 0x51
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  .globl fix_up_brackettick
  fix_up_brackettick:
		#BRACKETTICK
		#0x42 0x52 0x41 0x43 0x4B 0x45 0x54 0x54 0x49 0x43 0x4B
		li t0, 0x54		#T
		li t1, 0x4B		#K
		li t4, 0x43		#C
		li t3, 0x42
		sb t3, 0(a2)
		li t3, 0x52
		sb t3, 1(a2)
		li t3, 0x41
		sb t3, 2(a2)
		sb t4, 3(a2)
		sb t1, 4(a2)
		li t3, 0x45
		sb t3, 5(a2)
		sb t0, 6(a2)
		sb t0, 7(a2)
		li t3, 0x49
		sb t3, 8(a2)
		sb t4, 9(a2)
		sb t1, 10(a2)
		addi a2, a2, 10
		ret


  fix_up_zeroless:
		li t3, 0x5A
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x52
		sb t3, 2(a3)
		li t3, 0x4F
		sb t3, 3(a3)
		li t3, 0x4C
		sb t3, 4(a3)
		li t3, 0x45
		sb t3, 5(a3)
		li t3, 0x53
		sb t3, 6(a3)
		sb t3, 7(a3)
		addi a2, a2, 7
		ret

  .globl fix_up_zeroequal
  fix_up_zeroequal:
		li t3, 0x5A
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x52
		sb t3, 2(a3)
		li t3, 0x4F
		sb t3, 3(a3)
		li t3, 0x45
		sb t3, 4(a3)
		li t3, 0x51
		sb t3, 5(a3)
		li t3, 0x55
		sb t3, 6(a3)
		li t3, 0x41
		sb t3, 7(a3)
		li t3, 0x4C
		sb t3, 8(a3)
		addi a2, a2, 8
		ret

  .globl fix_up_gteq
  fix_up_gteq:
		li t3, 0x47
  gteq_to_lteq:
		sb t3, 0(a2)
		li t3, 0x54
		sb t3, 1(a2)
		li t3, 0x45
		sb t3, 2(a2)
		li t3, 0x51
		sb t3, 3(a2)
		addi a2, a2, 3
		ret

  .globl fix_up_lteq
  fix_up_lteq:
		li t3, 0x4C
		j gteq_to_lteq
		
  .globl fix_up_ccomma
  fix_up_ccomma:
		li t3, 0x43
		sb t3, 0(a2)
		sb t3, 1(a2)
		li t3, 0x4F
		sb t3, 2(a2)
		li t3, 0x4D
		sb t3, 3(a2)
		sb t3, 4(a2)
		li t3, 0x41
		sb t3, 5(a2)
		addi a2, a2, 5
		ret

  .globl fix_up_cq
  fix_up_cq:
		li t3, 0x43		#C
		sb t3, 0(a2)
		li t3, 0x51		#Q
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  .globl fix_up_squote
  fix_up_squote:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x51
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  .globl fix_up_seq
  fix_up_seq:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x51
		sb t3, 2(a2)
		addi a2, a2, 2
		ret



  #a0 has start
  #a1 has end
  #a2 returns length
  .globl utility_expand_word 
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
			bne t1, t2, utility_expand_two_cq
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
			bne t1, t2, utilities_expand_six_done
			PUSH ra
			call fix_up_compilecomma_internal
			POP ra
			j utility_expand_done


		#now the fix up
  .globl fix_up_compilecomma
  fix_up_compilecomma:
		ld ra, 0(sp)
		addi sp, sp, 16
  fix_up_compilecomma_internal:
		#copy 0 - 6 then expand ,
		lb t3, 0(a0)
		andi t3, t3, 0x5F
		sb t3, 0(a2)
		lb t3, 1(a0)
		andi t3, t3, 0x5F
		sb t3, 1(a2)
		lb t3, 2(a0)
		andi t3, t3, 0x5F
		sb t3, 2(a2)
		lb t3, 3(a0)
		andi t3, t3, 0x5F
		sb t3, 3(a2)
		lb t3, 4(a0)
		andi t3, t3, 0x5F
		sb t3, 4(a2)
		lb t3, 5(a0)
		andi t3, t3, 0x5F
		sb t3, 5(a2)
		lb t3, 6(a0)
		andi t3, t3, 0x5F
		sb t3, 6(a2)
		li t3, 0x43
		sb t3, 7(a2)
		li t3, 0x4F
		sb t3, 8(a2)
		li t3, 0x4D4D
		sh t3, 9(a2)
		li t3, 0x41
		sb t3, 11(a2)
		addi a2, a2, 11
		ret



  #a0 has start
  #a1 has end
  #a2 has length
  #a3 returns 1 on success
  #a4 holds address
  .globl utility_check_dictionary_match
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

