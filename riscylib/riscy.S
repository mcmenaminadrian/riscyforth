.include "riscyvar.S"
.include "../macros.S"


.section .bss
   .comm INPUT_BUFFER, BUFFERLEN
   .comm EXPANDED_BUFFER, BUFFERLEN
   .comm createwritepoint, ADDRWIDTH
   .comm newdictionary, ADDRWIDTH
   .comm dictionary, ADDRWIDTH
   .comm INPUT_START, ADDRWIDTH
   .comm INPUT_END, ADDRWIDTH
   .comm INPUT_DISPLACE, ADDRWIDTH
   .comm TOKEN_START, ADDRWIDTH
   .comm TOKEN_END, ADDRWIDTH
   .comm LOADINGFILE, ADDRWIDTH
   .comm FILEMEMORYADDR, ADDRWIDTH
   .comm LOADLINESETUP, ADDRWIDTH
   .comm INFILELOAD, ADDRWIDTH
   .comm MULTILINE, ADDRWIDTH
   .comm PULLINANOTHER, ADDRWIDTH
   .comm SCRATCH_PAD, SYSTEMAREA
   .comm CURRENT_BASE, ADDRWIDTH
   .comm CREATEFLAG, ADDRWIDTH
   .comm outerLoopTokenizeAddress, ADDRWIDTH
   .comm dataspaceptr, ADDRWIDTH
   .comm FP_AVAILABLE, ADDRWIDTH

.section .text

  #a0 holds start of name
  #a1 holds length of name
  #a5 holds value of header
  #a0 returns write point
  .globl lib_write_function_header
  lib_write_function_header:
			addi sp, sp, -56
			sd ra, 0(sp)
			sd s0, 8(sp)
			sd s1, 16(sp)
			sd s2, 24(sp)
			sd s3, 32(sp)
			sd s4, 40(sp)
			sd s5, 48(sp)
			la s1, newdictionary
			ld s3, 0(s1)
			mv s2, a5
			sd s2, 0(s3)				#flag
			addi s2, s3, 0x38			#word address of new word
			sd s2, 8(s3)
			la s0, dictionary
			ld s1, 0(s0)
			sd s1, 16(s3)				#words address of previous word
			sd a1, 24(s3)				#length
			li s2, 0XFFFFFFFFFFFFFFFF		#now fill in name space
			sd s2, 32(s3)
			sd s2, 40(s3)
			sd s2, 48(s3)
			addi s4, s3, 32
  lib_write_header_write_out_name:
			lbu s5, 0(a0)
			sb s5, 0(s4)
			addi a1, a1, -1
			beqz a1, lib_write_header_name_written
			addi a0, a0, 1
			addi s4, s4, 1
			j lib_write_header_write_out_name
  lib_write_header_name_written:
			add a0, s3, 56
			ld ra, 0(sp)
			ld s0, 8(sp)
			ld s1, 16(sp)
			ld s2, 24(sp)
			ld s3, 32(sp)
			ld s4, 40(sp)
			ld s5, 48(sp)
			addi sp, sp, 56
			fence.i
			ret
  #a0 has start
  #a1 has end
  .global lib_sanitize_string
  lib_sanitize_string:
			addi sp, sp, -40
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			li s0, 0x61		#a
			li s1, 0x7B		#z + 1
			li s4, 0x20		#for XOR
			mv s2, a0
  lib_sanitize_test:
			lbu s3, 0(s2)
			blt s3, s0, lib_sanitize_advance
			blt s3, s1, lib_sanitize_process
  lib_sanitize_advance:
			addi s2, s2, 1
			bgt s2, a1, lib_sanitize_done
			j lib_sanitize_test
  lib_sanitize_process:
			xor s3, s3, s4
			sb s3, 0(s2)
			j lib_sanitize_advance
  lib_sanitize_done:
			ld s4, 32(sp)
			ld s3, 24(sp)
			ld s2, 16(sp)
			ld s1, 8(sp)
			ld s0, 0(sp)
			addi sp, sp, 40
			ret

  #INPUT:
  #a0 has start
  #a1 has end (ignored)
  #a2 has length
  #OUTPUT:
  #a0 1 on success, 0 on failure
  #a1 type
  #a2 address	
  .global lib_check_dictionary
  lib_check_dictionary:
			addi sp, sp, -64
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			sd s5, 40(sp)
			sd s6, 48(sp)
			sd s7, 56(sp)
			mv s7, a0
			li a0, 0
			li s0, 24	#MAXNAMELEN
			bgt a2, s0, lib_check_dictionary_bail
			la s0, dictionary
			ld s1, 0(s0)
  lib_check_dictionary_length_match:
			mv s4, s7
			ld s2, 24(s1)
			bne s2, a2, lib_check_dictionary_get_next
			addi s3, s1, 32	#s3 points to word in dictionary
			mv s0, a2
  lib_check_dictionary_loop_word:
			lb s5, 0(s3)	#dictionary letter
			lb s6, 0(s4)
			bne s5, s6, lib_check_dictionary_get_next
			addi s0, s0, -1
			beqz s0, lib_check_dictionary_got_match
			addi s3, s3, 1
			addi s4, s4, 1
			j lib_check_dictionary_loop_word
  lib_check_dictionary_get_next:
			ld s1, 16(s1)
			bnez s1, lib_check_dictionary_length_match
			j lib_check_dictionary_bail
  lib_check_dictionary_got_match:
			li a0, 1
			ld a1, 0(s1)
			mv a2, s1
  lib_check_dictionary_bail:
			ld s7, 56(sp)
			ld s6, 48(sp)
			ld s5, 40(sp)
			ld s4, 32(sp)
			ld s3, 24(sp)
			ld s2, 16(sp)
			ld s1, 8(sp)
			ld s0, 0(sp)
			addi sp, sp, 64
			ret

  .global scan_floats
  scan_floats:
			#on input:
			#a0 points to start of string
			#on output:
			#a0 holds FP
			#a1 0 on success
			#can we interpret the string as FP?
			#must have digit and at least one of E or .
			mv t0, a0
			li a0, 0x30	#0
			li a1, 0x39	#9
			li a2, 0x45	#E
			li a3, 0x2E	#.
			mv a4, zero	#count of matches
			li a5, 0x20	#space
			li a6, 0x0A	#CR
			li a7, 0x2B	#+
			li t6, 0x2d	#-
			mv t1, t0
			mv t3, zero	#count length
			mv t4, zero	#don't keep counting numbers
  scan_float_scan:
			lbu t5, 0(t1)
			bne t5, a2, scan_float_notE
			#cannot start with an E
			beqz t3, scan_float_done_out
			addi a4, a4, 1
			addi t3, t3, 1
			j scan_float_next
  scan_float_notE:
			bne t5, a3, scan_float_notDot
			addi a4, a4, 1
			j scan_float_next
  scan_float_notDot:
			beq t5, a5, scan_float_done
			beq t5, a6, scan_float_done
			beq t5, a7, scan_float_continue
			beq t5, t6, scan_float_continue
			blt t5, a0, scan_float_done_out
			bgt t5, a1, scan_float_done_out
  scan_float_continue:
			addi t3, t3, 1
			bnez t4, scan_float_next
			addi a4, a4, 1
			addi t4, t4, 1
  scan_float_next:
			addi t1, t1, 1
			j scan_float_scan
  scan_float_done:
			li t4, 2	#min
			li t5, 3	#max
			blt a4, t4, scan_float_done_out
			bgt a4, t5, scan_float_done_out
			j process_float	#have a real one
  scan_float_done_out:
			li a1, 1
			ret
  process_float:
			mv t1, t0
			#first of all - check the sign
			addi s9, s9, -32	#store on return stack
			sd zero, 0(s9)		#ensure exponent default is zero
			li t6, 0x2D		#negative sign
			lb t5, 0(t1)
			beq t5, t6, process_float_negative
			sd zero, 24(s9)
			j process_float_check_mantissa
  process_float_negative:
			li t6, 1
			sd t6, 24(s9)
			addi t1, t1, 1
			addi t3, t3, -1
  process_float_check_mantissa:
			li t4, 0	#count of numbers to right of DP
			li t6, 0	#number
			li a4, 10	#for multiplying
			li a7, 0	#found dot
  process_float_calculate_mantissa:
			lb t5, 0(t1)
			beq t5, a3, process_float_check_mantissa_dot
			beq t5, a2, process_float_check_mantissa_e
			beq t5, a5, process_float_check_mantissa_done
			beq t5, a6, process_float_check_mantissa_done
			sub t5, t5, a0
			mul t6, t6, a4
			beqz a7, process_float_check_bigger
			addi t4, t4, 1
			j process_float_check_addin
  process_float_check_bigger:
			bnez t6, process_float_process_bigger
			#not yet broken zero
			beqz t5, process_float_process_on
  process_float_process_bigger:
			#get here because we've got a mantissa >= 1
  process_float_check_addin:
			add t6, t6, t5
  process_float_process_on:
			addi t1, t1, 1
			addi t3, t3, -1
			j process_float_calculate_mantissa
  process_float_check_mantissa_dot:
			li a7, 1
			j process_float_process_on
  process_float_check_mantissa_e:
			#store mantissa and correction count
			#and check exponent
			sd t6, 16(s9)
			sd t4, 8(s9)
			j process_float_search_exponent
  process_float_check_mantissa_done:
			#store mantissa and correction count
			sd t6, 16(s9)
			sd t4, 8(s9)
			j process_float_transfer_to_stack
  process_float_search_exponent:
			li t6, 0	#count of exponent
			PUSH ra
			addi a0, t1, 1	#start of string
			mv a1, t3
			call sumstring
			li a1, -1
			beq a0, a1, process_float_exponent_fail
			mv t6, a0
  process_float_save_exponent:
			sd t6, 0(s9)
  process_float_transfer_to_stack:
			#TODO: Implement this - place number on stack
			#process exponent
			ld a0, 0(s9)
			call process_index
			#process mantissa
			ld t0, 16(s9)	#number
			ld t1, 8(s9)	#offset
			mv a0, t0
			call process_mantissa	
			addi s9, s9, 32
			li a1, 1		#TODO: return 0 when code works
			POP ra
			ret
  process_float_exponent_fail:
			POP ra
			addi s9, s9, 32
			li a1, 1
			ret

 mantissa_division:
	#input a1 has mantissa
	#input a2 has current scaling
	#output a3 has divided number
	#output a4 has new scaling
			ret	

 sumstring:
	#input
	#a0 has start of string
	#a1 has length
	#output a0 - exponent
			addi sp, sp, -48
			sd s1, 0(sp)
			sd s2, 8(sp)
			sd s3, 16(sp)
			sd s4, 24(sp)
			sd s5, 32(sp)
			sd s6, 40(sp)
			li s1, 0x0A	#10
			li s2, 0x30	#0
			li s3, 0x39	#9
			#test for sign
			li s4, 0x2B	#+
			li s5, 0x2D	#-
			lbu s6, 0(a0)
			beq s6, s5, sumstring_negative
			bne s6, s4, sumstring_positive
			addi a0, a0, 1
			addi a1, a1, -1
			j sumstring_positive
  sumstring_negative:
			li s6, 0
			addi a0, a0, 1
			addi a1, a1, -1
			li s5, -1
			j sumstring_read
  sumstring_positive:
			li s6, 0
			li s5, 1
  sumstring_read:
			lbu s4, 0(a0)
			blt s4, s2, sumstring_fail
			bgt s4, s3, sumstring_fail
			sub s4, s4, s2
			mul s6, s6, s1
			add s6, s6, s4
			addi a1, a1, -1
			beqz a1, sumstring_done
			addi a0, a0, 1
			j sumstring_read
  sumstring_done:
			mv a0, s6
			mul a0, a0, s5
  sumstring_return:
			ld s6, 40(sp)
			ld s5, 32(sp)
			ld s4, 24(sp)
			ld s3, 16(sp)
			ld s2, 8(sp)
			ld s1, 0(sp)
			addi sp, sp, 48
			ret
  sumstring_fail:
			li a0, -1
			j sumstring_return


  process_mantissa:
	#INPUT  a0 - fractional number to be processed 
	#OUTPUT a0 - processed number
	#	a1 - bit count in output
			bnez a0, process_mantissa_continue
			ret					#just return 0
  process_mantissa_continue:
			addi sp, sp, -64
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			sd s5, 40(sp)
			sd s6, 48(sp)
			sd s7, 56(sp)
			mv s0, a0
			li s1, 10
			li s2, 10
			li s3, 1
  process_mantissa_test_scale:
			#find position of max 1
			div s0, s0, s1
			beqz s0, process_mantissa_found_scale
			mul s1, s1, s2
			addi s3, s3, 1
			j process_mantissa_test_scale
  process_mantissa_found_scale:
			#s3 holds power of 10
			#s1 has scale
			mv s0, a0
			li s7, 1	#to OR in
			li s2, 63	#max bits
			li s4, 0	#answer
			li s5, 0	#count of bits
  process_mantissa_multiply:
			slli s0, s0, 1	#multiply by 2
			div s6, s0, s1
			slli s4, s4, 1
			addi s5, s5, 1
			beqz s6, process_mantissa_div_zero
			or s4, s4, s7
			bgt s5, s2, process_mantissa_done
			remu s0, s0, s1
			beqz s0, process_mantissa_done
			j process_mantissa_multiply
  process_mantissa_div_zero:
			bgt s5, s2, process_mantissa_done
			j process_mantissa_multiply
  process_mantissa_done:
			mv a0, s4
			li a1, 64
			sub a1, a1, s5
			sll a0, a0, a1	
			mv a1, s5
			ld s0, 0(sp)
			ld s1, 8(sp)
			ld s2, 16(sp)
			ld s3, 24(sp)
			ld s4, 32(sp)
			ld s5, 40(sp)
			ld s6, 48(sp)
			ld s7, 56(sp)
			addi sp, sp, 64
			ret

  process_index:
	#INPUT: 	a0	index - base 10
	#OUTPUT:	a0	index - base 2
	#		a1	to add to mantissa
			bnez a0, process_index_continue
			ret
  process_index_continue:
			#handle transformation of a0
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			blt a0, zero, process_index_negative_continue
			#multiply number out - handle simple case of 1
			li t1, 1
			li s0, 10
			bne a0, t1, process_index_standard
			li s1, 3	#1010b - highest index is three
			j process_index_calc_comp
  process_index_standard:
			mv s2, a0
			addi s2, s2, -1
			li t0, 10	#invariant
  process_index_not1:
			mulh s3, s0, t0
			addi s2, s2, -1
			beqz s3, process_index_bitcount
			#handle overflow here
  process_index_bitcount:
			mul s0, s0, t0
			li t1, 0x80000000000000
			li t2, 63
  process_index_bitcount_check:
			and t3, s0, t1
			bnez t3, process_index_bitcount_found
			srli t1, t1, 1
			addi t2, t2, -1
			bltz t2, process_index_error
			j process_index_bitcount_check
  process_index_bitcount_found:
			mv s1, t2
			bnez s2, process_index_not1
  process_index_calc_comp:
			#get here with s0 as number - but do not need to divide as
			#s1 has bitcount - needed if > 63
			#but have to return a0 and a1
			mv a0, s1
			li s2, 1
			mv a1, s1
			li a2, 63
			ble a1, a2, process_index_bitcount_adjusted
			li a1, 63
 process_index_bitcount_adjusted:
			sll s2, s2, a1
			xor a1, s0, s2
 process_index_error:			#TODO: fix label	
			ld s0, 0(sp)
			ld s1, 8(sp)
			ld s2, 16(sp)
			ld s3, 24(sp)
			addi sp, sp, 40
			ret
  process_index_negative_continue:
			#handle negative index
			neg a0, a0	#reverse index
			mv s0, a0
			li s1, 0
			li t0, 10	#invariant
			li t1, 1
			
  process_index_negative_look:
			div s2, t1, t0
			beqz s2, process_index_negative_shift
			#have hit first number
			li s3, 0x8000000000000000
			j process_index_negative_fill
  process_index_negative_shift:
			slli t1, t1, 1
			j process_index_negative_look
  process_index_negative_fill:
			li t2, 62
			sub t1, t1, t0
			
			
			
			
		
			
			
			
				
						
