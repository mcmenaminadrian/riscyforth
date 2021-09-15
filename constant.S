		CODEHEADER _CONSTANT, VARIABLE, 0x0
                li t1, 1
                sd t1, VARIABLEFLAG, t0                 #we are creating/updating a constant in create mode
                ld t2, 8(s7)                            #length
                addi a1, s7, 16                         #points to name
                j constant_create_mode                  #search for match

                CODEHEADER CONSTANT, _CONSTANT, 0x01
                #create a constant in the constant dictionary
                #first get the name and check it's not already present
                #constant stack grows downwards but each entry in forwards direction
                #
                ld a1, INPUT_END
                ld a0, INPUT_START
                addi t0, a0, 1                        #account for minimal input
                bltu t0, a1, constant_have_data       #buffer has data
  constant_all_over:
                tail NEXT
  constant_have_data:
                mv t0, a0                             #t0 tracks start of token, t1 the end
                addi t2, zero, 0x20                   #t2 space
                addi t3, zero, 0x0A                   #t3 CR
  constant_look_for_start:
                lbu t4, 0(t0)
                beq t4, t2, constant_keep_going
                bne t4, t3, constant_found_start
                j constant_all_over
  constant_keep_going:
                addi t0, t0, 1
                bltu t0, a1, constant_look_for_start
                j constant_all_over                   #got nothing
  constant_found_start:
                #constant name must start with a letter
                li a3, 0x41                                                                       #A
                bge t4, a3, constant_good_start
                #start with a bad character - report error
  constant_gone_bad:
                la t0, NotOk_msg
                addi t1, zero, 24                     #error message is 24 chars long
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                ld a1, 0(t0)
                la t1, TOKEN_END
                ld a2, 0(t1)
                sub a2, a2, a1
                addi a2, a2, 1
                call write                            #output error message
                addi t0, zero, 1
                sd t0, OKSTATUS, t1
                tail NEXT
  constant_good_start:
                mv t1, t0                             #t1 to track end of token
  constant_advance_search:
                addi t1, t1, 1
                bgeu t1, a1, constant_end_token
                lbu t4, 0(t1)
                beq t4, t2, constant_end_token
                beq t4, t3, constant_end_token
                j constant_advance_search
  constant_end_token:
                sd t1, INPUT_START, t5                #update the end point for subsequent searches
                addi t1, t1, -1                       # space or NL not part of token
                mv t2, t0
                li t5, 0x61                   #lowercase a
                li t6, 0x7B                   #lowercase z + 1
  constant_sanity_test:
                lbu t4, 0(t2)
                blt t4, t5, constant_next_sane
                blt t4, t6, constant_sanitize
                j constant_next_sane
  constant_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  constant_next_sane:
                addi t2, t2, 1
                blt t1, t2, constant_finished_sanitization
                j constant_sanity_test
  constant_finished_sanitization:
                sd t0, TOKEN_START, t2
                sd t1, TOKEN_END, t2
                #now check this is not a keyword or a number
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                li t3, NAMEMAXLEN
                bge t3, t2, constant_length_good
                j constant_gone_bad
  constant_length_good:
                la t4, dictionary
                ld t3, 0(t4)
  constant_next_in_dictionary:
                ld t4, 24(t3)
                bne t4, t2, constant_tokens_do_not_match
                add a0, t3, 32                        #a0 now points into the name in the dictionary
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone
  constant_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, constant_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, constant_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j constant_loop_through_token
  constant_tokens_do_not_match:
                ld t3, 16(t3)                          #read the pointer to the next TIL command
                beq t3, zero, constant_search_scan_constant_stack        #at the end of the dictionary
                j constant_next_in_dictionary

  constant_tokens_matched:
                #cannot have constant with same name as word
                j constant_gone_bad

  constant_create_mode:
                #now scan for a constant name
                sd a1, TOKEN_START, t0
                add a1, a1, t2
                addi a1, a1, -1
                sd a1, TOKEN_END, t0
                la t4, BOTTOM_CONS
                la t0, TOP_CONS
                ld t2, 0(t4)
                ld t3, 0(t0)
                bne t2, t3, constant_consider_update_backwards
                j constant_backwards_var_no_match

 #enable update of existing constant
  constant_search_scan_constant_stack:
                #now scan for a constant name
                la t4, BOTTOM_CONS
                la t0, TOP_CONS
                ld t2, 0(t4)
                ld t3, 0(t0)
                bne t2, t3, constant_consider_update
                j constant_search_var_no_match        #no constants have been defined yet
  constant_consider_update:
                bne zero, a5, constant_consider_update_backwards
                ld t0, TOKEN_START                    #token values are valid
                ld t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
                ld t4, 0(t4)
                addi t4, t4, 48
                ld t3, 0(t4)                          #check value at first flag
                j constant_search_var_next_check

  constant_consider_update_backwards:
                ld t0, TOKEN_END
                ld t1, TOKEN_START
                sub t2, t0, t1
                add t2, t2, 1
                ld t4, 0(t4)
  constant_backwards_keep_going:
                add t4, t4, 48
                la t3, TOP_CONS
                ld t3, 0(t3)
                bgt t4, t3, constant_backwards_var_no_match
                ld t3, 0(t4)
                li a3, 0xbaadcafe
                beq t3, a3, constant_search_var_next_backwards_in_dictionary
                j constant_gone_bad
  constant_search_var_next_backwards_in_dictionary:
                ld t3, -8(t4)
                bne t3, t2, constant_search_backwards_tokens_do_not_match
                addi a0, t4, -9
                mv a1, t1
                mv a2, t2                       #how far
  constant_search_backwards_loop:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, constant_search_backwards_tokens_do_not_match
                addi a2, a2, -1                 #countdown size
                beq a2, zero, constant_search_var_tokens_matched
                addi a0, a0, -1
                addi a1, a1, 1
                j constant_search_backwards_loop
  constant_search_backwards_tokens_do_not_match:
                j constant_backwards_keep_going

  constant_search_var_next_check:
                li a3, 0xbaadcafe
                beq t3, a3, constant_search_var_next_in_dictionary
                j constant_gone_bad
  constant_search_var_next_in_dictionary:
                ld t3, -8(t4)
                #compare lengths
                bne t3, t2, constant_search_var_tokens_do_not_match
                addi a0, t4, -9                        #a0 now points into the name in the var stack
                mv a1, t0                             #a1 points to the name in the buffer
                mv a2, t2                             #a2 checks how far we've gone

  constant_search_var_loop_through_token:
                lbu t5, 0(a0)
                lbu t6, 0(a1)
                bne t5, t6, constant_search_var_tokens_do_not_match
                addi a2, a2, -1
                beq a2, zero, constant_search_var_tokens_matched
                addi a0, a0, -1
                addi a1, a1, 1
                j constant_search_var_loop_through_token

  constant_search_var_tokens_do_not_match:
                add t4, t4, 48                        #advance up the var stack
                la t3, TOP_CONS
                ld t3, 0(t3)
                bgt t4, t3, constant_search_var_no_match
                ld t3, 0(t4)
                j constant_search_var_next_check

  constant_search_var_tokens_matched:
                #update the value
                POP t0                 # assign from stack
                sd t0, -32(t4)
                tail NEXT

  constant_backwards_var_no_match:
                ld t1, TOKEN_START                    #reset t2
                ld t0, TOKEN_END
                sub t2, t0, t1
                addi t2, t2, 1                        #t2 has length of token
                la t1, BOTTOM_CONS
                ld t3, 0(t1)
                ld t4, 0(t3)
                beq zero, t4, constant_backwards_empty_space
                j constant_gone_bad                     #error in var stack
  constant_backwards_empty_space:
                li t1, 0xbaadcafe                       #mark in use
                sd t1, 0(t3)
                sd t2, -ADDRWIDTH(t3)                   #length - stack grows down
                mv t4, t3
                addi t3, t3, -(ADDRWIDTH + 1)
                mv a3, t2
                #reset a1
                ld a1, TOKEN_START
  constant_backwards_write_out_name:
                lbu t5, 0(a1)
                sb t5, 0(t3)
                addi t3, t3, -1
                addi a1, a1, 1
                addi a3, a3, -1
                bne a3, zero, constant_backwards_write_out_name
                addi t4, t4, -(NAMEMAXLEN + INSTWIDTH2)
                POP t0                                 #assign from stack
                sd t0, 0(t4)
                #update bottom pointer
                la t1, BOTTOM_CONS
                ld t3, 0(t1)
                addi t3, t3, -48
                sd t3, 0(t1)
                tail NEXT


  constant_search_var_no_match:
                ld t0, TOKEN_START                    #reset t2
                ld t1, TOKEN_END
                sub t2, t1, t0
                addi t2, t2, 1                        #t2 has length of token
  constant_varin_entry_point:
                la t1, BOTTOM_CONS
                ld t3, 0(t1)
                ld t4, 0(t3)
                beq zero, t4, constant_empty_space
                j constant_gone_bad                     #error in var stack
  constant_empty_space:
                li t1, 0xbaadcafe                       #mark in use
                sd t1, 0(t3)
                sd t2, -ADDRWIDTH(t3)                   #length - stack grows down
                mv t4, t3
                addi t3, t3, -(ADDRWIDTH + 1)
                mv a3, t2
  constant_write_out_name:
                #reset a1
                mv a1, t0
  constant_loop_write_out_name:
                lbu t5, 0(a1)
                sb t5, 0(t3)
                addi t3, t3, -1
                addi a1, a1, 1
                addi a3, a3, -1
                bne a3, zero, constant_loop_write_out_name
                addi t4, t4, -(NAMEMAXLEN + INSTWIDTH2)
                POP t0                                 #assign from stack
                sd t0, 0(t4)
                #update bottom pointer
                la t1, BOTTOM_CONS
                ld t3, 0(t1)
                addi t3, t3, -48
                sd t3, 0(t1)
                tail NEXT

