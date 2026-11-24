# Program: ob zagonu procesorja prek Telneta odda fiksen HTTP odgovor -
# nekakšen najpreprostejši mogoč "spletni strežnik"
#
# Vsak "sw" na Telnetov naslov (0xc000-0xffff, TELNETSel & datawrite) sproži
# oddajo spodnjih 8 bitov podatkovnega vodila kot en bajt prek Telneta.
# Odgovor pošljemo znak za znakom - brez tabele v pomnilniku, preprosto kot
# zaporedje "li r0, <znak>; sw r0, 0xc003" ukazov - kar ustreza nizu:
#
#   HTTP/1.1 200 OK
#   Content-Length: 22
#
#   <h1>Hello, MiMo!</h1>
#
# "Content-Length: 22" pove brskalniku vnaprej, koliko bajtov telesa
# odgovora naj pričakuje ("<h1>Hello, MiMo!</h1>\n" je dolgo natanko 22
# bajtov) - brez tega bi brskalnik čakal na več podatkov (ali na zaprtje
# povezave), saj naš Telnet po pošiljanju povezave ne zapre.
#
# Ker se pošiljanje sproži takoj ob zagonu (ne čaka na nikakršno zahtevo od
# stranke), gre za zelo grobo poenostavitev pravega HTTP strežnika: enak
# odgovor se odda ne glede na to, kaj (če sploh kaj) je klient poslal, in
# samo enkrat - po pošiljanju procesor obtiči v neskončni zanki.

main:   li   r0, 0x48        # 'H'
        sw   r0, 0xc003
        li   r0, 0x54        # 'T'
        sw   r0, 0xc003
        li   r0, 0x54        # 'T'
        sw   r0, 0xc003
        li   r0, 0x50        # 'P'
        sw   r0, 0xc003
        li   r0, 0x2f        # '/'
        sw   r0, 0xc003
        li   r0, 0x31        # '1'
        sw   r0, 0xc003
        li   r0, 0x2e        # '.'
        sw   r0, 0xc003
        li   r0, 0x31        # '1'
        sw   r0, 0xc003
        li   r0, 0x20        # ' '
        sw   r0, 0xc003
        li   r0, 0x32        # '2'
        sw   r0, 0xc003
        li   r0, 0x30        # '0'
        sw   r0, 0xc003
        li   r0, 0x30        # '0'
        sw   r0, 0xc003
        li   r0, 0x20        # ' '
        sw   r0, 0xc003
        li   r0, 0x4f        # 'O'
        sw   r0, 0xc003
        li   r0, 0x4b        # 'K'
        sw   r0, 0xc003
        li   r0, 0x0a        # '\n'
        sw   r0, 0xc003

        # Content-Length: 22
        li   r0, 0x43        # 'C'
        sw   r0, 0xc003
        li   r0, 0x6f        # 'o'
        sw   r0, 0xc003
        li   r0, 0x6e        # 'n'
        sw   r0, 0xc003
        li   r0, 0x74        # 't'
        sw   r0, 0xc003
        li   r0, 0x65        # 'e'
        sw   r0, 0xc003
        li   r0, 0x6e        # 'n'
        sw   r0, 0xc003
        li   r0, 0x74        # 't'
        sw   r0, 0xc003
        li   r0, 0x2d        # '-'
        sw   r0, 0xc003
        li   r0, 0x4c        # 'L'
        sw   r0, 0xc003
        li   r0, 0x65        # 'e'
        sw   r0, 0xc003
        li   r0, 0x6e        # 'n'
        sw   r0, 0xc003
        li   r0, 0x67        # 'g'
        sw   r0, 0xc003
        li   r0, 0x74        # 't'
        sw   r0, 0xc003
        li   r0, 0x68        # 'h'
        sw   r0, 0xc003
        li   r0, 0x3a        # ':'
        sw   r0, 0xc003
        li   r0, 0x20        # ' '
        sw   r0, 0xc003
        li   r0, 0x32        # '2'
        sw   r0, 0xc003
        li   r0, 0x32        # '2'
        sw   r0, 0xc003
        li   r0, 0x0a        # '\n'
        sw   r0, 0xc003
        li   r0, 0x0a        # '\n'  (prazna vrstica - konec glave)
        sw   r0, 0xc003

        # Telo (22 bajtov, glej Content-Length zgoraj)
        li   r0, 0x3c        # '<'
        sw   r0, 0xc003
        li   r0, 0x68        # 'h'
        sw   r0, 0xc003
        li   r0, 0x31        # '1'
        sw   r0, 0xc003
        li   r0, 0x3e        # '>'
        sw   r0, 0xc003
        li   r0, 0x48        # 'H'
        sw   r0, 0xc003
        li   r0, 0x65        # 'e'
        sw   r0, 0xc003
        li   r0, 0x6c        # 'l'
        sw   r0, 0xc003
        li   r0, 0x6c        # 'l'
        sw   r0, 0xc003
        li   r0, 0x6f        # 'o'
        sw   r0, 0xc003
        li   r0, 0x2c        # ','
        sw   r0, 0xc003
        li   r0, 0x20        # ' '
        sw   r0, 0xc003
        li   r0, 0x4d        # 'M'
        sw   r0, 0xc003
        li   r0, 0x69        # 'i'
        sw   r0, 0xc003
        li   r0, 0x4d        # 'M'
        sw   r0, 0xc003
        li   r0, 0x6f        # 'o'
        sw   r0, 0xc003
        li   r0, 0x21        # '!'
        sw   r0, 0xc003
        li   r0, 0x3c        # '<'
        sw   r0, 0xc003
        li   r0, 0x2f        # '/'
        sw   r0, 0xc003
        li   r0, 0x68        # 'h'
        sw   r0, 0xc003
        li   r0, 0x31        # '1'
        sw   r0, 0xc003
        li   r0, 0x3e        # '>'
        sw   r0, 0xc003
        li   r0, 0x0a        # '\n'
        sw   r0, 0xc003

end:    jmp  end             # konec - odgovor je bil poslan enkrat
