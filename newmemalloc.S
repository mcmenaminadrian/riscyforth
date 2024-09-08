# SIZE | Ptr to next Size | Ptr to used blocks | Ptr to free blocks |

.equ MEM_PAGE_COUNT,  64				# how many pages per allocation
.equ PAGE_SIZE, 0x1000

.macro STACK_UP
	addi sp, sp, -104
	sd ra, 0(sp)
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
.endm

.macro STACK_DOWN
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
	ld ra, 0(sp)
	addi sp, sp, 104
.endm

allocate_memory_pages:				        # allocate pages for read, write, execute
	addi sp, sp, -8
	sd ra, 0(sp)
	li t0, MEM_PAGE_COUNT				# how many pages
	li a1, PAGESIZE
	mul a1, a1, t0
	li a2, 0x07					# read, write, execute
	li a3, 0x22
	li a4, -1
	li a5, 0
	call mmap
	ld ra, 0(sp)
	addi sp, sp, 8
	beqz a0, memory_fail
	ret


memory_fail:
	STACK_DOWN
	tail BYE

initialize_memoryspace:
	STACK_UP
	mv a0, zero
	li a1, DATASPACEMAN			# size of allocated memory
	li a2, 0x03				# read and write
	li a3, 0x22
	li a4, -1
	li a5, 0
	call mmap				# map in memory
	li a4, -1
	beq a4, a0, memory_fail			# a0 points to allocated memory
	# setup the list
	la t0, datamanagement
	sd a0, 0(t0)				# datamanagement points to allocated memory
	li t1, DATASPACEMAN
	mv t0, a0
	add t1, t0, t1				# t1 points to first byte after allocated memory
zero_out_allocation:				# ensure everything starts as null pointers
	sd zero, 0(t0)
	addi t0, t0, 8
	blt t0, t1, zero_out_allocation
allocate_memory_blocks:
	la s9, datamanagement			# now write out tables and allocate memory
	ld s9, 0(s9)				# s9 pointer to start of chain info block
	li s1, PAGE_SIZE				# s1 holds page size
	li s4, MEM_PAGE_COUNT
	mul s4, s1, s4				# s4 holds size to be allocated
	li s2, 16				# start with 16 bytes - s2 holds current write size
allocate_big_loop:
	bgt s2, s1, allocate_memory_blocks_done
	call allocate_memory_pages		# returns with a0 pointing to allocated memory
	add s5, a0, s4				# s5 holds end address
	mv s3, s9				# s3 holds start of chain block
	sd s2, 0(s3)				# write out size
	addi t0, s3, 32				# address of the start of the chains
	sd t0, 16(s3)				# pointer to free chain
	addi t0, t0, 16				# free chain is just two nulls now - so beyond that
	sd t0, 24(s3)				# store address pointer to start of free chain
	mv t1, a0				# t1 holds start of allocated memory
allocate_small_loop:
	sd t1, 0(t0)				# write out pointer into memory
	add t2, t1, s2				
	bge t2, s5, ready_for_next_big_loop	# end of chain?
	addi t1, t0, 16				# start of next ptr pair
	sd t1, 8(t0)
	mv t0, t1				# update write address
	mv t1, t2				# update pointer address
	j allocate_small_loop
ready_for_next_big_loop:
	slli s2, s2, 1				# increase block size by power of two
	addi t0, t0, 16
	sd t0, 8(s9)				# write address of next block into old block header
	mv s9, t0
	j allocate_big_loop
allocate_memory_blocks_done:
	STACK_DOWN
	ret

find_block_memory_allocator:			# call with a0 holding address
	bgt a0, zero, execute_find_block_memory_allocator
	mv a0, zero				# cannot find zero
	ret
execute_find_block_memory_allocator:
	STACK_UP
	la s9, datamanagement			# s9 points to address holding memory management
	ld s9, 0(s9)				# s9 now points to memory management
	addi s9, s9, 8				# we don't care about the size for now
find_start_chain_search:
	mv s4, zero				# no previous tuple
	ld s1, 0(s9)				# s1 points to start of next chain
	beqz s1, find_no_match			# reached the end and there is no match
	ld s2, 8(s9)				# we only search the used chain - here held in s2
	ld t0, 0(s2)				# are any blocks allocated to this chain?
find_loop_through_chain:
	beqz t0, find_move_to_next_chain	# no allocated blocks for this chain
	mv s3, s2				# s3 now points to pair
	ld t1, 0(s3)
	beq t1, a0, find_matched_chain		# have a match
	ld s2, 8(s3)				# next tuple
	ld t0, 0(s2)				# read value
	mv s4, s3				# store previous tuple so we can update chain if needed
	j find_loop_through_chain
find_move_to_next_chain:
	mv s9, s1				# move on to the next chain
	addi s9, s9, 8
	j find_start_chain_search		# jump to the start of the search through the chain
find_no_match:
	mv a0, zero
	STACK_DOWN
	ret
find_matched_chain:				# returns a0 - 1, a1 - start of chain, a2 - pointer to tuple, a3, pointer to previous
	li a0, 1				# found
	mv a1, s9
	addi a1, a1, 8				# start of chain
	mv a2, s3				# address, sought tuple
	mv a3, s4				# address, previous tuple
	STACK_DOWN
	ret


# returns in a0
allocate_memory_allocator:			# call with a0 holding the size sought
	bgt a0, zero, execute_memory_allocator
	mv a0, zero				# don't allocate zero space
	li a1, -1
	ret					# return an error
execute_memory_allocator:
	STACK_UP
	la s9, datamanagement			# s9 holds address with pointer to start
	ld s9, 0(s9)				# s9 now points to start of chain records
allocator_check_size:
	ld t0, 0(s9)				# load size
	bge t0, a0, allocator_found_memory_size # size matches
	ld s9, 8(s9)				# next chain record
	beqz s9, allocator_big_allocator	# reached end of block
	j allocator_check_size
allocator_found_memory_size:
	ld t0, 24(s9)				# get pointer to first tuple in free chain
	beqz t0, allocator_big_allocator	# run out of memory so take it from the heap
allocator_not_end_of_chain:
	ld t1, 0(t0)
	ld s1, 8(t0)				# pointer to next in chain
	sd s1, 24(s9)				# update free chain
	ld s2, 16(s9)
	sd t0, 16(s9)				# update used chain
	sd s2, 8(t0)				# update used chain next pointer
	ld a0, 0(t0)				# address to return
	mv a1, zero
	STACK_DOWN
	ret
allocator_big_allocator:
	call malloc
	STACK_DOWN
	mv a1, zero
	ret

free_memory_allocator:				# call with a0 holding the address to be freed
	bgt a0, zero, execute_memory_free
	li a0, 0				# won't free a null pointer
	ret
execute_memory_free:
	STACK_UP
	addi sp, sp, -8
	sd a0, 0(sp)				# store address we are after
	call find_block_memory_allocator	# look for the block
	beqz a0, free_try_raw_free		# did not find - so just call free
	addi sp, sp, 8				# restore stack
	ld s9, 8(a2)				# s9 holds next in used chain
	beqz a3, free_at_chain_head		# if we are at top of the chain fix initial pointer only
	sd s9, 8(a3)				# update previous tuple
	j free_update_free_chain
free_at_chain_head:
	sd s9, 0(a1)				# update head of chain
free_update_free_chain:
	ld s1, 8(a1)				# get head of free chain
	sd a2, 8(a1)				# replace with freed tuple
	sd s1, 8(a2)				# update the pointer for the freed block
	STACK_DOWN
	li a0, 0				# success
	ret
free_try_raw_free:
	ld a0, 0(sp)
	addi sp, sp, 8
	call free
	STACK_DOWN
	li a0, 0
	ret
	
memory_get_block_size:				# a0 has size on input
	addi a0, a0, -1				# enforce counting up from zero
	li t0, 0
memory_count_blocks_loop:
	addi t0, t0, 1
	srli a0, a0, 1
	bnez a0, memory_count_blocks_loop
	li a0, 1
	mv a3, a0				# save if needed
	sll a0, a0, t0				# convert to size in power of 2
	ret

#places results on the stack
resize_memory_allocator:
	ld a1, 0(sp)				# a1 has size we seek
	ld a0, 8(sp)				# a0 has address of old block
	addi sp, sp, 16
	bnez a1, resize_non_zero		# not resizing to zero
	addi sp, sp, -8
	sd ra, 0(sp)
	call free_memory_allocator		# resizing to zero so just a free
	ld ra, 0(sp)
	addi sp, sp, -8
	sd zero, 8(sp)				# return 0 0 as freed
	sd a0, 0(sp)				
	ret
resize_non_zero:
	STACK_UP
	addi sp, sp, -16
	sd a1, 0(sp)				# size we seek stored on stack
	sd a0, 8(sp)				# address of old block stored on stack
	call find_block_memory_allocator	# look for block
	# have we found a block
	bnez a0, resize_check_size
	# we haven't - so we need to allocate from the heap
	ld a0, 0(sp)
	mv s4, a0
	call malloc
	bnez a0, resize_copy_data
resize_failed:
	ld a0, 8(sp)				# get back original address
	addi sp, sp, 16
	STACK_DOWN
	addi sp, sp, -16
	sd a0, 8(sp)				# return unchanged address on failure
	li a1, -1		
	sd a1, 0(sp)				# return -1 on failure
	ret
resize_check_size:
	# is it same size
	ld s4, -16(a1)				# load size of found (old) block
	ld a0, 0(sp)				# load size we are seeking
	bgt a0, s4, resize_allocate_new_size	# sizes do not match - allocation required
resize_unwind_on_failure:
	# sizes do match so clean up and go home
	ld a0, 8(sp)
	addi sp, sp, 16
	STACK_DOWN
	addi sp, sp, -16
	sd a0, 8(sp)
	sd zero, 0(sp)
	ret
resize_allocate_new_size:
	# not same size - allocate new block
	mv s5, a0				# store new size
	call allocate_memory_allocator		# get a new memory block
	bnez a1, resize_unwind_on_failure	# alloc failed so return
	# not same size - copy over old data
resize_copy_data:
	ld t0, 8(sp)				# address of old block
	mv t1, a0				# address of new block
	sd a0, 0(sp)				# store new address
resize_copy_byte:
	lb t2, 0(t0)				# byte from old block
	sb t2, 0(t1)				# copy over
	addi s4, s4, -1
	beqz s4, resize_free_old_block
	addi t0, t0, 1
	addi t1, t1, 1
	j resize_copy_byte
resize_free_old_block:
	# not same size - free old block
	ld a0, 8(sp)
	call free_memory_allocator
	bnez a0, resize_unwind_on_failure
	ld a0, 0(sp)
	addi sp, sp, 16
	STACK_DOWN
	addi sp, sp, -16
	sd a0, 8(sp)
	sd zero, 0(sp)
	ret
	
