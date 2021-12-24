

		CODEHEADER TRUE, COLON, 0x01
		addi sp, sp, -8
		j gt_true

		CODEHEADERZ GT, >, TRUE, 0x01
		ld t1, 0(sp)
		ld t0, 8(sp)
		addi sp, sp, 8
  gt_test:
		bgt t0, t1, gt_true
  gt_false:
		sd zero, 0(sp)
		tail NEXT
  gt_true:	
		li t0, -1
		sd t0, 0(sp)
		tail NEXT

		CODEHEADER LTEQ, GT, 0x01
		#non-standard less than or equal
		#(n n -- f)
		ld t0, 0(sp)
		ld t1, 8(sp)
  lteq_as_gteq:
		addi sp, sp, 8
		ble t1, t0, gt_true
		j gt_false

		CODEHEADER GTEQ, LTEQ, 0x01
		#non-standard greater than or equal
		#(n n -- f)
		ld t1, 0(sp)
		ld t0, 8(sp)
		j lteq_as_gteq

		CODEHEADERZ NE, <>, GTEQ, 0x01
		# (n n -- flag)
		ld t0, 0(sp)
		ld t1, 8(sp)
		beq t0, t1, ne_ne
		li t0, -1
		sd t0, 8(sp)
		addi sp, sp, 8
		tail NEXT
  ne_ne:
		sd zero, 8(sp)
		addi sp, sp, 8
		tail NEXT

		CODEHEADERZ LT, <, NE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
		j gt_test

		CODEHEADER FALSE, LT, 0x01
		addi sp, sp, -8
		j gt_false

		CODEHEADER EQUAL, FALSE, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		addi sp, sp, 8
		bne t0, t1, gt_false
		j gt_true

		CODEHEADER AND, EQUAL, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		and t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT

		CODEHEADER OR, AND, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		or t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT
		
		CODEHEADER XOR, OR, 0x01
		ld t0, 0(sp)
		ld t1, 8(sp)
		xor t3, t0, t1
		sd t3, 8(sp)
		addi sp, sp, 8
		tail NEXT

		CODEHEADER INVERT, XOR, 0x01
		ld t0, 0(sp)
		not t1, t0
		sd t1, 0(sp)
		tail NEXT

		#IF for compiled code
		CODEHEADER _IF, INVERT, 0x00
		ld t1, 0(sp)
		addi sp, sp, 8
		beqz t1, _if_handle_false
		#In TRUE lane
		#so execute next words
		addi s7, s7, 16
		tail NEXT
  _if_handle_false:
		#FALSE lane
		ld t2, 0(s7)
		beqz t2, _if_handle_then
		#have an else clause
		mv s7, t2
		tail NEXT
  _if_handle_then:
		ld t2, 8(s7)
		beqz t2, _if_failure
		mv s7, t2
		tail NEXT
  _if_failure:
		#no THEN created
		print badif
		tail NEXT		
		
		CODEHEADER IF, _IF, 0x01
		#just a place holder in immediate mode
		tail NEXT

		CODEHEADER THEN, IF, 0x01
		tail NEXT

		#ELSE for compiled code
		CODEHEADER _ELSE, THEN, 0x0
		#only get here if we were executing TRUE path
		ld t1, 0(s7)
		beqz t1, _else_failure
		mv s7, t1
		tail NEXT
  _else_failure:
		tail trackback_failed_else
		

		CODEHEADER ELSE, _ELSE, 0x01
		tail NEXT

