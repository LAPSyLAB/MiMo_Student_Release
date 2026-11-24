# Obvezen del

## 2. Implementirani mikroukazi
### 2.1 `umn`/`umx` - Unsinged minimum/maximum
Ukaza v `Rd` shranita nepredznacen minimum/maximum registrov `Rs` in `Rt`

Koda (custom zapis):
```
[Instr.umn]: { flags: 1, aluop: ALU.SUB, op2sel: Op2.T_REG, next: 164 },

[Instr.umx]: { flags: 1, aluop: ALU.SUB, op2sel: Op2.T_REG, next: 165 },

[164]: { cond: Cond.C, t: 166, f: 167 },

[165]: { cond: Cond.C, t: 167, f: 166 },

[166]: { dwrite: 1, regsrc: RSrc.SRC_REG, next: 0 },

[167]: { dwrite: 1, regsrc: RSrc.T_REG, next: 0 },
```

Vizualizacija:
![[OR_Graph.png]]
## 2.2 `calli` - Call immediate
Ukaz deluje podobno kot ARM-ov `bl`. Zbirnik za "link" register uporabi `r7`.
```
[Instr.calli]: { imload: 1, pcload: 1, next: 148 },

[148]: { dwrite: 1, regsrc: RSrc.PC, pcload: 1, pcsel: PC.IMMED, next: 0 },
```
V prvem mikrociklu prevzame naslov podrutine in premakne PC na naslednji ukaz.
V drugem mikrociklu shrani PC naslednjega ukaza v `Rd` in skoci v podrutino.

Iz trivialne podrutine se vrnemo z `b lr` ali `bsp` (`ret` v zbirniku)
## 2.3 Skladovni ukazi
Sklad raste navzdol, zbirnik za sklad (stack pointer) uporablja `r6`.
### `swrdb` - Store word (register addressed) decrement before
Dekrementira `Rs` in v `MEM[Rs]` shrani vrednost `Rd`. 
```
[Instr.swrdb]: {
  swrite: 1,
  regsrc: RSrc.ALU,
  aluop: ALU.SUB,
  op2sel: Op2.ONE,
  next: Instr.swr,
},

[Instr.swr]: {
  datawrite: 1,
  datasel: Data.DST_REG,
  addrsel: Addr.SRC_REG,
  next: 0,
},
```
### `lwrti` - Load word (register addressed) then increment
V `Rd` nalozi vrednost iz `MEM[Rs]`, potem inkrementira `Rs`. 
```
[Instr.lwrti]: {
  dwrite: 1,
  regsrc: RSrc.DATA_BUS,
  addrsel: Addr.SRC_REG,
  next: 153,
},

[153]: {
  swrite: 1,
  regsrc: RSrc.ALU,
  aluop: ALU.ADD,
  op2sel: Op2.ONE,
  next: 0,
},
```

### `lwrti2`, `swrdb2` - dual verziji
Obstajata tudi variaciji ukazov, ki shranita/nalozita 2 registra. (`Rd` in `Rt`)

### `bsp` - branch (to) stack pop
Iz sklada vzame eno vrednost in jo nalozi v `PC`.
```
[Instr.bsp]: { imload: 1, addrsel: Addr.SRC_REG, next: 174 },

[174]: {
  swrite: 1,
  regsrc: RSrc.ALU,
  aluop: ALU.ADD,
  op2sel: Op2.ONE,
  next: 175,
},

[175]: { pcload: 1, pcsel: PC.IMMED, next: 0 },
```
1. mikrocikel si v `Immed` zapomni naslov za vrnitev
2. mikrocikel odsteje `SP`.
3. skoci na naslov za vrnitev.
## Testni programi
(celi programi so v `.remia` datotekah)

Za `umn`,`umx`:
```
start:
    mov r0, #123
    mov r1, #7
    
    umn r2, r0, r1
    umx r3, r0, r1

    umn r4, r1, r0
    umx r5, r1, r0

// atp registers should be: 123,7,7,123,7,123,0,0
inf: b inf
```

Za klic in skladovne ukaze:
```
// u16 putwstr(u16 *buf) - prints a zero terminated wide string to TTY
fn_putwstr:
    push    lr
    push    r1, r2
    xor     r1, r1, r1

putwstr_loop:
    lw      r2, [r0, r1] // load

    cmp     r2, #0
    beq     putwstr_exit // exit loop if char is zero

    // putchr callsite:
    push    r0          // backup r0
    mov     r0, r2      // put char in r0
    call    fn_putchr   // call the function
    pop     r0          // restore old r0

    inc     r1

    b putwstr_loop

putwstr_exit:
    mov r0, r1
    pop r1, r2
    ret
```

## 4. Naslovna logika
![[OR_NL.png]]
(Napravi SYS in RND nista implementirani)
## 5. GPIO enota
GPIO enota je preslikana kot

```
struct GPIO {
	u16 mode;
	u16 indata;
	u16 outdata;
	u16 _nothing;
	u16 clear;
	u16 set;
};
```
V vsakem izmed registrov je preslikanih le spodnjih 8 bitov.
GPIO enoti (a,b) se nahajata na 
```
$GPIOA    0x4028
$GPIOB    0x4032
```

# Dodatno delo / razlike od originala
## Mikroukazi - Control ROM
Kontrolni ROM ima 3 nove signale:
- flags (bo ALU posodobil zastavice)
- twrite (pisanje v `Rt`)
- withcarry (bo ALU uposteval carry)
Poleg tega ima `Regsrc` novi opciji:
- `Rt`
- `PC`

## Mikrozbrinik
Mikrozbirnik sem zamenjal z typescript programom `fu`, ki hkrati vsebuje definicijo mikrokode. Poleg `.rom` datotek generira tudi `.dot` datoteko, ki opise usmerjen graf prehodov med mikroukazi.

## Zbirnik
Seznam ukazov iz mikrozbirnika potem uporabi zbirnik. Napisan je v Typescriptu in Ohm-u.
Zbirnik podpira konstante, vstavljanje datotek in vec formatov `string`-ov.
### Sintaksa
```
$STACK 0x1234
$TEST 123

.at 0 //eksplicitno se postavimo na zacetek
start:
	mov sp, #STACK // pripravimo sklad
	// ^ ta mov se prevede v `li`
	
	add r0, r0, r1
	add r0, r1 // <- ta dva add-a sta ekvivalentna
	
f: b f //neskoncna zanka

str:
.ascii "test"
.asciz "tst"
.utf16 "1 char = 1 word"

bin_thing:
.at 1000
.bin_include "datoteka.bin" // doda vsebino datoteke v koncno sliko programa

// za vec sintakse poglej .remia datoteke ali pa .ohm definicijo sintakse
// validne oblike instrukcij so razvidne iz kode (assembler.ts)
// opis machine ukazov se nahaja v isa.ts

// (prevod ukazov je 1:N, sw se lahko prevede v swi, swr, swri ali swrr)
// (nekateri ukazi so psevdoukazi (nop) ali pa so aliasi z dolocenimi registri (`push r0` je `swrdb r0, sp`))
```
## Uporaba
Oba projekta potreujeta `bun` (https://bun.sh).
### Generiranje mikrokode
```
cd fu
bun src/index.ts
```
### Prevajanje zbirnega jezika v strojni
```
cd remia
bun src/index.ts ./examples/gpiotest.remia > out/gpio.ram  
```