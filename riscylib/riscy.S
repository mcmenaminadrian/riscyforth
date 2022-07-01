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
			addi sp, sp, -56
			sd s0, 0(sp)
			sd s1, 8(sp)
			sd s2, 16(sp)
			sd s3, 24(sp)
			sd s4, 32(sp)
			sd s5, 40(sp)
			sd s6, 48(sp)
			li a0, 0
			li s0, 24	#MAXNAMELEN
			bgt a2, s0, lib_check_dictionary_bail
			la s0, dictionary
			ld s1, 0(s0)
  lib_check_dictionary_length_match:
			ld s2, 24(s1)
			bne s2, a2, lib_check_dictionary_get_next
			addi s3, s1, 32	#s3 points to word in dictionary
			mv s0, a2
			mv s4, a0
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
			ld a1, -8(s1)
			mv a2, s1
  lib_check_dictionary_bail:
			ld s6, 48(sp)
			ld s5, 40(sp)
			ld s4, 32(sp)
			ld s3, 24(sp)
			ld s2, 16(sp)
			ld s1, 8(sp)
			ld s0, 0(sp)
			addi sp, sp, 56
			ret
