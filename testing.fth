\ Unit tests

DECIMAL
( Verify brackets in immediate code )
\ Stack operations tests

: WHEN
TIME&DATE
." Date is " . ." : " . ." : " . CR
." Time is " . ." : " . ." : " . CR ;


: testOVER2
." Testing 2OVER " 5 SPACES
10 30 50 90 70 2OVER
BLUE 50 = SWAP 30 = AND IF ." 2OVER passed " else RED ." 2OVER FAILED " then RESET cr
;

: TESTPICK
." Testing PICK" 5 SPACES
14 12 13 2 PICK 14 = IF BLUE ." PICK passed" ELSE RED ." PICK FAILED" THEN RESET CR ;

: testDrop2
." Testing 2DROP " 5 spaces
99 2 3 4
2drop
BLUE 2 = if ." 2DROP passed " else RED ." 2DROP FAILED " then RESET cr
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
." Testing 2NIP " 5 spaces
10 20 30 40 50 2NIP
BLUE 50 = SWAP 40 = AND SWAP 10 = AND if ." 2NIP passed " else RED ." 2NIP FAILED " then RESET cr 
;

: testDUP2
." Testing 2DUP " 5 SPACES
900 800 700 2DUP
BLUE 700 = SWAP 800 = AND SWAP 700 = AND SWAP 800 = AND if ." 2DUP passed" else RED ." 2DUP FAILED " then RESET cr
;

: testtuck2
." Testing 2TUCK " 5 spaces
1 2 3 4 5 6 2TUCK
6 = swap 5 = and swap 4 = and swap 3 = and swap 6 = and swap 5 = and if BLUE ." 2TUCK passed" else RED ." 2TUCK FAILED " then RESET cr
;

: testswap2
." Testing 2SWAP " 5 spaces
1 2 3 4 5 6 7 8 2SWAP
BLUE 6 = swap 5 = and swap 8 = and if ." 2SWAP passed " else RED ." 2SWAP FAILED " then RESET cr
;

: testrot2
." Testing 2ROT " 5 spaces
99 2 3 4 5 6 2ROT
BLUE 2 = swap 99 = and swap 6 = and if ." 2ROT passed " else RED ." 2ROT FAILED " then RESET cr
;

: TESTDUP
." Testing DUP " 5 spaces
34 45 DUP
BLUE 45 = SWAP 45 = AND swap 34 = AND IF ." DUP passed " else RED ." DUP FAILED " then RESET cr ;

: TESTBL
." Testing BL" 5 spaces BL 32 = if BLUE ." BL passed " else RED ." BL FAILED " then RESET cr ;

: TESTDEPTH
." Testing DEPTH" 5 spaces
DEPTH DUP DUP 0> IF GREEN ." Stack over committed by " DUP . RESET CR ELSE DUP 0= IF BLUE ." DEPTH passed: stack depth " . RESET CR EXIT
ELSE RED ." DEPTH FAILED with stack depth " . RESET CR EXIT THEN THEN
DUP GREEN ." Removing " . ." stack entries" RESET CR
1+ 0 DO DROP LOOP
DEPTH DUP GREEN ." Stack depth now " . RESET CR
0= IF BLUE ." DEPTH passed" ELSE RED ." DEPTH FAILED" THEN RESET CR ;

: TEST?DUP
." Testing ?DUP " 5 SPACES
10 -1 0 ?DUP DROP -1 = ?DUP DROP -1 =
AND IF BLUE ." ?DUP passed" ELSE ." ?DUP FAILED" THEN RESET CR ;

: TESTINVERT
." Testing INVERT " 5 spaces
-1 INVERT IF RED ." INVERT FAILED " RESET ELSE hex F0F0F0F00F0F0F35 INVERT F0F0F0FF0F0F0CA = IF BLUE ." INVERT passed " ELSE RED ." INVERT FAILED " then then decimal RESET cr ;

\ Basic tests

: TESTHEX
." Testing HEX " 5 SPACES
HEX 10 FF + DUP
BLUE 10F = IF ." HEX passed with output 0x10F = " . ELSE RED ." HEX FAILED with output 0x10F =  " . then RESET cr
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
CYAN . cr . cr . cr . cr . cr . cr . cr . cr . cr . cr RESET DECIMAL ;

: VERIFYDOT
." Verifying DOT " 5 spaces 0 1 2 3 4 5
." ... should see countdown from 5 to 0: " CYAN . . . . . . RESET CR ;

: VERIFY.S
." Verifying .S" 5 SPACES CYAN 48 49 50 51 52 53 54 55 56 57 10 .S BLUE ."  .S verified" RESET CR ;

: TESTADD
." Testing + " 5 SPACES 900 -899 +
BLUE IF ." + passed " ELSE RED ." + FAILED " THEN RESET CR ;

: testMUL
." Testing * " 5 spaces
5 5 5 * *
5 cube
BLUE = if ." * passed " else RED ." * FAILED " then RESET cr
;

: TESTINEQUALITIES
." Testing equality and inequalities..." 5 SPACES
5 6 < 66 55 > AND 5 6 <= AND 66 55 >= AND 667 667 >= AND 667 667 <= AND 667 666 <= FALSE = AND
5 6 > FALSE = AND 6 5 <= FALSE = AND 10 9 < FALSE = AND 10 10 = AND 10 11 = FALSE = AND
IF BLUE ." Equality and Inequalities passed" ELSE RED ." Inequalities FAILED" THEN RESET CR ;

: TESTDIV
." Testing / " 5 SPACES 99 11 / 101 11 / * 81 =
BLUE IF ." / passed " else RED ." / FAILED " then RESET cr ;

: TESTSUB
." Testing - " 5 spaces 
BLUE 75 22 - 53 = IF ." - passed " else RED ." - FAILED " then RESET cr ;

: TEST0<>
." Testing 0<>" 5 SPACES
0 0<> INVERT 1 0<> AND IF BLUE ." 0<> passed" ELSE RED ." 0<> FAILED" THEN RESET CR ;

: TEST0>
." Testing 0>" 5 spaces
-3 0> FALSE = 3 0> TRUE = AND IF BLUE ." 0> passed" ELSE RED ." 0> FAILED" THEN CR RESET ;

: TEST0<
." Testing 0< " 5 SPACES
-3 0< TRUE = 3 0< FALSE = AND IF BLUE ." 0< passed" ELSE RED ." 0< FAILED" THEN CR RESET ;

: TEST0=
." Testing 0= " 5 SPACES
0 0= TRUE = 1 0= FALSE = AND IF BLUE ." 0= passed" ELSE RED ." 0= FAILED" THEN CR RESET ; 

: TEST1+
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

: TEST*/
." Testing */" 5 SPACES
5 7 3 */ 11 = IF BLUE ." */ passed" ELSE RED ." */ FAILED" THEN RESET CR ;

: TEST*/MOD
." Testing */MOD" 5 SPACES
5 7 3  */MOD 11 = SWAP 2 = AND IF BLUE ." */MOD passed" ELSE RED ." */MOD FAILED" THEN RESET CR ;

: TEST2/
." Testing 2/" 5 SPACES
35 2/ 17 = 34 2/ 17 = AND IF BLUE ." 2/ passed" ELSE RED ." 2/ FAILED" THEN RESET CR ;

: TEST2*
." Testing 2*" 5 SPACES
35 2* 70 = 34 2* 68 = AND IF BLUE ." 2* passed" ELSE RED ." 2* FAILED" THEN RESET CR ;

: TESTNEGATE
." Testing NEGATE" 5 spaces 13 negate -13 =
BLUE if ." NEGATE passed" else RED ." NEGATE FAILED" then RESET cr ;

: TESTABS
." Testing ABS" 5 spaces -13 abs 13 =
BLUE if ." ABS passed" else RED ." ABS FAILED" then RESET cr ;

: TESTMINMAX
." Testing MAX and MIN" 5 spaces
BLUE 20 10 2dup MAX 20 = if ." MAX passed and " else RED ." MAX FAILED and " then min 10 = if BLUE ." MIN passed." else RED ." MIN FAILED." then RESET cr ;

: TESTSHIFTS
." Testing LSHIFT and RSHIFT" 5 spaces
BLUE 10 4 lshift 160 = IF ." LSHIFT passed " ELSE RED ." LSHIFT FAILED " then RESET 48 2 rshift 12 = 
if BLUE ." RSHIFT passed " ELSE RED ." RSHIFT FAILED " THEN RESET cr ;


: VERIFYWORDLIST 
." Verifying WORDS .... " CYAN WORDS RESET CR ;

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


create acceptpad 80 allot
: TESTACCEPT
." Verifying ACCEPT" 5 SPACES ." Please type some text..." 
ACCEPTPAD 3 ACCEPT CR ." You should only see first 3 characters typed:"
CYAN ACCEPTPAD 10 TYPE BLUE ." : ACCEPT verified" RESET CR ;

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

\ Test [ ] and LITERAL
: TEST[]
." Testing [, ] and LITERAL " 5 SPACES
[ 10 5 - ] LITERAL [ 5 1 * ] LITERAL - 0= IF [ 8 4 / ] LITERAL 2 = IF BLUE ." [ ] and LITERAL passed " ELSE RED ." [ ] and LITERAL FAILED" THEN RESET ELSE RED ." [ ] and LITERAL FAILED" THEN
RESET CR ;

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
32 BEGIN CYAN DUP EMIT 1+ DUP 127 > UNTIL BLUE ."  BEGIN ... UNTIL passed " RESET CR ;


VARIABLE BAXX
: TESTBEGINAGAIN
." Testing BEGIN ... AGAIN looping " 5 SPACES
0 BAXX ! BEGIN 1 BAXX +! BAXX @ 7500000 = IF EXIT THEN AGAIN ;

: CONTROLBEGINAGAINTEST
TESTBEGINAGAIN BAXX @ 7500000 = IF BLUE ." BEGIN ... AGAIN passed " ELSE RED ." BEGIN ... AGAIN failed" THEN RESET CR ;


: FACTORAL
DUP 2 < IF DROP 1 EXIT THEN DUP BEGIN DUP 2 > WHILE 1- SWAP OVER * SWAP REPEAT DROP ;

: HARDREPEATTEST 
 BEGIN DUP 2 > WHILE DUP 5 < WHILE DUP 1+ REPEAT 123 ELSE 345 THEN ;

: TESTBEGINWHILE
." Testing BEGIN ... WHILE ... REPEAT " 5 spaces
4 FACTORAL 24 = 6 FACTORAL 3 FACTORAL / 6 5 4 * * = AND IF BLUE ." BEGIN ... WHILE ... REPEAT passed easier test "
ELSE RED ." BEGIN ... WHILE ... REPEAT FAILED " THEN RESET CR
." Trying harder test... " 5 SPACES 2 HARDREPEATTEST 345 = swap 2 = AND IF BLUE ." passed " ELSE BRIGHT RED ." FAILED "  THEN RESET CR ;

: TESTDOLOOP
." Testing DO ... LOOP " 5 spaces
1 10 1 DO DUP 1+ 10 1 DO LOOP LOOP 10 = IF BLUE ." DO ... LOOP passed" ELSE RED ." DO ... LOOP FAILED" THEN RESET CR ;

: TESTPLUSLOOP
." Testing DO .... +LOOP" 5 SPACES
1 100  1 DO DUP 1+ 101 +LOOP 2 = IF BLUE ." DO ... +LOOP passed" ELSE RED ." DO .... +LOOP FAILED" THEN RESET CR
." TESTING DO ... -LOOP" 5 SPACES
1 0 100 DO DUP 1+ -100 -LOOP 2 = IF BLUE ." DO ... -LOOP passed" ELSE RED ." DO ... -LOOP FAILED" THEN RESET CR ;

: TEST?DO
." Testing ?DO ... LOOP" 5 SPACES
1 1 1 ?DO 1+ LOOP DUP 1 = SWAP 3 1 ?DO 1+ LOOP 3 = AND IF BLUE ." ?DO ... LOOP passed" ELSE RED ." ?DO ... LOOP FAILED" THEN RESET CR
." TESTING ?DO ... +LOOP" 5 SPACES
2 2 2 ?DO 90 + 1 +LOOP DUP 2 = SWAP 3 1 ?DO 1+ 2 +LOOP 3 = AND IF BLUE ." ?DO .... +LOOP passed" ELSE RED ." ?DO ... +LOOP FALED" THEN RESET CR ;

: VERIFYIJ
." Verifying I and J in nested loops" CR
CYAN 10 0 DO 10 0 DO ." ( "  J . ." , " I . ." ) " LOOP CR LOOP RESET
BLUE ." I and J verified" RESET CR ; 

: VERIFYLEAVE
." Verifying LEAVE " CR
CYAN 10 0 DO 10 0 DO J I > J I = OR IF ." ( "  J . ." , " I . ." ) " ELSE LEAVE 3 0 DO LOOP 3 0 DO LOOP 3 0 DO LOOP THEN LOOP CR LOOP  RESET
BLUE ." LEAVE verified" CR RESET ;

VARIABLE TESTUNLOOPV
: TESTUNLOOP ." Testing UNLOOP " 5 SPACES
0 TESTUNLOOPV !
10 0 DO I TESTUNLOOPV ! I 3 = IF UNLOOP EXIT THEN LOOP
;

: SECONDPARTUNLOOP
TESTUNLOOPV @ 3 = IF BLUE ." UNLOOP passed " ELSE RED ." UNLOOP FAILED" THEN RESET CR ;

\ Testing memory functions
: ZZ BLUE ." ', EXECUTE and C! passed " RESET ;

: TESTINGTICK 
." Testing ', EXECUTE and C! " 5 spaces
hex 58 decimal ' ZZ 24 + C! ' XZ execute cr
\ Change back or else subsequent tests will break
." Testing one more time " 5 spaces
hex 5A decimal ' xz 24 + C! ' zZ exeCUTE  cr ;

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

: TEST@
." Testing @ (and BASE)" 5 spaces
octal base @ 10 = hex base @ 10 = AND decimal base @ 10 = AND if BLUE ." @ and BASE passed" ELSE RED ." @ and BASE FAILED" then RESET cr ;

1 CELLS ALLOT
CREATE SPEAKLIKEACHILD
1 CELLS ALLOT
: TEST2@
." Testing 2@" 5 spaces
100 SPEAKLIKEACHILD ! 101 SPEAKLIKEACHILD 1 CELLS + ! SPEAKLIKEACHILD 2@
100 = swap 101 = AND IF BLUE ." 2@ passed" ELSE RED ." 2@ FAILED" THEN RESET CR ;

CREATE STRANGETOWN
10 ALLOT
: TEST>BODY
." Testing >BODY" 5 SPACES
' STRANGETOWN >BODY STRANGETOWN = IF BLUE ." >BODY passed" ELSE RED ." >BODY FAILED" THEN RESET CR ;

: TEST>BODY2
." Testing >BODY against ineligible function" 5 SPACES
' TEST>BODY >BODY 0= IF BLUE ." >BODY passed" ELSE RED ." >BODY FAILED" THEN RESET CR ;

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

\ 2! test
VARIABLE 2!STORE
: TEST2!
." Testing 2!" 5 SPACES
100 ALLOCATE DROP 2!STORE !
55 56 2!STORE @ 2!
2!STORE @ @ 56 = 2!STORE @ 1 CELLS + @ 55 = AND IF BLUE ." 2! passed" ELSE RED ." 2! FAILED" THEN RESET 
2!STORE @ FREE CR ;


VARIABLE allocx
: TESTRESIZE
." Testing RESIZE " 5 SPACES
1 ALLOCATE DROP allocx !
HEX BADCAFEF00D DECIMAL allocx @ !
allocx @ 40 RESIZE 0 = FALSE AND IF RED ." RESIZE FAIL - no resize " RESET CR EXIT THEN
@ HEX BADCAFEF00D DECIMAL = IF BLUE ." RESIZE passed " RESET ELSE RED ." RESIZE FAIL: no copy" RESET CR EXIT THEN
CR ;


\ In immediate mode
CREATE X 199 ALLOT CREATE Y

: TESTCREATE
." Testing CREATE, HERE and ALLOT " 5 SPACES
Y X - 199 = Y IF BLUE ." CREATE and  ALLOT passed " ELSE RED ." CREATE and ALLOT FAILED " THEN RESET
HERE 3 ALLOT HERE - -3 = IF BLUE ." and HERE passed" ELSE RED ." and HERE FAILED " THEN RESET CR ;  

\ Test CREATE, DOES>
: INDEXED-ARRAY CREATE CELLS ALLOT DOES> SWAP  \ Across multiple lines
CELLS + ;

100 INDEXED-ARRAY FOO

: TESTDOES>
." Testing DOES> " 5 SPACES
99 FOO 0 FOO - 792 = IF BLUE ." DOES> passed " ELSE RED ." DOES> FAILED " THEN RESET CR ;


64 C, CREATE XC ALIGN 1024 ,  CREATE XN
: TESTCOMMA
." Testing C, and , " 5 SPACES
XC C@ 64 = IF BLUE ." C, passed " ELSE RED ." C, FAILED " THEN RESET 5 SPACES
XN @ 1024 IF BLUE ." , passed " ELSE RED ." , FAILED " THEN RESET CR ;

: TESTCELLS
." Testing CELLS AND CHARS" 5 SPACES
BLUE 10 CELLS 80 = IF ." CELLS passed " ELSE RED ." CELLS FAILED " THEN RESET CR 
95 CHARS 95 = IF BLUE ." CHARS passed " ELSE RED ." CHARS FAILED " THEN RESET CR ;

: TESTALIGN
." Testing ALIGN " 5 SPACES
HERE 7 AND 0 = IF 1 ALLOT THEN ALIGN HERE 7 AND 0 = IF BLUE ." ALIGN passed " ELSE RED ." ALIGN FAILED " RESET EXIT THEN RESET
CR ." Now testing ALIGNED... " 5 SPACES 1 ALLOT HERE ALIGNED HERE - 7 = 
IF BLUE ." ALIGNED passed " ELSE RED ." ALIGNED FAILED " THEN RESET CR ;


: FIBONACCI
CYAN DUP -ROT + DUP . DUP 5000000 < IF RECURSE THEN RESET ;

: VERIFYRECURSE
." Verifying RECURSE (and -ROT) " CR
." Fibonacci series: 0 1 " 0 1 FIBONACCI CR ;

DEFER TESTDEFER
: VERIFYDEFERIS
." Verifying DEFER and IS " CR
." Print ASCII characters..." ' EMIT IS TESTDEFER CYAN 128 32 DO I TESTDEFER LOOP RESET CR
." Now print numbers..." ' . IS TESTDEFER CYAN 128 32 DO I TESTDEFER LOOP RESET CR
' NOP IS TESTDEFER \ Restore default state
BLUE ." DEFER and IS verified" RESET CR ;

: TESTDEFER@
." Testing DEFER@ and DEFER!" CR
' EMIT IS TESTDEFER ' TESTDEFER DEFER@ ' EMIT = IF BLUE ." DEFER@ passed" ELSE RED ." DEFER@ FAILED" THEN RESET CR
' . ' TESTDEFER DEFER! ' TESTDEFER DEFER@ ' . = IF BLUE ." DEFER! passed" ELSE RED ." DEFER! FAILED" THEN RESET CR ' NOP IS TESTDEFER ;


VARIABLE PREBUFFER
25 CELLS BUFFER: TESXBUFF
VARIABLE POSTBUFFER
: TESTBUFFER:
." Testing BUFFER: addressing " 5 SPACES
TESXBUFF PREBUFFER - 1 CELLS = POSTBUFFER TESXBUFF - 25 CELLS = AND IF BLUE ." Addressing for BUFFER: passed " ELSE RED ." BUFFER: FAILED (addressing)" THEN RESET CR
." Now testing reading and writing for BUFFER: " 5 SPACES 
1 PREBUFFER ! 25 CELLS 1 - 0 DO I TESXBUFF I + ! I TESXBUFF I + @ = INVERT IF 0 PREBUFFER ! THEN LOOP
PREBUFFER IF BLUE ." Reading and writing to BUFFER: passed " ELSE RED ." Reading and writing to BUFFER: failed " THEN RESET CR
25 CELLS 1 - 0 DO -1 TESXBUFF I + ! LOOP ;

1 ALLOT
VARIABLE BITMANIP
: TESTBITMANIP
." Testing CSET, CRESET, CTOGGLE " CR
0 BITMANIP C! BITMANIP C@ 0= 2 BITMANIP CSET BITMANIP C@ 2 = AND IF BLUE ." CSET passed" ELSE RED ." CSET FAILED" THEN RESET CR
255 BITMANIP C! BITMANIP C@ 255 = 255 BITMANIP CRESET BITMANIP C@ 0= AND IF BLUE ." CRESET passed" ELSE RED ." CRESET FAILED" THEN RESET CR
15 BITMANIP C! BITMANIP C@ 15 = 31 BITMANIP CTOGGLE BITMANIP C@ 16 = AND IF BLUE ." CTOGGLE passed" ELSE RED ." CTOGGLE FAILED" THEN RESET CR ;

\ Colours
: VERIFYCOLOURS
BLACK BWHITE ." Verifying colours " CR
YELLOW BBLUE ." Yellow on blue " 3 spaces GREEN BRED ." Green on red " 3 SPACES CYAN BYELLOW ." Cyan on yellow " CR
MAGENTA BBLACK BRIGHT ." Going bright... Magenta on black" 3 spaces WHITE BCYAN ." White on cyan" 3 spaces RED BMAGENTA ." Red on magenta " CR
RESET ." And back to normal..." CR ;

: TESTMS
." Verifying MS word - waiting around 1 second..." 5 SPACES
1000 MS
BLUE ." Verification of MS complete" RESET CR ;

\ testing pictured output
: VERIFYPICTURED
." Verifying pictured output" CR
CYAN S" -£125.45" type ."  = " -12545 <# dup # # 46 hold #s 163 hold 194 hold drop sign 0 #> type RESET CR
." And verifying base conversion..." CR
CYAN 324 DUP . ." in binary is..." binary <# #s #> type decimal RESET CR
BLUE ." Numbered pictured output verified." RESET CR ; 

: TEST>NUMBER
." Testing >NUMBER" 5 SPACES
10 S" 1005" >NUMBER DROP DROP 1015 = IF BLUE ." >NUMBER passed" ELSE RED ." >NUMBER FAILED" THEN RESET CR ;



: TESTCASE
CASE
    1 OF RED ." CASE FAILED " RESET ENDOF
    2 OF RED ." CASE FAILED " RESET ENDOF
    3 OF RED ." CASE FAILED " RESET ENDOF
    4 OF BLUE ." CASE passed " RESET ENDOF
    DUP TRUE SWAP 4 <  OF RED ." CASE FAILED" RESET ENDOF DROP
    DUP TRUE SWAP 3 > OF BLUE ." CASE passed - again" RESET ENDOF DROP
    BLUE ." ... default message" RESET CR
ENDCASE ;

: TESTINGCASE
." Testing CASE" 5 SPACES 4 TESTCASE ;

VARIABLE QTEST
: TESTQ-?
." Verifying ?" 5 SPACES
1001 QTEST !
BLUE QTEST ? ." should equal " QTEST @ . RESET CR ;

\ Test groupings

\ Test facility
: TESTFACILITY
." Testing facility and timing words" CR
TESTMS
." Testing of facility and timing words complete" CR ;

\ Memory tests
: TESTMEMORY
." Testing memory manipulation words" cr
TESTINGTICK testcfetch testingmove testchar test@ TEST2@ testplusstore TESTPADFILLERASE
TESTALLOCATOR TESTRESIZE TESTCREATE TESTCELLS TESTALIGN TESTCOMMA TESTDOES> TEST2!
VERIFYDEFERIS TESTDEFER@ TESTBUFFER: TEST>BODY TEST>BODY2 TESTBITMANIP TESTQ-?
." Testing of memory code complete" cr ;

\ Test loops
: TESTLOOPS
." Running tests of looping " cr
TESTBEGINUNTIL testbeginwhile TESTDOLOOP TEST?DO TESTPLUSLOOP VERIFYIJ VERIFYLEAVE VERIFYRECURSE
TESTUNLOOP SECONDPARTUNLOOP CONTROLBEGINAGAINTEST
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
VERIFYSOURCE TESTCONSTANTVALUE TESTACCEPT
." 'listwords' group of tests complete " CR ;

\ Test integer
: INTEGERTESTS
." Running integer tests " cr
TESTADD TESTMUL TESTDIV TESTSUB TEST1+ TESTMINUS1 TEST0< TEST0= TEST0<> TEST0>
TESTminus2 testplus2 testunderplus testminmax testabs testnegate testshifts
TESTMOD TESTSLMOD TEST*/ TEST*/MOD TEST2/ TEST2* TESTINEQUALITIES TEST>NUMBER
TESTINGCASE
." Integer tests complete " CR
;

\ Group of stack operations tests
: STACKOPTESTS
." Running stackop tests " cr
TESTOVER2
testDrop2 testSquare
testCube
testNIP2 testDUP2 TEST?DUP
testtuck2 testswap2 testrot2 testdup testbl
testinvert
TEST[] TESTPICK 
." stackop tests over " cr
;

\ Group of Basics tests
: BASICSTESTS
." Running basics tests and verifications " cr
TESTHEX TESTDECIMAL TESTOCTAL VERIFYBINARY TESTEXIT
BLUE ." Verifying ENCSQ with this output " RESET cr
S" Verifying SQ" 2DUP TYPE 12 = IF BLUE 5 spaces ." Verified SQ" ELSE 5 spaces RED ." SQ FAILED" THEN RESET CR
BLUE ." Verifying COMMENT " RESET cr \ ." COMMENT verification FAILED " 
VERIFYDOT VERIFY.S 
." Basics tests and verifications over " cr
;

: ENTERCONTINUE
YELLOW BRIGHT 
." Press enter to continue " RESET GETLINE CR ;

\ Run all the tests
: UTS
CLEARSCREEN   \ Verifies CLEARSCREEN
DECIMAL
." Running unit tests (cleared screen verifies CLEARSCREEN)" cr
( Verify brackets in compiled code )
VERIFYCOLOURS CR
WHEN
STACKOPTESTS
ENTERCONTINUE
BASICSTESTS
ENTERCONTINUE
INTEGERTESTS
ENTERCONTINUE
VERIFYPICTURED
ENTERCONTINUE
LISTWORDSTESTS
ENTERCONTINUE
TESTCONDITIONALS
ENTERCONTINUE
RSTACKTESTS
ENTERCONTINUE
TESTLOOPS
ENTERCONTINUE
TESTMEMORY
ENTERCONTINUE
TESTFACILITY
ENTERCONTINUE
TESTDEPTH
ENTERCONTINUE
RED 0 ABORT" ABORTCOMM HAS FAILED"  
RESET 1 ABORT" ABORTCOMM has passed" ;
