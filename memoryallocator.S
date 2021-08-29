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

  get_big_allocation:
  chain_exhausted:
		ret
		
		
		
