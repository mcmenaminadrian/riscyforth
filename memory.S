#########################################################################################################
#Forth words from the optional Memory Allocation set							#
#use our local allocator code rather than just malloc/free to ensure we don't lock up memory		#
#Copyright Adrian McMenamin, 2021									#
#Licenced for reuse under version 2 of the GNU General Public License					#
#########################################################################################################
		CODEHEADER CELLS, LOAD, 0x01
		ld t0, 0(sp)
		slli t0, t0, 3
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER CREATE, CELLS, 0x01
		#read in name
		#create shell in dictionary that returns start address
		#based on COLON code
		#WRITE OUT FLAGS
		#WRITE OUT PTR
		#WRITE OUT PTR

		la t1, newdictionary
		ld t3, 0(t1)
		li t2, 0x01
		sd t2, 0(t3)						#flag
		addi t2, t3, 0x38					#word address of new word (56 bytes offset)
		sd t2, 8(t3)
		la t0, dictionary
		ld t1, 0(t0)
		sd t1, 16(t3)						#words address of previous word
		sd zero, 24(t3)						#zero length
		li t2, 0XFFFFFFFFFFFFFFFF				#now fill in name space
		sd t2, 32(t3)
		sd t2, 40(t3)
		sd t2, 48(t3)
		#now read in the name
		PUSH t3		

                ld a1, INPUT_END
                ld a0, INPUT_START
                addi t0, a0, 1                        			#account for minimal input
                bltu t0, a1, create_tokenize_have_data   		#buffer has data
  create_tokenize_all_over:
                j colon_fail
  create_tokenize_have_data:
                mv t0, a0                             			#t0 tracks start of token, t1 the end
                li t2, 0x20                   				#t2 space
                li t3, 0x0A                   				#t3 CR
  create_tokenize_look_for_start:
                lb t4, 0(t0)
                beq t4, t2, create_tokenize_keep_going
                bne t4, t3, create_tokenize_found_start
                j create_tokenize_all_over
  create_tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, create_tokenize_look_for_start
                j create_tokenize_all_over                   		#got nothing
  create_tokenize_found_start:
		li t2, 0x30
		li t3, 0x39
		bgt t4, t3, create_not_a_numeral
		bge t4, t2, create_tokenize_all_over	    		#cannot redefine a number
  create_not_a_numeral:
                mv t1, t0                             			#t1 to track end of token
		li t2, 0x20						#back to checking space and CR
		li t3, 0x0A
  create_tokenize_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, create_tokenize_end_token
                lb t4, 0(t1)
                beq t4, t2, create_tokenize_end_token
                beq t4, t3, create_tokenize_end_token
                j create_tokenize_advance_search
  create_tokenize_end_token:
                sd t1, INPUT_START, t5                			#update the end point for subsequent searches
                addi t1, t1, -1                       			# space or NL not part of token
                mv t2, t0
                li t5, 0x61                   				#lowercase a
                li t6, 0x7B                   				#lowercase z + 1
  create_tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, create_tokenize_next_sane
                blt t4, t6, create_tokenize_sanitize
                j create_tokenize_next_sane
  create_tokenize_sanitize:
                li t3, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  create_tokenize_next_sane:
                addi t2, t2, 1
                blt t1, t2, create_tokenize_finished_sanitization
                j create_tokenize_sanity_test
  create_tokenize_finished_sanitization:
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
		POP t3
		sub t4, t1, t0
		addi t4, t4, 1						#add 1 to get length
		sd t4, 24(t3)						#write out length
		addi t1, t3, 32
  create_write_out_name:
		lb t5, 0(t0)
		sb t5, 0(t1)
		addi t4, t4, -1
		beqz t4, create_name_written
		addi t0, t0, 1
		addi t1, t1, 1
		j create_write_out_name
  create_name_written:
		la t0, dataspaceptr
		ld t1, 0(t0)
		mv a0, t1						#copy to a0
		#t1 contains the number we need to push to the stack
		li t2, 0XFF810113
		sw t2, 56(t3)						# addi sp, sp, -8
		#now get what is in t1 in our space into t0 in the written code
		srli t1, t1, 32						#eliminate the lower 32 bits
		slli t1, t1, 20						#in right place for the add
		li t0, 0x293
		or t0, t0, t1
		sw t0, 60(t3)						#addi t0, zero, [upper 32 of NEXT]
		li t0, 0x2029293
		sw t0, 64(t3)						#slli t0, t0, 32
		#now deal with lower 32 bits of address
		mv t1, a0
		li t2, 0xFFFFF000
		and t1, t1, t2						#take upper 20 bits of lower 32
		li t2, 0x337
		or t0, t1, t2
		sw t0, 68(t3)						#lui t1, [bits 12 - 31]
		li t0, 0x2031313
		sw t0, 72(t3)						#slli t1, t1, 0x20
		li t0, 0x2035313
		sw t0, 76(t3)						#srli t1, t1, 0x20 (zero out upper 32 bits)
		mv t1, a0
		li t2, 0xFFF
		and t0, t1, t2						#lower 12 bits only
		srli t1, t0, 11						#t1 has twelveth bit only
		li t2, 0x7FF
		and t0, t0, t2						#t0 has the lower 11 bits
		li t4, 0x393
		slli t1, t1, 20
		or t4, t4, t1
		sw t4, 80(t3)						#addi t2, zero, [0 or 1]
		li t4, 0xB39393
		sw t4, 84(t3)						#slli t2, t2, 11
		li t4, 0x7282B3
		sw t4, 88(t3)						#add t0, t0, t2
		li t4, 0x393
		slli t0, t0, 20
		or t4, t4, t0
		sw t4, 92(t3)						#addi t2, zero, [lower 11 bits]
		li t4, 0x7282B3
		sw t4, 96(t3)						#add t0, t0, t2
		li t4, 0x6282B3
		sw t4, 100(t3)						#add t0, t0, t1
		#now t0 has the number, place it on the stack
		li t4, 0x513023
		sw t4, 104(t3)						#sd t0, 0(sp)
		#now execute equivalent of tail NEXT
		la t1, NEXT						#t1 has the number
		srli t1, t1, 32						#eliminate the lower 32 bits
		slli t1, t1, 20						#in right place for the add
		li t0, 0x293
		or t0, t0, t1
		sw t0, 108(t3)						#addi t0, zero, [upper 32 of NEXT]
		li t0, 0x2029293
		sw t0, 112(t3)						#slli t0, t0, 32
		#now deal with lower 32 bits of NEXT address
		la t1, NEXT
		li t2, 0xFFFFF000
		and t1, t1, t2						#take upper 20 bits of lower 32
		li t2, 0x337
		or t0, t1, t2
		sw t0, 116(t3)						#lui t1, [bits 12 - 31]
		li t0, 0x2031313
		sw t0, 120(t3)						#slli t1, t1, 0x20
		li t0, 0x2035313
		sw t0, 124(t3)						#srli t1, t1, 0x20 (zero out upper 32 bits)
		la t1, NEXT
		li t2, 0xFFF
		and t0, t1, t2						#lower 12 bits only
		srli t1, t0, 11						#t1 has twelveth bit only
		li t2, 0x7FF
		and t0, t0, t2						#t0 has the lower 11 bits
		li t4, 0x393
		slli t1, t1, 20
		or t4, t4, t1
		sw t4, 128(t3)						#addi t2, zero, [0 or 1]
		li t4, 0xB39393
		sw t4, 132(t3)						#slli t2, t2, 11
		li t4, 0x7282B3
		sw t4, 136(t3)						#add t0, t0, t2
		li t4, 0x393
		slli t0, t0, 20
		or t4, t4, t0
		sw t4, 140(t3)						#addi t2, zero, [lower 11 bits]
		li t4, 0x7282B3
		sw t4, 144(t3)						#add t0, t0, t2
		li t4, 0x6282B3
		sw t4, 148(t3)						#add t0, t0, t1
		li t0, 0x28067						#jalr zero, 0(t0)
		sw t0, 152(t3)
		la t1, newdictionary
		ld t1, 0(t1)
		addi t1, t1, CREATEOFFSET
		la t3, createwritepoint
		sd t1, 0(t3)
		la t0, newdictionary
		la t2, dictionary
		ld t3, 0(t0)			      #load address of new word
		sd t3, 0(t2)			      #store address of new word as start for dictionary
		sd t1, 0(t0)			      #update address we will writenext word to
		fence.i
		tail NEXT						#and out

		CODEHEADER ALLOT, CREATE, 0x01
		#get alignment
		#if character (not aligned) just move pointer ahead
		#if aligned ensure alignment is maintained
		la t2, dataspaceptr
		ld t3, 0(t2)
		ld t4, 0(sp)
		addi sp, sp, 8
		add t5, t3, t4
		la t0, alignmentstate
		ld t1, 0(t0)
		bnez t1, allot_aligned
		sd t5, 0(t2)
		tail NEXT
  allot_aligned:
		li a0, 0x07
		and a1, t5, a0
		beqz a1, allot_finished
		li a2, 0x08
		sub a3, a2, a1
		add t5, t5, a3
  allot_finished:
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
	
