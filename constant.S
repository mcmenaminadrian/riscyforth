#riscyforth is copyright (c) Adrian McMenamin, 2021
#code is licenced for resuse under the terms of version 2 of the GNU GPL

		CODEHEADER TO, VARIABLE, 0x01
		#get the word
		#does it exist and is it a constant
		ld a1, INPUT_END
		ld a0, INPUT_START
		addi t0, a0, 1
		bltu t0, a1, value_have_data
		tail NEXT				#nothing to parse
  value_have_data:
		call utility_find_string
		beqz a0, constant_gone_bad
		#now have a0 with start, a1 with end + 1, a2 with length
		sd a1, INPUT_START, t5			#update read in pointa
  _to_join:
		call utility_sanitize_string
		#now check this exists
		call utility_check_dictionary_match
		beqz a3, constant_gone_bad		#in this case we need a match
		ld t0, 0(a4)
		li t1, 0x04
		bne t0, t1, constant_gone_bad
		#now over-write code
		ld a0, 8(a4)
		mv a1, t6
		call utility_write_number_to_stack
		tail NEXT

		CODEHEADER CSET, TO, 0x01
		#(mask adr --)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		lbu t2, 0(t0)
		li t3, 0xFF
		and t1, t1, t3
		or t2, t1, t2
		sb t2, 0(t0)
		tail NEXT

		CODEHEADER CRESET, CSET, 0x01
		#(mask adr --)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		not t1, t1
		li t3, 0xFF
		and t1, t1, t3
		lbu t2, 0(t0)
		and t2, t2, t1
		sb t2, 0(t0)
		tail NEXT

		CODEHEADER CTOGGLE, CRESET, 0x01
		#(mask addr --)
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 16
		lbu t2, 0(t0)
		li t3, 0xFF
		and t1, t1, t3
		xor t2, t1, t2
		sb t2, 0(t0)
		tail NEXT

		CODEHEADER _TO, CTOGGLE, 0x0
		ld t6, 0(sp)
		addi sp, sp, 8
		#we are compiled into a word
		#so we pull the token
		mv a0, s7
		lb a2, 0(a0)
		addi a0, a0, 8
		add a1, a0, a2
		#update s7 to stay aligned
		li t0, 7
		li t1, 8
		and t2, t0, a2
		sub t3, t1, t2
		mv s7, a1
		add s7, s7, t3
		call _to_join	
		

		CODEHEADER VALUE, _TO, 0x01
		#exactly as constant except for header
		#TO then overwrites code
		li a5, 0x04				#4 for a value
		j constant_common_code


		CODEHEADER CONSTANT, VALUE, 0x01
		li a5, 0x02				#2 for a constant
  constant_common_code:
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
		#now have a0 with start, a1 with end + 1, a2 with length
		sd a1, INPUT_START, t5			#update read in point
		call utility_sanitize_string		
		#now check this is not a keyword or a number
		call utility_check_dictionary_match
		bnez a3, constant_gone_bad
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
