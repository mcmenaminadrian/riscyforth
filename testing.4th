\ Unit tests

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


\ Now the tests
: runTests
testDrop2 testSquare
testCube testMUL
testNIP2 testDUP2
testOVER2
;


