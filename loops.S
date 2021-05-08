

		CODEHEADER EMIT, VARIABLE, 0x01
		POP a1
		addi a0, zero, 1
		PUSH a1
		mv a1, sp
		add a2, zero, 1
		call write
		POP zero
		tail NEXT

		CODEHEADER CR, EMIT, 0x01
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
		PUSH t1
		PUSH t0
		tail NEXT

		CODEHEADER TOR2, TWORFETCH, 0x01  #2>R
		POP t0
		POP t1
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
		POP t0
		POP t1
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
		
		


		
