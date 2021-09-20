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

		CODEHEADER COMMA, CELLS, 0x01
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

		CODEHEADER CCOMMA, COMMA
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

		CODEHEADER CREATE, CCOMMA, 0x01
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
		#check alignment
		li t0, 0x07
		li t2, 0x08
		and t1, a1, t0
		beqz t1, create_advance_alloc
		sub t3, t2, t1
		add a1, a1, t3
  create_advance_alloc:
		call utility_write_number_to_stack
		#and get out
		la a1, NEXT
		call utility_write_out_call_function
		#now check if we are 8 bit aligned on writing address
		and t1, a0, t0
		beqz t1, create_done
		sub t3, t2, t1
		add a0, a0, t3
  create_done:
		la t4, alternativewritepoint
		sd a0, 0(t4)
		la t0, newdictionary
		la t1, dictionary
		ld t2, 0(t0)
		sd t2, 0(t1)
		sd a0, 0(t0)				#update address we will writenext word to
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
	
