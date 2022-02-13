rmiciscyforth: riscyforth.o
	ld --dynamic-linker=/lib/ld-linux-riscv64-lp64d.so.1 -o riscyforth riscyforth.o -lc -lncurses
riscyforth.o: *.S
	as -g riscyforth.S -o riscyforth.o
