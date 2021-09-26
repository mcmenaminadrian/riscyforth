\ Unit tests


\ Stack operations tests

: testOVER2
." Testing OVER2 " 5 SPACES
10 30 50 90 70 OVER2
BLUE 50 = SWAP 30 = AND IF ." OVER2 passed " else ." RED OVER2 FAILED " then RESET cr
;

: testDrop2
." Testing DROP2 " 5 spaces
99 2 3 4
drop2
BLUE 2 = if ." DROP2 passed " else ." RED DROP2 FAILED " then RESET cr
;

: testSquare
." Testing SQUARE " 5 spaces
7 square
BLUE 49 = if ." SQUARE passed " else RED ." SQUARE FAILED " then RESET cr
;

: testCube
." Testing CUBE " 5 spaces
5 cube
BLUE 125 = if ." CUBE passed " else RED ." CUBE FAILED " then RESET 5 spaces
3 cube
28 = if RED ." CUBE FAILED " else BLUE ." CUBE passed " then RESET cr
;

: testNIP2
." Testing NIP2 " 5 spaces
10 20 30 40 50 NIP2
BLUE 50 = SWAP 40 = AND SWAP 10 = AND if ." NIP2 passed " else RED ." NIP2 FAILED " then RESET cr 
;

: testDUP2
." Testing DUP2 " 5 SPACES
900 800 700 DUP2
BLUE 700 = SWAP 800 = AND SWAP 700 = AND SWAP 800 = AND if ." DUP2 passed" else RED ." DUP2 FAILED " then RESET cr
;

: testtuck2
." Testing TUCK2 " 5 spaces
1 2 3 4 5 6 TUCK2
6 = swap 5 = and swap 4 = and swap 3 = and swap 6 = and swap 5 = and if BLUE ." TUCK2 passed" else RED ." TUCK2 FAILED " then RESET cr
;

: testswap2
." Testing SWAP2 " 5 spaces
1 2 3 4 5 6 7 8 SWAP2
BLUE 6 = swap 5 = and swap 8 = and if ." SWAP2 passed " else RED ." SWAP2 FAILED " then RESET cr
;

: testrot2
." Testing ROT2 " 5 spaces
99 2 3 4 5 6 ROT2
BLUE 2 = swap 99 = and swap 6 = and if ." ROT2 passed " else RED ." ROT2 FAILED " then RESET cr
;

: TESTDUP
." Testing DUP " 5 spaces
34 45 DUP
BLUE 45 = SWAP 45 = AND swap 34 = AND IF ." DUP passed " else RED ." DUP FAILED " then RESET cr ;

: TESTBL
." Testing BL" 5 spaces BL 32 = if BLUE ." BL passed " else RED ." BL FAILED " then RESET cr ;

: TESTDEPTH
." Testing DEPTH" 5 spaces
depth dup 0 < IF GREEN ." WARNING: Stack in negative territory " THEN 10 20 rot depth swap - 3 = IF BLUE ." DEPTH passed " ELSE RED ." DEPTH FAILED " then RESET cr ;

: TESTINVERT
." Testing INVERT " 5 spaces
-1 INVERT IF RED ." INVERT FAILED " RESET ELSE hex 0xF0F0F0F00F0F0F35 INVERT 0xF0F0F0FF0F0F0CA = IF BLUE ." INVERT passed " ELSE RED ." INVERT FAILED " then then decimal RESET cr ;

\ Basic tests

: VERIFYTYPEPROMPT
." Verifying TYPEPROMPT " cr
TYPEPROMPT cr
;

: VERIFYGETNEXTLINE_IMM
." Verifying GETNEXTLINE_IMM - please press RETURN only " cr
GETNEXTLINE_IMM cr
;

: VERIFYOK
." Verifying OK " cr
OK cr
;

: VERIFYTOKENIZE_IMM
." Verifying TOKENIZE_IMM " cr
TOKENIZE_IMM
;

: VERIFYSEARCH
." Verifying SEARCH " cr
SEARCH
;

: TESTHEX
." Testing HEX " 5 SPACES
HEX 0x10 0xFF + DUP
BLUE 0x10F = IF ." HEX passed with output 0x10F = " . ELSE RED ." HEX FAILED with output 0x10F =  " . then RESET cr
\ ensure other tests keep testdup2
DECIMAL
;

: TESTDECIMAL
." Testing DECIMAL " 5 SPACES
DECIMAL 20 DUP
BLUE 20 = IF ." DECIMAL passed wth output 20 = " DUP . ." = " HEX . DECIMAL ELSE RED ." DECIMAL FAILED with output 20 = " DUP . ." = " HEX . DECIMAL THEN 
RESET CR
;

: TESTOCTAL 
." Testing OCTAL " 5 SPACES OCTAL 20 DUP DECIMAL 16 = IF BLUE ." OCTAL passed with output 20o = " DUP OCTAL . ." = " DECIMAL .
ELSE RED ." OCTAL FAILED with 20o = " DUP OCTAL . ." = " DECIMAL . THEN RESET CR ;

: VERIFYBINARY 
." Verifying BINARY  - " 1 2 4 8 16 32 64 128 256 512
BINARY ." powers of 2 from 9 to 0 in binary... " cr
. cr . cr . cr . cr . cr . cr . cr . cr . cr . cr DECIMAL ;

: VERIFYDOT
." Verifying DOT " 5 spaces 0 1 2 3 4 5
." ... should see countdown from 5 to 0: " . . . . . . CR ;

: TESTADD
." Testing ADD " 5 SPACES 900 -899 +
BLUE IF ." ADD passed " ELSE RED ." ADD FAILED " THEN RESET CR ;

: testMUL
." Testing MUL " 5 spaces
5 5 5 * *
5 cube
BLUE = if ." MUL passed " else RED ." MUL FAILED " then RESET cr
;

: TESTDIV
." Testing DIV " 5 SPACES 99 11 / 101 11 / * 81 =
BLUE IF ." DIV passed " else RED ." DIV FAILED " then RESET cr ;

: TESTSUB
." Testing SUB " 5 spaces 
BLUE 75 22 - 53 = IF ." SUB passed " else RED ." SUB FAILED " then RESET cr ;

: TESTPLUS1
." Testing 1+ " 5 SPACES
BLUE 10 1+ 11 = IF ." 1+ passed " ELSE RED ." 1+ FAILED " THEN RESET CR ;

: TESTPLUS2
." Testing 2+ " 5 SPACES
BLUE 10 2+ 12 = IF ." 2+ passed " ELSE RED ." 2+ FAILED " THEN RESET CR ;

: TESTMINUS1
." Testing 1- " 5 spaces
BLUE -1 1- -2 = IF ." 1- passed " ELSE RED ." 1- FAILED " THEN RESET CR ;

: TESTMINUS2
." Testing 2- " 5 SPACES
BLUE 10 2- 8 = IF ." 2- passed " ELSE RED ." 2- FAILED " THEN RESET CR ;

: TESTUNDERPLUS
." Testing UNDERPLUS" 5 spaces
BLUE 10 15 20 underplus 30 = if ." UNDERPLUS passed" else RED ." UNDERPLUS FAILED" then RESET cr ;

: TESTMOD
." Testing MOD" 5 spaces
BLUE 13 7 mod 6 = if ." MOD passed" else RED ." MOD FAILED" then RESET cr ;

: TESTSLMOD
." Testing /MOD" 5 spaces
BLUE 13 7 /mod 1 = swap 6 = and if ." /MOD passed " else RED ." /MOD FAILED" then RESET cr ;

: TESTNEGATE
." Testing NEGATE" 5 spaces 13 negate -13 =
BLUE if ." NEGATE passed" else RED ." NEGATE FAILED" then RESET cr ;

: TESTABS
." Testing ABS" 5 spaces -13 abs 13 =
BLUE if ." ABS passed" else RED ." ABS FAILED" then RESET cr ;

: TESTMINMAX
." Testing MAX and MIN" 5 spaces
BLUE 20 10 dup2 MAX 20 = if ." MAX passed and " else RED ." MAX FAILED and " then min 10 = if BLUE ." MIN passed." else RED ." MIN FAILED." then RESET cr ;

: TESTSHIFTS
." Testing LSHIFT and RSHIFT" 5 spaces
BLUE 10 4 lshift 160 = IF ." LSHIFT passed " ELSE RED ." LSHIFT FAILED " then RESET 48 2 rshift 12 = 
if BLUE ." RSHIFT passed " ELSE RED ." RSHIFT FAILED " THEN RESET cr ;


: VERIFYWORDLIST 
." Verifying WORDS .... " WORDS CR ;

: TESTLITERALNUMB 
." Testing LITERALNUMB .... " 213 213 = IF BLUE ." LITERALNUMB passed " ELSE RED ." LITERALNUMB FAILED " THEN RESET CR ;


VARIABLE OLDGEEZER
: TESTVARIABLE 
." Testing VARIABLE (and @ and !)" 5 SPACES
901 OLDGEEZER ! OLDGEEZER DUP @ 1+ SWAP ! OLDGEEZER @ 902 =
BLUE IF ." VARIABLE, @ and ! passed " ELSE RED ." VARIABLE, @ and ! FAILED " THEN RESET CR ;

5 CONSTANT FIVE
7 VALUE SEVEN
: TESTCONSTANTVALUE
." Testing CONSTANT, VALUE and TO " 5 SPACES FIVE SEVEN * -7 TO SEVEN SEVEN +
28 = IF BLUE ." CONSTANT, VALUE and TO passed" ELSE RED ." CONSTANT, VALUE and TO FAILED" THEN RESET
7 TO SEVEN CR ;

: TESTTYPE 
." Verifying GETLINE, TYPE and TIB " CR YELLOW BRIGHT ." Please enter some text to be echoed back. " RESET CR
GETLINE CR ." Echoing... " CYAN TIB SWAP TYPE RESET CR ;

: TESTCHAR
." Testing CHAR" 5 spaces
char Z 90 = IF char z 122 = IF BLUE ." CHAR passed " else RED ." CHAR FAILED " then RESET
else RED ." CHAR FAILED " THEN RESET cr ;

: VERIFYSOURCE 
." Verifying SOURCE" 5 spaces
source CYAN type RESET cr ;

\ Test if else then
: TESTCONDITIONALS 
." Testing IF ... ELSE ... THEN conditionals. " CR
1 if BLUE ." Simple IF passed " else RED ." Simple IF FAILED " then RESET cr
0 1 if ." Testing nested IF... " if RED ." Nested IF FAILED " else BLUE ." Nested IF passed " then 5 5 * . then ." = 25 " RESET cr
1 0 if RED ." FAILED a final test of IF " RESET else ." A final test of IF ... " if BLUE ." is passed " else RED ." is FAILED " then then RESET cr ;

\ Stuff to test EXIT
: EXITTEST1
EXIT RED ." If you see this EXIT FAILED " RESET CR ;
VARIABLE EXITVAR
: EXITTEST2
200 EXITVAR ! ;
: EXITTEST3
EXITVAR DUP @ 1+ SWAP ! EXITVAR DUP @ 1+ SWAP ! EXIT EXITVAR DUP @ 1+ SWAP ! ;

: TESTEXIT
." Testing EXIT " 5 SPACES EXITTEST1
EXITTEST2 EXITTEST3 EXITVAR @ 202 = IF BLUE ." EXIT passed " ELSE RED ." EXIT FAILED " THEN RESET CR ;

\ Test return stack words

: TESTRSTACKBASICS
." Testing >R, R@ and R> along with RDROP" cr
34 35 36 >R >R >R R@ 34 = RDROP R@ 35 = AND RDROP R@ 36 = AND RDROP if BLUE ." >R, R@ and RDROP passed " else 
RED ." >R, R@ and RDROP FAILED" then RESET cr
99 >R R> 99 = if BLUE ." R> passed " else RED ." R> FAILED " then RESET cr ;

\ loop
: TESTBEGINUNTIL
." Testing BEGIN ... UNTIL loop " 5 SPACES
32 BEGIN DUP EMIT 1+ DUP 127 > UNTIL BLUE ."  BEGIN ... UNTIL passed " RESET CR ;

: FACTORAL
DUP 2 < IF DROP 1 EXIT THEN DUP BEGIN DUP 2 > WHILE 1- SWAP OVER * SWAP REPEAT DROP ;

: HARDREPEATTEST
BEGIN DUP 2 > WHILE DUP 5 < WHILE DUP 1+ REPEAT 123 ELSE 345 THEN ;

: TESTBEGINWHILE
." Testing BEGIN ... WHILE ... REPEAT " 5 spaces
4 FACTORAL 24 = 6 FACTORAL 3 FACTORAL / 6 5 4 * * = AND IF BLUE ." BEGIN ... WHILE ... REPEAT passed easier test "
ELSE RED ." BEGIN ... WHILE ... REPEAT FAILED " THEN RESET CR
." Trying harder test... " 5 SPACES 2 HARDREPEATTEST 345 = 2 = AND IF BLUE ." passed " ELSE BRIGHT RED ." FAILED "  THEN RESET CR ;

: TESTDOLOOP
." Testing DO ... LOOP " 5 spaces
1 10 1 DO DUP 1+ LOOP 10 = IF BLUE ." DO ... LOOP passed" ELSE RED ." DO ... LOOP FAILED" THEN RESET CR ;

: TESTPLUSLOOP
." Testing DO .... +LOOP" 5 SPACES
1 100  1 DO DUP 1+ 101 +LOOP 2 = IF BLUE ." DO ... +LOOP passed" ELSE RED ." DO .... +LOOP FAILED" THEN RESET CR ;

: VERIFYIJ
." Verifying I and J in nested loops" CR
10 0 DO 10 0 DO ." ( "  J . ." , " I . ." ) " LOOP CR LOOP
." I and J verified" CR ; 

: VERIFYLEAVE
." Verifying LEAVE and UNLOOP " CR
10 0 DO 10 0 DO J I > J I = OR IF ." ( "  J . ." , " I . ." ) " ELSE UNLOOP LEAVE 3 0 DO LOOP 3 0 DO LOOP 3 0 DO LOOP THEN LOOP CR LOOP
." LEAVE and UNLOOP verified" CR ;


\ Testing memory functions
: ZZ BLUE ." ', EXECUTE and C! passed " RESET ;

: TESTINGTICK 
." Testing ', EXECUTE and C! " 5 spaces
hex 0x58 decimal ' ZZ 24 + C! ' XZ execute cr
\ Change back or else subsequent tests will break
." Testing one more time " 5 spaces
hex 0x5A decimal ' xz 24 + C! ' zZ exeCUTE  cr ;

: testcfetch 
." Testing C@" 5 spaces
' XOR 24 + c@ 88 = if BLUE ." C@ passed " else RED ." C@ FAILED " then RESET cr ;

\ Dummy words to use in MOVE test
: ZM * ;
: ZD / ;
: reup decimal 68 ' ZM 25 + C! ;

: TESTINGMOVE
." Testing MOVE " 5 spaces
10 10 ZM 100 = IF ' ZM 24 + ' ZD 24 + 24 move 100 2 ' ZM execute 50 = IF BLUE ." MOVE passed " else RED ." MOVE FAILED " then cr else RED ." Test failure " then reup RESET ;

: TESTFETCH
." Testing @ (and BASE)" 5 spaces
octal base @ 10 = hex base @ 0x10 = AND decimal base @ 10 = AND if BLUE ." @ and BASE passed" ELSE RED ." @ and BASE FAILED" then RESET cr ;

: TESTPLUSSTORE
." Testing +! " 5 SPACES ' ZM 24 + -1  SWAP +! 5 5 ' YM EXECUTE 25 = IF BLUE ." +! passed " ELSE RED ." +! FAILED " THEN RESET 2 SPACES
' YM 24 + 1 SWAP ' +! execute 5 5 ' ZM EXECUTE 25 = INVERT IF RED ." +! address find FAILED " THEN  RESET CR ;

: TESTPADFILLERASE
." Testing PAD, FILL and ERASE " 5 SPACES
PAD 10 35 FILL PAD 3 + 1 ERASE PAD 2 + C@ 35 = PAD 3 + C@ 0 = AND PAD 4 + C@ 35 = AND 
IF BLUE ." PAD, FILL and ERASE passed" ELSE RED ." PAD, FILL and ERASE FAILED" THEN RESET CR ;

\ Memory allocator
VARIABLE allocaddress
: TESTALLOCATOR
." Testing ALLOCATE and FREE " 5 SPACES
\ Test 100000 allocations, frees
1 ALLOCATE 0 = IF allocaddress ! ELSE RED ." ALLOCATE FAILED " RESET CR EXIT THEN
FREE 0 = FALSE AND IF RED ." ALLOCATE passed but FREE failed " RESET CR EXIT THEN
99999 1 DO
1 ALLOCATE 0 = allocaddress @ = AND FALSE AND IF RED ." ALLOCATE FAIL on pass " I . RESET CR EXIT THEN
allocaddress @ FREE 0 = FALSE AND IF RED ." FREE FAIL on pass " RESET I . CR EXIT THEN
LOOP BLUE ." ALLOCATE and FREE passed basic allocate and free test " RESET CR 
\ Test large allocation - 10000 times
." Now testing large allocations " 5 SPACES
1000 ALLOCATE 0 = FALSE AND IF RED ." Large ALLOCATE FAILED " RESET CR EXIT THEN
allocaddress ! allocaddress @ free 0 = FALSE AND IF RED ." Large FREE failed " RESET CR EXIT THEN
9999 1 DO
1 ALLOCATE 0 = allocaddress @ = AND FALSE AND IF RED ." Large ALLOCATE FAIL on pass " RESET I . CR EXIT THEN
allocaddress @ FREE 0 = FALSE AND IF RED ." Large FREE FAIL on pass " RESET I . CR EXIT THEN
LOOP BLUE ." Large ALLOCATE and FREE passed." RESET CR ;

VARIABLE allocx
: TESTRESIZE
." Testing RESIZE " 5 SPACES
1 ALLOCATE DROP allocx !
HEX 0xBADCAFEF00D DECIMAL allocx @ !
allocx @ 40 RESIZE 0 = FALSE AND IF RED ." RESIZE FAIL - no resize " RESET CR EXIT THEN
@ HEX 0xBADCAFEF00D DECIMAL = IF BLUE ." RESIZE passed " RESET ELSE RED ." RESIZE FAIL: no copy" RESET CR EXIT THEN
CR ;

\ In immediate mode
CREATE X 199 ALLOT CREATE Y

: TESTCREATE
." Testing CREATE, HERE and ALLOT " 5 SPACES
Y X - 199 = Y IF BLUE ." CREATE and  ALLOT passed " ELSE RED ." CREATE and ALLOT FAILED " THEN RESET
HERE 3 ALLOT HERE - -3 = IF BLUE ." and HERE passed" ELSE RED ." and HERE FAILED " THEN RESET CR ;  

: TESTCELLS
." Testing CELLS " 5 SPACES
BLUE 10 CELLS 80 = IF ." CELLS passed " ELSE RED ." CELLS FAILED " THEN RESET CR ;

: TESTALIGN
." Testing ALIGN " 5 SPACES
HERE 7 AND 0 = IF 1 ALLOT THEN ALIGN HERE 7 AND 0 = IF BLUE ." ALIGN passed " ELSE RED ." ALIGN FAILED " RESET EXIT THEN RESET
CR ." Now testing ALIGNED... " 5 SPACES 1 ALLOT HERE ALIGNED HERE - 7 = 
IF BLUE ." ALIGNED passed " ELSE RED ." ALIGNED FAILED " THEN RESET CR ;


: FIBONACCI
DUP BACKROT + DUP . DUP 5000000 < IF RECURSE THEN ;

: VERIFYRECURSE
." Verifying RECURSE " 5 SPACES
." Fibonacci series: " 0 1 FIBONACCI CR ;

\ Colours
: VERIFYCOLOURS
BLACK BWHITE ." Verifying colours " CR
YELLOW BBLUE ." Yellow on blue " 3 spaces GREEN BRED ." Green on red " 3 SPACES CYAN BYELLOW ." Cyan on yellow " CR
MAGENTA BBLACK BRIGHT ." Going bright... Magenta on black" 3 spaces WHITE BCYAN ." White on cyan" 3 spaces RED BMAGENTA ." Red on magenta " CR
RESET ." And back to normal..." CR ;

\ Test groupings

\ Memory tests
: TESTMEMORY
." Testing memory manipulation words" cr
TESTINGTICK testcfetch testingmove testchar testfetch testplusstore TESTPADFILLERASE
TESTALLOCATOR TESTRESIZE TESTCREATE TESTCELLS TESTALIGN
." Testing of memory code complete" cr ;

\ Test loops
: TESTLOOPS
." Running tests of looping " cr
TESTBEGINUNTIL testbeginwhile TESTDOLOOP TESTPLUSLOOP VERIFYIJ VERIFYLEAVE VERIFYRECURSE
." Testing of loops complete" CR ;

\ Test Rstack
: RSTACKTESTS
." Testing return stack" cr
testrstackbasics 
." Testing return stack complete" cr ;

\ Test listwords
: LISTWORDSTESTS
." Running 'listwords' group of tests " CR
VERIFYWORDLIST TESTLITERALNUMB TESTVARIABLE TESTTYPE
VERIFYSOURCE TESTCONSTANTVALUE
." 'listwords' group of tests complete " CR ;

\ Test integer
: INTEGERTESTS
." Running integer tests " cr
TESTADD TESTMUL TESTDIV TESTSUB TESTPLUS1 TESTMINUS1
TESTminus2 testplus2 testunderplus testminmax testmod testslmod testabs testnegate testshifts
." Integer tests complete " CR
;

\ Group of stack operations tests
: STACKOPTESTS
." Running stackop tests " cr
TESTOVER2
testDrop2 testSquare
testCube
testNIP2 testDUP2
testtuck2 testswap2 testrot2 testdup testbl testdepth
testinvert
." stackop tests over " cr
;

\ Group of Basics tests
: BASICSTESTS
." Running basics tests and verifications " cr
VERIFYTYPEPROMPT
VERIFYGETNEXTLINE_IMM
VERIFYOK
VERIFYTOKENIZE_IMM 
VERIFYSEARCH OK
." ***Any error message above can almost certainly be ignored*** " CR
TESTHEX TESTDECIMAL TESTOCTAL VERIFYBINARY TESTEXIT
." Verifying ENCSQ with this output " cr
." Verifying COMMENT " cr \ ." COMMENT verification FAILED " 
VERIFYDOT
." Basics tests and verifications over " cr
;


\ Run all the tests
: UTS
CLEARSCREEN	\ Verifies CLEARSCREEN
DECIMAL
." Running unit tests (cleared screen verifies CLEARSCREEN)" cr
VERIFYCOLOURS CR
STACKOPTESTS
YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
BASICSTESTS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
INTEGERTESTS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
LISTWORDSTESTS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
TESTCONDITIONALS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
RSTACKTESTS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
TESTLOOPS YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
TESTMEMORY YELLOW BRIGHT
." Press enter to continue " RESET GETLINE CR
 ABORT" Verifying ABORTCOMM and leaving tests with this message "  ." ABORTCOMM has FAILED"
;
