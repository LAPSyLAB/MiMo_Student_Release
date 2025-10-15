export enum PC {
    PLUS_ONE = 0,
    IMMED = 1,
    PLUS_IMMED = 2,
    SRC_REG = 3,
}

export enum ALU {
    ADD = 0,
    SUB = 1,
    MUL = 2,
    DIV = 3,
    MOD = 4,
    AND = 5,
    OR = 6,
    XOR = 7,
    NAND = 8,
    NOR = 9,
    NOT = 10,
    LSL = 11,
    LSR = 12,
    ASR = 13,
    ROL = 14,
    ROR = 15,
}

export enum Op2 {
    T_REG = 0,
    IMMED = 1,
    ZERO = 2,
    ONE = 3,
}

export enum Addr {
    PC,
    IMMED,
    ALU,
    SRC_REG,
}

export enum RSrc {
    DATA_BUS,
    IMMED,
    ALU,
    SRC_REG,
    T_REG,
    PC,
}

export enum Cond {
    Z = 0,
    Z_OR_N = 1,
    N = 2,
    C = 3,
}

export enum Data {
    PC = 0,
    DST_REG = 1,
    T_REG = 2,
    ALU = 3,
}

type Bool = 0 | 1;

interface IMicroInstruction {
    // ALU operation to perform
    aluop: ALU;
    // ALU 2nd operand selection
    op2sel: Op2;
    // Memory write?
    datawrite: Bool;
    // Memory Address source
    addrsel: Addr;
    // Next PC value source
    pcsel: PC;
    // Load into PC?
    pcload: Bool;
    // write to dst reg?
    dwrite: Bool;
    // Write to src reg?
    swrite: Bool;
    // Load instruction?
    irload: Bool;
    // Load immed?
    imload: Bool;
    // Register write source
    regsrc: RSrc;
    // Condition
    cond: Cond;
    // add opcode to next uinst index (opcode jump)
    idxsel: Bool;
    // Data bus selection when writing
    datasel: Data;
    // Set ALU flags?
    flags: Bool,
    // Write to t reg?
    twrite: Bool,
    // Use carry in ALU?
    carry: Bool,
    // address of next uinst if condition is true
    t: number;
    // address of next uinst if condition is false
    f: number;
}

const DEFAULT = {
    aluop: ALU.ADD,
    op2sel: Op2.T_REG,
    datawrite: 0,
    addrsel: Addr.PC,
    pcsel: PC.PLUS_ONE,
    pcload: 0,
    dwrite: 0,
    swrite: 0,
    irload: 0,
    imload: 0,
    regsrc: RSrc.DATA_BUS,
    cond: Cond.Z,
    idxsel: 0,
    datasel: Data.PC,
    flags: 0,
    twrite: 0,
    carry: 0,
} satisfies Omit<IMicroInstruction, "t" | "f">;

export interface IUinst extends Partial<IMicroInstruction> {
    next?: number;
}

function emitControlRom(uinst: IMicroInstruction): number {
    return (
        (uinst.carry << 26) |
        (uinst.twrite << 25) |
        (uinst.flags << 24) |
        (uinst.swrite << 23) |
        (uinst.datasel << 21) |
        (uinst.idxsel << 20) |
        (uinst.cond << 18) |
        (uinst.regsrc << 15) |
        (uinst.imload << 14) |
        (uinst.irload << 13) |
        (uinst.dwrite << 12) |
        (uinst.pcload << 11) |
        (uinst.pcsel << 9) |
        (uinst.addrsel << 7) |
        (uinst.datawrite << 6) |
        (uinst.op2sel << 4) |
        (uinst.aluop << 0)
    );
}

function emitDecisionRom(uinst: IMicroInstruction): number {
    if (uinst.t < 0 || uinst.t > 255) throw "Invalid T";
    if (uinst.f < 0 || uinst.f > 255) throw "Invalid F";
    return (uinst.t << 8) | uinst.f;
}

export function build(ucode: Record<number, IUinst | undefined>) {
    const control = new Uint32Array(256),
        decision = new Uint16Array(256);

    let nInstr = 0, nExtra = 0;

    for (let i = 0; i < 256; i++) {
        const _u = ucode[i];
        if (!_u) continue;
        i < 127 ? (nInstr++) : (nExtra++);

        const u = {
            t: _u.t ?? _u.next ?? i + 1,
            f: _u.f ?? _u.next ?? i + 1,
            ...DEFAULT,
            ..._u,
        };

        control[i] = emitControlRom(u);
        decision[i] = emitDecisionRom(u);
    }

    console.log(`All good.
    instructions: ${nInstr} / 128 slots
    extra:        ${nExtra} / 128 slots`)
    return { control, decision };
}

export function dot(ucode: Record<number, IUinst>, names: Record<string | number, any>): string {
    const nodes = Object.entries(ucode).filter(([k, v]) => parseInt(k) >= 0).map(([k, v]) => `u${k}[nojustify=false shape=record label="{${names[k] ?? `u${k}`} | ${Object.entries(v).filter(([x]) => !['t', 'f', 'next'].includes(x)).map(([x, y]) => `${x}: ${y}`).join('\\n')}\\l}"]`)
    nodes.push(`u256[label="end"]`)
    const edges = Object.entries(ucode).filter(([k, v]) => parseInt(k) >= 0).flatMap(([k, v]) => {
        const uiIdx = parseInt(k);
        const t = (v.t ?? v.next ?? uiIdx + 1) || 256,
            f = (v.f ?? v.next ?? uiIdx + 1) || 256;

        if (v.idxsel) {
            if (t != f) console.warn('[dot] idxsel + conditional next uinst, graph might be wrong')
            const selections = [...Array(128)].map((_, i) => t + i).filter(x => x in ucode).map(x => `u${k}->u${x} [color="gray"]`);
            if (selections.length < 128) {
                nodes.push(`nop${k}[label="${128 - selections.length} / 128 no-ops"]`)
                selections.push(`u${k}->nop${k} [color="blue"]`);
            }
            return selections;
        }



        return t == f ? [`u${k}->u${t}`] : [`u${k}->u${t} [color="green"]`, `u${k}->u${f} [color="red"]`];
    });

    return `digraph {
        ${nodes.join('\n')}
        ${edges.join('\n')}
    }`;
}

export function v3HexWordsPlain(data: Uint16Array | Uint32Array) {
    const lines = ["v3.0 hex words plain"];

    const wordSz = data instanceof Uint16Array ? 4 : 8,
        lineSz = data instanceof Uint16Array ? 16 : 8;


    const alignedSize = (data.length + lineSz - 1) & ~(lineSz - 1);

    for (let i = 0; i < alignedSize; i += lineSz) {
        let line = "";
        for (let j = 0; j < lineSz; j++) {
            const h = (data[i + j] ?? 0).toString(16).padStart(wordSz, "0");
            line += j ? ` ${h}` : h;
        }
        lines.push(line);
    }

    return lines.join("\n");
}

export function instruction(op: number, d = 0, s = 0, t = 0) {
    return ((op - 2) << 9) | (t << 6) | (s << 3) | d;
}
