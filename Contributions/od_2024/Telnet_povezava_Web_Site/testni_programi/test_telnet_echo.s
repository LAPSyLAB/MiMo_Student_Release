# Testni program: bere znake iz Telnet naprave in jih takoj pošlje nazaj
# (echo), da preverimo dvosmerno delovanje.
#
# Bralna beseda na naslovu 0xc000 (TELNETSel & !datawrite -> Telnet žene
# podatkovno vodilo nazaj proti CPU-ju) je sestavljena takole:
#   biti 0-7  = trenutni znak na čelu FIFO vrste (data out)
#   bit  8    = zastavica "znak na voljo" (data available, FIFO ni prazna)
#   biti 9-15 = 0 (padding)
#
# "activate receiving" (pomik FIFO vrste na naslednji znak) je speljan na
# isti signal kot "activate sending" (TELNETSel & datawrite). Vsak "sw" na
# 0xc000 zato naredi dvoje hkrati: odda bajt preko Telneta IN pomakne FIFO
# vrsto na naslednji znak. Spodnji "echo" sw ni le odgovor - je hkrati tudi
# zahteva za naslednji znak, zato zanka nikoli ne prehiti FIFO vrste in
# noben znak ni izgubljen.

main:   li   r7, 0            # r7 = 0, uporabljamo za primerjave (jeq potrebuje 2 registra)

loop:   lw   r0, 0xc000       # preberi Telnet: biti0-7=znak, bit8=data_available
        andi r1, r0, 0x100    # izloči zastavico "nov znak na voljo"
        jeq  r1, r7, loop     # če zastavica ni postavljena (r1==0), poizvedujemo naprej

        andi r2, r0, 0xff     # izloči dejanski prejeti znak (spodnjih 8 bitov)
        sw   r2, 0xc000       # pošlji ga takoj nazaj (echo) preko Telnet naprave

        jmp  loop
