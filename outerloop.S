#       This is the outer loop - a secodary

.balign 8
outer_loop:
          .4byte TYPE
          .4byte GETSTDIN
          .4byte GETNEXTLINE_IMM   # should loop forever
          .4byte OK                #fallback
          .4byte OLSEMI

