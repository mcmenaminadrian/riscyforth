riscy: riscy.o riscyA.o riscyinit.o
	ld -fpic --shared -o libriscy.so riscy.o riscyA.o riscyinit.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c -fPIC riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	as -c -fpic riscy.S -o riscyA.o
riscyinit.o: riscyinit.c
	gcc -c -g -fpic riscyinit.c -o riscyinit.o

