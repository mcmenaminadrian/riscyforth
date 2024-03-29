# riscyforth is licenced under GPL v2
# copyright, Adrian McMenamin, 2021
# search-create - search for word addresses when we are in create mode


  search_create_continue:
	        sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                ld t3, 0(t4)
  search_create_next_in_dictionary:
                lbu t4, 24(t3)
                bne t4, t2, search_create_tokens_do_not_match
                add a0, t3, 32                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_create_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, search_create_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_create_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_create_loop_through_token

  search_create_tokens_do_not_match:
                ld t3, 16(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_create_exhausted        #at the end of the dictionary
                j search_create_next_in_dictionary

  search_create_tokens_matched:
		#are we in POSTPONE mode?
		la a0, INPPONE
		ld a1, 0(a0)
		beqz a1, search_create_not_postpone_mode
		sd zero, 0(a0)
		addi t3, t3, 8
		j search_create_inscribe
  search_create_not_postpone_mode:
		#check - is this an immediate word
		ld a0, 0(t3)
		li a1, 0x100
		and a2, a0, a1
		beqz a2, search_create_nonimmediate
		la s7, outer_loop_tokenize
		tail search_tokens_matched
  search_create_nonimmediate:
                addi t3, t3, 8                        #address that points to the code
		#if this is just a comment we don't care - get to the next CR
		la t0, WA_POSTPONE
		bne t3, t0, search_create_check_colon
		la a0, INPUT_START
		ld a0, 0(a0)
		la a1, INPUT_END
		ld a1, 0(a1)
		call utility_process_postpone
		bnez a0, search_create_handle_postponed_word
		j search_create_does_outer_loop
  search_create_handle_postponed_word:
		j search_create_inscribe
  search_create_check_colon:
		#now check it is allowed
		la t0, WA_COLON			      #cannot nest definitions
		bne t3, t0, search_create_literal
		la t0, CREATEFLAG
		sd zero, 0(t0)
  search_create_report_error:
		tail search_failed		      #report error
  search_create_literal:
		la t0, WA_LITERAL
		bne t3, t0, search_create_does_
		ld a2, 0(sp)
		addi sp, sp, 8
		tail search_create_number_on_stack   #write out a literal
  search_create_does_:
		la t0, WA_DOES_
		bne t3, t0, search_create_allowed
		#write out DOES_ word address and tidy up
		#emulating SEMI
  search_create_keep_does_:				#rejoin here	
		la t0, createwritepoint
		ld t1, 0(t0)
		la t5, INDOES
		ld t6, 0(t5)
		bnez t6, search_create_continue_indoes
		sd t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 8
		#set INDOES to 1
		li t6, 1
		sd t6, 0(t5)
  search_create_continue_indoes:
		#now copy out the following text until we hit semi
		la a0, INPUT_START
		ld a1, 0(a0)
		la t5, INPUT_END
		la a5, INPUT_DISPLACE
		ld t6, 0(t5)
		ld a6, 0(a5)				#track >IN
		li a2, 59				#;
		li a7, 10				#\n
  search_create_does_copy:
		lbu a3, 0(a1)
		sb a3, 0(t1)
		addi t1, t1, 1
		addi a1, a1, 1
		addi a6, a6, 1
		beq a3, a7, search_create_does_keep_on
		beq a3, a2, search_create_does_copy_done		
		bgt a1, t6, search_create_does_keep_on
		j search_create_does_copy
  search_create_does_copy_done:
		li a3, 0x0A
		sb a3, 0(t1)
		addi t1, t1, 1
		sd a1, 0(a0)
		sd a6, 0(a5)
		#check alignment for writing
		li t5, 0x07
		and t6, t1, t5
		beqz t6, search_create_does_update_wp
		li t4, 0x08
		sub t5, t4, t6
		add t1, t1, t5
  search_create_does_update_wp:
		sd t1, 0(t0)
		la t0, CREATEFLAG
		sd zero, 0(t0)			      #back to immediate execution
		la t0, newdictionary
		la t2, dictionary
		ld t3, 0(t0)			      #load address of new word
		sd t3, 0(t2)			      #store address of new word as start for dictionary
		sd t1, 0(t0)			      #update address we will writenext word to
		la s7, outer_loop_tokenize
		fence.i 				#ensure cache coherency
		la t0, INDOES
		sd zero, 0(t0)				#we're done with DOES so reset flag
		tail NEXT
  search_create_does_keep_on:
		#update write point
		sd t1, 0(t0)
		la t3, INFILELOAD
		ld t4, 0(t3)
		beqz t4, search_create_does_outer_loop
		la s7, outer_loop_tokenize		#pull in next line from file
		la t0, LOADLINESETUP
		sd zero, 0(t0)
		tail NEXT
  search_create_does_outer_loop:
		la s7, outer_loop			#not done with does so require more input
		tail NEXT
	
  search_create_allowed:
		#handle in the same way as printed strings generally
		la t0, WA_ABORTCOMM
		bne t3, t0, search_encsq
                la t3, WA__ABORTCOMM
		add a5, a5, 4			      #clear the command
		tail embed_encsq
  search_encsq:
		#test for DOTQ (ie string printing)
		la t0, WA_DOTQ
		bne t3, t0, search_sq
		#substitute WA__DOTQ
		la t3, WA__DOTQ
		#jump to code that will count string and embed length and literal
		tail embed_encsq
  search_sq:
		la t0, WA_SQ
		bne t3, t0, search_cq
		#put in WA__SQ
		la t3, WA__SQ
		tail embed_sq
  search_cq:
		la t0, WA_CQ
		bne t3, t0, search_seq
		#subsititue WA__CQ
		la t3, WA__CQ
		tail embed_sq
  search_seq:
		la t0, WA_SEQ
		bne t3, t0, search_marker
		#substitute WA__SEQ
		la t3, WA__SEQ
		tail embed_seq
  search_marker:
		la t0, WA_MARKER
		bne t3, t0, search_tick
		#subsititue WA__MARAKER
		la t3, WA__MARKER
		tail embed_marker
  search_tick:
		la t0, WA_TICK
		bne t3, t0, search_brackettick
		#substitute WA__TICK
  search_tick_brackettick_join:
		la t3, WA__TICK
		tail embed_tick
  search_brackettick:
		la t0, WA_BRACKETTICK
		beq t3, t0, search_tick_brackettick_join
		#handle COMPILE,
		la t0, WA_COMPILECOMMA
		bne t3, t0, search_is
		ld t3, 0(sp)
		addi sp, sp, 8
		j search_create_inscribe
  search_is:
		la t0, WA_IS
		bne t3, t0, search_to
		#subsitute WA__IS
		la t3, WA__IS
		tail embed_tick
  search_to:
	 	la t0, WA_TO
		bne t3, t0, search_bracketchar
		#substitute WA__TO
		la t3, WA__TO
		tail embed_to
  search_bracketchar:
		la t0, WA_BRACKETCHAR
		bne t3, t0, search_termiosstring
		#substitute WA__BRACKETCHAR
		la t3, WA__BRACKETCHAR
		tail embed_to
  search_termiosstring:
		la t0, WA_TERMIOSSTRING
		bne t3, t0, search_char
		# substitute WA__TERMIOSSTRING
		la t3, WA__TERMIOSSTRING
		tail embed_to
  search_char:
		la t0, WA_CHAR
		bne t3, t0, search_actionof
		la t3, WA__CHAR
		tail embed_tick
  search_actionof:
		la t0, WA_ACTIONOF
		bne t3, t0, search_wa_again
		la t3, WA__ACTIONOF
		tail embed_defer
  search_wa_again:
		#test for AGAIN
		la t0, WA_AGAIN
		bne t3, t0, search_wa_until
		#insert three instruction simple loop back
		la t3, WA__AGAIN			#substitute
		j search_create_inscribe
  search_wa_until:
		#test for UNTIL
		la t0, WA_UNTIL
		bne t3, t0, search_loop_replace_do
		#insert three instruction simple loop back
		la t3, WA__UNTIL			#substitute
		j search_create_inscribe
  search_loop_replace_do:
		la t0, WA_DO
		bne t3, t0, search_loop_replace_qdo
		la t3, WA__DO
		j transitions_do_out
  search_loop_replace_qdo:
		la t0, WA_QDO
		bne t3, t0, search_loop_replace_loop
		la t3, WA__QDO
		j transitions_do_out
  search_loop_replace_loop:
		la t0, WA_LOOP
		bne t3, t0, search_loop_replace_plusloop
		la t3, WA__LOOP
		j transitions_loop_out
  search_loop_replace_plusloop:
		la t0, WA_PLUSLOOP
		bne t3, t0, search_loop_replace_minusloop
		la t3, WA__PLUSLOOP
		j transitions_loop_out
  search_loop_replace_minusloop:
		la t0, WA_MINUSLOOP
		bne t3, t0, search_loop_replace_unloop
		la t3, WA__MINUSLOOP
		j transitions_loop_out
  search_loop_replace_unloop:
		la t0, WA_UNLOOP
		bne t3, t0, search_loop_replace_leave
		la t3, WA__UNLOOP
		j search_create_inscribe
  search_loop_replace_leave:
		la t0, WA_LEAVE
		bne t3, t0, search_loop_replace_recurse
		la t3, WA__LEAVE
		j search_create_inscribe
  search_loop_replace_recurse:
		la t0, WA_RECURSE
		bne t3, t0, search_loop_replace_i
		la t0, newdictionary
		ld t1, 0(t0)
		addi t3, t1, 0x8
		j search_create_inscribe				#t3 has address of word to drop in	
  search_loop_replace_i:
		la t0, WA_I
		bne t3, t0, search_loop_replace_j
		la t3, WA__I
		j search_create_inscribe
  search_loop_replace_j:
		la t0, WA_J
		bne t3, t0, search_replace_exit
		la t3, WA__J
		j search_create_inscribe
  search_replace_exit:
		la t0, WA_EXIT
		bne t3, t0, search_create_test_conditionals
		la t3, WA__EXIT
		j search_create_inscribe
  search_create_test_conditionals:
		#test for conditionals
		la t0, WA_IF
		bne t3, t0, search_create_test_else
		la t3, WA__IF
		j transitions_if_out
  search_create_test_else:
		la t0, WA_ELSE
		bne t0, t3, search_create_test_of
		la t3, WA__ELSE
		j transitions_else_out
  search_create_test_of:
		la t0, WA_OF
		bne t0, t3, search_create_test_then
		la t3, WA__OF
		j search_create_inscribe
  search_create_test_then:
		la t0, WA_THEN
		bne t0, t3, search_create_test_while
		j transitions_then_out
  search_create_test_while:
		la t0, WA_WHILE
		bne t0, t3, search_create_test_repeat
		la t3, WA__WHILE
		j transitions_while_out
  search_create_test_repeat:
		la t0, WA_REPEAT
		bne t0, t3, search_create_inscribe
		la t3, WA__REPEAT
		j transitions_repeat_out
  search_create_bad_ifmode:
		#error
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail search_failed

  search_create_inscribe:
		#test for special case
		la t0, WA__UNTIL
		beq t0, t3, search_create_add_until_backcount
		la t0, WA__AGAIN
		bne t0, t3, search_create_continue_inscription
		j transitions_again_out
  search_create_add_until_backcount:
		j transitions_until_out
  search_create_continue_inscription:
		#search through the extenders
		PUSH t3
		mv a0, t3
		call getExtenders
		POP t3
		beqz a0, search_create_no_extender
		jr a0					#shift control to extender code
  search_create_no_extender:
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 8
		sd t1, 0(t0)
  search_create_test_semi:
		la t0, WA_SEMI			      #are we finished with create?
		bne t3, t0, search_create_leave
  search_create_test_postpone_semi:
		#tidy up create as we are done
		sd zero, MULTILINE, a0
		la t0, CREATEFLAG
		sd zero, 0(t0)			      #back to immediate execution
		li t0, 0x07
		and t0, t0, t1
		beq t0, zero, search_create_address_aligned_ok #already aligned
		addi t1, t1, 0x08
		li t0, 0xFFFFFFFFFFFFFFF8
		and t1, t1, t0			      #ensure alignment
  search_create_address_aligned_ok:
		la t0, newdictionary
		la t2, dictionary
		ld t3, 0(t0)			      #load address of new word
		sd t3, 0(t2)			      #store address of new word as start for dictionary
		sd t1, 0(t0)			      #update address we will writenext word to
  search_create_leave:
		la s7, outer_loop_tokenize
		fence.i 				      #ensure cache coherency
                tail NEXT

  search_create_exhausted:
		#firstly - are we in POSTPONE?
		la a0, INPPONE
		ld a1, 0(a0)
		beqz a1, search_create_exhausted_postpone_only
		la t3, WA__NUMBER
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 8
		sd t1, 0(t0)
		j search_create_leave	
  search_create_exhausted_postpone_only:
		#test for variable etc
		mv a4, t0
		lbu t4, 0(a4)
		li a5, 0x23
		#test for address #
		beq t4, a5, search_create_read_address
		li a5, 0x5A 				#Z
		#if not a number then a fail 
		bleu t4, a5, search_create_handle_number
		j variable_gone_bad
  search_create_handle_number:
		ld t2, CURRENT_BASE
		li t3, 16
		beq t2, t3, search_create_check_hex
		li t3, 8
		bne t2, t3, search_create_check_decimal
		j search_create_check_octal

  search_create_check_hex:
		#function call
		#a0 - start address [in]
		#a1 - valid [out]
		#a2 - result [out]
		#a3 - end address [in]
		mv a0, t0
		mv a3, t1
		call func_test_hex
  search_create_test_func_result:
		li t2, 1
		beq a1, t2, search_create_number_on_stack
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail search_failed

  search_create_check_decimal:
		mv a0, t0
		mv a3, t1
		call func_test_hex
		j search_create_test_func_result

  search_create_check_octal:
		mv a0, t0
		mv a3, t1
		call func_test_hex
		j search_create_test_func_result

  search_create_read_address:
		#hash at first address
		#then check numbers
		
		ld t2, CURRENT_BASE
		addi t0, t0, 1
		li t3, 16
		beq t2, t3, search_create_check_hex_address
		li t3, 8
		bne t2, t3, search_create_check_decimal_address
		j search_create_check_octal_address


  search_create_check_hex_address:
		#function call
		#a0 - start address [in]
		#a1 - valid [out]
		#a2 - result [out]
		#a3 - end of token [in]
		mv a0, t0
		mv a3, t1
		call func_test_hex
  search_create_test_func_result_address:
		li t2, 1
		beq a1, t2, search_create_address_on_stack
		la t0, CREATEFLAG
		sd zero, 0(t0)
		tail search_failed

  search_create_check_decimal_address:
		mv a0, t0
		call func_test_hex
		j search_create_test_func_result_address

  search_create_check_octal_address:
		mv a0, t0
		call func_test_hex
		j search_create_test_func_result_address

  search_create_number_on_stack:
		la t3, WA_LITERALNUMB
		j search_create_literal_out
  search_create_address_on_stack:
		la t3, WA_LITERALADDR

  search_create_literal_out:		
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      #write out word address in definition
  search_create_literal_out_postpone:
		sd a2, 8(t1)
		addi t1, t1, 16
		sd t1, 0(t0)
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT

		#now number processing functions
		#a0 address [in]
		#a1 valid [out]
		#a2 result [out]
		#a3 end of token [in]
		#a4 base (set in fuction)
  func_test_hex:
		#hex name is hangover from old code - handles all bases
		add sp, sp, -96
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		sd s3, 24(sp)
		sd s4, 32(sp)
		sd s5, 40(sp)
		sd s6, 48(sp)
		sd s7, 56(sp)
		sd s8, 64(sp)
		sd s9, 72(sp)
		sd s10, 80(sp)
		sd s11, 88(sp)
		mv a1, zero
		mv a2, zero
		la a4, CURRENT_BASE
		ld a4, 0(a4)

		#test if number is neagtive
		li s10, 1
		li s0, 0x2D
		lbu s11, 0(a0)
		bge s0, s11, func_test_hex_negative
		j func_test_hex_characters
  func_test_hex_negative:
		li s10, -1			#handle negative
		addi a0, a0, 1
		bgt a0, a3, func_test_hex_clean
  func_test_hex_characters:
		#establish the range of characters
		li s0, 0x30			#0
		li s1, 0x39			#9
		li s2, 0x41			#A

		li s5, 10
		bgt a4, s5, func_test_hex_over10
		li s4, 0x2F
		j func_test_hex_set_max
  func_test_hex_over10:
		li s4, 0x36
  func_test_hex_set_max:
		add s4, s4, a4
  func_test_hex_read:
		lbu s3, 0(a0)			#read character
		blt s3, s0, func_test_hex_clean	#too low
		bgt s3, s4, func_test_hex_clean	#too high
		bge s3, s2, func_test_hex_good
		ble s3, s1, func_test_hex_good
		j func_test_hex_clean		#in impermissable range
  func_test_hex_good:
		mul a2, a2, a4
		ble s3, s1, func_test_hex_digit
		addi s3, s3, -55
		j func_test_hex_sum
  func_test_hex_digit:
		addi s3, s3, -48
  func_test_hex_sum:
		add a2, a2, s3
		addi a0, a0, 1
		bgt a0, a3, func_test_hex_done
		j func_test_hex_read

  func_test_hex_done:
		mul a2, a2, s10
		li a1, 1
  func_test_hex_clean:
		ld s11, 88(sp)
		ld s10, 80(sp)
		ld s9, 72(sp)
		ld s8, 64(sp)
		ld s7, 56(sp)
		ld s6, 48(sp)
		ld s5, 40(sp)
		ld s4, 32(sp)
		ld s3, 24(sp)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, 96
		ret		

  embed_defer:
		#embed string - processing it as we go
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)				#write out word address
  embed_defer_postpone:
		PUSH t1					# save for later
		la a0, INPUT_START
		la a1, INPUT_END
		ld a0, 0(a0)
		ld a1, 0(a1)
		call utility_find_string
		bnez a0, embed_defer_continue
		tail search_failed
  embed_defer_continue:
		la a5, INPUT_DISPLACE
		ld a6, 0(a5)
		sub a7, a1, a0
		add a6, a6, a7
		sd a6, 0(a5)
		sd a1, INPUT_START, t5
		call utility_sanitize_string
		mv t0, a0
		mv t1, a1
		#t0 has start of token
		#t1 has end of token
		addi t1, t1, -1
		mv t2, t0
		mv t3, t1
		sub a0, t3, t2
		addi a0, a0, 1
		POP t1
		sd a0, 8(t1)				#write out length
		addi t1, t1, 16				#prepare to embed
		mv a2, a0
		mv a3, t0
		mv a5, t1
  embed_defer_code:
		beqz a2, embed_defer_check_alignment
		lbu a4, 0(a3)
		sb a4, 0(a5)
		addi a2, a2, -1
		addi a5, a5, 1
		addi a3, a3, 1
		j tick_embed_code
  embed_defer_check_alignment:
		#need to ensure alignment of output maintained
		#a1 holds length
		mv a1, a0
		li a0, 0x07
		li a2, 0x08
		and a3, a1, a0
		sub a3, a2, a3
		add a1, a1, a3
		add t1, t1, a1
		la a0, createwritepoint
		sd t1, 0(a0)				#advance writepoint
		beqz a0, embed_defer_done
		#increment the conditionals
		addi a1, a1, 16				#command and length
		srli a5, a1, 3
  embed_defer_done:
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT

  embed_to:
  embed_tick:
  embed_marker:
		# embed string - but don't process it in any way
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)				# write out word address
  embed_tick_postpone:
		PUSH t1					# save for later
		# find length
		call tick_start_looking
		# t0 has start of token
		# t1 has end of token
		# update buffer pointers
		la t3, INPUT_START
		ld t4, 0(t3)
		la t5, INPUT_DISPLACE
		ld a5, 0(t5)
		# TODO: does this work for eval and should it?
		la a0, INPUT_BUFFER			# update from start of input
		sub t6, t4, a0
		sd t6, 0(t5)
		addi t1, t1, -1
		mv t2, t0
		mv t3, t1
		sub a0, t3, t2
		addi a0, a0, 1
		POP t1
		sd a0, 8(t1)				# write out length
		addi t1, t1, 16				# prepare to embed
		mv a2, a0
		mv a3, t0
		mv a5, t1
  tick_embed_code:
		beqz a2, tick_embed_check_alignment
		lbu a4, 0(a3)
		sb a4, 0(a5)
		addi a2, a2, -1
		addi a5, a5, 1
		addi a3, a3, 1
		j tick_embed_code
  tick_embed_check_alignment:
		#need to ensure alignment of output maintained
		#a1 holds length
		mv a1, a0
		li a0, 0x07
		li a2, 0x08
		and a3, a1, a0
		beqz a3, tick_embed_advance_write 
		sub a3, a2, a3
		add a1, a1, a3
  tick_embed_advance_write:
		add t1, t1, a1
		la a0, createwritepoint
		sd t1, 0(a0)				#advance writepoint
  embed_tick_done:
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT

  embed_seq:
		#embed processed string
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)				#write out WA__SEQ
		#now count and process the string
		addi t1, t1, 24				#WA__SEQ, advance, length, string
		PUSH t1					#we need this for later
		la t0, INPUT_START
		ld t0, 0(t0)
		mv a7, t0				#to calculate the offset later
		addi t0, t0, 1
		ld a0, 0(sp)				#write address
		li a1, 0				#characters written
		li a2, 0x5C
		li t1, 0x22
  embed_seq_pick_up_char:
		lbu t2, 0(t0)
		beq t2, a2, embed_seq_process_escape
		beq t2, t1, embed_seq_check_alignment
  embed_seq_write_out_char:
		sb t2, 0(a0)
		addi a1, a1, 1
		addi a0, a0, 1
		addi t0, t0, 1
		j embed_seq_pick_up_char
  embed_seq_process_escape:
		lbu t3, 1(t0)
		li t4, 0x22				#"
		bne t3, t4, embed_seq_process_a
		mv t2, t4
  embed_seq_process_escaped:
		addi t0, t0, 1
		j embed_seq_write_out_char
  embed_seq_process_a:
		li t4, 0x61
		bne t3, t4, embed_seq_process_b
		li t2, 7				#BEL
		j embed_seq_process_escaped
  embed_seq_process_b:
		li t4, 0x62
		bne t3, t4, embed_seq_process_e
		li t2, 8				#BS
		j embed_seq_process_escaped
  embed_seq_process_e:
		li t4, 0x65
		bne t3, t4, embed_seq_process_f
		li t2, 0x1B				#ESC
		j embed_seq_process_escaped
  embed_seq_process_f:
		li t4, 0x66
		bne t3, t4, embed_seq_process_l
		li t2, 12				#Form feed
		j embed_seq_process_escaped
  embed_seq_process_l:
		li t4, 0x6C
		bne t3, t4, embed_seq_process_m
		li t2, 10				#LF
		j embed_seq_process_escaped
  embed_seq_process_m:
		li t4, 0x6D
		bne t3, t4, embed_seq_process_n
		li t2, 13
		sb t2, 0(a0)
		addi a0, a0, 1
		li t2, 10				#CR/LF
		j embed_seq_process_escaped
  embed_seq_process_n:
		li t4, 0x6E
		bne t3, t4, embed_seq_process_q
		li t2, 10				#LF is newline for Unix
		j embed_seq_process_escaped
  embed_seq_process_q:
		li t4, 0x71
		bne t3, t4, embed_seq_process_r
		li t2, 0x22				#"
		j embed_seq_process_escaped
  embed_seq_process_r:
		li t4, 0x72
		bne t3, t4, embed_seq_process_t
		li t2, 13				#CR
		j embed_seq_process_escaped
  embed_seq_process_t:
		li t4, 0x74
		bne t3, t4, embed_seq_process_v
		li t2, 9				#horizontal tab
		j embed_seq_process_escaped
  embed_seq_process_v:
		li t4, 0x76
		bne t3, t4, embed_seq_process_z
		li t2, 11				#vertical tab
		j embed_seq_process_escaped
  embed_seq_process_z:
		li t4, 0x7A
		bne t3, t4, embed_seq_process_slash
		li t2, 0				#NUL
		j embed_seq_process_escaped
  embed_seq_process_slash:
		li t4, 92
		bne t3, t4, embed_seq_process_x
		mv t2, t4				#\
		j embed_seq_process_escaped
  embed_seq_process_x:
		li t4, 0x78
		bne t3, t4, embed_seq_process_escaped
		#convert next two characters to hex number
		lbu t5, 2(t0)
		lbu t6, 3(t0)
		li t3, 0x20
		or t5, t5, t3
		or t6, t6, t3
		li t3, 0x30				#0
		li t4, 0x39				#9
		li a7, 0x66				#f
		li a6, 0x61				#a
		li a5, 0				#character we build
		#process highest digit
		blt t5, t3, embed_seq_process_escaped	#failed
		bgt t5, t4, embed_seq_process_highdigit_high
		mv a5, t5
		sub a5, a5, t3
  embed_seq_build_high_digit:
		slli a5, a5, 4				#multiply by 16
		j embed_seq_process_low_digit
  embed_seq_process_highdigit_high:
		blt t5, a6, embed_seq_process_escaped
		bgt t5, a7, embed_seq_process_escaped
		mv a5, t5
		addi a5, a5, -87			#a = 10
		j embed_seq_build_high_digit
  embed_seq_process_low_digit:
		blt t6, t3, embed_seq_process_escaped	#failed
		bgt t6, t4, embed_seq_process_lowdigit_high
		sub t6, t6, t3
  embed_seq_build_low_digit:
		add a5, a5, t6
		j embed_seq_process_hex_done
  embed_seq_process_lowdigit_high:
		blt t6, a6, embed_seq_process_escaped
		bgt t6, a7, embed_seq_process_escaped
		addi t6, t6, -87			#a = 10
		j embed_seq_build_low_digit
  embed_seq_process_hex_done:
		addi t0, t0, 2
		mv t2, a5
		j embed_seq_process_escaped
  embed_seq_check_alignment:
		la a4, INPUT_START
		addi t0, t0, 1				#past the "
		sd t0, 0(a4)
		sub a6, a7, t0
		la a7, INPUT_DISPLACE
		ld a5, 0(a7)
		add a5, a5, a6
		sd a5, 0(a7)				#update >IN
		#writing done
		POP a4
		sd a1, -8(a4)				#length of string
		#need to ensure alignment of output maintained
		#a0 holds where we ended up
		li a1, 0x07
		li a2, 0x08
		and a3, a1, a0
		sub a3, a2, a3
		add a0, a0, a3
		la a1, createwritepoint
		sd a0, 0(a1)				#advance writepoint
		sd a0, -16(a4)
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT


  embed_sq:
  embed_encsq:
		#embed string - after we count how long it is
		la t0, createwritepoint
		ld t1, 0(t0)
		sd t3, 0(t1)			      	#write out word address in definition
		#now get length
		mv t0, a5
		addi t0, t0, 3			      	#pass the opening "
		mv a0, t0				#set up pointer to inside string
		li a1, 0
		li a2, 0x201				#max length
		li t2, 0x22				#"
  embed_encsq_check_next:
		lbu a3, 0(a0)				#read char
		beq a3, t2, embed_encsq_gotlength	#if closing " jump
		addi a0, a0, 1				#increment pointer
		addi a1, a1, 1				#increment count
		blt a1, a2, embed_encsq_check_next	#loop back if in range
		la t0, String_err			#otherwise -- error message
		li t1, 18
		WRITESTRINGR t0, t1
		WRITECR
		tail NEXT				#failed
  embed_encsq_gotlength:
		#write out the length
		sd a1, 8(t1)				#embed length
		addi t1, t1, 16				#prepare to embed the string
		#t0 points to the start of the string in buffer
		#a1 holds its length
		#t1 the write point
		mv a2, a1				#countdown
		mv a3, t0				#readpoint
  embed_encsq_embed:
		beqz a2, embed_encsq_checkalignment	#jump if counted to zero
		lbu a4, 0(a3)				#load char
		sb a4, 0(t1)				#write char
		addi a2, a2, -1				#decement countdown
		addi a3, a3, 1				#increment readpoint
		addi t1, t1, 1				#increment writepoint
		j embed_encsq_embed			#loop
  embed_encsq_checkalignment:
		#need to ensure alignment of output maintained
		#a1 holds length
		li a0, 0x07
		li a2, 0x08
		la t1, INPUT_START
		la t5, INPUT_DISPLACE
		ld t0, 0(t1)
		ld t6, 0(t5)
		add t0, t0, a1
		add t6, t6, a1
		addi t0, t0, 2				#account for "
		addi t6, t6, 2
		sd t0, 0(t1)
		sd t6, 0(t5)
		and t0, a1, a0
		beqz t0, embed_encsq_alignmentadjusted
		sub t2, a2, t0
		add a1, a1, t2
  embed_encsq_alignmentadjusted:
		addi a1, a1, 16				#account for length too
		la t1, createwritepoint
		ld t0, 0(t1)
		add t0, t0, a1
		sd t0, 0(t1)
		beqz a0, embed_encsq_done
		#increment the conditionals
		srli a5, a1, 3
  embed_encsq_done:
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT


  search_create_dispose_of_comment:
		#this code just takes us beyond the current comment
		#no need to write out a comment word - just delay execution for nothing
		#only need to check if we are in MULTILINE
		la t0, MULTILINE
		ld t1, 0(t0)
		la t0, INPUT_START
		la t2, INPUT_END
		ld t3, 0(t2)
		bnez t1, search_create_move_through_comment
  search_create_comment_done:
		sd t3, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT
  search_create_move_through_comment:
		#we are in MULTILINE mode - so search for next CR
		li t4, 10
		ld t1, 0(t0)
  search_create_keep_processing_comment:
		beq t1, t3, search_create_comment_done
		lb t5, 0(t1)
		addi t1, t1, 1
		bne t4, t5, search_create_keep_processing_comment
		sd t1, 0(t0)
		la s7, outer_loop_tokenize
		tail NEXT
