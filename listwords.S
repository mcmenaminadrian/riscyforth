#Run through the dictionary listing all words flagged for use

                CODEHEADER WORDLIST, DUP, 0x01
                la t0, dictionary
  wordlist_fetch:
                lw t1, 0(t0)
                beq t1, zero, wordlist_get_next             #flag is zero, not for printing
                addi t1, t0, INSTWIDTH4                     #address of characters for name
                lw t2, INSTWIDTH3(t0)                       #length of name
                PUSH t0
                WRITESTRINGR t1, t2
                WRITECR
                WRITECHAR 0x0A
                POP t0
  wordlist_get_next:
                lw t1, INSTWIDTH2(t0)                       #next pointer
                beq t1, zero, wordlist_finished
                mv t0, t1
                j wordlist_fetch
  wordlist_finished:
                tail NEXT

