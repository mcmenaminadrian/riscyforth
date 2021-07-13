
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
	la a1, stdinopen
	call fopen
	addi s10, s10, 1
	sd s10, 0(s0)
	bgt zero, a0, load_failed_nopath
	#create an area on the stack to store some values
	add sp, sp, -24
	sd a0, 0(sp)		#file pointer
	li a0, 512		#get 512 bytes from malloc
	call malloc
	beqz a0, load_malloc_failed
	sd a0, 8(sp)		#pointer to allocated memory
  load_get_next_line:
	li a1, 512
	ld a2, 0(sp)
	call fgets
	beqz a0, load_free_malloc #nothing returned
	sd a0, 16(sp)
	#output the read in line
	call puts
	#now process the line
  load_tokenize_have_data:
        mv t0, a0                             #t0 tracks start of token, t1 the end
        addi t2, zero, 0x20                   #t2 space
        addi t3, zero, 0x0A                   #t3 CR
  load_tokenize_look_for_start:
        lb t4, 0(t0)
        beq t4, t2, load_tokenize_keep_going
        bne t4, t3, load_tokenize_found_start
        j load_tokenize_all_over
  load_tokenize_keep_going:
        addi t0, t0, 1
        bltu t0, a1, load_tokenize_look_for_start
        j load_tokenize_all_over                   #got nothing
  load_tokenize_found_start:
        mv t1, t0                             #t1 to track end of token
		
  load_tokenize_advance_search:
        addi t1, t1, 1
        bgeu t1, a1, load_tokenize_end_token
        lb t4, 0(t1)
        beq t4, t2, load_tokenize_end_token
        beq t4, t3, load_tokenize_end_token
        j load_tokenize_advance_search
  load_tokenize_end_token:
        sd t1, INPUT_START, t5                #update the end point for subsequent searches
        addi t1, t1, -1                       # space or NL not part of token
        mv t2, t0
	bne t0, t1, load_tokenize_prepare_sanity_test
	PUSH t0
	jal fix_up_input		      #one character token so check for expansion

		
  load_tokenize_prepare_sanity_test:
        addi t5, zero, 0x61                   #lowercase a
        addi t6, zero, 0x7B                   #lowercase z + 1
  load_tokenize_sanity_test:
        lb t4, 0(t2)
        blt t4, t5, load_tokenize_next_sane
        blt t4, t6, load_tokenize_sanitize
        j load_tokenize_next_sane
  load_tokenize_sanitize:
        addi t3, zero, 0x20
        xor t4, t4, t3
        sb t4, 0(t2)
  load_tokenize_next_sane:
        addi t2, t2, 1
        blt t1, t2, load_tokenize_finished_sanitization
        j load_tokenize_sanity_test
  load_tokenize_finished_sanitization:
        sd t0, TOKEN_START, t2
        sd t1, TOKEN_END, t2
        la s8, WA_SEARCH                      #TODO: CANNOT DO THIS NOW! hit search directly now
        li t2, 1
        PUSH t2                     

	ld a0, 8(sp)
	j load_get_next_line
	ld a0, 16(sp)
	 

  load_free_malloc:
	ld a0, 8(sp)
	call free

  load_malloc_failed:
	add sp, sp, 24

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
