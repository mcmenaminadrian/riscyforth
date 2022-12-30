loadmodule ./modules/ncurses/ncurses.so

0 constant startx
0 constant starty
120 constant endx
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
            1 = If j i 55 mvaddch else j i 32 mvaddch then
        loop
    loop
    refresh
;

: initgrid
  1 19 15 endx * + grida @ + C!
  1 20 15 endx * + grida @ + C!
  1 21 15 endx * + grida @ + C!
  1 19 16 endx * + grida @ + C!
  1 19 17 endx * + grida @ + C!
  1 21 16 endx * + grida @ + C!
  1 21 17 endx * + grida @ + C!
  1 19 18 endx * + grida @ + C!
  1 39 16 endx * + grida @ + C!
  1 40 16 endx * + grida @ + C!
  1 41 16 endx * + grida @ + C!
  1 39 17 endx * + grida @ + C!
  1 39 18 endx * + grida @ + C!
  1 41 17 endx * + grida @ + C!
  1 41 18 endx * + grida @ + C!
  1 0 0 endx * + grida @ + C!
  scale @ 0 do i grida @ + C@ i gridb @ + C! loop 
;
            
             
: life
    memsetup
    initscr
    clear
    raw
    keypadstd
    noecho
    initgrid
    displaygrid
    begin getch 1 key_f = while grida gridb swap updategrid displaygrid repeat
    memclean
    endwin
;   
