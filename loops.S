# offset for jumping
.equ CREATEOFFSET,	120


		CODEHEADER EMIT, VARIABLE, 0x01
		li a0, 1
		mv a1, sp
		li a2, 1
		call write
		POP zero
		tail NEXT

		CODEHEADER BEGIN, EMIT, 0x01
		tail NEXT			#BEGIN and END do nothing in immediate mode

		CODEHEADER END, BEGIN, 0x01
		tail NEXT

		CODEHEADER _END, END, 0x0	#subsitituted in compiled
		POP t0
		bnez t0, end_of_end
		ld t0, 0(s7)
		add s7, s7, t0
		tail NEXT
  end_of_end:
		add s7, s7, 8
		tail NEXT

		CODEHEADER WHILE, _END, 0x01
		tail NEXT

		CODEHEADER _WHILE, WHILE, 0x0
		ld t0, 0(s7)			#similar to _END but jump back is unconditional
		add s7, s7, t0
		tail NEXT

		CODEHEADER CR, _WHILE, 0x01
		WRITECR
		WRITECHAR 0x0A
		tail NEXT

		CODEHEADER SPACE, CR, 0x01
		WRITECHAR 0x20
		tail NEXT

		CODEHEADER RDROP, SPACE, 0x01
		addi s9, s9, STACKOFFSET
		tail NEXT

		CODEHEADER TWORDROP, RDROP, 0x01
		addi s9, s9, (2 * STACKOFFSET)
		tail NEXT

		CODEHEADER RFETCH, TWORDROP, 0x01	#R@
		ld t0, 0(s9)
		PUSH t0
		tail NEXT

		CODEHEADER TWORFETCH, RFETCH, 0x01	#2R@
		ld t0, 0(s9)
		ld t1, STACKOFFSET(s9)
		addi sp, sp, -16
		sd t1, 8(sp)
		sd t0, 0(sp) 
		tail NEXT

		CODEHEADER TOR2, TWORFETCH, 0x01  #2>R
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		add s9, s9, -(STACKOFFSET * 2)
		sd t1, STACKOFFSET(s9)
		sd t0, 0(s9)
		tail NEXT

		CODEHEADER TOR, TOR2, 0x01 #>R
		POP t0
		addi s9, s9, -STACKOFFSET
		sd t0, 0(s9)
		tail NEXT

		CODEHEADER RFROM, TOR, 0x01 #R>
		ld t0, 0(s9)
		PUSH t0
		addi s9, s9, STACKOFFSET
		tail NEXT

		CODEHEADER STORE, RFROM, 0x01		#!
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		sd t1, 0(t0)
		tail NEXT

		CODEHEADER SPACES, STORE, 0x01
		POP a0		#how many spaces
		PUSH s0
		mv s0, a0
  spaces_go:
		beq s0, zero,  spaces_done
		WRITECHAR 0x20
		addi s0, s0, -1
		j spaces_go
  spaces_done:
		POP s0		#honour ABI
		tail NEXT

		CODEHEADER COLON, SPACES, 0x01
		#SHIFT TO COMPILE MODE
		#WRITE OUT FLAGS
		#WRITE OUT PTR
		#WRITE OUT PTR

		la t0, CREATEFLAG
		li t1, 0x01
		sd t1, 0(t0)				#set MODE to 1 (compile)
		la t1, newdictionary
		ld t3, 0(t1)
		li t2, 0x01
		sd t2, 0(t3)				#flag
		addi t2, t3, 0x38			#word address of new word
		sd t2, 8(t3)
		la t0, dictionary
		ld t1, 0(t0)
		sd t1, 16(t3)				#words address of previous word
		sd zero, 24(t3)				#zero length
		li t2, 0XFFFFFFFFFFFFFFFF		#now fill in name space
		sd t2, 32(t3)
		sd t2, 40(t3)
		sd t2, 48(t3)
		#now read in the name
		PUSH t3		

                ld a1, INPUT_END
                ld a0, INPUT_START
                addi t0, a0, 1                        	#account for minimal input
                bltu t0, a1, colon_tokenize_have_data   #buffer has data
  colon_tokenize_all_over:
                j colon_fail
  colon_tokenize_have_data:
                mv t0, a0                             	#t0 tracks start of token, t1 the end
                li t2, 0x20                   		#t2 space
                li t3, 0x0A                   		#t3 CR
  colon_tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, colon_tokenize_keep_going
                bne t4, t3, colon_tokenize_found_start
                j colon_tokenize_all_over
  colon_tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, colon_tokenize_look_for_start
                j colon_tokenize_all_over                   #got nothing
  colon_tokenize_found_start:
		li t2, 0x30
		li t3, 0x39
		bgt t4, t3, colon_not_a_numeral
		bge t4, t2, colon_tokenize_all_over	    #cannot redefine a number
  colon_not_a_numeral:
                mv t1, t0                             #t1 to track end of token
		li t2, 0x20			#back to checkinging space and CR
		li t3, 0x0A
  colon_tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, colon_tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, colon_tokenize_end_token
                beq t4, t3, colon_tokenize_end_token
                j colon_tokenize_advance_search
  colon_tokenize_end_token:
                sd t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
                bne t0, t1, colon_tokenize_prepare_sanity_test
                PUSH t0				      #POPed by fix_up code
                jal fix_up_input                      #one character token so check for expansion
  colon_tokenize_prepare_sanity_test:
                li t5, 0x61                   #lowercase a
                li t6, 0x7B                   #lowercase z + 1
  colon_tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, colon_tokenize_next_sane
                blt t4, t6, colon_tokenize_sanitize
                j colon_tokenize_next_sane
  colon_tokenize_sanitize:
                li t3, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  colon_tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, colon_tokenize_finished_sanitization
                j colon_tokenize_sanity_test
  colon_tokenize_finished_sanitization:
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
		POP t3
		sub t4, t1, t0
		addi t4, t4, 1				#add 1 to get length
		sd t4, 24(t3)				#write out length
		addi t1, t3, 32
  colon_write_out_name:
		lb t5, 0(t0)
		sb t5, 0(t1)
		addi t4, t4, -1
		beqz t4, colon_name_written
		addi t0, t0, 1
		addi t1, t1, 1
		j colon_write_out_name
  colon_name_written:
		#now write out the colon code
		li t0, 0xFF8C8C93
		sw t0, 56(t3)		#addi s9, s9, -8,
		li t0, 0x017cb023	
		sw t0, 60(t3)		#sd s7, 0(s9)
		#calculate the address we need to jump to for 64 bits
		mv t2, t3
		addi t2, t2, CREATEOFFSET
		srli t2, t2, 32
		slli t2, t2, 20
		li t1, 0xC13
		or t2, t2, t1
		sw t2, 64(t3)		#addi s8, zero, [upper 32 bits >> 32]
		li t2, 0x20C1C13
		sw t2, 68(t3)		#slli s8, s8, 32
		li t1, 0xFFFFF000
		addi t4, t3, CREATEOFFSET
		and t0, t4, t1
		li t1, 0x2B7
		or t0, t0, t1
		sw t0, 72(t3)		#lui t0, [bits 12 - 31]
		li t2, 0x2029293
		sw t2, 76(t3)		#slli t0 32
		li t2, 0x202D293
		sw t2, 80(t3)		#srli t0 32	(zero out upper 32 bits)
		li t1, 0xFFF
		and t0, t4, t1		#t0 now has lower 12 bits
		mv t1, t0		#t1 has same lower 12 bits
		srli t1, t1, 11		#t1 now just top bit
		slli t1, t1, 20
		
		li t2, 0x313
		or t2, t1, t2
		sw t2, 84(t3)		#either addi t1, zero, 1 or addi t1, zero, 0
		li t1, 0xB31313
		sw t1, 88(t3)		#slli t1, t1, 11
		andi t0, t0, 0x7FF	#lower eleven bits
		slli t0, t0, 20
		li t1, 0x30313
		or t1, t0, t1
		sw t1, 92(t3)		#add bottom 11 bits to t1
		li t1, 0x6282B3
		sw t1, 96(t3)		#add t0, t0, t1
		li t0, 0x5C6C33
		sw t0, 100(t3)		#or s8, s8, t0
		li t0, 0x8be2
		sh t0, 104(t3)		#mv s7, s8
		#execute register based jump to NEXT
		la t1, NEXT		#t1 has the number
		#load the number into register t0
		li t2, 0xFFFFF000
		and t4, t1, t2
		ori t4, t4, 0x2B7	#lui t0
		sw t4, 106(t3)
		li t4, 0xFFF
		and t2, t1, t4
		slli t4, t2, 20
		li t5, 0x28293		#addi t0
		or t4, t4, t5
		sw t4, 110(t3)
		li t0, 0x28067		#jalr zero, 0(t0)
		sw t0, 114(t3)

		la t1, newdictionary
		ld t1, 0(t1)
		addi t1, t1, CREATEOFFSET
		la t3, createwritepoint
		sd t1, 0(t3)
		tail NEXT

  colon_fail:
		la t0, CREATEFLAG
		sd zero, 0(t0)				#set MODE to 0 (no compile)
		POP zero
		PRINT bad_colon
		tail NEXT
		
		
  compile_in_end:					#a0 has old s7 value
		addi sp, sp, -80
		sd ra, 72(sp)
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
		sd a0, 0(s3)
		
		#now search for WA_BEGIN
		li s0, 0x200				#max depth of search backwards
		li s1, -8
		li s2, 8
		la s5, WA_BEGIN
		mv s6, s3
		mv s7, zero
		la s8, WA__END
  end_check_begin:
		addi s3, s3, -8
		ld s4, 0(s3)
		bne s4, s8, end_keep_checking
		addi s7, s7, 1
		j end_check_next
  end_keep_checking:
		beq s5, s4, end_found_begin
  end_check_next:
		add s1, s1, -8
		add s2, s2, 8
		blt s2, s0, end_check_begin
		#we have failed
		mv a0, zero
		j real_end_of_end
  end_found_begin:
		beqz s7, end_correct_begin
		addi s7, s7, -1				#skip an inner loop
		j end_check_next
  end_correct_begin:
		sd s1, 8(s6)				#write out offset
		la s0, createwritepoint
		addi s6, s6, 16
		sd s6, 0(s0)
		#now - are we in a conditional?
		call get_iffmode
		beqz a0, almost_end_of_end
		SETUP_CONDITIONAL_CALL
		call increment_current_skip		#we have to account for the literal (skip) if in a conditional
  almost_end_of_end:
		li a0, 1
  real_end_of_end:
		ld s0, 0(sp)
		ld s1, 8(sp)
		ld s2, 16(sp)
		ld s3, 24(sp)
		ld s4, 32(sp)
		ld s5, 40(sp)
		ld s6, 48(sp)
		ld s7, 56(sp)
		ld s8, 64(sp)
		ld ra, 72(sp)
		addi sp, sp, 80
		ret
