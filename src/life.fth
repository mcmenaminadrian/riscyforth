\ Conway's Game of Life in Forth (Riscyforth)
\ Copyright (c) Adrian McMenamin, 2022
\ Loosely inspired by the NCURSES How-To version
\ You may distribute this code or a modified version subject
\ to the terms of the GNU GPL, either version 2 or any later
\ version at your discretion
\ See https://github.com/mcmenaminadrian/riscyforth for latest code

loadmodule ./modules/ncurses/ncurses.so

0 constant startx
0 constant starty
160 constant endx
50 constant endy

variable grida
variable gridb
variable countup

variable scale
endx endy * scale !

: memsetup
    scale @ allocate 0<> IF ." ALLOCATE failed" exit then grida !
    scale @ allocate 0<> IF ." ALLOCATE failed" exit then  gridb !
    scale @ 0 do 0 i grida @ + C! 0 i gridb @ + C! loop
;

: memclean
    grida @ free
    gridb @ free
;

variable aheadx
variable behindx
variable aheady
variable behindy
variable currentpos


: updategrid
    \ swap the numbers about
    @ swap @ 
    grida ! gridb !
    endy starty do
        i 1+ endy mod aheady !
        i 1- endy mod dup 0< if endy + then behindy !
        endx startx do
            0 countup !
            i 1+ endx mod aheadx !
            i 1- endx mod dup 0< if endx + then behindx !
            \ all the aheadx
            aheadx @ behindy @ endx * +  gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            aheadx @ j endx * +  gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            aheadx @ aheady @ endx * +  gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            \ equal x
            i behindy @ endx * + gridb @ + C@ 1 = if countup @ 1+ countup ! then
            i aheady @ endx * + gridb @ + C@ 1 = if countup @ 1+ countup ! then
            \ behindx
            behindx @ behindy @ endx * + gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            behindx @ j endx * + gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            behindx @ aheady @ endx * + gridb @ + C@ 1 = IF countup @ 1+ countup ! then
            \ now update display grid
            i j endx * + dup currentpos !
            gridb @ + C@ currentpos @ grida @ + C!
            countup @ 3 > if 0 currentpos @ grida @ + C! then
            countup @ 3 = if 1 currentpos @ grida @ + C! then
            countup @ 2 < if 0 currentpos @ grida @ + C! then
        loop
    loop
;


: displaygrid
    endy starty  do
         endx startx do
            i j endx * + grida @ + C@
            1 = If j i 79 mvaddch else j i 32 mvaddch then
        loop
    loop
    refresh
;

variable rowpos 0 rowpos !
variable colpos 0 colpos !

: initgrid
  displaygrid
  rowpos @ colpos @ movestd
  begin getch dup 1 key_f <> \ F1 to end this
      while
         dup 259 = if rowpos @ 1- dup 0< if drop endy 1- then rowpos ! drop  else \ up arrow
             dup 260 = if colpos @ 1- dup 0< if drop endx 1- then colpos ! drop else \ left arrow
                 dup 261 = if colpos @ 1+ dup endx > if drop 0 then colpos ! drop else \ right arrow
                     258 = if rowpos @ 1+ dup endy > if drop 0 then rowpos ! else \ down arrow
                         rowpos @ endx * colpos @ + grida @ + C@ 0<> if 0 rowpos @ endx * colpos @ + grida @ + C! else 1 rowpos @ endx * colpos @ + grida @ + C! \ everything else toggles state
                         then displaygrid
                     then
                 then
             then
         then
      rowpos @ colpos @ movestd
      repeat
  scale @ 0 do i grida @ + C@ i gridb @ + C! loop 
;
            
             
: life
    memsetup
    initscr
    start_color
    2 COLOR_CYAN COLOR_BLACK init_pair
    1 COLOR_RED COLOR_BLACK init_pair
    2 color_pair attron
    boldon
    clear
    raw
    keypadstd
    noecho
    initgrid
    2 color_pair attroff
    clear
    1 color_pair attron
    displaygrid getch nodelayonstd
    begin getch 1 key_f <>  while grida gridb swap updategrid displaygrid repeat
    nodelayoffstd
    boldoff
    1 color_pair attroff
    memclean
    endwin
;

life   
