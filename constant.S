		CODEHEADER CONSTANT, VARIABLE, 0x01
		ld t6, 0(sp)
		addi sp, sp, 8
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, constant_have_data
		tail NEXT				#nothing to parse
  constant_have_data:
		call utility_find_string
		beqz a0, constant_gone_bad
		#now have a0 with start, a1 with end, a2 with length
		mv t0, a1
		add t0, t0, 1
		sd t1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
  constant_finished_sanitization:
		la t4, INPUT_START
		addi t5, a1, 1
		sd t5, 0(t4)
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, constant_gone_bad
  constant_create_name:
		#write out a word with the constant name that will return the constant
		mv a1, a2
		call utility_write_function_header
		mv a1, t6				#fetch constant
		call utility_write_number_to_stack
		#and get out
		la a1, NEXT
		call utility_write_out_call_function
		#now check if we are 8 bit aligned on writing address
		li t0, 0x07
		li t2, 0x08
		and t1, a0, t0
		beqz t1, constant_done
		sub t3, t2, t1
		add a0, a0, t3
  constant_done:
		la t4, createwritepoint
		sd a0, 0(t4)
		la t0, newdictionary
		la t1, dictionary
		ld t2, 0(t0)
		sd t2, 0(t1)
		sd a0, 0(t0)			      #update address we will writenext word to
		fence.i
		tail NEXT			      #and out
constant_gone_bad:
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
