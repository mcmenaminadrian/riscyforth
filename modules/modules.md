# Adding a module

Riscyforth allows you to add modules of words (written in assembly) in binary
form.

Modules are loaded as dynanmic libraries and their words are appended to the
Forth dictionary. (Riscyforth only has one dictionary.)

A module being added needs to be supplied with the address for the ***NEXT*** directive
and to be given the address of the current end of the dictionary. The module then
updates the address of the endf of the dictionary so that any subsequent module (or
colon word) can be added to the dictionary successfully.

This is accomplished by linking the module to another library - ___libriscy___.

The main Riscyforth executible is built linked to ___libriscy___ and do this
library allows for the passing of data between modules and the main executible.

### Code for your module

Your module needs to call functions in ___libriscy___ on startup to ensure that
your Forth words are added to the dictionary and function correctly.

Your module must also set aside some space to store the address of the ***NEXT***
directive so that calls to ***NEXT*** work.

The example below is taken from the first module - ___double.so___

>     .include "../macros.S"
>     .section .bss
>        .comm NEXTMOD, 8


Firstly, include the standard Riscyforth macros file.

Then create a ___.bss___ section to store data - here 8 bytes are set aside
for a named memory location ***NEXTMOD*** (which is where we will store the
address of next.

Your first word should use the ***CODEEND*** macro - this makes it look like
end of the dictionary (i.e. leave a space into which a link to the next word
can be inserted):

>     .section .text
>     .balign 8
>            CODEEND DABS, 0x01

As you are now writing code you have to declare a ___.text___ section.

Subsequent words can use the normal ***CODEHEADER*** or ***CODEHEADERZ*** macros.

Instead of the ***tail NEXT*** formulation used to end a word in the main
dictionary, you need to use a formulation like this:

>        la t1, NEXTMOD
>        ld t1, 0(t1)
>        jr t1

I.e., load the address into the register and then jump to the register (under the
hood this and a ***tail*** call are likely to be very similar so this may look
more inefficient but may not be and certainly won't be by much.)


### Initialisation code for your module

You need to write specific initialisation code for your module which should look
like this (without the line numbers obviously!)

>       1      starter:
>       2       PUSH ra
>       3       call getNextAddress     #get the address for tail return
>       4       la t0, NEXTMOD
>       5       sd a0, 0(t0)            #store the tail return address
>       6       la a0, DABS
>       7       addi a0, a0, -56
>       8       PUSH a0
>       9       li t3, 0xFFFFFFFFFFFFF000
>      10       and a0, a0, t3
>      11       li a1, 0x100
>      12       li a2, 0x7      #rw permissions
>      13       call mprotect
>      14       POP a0
>      15       addi a1, a0, 16
>      16       PUSH a1
>      17       call getDictionaryAddress
>      18       POP a1
>      19       sd a0, 0(a1)    #update lead word
>      20       la a0, DTOS     #new end of dictionary
>      21       addi a0, a0, -56
>      22       call setDictionaryAddress       #return new tail of dictionary to caller
>      23       POP ra
>      24       ret



So at line:

1:        Save the return address

2:        Get the address for ***NEXT*** (returned in register a0)

4 - 5:    Store the returned address

6 - 8:    Get the address of the currently null location we need to overwrite (see ***CODEEND*** above) and store for efficiency

9 - 12:   Set up call to ***mprotect*** (library call) calculataing page address,
asking for one page of protections to be changed and setting protection
to 0x07 (RWX)

13:       make call

14 - 19:  Get and write out joining address now we've fixed the permissions

20:       Get address of last word in this module (new end of dictionary)

21 - 22:  Pass this new end of dictionary to ___libriscy___

23 - 24:  Restore return address and return

### Init array section

Finally you need to create a new section that points to the start up code:

>     .section .init_array
>     .balign 8
>     .8byte starter



### Makefile

You need to explicitly link with ___libriscy___ e.g.:

>     doublemod: double.o
>             ld --shared -o double.so double.o -lc -ldl -lriscy
>     doubleobj: double.S
>             as -g double.S -o double.o





