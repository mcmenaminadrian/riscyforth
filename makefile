PREFIX ?= /usr/local
main_dir = ${DESTDIR}${PREFIX}
man_dir = ${main_dir}/share/man

riscyforth: riscyforth.o
	ld --dynamic-linker=/lib/ld-linux-riscv64-lp64d.so.1 -o riscyforth riscyforth.o -lc -ldl -lriscy
riscyforth.o: *.S
	as -g riscyforth.S -o riscyforth.o
install:riscylib install-man
install-man:
	@echo Installing manuals to ${man_dir}
	@mkdir -p ${man_dir}/man1
	@cp riscyforth.1 ${man_dir}/man1/riscyforth.1 
.PHONY: riscylib
riscylib:
	$(MAKE) -C ./riscylib install
