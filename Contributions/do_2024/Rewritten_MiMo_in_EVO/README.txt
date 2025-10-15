V "MiMo_OR_evo.circ" je shranjena moja verzija MiMo modela, narejena v logisim-evolution
(https://github.com/logisim-evolution/logisim-evolution). Morala bi biti funkcionalno enaka originalnemu
modelu (v0.4b OR) - vanj lahko naložiš isto mikrokodo in programe, in zadeva bi morala delovati. Med
razvojem sem kar precej testiral, ampak mogoče vsebuje kakšen hrošč, na katerega nisem naletel.

Seznam sprememb:
    - model je bil narejen od začetka, zato je struktura (in izgled) vezja precej drugačna. osnovno
      strukturo vezja sem poskusil ohraniti.
    - podvezja imajo zdaj enak izgled: ime podvezja je jasno označeno, vhodi so vedno na levi strani in so
      označeni, izhodi so vedno na desni strani in so označeni. stanje nekaterih notranjih registrov je
      vidno kar v grafični podobi podvezja, namesto tega, da podvezja potrebujejo zunanje prikazovalnike:
          - PC ima prikazano vrednost PC registra
          - IR ima prikazano vrednost IR registra
          - Registers ima prikazane vrednosti r0..r7, in tudi prikazan izbor registra Rt, Rs, Rd
          - ALU ima prikazane zastavice kar v grafični podobi podvezja
    - vezje je večje (večinoma zaradi velikosti RAM/ROM komponent)
    - 7-segmentnih prikazovalnikov za addr in data bus ni več - vse pomembne vrednosti so itak na
      dveh mestih (eno za registre in addr/databus, eno za mikroukaze in števce)
    - števci so zdaj konsistentni - začnejo z 0 in se povečajo za 1 vsakič, ko se zgodi določeni dogodek
      (npr. števec "Instruction Cycles" je zdaj enak števcu "Total Cycles", dokler se ne začne nov ukaz).
      to pomeni tudi, da je števec "Instruction Cycles" na zadnjem mikroukazu določenega ukaza enak
      dolžini ukaza - 1 (potem se pa ponastavi na 0).
    - logika števcev je zdaj v svojem podvezju "CycleCounter".
    - dodan je števec, ki šteje število ukazov (ne mikroukazov).
    - dodano je podvezje, ki pomaga pri razhroščevanjem programov "SuspendHelper". Nanj je povezan urin signal
      (Auto-Tick je vklopljen na visoki frekvenci), ki se pošlje naprej v vezje razen ob določenih pogojih:
          - aktiven je vhod "break_on_cycle" (urin signal takoj zaustavi)
          - aktiven je vhod "break_on_instr" in mikroprogramski števec je enak 0
            (urin signal zaustavi ob začetku vsakega novega ukaza)
          - aktiven je vhod "break_on_addr", mikroprogramski števec je enak 0 in programski števec je
            enak vhodu "break_addr" (urin signal zaustavi, ko program doseže določen naslov)
      urin signal lahko enkrat spustiš čez s pritiskom na gumb "continue". podvezje zazna spremembo v
      gumbu in spusti samo en urin signal, tudi če gumb držiš predolgo (da se ne preskoči kakšen breakpoint).
    - dodana je naprava GPIO, ki poskuša emulirati dvosmerne konektorje (glej "/naloge/5.txt").
    - nekateri tuneli v glavnem vezju so preimenovani:
          - CLK -> clk
          - RAM -> e_ram
          - FB_LED -> e_dev0
          - TTY -> e_dev1
          - immed -> imreg
          - pc -> pcreg
          - MicroPC -> ucounter
          - tregs -> tsel
          - sregs -> ssel
          - dregs -> dsel
    - dodan je opis večbitnih vrednosti v vizualizacijo mikroukaza
