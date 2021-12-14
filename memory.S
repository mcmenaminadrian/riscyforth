#########################################################################################################
#Forth words from the optional Memory Allocation set							#
#use our local allocator code rather than just malloc/free to ensure we don't lock up memory		#
#Copyright Adrian McMenamin, 2021									#
#Licenced for reuse under version 2 of the GNU General Public License					#
#########################################################################################################
.equ		DOESOFFSET, 104

		CODEHEADER CELLS, INCLUDE, 0x01
		#(x - x)
		ld t0, 0(sp)
		slli t0, t0, 3
		sd t0, 0(sp)
		tail NEXT

		CODEHEADERZ CELLPLUS, CELL+, CELLS, 0x01
		ld t0, 0(sp)
		addi t0, t0, 8
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER CELL, CELLPLUS, 0x01
		addi sp, sp, -8
		li t0, 8
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER COMMA, CELL, 0x01
		#(x --)
		#reserve one cell of data space and store TOS in the cell
		ld t0, 0(sp)
		addi sp, sp, 8
		la t1, dataspaceptr
		ld t2, 0(t1)
		addi t2, t2, 8
		sd t2, 0(t1)
		sd t0, 0(t2)
		tail NEXT

		CODEHEADER CCOMMA, COMMA, 0x01
		#(char --)
		#reserve one character space of data space and store character at TOS in that space
		lb t0, 0(sp)
		addi sp, sp, 8
		la t1, dataspaceptr
		ld t2, 0(t1)
		addi t2, t2, 1
		sd t2, 0(t1)
		sb t0, 0(t2)
		tail NEXT

		CODEHEADER CHARS, CCOMMA, 0x01
		#(n -- n)
		#chars are 1 wide
		tail NEXT

		CODEHEADER NOP, CHARS, 0x0
		#do nothing
		tail NEXT

		CODEHEADERZ DEFERSTORE, DEFER!, NOP, 0x0
		#(x2 x1 --) x1 executes x2
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		ld t2, 0(t0)
		addi t3, t2, DOESOFFSET
		sd t1, 0(t3)
		tail NEXT

		CODEHEADERZ DEFERFETCH, DEFER@, DEFERSTORE, 0x01
		#(xt - xt)
		ld t0, 0(sp)
		ld t1, 0(t0)
		addi t2, t1, DOESOFFSET
		ld t3, 0(t2)
		sd t3, 0(sp)
		tail NEXT

		CODEHEADER _IS, DEFERFETCH, 0x0
		#get length
		ld a0, 0(s7)
		mv a1, s7
		addi s7, s7, 8
		add s7, s7, a0
		li t0, 7
		and t1, s7, t0
		beqz t1, _is_adjustment_over
		li t2, 8
		sub t2, t2, t1
		add s7, s7, t2
  _is_adjustment_over:
		#now rejoin IS
		add t0, a1, 8
		add t1, a0, t0
		call is_process_found_token
		tail NEXT

		CODEHEADER IS, _IS, 0x01
		#(xt -)
		#Also parses ahead for word created with DEFER
		#Parse input and take xt off stack
		#and use it to replace NOP (or previously replaced word)
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, is_have_data
		tail NEXT

  is_have_data:
		call utility_find_string
		beqz a0, is_exhausted
		mv t0, a0
		mv t1, a1
		mv a0, a2
		call is_process_found_token
		#now suppress the word being called!
		la t0, INPUT_START
		ld t1, 0(t0)
		add t1, t1, a0
		addi t1, t1, 1
		sd t1, 0(t0)
		tail NEXT

		#code essentially copied from TICK word
  is_process_found_token:
		addi sp, sp, -16
		sd ra, 0(sp)
		sd a0, 8(sp)				#store length
		la a7, is_finished_sanitization
		addi t1, t1, -1
		add a0, a0, -1
		bnez a0, is_length_two_or_more
		call tick_fix_up_single
		j is_prepare_sanity_test		#can skip the other tests for length
  is_length_two_or_more:
		li a1, 1
		bne a0, a1, is_length_six_or_more
		call tick_fix_up_length_two
		j is_prepare_sanity_test
  is_length_six_or_more:
		li a1, 5
		bne a0, a1, is_prepare_sanity_test
		call tick_fix_up_length_six
  is_prepare_sanity_test:
		mv a0, t0
		mv a1, t1
		call utility_sanitize_string
  is_finished_sanitization:
		#look up the command
		sub t2, t1, t0
		addi t2, t2, 1
		la t4, dictionary
		ld t3, 0(t4)
  is_next_in_dictionary:
		lb t4, 24(t3)
		bne t4, t2, is_tokens_do_not_match
		add a0, t3, 32
		mv a1, t0
		mv a2, t2
  is_loop_through_token:
		lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, is_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, is_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j is_loop_through_token
  is_tokens_do_not_match:
		ld t3, 16(t3)
		beqz t3, is_exhausted
		j is_next_in_dictionary
  is_tokens_matched:
		addi t3, t3, 8
		ld t3, 0(t3)
		#t3 now had address we need
		addi t3, t3, DOESOFFSET
		ld t0, 16(sp)
		sd t0, 0(t3)
		ld ra, 0(sp)
		ld a0, 8(sp)			#a0 returns with length
		addi sp, sp, 24
		ret
  is_exhausted:
		addi sp, sp, 16
		tail search_failed

		CODEHEADER DEFER, IS, 0x01
		#Parsing word - no stack action
		#Write out COLON
		#Insert NOP
		#Insert SEMI
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, defer_have_data
		tail NEXT
  defer_have_data:
		#small stack
		addi sp, sp, -8
		sd s0, 0(sp)
		call utility_find_string
		beqz a0, defer_gone_bad
		#now have a0 with start, a1 with end+1, a2 with length
		sd a1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, defer_gone_bad
		#write out a word with the variable name that will return the address
		#get the address we'll return
		mv a1, a2
		li a5, 0x21				#33 for a deferred word
		call utility_write_function_header
		mv s0, a0
		addi s0, s0, -56
		#write out colon
		mv t3, a0
		li t0, 0xFF8C8C93
		sw t0, 0(t3)		#addi s9, s9, -8,
		li t0, 0x017cb023	
		sw t0, 4(t3)		#sd s7, 0(s9)
		#calculate the address we need to jump to for 64 bits
		mv t2, t3
		addi t2, t2, DOESOFFSET
		srli t2, t2, 32
		slli t2, t2, 20
		li t1, 0xC13
		or t2, t2, t1
		sw t2, 8(t3)		#addi s8, zero, [upper 32 bits >> 32]
		li t2, 0x20C1C13
		sw t2, 12(t3)		#slli s8, s8, 32
		li t1, 0xFFFFF000
		addi t4, t3, DOESOFFSET
		and t0, t4, t1
		li t1, 0x2B7
		or t0, t0, t1
		sw t0, 16(t3)		#lui t0, [bits 12 - 31]
		li t2, 0x2029293
		sw t2, 20(t3)		#slli t0 32
		li t2, 0x202D293
		sw t2, 24(t3)		#srli t0 32	(zero out upper 32 bits)
		li t1, 0xFFF
		and t0, t4, t1		#t0 now has lower 12 bits
		mv t1, t0		#t1 has same lower 12 bits
		srli t1, t1, 11		#t1 now just top bit
		slli t1, t1, 20
		
		li t2, 0x313
		or t2, t1, t2
		sw t2, 28(t3)		#either addi t1, zero, 1 or addi t1, zero, 0
		li t1, 0xB31313
		sw t1, 32(t3)		#slli t1, t1, 11
		andi t0, t0, 0x7FF	#lower eleven bits
		slli t0, t0, 20
		li t1, 0x30313
		or t1, t0, t1
		sw t1, 36(t3)		#add bottom 11 bits to t1
		li t1, 0x6282B3
		sw t1, 40(t3)		#add t0, t0, t1
		li t0, 0x5C6C33
		sw t0, 44(t3)		#or s8, s8, t0
		li t0, 0x8be2
		sh t0, 48(t3)		#mv s7, s8
		#register based jump to NEXT
		mv a0, t3
		addi a0, a0, 50
		la a1, NEXT
		call utility_write_out_call_function
		sw zero, 0(a0)		#padding
		sh zero, 4(a0)
		la t0, WA_NOP		#will be overwritten by IS
		sd t0, 6(a0)
		la t0, WA_SEMI
		sd t0, 14(a0)
		#update dictionary etc
		addi a0, a0, 22
		la t0, newdictionary
		sd a0, 0(t0)
		la t0, dictionary
		sd s0, 0(t0)
		ld s0, 0(sp)
		addi sp, sp, 8
		tail NEXT

  defer_gone_bad:
		ld s0, 0(sp)
		addi sp, sp, 8
		j create_gone_bad

		CODEHEADERZ BODY_, >BODY, DEFER, 0x01
		#(xt - addr)
		ld t0, 0(sp)
		#first of all - check the address in t0 is of word created by CREATE
		mv t1, t0
		addi t1, t1, -8
		ld t2, 0(t1)
		li t3, 0x11
		beq t2, t3, body_continue
		#not a word created via CREATE
		#return zero
		sd zero, 0(sp)
		tail NEXT
  body_continue:
		ld t1, 72(t0)			#stored number 
		sd t1, 0(sp)
		tail NEXT

		CODEHEADERZ DOES_, DOES>,  BODY_, 0x01
		#write out a new colon at current address
		#replace the tail NEXT with a jump to the colon
		#now write out the colon code
		addi sp, sp, -24
		#small stack
		sd s0, 0(sp)
		sd s1, 8(sp)
		sd s2, 16(sp)
		#check the most recent definition - is it from CREATE?
		la t0, dictionary
		ld t1, 0(t0)
		ld t2, 0(t1)
		#reset newdictionary
		la t3, newdictionary
		sd t1, 0(t3)
		li t3, 0x11
		bne t3, t2, does__not_created_word
		ld s0, 8(t1)				#s0 has WA for created word
		la t0, CREATEFLAG
		li t1, 0x01
		sd t1, 0(t0)				#set MODE to 1 (compile)
		la t1, createwritepoint
		ld t3, 0(t1)
		li t0, 0xFF8C8C93
		sw t0, 0(t3)		#addi s9, s9, -8,
		li t0, 0x017cb023	
		sw t0, 4(t3)		#sd s7, 0(s9)
		#calculate the address we need to jump to for 64 bits
		mv t2, t3
		addi t2, t2, DOESOFFSET
		srli t2, t2, 32
		slli t2, t2, 20
		li t1, 0xC13
		or t2, t2, t1
		sw t2, 8(t3)		#addi s8, zero, [upper 32 bits >> 32]
		li t2, 0x20C1C13
		sw t2, 12(t3)		#slli s8, s8, 32
		li t1, 0xFFFFF000
		addi t4, t3, DOESOFFSET
		and t0, t4, t1
		li t1, 0x2B7
		or t0, t0, t1
		sw t0, 16(t3)		#lui t0, [bits 12 - 31]
		li t2, 0x2029293
		sw t2, 20(t3)		#slli t0 32
		li t2, 0x202D293
		sw t2, 24(t3)		#srli t0 32	(zero out upper 32 bits)
		li t1, 0xFFF
		and t0, t4, t1		#t0 now has lower 12 bits
		mv t1, t0		#t1 has same lower 12 bits
		srli t1, t1, 11		#t1 now just top bit
		slli t1, t1, 20
		
		li t2, 0x313
		or t2, t1, t2
		sw t2, 28(t3)		#either addi t1, zero, 1 or addi t1, zero, 0
		li t1, 0xB31313
		sw t1, 32(t3)		#slli t1, t1, 11
		andi t0, t0, 0x7FF	#lower eleven bits
		slli t0, t0, 20
		li t1, 0x30313
		or t1, t0, t1
		sw t1, 36(t3)		#add bottom 11 bits to t1
		li t1, 0x6282B3
		sw t1, 40(t3)		#add t0, t0, t1
		li t0, 0x5C6C33
		sw t0, 44(t3)		#or s8, s8, t0
		li t0, 0x8be2
		sh t0, 48(t3)		#mv s7, s8
		#execute register based jump to NEXT
		#make this fully portable even at cost of unneeded code
		la t1, NEXT		#t1 has the number
		srli t1, t1, 32		#eliminate the lower 32 bits
		slli t1, t1, 20		#in right place for the add
		li t0, 0x293
		or t0, t0, t1
		sw t0, 50(t3)		#addi t0, zero, [upper 32 of NEXT]
		li t0, 0x2029293
		sw t0, 54(t3)		#slli t0, t0, 32
		#now deal with lower 32 bits of NEXT address
		la t1, NEXT
		li t2, 0xFFFFF000
		and t1, t1, t2		#take upper 20 bits of lower 32
		li t2, 0x337
		or t0, t1, t2
		sw t0, 58(t3)		#lui t1, [bits 12 - 31]
		li t0, 0x2031313
		sw t0, 62(t3)		#slli t1, t1, 0x20
		li t0, 0x2035313
		sw t0, 66(t3)		#srli t1, t1, 0x20 (zero out upper 32 bits)
		la t1, NEXT
		li t2, 0xFFF
		and t0, t1, t2		#lower 12 bits only
		srli t1, t0, 11		#t1 has twelveth bit only
		li t2, 0x7FF
		and t0, t0, t2		#t0 has the lower 11 bits
		li t4, 0x393
		slli t1, t1, 20
		or t4, t4, t1
		sw t4, 70(t3)		#addi t2, zero, [0 or 1]
		li t4, 0xB39393
		sw t4, 74(t3)		#slli t2, t2, 11
		li t4, 0x7282B3
		sw t4, 78(t3)		#add t0, t0, t2
		li t4, 0x393
		slli t0, t0, 20
		or t4, t4, t0
		sw t4, 82(t3)		#addi t2, zero, [lower 11 bits]
		li t4, 0x7282B3
		sw t4, 86(t3)		#add t0, t0, t2
		li t4, 0x6282B3
		sw t4, 90(t3)		#add t0, t0, t1
		li t0, 0x28067		#jalr zero, 0(t0)
		sw t0, 94(t3)
		#now update the previously created function
		sd t3, 32(s0)
		#now update the writing point
		la t1, createwritepoint
		ld t3, 0(t1)
		addi t3, t3, DOESOFFSET
		sd t3, 0(t1)
		la s0, MULTILINE
		li s1, 1
		sd s1, 0(s0)
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, -24
		#now try to tokenize the line
		la t0, INPUT_START
		sd s7, 0(t0)
		addi t1, s7, 0x200
		la t2, INPUT_END
		sd t1, 0(t2)
		la s7, outer_loop_tokenize
		fence.i
		tail NEXT
  does__not_created_word:
		ld s2, 16(sp)
		ld s1, 8(sp)
		ld s0, 0(sp)
		addi sp, sp, -24
		tail create_gone_bad

		CODEHEADER CREATE, DOES_, 0x01
		#read in name
		#create shell in dictionary that returns start address
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, create_have_data
		tail NEXT				#nothing to parse
  create_have_data:
		call utility_find_string
		beqz a0, create_gone_bad
		#now have a0 with start, a1 with end+1, a2 with length
		sd a1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, create_gone_bad
		#write out a word with the variable name that will return the address
		#get the address we'll return
		mv a1, a2
		li a5, 0x11				#17 for a created word
		call utility_write_function_header
		la a3, dataspaceptr
		ld a1, 0(a3)
		la a2, NEXT
		call utility_constant_code
		#now check if we are 8 bit aligned on writing address
		li t0, 7
		li t2, 8
		and t1, a0, t0
		beqz t1, create_done
		sub t3, t2, t1
		add a0, a0, t3
  create_done:
		la t4, createwritepoint
		sd a0, 0(t4)
		la t0, CREATEFLAG
		ld t1, 0(t0)
		bnez t1, create_leave
		#'naked' CREATE so update dictionary
		la t0, dictionary
		la t1, newdictionary
		ld t2, 0(t1)
		sd t2, 0(t0)
		sd a0, 0(t1)
 create_leave:
		sd a0, 0(t4)
		tail NEXT
		
  create_gone_bad:
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

		CODEHEADER ALLOT, CREATE, 0x01
		la t2, dataspaceptr
		ld t3, 0(t2)
		ld t4, 0(sp)
		addi sp, sp, 8
		add t5, t3, t4
		sd t5, 0(t2)
		tail NEXT

		CODEHEADER ALIGN, ALLOT, 0x01
		#ensure dataspace pointer is aligned
		la t0, dataspaceptr
		ld t1, 0(t0)
		li t2, 0x07
		and t3, t1, t2
		beqz t3, align_finished
		li t4, 0x08
		sub t5, t4, t3
		add t6, t5, t1
		sd t6, 0(t0)
  align_finished:
		tail NEXT

		CODEHEADER ALIGNED, ALIGN, 0x01
		#return the first aligned address greater or equal to TOS
		ld a0, 0(sp)
		li t0, 0x07
		and t1, a0, t0
		beqz t1, aligned_store
		li t2, 0x08
		sub t3, t2, t1
		add a0, a0, t3
  aligned_store:
		sd a0, 0(sp)
		tail NEXT

		CODEHEADER HERE, ALIGNED, 0x01
		#return the dataspaceptr
		la t0, dataspaceptr
		ld a0, 0(t0)
		PUSH a0
		tail NEXT
		

		CODEHEADER FREE, HERE, 0x01
		#return a block to the free pool
		ld a0, 0(sp)
		call free_memory_allocation
		sd a0, 0(sp)
		tail NEXT

		CODEHEADER RESIZE, FREE, 0x01
		ld a0, 0(sp)
		ld a1, 8(sp)
		call resize_memory_allocation
		sd a1, 8(sp)
		sd a0, 0(sp)
		tail NEXT
		
		CODEHEADER ALLOCATE, RESIZE, 0x01
		#get memory from the allocator
		ld t0, 0(sp)
		call get_memory_allocation
		addi sp, sp, -8
		sd a0, 8(sp)
		sd a1, 0(sp)
		tail NEXT
	
