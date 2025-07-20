LOADMODULE ./modules/ncurses/ncurses.so
DROP
VARIABLE SA
VARIABLE SB
VARIABLE SC
VARIABLE N
VARIABLE TOTAL
VARIABLE POLES 2 CELLS ALLOT         \ number of counters on each pole
VARIABLE NUMBERS 74 CELLS ALLOT      \ which counters are on each pole


: GETCOUNTERNUMBER
  ( pole index -- n)
  SWAP
  [ DECIMAL 25 ] LITERAL * + CELLS
  NUMBERS + @
;
  
: DRAWBASE
 ( -- )
 [ DECIMAL 66 ] LITERAL COLOR_PAIR ATTRON
 3 0 DO
   21 0 DO
     [ DECIMAL 30 ] LITERAL [ DECIMAL 30 ] LITERAL J 20 * + I + [ DECIMAL 32 ] LITERAL mvaddch drop
   loop
 loop
 [ DECIMAL 66 ] LITERAL COLOR_PAIR ATTROFF
;

: CLEARPOLES
 ( -- )
 0 COLOR_PAIR ATTRON
 TOTAL @ 0 DO
   [ DECIMAL 10 ] LITERAL 0 DO
     [ DECIMAL 29 ] LITERAL J - >R
     R@ [ DECIMAL 40 ] LITERAL I - 32 MVADDCH DROP
     R@ [ DECIMAL 40 ] LITERAL I + 32 MVADDCH DROP
     R@ [ DECIMAL 61 ] LITERAL I - 32 MVADDCH DROP
     R@ [ DECIMAL 61 ] LITERAL I + 32 MVADDCH DROP
     R@ [ DECIMAL 82 ] LITERAL I - 32 MVADDCH DROP
     R> [ DECIMAL 82 ] LITERAL I + 32 MVADDCH DROP
   LOOP
 LOOP
 0 COLOR_PAIR ATTROFF
;    


: DRAWPOLES
  ( -- )
  CLEARPOLES
  [ DECIMAL 18 ] LITERAL COLOR_PAIR
  ATTRON
  TOTAL @ 0 DO
    [ DECIMAL 29 ] LITERAL I -
    >R R@
    [ DECIMAL 40 ] LITERAL [CHAR] | MVADDCH DROP
    R@
    [ DECIMAL 61 ] LITERAL [CHAR] | MVADDCH DROP
    R>
    [ DECIMAL 82 ] LITERAL [CHAR] | MVADDCH DROP
  LOOP 
  [ DECIMAL 18 ] LITERAL COLOR_PAIR ATTROFF
;

: DRAWCOUNTERS
 ( n -- )
 DUP
 CELLS POLES + @ 0> IF
   DUP
   CELLS POLES + @ 0 DO
     DUP >R
     I GETCOUNTERNUMBER DUP COLOR_PAIR ATTRON
     [ DECIMAL 20 ] LITERAL SWAP -
     DUP
     2 / 0 DO
       [ DECIMAL 29 ] LITERAL J - [ DECIMAL 40 ] LITERAL I - R@ 21 * + [CHAR] 0 MVADDCH DROP
       [ DECIMAL 29 ] LITERAL J - [ DECIMAL 40 ] LITERAL R@ 21 * + [CHAR] 0 MVADDCH DROP
       [ DECIMAL 29 ] LITERAL J - [ DECIMAL 40 ] LITERAL I + R@ 21 * + [CHAR] 0 MVADDCH DROP
     LOOP
     [ DECIMAL 20 ] LITERAL SWAP -
     COLOR_PAIR ATTROFF
     R>
   LOOP
 THEN
 DROP
; 

: DRAWTOWER
 DRAWPOLES
 0 DRAWCOUNTERS
 1 DRAWCOUNTERS
 2 DRAWCOUNTERS
 REFRESH
 DROP
;

: CHKPAIR
 ( n -- )
 -1 = IF
   ." INIT_PAIR fails" CR
   QUIT
 THEN
;

: ALLOCATECOUNTERS
 ( n -- )
 DECIMAL
 1 5 0 INIT_PAIR CHKPAIR
 2 17 0 INIT_PAIR CHKPAIR
 3 18 0 INIT_PAIR CHKPAIR
 4 19 0 INIT_PAIR CHKPAIR
 5 20 0 INIT_PAIR CHKPAIR
 6 21 0 INIT_PAIR CHKPAIR
 7 39 0 INIT_PAIR CHKPAIR
 8 38 0 INIT_PAIR CHKPAIR
 9 38 0 INIT_PAIR CHKPAIR
 10 36 0 INIT_PAIR CHKPAIR
 11 35 0 INIT_PAIR CHKPAIR
 12 84 0 INIT_PAIR CHKPAIR
 13 83 0 INIT_PAIR CHKPAIR
 14 82 0 INIT_PAIR CHKPAIR
 15 202 0 INIT_PAIR CHKPAIR
 16 172 0 INIT_PAIR CHKPAIR
 17 196 0 INIT_PAIR CHKPAIR
 18 124 0 INIT_PAIR CHKPAIR
 19 52 0 INIT_PAIR CHKPAIR
 66 0 124 INIT_PAIR CHKPAIR
 0 DO
   I 1+                                 \ simple initial in order allocation to first pole
   I CELLS NUMBERS + !
 LOOP
;


: HANOIINNER
 SC ! SB ! SA ! N !
 N @ 0= IF EXIT THEN
 N @ SA @ SB @ SC @
 N @ 1- SA @ SC @ SB @ RECURSE
 SC ! SB ! SA ! N !
 \ CR ." move a ring from " SA @ . ." to " SB @ . 

 \ get index to counter being moved
 POLES SA @ 1- CELLS + @                                 \ number of counters currently on SA
 1- CELLS                                                  \ convert to index
 SA @ 1- [ DECIMAL 25 ] LITERAL * CELLS + NUMBERS        \ index to SA pole
 +  @                                                      \ get the counter number
 POLES SB @ 1- CELLS + @                                 \ number of counters currently on SB
 CELLS                                                   \ convert to index to next position
 SB @ 1- [ DECIMAL 25 ] LITERAL  * CELLS + NUMBERS       \ index to SB pole
 +  !                                                     \ store the transferred counter there
 
  
 -1 POLES SA @ 1- CELLS + +!
 1 POLES SB @ 1- CELLS + +!
 DRAWTOWER
 N @ 1- SC @ SB @ SA @ RECURSE
;

: HANOI ( n -- n )
 DECIMAL
 1 2 3
 3 PICK DUP
 TOTAL !
 POLES !
 0 POLES 1 CELLS + !
 0 POLES 2 CELLS + !
 INITSCR CLEAR
 START_COLOR
 -1 = IF
   ENDWIN
   ." START_COLOR fails." CR
   QUIT
 THEN
 3 PICK
 ALLOCATECOUNTERS
 CURS_INVIS
 DRAWBASE
 DRAWTOWER
 GETCH DROP
 HANOIINNER
 DRAWTOWER
 GETCH DROP
 ENDWIN
 ." DONE " CR
;
