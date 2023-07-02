riscy: riscy.o riscyA.o
	ld -fPIC --shared -o libriscy.so riscy.o riscyA.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c -fPIC riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	as -c -fPIC riscy.S -o riscyA.o

