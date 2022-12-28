\ Define some words in Forth that might be useful for compatibility reasons

: parse-word
    ( "name" -- c-addr u)
    parse-name
;

: on
    ( a-addr --)
    true swap !
;

: off
    ( a-addr --)
    false swap !
;
