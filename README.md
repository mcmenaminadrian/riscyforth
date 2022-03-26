An assembly-based FORTH for RISC-V SBCs
Licensed under GPL v2

Riscyforth is compiled and tested on the RVBoards Nezha 64-bit single board Risc-V computer (running Debian Linux with GNU Libc). Other boards will be added as they become
available. 

To understand your rights and obligations with this code please read (version 2 of) the GNU General Public Licence which is included with this software. Contributions and suggestions are welcome.

If you distribute this code (you are free to do so), you **must** include a copy of the GNU GPL in your redistribution as well as meet all the other obligations in the licence.

Riscyforth is still under development and is moving (much) closer to the Forth 2012 standard. Not quite all the words in the standard are yet implemented, but the list is growing.

To see the words currently available start Riscyforth and run the **WORDS** command. For reasons to do with the macros used in the RISC V assembly, some words are listed in their long form and not their more familiar form - e.g., **0=** is listed as **ZEROEQUALS** but the 0= form will be correctly handled in any program.

You can see the Forth standard here: [https://forth-standard.org/]

***To run Riscyforth***

Clone the repo

cd < riscyforth directory >

make

./riscyforth

Copyright, Adrian McMenamin, 2020, 2021, 2022
