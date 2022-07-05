floatmod: float.o
	ld --shared -o float.so float.o -lc -ldl -lriscy
float.o: float.S 
	gcc -c -fpic float.S -o float.o
