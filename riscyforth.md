% RISCYFORTH
% Adrian McMenamin
% January 2022

# NAME

riscyforth - Forth for RISC-V SBCs

# SYNOPSIS

**riscyforth**

# DESCRIPTION

**riscyforth** is a 64-bit Forth for RISC-V single board computers. It is
written in RISC-V assembly and is free software with modification and
distribution (including of this man file) covered by version 2 of the GNU
General Public Licence (which should be found in every distribution of
**riscyforth**).

The most up-to-date version of **riscyforth** can be found at
https://github.com/mcmenaminadrian/riscyforth

Staring **riscyforth** will invoke a terminal interface and programs may be 
loaded or written directly. Persistent programs need to be written in an
editor and loaded into a running instance of **riscyforth**.

This man file describes the words natively supported by **riscyforth**. Like
all Forths **riscyforth** may be extended through *colon words* written in
Forth itself.

**riscyforth** aims to support the Forth 2012 standard but not all words here
are part of the standard and not all the standard is (currently) supported.

It should be noted that **riscyforth** is a 64 bit Forth - i.e., cells are 8
bytes wide by default.

**riscyforth** is copyright (c) Adrian McMenamin, 2020 - 2022.

# FORTH WORDS

An alphabetical list of Forth words implemented on **riscyforth** follows. A
word in the Forth 2012 Core which is not yet implemented (and may never be) is
also noted for the convenience of those porting code.

**ABORT** Quit without displaying a message

**ABORT"** (x --) if *x* is non-zero quit displaying a message
e.g., *1 ABORT" Display this message on quitting"*

**ABS** (n -- u) Place the absolute value of *n* on the stack

**ACCEPT** (addr n1 -- n2) Store at most *n1* characters in buffer at address
*addr*, *n2* is the actual number of characters stored

**ACTION-OF** (-- xt) At run time returns the execution token *xt* for the
deferred word eg., to use *ACTION-OF TESTDEFER*

**AGAIN** Return to the code block marked by *BEGIN*

**ALIGN** (--) If required (8-byte) align the data space pointer

**ALIGNED** (a1 -- a2) *a2* is the first aligned address greater than or equal
to *a1*

**ALLOCATE** (u -- addr ior) allocate *u* bytes at address *addr*

**ALLOT** (n --) move the data space pointer by *n* bytes

**AND** (x1 x2 -- x3) *x3* is the bitwise logical *AND* of *x1* with *x2*

**BASE** (-- a) *a* is the address of the current number conversion radix
(number base)

**BBLACK** Set terminal background to black

**BBLUE** Set terminal background to blue

**BCYAN** Set terminal background to cyan

**BEGIN** Begins a loop code block

**BGREEN** Sets terminal background to green

**BINARY** Set the radix (base) to two

**BL** (-- c) Places the value 0x20 (ascii 32 - space) on the stack

**BLACK** Set terminal foreground to black

**BLUE** Set terminal foreground to blue

**BMAGENTA** Set terminal background to magenta

**BRED** Set terminal background to red

**BRIGHT** Set terminal output to bright

**BUFFER:** (-- a) Creates a buffer that returns address *a* e.g.,
*80 BUFFER: TESTBUF* creates the buffer *TESTBUF* of length 80 bytes

**BWHITE** Set terminal background to white

**BYE** Leave **riscyforth**

**BYELLOW** Set terminal background to yellow

**[** At compile time the contents of *[ ]* are immediately evaluated

**[CHAR]** ("spaces\<name\>" --) At runtime: (-- char) Places value of first
character in *name* on stack as *char*

**[COMPILE]** NOT IMPLEMENTED: Word is obsolescent in Forth 2012. Use 
*POSTPONE* instead.

**[']** ("spaces"\<name\>" --) At runtime: (-- xt) Please use *'* instead
(*[']* has the same functionality)

**CASE** Mark the start of *CASE .. OF .. ENDOF .. ENDCASE* control structure

**C,** (c --) Advance data space pointer by 1 and store *c* in data space

**CELL+** (a1 -- a2) add a cell size (8 bytes) to *a1* and store sum *a2* on
the stack

**CELLS** (n1 -- n2) store the size, *n2* of *n1* cells on the stack

**C@** (c-addr -- char) Fetch the character stored at *c-addr* and store
on the stack as *char*

**CHAR** ("name" -- char) Put the first character of the string *name* on
the stack as *char*

**CHAR+** (caddr1 -- caddr2) Add character size (1) to address *caddr1* and
store result on stack in *caddr2*

**CHARS** (n1 -- n2) *n2* is the size in address units of *n1* (this is a NOP)

**COMPILE,** (xt --) At compile time *xt* is compiled in (replacing *COMPILE,*)

**CONSTANT** Create a word that returns a constant value to the stack e.g.,
*25 FIVESQUARED CONSTANT* creates the constant *FIVESQUARED* that will always
return 25 on the stack

**COUNT** (c-addr1 -- c-addr2 u) Return character count and text address for
counted string 

**CR** (--) output a newline

**CREATE** Create a word that returns a constant pointer to the data space
e.g., *CREATE TEST* creates the word *TEST* that returns the value of the
data space pointer at the time of creation.

**C!** (char caddr --) Stores character *char* at *caddr*

**CYAN** Set termainal foreground to cyan

**:** Begin a *colon word* definition

**:NONAME** (-- xt) Create a *colon-word* and place execution token *xt*
on stack

**,** (x --) Advance data space pointer by one cell and store *x* in the cell

**C"** (-- c-addr) on execution, ("ccc<quote>" --) on compilation. Return
counted string at address *c-addr* - compiled code only. Does nothing
in intrepreted code.

**CRESET** (mask addr --) Turn bits off at *addr* using 8-bit *mask*

**CSET** (mask addr --) Set bits at *addr* using 8-bit *mask*

**CTOGGLE** (mask addr --) Toggle bits at *addr* using 8-bit *mask*

**CUBE** (x1 -- x2) Cube *x1* and store in *x2*

**DECIMAL** Set radix (base) to ten

**DEFER** Defer execution of created word to another word
e.g., *DEFER TEST* creates a word *TEST* that we can later assign execution
characteristics to (see e.g., *DEFER@*)

**DEFER@** (x1 -- x2) Reports that execution token *x1* is set to *x2* e.g.,
*EMIT IS TESTDEFER ' TESTDEFER DEFER@ ' EMIT =* will return *TRUE* if a call
to *TESTDEFER* executes *EMIT*

**DEFER!** (x2 x1 --) will set execution token *x1* to *x2* e.g.,
*' EMIT ' TESTDEFER DEFER!* will set *TESTDEFER* to execute *EMIT*

**DEPTH** (-- n) Reports depth of stack

**DISPLAY** (x..x -- x..x) will display zero terminated string built from stack

**DO** Begins *LOOP* block in form:
*limit first DO ... LOOP* (or *+LOOP* or *-LOOP*)

**DOES>** Assigns execution body to word created in data space e.g.,
*: INDEXED-ARRAY CREATE CELLS ALLOT DOES> SWAP CELLS + ;* creates an
indexed array type

**DROP** (x --)

**DUP** (x -- x x)

**/** (n1 n2 -- n3) Divide *n1* by *n2* and store the result on the stack as
 *n3*

**/MOD** (n1 n2 -- n3 n4) Divide *n1* by *n2*, storing the remainder *n3* and
the quotient *n4* on the stack

**.R** (n1 n2 --) Display *n1* right flushed in a field of width *n2*

**.S** Debug word that displays contents of stack

**.(** ("ccc<paren>" --) Parse and display ccc - immediate word

**."** Output the enclosed string e.g. *." Output this"*

**DROPINPUT** Discard rest of input line

**ELSE** *ELSE* clause in *IF .. ELSE .. THEN*

**EMIT** (x --) Output character of value *x*

**ENDCASE** Mark the end of *CASE .. OF .. ENDOF .. ENDCASE* control structure

**ENDOF** Mark the end of *OF .. ENDOF* clause in *CASE .. ENDCASE* control
structure

**ENVIRONMENT?** (addr u -- false | i * x true) Query the local environment.
*addr* and *u* are the address and length of a query string. Returns false
if query is not supported, otherwise an answer based on the query.
Currently supported query words: /COUNTED-STRING /HOLD /PAD
ADDRESS-UNIT-BITS FLOORED MAX-CHAR MAX-D MAX-N MAX-U MAX-UD RETURN-STACK-CELLS
STACK-CELLS

**ERASE** (addr u --) if *u* greater than zero, clear (set to zero) *u* bytes
from address *addr*

**EVALUATE** ( i * x c-addr u -- j * x ) Interpret the string at *c-addr*

**EXECUTE** (xt -- ?) Remove *xt* from stack and execute it

**EXIT** Leave an *IF .. ELSE .. THEN* structure (care must be taken to 
*UNLOOP* if necessary)

**=** (x1 x2 -- flag) Set *flag* to *TRUE* (-1) if *x1 = x2* otherwise set
*flag* to *FALSE* (zero)

**FALSE** (-- 0) Zero indicating logical false

**FILL** (c-addr u char --) if *u* is greater than zero set *u* bytes from
*c-addr* onwards to *char*

**FIND** (c-addr -- caddr 0 | xt 1 | xt -1) Find the definition named in the
counted string at c-addr. If the definition is not found, return c-addr and
zero. If the definition is found, return its execution token xt. If the
definition is immediate, also return one (1), otherwise also return minus-one 
(-1).

**FM/MOD** (d n2 -- n1 n0) Floored division: divide *n2* by *d* and report
remainder in *n1* and floored quotient in *n0*

**@** (addr -- x) Fetch as *x* the contents of cell at *addr* and store on
the stack

**FREE** (addr -- ior) Free memort at *addr* (*ior* is zero on success)

**GETLINE** Fetch text input

**GREEN** Set terminal foreground to green

**HERE** (-- addr) Return the current value of the data space pointer

**HEX** Set the radix (base) to sixteen

**HOLD** (char --) Add *char* to the beginning of a pictured numeric output
string

**HOLDS** (caddr u --) Add counted string defined by *u* and *caddr* to the
start of pictured numeric output

**I** (-- n) Place the value of the current innermost loop counter on the stack

**IF** (x --) Begin *IF ... ELSE .. THEN* structure. *IF* clause is executed if
*x* is non-zero, otherwise *ELSE* clause (if present) is executed.

**IMMEDIATE** (--) Make the most recent definition an immediate word

**INCLUDE** Load file and immediately parse e.g.
*INCLUDE /home/foo/bar.fth* will load and evaluate *bar.fth*

**INVERT** (x1 -- x2) Invert all bits of *x1* and store on the stack as *x2*

**IS** (xt --) Set *name* to execute *xt* e.g.,
*' . IS TESTDEFER* will ensure *TESTDEFER* executes *.*

**J** (-- n) Place the value of the next-outer loop counter on the stack

**KEY** NOT YET IMPLEMENTED

**LEAVE** R:(n --) Immediately leave a loop discarding control parameters

**LITERAL** (-- x) Place *x* on the stack e.g. *[ x ] LITERAL*

**LOOP** Evaluate loop parameters and either terminate loop R:(x --) or
continue to execute loop R:(x1 -- x2)

**LSHIFT** (x1 u -- x2) left shift *x1* by *u* and store as *x2*

**MAGENTA** Set terminal foreground to magenta

**MARKER** NOT YET IMPLEMENTED

**MAX** (n1 n2 -- n3) *n3* is the greater of *n1* and *n2*

**MIN** (n1 n2 -- n3) *n3* is the lesser of *n1* and *n2*

**-LOOP** (n --) R:(x -- x1) Subtract *n* from *x* and check loop limits

**-ROT** (x2 x1 x0 -- x0 x2 x1)

**MOD** (n1 n2 -- n3) *n3* is the remainder of dividing *n1* by *n2*

**MOVE** (addr1 addr2 u --) if *u* is greater than zero copy *u* bytes from
*addr1* to *addr2*

**M\*** NOT YET IMPLEMENTED

**-** (n1 n2 -- n3) *n3* is the result of *n1* minus *n2*

**MS** (x --) Pause execution for *x* milliseconds

**NEGATE** (n1 -- n2) *n2* is the arithmetic inverse of *n1*

**NIP** (x1 x2 -- x2)

**OCTAL** Set radix (base) to eight

**OF** From *CASE ... OF ... ENDOF .. ENDCASE* structure

**OR** (x1 x2 -- x3) *x3* is bitwise inclusive or of *x1* with *x2*

**OVER** (x1 x2 -- x1 x2 x1)

**1-** (x1 -- x2) Subtract 1 from *x1* and store the result in *x2*

**1+** (x1 -- x2) Add 1 to *x1* and store the result in *x2*

**PAD** (-- addr) return the address of a transient scratch pad

**PAGE** Clear the terminal and set output to the top left

**PARSE-NAME** NOT YET IMPLEMENTED

**PARSE** NOT YET IMPLEMENTED

**PICK** (xu ... x1 x0 u -- x1 x0 xu)

**POSTPONE** ("\<spaces\>name" --) Compile in *name* even if *IMMEDIATE* -
in general append the compilation semantics of *name* to the current
colon definition.

**+** (n1 n2 -- n3) *n3* is the sum of *n1* and *n2*

**+LOOP** (n --) R:(x -- x1) Add *n* to *x* and check loop limits

**+!** (n addr --) add *n* to the value stored in the cell at *addr*

**?** (addr --) Output value stored at address *addr*

**QUIT** Leave the executing program

**RDROP** R:(x --)

**RECURSE** Re-execute the current word

**RED** Set terminal forground to red

**REFILL** NOT YET IMPLEMENTED

**REPEAT** End of a *BEGIN .. WHILE .. REPEAT* block

**RESET** Reset the terminal colours

**RESIZE** (addr1 u -- addr2 ior) Copy data at *addr1* to new area of
size *u* which will be found at *addr2*

**RESTORE-INPUT** NOT YET IMPLEMENTED

**R@** (--x) R:(x -- x) Copy x from the return stack to the (data) stack

**ROLL** (xu xu-1 .. x1 x0 u -- xu-1 .. x1 x0 xu)

**ROT** (x1 x2 x3 -- x2 x3 x1)

**RSHIFT** (x1 u -- x2) Logically right shift *x1* by *u* and store in *x2*

**R>** (--x) R:(x--) Move *x* from the return stack to the (data) stack

**SAVE-INPUT** NOT YET IMPLEMENTED

**SIGN** (n --) if *n* is negative add a minus sign to the beginning of the
pictured numeric output string

**SM/REM** (d n2 -- n1 n0) Symmetric division: divide *n2* by *d* and report
remainder in *n1* and symmetric quotient *n0*

**SOURCE-ID** NOT YET IMPLEMENTED

**SOURCE** (-- addr u) *addr* is the address of the input buffer and *u* the
number of caharcters it contains

**SPACE** Display one space

**SPACES** (x --) Display *x* spaces

**SQUARE** (x1 -- x2) Square *x1* and store in *x2*

**STATE** (-- addr) $addr$ is the address of a cell reporting the compilation
state

**SWAP** (x1 x2 -- x2 x1)

**;** Mark the end of a *colon word*

**S\\"** NOT YET IMPLEMENTED

**S"** (-- addr u) *addr* contains the address of, and *u* the length of,
the string defined in the inverted commas

**S>D** NOT YET IMPLEMENTED

**!** (x addr --) Store *x* at *addr*

**THEN** Final clause in all *IF...* structures, execution continues after
*THEN* once *IF* and *ELSE* clauses exhausted

**TIB** (-- addr) Returns address of input buffer

**TIME&DATE** (-- n1 n2 n3 n4 n5 n6) *n1* is wall clock second, *n2* minute, 
*n3* hour, *n4* day, *n5* month, *n6* year

**TO** (x --) Set a *VALUE* to *x*

**TRUE** (-- -1) Logical *TRUE* flag (-1)

**TUCK** (x2 x1 -- x1 x2 x1)

**TYPE** (addr u --) Display the character string of length *u* at address
*addr*

**TYPEPROMPT** Display *>*

**'** (-- xt) Get the execution token for the word named e.g., *' EMIT*

**\*** (n1 n2 -- n3) *n3* is the product of *n1* *n2*

**\*/** (n1 n2 n3 -- n4) *n4* is *n1* times *n2* divided by *n3*

**\*/MOD** (n1 n2 n3 -- n4 n5) *n4* is the remainder of *n1* times *n2*
divided by *n3* and *n5* is the quotient

**2DROP** (n1 n2 --)

**2DUP** (x1 x2 -- x1 x2 x1 x2)

**2/** (x1 -- x2) *x2* is x1 divided by 2

**2@** (addr -- x1 x2) Fetch the two cells at *addr* (stored in *x2*) and
*addr + 8* (stored in *x1*)

**2OVER** (x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2)

**2RDROP** R:(x1 x2 --)

**2R@** (-- x1 x2) R:(x1 x2 -- x1 x2) copy two top entries on the return stack
to the (data) stack

**2-** (x0 -- x1) Subtract 2 from *x0* and store in *x1*

**2NIP** (x4 x3 x2 x1 x0 -- x4 x1 x0)

**2+** (x0 -- x1) Add 2 to *x0* and store in *x1*

**2R>** (-- x1 x2) R:(x1 x2 --)  move top two entries on the return stack to
the (data) stack

**2ROT** (x5 x4 x3 x2 x1 x0 -- x3 x2 x1 x0 x5 x4)

**2SWAP** (x1 x2 x3 x4 -- x3 x4 x1 x2)

**2TUCK** (x3 x2 x1 x0 -- x1 x0 x3 x2 x1 x0)

**2!** (x1 x2 addr --) store *x2* at *addr* and *x1* at *addr + 8*

**2\*** (x1 -- x2) *x2* is *x1* times 2

**2>R** (x1 x2) R:(-- x1 x2) move the top two entries on the (data) stack to
the return stack

**U.R** NOT YET IMPLEMENTED

**UM/MOD** (ud u1 -- u2 u3) Divide *ud* by *u1* giving quotient *u3* and
remainder *u2* - all arithmetic is unsigned

**UM\*** (u1 u2 -- ud) Multipy *u1* by *u2* and store result in *ud* - all
arithmetic is unsigned

**+UNDER** (x2 x1 x0 -- x1 x3) *x3* is the sum of *x2* and *x0*

**UNLOOP** Discard the loop parameters for the current loop (before *EXIT*)

**UNTIL** (x --) if *x* is zero return to code block starting with *BEGIN*

**UNUSED** NOT YET IMPLEMENTED

**U.** (u --) display *u* as an unsigned number

**VALUE** A value is a word proxy for a number e.g.
*7 VALUE SEVEN* assigns 7 to the word *SEVEN*

**VARIABLE** A variable is word proxy for a memory address - 
accessed via *!* and *@*

**WHILE** (x --) if *x* is non-zero execute the code in a *WHILE .. REPEAT*
block

**WHITE** Set terminal foreground to white

**WITHIN** (x1 x2 x3 -- flag) *flag* returns *TRUE* if *x1* is between
*x2* and *x3*

**WORD** NOT YET IMPLEMENTED

**WORDS** Lists supported Forth words

**XOR** (x1 x2 -- x3) *x3* is the results of the exclusive-or of *x1* with *x2*

**YELLOW** Set terminal foreground to yellow

**0=** (x -- flag) *flag* is *TRUE* if *x* is zero
(otherwise *FALSE*)

**0<** (x -- flag) *flag* is *TRUE* if *x* is less than zero
(otherwise *FALSE*)

**0>** (x -- flag) *flag* is *TRUE* if *x* is greater than zero
(otherwise *FALSE*)

**0<>** (x -- flag) *flag* is *TRUE* if *x* is not equal to zero
(otherwise *FALSE*)

**\\** The rest of the line is treated as a comment and is not processed

**.** (x --) *x* is output (as a signed number if *BASE* is ten)

**<** (x1 x2 -- flag) *flag* is *TRUE* if *x1* is less than *x2*
(otherwise *FALSE*)

**>** (x1 x2 -- flag) *flag* is *TRUE* if *x1* is greater than *x2*
(otherwise *FALSE*)

**<>** (x1 x2 -- flag) *flag* is *TRUE* if *x1* is not equal to *x2*
(otherwise *FALSE*)

**#>** (xd -- addr u) Make a pictured numeric string of length *u* 
available at *addr*

**<#** Initialise the pcitured numeric string process

**#** (ud1 -- ud2) Extract one (lowest) digit (by radix) from *ud1*
leaving *ud2* and add to pictured numeric string

**#S** (ud1 -- ud2) Add all remaining digits to pictured numeric string -
at conclusion **ud2** is zero

**(** Begin a parenthesised comment (closed with *)*)

**?DO** (n1 n2 --) Do not execute loop body if *n1* and *n2* are equal

**?DUP** (x -- 0 | x x) if *x* is non-zero duplicate *x*

**>BODY** (xt -- addr) *addr* returns the data space pointer value used
by *xt*

**>IN** NOT YET IMPLEMENTED

**>NUMBER** (ud1 addr1 u1 -- ud2 addr2 u2) Convert the string at *addr1* of
length *u1* to a number, using the current radix. *ud1* may be set to a
non-zero number at the start and this will be added to the converted number.
At the end *ud2* holds the converted number, *addr2* points to the first
unconverted characted and *u2* holds the number of unconverted characters.

**>R** (x --) R:(--x) Move *x* from the (data) stack to the return stack

