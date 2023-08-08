**FORTH for RISC-V SBCs**

Licensed under the GNU General Public License, version 2 (or later)

Riscyforth has been compiled and tested on the RVBoards Nezha 64-bit single board RISC-V computer (running Debian Linux with GNU Libc). It should run on any RISC-V SBC running Linux. Most of Riscyforth is written in RISC-V assembly so it is not portable to other architectures. It is what it is.

To understand your rights and obligations with this code please read (version 2 of) the GNU General Public License which is included with this software. Contributions and suggestions are welcome.

If you distribute this code (you are free to do so), you **must** include a copy of the GNU GPL in your redistribution as well as meet all the other obligations in the licence.

Riscyforth is still under development. It is modelled closely on the Forth 2012 standard, though no guarentee of compatibility is offered. Various modules to extend the core code (e.g. to add floating point support) are also included.

Riscyforth is a 64 bit implementation of Forth (this is a key difference from GNU's GForth for instance). The standard cell size is 64 bits and integer maths is conducted with 64 bit numbers and so on.

To see the words currently available start Riscyforth and run the **WORDS** command. For reasons to do with the macros used in the RISC V assembly, some words are listed in their long form and not their more familiar form - e.g., **0=** is listed as **ZEROEQUALS** but the 0= form will be correctly handled in any program.

You can see the Forth standard here: [https://forth-standard.org/]

***To run Riscyforth***

Clone the repo

cd < riscyforth directory >

make

./riscyforth -u 

This will display a usage message and you can take it from there.

Copyright, Adrian McMenamin, 2020, 2021, 2022, 2023
