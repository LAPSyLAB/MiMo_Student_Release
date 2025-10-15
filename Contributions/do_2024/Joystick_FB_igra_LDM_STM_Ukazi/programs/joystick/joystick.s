main:   li r7, 0x0fff
        li r5, 0
loop:   jsr prep_horizontal
        jsr prep_vertical
        beq r1, r5, skip
        jsr reset
skip:   jsr write   
        br loop

reset:  sw r0, 0x4fff
        move r5, r2
        rts

write:  swi r0, r1, 0x4000
        rts


prep_horizontal:        stm {r1-r2}
                        lw r2, 0xC010
                        li r1, 1
                        lsl r0, r1, r2
                        ldm {r1-r2}
                        rts

prep_vertical:          lw r1, 0xC011
                        rts
        

        
