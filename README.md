Create an assembly-based FORTH for RISC-V SBCs
Licensed under GPL v2

Riscyforth is compiled and tested on the RVBoards Nezha 64-bit single board Risc-V computer (running Debian Linux with GNU Libc). Other boards will be added as they become
available. It also runs on Fedora for RISC-V under QEMU.

To understand your rights and obligations with this code please read (version 2 of) the GNU General Public Licence. Contributions and suggestions are welcome.

Riscyforth is still under heavy development and on this page I aim to keep a list of the implemented functions. You'll need to read the code to see the details though.

**LOAD**		    Load (and execute) - use like load /path/to/file

**BYE**                     Quit Riscyforth

**WORDLIST**                Output (public) keywords

**VARIABLE**                ( - ) Put a variable on the variable stack, initially valued as 0

**CONSTANT**		    (u - ) Put a constant on the constant stack, valued as u. NB: a variable and a constant sharing a name will always return the variable.

**ABORT**		    End Forth program - also **ABORT"** (expanded to ABORTCOMM) - abort with message

**EXECUTE**		    Execute the code the word address of which is top of the stack

**TICK**		    Find the word address of the word that follows (**'** expanded to TICK)

**DEPTH**		    ( - n) Report the depth of the stack _before_ n added

_Compiling code_

**COLON**		    Enter compiler mode (: is recognised and explanded to COLON)

**SEMI**                    Procedure to end all secondaries (; is recognised and expanded to SEMI) - DO NOT USE outside a compilation

**EXIT**		    In compiled code will cause an immediate jump to SEMI, returning control to the upper primative/secondary

_Memory_

**EXCLAIM**		    (xa -- ) store x at address a - **!** is recognised and expanded to EXCLAIM

**CSTORE**		    (xa --)  store x (single byte) at address a -  **C!** is expanded to CSTORE

**CFETCH**		    (a - c) store c (single byte) read at address a on stack - **C@** is expanded to CFETCH

**BASE**		    (  - a) returns address a of where current base is stored

**FETCH**		    (a   u) returns contents stored at address a (**@** is expanded to FETCH)

**PLUSSTORE**		    (xa -) add x to the value stored at address a (**+!** is expanded to PLUSSTORE)

**PAD**			    ( - a) return address of transient buffer (scratchpad)

**FILL**		    (auc - ) If u != 0 fill u bytes with character c from address a onwards

**ERASE**		    (au - ) If u != 0 fill u bytes with 0 from address a onwards

_Text entry_

**GETSTDIN**                Gets the file pointer for stdin

**TYPEPROMPT**              Gets a > prompt

**GETNEXTLINE_IMM**         Fetch a line for immediate execution

**GETLINE**		    Fetch a line of text, not for processing - (uu-uuab) a is address, b length

**DROPINPUT**		    Halts any further processing on input line

**OK**                      Output OK (or error) message

**TOKENIZE_IMM**            Gets the next valid token from input and executes

**CHAR**		    (ccc"String" u) Places the ascii code of the first character of "String" on top of the stack, ignoring leading spaces ccc

**SEARCH**                  Searches the dictionary to match the token

_Output_

**DOT**                     Output top of stack (. is recognised and expanded to DOT)

**SPACES**		    Output as many spaces as indicated by the number at the top of the stack

**SPACE**		    Output a single space.

**EMIT**		    Output the single character corresponding to the ASCII code of the number at the top of the stack

**CR**			    Output a carriage return (newline)

**ENCSQ**		    Output a string (use via ." _STRING_ " )

**DISPLAY**		    Will output characters from the stack (stops when reaching character value >=128)

**TIB**			    Return the address of the terminal input buffer on the stack

**TYPE**		    (ab --) Outputs string of length b at address a

**SOURCE**		    (-- ab) Puts the address a and length b of the input buffer on the stack

_Integer arithmetic_

**DECIMAL**                 Sets input/output to decimal

**HEX**                     Sets input/out to hex

**OCTAL**                   Sets input/output to octal

**BINARY**                  Sets output to binary (input yet to be implemented)

**RSHIFT**		    (au  x) shift a u bits to the right, storing x on stack

**LSHIFT**		    (au  x) shift a u bits to the left, storing x on stack

**OLSEMI**                  Internal procedure - don't use

**ADD**                     Add the numbers at the top iof the stack (+ is recognised and expanded to ADD)

**MUL**                     Multiply the same (* is recognised and expanded to MUL)

**SQUARE**		    Square the number at the top of the stack

**CUBE**		    Cube the number at the top of the stack

**DIV**                     Divide the top of the stack by the next to top (/ is recognised and expanded to DIV)

**SUB**                     Subtract the second item on the stack from the first (- is recognised and expanded to SUB)

**PLUS1**                   Increment the top of the stack by 1 - 1+ is recognised and expanded to PLUS1

**MINUS1**                  Decrement the top of the stack by 1 - 1- is recognised and expanded to MINUS1

**PLUS2**                   Increment the top of the stack by 2 - 2+ is recognised and expanded to PLUS2

**MINUS2**                  Decrement the top of the stack by 2 - 2- is recognised and expanded to MINUS2

**UNDERPLUS**               Add the top of the stack to the third item in the stack

**MOD**                     Get the second item in the stack modulo the top item

**SLMOD**               Divide the second item in the stack by the first and then store the remainder and the quotient (quotient at the top of the stack) **/MOD** is recognised and expanded to SLMOD

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

**TOR**			    Pop top of the (data) stack and place on top of the return stack (**>R** is expanded to this)

**RFETCH**		    Copy the top of the return stack to the data stack (**R@** is expanded to this)

**RDROP**                   Drop the top of the return stack

**RFROM**                   Move the top of the return stack to the top of the data stack (**R>** is expanded to this)

_Logic_

**AND**			    (ab - u) Bitwise AND of a and b

**OR**			    (ab - u) Bitwise OR of a and b

**XOR**			    (ab - u) Bitwise XOR of a and b

**INVERT**	            (u - u') Replaces u with logical (bitwise) inversion u'

**EQUALS**	 	    (ab - u) Returns -1 (all bits set)  top two stack entries are equal, zero otherwise, = is recognised and expanded to this (consumes entries)

**TRUE**		    ( - u) Places -1 (all bits set) on top of stack

**FALSE**		    ( - u) Places 0 (no bits set) on top of stack

**GT**			    (ab - u) Places -1 on stack if a > b, otherwise places 0 on stack, > is recognised and explanded to this

**LT**			    (ab - u) Places -1 on stack if a < b, otherwise places 0 on stack, < is recognised and expanded to this

_Conditionals_

_Note: conditional code's outcome is undefined for immediate execution_

**IF**			    (a - )Execute what follows if a is non-zero

**ELSE**		    ( - ) Alternative path of execution to **IF**, if the top of the stack is zero

**THEN**		    ( - ) Code path taken once either **IF** and **ELSE** completed - **IF** must be followed by **THEN** though **ELSE** is optional

_Looping_

**BEGIN**		    ( - ) Mark the start of a simple BEGIN ... END loop (may be nested)

**END**			    (a - ) Mark the end of a simple BEGIN ... END loop (NB: BEGIN and END are effectively nops for immediate mode)

**WHILE**		    Unconditionally returns to BEGIN in BEGIN ... IF ...(ELSE) .... WHILE (replacing THEN)

**DO**			    (lc - ) Start a loop with c as the current index value and l the limit

**LOOP**		    End of a DO loop

**PLUSLOOP**		    (i - ) End of a DO loop, with index incremented by i (**+LOOP** is expanded to PLUSLOOP)

**UNLOOP**		    ( - ) Remove loop variables from the loop stack

**LEAVE**		    ( - ) Immediately leave current loop (UNLOOP should be called first)

**I**			    ( - u) Return the value of the inner-most loop variable from loop stack

**J**			    ( - u) Return the value of the outer loop variable from loop stack
