

		CODEHEADER TRUE, COLON, 0x01
		j gt_true

		CODEHEADER GT, TRUE, 0x01
		POP t1
		POP t0
  gt_test:
		bgt t0, t1, gt_true
  gt_false:
		PUSH zero
		tail NEXT
  gt_true:	
		li t0, -1
		PUSH t0
		tail NEXT

		CODEHEADER LT, GT, 0x01
		POP t0
		POP t1
		j gt_test

		CODEHEADER FALSE, LT, 0x01
		j gt_false

		CODEHEADER EQUALS, FALSE, 0x01
		POP t0
		POP t1
		bne t0, t1, gt_false
		j gt_true
		


		CODEHEADER IF, EQUALS, 0x01
		#evaluate head of stack
		#if matches then execute following THEN
		#otherwise look for ELSE
		POP t0
			
