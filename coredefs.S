# Copyright Adrian McMenamin, 2021
# Resuse licensed under version 2 of the GNU GPL
# Words from the Forth standard core not defined somewhere else

		CODEHEADER ABORTCOMM, LOAD, 0x01
		#display comment and abort
		#copy ENCSQ code and replace tail NEXT with tail EXIT
		tail EXIT

		

		CODEHEADER ABORT, ABORTCOMM, 0x01
		tail EXIT


