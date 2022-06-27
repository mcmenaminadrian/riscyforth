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
   .comm EXTENDERS, PAGESIZE
   .comm EXTENDERSPTR, ADDRWIDTH

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

