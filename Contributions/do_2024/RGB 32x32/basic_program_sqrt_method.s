# This program uses the instructions defined in the
# basic_microcode.def file.
# (c) Marcel Homšak, 2024

# Računanje korena z uporabo bisekcije

# Registri:
# r0: razlika mej
# r1: vnos
# r2: spodnja meja iskanja
# r3: zgornja meja iskanja
# r4: srednja točka
# r5: kvadrat srednje točke
# r6: rezultat (koren vnosa)
# r7: dovoljena razlika mej

start:      li r1, 361          # vnos
            li r2, 0            # spodnja meja iskanja = 0
            move r3, r1         # zgornja meja iskanja = vnos
            li r7, 1            # dovoljena razlika mej = 1

search:     addi r3, r3, 1      # zgornjo mejo povečamo za 1  

            # srednja točka je (spodnja_meja + zgornja_meja)/2
            add r4, r2, r3       
            lsri r4, r4, 1

            mul r5, r4, r4      # r5 = kvadrat srednje točke
            
            # če je kvadrat srednje točke enak vnosu
            jeq r5, r1, endperfect
            # če je kvadrat srednje točke manjši od vnosa    
            jlt r5, r1, updatelow
            # če je kvadrat srednje točke večji od vnosa
            jgt r5, r1, updateup

updatelow:  move r2, r4         # spodnja meja = srednja točka
            jmp checkdiff       # poglej če sta meji blizu

updateup:   move r3, r4         # zgornja meja = srednja točka
            jmp checkdiff       # poglej če sta meji blizu
                      
checkdiff:  sub r0, r3, r2      # r0 = zgornja_meja - spodnja_meja
            jle r0, r7, endlow  # razlika mej <= 1?
            jmp search          # sicer nadaljuj z iskanjem

endlow:     move r6, r2         # rezultat = spodnja meja
            jmp save            # shrani in končaj

endperfect: move r6, r4         # rezultat = natančen koren
            jmp save            # shrani in končaj

save:       sw r6, 48           # shrani v pomnilnik M[48] = rezultat
            jmp end

end:        jmp end             # mrtva zanka