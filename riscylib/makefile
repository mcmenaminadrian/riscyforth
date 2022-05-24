riscy: riscy.o riscyA.o
	ld --shared -o libriscy.so riscy.o riscyA.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	gcc -c riscy.S -o riscyA.o

