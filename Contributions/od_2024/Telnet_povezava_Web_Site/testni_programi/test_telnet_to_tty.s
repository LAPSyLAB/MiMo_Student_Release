# Program: sprejema znake preko Telneta in jih izpisuje na TTY zaslon
# (namesto da bi jih zgolj pošiljali nazaj preko Telneta - "echo").
#
# "activate receiving" (pomik Telnetove FIFO vrste na naslednji znak) je
# speljan na isti signal kot "activate sending" (TELNETSel & datawrite),
# zato se FIFO pomakne na naslednji znak vsakič, ko pišemo (sw) na Telnetov
# naslov (0xc000). Da bi prebrali naslednji znak, moramo torej po izpisu na
# TTY še enkrat zapisati na 0xc000 zgolj zato, da sprožimo ta pomik - kar
# ima stranski učinek, da se prebrani znak ob tem tudi dejansko pošlje
# nazaj preko Telneta, poleg izpisa na TTY.

main:   li   r7, 0            # r7 = 0, za primerjave (jeq potrebuje 2 registra)

loop:   lw   r0, 0xc000       # preberi RX besedo iz Telneta
        andi r1, r0, 0x100    # izloči zastavico "nov znak na voljo"
        jeq  r1, r7, loop     # čakaj, dokler znak ni na voljo

        andi r2, r0, 0xff     # izloči dejanski prejeti znak (spodnjih 8 bitov)
        sw   r2, 0x4000       # izpiši znak na TTY zaslon

        sw   r2, 0xc000       # zapiši nazaj na Telnetov naslov SAMO zato, da
                               # sprožimo "pop" naslednjega znaka iz FIFO
                               # (glej zgornjo opombo - to znak tudi dejansko
                               # pošlje nazaj preko Telneta)

        jmp  loop
