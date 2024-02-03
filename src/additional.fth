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

\ add a character to a string
:  c$+!
    ( saddr char -- )
    >R                          \ save the character
    DUP @ 1+ 
    , HERE >R                   \ get the old length, add 1, store on R stack, set new address to R stack
    @ >R                        \ put old length on R stack
    @                           \ get read address
    0 R> DO DUP C@ C, 1+ -1 +LOOP      \ copy characters
    DROP
    R>
    R> C,                       \ save the character
    !                           \ save the updated address
;
    
