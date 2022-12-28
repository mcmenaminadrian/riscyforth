loadmodule ./modules/ncurses/ncurses.so

0 constant startx
0 constant starty
79 constant endx
24 constant endy

variable grida
variable gridb
variable countup

variable scale
endx endy * scale !

: memsetup
    scale @  allocate drop grida !
    scale @  allocate drop gridb !
    scale @ 0 do i grida + 0 swap C! i gridb + 0 swap C! loop
;

: memclean
    grida free
    gridb free
;

variable aheadx
variable behindx
variable aheady
variable behindy


: updategrid
    grida ! gridb !
    endy starty do
        i 1+ endy mod aheady !
        i 1- endy mod behindy !
        endx startx do
            0 countup !
            i 1+ endx mod aheadx !
            i 1- endx mod behindx !
            \ all the aheadx
            aheadx @ behindy @ * gridb + C@ 1 = IF countup @ 1+ countup ! then
            aheadx @ j * gridb + C@ 1 = IF countup @ 1+ countup ! then
            aheadx @ aheady @ gridb + C@ 1 = IF countup @ 1+ countup ! then
            \ equal x
            i behindy @ * gridb + C@ 1 = if countup @ 1+ countup ! then
            i aheady @ * gridb + C@ 1 = if countup @ 1+ countup ! then
            \ behindx
            behindx @ behindy @ * gridb + C@ 1 = IF countup @ 1+ countup ! then
            behindx @ j * gridb + C@ 1 = IF countup @ 1+ countup ! then
            behindx @ aheady @ gridb + C@ 1 = IF countup @ 1+ countup ! then
            \ now update display grid
            countup @ 3 > IF 0 i j * grida + C! else countup @ 3 = if 1 i j * grida + C! else countup @ 2 < IF 0 i j * grida + C! then
        loop
    loop
;


: display
    endy starty  do
         endx startx do
            i j * grida + C@
            1 = If j i 55 mvaddch else j i 32 mvaddch then
        loop
    loop
    refresh
;

: initgrid
  1 39 15 * grida + C!
  1 40 15 * grida + C!
  1 41 15 * grida + C!
  1 39 16 * grida + C!
  1 39 17 * grida + C!
  1 41 16 * grida + C!
  1 41 17 * grida + C!
  1 39 20 * grida + C!
  scale @ 0 do i grida + C@ i gridb + C! loop 
;
            
             
: life
    memsetup
    initscr
    clear
    raw
    keypadstd
    noecho
    initgrid
    display
    begin getch 1 key_f = while grida gridb swap updategrid display repeat
    memclean
    endwin
;   


