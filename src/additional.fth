\ Define some words in Forth that might be useful for compatibility reasons

\ obsolete word replaced by parse-name
: parse-word
    ( "name" -- c-addr u)
    parse-name
;

\ set an address to true
: on
    ( a-addr --)
    true swap !
;

\ set an address to false
: off
    ( a-addr --)
    false swap !
;

\ drop 3 from stack
: 3DROP
  ( n n n -- )
  2DROP DROP
;

\ string commands - as in GForth

: count-trailing      \ count trailing spaces
  ( c-addr u -- u )
  0 >R
  DUP >R
  + 1-
  0 R> DO DUP C@ 32 <> IF LEAVE ELSE R> 1+ >R 1- -1 -LOOP THEN
  DROP R>
;


: -trailing           \ remove trailing spaces
  ( c_addr u1 -- c_addr u2 )
  2DUP count-trailing
  -
;

\ read characters at two addresses
: 2C@
  ( addr1 addr2 -- c1 c2)
  C@ SWAP C@ SWAP
;


: str==           \ str-equals - strict equality
  ( c-addr1 u1 c-addr2 u2 -- f )
  \ test length first
  2>R 2>R -1
  2R> 2R>
  >R SWAP R@
  <> IF 3DROP 0 1 2
  ELSE
  \ now test character equality
     R@ 0 DO 2DUP C@ SWAP C@ <> IF 3DROP 0 1 2 LEAVE THEN 1+ SWAP 1+ LOOP
  THEN
      RDROP 2DROP
;


: str=           \ lexical comparison
  ( c-addr1 u1 c-addr2 u2 -- f )
  2>R -TRAILING 2R> -TRAILING str==
;


: compare             \ lexical comparison -1 <, 0 =, 1 >
  ( caddr2 u2 caddr1 u1 -- n )
  2>R -TRAILING 2R> -TRAILING     \ remove trailing spaces
  2>R 2DUP                        \ addr2 u2 addr2 u2   R: addr1 u1
  2R> 2DUP 2>R                    \ addr2 u2 addr2 u2 addr1 u1   R: addr1 u1
  str= IF 2DROP 0                 \ 0  R: addr 1 u1
    ELSE                          \ addr2 u2    R: addr1 u1
    2R> >R SWAP R>                \ addr2 addr1 u2 u1 R:
    SWAP >R R@                    \ addr2 addr1 u1 u2 R: u2
    0 DO                          \ addr2 addr1 u1 R: u2
    DUP 1- I <                    \ addr2 addr1 u1 f R: u2
    IF R> 2DROP 2DROP 1 LEAVE
    THEN
    >R 2DUP 2C@                   \ addr2 addr1 c2 c1 R: u2 u1
    < IF
      2DROP -1 LEAVE
    THEN 2DUP 2C@ > IF
      2DROP 1 LEAVE THEN
    SWAP 1+ SWAP 1+
    I 1+ R> SWAP R@ = IF >R 2DROP -1 LEAVE THEN >R
    R> LOOP
  THEN
  2RDROP
;


: str<             \ lexical comparison
  ( caddr2 u2 caddr1 u1 -- f)
  compare -1 =
;


: str>            \ lexical comparison
  ( caddr2 u2 caddr1 u1 -- f)
  compare 1 =
;


: find-char \ find a character in a string
    ( a u c -- u f )
    >R .s 0 DO          \ a R: c
    DUP C@ R@ =         \ a f R: c
    IF DROP I -1 LEAVE  \ l -1 R: c
    ELSE
      1+ LOOP
    THEN
    -1 = IF -1
    ELSE
      0 0
    THEN RDROP
;


\ search str1 for str2 = f indicates success of search, u3 is remaining length of str1 at found point
: search
  ( ca1 u1 ca2 u2 -- ca3 u3 f) 
  2>R DUP                              \ CA U u1 R: ca2 u2
  0 DO                                 \ CA U R: ca2 u2
    DUP                                \ CA U U R: ca2 u2
    I -                                \ CA U u R: ca2 u2
    R@                                 \ CA U u u2 R: ca2 u2
    < IF 0 LEAVE
    ELSE                               \ CA U R: ca2 u2
      SWAP DUP                         \ U CA CA R: ca2 u2
      I +                              \ U CA ca R: ca2 u2
      >R SWAP R>                       \ CA U ca R: ca2 u2
      R@ 2R@                           \ CA U ca u2 ca2 u2 R: ca2 u2
      str=                             \ CA U f R: ca2 u2
      IF                               \ CA U R: ca2 u2
        I - SWAP I + SWAP -1 LEAVE
      THEN                             \ CA U R: ca2 u2 
    THEN                               \ CA U R: ca2 u2
  LOOP
  DUP -1 <> IF 0
  THEN 2RDROP
;

\ is str2 a prefix of str1?
: string-prefix?
  ( ca1 u1 ca2 u2 -- f)
  >R SWAP >R                          \ ca1 ca2     R: u2 u1
  2R@ > IF 2DROP 2RDROP 0
  ELSE                                \ ca1 ca2 R: u2 u1
    RDROP R> DUP                      \ ca1 ca2 u2 u2  
    -ROT
    str==
  THEN
;

\ copy u from c-from to c-to going from low to high addresses
: cmove
  ( c-from c-to u -- )
   0 DO 2DUP SWAP C@  SWAP C! SWAP 1+ SWAP 1+ LOOP
   2DROP
;

\ copy u from c-from to c-to going from higher to lower addresses
: cmove>
  ( c-from c-to u -- )
  >R
  R@ 1- + SWAP R@ 1- + SWAP
  R> 0 DO 2DUP SWAP C@ SWAP C! SWAP 1- SWAP 1- LOOP
  2DROP
;
 
\ fill caddr with u spaces
: blank
  ( caddr u -- )
  32 fill
;


\ remove n characters from start of string
: /string
  ( c-addr1 u1 n -- caddr2 u2 )
  >R
  DUP R@ <  IF 2DUP BLANK DROP 0 RDROP
  ELSE
    2DUP SWAP R@ + SWAP R@ -
    2SWAP DROP SWAP 2>R 2R@ MOVE
    2R> RDROP
  THEN
;

\ create an address 2-tuple
: bounds
  ( addr u -- addr+u addr)
  2>R 2R@ + 2R> DROP
;

\ convert an integer to a counted string
: >STRING
  ( n -- c-addr )
  0 >R                                             \ length 0 on stack
  PAD SWAP
  BEGIN
  DUP
  0<>
  WHILE
    10 /MOD
    SWAP 48 +
    ROT DUP >R
    C!
    R> CHAR+ SWAP
    R> 1+ >R
  REPEAT
  2DROP
  R@ CELL+ ALLOCATE 0=
  IF
    DUP
    R@ SWAP !
    DUP
    CELL+
    R@ 0 DO DUP R@ 1- I - PAD + C@
    SWAP C! CHAR+ LOOP
    DROP RDROP
 ELSE ABORT" Allocation failed."
 THEN ;


: AT-XY
  ( x y -- )
  \ Generate and evaluate TERMIOSSTRING "y;xH"
    DECIMAL 32 ALLOCATE 0=                    \ allocate space for string command
    IF                                        \ proceed if allocation succeeded
     >R                                       \ copy the allocated address to return stack R: (addr)
     C" TERMIOSSTRING "                       \ get a counted string for the first part of the command
     DUP @ R@ !                               \ write initial count to memory location
     DUP
     @ 0 DO                                   \ limit index
       DUP I +                                \ update address by index and duplicate
       CELL+ C@                               \ get character
       R@ CELL+ I +                           \ address to copy to
       C!                                     \ copy
     LOOP
     DROP
     R@ @                                     \ current length of final string
     CHAR+                                    \ increase by 1
     R@  !                                    \ update length
     34                                       \ "
     R@ @ 1- CELL+ R@ + C!                    \ write out
     >STRING DUP >R
     @ 0 DO 
       R@ CELL+ I + C@                        \ character to write out
       2R> SWAP DUP @ 1+ 1 PICK ! SWAP 2>R    \ update length
       2R@ DROP @ 1- CELL+ 2R@ DROP + C!      \ write out
     LOOP
     R> FREE DROP
     R@ @
     CHAR+
     R@ !
     59                                       \ ;
     R@ @ 1- CELL+ R@ + C!
     >STRING DUP >R
     @ 0 DO 
       R@ CELL+ I + C@                        \ character to write out
       2R> SWAP DUP @ 1+ 1 PICK ! SWAP 2>R    \ update length
       2R@ DROP @ 1- CELL+ 2R@ DROP + C!      \ write out
     LOOP
     DROP
     R> FREE DROP
     R@ 8 + R@ @
     CHAR+
     R@ !
     72                                       \ H
     R@ @ 1- CELL+ R@ + C!
     R@ @
     CHAR+
     R@ !
     34                                       \ "
     R@ @ 1- CELL+ R@ + C!
     R@ 8 + R@ @ EVALUATE
     R> FREE DROP
  ELSE
    ABORT" Memory allocation failure in AT-XY"
  THEN 
  ;

\ Test memory word result
: _MEM_TEST_ERR_
  ( u -- )
  0<> IF ABORT" Heap memory failure" THEN ;

\ Concatenate two strings and save on heap
: S+
  ( addr1 u1 addr2 u2 -- addr3 u3 )
  2>R
  DUP
  R@ +                                         \ stack now: addr1 u1 u3                 R-stack: addr2 u2
  >R R@ ALLOCATE _MEM_TEST_ERR_                \ stack: addr1 u1 addr3                  R-stack: addr2 u2 u3
  >R R@ SWAP >R R@                             \ stack: addr1 addr3 u1                  R-stack: addr2 u2 u3 addr3 u1
  MOVE                                         \ stack:                                 R-stack: addr2 u2 u3 addr3 u1
  2R@ +                                        \ stack: t-addr                          R-stack: addr2 u2 u3 addr3 u1
  RDROP                                        \ stack: t-addr                          R-stack: addr2 u2 u3 addr3
  2R>                                          \ stack: t-addr u3 addr3                 R-stack: addr2 u2
  2 PICK                                       \ stack: t-addr u3 addr3 t-addr          R-stack: addr2 u2
  2R>                                          \ stack: t-addr u3 addr3 t-addr addr2 u2
  ROT SWAP                                     \ stack: t-addr u3 addr3 addr2 t-addr u2
  MOVE                                         \ stack: t-addr u3 addr3
  2>R DROP 2R> SWAP                            \ stack: addr3 u3
;
