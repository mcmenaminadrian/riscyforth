floatmod: float.o floatc.o
	ld --shared -o float.so float.o floatc.o -lc -ldl -lriscy
float.o: float.S 
	gcc -c -fpic float.S -o float.o
floatc.o: float.c
	gcc -c -fpic float.c -o floatc.o
