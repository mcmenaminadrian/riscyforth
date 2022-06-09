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

 #a0 address to start writing
 #a1 low part of number to write
 #a2 high part of number to write
 #a3 next address
 .globl utility_two_constant_code
 utility_two_constant_code:
			li t0, 0x297
			sw t0, 0(a0)						#aui t0, 0 (mv t0, pc)
			li t0, 0x202B303
			sw t0, 4(a0)						#ld t1, 32(t0)
			li t0, 0x282B383
			sw t0, 8(a0)						#ld t2, 40(t0)
			li t0, 0xFF010113
			sw t0, 12(a0)						#addi sp, sp, -16
			li t0, 0x613423
			sw t0, 16(a0)						#sd t1, 8(sp)
			li t0, 0x713023
			sw t0, 20(a0)						#sd t2, 0(sp)
			#now jump to next
			li t0, 0x302B303
			sw t0, 24(a0)						#ld t1, 48(t0)
			li t0, 0x30067
			sw t0, 28(a0)						#jr t1
			sd a2, 32(a0)						#hi						
			sd a1, 40(a0)						#low
			sd a3, 48(a0)						#NEXT
			addi a0, a0, 56
			fence.i
			ret

