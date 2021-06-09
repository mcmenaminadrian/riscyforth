

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
		lw t0, 0(s7)
		add s7, s7, t0
		tail NEXT
  end_of_end:
		add s7, s7, 4
		tail NEXT

		CODEHEADER WHILE, _END, 0x01
		tail NEXT

		CODEHEADER _WHILE, WHILE, 0x0
		lw t0, 0(s7)			#similar to _END but jump back is unconditional
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
		lw t0, 0(s9)
		PUSH t0
		tail NEXT

		CODEHEADER TWORFETCH, RFETCH, 0x01	#2R@
		lw t0, 0(s9)
		lw t1, STACKOFFSET(s9)
		addi sp, sp, -16
		sw t1, 8(sp)
		sw t0, 0(sp) 
		tail NEXT

		CODEHEADER TOR2, TWORFETCH, 0x01  #2>R
		lw t0, 0(sp)
		lw t1, 8(sp)
		addi sp, sp, 16
		add s9, s9, -(STACKOFFSET * 2)
		sw t1, STACKOFFSET(s9)
		sw t0, 0(s9)
		tail NEXT

		CODEHEADER TOR, TOR2, 0x01 #>R
		POP t0
		addi s9, s9, -STACKOFFSET
		sw t0, 0(s9)
		tail NEXT

		CODEHEADER RFROM, TOR, 0x01 #R>
		lw t0, 0(s9)
		PUSH t0
		addi s9, s9, STACKOFFSET
		tail NEXT

		CODEHEADER STORE, RFROM, 0x01		#!
		lw t0, 0(sp)
		lw t1, 8(sp)
		addi sp, sp, 16
		sw t1, 0(t0)
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
		sw t1, 0(t0)				#set MODE to 1 (compile)
		la t1, newdictionary
		lw t3, 0(t1)
		li t2, 0x01
		sw t2, 0(t3)				#flag
		addi t2, t3, 0x28			#word address of new word
		sw t2, 4(t3)
		la t0, dictionary
		lw t1, 0(t0)
		sw t1, 8(t3)				#words address of previous word
		li t2, 0XFFFFFFFF			#now fill in name space
		sw t2, 16(t3)
		sw t2, 20(t3)
		sw t2, 24(t3)
		sw t2, 28(t3)
		sw t2, 32(t3)
		sw t2, 36(t3)
		#now read in the name
		PUSH t3		

                lw a1, INPUT_END
                lw a0, INPUT_START
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, colon_tokenize_have_data       #buffer has data
  colon_tokenize_all_over:
                j colon_fail
  colon_tokenize_have_data:
                mv t0, a0                             #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                   #t2 space
                addi t3, zero, 0x0A                   #t3 CR
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
		addi t2, zero, 0x20			#back to checkinging space and CR
		addi t3, zero, 0x0A
  colon_tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, colon_tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, colon_tokenize_end_token
                beq t4, t3, colon_tokenize_end_token
                j colon_tokenize_advance_search
  colon_tokenize_end_token:
                sw t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
                bne t0, t1, colon_tokenize_prepare_sanity_test
                PUSH t0				      #POPed by fix_up code
                jal fix_up_input                      #one character token so check for expansion
  colon_tokenize_prepare_sanity_test:
                addi t5, zero, 0x61                   #lowercase a
                addi t6, zero, 0x7B                   #lowercase z + 1
  colon_tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, colon_tokenize_next_sane
                blt t4, t6, colon_tokenize_sanitize
                j colon_tokenize_next_sane
  colon_tokenize_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  colon_tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, colon_tokenize_finished_sanitization
                j colon_tokenize_sanity_test
  colon_tokenize_finished_sanitization:
                sw t0, TOKEN_START, t2
                sw t1, TOKEN_END, t2
		POP t3
		sub t4, t1, t0
		addi t4, t4, 1				#add 1 to get length
		sw t4, 12(t3)				#write out length
		addi t1, t3, 16
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
		li t0, 0x1ce1
		sh t0, 40(t3)		#addi s9, s9, -8
		li t0, 0x0001
		sh t0, 42(t3)		#nop (to preserve alignment)
		li t0, 0x017ca023	
		sw t0, 44(t3)		#sw s7, 0(s9)
		#calculate the offset for lui
		addi t0, t3, 0x48
		li t1, 0xFFFFF000
		and t0, t0, t1
		li t1, 0xC37
		or t0, t0, t1
		sw t0, 48(t3)		#lui word address
		#calculate lower part of the sum
		addi t0, t3, 0x48
		li t4, 0xFFF
		and t0, t0, t4
		slli t0, t0, 20
		li t4, 0xc0c13
		or t0, t0, t4
		sw t0, 52(t3)		#add lower part
		li t0, 0x8be2
		sh t0, 56(t3)		#mv s7, s8
		li t0, 0x01
		sh t0, 58(t3)		#nop (to preserve alignment)
		#execute register based jump to NEXT
		la t1, NEXT		#t1 has the number
		#load the number into register t0
		li t2, 0xFFFFF000
		and t4, t1, t2
		ori t4, t4, 0x2B7	#lui t0
		sw t4, 60(t3)
		li t4, 0xFFF
		and t2, t1, t4
		slli t4, t2, 20
		li t5, 0x28293		#addi t0
		or t4, t4, t5
		sw t4, 64(t3)
		li t0, 0x28067		#jalr zero, 0(t0)
		sw t0, 68(t3)


		la t1, newdictionary
		lw t1, 0(t1)
		addi t1, t1, 72
		la t3, createwritepoint
		sw t1, 0(t3)
		tail NEXT


  colon_fail:
		la t0, CREATEFLAG
		sw zero, 0(t0)				#set MODE to 0 (no compile)
		POP zero
		PRINT bad_colon
		tail NEXT
		
		
  compile_in_end:					#a0 has old s7 value
		addi sp, sp, -80
		sw ra, 72(sp)
		sw s8, 64(sp)
		sw s7, 56(sp)
		sw s6, 48(sp)
		sw s5, 40(sp)
		sw s4, 32(sp)
		sw s3, 24(sp)
		sw s2, 16(sp)
		sw s1, 8(sp)
		sw s0, 0(sp)
		
		la s3, createwritepoint
		lw s3, 0(s3)
		sw a0, 0(s3)
		
		#now search for WA_BEGIN
		li s0, 0x200				#max depth of search backwards
		li s1, -4
		li s2, 4
		la s5, WA_BEGIN
		mv s6, s3
		mv s7, zero
		la s8, WA__END
  end_check_begin:
		addi s3, s3, -4
		lw s4, 0(s3)
		bne s4, s8, end_keep_checking
		addi s7, s7, 1
		j end_check_next
  end_keep_checking:
		beq s5, s4, end_found_begin
  end_check_next:
		add s1, s1, -4
		add s2, s2, 4
		blt s2, s0, end_check_begin
		#we have failed
		mv a0, zero
		j real_end_of_end
  end_found_begin:
		beqz s7, end_correct_begin
		addi s7, s7, -1				#skip an inner loop
		j end_check_next
  end_correct_begin:
		sw s1, 4(s6)				#write out offset
		la s0, createwritepoint
		addi s6, s6, 8
		sw s6, 0(s0)
		#now - are we in a conditional?
		call get_iffmode
		beqz a0, almost_end_of_end
		SETUP_CONDITIONAL_CALL
		call increment_current_skip		#we have to account for the literal (skip) if in a conditional
  almost_end_of_end:
		li a0, 1
  real_end_of_end:
		lw s0, 0(sp)
		lw s1, 8(sp)
		lw s2, 16(sp)
		lw s3, 24(sp)
		lw s4, 32(sp)
		lw s5, 40(sp)
		lw s6, 48(sp)
		lw s7, 56(sp)
		lw s8, 64(sp)
		lw ra, 72(sp)
		addi sp, sp, 80
		ret
