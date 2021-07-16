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


: runTests
testDrop2 testSquare
testCube testMUL
testNIP2
;


