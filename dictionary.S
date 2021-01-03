#         RISCYFORTH dictionary
###############################

codeheader ADDITION, ADDITION
            popdata t0
            popdata t1
            add t2, t0, t1
            pushdata t2
            DONEXT

codeheader SUBTRACTION, ADDITION
            popdata t0
            popdata t1
            sub t2, t1, t0
            pushdata t2
            DONEXT

codeheader MULTIPLY, SUBTRACTION
            popdata t0
            popdata t1
            mul t2, t1, t0
            pushdata t2
            DONEXT

codeheader DIVIDE, MULTIPLY
            popdata t0
            popdata t1
            div t2, t1, t0
            pushdata t2
            DONEXT

codeheader CALC, DIVIDE
            la t0, 10
            pushdata t0
            la t0, 20
            pushdata t0
            ADDITION
            la t0, 7
            SUBTRACTION
            la t0, 5
            MULTIPLICATION
            la t0, 8
            DIVISION
            output arith_msg, len_arith_msg
            popdata t0
            csrw OUTREG, t0
            DONEXT

STARTUP:
            la s7, CALC
            DONEXT
            RUN
            j 0xFFFFFF

SEMI:       .word + 4
            popcall s7
            DONEXT 
RUN:        lw s6, 0(s8)
            addi s8, s8, 4
            jalr x0, s6, 0



NEXT:
            
