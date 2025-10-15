        li      r7, 16383 # 0x3FFF - stack init

main:   jsr INIT_PIO
        li      r5,  30

loop:   dec     r5

        li      r0, 49152      # BASE_PIOA
        li      r1, 2           # pin 1

        jsr     PIN_OFF
        jsr     DELAY

        jsr     PIN_ON
        jsr     DELAY

        jgtz    r5, loop


inf:    jmp inf			    # infinity loop

INIT_PIO:   push    r0
            push    r1
            push    r2

            # BASE_PIOA = 49152
            # BASE_PIOB = 57344
            
            li      r0, 49152
            li      r1, 57344

            # ENABLE_INTERFACE = BASE + 0 
            # OUT_IN           = BASE + 2048
            # SET_CLR          = BASE + 4096

            li      r2, 2           # 0b1001 (pin1)

            swi	r2, r0, 0      # enable PIOA pin1
            swi	r2, r0, 2048   # output PIOA pin1
            swi	r2, r0, 4096   # set PIOA pin1

            li      r2, 5           # 0b1001 (pin2,0)

            swi	r2, r1, 0      # enable PIOB pin2,0
            swi	r2, r1, 2048   # output PIOB pin2,0
            swi	r2, r1, 4096   # set PIOB pin2,0

            pop    r2
            pop    r1
            pop    r0

            rts

PIN_ON:     push r2 # vrednost registra set/clear
            push r3 # rezultat
            # r0 -> inpit PIO address
            # r1 -> input pin 

            lwi	    r2, r0, 4096
            or      r3, r2, r1
            swi     r3, r0, 4096

            pop r3
            pop r2
            rts

PIN_OFF:    push r2 # vrednost registra set/clear
            push r3 # rezultat
            # r0 -> inpit PIO address
            # r1 -> input pin 

            lwi	    r2, r0, 4096
            nor      r3, r2, r1
            swi     r3, r0, 4096

            pop r3
            pop r2
            rts


DELAY:      push    r2
            li      r2, 30

loop1:      dec     r2
            jgtz    r2, loop1

            pop     r2
            rts
