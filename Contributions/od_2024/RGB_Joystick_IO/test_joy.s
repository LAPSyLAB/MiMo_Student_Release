        # Inicializacija Joy naprave
        li      r0, 1               # bit0 = 1 enable
        li      r5, 0x0080          # nariše srednja dva bita v 0. vrstico FB
        sw      r0, 0xC000            # 0xC000 = CTRL
        sw	r5, 16384		# nariše
        li      r3, 0x0080      # x pozicija
        li      r4, 16384       # y pozicija

main:   lw      r1, 0xC001           # 0xC001 = X
        lw      r2, 0xC002            # 0xC002 = Y

        subi    r6, r1, 5
        jltz    r6, left
        subi    r6, r1, 11
        jgtz    r6, right
        jmp     y_axis

left:   subi    r6, r3, 0x8000
        jeqz    r6, leftc
        lsli    r3, r3, 1
        jmp     y_axis

leftc:  li      r3, 1
        jmp     y_axis

right:  subi    r6, r3, 1
        jeqz    r6, rightc
        lsri    r3, r3, 1
        jmp     y_axis

rightc: li      r3, 0x8000
        jmp     y_axis

y_axis: subi    r6, r2, 5
        jltz    r6, up
        subi    r6, r2, 11
        jgtz    r6, down
        jmp     store

up:     subi    r6, r4, 16399
        jeqz    r6, upc
        addi    r4, r4, 1
        jmp     store

upc:    li      r4, 16384
        jmp     store

down:   subi    r6, r4, 16384
        jeqz    r6, downc
        addi    r4, r4, -1
        jmp     store

downc:  li      r4, 16399
        jmp     store

store:  swi     r3, r4, 0
        jmp     main
