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
   .comm literalNumberAddress, ADDRWIDTH
   .comm STACKTOP, ADDRWIDTH

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
			li t3, 1				#count length
			li t4, 0				#don't keep counting numbers
			#cannot start with E
			lbu t5, 0(t1)
			beq t5, a2, scan_float_done_out
			j scan_float_notE
  scan_float_scan:
			lbu t5, 0(t1)
			addi t3, t3, 1				#increment count
			bne t5, a2, scan_float_notE
			bnez a4, scan_float_scan_E
			addi a4, a4, 1				#number with E is sufficient for match eg 2E5
  scan_float_scan_E:
			addi a4, a4, 1				#record match with E
			j scan_float_next			#move on
  scan_float_notE:
			bne t5, a3, scan_float_notDot
			addi a4, a4, 1				#record match with dot
			j scan_float_next
  scan_float_notDot:
			beq t5, a5, scan_float_done		#hit space - evaluate
			beq t5, a6, scan_float_done		#hit CR - evaluate
			beq t5, a7, scan_float_continue		#+ sign
			beq t5, t6, scan_float_continue		#- sign
			blt t5, a0, scan_float_done_out		#out or range of number
			bgt t5, a1, scan_float_done_out		#out of range of number
  scan_float_continue:
			bnez t4, scan_float_next		#if already seen a digit move on
			addi a4, a4, 1				#match digit
			addi t4, t4, 1				#ensure we don't keep matching digits
  scan_float_next:
			addi t1, t1, 1				#move on to next part of string
			j scan_float_scan			#loop
  scan_float_done:
			addi t3, t3, -1				#decrement to reflect we've hit the end
			li t4, 2				#min
			li t5, 3				#max
			blt a4, t4, scan_float_done_out
			bgt a4, t5, scan_float_done_out
			j process_float				#have a real one
  scan_float_done_out:
			li a1, 1
			ret

  #code to handle mantissa and index
  process_float:
			#set up stack area on return stack
			PUSH ra
			call float_stack_up
			POP ra
			mv t1, t0					#copy start of buffer address to t1
			#first of all - check the sign
			sd zero, 144(s9)				#zero as default exponent
			lb t5, 0(t1)					#read first char
			addi t3, t3, -1					#decrement number left to read
			beq t5, t6, process_float_negative		#check for - sign
			sd zero, 128(s9)				#positive number - store 0
			beq t5, a7, process_float_positive		#check for + sign
			j process_float_check_mantissa			#jump ahead but no extra read
  process_float_positive:
			addi t1, t1, 1					#increment index to input
			addi t3, t3, -1					#just forget the sign
			j process_float_check_mantissa			#jump ahead
  process_float_negative:
			li t6, 1					#store 1 as...
			addi t1, t1, 1					#increment index to input
			addi t3, t3, -1					#ignore the sign now
			sd t6, 128(s9)					#negative number
  process_float_check_mantissa:
			li s6, 0					#count of found numbers
			li s7, 17					#max number of numbers we can count
			li t4, 0					#count of numbers to right of DP
			sd s0, 64(s9)					#use return stack space
			li s0, 0					#count of numbers to left of DP
			li t6, 0					#number
			li a4, 10					#for multiplying
			li a7, 0					#found dot
  process_float_calculate_mantissa:
			bltz t3, process_float_check_mantissa_done	#already at the end (no exponent)
			lb t5, 0(t1)					#read char
			beq t5, a3, process_float_check_mantissa_dot	#char is dot
			beq t5, a2, process_float_check_mantissa_e	#char is E
			beq t5, a5, process_float_check_mantissa_done	#char is space
			beq t5, a6, process_float_check_mantissa_done	#char is CR
			sub t5, t5, a0					#char is numeral - convert to number
			mul t6, t6, a4					#increment saved number by 10
			beqz a7, process_float_check_addin		#not found . yet so test for x10
			addi t4, t4, 1					#found . already so increment count to right of DP
  process_float_check_addin:
			add t6, t6, t5					#add found numeral - maybe zero but save nothing with jump
			beqz t6, process_float_process_on
			addi s6, s6, 1
			bgt s6, s7,  float_return_nan			#input too long to process - return NaN
  process_float_process_on:
			addi t1, t1, 1					#increment index into number string
			addi t3, t3, -1					#decrement numb of chars left
			j process_float_calculate_mantissa		#loop back
  process_float_check_mantissa_dot:
			li a7, 1					#found a dot
			j process_float_process_on			#loop back
  process_float_check_mantissa_e:
			beqz t6, float_return_zero			#return 0 for zero
			#store mantissa and correction count
			#and check exponent
			sd t6, 136(s9)					#store number
			sd t4, 152(s9)					#right of DP
			sd s0, 160(s9)					#left of DP
			ld s0, 64(s9)					#restore s0
			j process_float_search_exponent			#move on to checking exponent
  process_float_check_mantissa_done:
			beqz t6, float_return_zero			#return 0 (all bits off)
			#store mantissa and correction count
			sd t6, 136(s9)					#number
			sd t4, 152(s9)					#right of DP
			sd s0, 160(s9)					#left of DP
			mv a0, s0
  process_float_mantissa_done_ahead:
			sub a0, a0, t4
			sd a0, 144(s9)
			ld s0, 64(s9)
			PUSH ra
			j process_float_transfer_to_stack
  process_float_search_exponent:
			li t6, 0					#count of exponent
			PUSH ra
			addi a0, t1, 1					#start of string
			mv a1, t3
			call sumstring					#returns with a0 holding exponent
			#now adjust to account for left or right
			ld t0, 152(s9)					#right of DP
			sub a0, a0, t0
			ld t0, 160(s9)					#left of DP
			beqz t0, process_float_search_exponent_ahead	#don't subtract 1 if nothing to left
			addi t0, t0, -1					#1 digit to left is power of 0 etc
  process_float_search_exponent_ahead:
			blez t0, process_float_save_exponent
  process_float_save_exponent:
			sd a0, 144(s9)	#store base 10 index
  process_float_transfer_to_stack:
			#process exponent
			call process_index
			sd a0, 144(s9)		#store base 2 index
			sd a1, 152(s9)		#store adjustment
			sd a2, 160(s9)		#offset for adjustment
			#process mantissa
			ld a0, 136(s9)		#number
			call process_mantissa
			ld a2, 144(s9)		#a2 now has index
			ld a3, 152(s9)		#a3 now has addition
			ld a4, 160(s9)		#a4 has any additional offset
			#sum up the mantissa
			call sum_up_mantissa
			#now have all we need
			#a0 has mantissa
			#a2 has power
			li a1, 1	#default is failure
			li t0, 1023	#test exponent in range
			add a2, a2, t0
			blez a2, float_out_zero
			slli t0, t0, 1
			bgt a2, t0, float_out_pve_inf
			ld t0, 128(s9)	#sign data
			beqz t0, float_is_positive
			li t0, 0x8000000000000000	#turn neg bit on
			j float_insert_mantissa
  float_is_positive:
			li t0, 0
  float_insert_mantissa:
			li t1, 0xFFFFFFFFFFFFF	#52 bits
			and a0, a0, t1
			or t0, t0, a0
			slli a2, a2, 52
			or a0, t0, a2	#have a float now
			li a1, 0	#return success
  process_float_recover:
  float_out:
			call float_stack_down
			POP ra
			ret
  float_out_pve_inf:
			li a0, 0x7FF0000000000000	#positive infinity
  float_out_test_negative:
			ld t0, 128(s9)
			beqz t0, float_out_continue
			li a1, 0x8000000000000000
			or a0, a0, a1
  float_out_continue:
			li a1, 0
			j float_out
  float_out_zero:
			li a0, 0x0			#zero
			j float_out_test_negative
  process_float_exponent_fail:
			li a1, 1
			j process_float_recover
  float_return_zero:					#return 0 (all bits off)
			PUSH ra
			call float_stack_down
			POP ra
			li a0, 0
			li a1, 0
			ret
  float_return_nan:
			li a0, 0x7FFFFFFFFFFFFFFF	#NaN - input too long
			li a1, 0
			PUSH ra
			call float_stack_down
			POP ra
			ret


  process_mantissa:
	#INPUT  a0 - fractional number to be processed 
	#OUTPUT a0 - processed number
	#	a1 - power count
			bnez a0, process_mantissa_continue
			li a1, 0
			ret					#just return 0
  process_mantissa_continue:
			sd s0, 64(s9)
			mv s0, a0
			li s1, 63
			li s3, 1
  process_mantissa_test_scale:
			sll s2, s3, s1
			and s4, s0, s2
			bnez s4, process_mantissa_done
			addi s1, s1, -1
			j process_mantissa_test_scale
  process_mantissa_done:
			mv a1, s1
			ld s0, 64(s9)
			ret

  process_index:
	#INPUT: 	a0	index - base 10
	#OUTPUT:	a0	index - base 2
	#		a1	to add to mantissa
	#		a2	offset to addition
			bnez a0, process_index_continue
			li a1, 0
			li a2, 0
			ret
  process_index_continue:
			#handle transformation of a0
			sd s0, 64(s9)					#store registers
			sd s1, 72(s9)
			sd s2, 80(s9)
			sd s3, 88(s9)
			sd s4, 96(s9)
			sd s5, 104(s9)					#use s5 as base for bit count
			blt a0, zero, process_index_negative_continue	#negative power
			li s5, 0					#set to zero
			#multiply number out - handle simple case of 1
			li t1, 1
			li s0, 10
			bne a0, t1, process_index_standard		#not equal to 1
			li s1, 3					#1010b - highest index is three for 10^1
			j process_index_calc_comp			#jump ahead
  process_index_standard:
			mv s2, a0					#set s2 to 10 index
			addi s2, s2, -1					#decrement index
			li t0, 10					#invariant
  process_index_not1:
			mulhu s3, s0, t0				#get upper 128 bits of multiple
			addi s2, s2, -1					#decrement index
			beqz s3, process_index_bitcount			#upper 128 bits are 0
			#how far have we 'overshot'?
			li t5, 1
			li t6, 63
  process_index_test_overflow:
			sll a3, t5, t6					#mark index bit
			and a4, s3, a3					#test index bit
			bnez a4, process_index_found_overflow		#if bit is 1 jump head
			addi t6, t6, -1					#decrement index
			j process_index_test_overflow			#loop back
  process_index_found_overflow:
			#now have to calculate increase
			bnez s5, process_index_found_overflow_repeat	#not the first time?
			add s5, s5, t6					#first time - add offset into 64 bits
			addi s5, s5, 2					#make up for reduction back to 62
			li a3, 63					#calculate real update
			j process_index_found_overflow_continue
  process_index_found_overflow_repeat:
			add s5, s5, t6					#add offset into upper 64 bits
			addi s5, s5, 2					#based on resetting to 62nd bit
  process_index_found_overflow_continue:
			mul s0, s0, t0					#generate lower 64 bits
			li a3, 63
			sub a3, a3, t6					#calculate shift needed
			sll s3, s3, a3					#shift left
			addi t6, t6, 1
			srl s0, s0, t6					#shift lower 64 bits right to drop lower bits
			or s0, s3, s0					#get new number
			srli s0, s0, 1					#reset to 62 bits
			li s1, 62					#set count to 62
			bnez s2, process_index_not1			#need to do more?
			j process_index_calc_comp			#no, so jump ahead
			
  process_index_bitcount:
			mul s0, s0, t0					#multiply by 10 - result in s0
			li t1, 1					#turn single bit on
			li t2, 63					#max bit shift
			sll t1, t1, t2					#set t1 to 0x8000000000000000
  process_index_bitcount_check:
			and t3, s0, t1					#is bit set?
			bnez t3, process_index_bitcount_found		#if bit set jump ahead
			srli t1, t1, 1					#shift right
			addi t2, t2, -1					#decrease count
			bltz t2, process_index_error			#underflow error
			j process_index_bitcount_check			#loop back
  process_index_bitcount_found:
			mv s1, t2					#found set bit - s1 holds count
			bnez s2, process_index_not1			#loop back if more to do
  process_index_calc_comp:
			#get here with s0 as number - but do not need to divide as
			#s1 has bitcount - needed if > 63
			#but have to return a0 and a1
			mv a0, s1
			li s2, 1
			sll s3, s2, s1					#set bit to match index
			mv a1, s0
			xor a1, a1, s3					#get rid of index bit
			bnez a1, process_index_calc_comp_offset_calc
			#no addition at all
			li a2, 0
			j process_index_error
  process_index_calc_comp_offset_calc:
			li s2, 1
			li s3, 0
			sll s2, s2, a0
  process_index_calc_comp_offset_check:
			srli s2, s2, 1
			and s4, a1, s2
			bnez s4, process_index_calc_comp_offset_done
			addi s3, s3, 1
			j process_index_calc_comp_offset_check
  process_index_calc_comp_offset_done:
			mv a2, s3
			add a0, a0, s5					#increment by any increase from shifting window
  process_index_error:			#TODO: fix label	
			ld s0, 64(s9)
			ld s1, 72(s9)
			ld s2, 80(s9)
			ld s3, 88(s9)
			ld s4, 96(s9)
			ld s5, 104(s9)
			ret
  process_index_negative_continue:
			#handle negative index
			#divide 1 by 10 by number of times indicated by index
			mv s0, a0
			neg s0, s0
			li t0, 10	#invariant
			
  			#set up counts
			li s1, 0	#depth of first 1
			li s2, 1	#starting number
  process_index_negative_look:
			divu t1, s2, t0
			beqz t1, process_index_negative_advance_search
			j process_index_negative_divide_out_number
  process_index_negative_advance_search:
			addi s1, s1, 1
			slli s2, s2, 1
			j process_index_negative_look
  process_index_negative_divide_out_number:
			li a7, 63
			li a6, 1
			sll a5, a6, a7		#a5 holds number
  process_index_negative_div_process:
			beqz a7, process_index_negative_div_done
			rem s2, s2, t0
			slli s2, s2, 1
			addi a7, a7, -1
			divu a4, s2, t0
			bnez a4, process_index_negative_div_factor
			j process_index_negative_div_process
  process_index_negative_div_factor:
			sll t2, a6, a7
			or a5, a5, t2
			mul a4, a4, t0
			sub s2, s2, a4
			bnez s2, process_index_negative_div_process
  process_index_negative_div_done:
			#a5 has current value
			#s1 has index
			mv s2, a5
			#now process second and subsequent divisions
			li a7, 0x8000000000000000
  process_index_negative_scan:
			and a6, a7, s2
			bnez a6, process_index_negative_look_second
			slli s2, s2, 1
			addi s1, s1, 1
			j process_index_negative_scan
  process_index_negative_look_second:
			addi s0, s0, -1
			beqz s0, process_index_negative_result
			divu s2, s2, t0
			j process_index_negative_scan
  process_index_negative_result:
			#calculate any additional offset for addition
			li a2, 0
			li t0, 62
			li t1, 1
  process_index_negative_test_additional_offset:
			sll t3, t1, t0
			and t4, s2, t3
			bnez t4, process_index_negative_additional_offset_d
			addi t0, t0, -1
			bltz t0, process_index_negative_additional_offset_d
			addi a2, a2, 1
			j process_index_negative_test_additional_offset
  process_index_negative_additional_offset_d:
			mv a0, s1
			li t0, 0x8000000000000000
			xor a1, s2, t0
			neg a0, a0
			j process_index_error


  float_stack_up:
			#use 0 - 127 for register storage (16 registers at most)
			#Fixed locations
			#a0 - a7: 0 - 56
			#s0 - s7: 64 - 120
			#128 - 255 for scratch pad
			#128 - sign
			#136 - mantissa
			#144 - exponent
			addi s9, s9, -256
			sd s0, 64(s9)
			sd s1, 72(s9)
			sd s2, 80(s9)
			sd s3, 88(s9)
			sd s4, 96(s9)
			sd s5, 104(s9)
			sd s6, 112(s9)
			sd s7, 120(s9)
			ret

  float_stack_down:	
			ld s0, 64(s9)
			ld s1, 72(s9)
			ld s2, 80(s9)
			ld s3, 88(s9)
			ld s4, 96(s9)
			ld s5, 104(s9)
			ld s6, 112(s9)
			ld s7, 120(s9)
			addi s9, s9, 256
			ret

 sum_up_mantissa:
			#input 	a0 - mantissa
			#	a1 - length in
			#	a3 - addition
			#	a4 - offset
			li s6, 0
			mv t1, a0
			mv t2, a3
			mv t3, a4
			li t4, 1
			li t5, 63
			beq a1, t5, sum_up_mantissa_setup	#no shift needed
			sub s7, t5, a1				#calculate shift
			addi s7, s7, -1				#but leave top bit free
			sll a0, a0, s7				#make shift
			sub a2, a2, s7				#decrement exponent by shift
  sum_up_mantissa_setup:
			mv t0, a0
			bgt t3, t5, sum_up_mantissa_done	#offset too big to be of use
			beqz a3, sum_up_mantissa_done		#addition is zero
			#find start of addition
  sum_up_mantissa_look_for_start:
			sll t6, t4, t5				#look for the first bit in the 'addition'
			and s1, t6, t2				#look for bit
			bnez s1, sum_up_mantissa_begin		#found start
			addi t5, t5, -1				#decrement shift
			j sum_up_mantissa_look_for_start	#loop
  sum_up_mantissa_begin:
			#t5 holds bit count
			li s1, 62
			li a6, 0x8000000000000000		#used to test for 63rd bit
			li s2, 1
			add t4, t4, t3				#t4 holds displacement
			bgt t4, s1, sum_up_mantissa_done
  sum_up_mantissa_sum:
			srl t3, a0, t4				#number to add
			beqz t3, sum_up_mantissa_done
			add t0, t0, t3				#add number
			and a7, a6, t0				#has 63rd bit been turned on?
			beqz a7, sum_up_mantissa_shift_count	#no then jump ahead
			srli t0, t0, 1  			#return to 62 bits
			addi s6, s6, 1				#increment count of power increase
			addi t4, t4, 1  			#adjust the 'addition' offset
  sum_up_mantissa_shift_count:
			addi t4, t4, 1				#increment addition offset
			bgt t4, s1, sum_up_mantissa_done	#no point in continuing if now too big
			addi t5, t5, -1				#decrement index to bit in addition
			bltz t5, sum_up_mantissa_done		#stop if we are at the end here
			sll t6, s2, t5				#build index
			and s3, t2, t6				#get indexed bit
			beqz s3, sum_up_mantissa_shift_count	#zero - so just decrement
			j sum_up_mantissa_sum			#go back to add
  sum_up_mantissa_done:
			li t2, 0x200				#index for overflow
			and t3, t0, t2				#get overflow bit
			srli t0, t0, 10				#shift right
			beqz t3, sum_up_mantissa_overflow_done	#no overflow so jump ahead
			addi t0, t0, 1				#add overflow bit
			li t1, 0x20000000000000			#index for increase in bit length
			and t5, t0, t1				#get bit that indicates increase
			beqz t5, sum_up_mantissa_overflow_done 	#no increase - jump ahead
			srli t0, t0, 1				#correct length
			addi s6, s6, 1				#increment power
  sum_up_mantissa_overflow_done:
			mv a0, t0
			add a2, a2, s6
			addi a2, a2, 62 #power
  sum_up_done:
			ret
  sum_up_mantissa_power_inc:
			addi a2, a2, 1
			j sum_up_done

  sumstring:
			#input
			#a0 has start of string
			#a1 has length
			#output a0 - exponent
			#a3 == -1: failure
			sd s1, 72(s9)
			sd s2, 80(s9)
			sd s3, 88(s9)
			sd s4, 96(s9)
			sd s5, 104(s9)
			sd s6, 112(s9)
			li a3, 0
			li s1, 0x0A	#10
			li s2, 0x30	#0
			li s3, 0x39	#9
			#test for sign
			li s4, 0x2B	#+
			li s5, 0x2D	#-
			lbu s6, 0(a0)
			beq s6, s5, sumstring_negative		#check if first char is a sign
			beq s6, s4, sumstring_positive		#check for sign
			li s6, 0				#not a sign
			li s5, 1				#so set up assuming +ve
			j sumstring_read			#use current index
  sumstring_negative:
			li s5, -1				#mark negative
			j sumstring_signed
  sumstring_positive:
			li s5, 1				#mark positive
  sumstring_signed:
			li s6, 0
			addi a0, a0, 1
			addi a1, a1, -1
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
			mul a0, a0, s5				#correct for sign
  sumstring_return:
			ld s6, 112(s9)
			ld s5, 104(s9)
			ld s4, 96(s9)
			ld s3, 88(s9)
			ld s2, 80(s9)
			ld s1, 72(s9)
			ret
  sumstring_fail:
	 		li a3, -1
			j sumstring_return
