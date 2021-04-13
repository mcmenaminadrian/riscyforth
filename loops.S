

		CODEHEADER EMIT, VARIABLE, 0x01
		POP a1
		addi a0, zero, 1
		PUSH a1
		mv a1, sp
		add a2, zero, 1
		call write
		POP zero
		tail NEXT

		CODEHEADER CR, EMIT, 0x01
		WRITECR
		WRITECHAR 0x0A
		tail NEXT


		CODEHEADER SPACES, CR, 0x01
		POP a0		#how many spaces
		PUSH s0
		mv s0, a0
  spaces_go:
		beq s0, zero,  spaces_done
		WRITECHAR 0x20
		addi s0, s0, -1
		j spaces_go
  spaces_done:
		POP s0		#honour ABI
		tail NEXT

		
