xfbmod: xframebuffer.o xframebufferc.o
	ld --shared -o xfb.so xframebuffer.o xframebufferc.o -lc -ldl -lriscy -lX11
xframebuffer.o: xframebuffer.S 
	gcc -c -fpic xframebuffer.S -o xframebuffer.o
xframebufferc.o: xframe.c
	gcc -c -g -fpic xframe.c -o xframebufferc.o
