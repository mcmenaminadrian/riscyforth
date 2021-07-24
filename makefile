riscyforth: riscyforth.o
	ld -o riscyforth riscyforth.o -lc -lncurses
riscyforth.o: *.S
	as -g riscyforth.S -o riscyforth.o
