
	#Load files

	CODEHEADER LOAD, ELSE, 0x01
	#Load a file line by line, executing each line as we go
	addi sp, sp, -80
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	sd s3, 32(sp)
	sd s4, 40(sp)
	sd s5, 48(sp)
	sd s6, 56(sp)
	sd s10, 64(sp)
	sd s11, 72(sp)

	#parse the file name
	la s0, INPUT_START
	ld s1, 0(s0)
	la s2, INPUT_END
	ld s2, 0(s2)
	li s3, 0x20			#space
	li s4, 0x0A			#cr
  load_loop_searchpath:
	lb s5, 0(s1)
	beq s5, s4, load_failed_nopath
	bne s5, s3, load_start_path
	addi s1, s1, 1
	bgt s1, s2, load_failed_nopath
	j load_loop_searchpath
  load_start_path:
	li s6, 1			#length of path
  load_find_path:
	add s10, s1, s6			#next place to check
	bgt s10, s2, load_failed_nopath
	lb s5, 0(s10)
	beq s5, s3, load_got_path
	beq s5, s4, load_got_path
	addi s6, s6, 1
	j load_find_path
  load_got_path:
	#now make a system call - read in the file one line at a time
	#first make our string null terminated
	sb zero, 0(s10)
	mv a0, s1
	mv a1, zero
	call open
	addi s10, s10, 1
	sd s10, 0(s0)
	bgt zero, a0, load_failed_nopath
	#now call fdopen
	la a1, stdinopen
	call fdopen

  load_failed_nopath:
	ld s11, 72(sp)
	ld s10, 64(sp)
	ld s6, 56(sp)
	ld s5, 48(sp)
	ld s4, 40(sp)
	ld s3, 32(sp)
	ld s2, 24(sp)
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 80
	tail NEXT
