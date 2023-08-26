ifeq ($(PREFIX),)
	PREFIX := /usr
endif

libriscy.so.1.0: riscy.o riscyA.o riscyinit.o
	ld -fpic --shared -o libriscy.so.1.0 riscy.o riscyA.o riscyinit.o -lc -ldl
riscy.o: riscy.c riscyvar.S
	gcc -c -fPIC riscy.c -o riscy.o
riscyA.o: riscy.S riscyvar.S
	as -c -fpic riscy.S -o riscyA.o
riscyinit.o: riscyinit.c
	gcc -c -g -fpic riscyinit.c -o riscyinit.o
install: libriscy.so.1.0
	install -d $(DESTDIR)$(PREFIX)/lib/
	install -m 755 libriscy.so.1.0 $(DESTDIR)$(PREFIX)/lib/
	ln -svf $(DESTDIR)$(PREFIX)/lib/libriscy.so.1.0 $(DESTDIR)$(PREFIX)/lib/libriscy.so

