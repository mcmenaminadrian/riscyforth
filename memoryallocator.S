	#each entry:
	# SIZE | ChainPtr | Next Ptr  ---> SIZE....
	#          |
	#      | NextPtr  | Address
	#      |   |
	#      | NextPtr  | Address

	init_used_chain:
		#simple code as everything is empty at this point
		#a0 has the start address
		#a2 the maximum size of the basic chain
		mv t0, a0
		li t1, 8
		mv t2, a2
  init_used_chain_write:
		sd t1, 0(t0)
		sd zero, 8(t0)
		addi t3, t0, 24
		slli t1, t1, 1
		bgt t1, t2, end_init_used_chain
		sd t3, 16(t0)
		mv t0, t3
		j init_used_chain_write
  end_init_used_chain:
		sd zero, 16(t0)
		la t2, recyclewatermark
		addi t3, t0, 24
		sd t3, 0(t2)			#point to start writing
		ret

	init_free_space:
		addi sp, sp, -104
		sd ra, 0(sp)
		sd s0, 8(sp)
		sd s1, 16(sp)
		sd s2, 24(sp)
		sd s3, 32(sp)
		sd s4, 40(sp)
		sd s5, 48(sp)
		sd s6, 56(sp)
		sd s7, 64(sp)
		sd s8, 72(sp)
		sd s9, 80(sp)
		sd s10, 88(sp)
		sd s11, 96(sp)
		#set the recycleallot to NULL
		la s0, recycleallot
		sd zero, 0(s0)
		#a0 has start address of control struct
		#a1 has size we start allocating for
		#a2 has max size we put in free chain	
		#a3 has initial number of pages per chain
		mv s0, a0
		mv s1, a1
		mv s2, a2
		mv s3, a3			#use this locally
		mv s8, s3			#use this as constant
		li s4, PAGESIZE
		mul s5, s3, s4
		#create the head of the chain
  init_start_chain:
		mv s6, s0			#copy head address
		sd s1, 0(s0)
  init_allocate_page:
		mv a0, zero
		mv a1, s5
		li a2, 0x07			#read write and execute
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222
		ecall
		beqz a0, memory_fail
		mv s3, s8
		#have page(s) of memory for this size, now create list for it
		addi s0, s0, 8
		mv s7, s5			#s7 is how many bytes we have left
		addi s8, s0, 16
		sd s8, 0(s0)			#top of the free chain
		mv s0, s8			#now s0 writes to the free chain
  init_continue_free_chain:
		sd a0, 0(s0)			#pointer to memory
		sub s7, s7, s1 
		addi s0, s0, 8
		bnez s7, init_lengthen_chain 
		sd zero, 0(s0)			#end of this chain
		j init_prime_next_chain
  init_lengthen_chain:
		addi s8, s0, 8
		sd s8, 0(s0)
		mv s0, s8
		add a0, a0, s1
		j init_continue_free_chain
  init_prime_next_chain:
		slli s1, s1, 1
		bgt s1, s2, init_chain_is_finished
		addi s0, s0, 8
		sd s0, 16(s6)			#pointer to the next chain
		j init_start_chain
  init_chain_is_finished:
		ld s11, 96(sp)
		ld s10, 88(sp)
		ld s9, 80(sp)
		ld s8, 72(sp)
		ld s7, 64(sp)
		ld s6, 56(sp)
		ld s5, 48(sp)
		ld s4, 40(sp)
		ld s3, 32(sp)
		ld s2, 24(sp)
		ld s1, 16(sp)
		ld s0, 8(sp)
		ld ra, 0(sp)
		addi sp, sp, 104
		ret

		

  memory_fail:
		tail BYE
  initialize_dataspace:
		PUSH ra
		mv a0, zero
		li a1, DATASPACEMAN
		li a2, 0x03			#both read and write
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222
		ecall
		beqz a0, memory_fail
		#setup free list
		la t0, datamanagement 		#this will always be the head of the free list
		sd a0, 0(t0)
		#ensure data management space is zero
		mv t0, a0
		li t1, DATASPACEMAN
		add t1, t0, t1
  zero_out_memmanagement:
		sd zero, 0(t0)
		addi t0, t0, 8
		blt t0, t1, zero_out_memmanagement
		
		la a0, datamanagement
		ld a0, 0(a0)			#start address for free chain
		li a1, 0x08			#first size
		li a2, PAGESIZE			#max size for free chain
		li a3, 1			#objects to be allocated
		call init_free_space
		#now handle the (currently empty) chain of used segments
		mv a0, zero
		li a1, DATASPACEMAN
		li a2, 0x03			#both read and write
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222
		ecall
		beqz a0, memory_fail
		la t0, recycleallot
		sd a0, 0(t0)
		li a2, PAGESIZE
		call init_used_chain
		POP ra
		fence
		ret

  get_memory_allocation:
		addi sp, sp, -104
		sd ra, 0(sp)
		sd s0, 8(sp)
		sd s1, 16(sp)
		sd s2, 24(sp)
		sd s3, 32(sp)
		sd s4, 40(sp)
		sd s5, 48(sp)
		sd s6, 56(sp)
		sd s7, 64(sp)
		sd s8, 72(sp)
		sd s9, 80(sp)
		sd s10, 88(sp)
		sd s11, 96(sp)
		#a0 has size in bytes - always a multiple of 8
		#is a0 > PAGESIZE
		li s0, PAGESIZE
		bgt a0, s0, get_big_allocation
		# check chain
		la s0, datamanagement
		ld s0, 0(s0)			#s0 points to start of the chain
  check_chain_size:
		ld s1, 0(s0)
		mv s9, s1			#s9 has chain size
		bge s1, a0, alloc_found_chain
		addi s0, s0, 16
		ld s0, 0(s0)
		beqz s0, memory_fail		#followed a NULL pointer
		j check_chain_size
		#now have a chain, lets go to the end
  alloc_found_chain:
		#first test the chain is not empty
		addi s0, s0, 8
		ld s1, 0(s0)
		beqz s1, chain_exhausted
		#chain has at least one entry
  alloc_progress_chain:
		#take the top entry in the chain
		ld s3, 8(s1)
		sd s3, 0(s0)
		mv s0, s1
		ld a0, 0(s0)			#a0 now has the pointer
  		#now remove the entry from the chain and add to the used list
		la s4, recycleallot
		ld s4, 0(s4)
  test_used_chain_size:
		ld s5, 0(s4)
		beqz s5, memory_fail		#should never be null
		beq s5, s9, found_used_chain
		addi s6, s4, 16
		ld s4, 0(s6)
		beqz s4, memory_fail		#should never be null
		j test_used_chain_size
  found_used_chain:
		ld s7, 8(s4)
		beqz s7, stick_on_used_chain
		mv s4, s7
		j found_used_chain
  stick_on_used_chain:
		sd s0, 8(s4)
		sd zero, 8(s0)			#start a recyclechain
		j allot_over
  allot_over:
		ld s11, 96(sp)
		ld s10, 88(sp)
		ld s9, 80(sp)
		ld s8, 72(sp)
		ld s7, 64(sp)
		ld s6, 56(sp)
		ld s5, 48(sp)
		ld s4, 40(sp)
		ld s3, 32(sp)
		ld s2, 24(sp)
		ld s1, 16(sp)
		ld s0, 8(sp)
		ld ra, 0(sp)
		addi sp, sp, 104
		mv a1, zero
		ret

  allocation_failed:
		ret
  get_big_allocation:
		#a0 has size
		mv s1, a0
		#malloc the size and add to used chain
		PUSH ra
		call malloc
		POP ra
		beqz a0, allocation_failed
		#now walk used chain looking for size - if it exists
		ld t0, recycleallot
  big_allocation_walk_chain:
		ld t1, 0(t0)
		bgt t1, s1, big_allocation_insert_before
		beq t1, s1, big_allocation_insert_here
		mv t6, t0
		ld t1, 16(t0)
		beqz t1, big_allocation_insert_next
		mv t0, t1
		j big_allocation_walk_chain
  big_allocation_insert_next:
		#insert at high water point
		la t2, recyclewatermark
		ld t2, 0(t2)
		sd t2, 16(t0)
		sd s1, 0(t2)		#size
		addi t3, t2, 24
		sd t3, 8(t2)
		sd zero, 16(t2)
  big_allocation_tidy_insert:
		sd a0, 0(t3)
		sd zero, 8(t3)
		addi t4, t3, 16
		la t0, recyclewatermark
		sd t4, 0(t0)
		li a1, 0
		ret
  big_allocation_insert_before:
		#t6 points to chain point to insert after
		la t0, recyclewatermark
		ld t1, 0(t0)
		ld t2, 16(t6)			#old pointer
		sd s1, 0(t1)			#size
		sd t1, 16(t6)			#add new part of chain
		addi t3, t1, 24			#downward chain
		sd t3, 8(t1)
		sd t2, 16(t1)			#reconnect
		j big_allocation_tidy_insert	#finish up
 big_allocation_insert_here:
		#now insert into the downward chain
		#t0 holds insertion point here
		la t1, recyclewatermark
		ld t2, 0(t1)
		ld t4, 8(t0)
		sd t2, 8(t0)
		sd a0, 0(t2)
		sd t4, 8(t2)
		addi t2, t2, 16			#push the watermark upstream
		la t0, recyclewatermark
		sd t2, 0(t0)
		li a1, 0
		ret
		
		
  chain_exhausted:
		#TODO: FIX ME!
		ret
		
  free_memory_allocation:
		#a0 comes in with the address of the block
		la t0, recycleallot
		ld t0, 0(t0)
  free_memory_allocation_test_chain:
		mv t6, t0		#t6 holds the top
		ld t1, 0(t0)
		beqz t1, free_memory_allocation_failed
		mv t3, t1		#store size
		ld t1, 8(t0)
  free_memory_allocation_walk_chain:
		beqz t1, free_memory_allocation_advance
		ld t2, 0(t1)
		beq t2, a0, free_memory_allocation_found_block
		ld t1, 8(t1)
		j free_memory_allocation_walk_chain
  free_memory_allocation_advance:
		ld t0, 16(t0)
		beqz t0, free_memory_allocation_failed		#end of the line
		j free_memory_allocation_test_chain
  free_memory_allocation_failed:
		li a0, -1
		ret
  free_memory_allocation_found_block:
		#now have to return to the free chain
		#t3 is the chain we are looking for
		mv t2, t1
		#clean the used chain first
		ld t4, 8(t1)
		sd t4, 8(t6)
		#check whether we have big allocation
		li t5, PAGESIZE
		bgt t3, t5, free_big_allocation
		la t0, datamanagement
		ld t0, 0(t0)
  free_walk_free_chain:
		ld t1, 0(t0)
		beqz t1, free_memory_allocation_failed
		beq t1, t3, free_found_free_chain
		ld t0, 16(t0)
		beqz t0, free_memory_allocation_failed
		j free_walk_free_chain
  free_found_free_chain:
		#t0 points to the head of the chain
		#t2 points to the block to be added back
		ld t4, 8(t0)
		sd t2, 8(t0)
		sd t4, 8(t2)
		li a0, 0
		ret
  free_big_allocation:
		PUSH ra
		ld a0, 0(t2)
		call free
		POP ra
		sd zero, 0(t2)
		sd zero, 8(t2)
		la t0, recyclewatermark
		ld t1, 0(t0)
		addi t3, t2, 24
		bne t3, t1, finish_free_big_allocation
		sd t2, 0(t0)			#shrink the watermark
  finish_free_big_allocation:
		li a0, 0
		ret
		
