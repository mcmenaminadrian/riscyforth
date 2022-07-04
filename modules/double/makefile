doublemod: double.o
	ld --shared -o double.so double.o -lc -ldl -lriscy
double.o: double.S 
	gcc -c -fpic double.S -o double.o
