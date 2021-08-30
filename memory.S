#########################################################################################################
#Forth words from the optional Memory Allocation set							#
#use our local allocator code rather than just malloc/free to ensure we don't lock up memory		#
#Copyright Adrian McMenamin, 2021									#
#Licenced for reuse under version 2 of the GNU General Public License					#
#########################################################################################################
		CODEHEADER FREE, LOAD, 0x01
		#return a block to the free pool
		ld a0, 0(sp)
		call free_memory_allocation
		sd a0, 0(sp)
		tail NEXT

		
		CODEHEADER ALLOCATE, FREE, 0x01
		#get memory from the allocator
		ld t0, 0(sp)
		slli a0, t0, 3				#convert from cells to bytes
		call get_memory_allocation
		addi sp, sp, -8
		sd a0, 8(sp)
		sd a1, 0(sp)
		tail NEXT

		
