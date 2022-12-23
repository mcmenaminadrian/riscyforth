loadmodule ./modules/ncurses/ncurses.so
loadmodule ./modules/float/float.so
variable chx 
: main
initscr clear raw keypadstd noecho
S\" Well then\z" DROP  pi 8 7 6 5 4 3 2 1 19 5 S\" %i %i %i %i %i %i HELLO %i %%%i%% %f %s \n" mvprintw
\ S\" Type any character to see it in bold\n" printw
getch dup chx !
1 KEY_F =
if S" F1 Key pressed" printw else
S" The key pressed is " printw chx @ A_BOLD OR A_REVERSE OR A_BLINK OR addch
then refresh getch endwin
;
