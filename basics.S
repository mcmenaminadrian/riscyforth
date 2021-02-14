#Basic primatives we need to get anything done


  dictionary_top:
		            CODEEND GETSTDIN, 0x01
    		        GETIN
        		    PUSH a0
            		tail NEXT

		            CODEHEADER TYPE, GETSTDIN, 0x01
                WRITECR
                WRITECHAR 0x0A
         		    WRITECHAR 0x3E                      #> prompt
          			tail NEXT

  		          CODEHEADER GETNEXTLINE_IMM, TYPE, 0x01
                #Fetch a line for immediate execution
                #Leaves length (top) and address on stack
      		      POP a2
                la a0, INPUT_BUFFER
                MARKINPUTBUFFER INPUT_BUFFER        #ensure buffer starts 'empty'
                addi a1, zero, BUFFERLEN
        		    call fgets
                sw a0, INPUT_START, t0
                add a1, a0, a2                      #a2 has the end of input
                sw a1, INPUT_END, t0
                la t0, TOKENIZE_IMM
                sw s9, 0(t0)
                addi s9, s9, -4
        		    tail NEXT

                CODEHEADER OK, GETNEXTLINE_IMM, 0x01
                la a0, Ok_msg
                call puts
                la t0, TYPE
                sw s9, 0(t0)
                addi s9, s9, -4
                la t0, GETNEXTLINE_IMM
                sw s9, 0(t0)
                addi s9, s9, -4
                tail NEXT

                CODEHEADER NOTOK, OK, 0x01
                la a0, Error_msg
                call puts
                la t0, TYPE
                sw s9, 0(t0)
                addi s9, s9, -4
                la t0, GETNEXTLINE_IMM
                sw s9, 0(t0)
                addi s9, s9, -4
                tail NEXT


                CODEHEADER TOKENIZE_IMM, NOTOK, 0x01       
                #puts 1 on stack if system variables
                #TOKEN_START and TOKEN_END hold valid values
                lw a1, INPUT_END
                lw a0, INPUT_START
                bltu a0, a1, tokenize_have_data     #buffer has data
  tokenize_all_over:
                la t0, OK                           #we are done
                sw s9, 0(t0)
                tail NEXT
  tokenize_have_data:
                mv t0, a0                           #t0 tracks start of token, t1 the end
                mv t1, zero
                ori t2, t0, 0x20                    #t2 space
                ori t3, t0, 0x0A                    #t3 CR
  tokenize_look_for_start:
                lw t4, 0(t0)
                beq t4, t2, tokenize_keep_going
                bne t4, t3, tokenize_found_start
                j tokenize_all_over
  tokenize_keep_going:
                addi t0, t0, 1
                bltu t0, a1, tokenize_look_for_start
                j tokenize_all_over                 #got nothing
  tokenize_found_start:
                mv t1, t0
  tokenize_advance_search:
                addi t1, t1, 1
                bltu t1, a1, tokenize_end_token
                lw t4, 0(t1)
                beq t4, t2, tokenize_end_token
                beq t4, t3, tokenize_end_token
                j tokenize_advance_search
  tokenize_end_token:
                sw t1, INPUT_START, t5              #update the end point for subsequent searches
                mv t2, t0
                addi t5, zero, 0x61                 #lowercase a
                addi t6, zero, 0x7A                 #lowercase z
  tokenize_sanity_test:
                lb t4, 0(t2)
                blt t4, t5, tokenize_next_sane
                blt t4, t6, tokenize_sanitize
                j tokenize_next_sane
  tokenize_sanitize:
                addi t3, zero, 0x20
                xor t4, t4, t3
                sb t4, 0(t2)
  tokenize_next_sane:
                addi t2, t2, 1
                beq t2, t1, tokenize_finished_sanitization
                j tokenize_sanity_test
  tokenize_finished_sanitization:
                addi t1, t1, -1                   #prepare for next round
                sw t0, TOKEN_START, t2
                sw t1, TOKEN_END, t2
                la t0, SEARCH
                sw s9, 0(t0)                      #search as next command
                addi s9, s9, -4
                li t2, 1
                PUSH t2                           #indicate TOKEN_ values are valid
                tail NEXT

		            CODEHEADER SEARCH, TOKENIZE_IMM, 0x01
                POP a0
                beq a0, zero, search_no_token     
                addi t0, zero, 1
                bne a0, t0, search_bad_pop
                sw t0, TOKEN_START, t1            #token values are valid
                sw t1, TOKEN_END, t2
                j search_continue
  search_no_token:
                la t0, NOTOK                      #should never get here - so warn if we do
                sw s9, 0(t0)
                addi s9, s9, -4
                tail NEXT
  search_bad_pop:
                la t0, NOTOK
                sw s9, 0(t0)
                addi s9, s9, -4
                PUSH a0                           #restore bad POP
                PUSH t0
                tail NEXT
  search_continue:
                sub t2, t1, t0
                addi t2, t2, 1                    #t2 has length of token
                la t3, dictionary
  search_next_in_dictionary:
                lb t4, 12(t3)
                bne t4, t2, search_tokens_do_not_match
                add a0, t3, 16                    #a0 now points into the name in the dictionary
                mv a1, t0                         #a1 points to the name in the buffer
                mv a2, t2                         #a2 checks how far we've gone 

  search_loop_through_token:
                lb t5, 0(a0)
                lb t6, 0(a1)
                bne t5, t6, search_tokens_do_not_match
                add a2, a2, -1
                beq a2, zero, search_tokens_matched
                addi a0, a0, 1
                addi a1, a1, 1
                j search_loop_through_token
                
  search_tokens_do_not_match:
                lw t3, 8(t3)                      #read the pointer to the next TIL command
                beq t3, zero, search_exhausted    #at the end of the dictionary
                j search_next_in_dictionary

  search_tokens_matched:
                lw t3, 4(t3)
                sw s9, 0(t3)                      #store word address on the call stack
                tail NEXT

  search_exhausted:
                nop                                  #TODO: Code to handle literals
                lw t2, CURRENT_BASE
                li t3, 16
                beq t2, t3, search_check_hex
                li t3, 8
                bne t2, t3, search_assume_decimal
                j search_check_octal              #go to octal code
  search_assume_decimal:
                j search_setup_decimal
                nop
  search_check_octal:
                li t2, 8
                li t5, 48
                li t6, 55
                j search_octal_decimal_join
  search_setup_decimal:
                li t2, 10                         #assume we are decimal - trust but verify
                li t5, 48                         #ascii 0
                li t6, 57
  search_octal_decimal_join:
                sub t3, t1, t0
                mv a7, t4
                mul t4, t3, t2
                beq t4, zero, search_increment_octdec
                j search_literal
  search_increment_octdec:
                li t4, 1                          #number has to have at least 1 digit
                j search_literal
  search_check_hex:
                                                  #must begin with 0X
                lb a0, 0(t0)
                li t5, 48
                beq a0, t5, search_test_X
                j search_failed
  search_test_X:
                lb a0, 1(t0)
                li t6, 88                         #X
                beq a0, t6, search_build_hex
                j search_failed
  search_build_hex:
                li t6, 57
                li a1, 65
                li a2, 71                         #G
                sub t3, t1, t0
                add t3, t3, -2
                mv a7, t4
                mul t4, t3, t2
                bne t4, zero, search_hex
                li t4, 1
  search_hex:
                mv a3, t0
                mv a4, zero                       #a4 holds value to push
                addi a3, a3, 2
                bgeu t1, a3, search_hex_continue
                j search_failed
  search_hex_continue:
                lb a5, 0(a3)
                bgeu a5, t5, search_check_9_less
                j search_failed
  search_check_9_less:
                bltu a5, t6, search_hex_stackup_num
                beq a5, t6, search_hex_stackup_num
                bltu a5, a2, search_hex_check_A
                j search_failed
  search_hex_check_A:
                bgeu a5, a1, search_hex_stackup_alpha
                j search_failed
  search_hex_stackup_num:
                addi a5, a5, -48                    #map 0 -> 0
                mul a5, a5, t4
                j search_hex_decrement
  search_hex_stackup_alpha:
                addi a5, a5, -55                    #map A -> 10
                mul a5, a5, t4
  search_hex_decrement:
                add a4, a4, a5
                add a7, a7, -1
                bne a7, zero, search_reset_hex_factor
                li t4, 1
                j search_next_hex_char
  search_reset_hex_factor:
                mul t4, a7, t2
  search_next_hex_char:
                addi a3, a3, 1
                blt t1, a3, search_hex_push_it
                j search_hex_continue
  search_hex_push_it:
                PUSH a4                         #save number on stack
                la t0, TOKENIZE_IMM             #keep tokenizing
                sw s9, 0(t0)
                tail NEXT
                nop
  search_literal:
                mv a3, t0
                mv a4, zero
  search_octdec_continue:
                lb a5, 0(a3)
                bgeu a5, t5, search_check_max_octdec
                j search_failed
  search_check_max_octdec:
                bltu a5, t6, search_octdec_stackup
                beq a5, t6, search_octdec_stackup
                j search_failed
  search_octdec_stackup:
                addi a5, a5, -48
                mul a5, a5, t4
                add a4, a4, a5
                add a7, a7, -1 
                bne a7, zero, search_reset_octdec_factor
                li t4, 1
                j search_next_octdec_char
  search_reset_octdec_factor:
                mul t4, a7, t2
  search_next_octdec_char:
                addi a3, a3, 1
                blt t1, a3, search_hex_push_it
                j search_octdec_continue

  search_failed:
                la t0, NotOk_msg
                addi t1, zero, 24 
                WRITESTRINGR t0, t1
                li a0, 1
                la t0, TOKEN_START
                lw a1, 0(t0)
                sub a2, t1, t0
                addi a2, a2, 1
                call write                          #output error message
                tail NEXT


                CODEHEADER DECIMAL, SEARCH
                addi t1, zero, 10
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER HEX, DECIMAL
                addi t1, zero, 16
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER OCTAL, HEX
                addi t1, zero, 8
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER BINARY, OCTAL
                addi t1, zero, 2
                sw t1, CURRENT_BASE, t0
                tail NEXT

                CODEHEADER DOT, BINARY
                lw t0, CURRENT_BASE
                POP a2                            #get item on stack
                la a0, SCRATCH_PAD
                beq t0, t1, ps_format_hex
                addi t1, zero, 8
                beq t0, t1, ps_format_octal
                addi t1, zero, 2
                beq t0, t1, ps_format_binary
                la a1, hexout
                j dot_output
  ps_format_hex:
                la a1, hexout
                j dot_output
  ps_format_octal:
                la a1, octalout
                j dot_output
  ps_format_binary:
                la a1, hexout                   #no binary for now
  dot_output:
                addi a3, zero, 3
                call sprintf
                la t0, SCRATCH_PAD
                mv t1, a0
                WRITESTRINGR t0, t1
                tail NEXT

                CODEHEADER 1, DOT
                addi t0, zero, 1
                PUSH t0
                tail NEXT


.include "integer.S"


#Update this to point to the last (first) entry
          
