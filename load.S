	#Load files

	CODEHEADER ACCEPT, ELSE, 0x01
	#( addr m -- n ) 
	#Fetch up to m characters
	mv a0, zero
	ld a1, 8(sp)
	ld a2, 0(sp)
	li a7, 63
	ecall
	sd a0, 8(sp)
	addi sp, sp, 8
	la a0, INPUT_BUFFER		#ensure no tokenization
	sd a0, INPUT_START, t0
	sd a0, INPUT_END, t0
	tail NEXT

	CODEHEADER INCLUDE, ACCEPT, 0x01
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

	#have we got an already openfile
	la s0, LOADINGFILE
	ld a0, 0(s0)
	beqz a0, load_check_memory
	call fclose			#close file
	sd zero, 0(s0)
  load_check_memory:
	la s1, FILEMEMORYADDR
	ld a0, 0(s1)
	beqz a0, load_parse_name
	call free
	sd zero, 0(s1)

  load_parse_name:
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
	la s4, LOADINGFILE	#file stream
	sd a0, 0(s4)
	li a0, 512		#get 512 bytes from malloc
	call malloc
	beqz a0, load_malloc_failed
	la s5, FILEMEMORYADDR	#hold address of allocated memory
	sd a0, 0(s5)
	#now rig the outerloop
	la s7, outer_loop_tokenize
	la t2, INFILELOAD
	la t0, LOADLINESETUP
	li t1, 1
	sd t1, 0(t2)
	sd zero, 0(t0)
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
  

  load_get_next_line:
	#setup to pull a line in
	addi sp, sp, -8
	sd ra, 0(sp)
	la t0, LOADLINESETUP
	li t1, 1
	sd t1, 0(t0)
	la t1, FILEMEMORYADDR
	ld a0, 0(t1)
	li a1, 512
	la t1, LOADINGFILE
	ld a2, 0(t1)
	call fgets
	beqz a0, load_free_malloc #nothing returned
	PUSH a0
	#output the read in line
	call puts
	#now process the line
	#start by looking for tokens
	la t0, INPUT_START
	POP t1
	sd t1, 0(t0)
	addi t1, t1, 512
	la t0, INPUT_END
	sd t1, 0(t0)
	fence.i
	ld ra, 0(sp)
	addi sp, sp, 8
	ret		#go back
       	 

  load_free_malloc:
	la t0, LOADINGFILE
	ld a0, 0(t0)
	beqz a0, load_check_out_memory
	call fclose			#close file
	la t0, LOADINGFILE
	sd zero, 0(t0)
  load_check_out_memory:
	la t1, FILEMEMORYADDR
	ld a0, 0(t1)
	beqz a0, load_finish_free
	call free
	la t1, FILEMEMORYADDR
	sd zero, 0(t1)
  load_finish_free:
	fence.i
	la t0, INFILELOAD
	sd zero, 0(t0)
	la t0, LOADLINESETUP
	sd zero, 0(t0)
	la s7, outer_loop_ok
	ld ra, 0(sp)
	addi sp, sp, 8
	la a0, INPUT_START			#ensure we don't process junk bytes
	la a1, INPUT_END
	ld a2, 0(a1)
	sd a2, 0(a0)
	ret				


  load_malloc_failed:
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
