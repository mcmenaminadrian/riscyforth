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

: foxy S" the quick brown fox jumped over the lazy dog" ;
: quick S" quick" ;
: lazy S" lazy" ;
: laser S" lazer" ;

: test-search
." Searching..." foxy type CR
." FOR " laser type ." ..." foxy laser search IF type ELSE ." failed" THEN CR
." FOR " quick type ." ..." foxy quick search IF type ELSE ." failed" THEN CR
." FOR " lazy type ." ..." foxy lazy search IF type ELSE ." failed" THEN CR
." AND look for " laser type ." IN " lazy type ."  ..." lazy laser search IF type ELSE ." also failed." CR
;
test-search

bye

