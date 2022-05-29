riscy: riscy.o riscyA.o
	ld -fpic --shared -o libriscy.so riscy.o riscyA.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c -fpic riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	as -c -fpic riscy.S -o riscyA.o

