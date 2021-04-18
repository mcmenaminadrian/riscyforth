#       This is the outer loop - a secodary

.balign 8
outer_loop:
          .4byte WA_TYPE
	  .4byte WA_GETSTDIN
          .4byte WA_GETNEXTLINE_IMM 
outer_loop_tokenize:
          .4byte WA_TOKENIZE_IMM
          .4byte WA_OK                #fallback
          .4byte WA_OLSEMI

