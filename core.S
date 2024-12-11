#         RISCYFORTH dictionary
###############################
                #s9 as RS
                #s8 as WA
                #s7 as I
.balign 8
  launchRISCYFORTH:
		la a0, outerLoopTokenizeAddress
		la a1, outer_loop_tokenize
		sd a1, 0(a0)
		la a0, literalNumberAddress
		la a1, WA_LITERALNUMB
		sd a1, 0(a0)
		la t0, pull_in_another
		la t1, PULLINANOTHER
		sd t0, 0(t1)			# for library code
		la a5, VERBOSE			# test for verbose output
		ld a6, 0(a5)
		beqz a6, printmsgonly
                la a0, riscy_forth0
                call puts
                la a0, welcome_msg
                call puts
                PRINT riscy_forth0
                PRINT riscy_forth1
                PRINT riscy_forth3
                PRINT riscy_forth4
                PRINT riscy_forth4a
                PRINT riscy_forth5
                PRINT riscy_forth0
                WRITECR
                WRITECHAR 0x0A
                WRITECR
                WRITECHAR 0x0A
                WRITECR
                WRITECHAR 0x0A
		j printdone
  printmsgonly:
                la a0, welcome_msg
                call puts
  printdone:
		la t0, LOADINGFILE
		sd zero, 0(t0)			#ensure filehandle is NULL
		la t0, STACKTOP
		sd sp, 0(t0)			#top of the stack

		la t0, INFILELOAD
		sd zero, 0(t0)			#we are not in file load mode
		la t0, LOADLINESETUP
		sd zero, 0(t0) 
		li t0, 1
		#set up memory allocator
		call initialize_memoryspace	  
		#now create standard dataspace
                mv a0, zero
		li a1, BIGGERSPACE
		li a2, 0x07			#read and execute
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222			#mmap
		ecall
		la t0, dataspace
		sd a0, 0(t0)
		la t0, dataspaceptr
		sd a0, 0(t0)
		#allocate space for new definitions
                mv a0, zero
		li a1, BIGGERSPACE
		li a2, 0x07			  #read and execute
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222			  #mmap
		ecall
		la t0, newdictionary
		sd a0, 0(t0)
		#now allocate space for conditional blocks
		mv a0, zero
		li a1, BIGSPACE
		li a2, 0x07
		li a3, 0x22
		li a4, -1
		li a5, 0
		li a7, 222			#mmap
		ecall
		#set up the simple stack pointer for the decision creation
		mv t0, a0
		add t0, t0, a1
		addi t0, t0, -8
		la t1, DECIDESTACKB
		sd t0, 0(t1)			#top of the stack, holds address of next decision block block
		sd a0, 0(t0)			#store address
		addi t0, t0, -8
		la t1, DECIDESTACKP
		sd t0, 0(t1)
		sd zero, 0(t0)			    #zero skips currently
		sd zero, -8(t0)			    #high tide also zero	
		sd zero, -16(t0)			    #ensure all of stack is zero
		sd zero, -24(t0)
		sd zero, -32(t0)
		sd zero, -40(t0)
		sd zero, -48(t0)
                sd zero, OKSTATUS, t0
                sd zero, CREATEFLAG, t0
		sd zero, VARIABLEFLAG, t0
                la t1, TIL_ABORT	                    #start search from here
                sd t1, dictionary, t0

                sd zero, TOKEN_START, t0
                sd zero, TOKEN_END, t0
                li t1, 10                   	#decimal as start-up base
                sd t1, CURRENT_BASE, t0
		#setup termios
		call copy_termios_structure
		call reset_termios
		#pass NEXT for modules
		la a0, NEXT
		call setNextAddress
		# any initial execution?
		la t0, CMDLINE
		ld t1, 0(t0)
		beqz t1, set_outer_loop 
		j process_init_file 
  set_outer_loop:
                la s7, outer_loop                   #set instruction register to start of outer loop

  NEXT:
                ld s8, 0(s7)                        #word address register takes content of next secondary
                addi s7, s7, ADDRWIDTH              #next secondary along
  
  RUN:
                ld t0, 0(s8)                        #extract first instruction address of primative
                addi s8, s8, ADDRWIDTH              #increment WA
                jalr zero, t0, 0                    #run the code    

  EXE:                                              #execute the next command on the stack
               	la s7, outer_loop_tokenize
               	POP s8
               	j RUN


  process_init_file:
        la a0, INITFILE
        ld a1, 0(a0)
        beqz a1, cmdline_opts
        la t0, ININIT
        li t1, 1
        sd t1, 0(t0)                                # in -i loading
        addi sp, sp, -16
        sd a1, 0(sp)                                # store for count
        sd zero, 8(sp)                              # count up
        li t0, 0
  process_init_file_pick:
        li t1, 0x80                                 # paths may be 127 chars long
        mul t2, t0, t1
        la a0, INITFILEPATH
        add a0, a0, t2
		# code to process init file and then hand over control to INCLUDE code
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
		#now point the registers to the right place
		la a1, stdinopen
		call fopen
		tail init_join_include
  process_next_init:
        ld a0, 0(sp)
        addi a0, a0, -1
        beqz a0, process_init_done
        sd a0, 0(sp)
        ld t0, 8(sp)
        addi t0, t0, 1
        sd t0, 8(sp)
        j process_init_file_pick
  process_init_done:
        la a0, CMDLINE
        ld a1, 0(a0)
        li a2, 2
        beq a1, a2, process_cmdline
        addi sp, sp, 16
        la a0, ININIT
        sd zero, 0(a0)                      # not in -i loading
        j set_outer_loop

  process_cmdline:
        ld a0, 8(sp)
        addi a0, a0, 1
        addi sp, sp, 16
  process_cmdline_zero:
        li a1, 0x80
        mul a2, a1, a0
        la a3, INITFILEPATH
        add a0, a2, a3
        # count up to zero
        li t0, 0
        li t1, 0
        mv t2, a0
  cmdline_loop_for_zero:
        lb t3, 0(t2)
        beq t3, t1, cmdline_found_zero
        addi t0, t0, 1
        addi t2, t2, 1
        j cmdline_loop_for_zero
  cmdline_found_zero:
        #set up call to EVALUATE word
        addi sp, sp, -16
        sd a0, 8(sp)
        sd t0, 0(sp)
        la s8, WA_EVALUATE
        tail RUN
 

  cmdline_opts:
        mv a0, zero
        j process_cmdline_zero
