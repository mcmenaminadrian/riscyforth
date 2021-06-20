riscyforth: riscyforth.o
	ld -o riscyforth riscyforth.o -lc
riscyforth.o: *.S
	as -g riscyforth.S -o riscyforth.o
