export enum Instr {
    /**
     * **move** \
     * `Rd` = `Rs`
     */
    mov = 2,

    /**
     * **load immediate* \
     * `Rd` = `MEM[PC++]`
     */
    li,

    /**
     * **add** \
     * `Rd` = `Rs` + `Rt`
     */
    add,

    /**
     * **add immediate** \
     * `Rd` = `Rs` + `#i`
     */
    addi,

    /**
     * **subtract** \
     * `Rd` = `Rs` - `Rt`
     */
    sub,

    /**
     * **subtract immediate** \
     * `Rd` = `Rs` - `#i`
     */
    subi,

    /**
     * **multiply** \
     * `Rd` = `Rs` * `Rt`
     */
    mul,

    /**
     * **multiply immediate** \
     * `Rd` = `Rs` * `#i`
     */
    muli,

    /**
     * **divide** \
     * `Rd` = `Rs` / `Rt`
     */
    div,

    /**
     * **divide immediate** \
     * `Rd` = `Rs` / `#i`
     */
    divi,

    /**
     * **modulo** \
     * `Rd` = `Rs` % `Rt`
     */
    mod,

    /**
     * **modulo immediate** \
     * `Rd` = `Rs` % `#i`
     */
    modi,

    /**
     * **and** \
     * `Rd` = `Rs` & `Rt`
     */
    and,

    /**
     * **and immediate** \
     * `Rd` = `Rs` & `#i`
     */
    andi,

    /**
     * **or** \
     * `Rd` = `Rs` | `Rt`
     */
    orr,

    /**
     * **or immediate** \
     * `Rd` = `Rs` | `#i`
     */
    orri,

    /**
     * **exclusive or** \
     * `Rd` = `Rs` ^ `Rt`
     */
    xor,

    /**
     * **exclusive or immediate** \
     * `Rd` = `Rs` ^ `#i`
     */
    xori,

    /**
     * **nand** \
     * `Rd` = `Rs` nand `Rt`
     */
    nnd,

    /**
     * **nand immediate** \
     * `Rd` = `Rs` nand `#i`
     */
    nndi,

    /**
     * **nor** \
     * `Rd` = `Rs` nor `Rt`
     */
    nor,

    /**
     * **nor immediate** \
     * `Rd` = `Rs` nor `#i`
     */
    nori,

    /**
     * **not** \
     * `Rd` = ~`Rs`
     */
    not,

    /**
     * **idk why** \
     * `Rd` = ~`Rs` + wastes one word and an extra cycle 
     */
    noti,

    /**
     * **logical shift left** \
     * `Rd` = `Rs` << `Rt`
     */
    lsl,

    /**
     * **logical shift left immediate** \
     * `Rd` = `Rs` << `#i`
     */
    lsli,

    /**
     * **logical shift right** \
     * `Rd` = `Rs` >> `Rt` (logical)
     */
    lsr,

    /**
     * **logical shift right immediate** \
     * `Rd` = `Rs` >> `#i` (logical)
     */
    lsri,

    /**
     * **arithmetic shift right** \
     * `Rd` = `Rs` >> `Rt` (arithmetic)
     */
    asr,

    /**
     * **arithmetic shift right immediate** \
     * `Rd` = `Rs` >> `#i` (arithmetic)
     */
    asri,

    /**
     * **roll left** \
     * `Rd` = `rollLeft(Rs + Rt)`
     */
    rol,

    /**
     * **roll left immediate** \
     * `Rd` = `rollLeft(Rs + #i)`
     */
    roli,

    /**
     * **roll right** \
     * `Rd` = `rollRight(Rs, Rt)`
     */
    ror,

    /**
     * **roll right immediate** \
     * `Rd` = `rollRight(Rs, #i)`
     */
    rori,

    /**
     * **branch absolute** \
     * `PC` = `Rs` 
     */
    bar,

    /**
     * **branch absolute immediate** \
     * `PC` = `#i` 
     */
    bai,

    /**
     * **branch relative immediate** \
     * `PC` += `#i` 
     */
    bri,

    /**
     * **branch relative immediate if equal** \
     * if (`Zero`) then `PC` += `#i`
     */
    brieq,

    /**
     * **branch relative immediate if not equal** \
     * if (!`Zero`) then `PC` += `#i`
     */
    brine,

    /**
     * **branch relative immediate if minus** \
     * if (`Negative`) then `PC` += `#i`
     */
    brimi,

    /**
     * **branch relative immediate if plus** \
     * if (!`Negative`) then `PC` += `#i`
     */
    bripl,

    /**
     * **branch relative immediate if higher or same** \
     * if (`Carry`) then `PC` += `#i`
     */
    brihs,

    /**
     * **branch relative immediate if lower** \
     * if (!`Carry`) then `PC` += `#i`
     */
    brilo,

    /**
     * **branch relative immediate if higher** \
     * if (`Carry` && !`Zero`) then `PC` += `#i`
     */
    brihi,

    /**
     * **branch relative immediate if lower or same** \
     * if (!`Carry` || `Zero`) then `PC` += `#i`
     */
    brils,

    /**
     * **compare** \
     * sets flags based on `Rs - Rt`
     */
    cmp,

    /**
     * **compare immediate** \
     * sets flags based on `Rs - #i`
     */
    cmpi,

    /**
     * **test** \
     * sets flags based on `Rs & Rt`
     */
    tst,

    /**
     * **test immediate** \
     * sets flags based on `Rs & #i`
     */
    tsti,

    /**
     * **call immediate** \
     * `Rd` = `PC`, \
     * `PC` = #i
     */
    calli,

    /**
     * **call** \
     * `Rd` = `PC`, \
     * `PC` = `Rs`
     */
    call,

    /**
     * **load word immediate** \
     * `Rd` = `MEM[#i]`
     */
    lwi,

    /**
     * **load word register** \
     * `Rd` = `MEM[Rs]`
     */
    lwr,

    /**
     * **load word register+immediate** \
     * `Rd` = `MEM[Rs + #i]`
     */
    lwri,

    /**
     * **load word register+register** \
     * `Rd` = `MEM[Rs + Rt]`
     */
    lwrr,

    /**
     * **store word immediate** \
     * `MEM[#i]` = `Rd`
     */
    swi,

    /**
     * **store word register** \
     * `MEM[Rs]` = `Rd`
     */
    swr,

    /**
     * **store word register+immediate** \
     * `MEM[Rs + #i]` = `Rd`
     */
    swri,

    /**
     * **store word register+register** \
     * `MEM[Rs + Rt]` = `Rd`
     */
    swrr,

    /**
     * **load word register then increment** \
     * `Rd` = `MEM[Rs++]`
     */
    lwrti,

    /**
     * **store word register decrement before** \
     * `MEM[--Rs]` = `Rd`
     */
    swrdb,

    /**
     * **increment** \
     * `Rd` = `Rs` + 1 
     */
    inc,

    /**
     * **decrement** \
     * `Rd` = `Rs` - 1 
     */
    dec,

    /**
     * **unsigned minimum** \
     * `Rd` = `umin(Rs, Rt)`
     */
    umn,

    /**
     * **unsigned maximum** \
     * `Rd` = `umax(Rs, Rt)`
     */
    umx,

    /**
     * **load word register then increment dual** \
     * `Rd` = `MEM[Rs++]`, \
     * `Rt` = `MEM[Rs++]`
     */
    lwrti2,

    /**
     * **store word register decrement before dual** \
     * `MEM[--Rs]` = `Rt`, \
     * `MEM[--Rs]` = `Rd`
     */
    swrdb2,

    /**
     * **branch (to) stack pop** \
     * `PC` = `MEM[Rs++]`
     */
    bsp,

    /**
     * **add with carry** \
     * `Rd` = `Rs` + `Rt` + `Carry`
     */
    addc,

    /**
     * **subtract with carry** \
     * `Rd` = `Rs` - `Rt` - `Carry`
     */
    subc,

    /**
     * **add carry only** \
     * `Rd` = `Rs` + `Carry`
     */
    addco,

    /**
     * **subtract carry only** \
     * `Rd` = `Rs` - `Carry`
     */
    subco,
}