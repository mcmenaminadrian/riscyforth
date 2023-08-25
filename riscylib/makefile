ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

install: libriscy.so.1.0
	install -d $(DESTDIR)$(PREFIX)/lib/
	install -m 644 libriscy.so.1 $(DESTDIR)$(PREFIX)/lib/
	ln -s $(DESTDIR)$(PREFIX)/lib/libriscy.so.1 $(DESTDIR)$(PREFIX)/lib/libriscy.so
riscy: riscy.o riscyA.o riscyinit.o
	ld -fpic --shared -o libriscy.so.1.0 riscy.o riscyA.o riscyinit.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c -fPIC riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	as -c -fpic riscy.S -o riscyA.o
riscyinit.o: riscyinit.c
	gcc -c -g -fpic riscyinit.c -o riscyinit.o

