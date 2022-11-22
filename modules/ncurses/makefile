ncursesmod: ncurses.o
	ld --shared -o ncurses.so ncurses.o -lc -ldl -lriscy -lncurses
ncurses.o: ncurses.S 
	gcc -c -fpic ncurses.S -o ncurses.o
