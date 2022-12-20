loadmodule ./modules/ncurses/ncurses.so
variable chx 
: main
initscr clear raw keypadstd noecho
S\" Type any character to see it in bold\n" printw
getch dup chx !
1 KEY_F =
if S" F1 Key pressed" printw else
S" The key pressed is " printw BOLDON chx 1 printw boldoff
then refresh getch endwin
;
