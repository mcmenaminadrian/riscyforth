# riscyforth is licenced under GPL v2
# copyright, Adrian McMenamin, 2021
# search-create - search for word addresses when we are in create mode


  search_create_continue:
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                la t4, dictionary
                lw t3, 0(t4)
  search_create_next_in_dictionary:
                lb t4, 12(t3)
                bne t4, t2, search_create_tokens_do_not_match
                add a0, t3, 16                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone 

  search_create_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_create_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, search_create_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_create_loop_through_token

  search_create_tokens_do_not_match:
                lw t3, 8(t3)                          #read the pointer to the next TIL command
                beq t3, zero, search_create_exhausted        #at the end of the dictionary
                j search_create_next_in_dictionary

  search_create_tokens_matched:
                addi t3, t3, 4                        #address that points to the code
		#now check it is allowed
		la t0, WA_COLON			      #cannot nest definitions
		bne t3, t0, search_create_allowed
		tail search_failed		      #report error
  search_create_allowed:
		la t0, createwritepoint
		lw t1, 0(t0)
		sw t3, 0(t1)			      #write out word address in definition
		addi t1, t1, 4
		sw t1, 0(t0)
		la t0, WA_SEMI			      #are we finished with create?
		bne t3, t0, search_create_leave_normal
		#tidy up create as we are done
		la t0, CREATEFLAG
		sw zero, 0(t0)			      #back to immediate execution
		li t0, 0x07
		and t0, t0, t1
		beq t0, zero, search_create_address_aligned_ok #already aligned
		addi t1, t1, 0x08
		li t0, 0xFFFFFFF8
		and t1, t1, t0			      #ensure alignment
  search_create_address_aligned_ok:
		la t0, newdictionary
		la t2, dictionary
		lw t3, 0(t0)			      #load address of new word
		sw t3, 0(t2)			      #store address of new word as start for dictionary
		sw t1, 0(t0)			      #update address we will writenext word to
		j search_create_leave
  search_create_leave_normal:
		PUSH t1
  search_create_leave:
		la s7, outer_loop_tokenize
                tail NEXT

  search_create_exhausted:
		tail search_failed
		
