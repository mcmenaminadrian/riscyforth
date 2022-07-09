#Basic primatives we need to get anything done

.balign 8

  dictionary_top:

	        CODEEND TYPEPROMPT,  0x01
                WRITECR
                WRITECHAR 0x0A
                WRITECHAR 0x3E                          #> prompt
                tail NEXT

  	        CODEHEADER GETNEXTLINE_IMM, TYPEPROMPT, 0x0
                #Fetch a line for immediate execution
                MARKINPUTBUFFER INPUT_BUFFER            #ensure buffer starts 'empty'
		sd zero, INPUT_DISPLACE, t0
  getnextline_imm_entry:
		li a0, 0
		la a1, INPUT_BUFFER
		li a2, BUFFERLEN
		call read
		li t0, 1
                mv a2, a0                          #a2 to hold length
                bgeu a2, t0, getnextline_imm_input
                tail NEXT                               #no input
  getnextline_imm_input:
                sd a1, INPUT_START, t0
                add a1, a1, a2                          #a2 has the end of input
                sd a1, INPUT_END, t0
		tail NEXT

		CODEHEADER GETLINE, GETNEXTLINE_IMM, 0x01
		#Fetch a line - not available for tokenization
		li a0, 0
		la a1, INPUT_BUFFER
		li a2, BUFFERLEN
		call read
		addi sp, sp, -16
		sd a1, 8(sp)			#address pf text
		sd a0, 0(sp)			#length of text
		la a0, INPUT_BUFFER		#ensure no tokenization
		sd a0, INPUT_START, t0
		sd a0, INPUT_END, t0
		sd zero, INPUT_DISPLACE, t0 
		tail NEXT

		CODEHEADER DROPINPUT, GETLINE, 0x01
		#stop input line being processed
		la t0, INPUT_END
		ld t0, 0(t0)
		la t1, INPUT_START
		sd t0, 0(t1)
		sd zero, INPUT_DISPLACE, t0
		tail NEXT
          
                CODEHEADER OK, DROPINPUT, 0x00
                la a0, OKSTATUS
		ld a0, 0(a0)
                bne a0, zero, ok_not_ok
                la a0, Ok_msg
                call puts
                tail NEXT
  ok_not_ok:
                addi t0, zero, 1
                bne a0, t0, ok_serious_issue_possibly
                sd zero, OKSTATUS, t0
                tail NEXT
  ok_serious_issue_possibly:
                la a0, Error_msg
                call puts
                sd zero, OKSTATUS, t0
                tail NEXT


                CODEHEADER TOKENIZE_IMM, OK, 0x0       
                #puts 1 on stack if system variables
                #TOKEN_START and TOKEN_END hold valid values
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, tokenize_normal
		la t0, LOADLINESETUP
		ld t0, 0(t0)
		bnez t0, tokenize_normal
  pull_in_another:
		jal load_get_next_line		      #suck in a line
  tokenize_normal:
		la t3, INDOES				#check if we are still doing DOES>
		ld t4, 0(t3)
		beqz t4, tokenize_not_does_
		tail search_create_keep_does_
  tokenize_not_does_:
                la a1, INPUT_END
		ld a1, 0(a1)
                la a0, INPUT_START
		ld a0, 0(a0)
		la a4, INFILELOAD
		ld a4, 0(a4)
		bnez a4, tokenize_buffer_set		#don't mess about with file loads
		la a5, INPUT_DISPLACE
		ld a5, 0(a5)
		la a6, INPUT_BUFFER
		sub a7, a0, a6
		beq a7, a5, tokenize_buffer_set
		add a0, a6, a5
  tokenize_buffer_set:
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, tokenize_have_data       #buffer has data
  tokenize_all_over:
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, tokenize_really_all_over
		la t0, LOADLINESETUP
		sd zero, 0(t0)
  tokenize_really_all_over:
		la t0, INEVAL				#handle EVALUATE case
		ld t1, 0(t0)
		beq t1, zero, tokenize_leave
		sd zero, INEVAL, t1
		la t0, RESUME_AFTER_EVAL
		ld s7, 0(t0)
		la t0, SOURCEID
		sd zero, 0(t0)				#SOURCE-ID
  tokenize_leave:
                tail NEXT
  tokenize_have_data:
                mv t0, a0                             #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                   #t2 space
                addi t3, zero, 0x0A                   #t3 CR
  tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, tokenize_keep_going
                bne t4, t3, tokenize_found_start
		la t5, MULTILINE
		ld t6, 0(t5)
		beqz t6, tokenize_call_all_over
		#handle special DOES> case
		addi t0, t0, 1
		sd t0, INPUT_START, t5
		j tokenize_not_does_
  tokenize_call_all_over:
                j tokenize_all_over
  tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, tokenize_look_for_start
                j tokenize_all_over                   #got nothing
  tokenize_found_start:
                mv t1, t0                             #t1 to track end of token
		
  tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, tokenize_end_token
                beq t4, t3, tokenize_end_token
                j tokenize_advance_search
  tokenize_end_token:
                sd t1, INPUT_START, t5                #update the end point for subsequent searches
		la a5, INPUT_BUFFER
		la a6, INPUT_DISPLACE
		sub a7, t1, a5
		sd a7, 0(a6)
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
		sub a0, t1, t0			      #a0 has length of token - 1
		bnez a0, tokenize_test_length_two
		li a0, 0x41			      #A
		li a1, 0x5A			      #Z
		li a2, 0x61			      #a
		li a3, 0X7A			      #z
		lb a4, 0(t0)
		blt a4, a0, tokenize_fix_up_single
		bltu a4, a0, tokenize_prepare_sanity_test
		blt a4, a2, tokenize_fix_up_single
		bltu a4, a3, tokenize_prepare_sanity_test
		j tokenize_fix_up_single
  tokenize_test_length_two:
		li a1, 1			      #test if input is of length2
		bne a0, a1, tokenize_test_length_three
		PUSH t0
		jal fix_up_length_two
		j tokenize_prepare_sanity_test
  tokenize_fix_up_single:
		PUSH t0
		jal fix_up_input		      #one character token so check for expansion
		j tokenize_prepare_sanity_test
  tokenize_test_length_three:
		li a1, 2
		bne a0, a1, tokenize_test_length_six
		PUSH t0
		jal fix_up_length_three
		j tokenize_prepare_sanity_test	
  tokenize_test_length_six:	
		li a1, 5
		bne a0, a1, tokenize_test_length_eight
		PUSH t0
		jal fix_up_length_six
		j tokenize_prepare_sanity_test
  tokenize_test_length_eight:
		li a1, 7
		bne a0, a1, tokenize_prepare_sanity_test
		PUSH t0
		jal fix_up_length_eight
		
  tokenize_prepare_sanity_test:
                addi t5, zero, 0x61                   #lowercase a
                addi t6, zero, 0x7B                   #lowercase z + 1
  tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, tokenize_next_sane
                blt t4, t6, tokenize_sanitize
                j tokenize_next_sane
  tokenize_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, tokenize_finished_sanitization
                j tokenize_sanity_test
  tokenize_finished_sanitization:
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
                la s8, WA_SEARCH                      #hit search directly now
                li t2, 1
                PUSH t2                               #indicate TOKEN_ values are valid
                tail RUN


		CODEHEADER SEARCH, TOKENIZE_IMM, 0x0
                POP a0
                beq a0, zero, search_no_token     
                li t0, 1
                bne a0, t0, search_bad_pop
                la t0, TOKEN_START                    #token values are valid
		ld t0, 0(t0)
                la t1, TOKEN_END
		ld t1, 0(t1)
		la t2, CREATEFLAG
		ld t2, 0(t2)
		beq t2, zero, search_continue	      #we are in immediate mode
                j search_create_continue
  search_no_token:
                li t0, 2                      #should never get here - so warn if we do
                sd t0, OKSTATUS, t1
                tail NEXT
  search_bad_pop:
                li t0, 2
                sd t0, OKSTATUS, t1
                PUSH a0                               #restore bad POP
                tail NEXT
  search_continue:
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                ld t3, 0(t4)
  search_next_in_dictionary:
                lb t4, 24(t3)
                bne t4, t2, search_tokens_do_not_match
                add a0, t3, 32                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_loop_through_token
                
  search_tokens_do_not_match:
                ld t3, 16(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_exhausted        #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                addi t3, t3, 8                        #address that points to the code
                PUSH t3                               #store word address on the call stack
                tail EXE


  sumstring:
	#input
	#a0 has start of string
	#a1 has length
		addi sp, sp, -40
		sd s1, 0(sp)
		sd s2, 8(sp)
		sd s3, 16(sp)
		sd s4, 24(sp)
		sd s5, 32(sp)
		li s1, 0x10	#10
		li s2, 0x30	#0
		li s3, 0x39	#9
		mv s6, zero	#count
  sumstring_read:
		lbu s4, 0(a0)
		blt s4, s2, sumstring_fail
		bgt s4, s3, sumstring_fail
		sub s4, s4, s2
		mul s6, s6, s1
		add s6, s6, s4
		addi a1, a1, -1
		beqz a1, sumstring_done
		addi a0, a0, 1
		j sumstring_read
  sumstring_done:
		mv a0, s6
  sumstring_return:
		ld s5, 32(sp)
		ld s4, 24(sp)
		ld s3, 16(sp)
		ld s2, 8(sp)
		ld s1, 0(sp)
		addi sp, sp, 40
		ret
  sumstring_fail:
		li a0, -1
		j sumstring_return

  scan_floats:
		#can we interpret the string as FP?
		#must have digit and at least one of E or .
		li a0, 0x30	#0
		li a1, 0x39	#9
		li a2, 0x45	#E
		li a3, 0x2E	#.
		mv a4, zero	#count of matches
		li a5, 0x20	#space
		li a6, 0x0A	#CR
		PUSH t1		#start of string
		mv t3, zero	#count length
		mv t4, zero	#don't keep counting numbers
 scan_float_scan:
		lbu t5, 0(t1)
		bne t5, a2, scan_float_notE
		#cannot start with an E
		beqz t3, scan_float_done_out
		addi a4, a4, 1
		addi t3, t3, 1
		j scan_float_next
  scan_float_notE:
		bne t5, a3, scan_float_notDot
		addi a4, a4, 1
		j scan_float_next
  scan_float_notDot:
		beq t5, a5, scan_float_done
		beq t5, a6, scan_float_done
		blt t5, a0, scan_float_done_out
		bgt t5, a1, scan_float_done_out
		addi t3, t3, 1
		bnez t4, scan_float_next
		addi a4, a4, 1
		addi t4, t4, 1
  scan_float_next:
		addi t1, t1, 1
		j scan_float_scan
  scan_float_done:
		li t4, 2	#min
		li t5, 3	#max
		blt a4, t4, scan_float_done_out
		bgt a4, t5, scan_float_done_out
		j process_float	#have a real one
  scan_float_done_out:
		POP t1
		ret
  process_float:
		ld t1 0(sp)
		PUSH t3		#save length
		#first of all - look for exponent
  process_float_search_exponent:
		mv t6, 0	#count of exponent
		lbu t5, 0(t1)
		addi t3, t3, -1
		beq t5, a2, process_float_count_exponent
		beqz t3, process_float_save_exponent
		j process_float_search_exponent
  process_float_count_exponent:
		addi sp, sp, -24
		sd a0, 0(sp)
		sd a1, 8(sp)
		sd ra, 16(sp)
		addi a0, t1, 1	#start of string
		mv a1, t3
		call sumString
		li a1, -1
		beq a0, a1, process_float_exponent_fail
		mv t6, a0
		ld a0, 0(sp)
		ld a1, 8(sp)
		ld ra, 16(sp)
		addi sp, sp, 24
  process_float_save_exponent:
		PUSH t6
		
		
		#TODO: Implement this - place number on stack
		tail EXE


  search_exhausted:
		#not a keyword - so can we interpret it as a number?
		la a0, FP_AVAILABLE
		ld a1, 0(a0)
		beqz a1, scan_integers
		call scan_floats
  scan_integers:
		#t0 points to start
		#modified version of code used in >NUMBER here
		mv t1, t0				#t1 points to characters
		mv t2, zero				#sum of number	
		#check if negative
		li a7, 1
		lbu t0, 0(t1)
		li t3, 0x2D
		bne t3, t0, search_start_number
		li a7, -1
		addi t1, t1, 1
  search_start_number:
		mv t6, zero
		la t3, CURRENT_BASE
		ld t3, 0(t3)				#base
		#establish the range of characters
		li t4, 0x0A
		li a0, 0x30
		bgt t3, t4, search_letter_base
		add a1, a0, t3
		j search_process_start
  search_letter_base:
		addi a1, t3, 0x36
  search_process_start:
		li a2, 0x40				#impermissibles
		li a3, 0x3A
		li a4, 0x20				#space
		li a5, 0x0A				#CR
  search_read:
		lbu t5, 0(t1)
		beq t5, a4, search_done
		beq t5, a5, search_done
		blt t5, a0, search_done_no_numb		#less than 0
		bgt t5, a1, search_done_no_numb		#greater than max
		blt t5, a3, search_continue_numb
		ble t5, a2, search_done_no_numb		#impermissible
  search_continue_numb:
		mul t6, t6, t3
		blt t5, a3, search_digit
		addi t5, t5, -55
		j search_sum
  search_digit:
		add t5, t5, -48
  search_sum:
		add t6, t6, t5
		addi t1, t1, 1
		j search_read
  search_done:
		add t6, t6, t2
		mul t6, t6, a7			      	#multiply by 1 or -1
		addi sp, sp, -16
                sd t6, 8(sp)                      	#save number on stack
                la t0, WA_TOKENIZE_IMM                	#keep tokenizing
                sd t0, 0(sp)
                tail EXE

  search_done_no_numb:
  search_failed:
                la t0, NotOk_msg
                addi t1, zero, 24                     #error message is 24 chars long 
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                ld a1, 0(t0)
                la t1, TOKEN_END
                ld a2, 0(t1)
                sub a2, a2, a1
                addi a2, a2, 1
                call write                            #output error message
                addi t0, zero, 1
                sd t0, OKSTATUS, t1
                tail NEXT

                CODEHEADER DECIMAL, SEARCH, 0x01
		li t1, 10
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER HEX, DECIMAL, 0x01
		li t1, 16
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER OCTAL, HEX, 0x01
		li t1, 8
                sd t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER BINARY, OCTAL, 0x01
		li t1, 2
                sd t1, CURRENT_BASE, t0
                tail NEXT

                #semi for outer loop
		CODEHEADER OLSEMI, BINARY, 0x0
		la t1, INFILELOAD
		ld t0, 0(t1)
		bnez t0, olsemi_fileload
                la s7, outer_loop
                tail NEXT
  olsemi_fileload:
		#loading a file
		la s7, outer_loop_tokenize
		tail NEXT
		
		#semi for the rest of us
                CODEHEADER SEMI, OLSEMI, 0x01
                ld s7, 0(s9)
                addi s9, s9, STACKOFFSET
                tail NEXT

		CODEHEADER _CQ, SEMI, 0x0
		#(-- c-addr)
		#pointer to counted string
		#only in compiled code
		PUSH s7
		ld t1, 0(s7)
		#now move s7 to next aligned address
		addi s7, s7, 8
		add t3, s7, t1
		li t4, 7
		and t5, t3, t4
		beqz t5, _cq_out
		li t4, 8
		sub t6, t4, t5
		add t3, t3, t6
  _cq_out:
		mv s7, t3
		tail NEXT

		CODEHEADER CQ, _CQ, 0x01
		#do nothing in interpreted code
		#nb expanded from C"
		tail NEXT

		CODEHEADERZ DOTP, .(, CQ, 0x101
		#("ccc<paren>" ---) immediate word
		#Print in a string
		#first of all, get the address and length of the string
		la t5, INPUT_END
		ld t5, 0(t5)		#absolute end of string
		li t3, 0
		la t6, INPUT_START
		ld t4, 0(t6)
		li t1, 0x29		#)
		j encsq_check_next

		CODEHEADER _SQ, DOTP, 0x0
		/* Expands to/from S"
		   (-- c-addr u)
		   Compiled version - permanent strings
		*/
		addi sp, sp, -16
		ld t1, 0(s7)
		sd t1, 0(sp)
		addi s7, s7, 8
		sd s7, 8(sp)
		#now move s7 to next aligned address
		add t3, s7, t1
		li t4, 7
		and t5, t3, t4
		beqz t5, _sq_out
		li t4, 8
		sub t6, t4, t5
		add t3, t3, t6
  _sq_out:
		mv s7, t3
		tail NEXT

		CODEHEADER SQ, _SQ, 0x01
		# Expands to S"
		#   (-- c-addr u)
		#In immediate mode this string
		#not guarenteed to last
		la t5, INPUT_END
		ld t5, 0(t5)		#absolute end of string
		li t3, 0
		la t6, INPUT_START
		ld t4, 0(t6)
		addi t4, t4, 1
		li t1, 0x22		#"
  sq_check_next:
		lb t0, 0(t4)
		beq t0, t1, sq_prep_memory_area
		addi t3, t3, 1
		addi t4, t4, 1
		blt t4, t5, sq_check_next
		la t0, String_err
		li t1, 18		#length of error message
		WRITESTRINGR t0, t1
		tail NEXT
  sq_prep_memory_area:
		ld t4, 0(t6)
		addi t4, t4, 1
		addi t2, t3, 1		#calculate end of string
		add t1, t4, t2
		sd t1, 0(t6)		#update input read point
		#now copy to memory area - temporary copy only
		la t0, dataspaceptr
		ld t1, 0(t0)
		li t2, 7
		and t0, t1, t2
		beqz t0, sq_write_out
		li t2, 8
		sub t2, t2, t0
		add t1, t1, t2
  sq_write_out:
		sd t3, 0(t1)
		addi t1, t1, 8
		addi sp, sp, -16
		sd t3, 0(sp)
		sd t1, 8(sp)
  sq_write_mem:
		beqz t3, sq_done
		lb t5, 0(t4)
		sb t5, 0(t1)
		addi t4, t4, 1
		addi t1, t1, 1
		addi t3, t3, -1
		j sq_write_mem
  sq_done:
		tail NEXT

		CODEHEADER _DOTQ, SQ, 0x00
		#compiled DOTQ
		ld a0, 0(s7)
		mv a1, s7
		add s7, s7, a0
		li t0, 7
		and t1, s7, t0
		beqz t1, encsq_compiled_readyoutput
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  encsq_compiled_readyoutput:
		addi s7, s7, 8
		addi a1, a1, 8
		mv a2, a0
		li a0, 1
		li a7, 64
		ecall			#make system call
		tail NEXT

		CODEHEADER DOTQ, _DOTQ, 0x01
		#Print in a string
		#first of all, get the address and length of the string
		la t5, INPUT_END
		ld t5, 0(t5)		#absolute end of string
		li t3, 0
		la t6, INPUT_START
		ld t4, 0(t6)
		li t1, 0x22		#"
  encsq_check_next:
		lb t0, 0(t4)
		beq t0, t1, encsq_prep_imm_syscall
		addi t3, t3, 1
		add t4, t4, 1
		blt t4, t5, encsq_check_next
		la t0, String_err
		li t1, 18		#length of error message
		WRITESTRINGR t0, t1
		tail NEXT
  encsq_prep_imm_syscall:
		ld t4, 0(t6)
		addi t2, t3, 1
		add t1, t4, t2
		sd t1, 0(t6)
		la a0, INPUT_DISPLACE
		ld a1, 0(a0)
		add a1, a1, t3
		addi a1, a1, 1
		sd a1, 0(a0)		#update >IN count
		WRITESTRINGR t4, t3
		tail NEXT

		CODEHEADERZ COMMENT, \\, DOTQ, 0x101
		#immediate word
		tail search_create_dispose_of_comment

                CODEHEADERZ DOT, ., COMMENT, 0x01
		li a7, 10
                ld t0, CURRENT_BASE
                POP a2                            #get item on stack
                la a0, SCRATCH_PAD                #sprintf uses this
		mv a3, zero

		#convert to based string
		#limiting characters
		li t2, 0x30				#0
		li t3, 0x39				#9
		mv a1, a2
		bne t0, a7, dot_produce_char_non_decimal
		bgez a2, dot_produce_char
		neg a2, a2				#in decimal - negative number
		
  dot_produce_char:		
		#decimal - signed output
		div t1, a2, t0
		j dot_produce_continue
  dot_produce_char_non_decimal:
		divu t1, a2, t0
  dot_produce_continue:
		mul t6, t1, t0
		sub t6, a2, t6				#t6 now has remainder
		add t6, t6, t2
		ble t6, t3, dot_char_out
		#greater than 9 - so add more
		addi t6, t6, 7
  dot_char_out:
		sb t6, 0(a0)
		addi a0, a0, 1
		addi a3, a3, 1
		mv a2, t1
		beqz a2, dot_produce_output
		beq t0, a7, dot_produce_char
		j dot_produce_char_non_decimal

  dot_produce_output:
		#now have our string but backwards
		la t5, SCRATCH_PAD
		#negative number?
		bne t0, a7, dot_prepare_to_write
		bge a1, zero, dot_prepare_to_write
		li t6, 0x2D				#-
		add t0, t5, a3	
		sb t6, 0(t0)
		addi a3, a3, 1

  dot_prepare_to_write:
		li t0, 1
		beq a3, t0, dot_write
		mv t0, t5
		add t1, t5, a3
		addi t1, t1, -1
		mv t2, t5
  dot_reverse:
		lbu t3, 0(t2)
		lbu t4, 0(t1)
		sb t4, 0(t2)
		sb t3, 0(t1)
		addi t2, t2, 1
		addi t1, t1, -1
		ble t1, t2, dot_write
		j dot_reverse
  dot_write:
		mv t1, a3
		WRITESTRINGR t5, t1		
                WRITECHAR 0x20            #space
                j NEXT
  fix_up_length_three:
		#expand ['] --> BRACKETTICK
		#S\" --> SEQ
		POP a0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		lbu t1, 0(a0)
		li t3, 0xDF		#to fix to upper case
		and t4, t1, t3
		li t2, 0x53		#S
		bne t4, t2, fix_up_length_three_check_bracket
		lbu t1, 1(a0)
		li t2, 0x5C		#\
		bne t1, t2, fix_up_finished
		lbu t1, 2(a0)
		li t2, 0x22
		bne t1, t2, fix_up_finished
		call fix_up_seq
		j fix_up_done
  fix_up_length_three_check_bracket:
                li t2, 0x5B             #[
                bne t1, t2, fix_up_finished
                lbu t1, 1(a0)
                li t2, 0x27             #'
                bne t1, t2, fix_up_finished
                lbu t1, 2(a0)
                li t2, 0x5D             #]
                bne t1, t2, fix_up_finished
		call fix_up_brackettick
		j fix_up_done

  fix_up_length_eight:
		#expand COMPILE, --> COMPILECOMMA
		#COMPILE: 0x43 0x4F 0x4D 0x50 0x49 0x4C 0x45
		#COMMA: 0x43 0x4F 0x4D 0x4D 0x41
		POP a0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		li t2, 0x43		#C
		lbu t1, 0(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x4F		#O
		lbu t1, 1(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x4D		#M
		lbu t1, 2(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x50		#P
		lbu t1, 3(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x49		#I
		lbu t1, 4(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x4C		#L
		lbu t1, 5(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x45		#E
		lbu t1, 6(a0)
		andi t1, t1, 0x5F
		bne t1, t2, fix_up_finished
		li t2, 0x2C		#,
		lbu t1, 7(a0)
		bne t1, t2, fix_up_finished

		#now the fix up
  fix_up_compilecomma:
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
		j fix_up_done
					

  fix_up_length_six:
		#expand the following
		# ABORT" --> ABORTCOMM
		POP a0
		la a2, EXPANDED_BUFFER
		mv a3, a2
		mv a1, t1 
		mv a5, t2
		li t2, 0x41
		lb t1, 0(a0)
		andi t1, t1, 0x5F
		bne t2, t1, fix_up_six_done
		li t2, 0x42
		lb t1, 1(a0)
		andi t1, t1, 0x5F
		bne t2, t1, fix_up_six_done 
		li t2, 0x4F
		lb t1, 2(a0)
		andi t1, t1, 0x5F
		bne t2, t1, fix_up_six_done 
		li t2, 0x52
		lb t1, 3(a0)
		andi t1, t1, 0x5F
		bne t2, t1, fix_up_six_done 
		li t2, 0x54
		lb t1, 4(a0)
		andi t1, t1, 0x5F
		bne t2, t1, fix_up_six_done 
		lbu t1, 5(a0)
		li t2, 0x22		 #"
		bne t1, t2, fix_up_six_done
		call fix_up_acomma
		j fix_up_done
  fix_up_six_done:
		j fix_up_finished
		
  fix_up_length_two:
                #code to expand, if needed, two character input
                #SUPPORTED EXPANSIONS
		# ."  --> ENCSQ
		# C,  --> CCOMMA
		# 0=  --> ZEROEQUAL
		# >=  --> GTEQ
		# <=  --> LTEQ
		# S"  --> SQ
		POP a0				#unexpanded token address
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
		mv a1, t1
		mv a5, t2
		lbu t1, 0(a0)
		li t2, 0x30			#0
		beq t1, t2, length_two_begin0
		li t2, 0x2E			#.
		beq t1, t2, length_two_begindot
		li t2, 0x3E			#>
		beq t1, t2, length_two_begingt
		li t2, 0x3C			#<
		beq t1, t2, length_two_beginlt
		PUSH t1
		andi t1, t1, 0x5F		#character based tests all in here
		li t2, 0x43			#C
		beq t1, t2, length_two_beginC
		li t2, 0x53
		beq t1, t2, length_two_beginS
		POP t1
		
		
  fix_up_length_two_finished:
		j fix_up_finished

  length_two_begin0:
		lb t1, 1(a0)
		li t2, 0x3D			#=
		bne t1, t2, length_two_begindot_done
 		call fix_up_zeroequal
		j fix_up_done	
  length_two_begindot:
		lb t1, 1(a0)
		li t2, 0x22			#"
		bne t1, t2, length_two_begindot_done
                call fix_up_encsq
		j fix_up_done
  length_two_begingt:
		lb t1, 1(a0)
		li t2, 0x3D			#>
		bne t1, t2, length_two_begindot_done
 		call fix_up_gteq
		j fix_up_done	
  length_two_beginlt:
		lb t1, 1(a0)
		li t2, 0x3D			#<
		bne t1, t2, length_two_begindot_done
 		call fix_up_lteq
		j fix_up_done	
		
  length_two_begindot_done:
		j fix_up_length_two_finished

  length_two_beginC:
		addi sp, sp, 8			#clear stack
		lb t1, 1(a0)
		li t2, 0x2C			#,
		bne t1, t2, length_two_c_q
		call fix_up_ccomma
		j fix_up_done
  length_two_c_q:
		li t2, 0x22			#"
		bne t1, t2, length_two_c_done
		call fix_up_cq
		j fix_up_done
		
  length_two_c_done:
		j fix_up_length_two_finished

  length_two_beginS:
		lb t1, 1(a0)
		li t2, 0x22			#"
		bne t1, t2, length_two_c_done
		addi sp, sp, 8
		call fix_up_squote
		j fix_up_done


  fix_up_input:
		#code to expand standard FORTH commands
		#to things we can use in RISC-V assembly
		#CURRENT EXPANSIONS
		# ;  --> SEMI
                # =  --> EQUALS
		# '  --> TICK
		# ,  --> COMMA
		POP a0				#unexpanded token address
		la a2, EXPANDED_BUFFER 		#store expanded token
		mv a3, a2
  fix_up_start:
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
		j fix_up_done
  fix_up_equals:
		call do_fix_up_equals
		j fix_up_done
  fix_up_comment:
		call do_fix_up_comment
		mv t0, a0
		mv t1, a1
		mv t2, a5
		j tokenize_finished_sanitization	#no expansion
  fix_up_tick:
		call do_fix_up_tick
		j fix_up_done
  fix_up_comma:
		call do_fix_up_comma
		j fix_up_done
		
  fix_up_done:
		mv t0, a3
		mv t1, a2	
                j tokenize_finished_sanitization 

  fix_up_finished:
		mv t0, a0
		mv t1, a1
		mv t2, a5
		ret

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

  do_fix_up_comment:
		la t1, MULTILINE
		ld t2, 0(t1)
		bnez t2, keep_fixing_up_comment
		la t0, INFILELOAD
		ld t0, 0(t0)
		beqz t0, keep_fixing_up_comment
		j pull_in_another		      #suck in a line
  keep_fixing_up_comment:
		ret

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

  fix_up_lteq:
		li t3, 0x4C
		j gteq_to_lteq
		
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

  fix_up_cq:
		li t3, 0x43		#C
		sb t3, 0(a2)
		li t3, 0x51		#Q
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  fix_up_squote:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x51
		sb t3, 1(a2)
		addi a2, a2, 1
		ret

  fix_up_seq:
		li t3, 0x53
		sb t3, 0(a2)
		li t3, 0x45
		sb t3, 1(a2)
		li t3, 0x51
		sb t3, 2(a2)
		addi a2, a2, 2
		ret
		
.include "integer.S"
.include "stackop.S"
.include "listwords.S"
.include "loops.S"
.include "facility.S"
