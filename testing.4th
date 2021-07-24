\ Unit tests


\ Stack operations tests

: testOVER2
[ Testing OVER2 ] 5 SPACES
10 30 50 90 70 OVER2
50 = SWAP 30 = AND IF [ OVER2 passed ] else [ OVER2 failed ] then cr
;

: testDrop2
[ Testing DROP2 ] 5 spaces
99 2 3 4
drop2
2 = if [ DROP2 passed ] else [ DROP2 failed ] then cr
;

: testSquare
[ Testing SQUARE ] 5 spaces
7 square
49 = if [ SQUARE passed ] else [ SQUARE failed ] then cr
;

: testCube
[ Testing CUBE ] 5 spaces
5 cube
125 = if [ CUBE passed ] else [ CUBE failed ] then 5 spaces
3 cube
28 = if [ CUBE failed ] else [ CUBE passed ] then cr
;

: testMUL
[ Testing MUL ] 5 spaces
5 5 5 * *
5 cube
= if [ MUL passed ] else [ MUL failed ] then cr
;

: testNIP2
[ Testing NIP2 ] 5 spaces
10 20 30 40 50 NIP2
50 = SWAP 40 = AND SWAP 10 = AND if [ NIP2 passed ] else [ NIP2 failed ] then cr 
;

: testDUP2
[ Testing DUP2 ] 5 SPACES
900 800 700 DUP2
700 = SWAP 800 = AND SWAP 700 = AND SWAP 800 = AND if [ DUP2 passed] else [ DUP2 failed ] then cr
;

: testOVER2
[ Testing OVER2 ] 5 spaces
1 2 3 4 5 6 7 8 OVER2
6 = swap 5 = and swap 8 = and if [ OVER2 passed ] else [ OVER2 failed ] then cr
;

: testtuck2
[ Testing TUCK2 ] 5 spaces
1 2 3 4 5 6 TUCK2
6 = swap 5 = and swap 4 = and swap 3 = and swap 6 = and swap 5 = and if [ TUCK2 passed] else [ TUCK2 failed ] then cr
;

: testswap2
[ Testing SWAP2 ] 5 spaces
1 2 3 4 5 6 7 8 SWAP2
6 = swap 5 = and swap 8 = and if [ SWAP2 passed ] else [ SWAP2 failed ] then cr
;

: testrot2
[ Testing ROT2 ] 5 spaces
99 2 3 4 5 6 ROT2
2 = swap 99 = and swap 6 = and if [ ROT2 passed ] else [ ROT2 failed ] then cr
;

: TESTDUP
[ Testing DUP ] 5 spaces
34 45 DUP
45 = SWAP 45 = AND swap 34 = AND IF [ DUP passed ] else [ DUP failed ] then cr ;

\ Basic tests

: VERIFYTYPEPROMPT
[ Verifying TYPEPROMPT ] cr
TYPEPROMPT cr
;

: VERIFYGETNEXTLINE_IMM
[ Verifying GETNEXTLINE_IMM - please press RETURN only ] cr
GETNEXTLINE_IMM cr
;

: VERIFYOK
[ Verifying OK ] cr
OK cr
;

: VERIFYTOKENIZE_IMM
[ Verifying TOKENIZE_IMM ] cr
TOKENIZE_IMM
;

: VERIFYSEARCH
[ Verifying SEARCH ] cr
SEARCH
;

: TESTHEX
[ Testing HEX ] 5 SPACES
HEX 0x10 0xFF + DUP
0x10F = IF [ HEX passed with output 0x10F = ] . ELSE [ HEX failed with output 0x10F =  ] . then cr
\ ensure other tests keep testdup2
DECIMAL
;

: TESTDECIMAL
[ Testing DECIMAL ] 5 SPACES
DECIMAL 20 DUP
20 = IF [ DECIMAL passed wth output 20 = ] DUP . [ = ] HEX . DECIMAL ELSE [ DECIMAL failed with output 20 = ] DUP . [ = ] HEX . DECIMAL THEN CR
;

: TESTOCTAL [ Testing OCTAL ] 5 SPACES OCTAL 20 DUP DECIMAL 16 = IF [ OCTAL passed with output 20o = ] DUP OCTAL . [ = ] DECIMAL .
ELSE [ OCTAL failed with 20o = ] DUP OCTAL . [ = ] DECIMAL . THEN CR ;

: VERIFYBINARY [ Verifying BINARY  - ] 1 2 4 8 16 32 64 128 256 512
BINARY [ powers of 2 from 9 to 0 in binary... ] cr
. cr . cr . cr . cr . cr . cr . cr . cr . cr . cr DECIMAL ;

: VERIFYDOT
[ Verifying DOT ] 5 spaces 0 1 2 3 4 5
[ ... should see countdown from 5 to 0: ] . . . . . . CR ;

\ Test groupings

\ Group of stack operations tests
: STACKOPTESTS
[ Running stackop tests ] cr
testDrop2 testSquare
testCube testMUL
testNIP2 testDUP2
testOVER2 testtuck2
testtuck2 testswap2 testrot2 testdup
[ stackop tests over ] cr
;

\ Group of Basics tests
: BASICSTESTS
[ Running basics tests and verifications ] cr
VERIFYTYPEPROMPT
VERIFYGETNEXTLINE_IMM
VERIFYOK
VERIFYTOKENIZE_IMM 
VERIFYSEARCH OK
[ ***Above message on interpreter failure can be ignored*** ] CR
TESTHEX TESTDECIMAL TESTOCTAL VERIFYBINARY
[ Verifying ENCSQ with this output ] cr
[ Verifying COMMENT ] cr \ [ COMMENT verification failed ] 
VERIFYDOT
[ Basics tests and verifications over ] cr
;


\ Run all the tests
: UTS
DECIMAL
[ Running unit tests ] cr
STACKOPTESTS
[ Press enter to continue ] GETNEXTLINE_IMM OK
BASICSTESTS
[ Unit tests complete ] cr
;


