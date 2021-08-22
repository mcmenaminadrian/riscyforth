\ Unit tests


\ Stack operations tests

: testOVER2
." Testing OVER2 " 5 SPACES
10 30 50 90 70 OVER2
50 = SWAP 30 = AND IF ." OVER2 passed " else ." OVER2 failed " then cr
;

: testDrop2
." Testing DROP2 " 5 spaces
99 2 3 4
drop2
2 = if ." DROP2 passed " else ." DROP2 failed " then cr
;

: testSquare
." Testing SQUARE " 5 spaces
7 square
49 = if ." SQUARE passed " else ." SQUARE failed " then cr
;

: testCube
." Testing CUBE " 5 spaces
5 cube
125 = if ." CUBE passed " else ." CUBE failed " then 5 spaces
3 cube
28 = if ." CUBE failed " else ." CUBE passed " then cr
;

: testNIP2
." Testing NIP2 " 5 spaces
10 20 30 40 50 NIP2
50 = SWAP 40 = AND SWAP 10 = AND if ." NIP2 passed " else ." NIP2 failed " then cr 
;

: testDUP2
." Testing DUP2 " 5 SPACES
900 800 700 DUP2
700 = SWAP 800 = AND SWAP 700 = AND SWAP 800 = AND if ." DUP2 passed" else ." DUP2 failed " then cr
;

: testtuck2
." Testing TUCK2 " 5 spaces
1 2 3 4 5 6 TUCK2
6 = swap 5 = and swap 4 = and swap 3 = and swap 6 = and swap 5 = and if ." TUCK2 passed" else ." TUCK2 failed " then cr
;

: testswap2
." Testing SWAP2 " 5 spaces
1 2 3 4 5 6 7 8 SWAP2
6 = swap 5 = and swap 8 = and if ." SWAP2 passed " else ." SWAP2 failed " then cr
;

: testrot2
." Testing ROT2 " 5 spaces
99 2 3 4 5 6 ROT2
2 = swap 99 = and swap 6 = and if ." ROT2 passed " else ." ROT2 failed " then cr
;

: TESTDUP
." Testing DUP " 5 spaces
34 45 DUP
45 = SWAP 45 = AND swap 34 = AND IF ." DUP passed " else ." DUP failed " then cr ;

: TESTBL
." Testing BL" 5 spaces BL 32 = if ." BL passed " else ." BL FAILED " then cr ;

: TESTDEPTH
." Testing DEPTH" 5 spaces
depth dup 0 < IF ." WARNING: Stack in negative territory " THEN 10 20 rot depth swap - 3 = IF ." DEPTH passed " ELSE ." DEPTH FAILED " then cr ;

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
0x10F = IF ." HEX passed with output 0x10F = " . ELSE ." HEX failed with output 0x10F =  " . then cr
\ ensure other tests keep testdup2
DECIMAL
;

: TESTDECIMAL
." Testing DECIMAL " 5 SPACES
DECIMAL 20 DUP
20 = IF ." DECIMAL passed wth output 20 = " DUP . ." = " HEX . DECIMAL ELSE ." DECIMAL failed with output 20 = " DUP . ." = " HEX . DECIMAL THEN CR
;

: TESTOCTAL 
." Testing OCTAL " 5 SPACES OCTAL 20 DUP DECIMAL 16 = IF ." OCTAL passed with output 20o = " DUP OCTAL . ." = " DECIMAL .
ELSE ." OCTAL failed with 20o = " DUP OCTAL . ." = " DECIMAL . THEN CR ;

: VERIFYBINARY 
." Verifying BINARY  - " 1 2 4 8 16 32 64 128 256 512
BINARY ." powers of 2 from 9 to 0 in binary... " cr
. cr . cr . cr . cr . cr . cr . cr . cr . cr . cr DECIMAL ;

: VERIFYDOT
." Verifying DOT " 5 spaces 0 1 2 3 4 5
." ... should see countdown from 5 to 0: " . . . . . . CR ;

: TESTADD
." Testing ADD " 5 SPACES 900 -899 +
IF ." ADD passed " ELSE ." ADD failed " THEN CR ;

: testMUL
." Testing MUL " 5 spaces
5 5 5 * *
5 cube
= if ." MUL passed " else ." MUL failed " then cr
;

: TESTDIV
." Testing DIV " 5 SPACES 99 11 / 101 11 / * 81 =
IF ." DIV passed " else ." DIV failed " then cr ;

: TESTSUB
." Testing SUB " 5 spaces 
75 22 - 53 = IF ." SUB passed " else ." SUB failed " then cr ;

: TESTPLUS1
." Testing 1+ " 5 SPACES
10 1+ 11 = IF ." 1+ passed " ELSE ." 1+ failed " THEN CR ;

: TESTPLUS2
." Testing 2+ " 5 SPACES
10 2+ 12 = IF ." 2+ passed " ELSE ." 2+ failed " THEN CR ;

: TESTMINUS1
." Testing 1- " 5 spaces
-1 1- -2 = IF ." 1- passed " ELSE ." 1- failed " THEN CR ;

: TESTMINUS2
." Testing 2- " 5 SPACES
10 2- 8 = IF ." 2- passed " ELSE ." 2- failed " THEN CR ;

: TESTUNDERPLUS
." Testing UNDERPLUS" 5 spaces
10 15 20 underplus 30 = if ." UNDERPLUS passed" else ." UNDERPLUS failed" then cr ;

: TESTMOD
." Testing MOD" 5 spaces
13 7 mod 6 = if ." MOD passed" else ." MOD failed" then cr ;

: TESTSLMOD
." Testing /MOD" 5 spaces
13 7 /mod 1 = swap 6 = and if ." /MOD passed " else ." /MOD failed" then cr ;

: TESTNEGATE
." Testing NEGATE" 5 spaces 13 negate -13 =
if ." NEGATE passed" else ." NEGATE failed" then cr ;

: TESTABS
." Testing ABS" 5 spaces -13 abs 13 =
if ." ABS passed" else ." ABS failed" then cr ;

: TESTMINMAX
." Testing MAX and MIN" 5 spaces
20 10 dup2 MAX 20 = if ." MAX passed and " else ." MAX failed and " then min 10 = if ." MIN passed." else ." MIN failed." then cr ;

: TESTSHIFTS
." Testing LSHIFT and RSHIFT" 5 spaces
10 4 lshift 160 = IF ." LSHIFT passed " ELSE ." LSHIFT FAILED " then 48 2 rshift 12 = if ." RSHIFT passed " ELSE ." RSHIFT FAILED " THEN cr ;


: VERIFYWORDLIST 
." Verifying WORDS .... " WORDS CR ;

: TESTLITERALNUMB 
." Testing LITERALNUMB .... " 213 213 = IF ." LITERALNUMB passed " ELSE ." LITERALNUMB failed " THEN CR ;

: TESTVARIABLE 
." Testing VARIABLE and VARIN " 5 SPACES
901 VARIABLE OLDGEEZER OLDGEEZER 1 + VARIABLE OLDGEEZER 902 OLDGEEZER =
IF ." VARIABLE and VARIN passed " ELSE ." VARIABLE and VARIN failed " THEN CR ;

: TESTTYPE 
." Verifying GETLINE, TYPE and TIB " CR ." Please enter some text to be echoed back. " CR
GETLINE CR ." Echoing... " TIB SWAP TYPE CR ;

: TESTCHAR
." Testing CHAR" 5 spaces
char Z 90 = IF char z 122 = IF ." CHAR passed " else ." CHAR FAILED " then else ." CHAR FAILED " THEN cr ;

: VERIFYSOURCE 
." Verifying SOURCE" 5 spaces
source type cr ;

\ Test if else then
: TESTCONDITIONALS 
." Testing IF ... ELSE ... THEN conditionals. " CR
1 if ." Simple IF passed " else ." Simple IF failed " then cr
0 1 if ." Testing nested IF... " if ." Nested IF failed " else ." Nested IF passed " then 5 5 * . then ." = 25 " cr
1 0 if ." Failed a final test of IF " else ." A final test of IF ... " if ." is passed " else ." is failed " then then cr ;


\ Test return stack words

: TESTRSTACKBASICS
." Testing >R, R@ and R> along with RDROP" cr
34 35 36 >R >R >R R@ 34 = RDROP R@ 35 = AND RDROP R@ 36 = AND RDROP if ." >R, R@ and RDROP PASSED " else ." >R, R@ and RDROP FAILED" then cr
99 >R R> 99 = if ." R> PASSED " else ." R> FAILED " then cr ;

\ loop
: TESTBEGINEND
." Testing BEGIN ... END loop " 5 SPACES
32 BEGIN DUP EMIT 1+ DUP 127 > END ."  BEGIN ... END PASSED " CR ;

: TESTBEGINWHILE
." Testing BEGIN ... WHILE " 5 spaces
32 BEGIN DUP space hex . space decimal DUP 100 < IF DUP EMIT 1+ ELSE DUP 32 - EMIT 1+ WHILE DUP 110 = END ."  BEGIN ... WHILE passed " cr ;

\ Testing memory functions
: ZZ ." ', EXECUTE and C! PASSED " ;

: TESTINGTICK 
." Testing ', EXECUTE and C! " 5 spaces
hex 0x58 decimal ' ZZ 24 + C! ' XZ execute cr
\ Change back or else subsequent tests will break
." Testing one more time " 5 spaces
hex 0x5A decimal ' xz 24 + C! ' zZ exeCUTE  cr ;

: testcfetch 
." Testing C@" 5 spaces
' XOR 24 + c@ 88 = if ." C@ passed " else ." C@ FAILED " then cr ;

\ Dummy words to use in MOVE test
: ZM * ;
: ZD / ;
: reup decimal 68 ' ZM 25 + C! ;

: TESTINGMOVE
." Testing MOVE " 5 spaces
10 10 ZM 100 = IF ' ZM 24 + ' ZD 24 + 24 move 100 2 ' ZM execute 50 = IF ." MOVE passed " else ." MOVE FAILED " then cr else ." Test failure " then reup ;

: TESTFETCH
." Testing FETCH (and BASE)" 5 spaces
octal base fetch 10 = hex base fetch 0x10 = AND decimal base fetch 10 = AND if ." FETCH and BASE passed" ELSE ." FETCH and BASE FAILED" then cr ;
\ Test groupings

\ Memory tests
: TESTMEMORY
." Testing memory manipulation words" cr
TESTINGTICK testcfetch testingmove testchar testfetch
." Testing of memory code complete" cr ;

\ Test loops
: TESTLOOPS
." Running tests of looping " cr
TESTBEGINEND
testbeginwhile
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
VERIFYSOURCE
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
TESTHEX TESTDECIMAL TESTOCTAL VERIFYBINARY
." Verifying ENCSQ with this output " cr
." Verifying COMMENT " cr \ ." COMMENT verification failed " 
VERIFYDOT
." Basics tests and verifications over " cr
;


\ Run all the tests
: UTS
DECIMAL
." Running unit tests " cr
STACKOPTESTS
." Press enter to continue " GETLINE 
BASICSTESTS
." Press enter to continue " GETLINE
INTEGERTESTS
." Press enter to continue " GETLINE
LISTWORDSTESTS
." Press enter to continue " GETLINE
TESTCONDITIONALS
." Press enter to continue " GETLINE
RSTACKTESTS
." Press enter to continue " GETLINE
TESTLOOPS
." Press enter to continue " GETLINE
TESTMEMORY
." Press enter to continue " GETLINE
 ABORT" Verifying ABORTCOMM and leaving tests with this message "
;


