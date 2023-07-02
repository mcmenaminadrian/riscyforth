floatmod: float.o floatc.o
	ld --shared -o float.so float.o floatc.o -lc -ldl -lriscy -lm
float.o: float.S 
	gcc -c -fPIC float.S -o float.o
floatc.o: float.c
	gcc -c -g -fPIC float.c -o floatc.o
