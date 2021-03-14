Create a FORTH-like language for RISC-V
Licensed under GPL v2

Currently RISCYFORTH targets the pk kernel emulator that runs on top of Spike. When I get a real RISC-V computer it will focus on that instead.

To understand your rights and obligations with this code please read (version 2 of) the GNU General Public Licence. Contributions and suggestions are welcome.

We are in the development stage of RISCYFORTH and on this page I aim to keep a list of the implemented functions. You'll need to read the code to see the details though.

**DOT**                     Output top of stack

**BYE**                     Quit RISCYFORTH

**WORDLIST**                Output (public) keywords


_Text entry_

**GETSTDIN**                Gets the file pointer for stdin

**TYPE**                    Gets a > prompt

**GETNEXTLINE_IMM**         Fetch a line for immediate execution

**OK**                      Output OK (or error) message

**TOKENIZE_IMM**            Gets the next valid token from input

**SEARCH**                  Searches the dictionary to match the token


_Integer arithmetic_

**DECIMAL**                 Sets input/output to decimal

**HEX**                     Sets input/out to hex

**OCTAL**                   Sets input/output to octal

**BINARY**                  Sets output to binary (input yet to be implemented)

**OLSEMI**                  Internal procedure - don't use

**SEMI**                    Procedure to end all secondaries

**ADD**                     Add the numbers at the top iof the stack

**MUL**                     Multiply the same

**DIV**                     Divide the top of the stack by the next to top

**SUB**                     Subtract the second item on the stack from the first

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

