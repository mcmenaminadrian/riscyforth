
		CODEHEADER DO, VARIABLE, 0x00
		POP a1		#index
		POP a0		#limit
		PUSH s0		#previous limit?
		PUSH s1		#previous index?
		mv s0, a0
		mv s1, a1

		CODEHEADER SPACES, DO, 0x01
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

		
