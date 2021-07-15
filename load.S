
	#Load files

	CODEHEADER LOAD, ELSE, 0x01
	#Load a file line by line, executing each line as we go
	addi sp, sp, -72
	sd s0, 0(sp)
	sd s1, 8(sp)
	sd s2, 16(sp)
	sd s3, 24(sp)
	sd s4, 32(sp)
	sd s5, 40(sp)
	sd s6, 48(sp)
	sd s10, 56(sp)
	sd s11, 64(sp)

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
	la a1, stdinopen
	call fopen
	addi s10, s10, 1
	sd s10, 0(s0)
	bgeu zero, a0, load_failed_nopath
	#create an area on the stack to store some values
	add sp, sp, -24
	sd a0, 0(sp)		#file pointer
	li a0, 512		#get 512 bytes from malloc
	call malloc
	beqz a0, load_malloc_failed
	sd a0, 8(sp)		#pointer to allocated memory
	#now rig the outerloop
	la s7, outer_loop_tokenize
	la t2, INFILELOAD
	la t0, LOADLINESETUP
	li t1, 1
	sd t1, 0(t2)
	sd zero, 0(t0)
	tail NEXT
  load_get_next_line:
	#setup to pull a line in
	la t0, LOADLINESETUP
	li t1, 1
	sd t1, 0(t0)
	ld a0, 8(sp)
	li a1, 512
	ld a2, 0(sp)
	PUSH ra
	call fgets
	POP ra
	fence
	beqz a0, load_free_malloc #nothing returned
	sd a0, 16(sp)
	#output the read in line
	PUSH ra
	call puts
	POP ra
	#now process the line
	#start by looking for tokens
	la t0, INPUT_START
	ld t1, 16(sp)
	sd t1, 0(t0)
	addi t1, t1, 512
	la t0, INPUT_END
	sd t1, 0(t0)
	ret		#go back
       	 

  load_free_malloc:
	ld a0, 8(sp)
	call free

  load_malloc_failed:
#	ld a0, 0(sp)
#	call fclose
	add sp, sp, 24
	la t0, INFILELOAD
	sd zero, 0(t0)
	la t0, LOADLINESETUP
	sd zero, 0(t0)
  load_failed_nopath:
	la s7, outer_loop_ok			#we are done
	ld s11, 64(sp)
	ld s10, 56(sp)
	ld s6, 48(sp)
	ld s5, 40(sp)
	ld s4, 32(sp)
	ld s3, 24(sp)
	ld s2, 16(sp)
	ld s1, 8(sp)
	ld s0, 0(sp)
	addi sp, sp, 72
	tail NEXT
