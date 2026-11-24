# Testni program za dodatno VI napravo (Telnet)
#
# Naslovni dekoder (Address_Decoder) gleda ZGORNJA 2 bita naslova (A15,A14):
#   00 -> RAM     (0x0000-0x3FFF)
#   01 -> TTY     (0x4000-0x7FFF)
#   10 -> FB_LED  (0x8000-0xBFFF)
#   11 -> output_3 / TELNETSel  (0xC000-0xFFFF)   <-- naša naprava
#
# Ko sta oba zgornja bita naslova enaka 1 (naslov v obsegu 0xC000-0xFFFF),
# postane aktiven TELNETSel. Skupaj z datawrite (ki ga generira vsak "sw"
# ukaz) to sproži pulz, ki preko CLK naroči Telnet napravi, naj odda
# spodnjih 8 bitov podatkovnega vodila.
#
# Kateri koli naslov znotraj 0xC000-0xFFFF deluje (nepopolno naslovno
# dekodiranje, spodnjih 14 bitov je "reserved") - izbrali smo 0xC003.

main:   li   r0, 0x00        # r0 = podatek, ki ga pošiljamo (začnemo z 0x00)
        li   r1, 0x100       # r1 = zgornja meja (0xFF + 1) -> zajamemo cel bajt

loop:   sw   r0, 0xc003      # zapiši r0 na naslov v 0xC000-0xFFFF -> TELNETSel & datawrite -> pošlji bajt
        addi r0, r0, 0x1     # r0++
        jeq  r0, r1, reset   # ko r0 doseže 0x100, ponastavi na 0
        jmp  loop

reset:  li   r0, 0x00        # nazaj na začetek zaporedja
        jmp  loop