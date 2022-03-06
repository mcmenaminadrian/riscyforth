#       This is the outer loop - a secondary

.balign 8
outer_loop:
          .8byte WA_TYPEPROMPT
          .8byte WA_GETNEXTLINE_IMM 
outer_loop_tokenize:
          .8byte WA_TOKENIZE_IMM
outer_loop_ok:
          .8byte WA_OK                #fallback
          .8byte WA_OLSEMI
