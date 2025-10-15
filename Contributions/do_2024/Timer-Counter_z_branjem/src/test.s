main:  li r0, 1             # 2 + 2 - v r0 se naloži 0x1
       li r1, 4             # 2 + 2 - v r1 se naloži 0x4
       lsli r0, r0, 2       # 3 + 2 - pri r0 se biti premaknejo v levo za 2, 0x4
       jeq r0, r1, equal    # 3 + 2 - jump eqaul
       addi r0, r0, 1       # 3 + 2 - se ne izvede
equal: subc r2, r0, r1, end # 3 + 2 - r0 se odsteje r1, v r2 se naloži 0x0
       subi r1, r1, 1       # 3 + 2 - r1 se odsteje 1, 0x3
       bne r0, r1, noteq    # 3 + 2 - branch noteq
       andi r2, r2, 1       # 3 + 2 - se ne izvede
noteq: lsri r1, r1, 2       # 3 + 2 - pri r1 se biti premaknjejo v desno za 2, 0x0
       jltz r1, equal       # 3 + 2 - r1 == 0, n zastavica je 0, brez jump-a
       bnez r2, main        # 3 + 2 - r2 == 0, z zastavica je 1, brez branch-a
end:   jmp end              # 2 + 2 - neskončna zanka
#                             Skupaj urinih period: 30 + 22 = 52