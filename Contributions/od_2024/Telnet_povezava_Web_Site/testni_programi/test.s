main:   li r7, 0x4000       # inicializiramo kazalec na sklad
        li r0, 0x0          # v register r0 naložimo začetno vrednost 0 (naš števec)
        li r1, 0xa          # v register r1 naložimo vrednost 10 (0xa v heksadecimalnem sistemu)
lab1:   jeq r0, r1, end     # preverimo če sta števec (r0) in meja (r1) enaka; če sta, skočimo na end
        
        # Dummy loop
        li r2, 0x2          # v register r2 naložimo poljubno vrednost (npr. 2)
        neg r2              # vrednost obrnemo (negiramo)
        push r2             # potisnemo jo na sklad (naredi se 10-krat)
        
        addi r0, r0, 0x1    # vrednosti v r0 (števcu) dodamo 1
        jmp lab1            # skok nazaj na lab1, kjer se ponovno preveri pogoj
end:	li r6, 0x42			# nastavimo r7 na 0x42, kot znak konca    
end2: 	jmp end2            # končamo program