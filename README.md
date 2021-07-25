Create a FORTH-like language for RISC-V
Licensed under GPL v2

Riscyforth is compiled and tested on the RVBoards Nezha 64-bit single board Risc-V computer (running Debian Linux with GNU Libc). Other boards will be added as they become
available.

To understand your rights and obligations with this code please read (version 2 of) the GNU General Public Licence. Contributions and suggestions are welcome.

We are in the development stage of RISCYFORTH and on this page I aim to keep a list of the implemented functions. You'll need to read the code to see the details though.

**LOAD**		    Load (and execute) - use like load /path/to/file

**BYE**                     Quit RISCYFORTH

**WORDLIST**                Output (public) keywords

**VARIABLE**                Put a variable on the variable stack

_Compiling code_

**COLON**		    Enter compiler mode (: is recognised and explanded to COLON)

**SEMI**                    Procedure to end all secondaries (; is recognised and expanded to SEMI) - DO NOT USE outside a compilation

_Text entry_

**GETSTDIN**                Gets the file pointer for stdin

**TYPEPROMPT**              Gets a > prompt

**GETNEXTLINE_IMM**         Fetch a line for immediate execution

**GETLINE**		    Fetch a line of text, not for processing - (uu-uuab) a is address, b length

**DROPINPUT**		    Halts any further processing on input line

**OK**                      Output OK (or error) message

**TOKENIZE_IMM**            Gets the next valid token from input and executes

**SEARCH**                  Searches the dictionary to match the token

_Output_

**DOT**                     Output top of stack (. is recognised and expanded to DOT)

**SPACES**		    Output as many spaces as indicated by the number at the top of the stack

**SPACE**		    Output a single space.

**EMIT**		    Output the single character corresponding to the ASCII code of the number at the top of the stack

**CR**			    Output a carriage return (newline)

**ENCSQ**		    Output a string (use via [ _STRING_ ] )

**DISPLAY**		    Will output characters from the stack (stops when reaching character value >=128)

**TIB**			    Return the address of the terminal input buffer on the stack

**TYPE**		    (uuab-uu) Outputs string of length b at address a

_Integer arithmetic_

**DECIMAL**                 Sets input/output to decimal

**HEX**                     Sets input/out to hex

**OCTAL**                   Sets input/output to octal

**BINARY**                  Sets output to binary (input yet to be implemented)

**OLSEMI**                  Internal procedure - don't use

**ADD**                     Add the numbers at the top iof the stack (+ is recognised and expanded to ADD)

**MUL**                     Multiply the same (* is recognised and expanded to MUL)

**SQUARE**		    Square the number at the top of the stack

**CUBE**		    Cube the number at the top of the stack

**DIV**                     Divide the top of the stack by the next to top (/ is recognised and expanded to DIV)

**SUB**                     Subtract the second item on the stack from the first (- is recognised and expanded to SUB)

**PLUS1**                   Increment the top of the stack by 1

**MINUS1**                  Decrement the top of the stack by 1

**UNDERPLUS**               Add the top of the stack to the third item in the stack

**MOD**                     Get the second item in the stack modulo the top item

**SLASH_MOD**               Divide the second item in the stack by the first and then store the remainder and the quotient (quotient at the top of the stack)

**NEGATE**                  Negate the top of the stack

**ABS**                     Get the absolute value of the top of the stack

**MIN**                     Get the minimum of the top two items on the stack

**MAX**                     Get the maximum of the same


_Stack operations are show in diagrammatic form (before -> after). Top of the stack is to the right_

**SWAP**                    s1 s0 -> s0 s1

**ROT**                     s2 s1 s0 -> s1 s0 s2

**BACKROT**                 s2 s1 s0 -> s0 s2 s1

**DROP**                    s1 s0 -> s1

**NIP**                     s1 s0 -> s0

**OVER**                    s1 s0 -> s1 s0 s1

**TUCK**                    s1 s0 -> s0 s1 s0

**PICK**                    su...s1s0[Number = u] -> su...s1su

**ROLL**                    su su-1 ... s1 s0[Number = u] -> su-1 .... s1 su

**DROP2**                   s2 s1 s0 -> s2 (currently implemented as a secondary to test mechanism)

**NIP2**                    s3 s2 s1 s0 -> s1 s0

**DUP**                     s0 -> s0 s0

**DUP2**                    s1 s0 -> s1 s0 s1 s0

**OVER2**                   s3 s2 s1 s0 -> s3 s2 s1 s0 s3 s2

**TUCK2**                   s3 s2 s1 s0 -> s1 s0 s3 s2 s1 s0

**SWAP2**                   s3 s2 s1 s0 -> s1 s0 s3 s2

**ROT2**                    s5 s4 s3 s2 s1 s0 -> s3 s2 s1 s0 s5 s4 (NB executing ROT twice would give us s5 s4 s3 s0 s2 s1)

_Return stack operations_

**LTR**			    Pop top of the (data) stack and place on top of the return stack (<R in traditional FORTH)

**RGT**			    Pop top of the return stack and place on top of the (data) stack (R> in traditional FORTH)

_Logic_

**AND**			    Bitwise AND of top two stack entries (cosumes stack)

**OR**			    Bitwise OR of top two stack entries (consumes stack)

**XOR**			    Bitwise XOR of top two stack entries (consumes stack)

**NOT**			    Replaces top of stack with logical inversion

**EQUALS**	 	    Returns -1 (all bits set)  top two stack entries are equal, zero otherwise, = is recognised and expanded to this (consumes entries)

**TRUE**		    Places -1 (all bits set) on top of stack

**FALSE**		    Places 0 (no bits set) on top of stack

**GT**			    Places -1 on stack if s1 > s0, otherwise places 0 on stack, > is recognised and explanded to this (consumes stack)

**LT**			    Places -1 on stack if s1 < s0, otherwise places 0 on stack, < is recognised and expanded to this (consumes stack)

_Conditionals_

_Note: conditional code's outcome is undefined for immediate execution_

**IF**			    Execute what follows if the top of the stack is non-zero (consumes top of stack)

**ELSE**		    Alternative path of execution to **IF**, if the top of the stack is zero (consumes top of stack)

**THEN**		    Code path taken once either **IF** and **ELSE** completed - **IF** must be followed by **THEN** though **ELSE** is optional

_Looping_

**BEGIN**		    Mark the start of a simple BEGIN ... END loop (may be nested)

**END**			    Mark the end of a simple BEGIN ... END loop (NB: BEGIN and END are effectively nops for immediate mode)

**WHILE**		    Unconditionally returns to BEGIN in BEGIN ... IF ...(ELSE) .... WHILE (replacing THEN)

