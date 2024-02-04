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


\ string commands - as in GForth

: str=           \ str-equals
  ( c-addr1 u1 c-addr2 u2 -- f)
  \ test length first
  2>R 2>R -1
  2R> 2R>
  >R swap R@ 
  = FALSE = IF 2DROP DROP 0
  ELSE
  \ now test character equality
     R@ 0 DO 2DUP C@ SWAP C@ = FALSE = IF 2DROP DROP 0 1 2 LEAVE THEN 1+ SWAP 1+ LOOP
  THEN
      R> DROP 2DROP
;

: count-trailing      \ count trailing spaces
  ( c-addr u -- u )
  0 >R
  DUP >R
  + 1-
  0 R> DO DUP C@ 32 = FALSE = IF LEAVE ELSE R> 1+ >R 1- -1 -LOOP THEN
  DROP R>
;

