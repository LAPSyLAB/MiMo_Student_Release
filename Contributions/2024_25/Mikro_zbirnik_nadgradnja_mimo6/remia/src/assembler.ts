import { file } from "bun";
import type {
    ASTRoot,
    Immed,
    Instruction,
    InstructionR,
    InstructionRR,
    InstructionRRR,
    Register,
} from "./ast";
import { evalNumber, evalString, stringToU16Buf } from "./util";
import { resolve } from "path";
import { stderr } from "process";

import { Instr } from "../../fu/src/isa";
import { disasm } from "./disasm";

export async function buildFileCache(
    ast: ASTRoot,
    baseDir: string
): Promise<Record<string, Uint16Array>> {
    const uniqueFiles = new Set(
        ast.filter((x) => x.type == "IncludeDirective").map((x) => x.file)
    );

    const fileCache = Object.fromEntries(
        await Promise.all(
            uniqueFiles.values().map(async (nameStr) => {
                const name = evalString(nameStr);
                const realPath = resolve(baseDir, name);

                const contents = await file(realPath).arrayBuffer();
                let size = contents.byteLength;
                if (size & 1) size++;

                const dv = new DataView(contents);
                const u16array = new Uint16Array(size / 2);

                for (let i = 0; i + 1 < contents.byteLength; i += 2) {
                    u16array[i >> 1] = dv.getUint16(i, false);
                }

                if (contents.byteLength & 1) {
                    u16array[u16array.length - 1] =
                        dv.getUint8(contents.byteLength - 1) << 8;
                }

                return [name, u16array];
            })
        )
    );

    return fileCache;
}

export function pass1(ast: ASTRoot, fc: Record<string, Uint16Array>) {
    const vars: Record<string, number> = {};

    function setVar(name: string, value: number) {
        if (name in vars) throw new Error(`Duplicate variable/label: ${name}`);
        vars[name] = value;
    }

    let pc = 0;
    for (const expr of ast) {
        switch (expr.type) {
            case "ConstDef":
                setVar(expr.name, evalNumber(expr.value));
                break;
            case "AtDirective":
                pc = evalNumber(expr.addr);
                break;
            case "VarDirective":
                pc += expr.values.length;
                break;
            case "IncludeDirective":
                pc += fc[evalString(expr.file)].length;
                break;
            case "StringDirective":
                pc += stringToU16Buf(
                    evalString(expr.string),
                    expr.stype
                ).length;
                break;
            case "Instruction": {
                pc++;
                if (
                    expr.args.includes("i") ||
                    (expr.args == "rX" && expr.index.itype.includes("i")) ||
                    expr.args == "b"
                ) {
                    pc++;
                }
                break;
            }
            case "Label": {
                setVar(expr.name, pc);
            }
        }
    }

    return vars;
}

function instr(opcode: number, r0 = 0, r1 = 0, r2 = 0) {
    return (
        ((opcode & 0x7f) << 9) |
        ((r2 & 0x7) << 6) |
        ((r1 & 0x7) << 3) |
        (r0 & 0x7)
    );
}

const REGMAP: Record<Register, number> = {
    r0: 0,
    r1: 1,
    r2: 2,
    r3: 3,
    r4: 4,
    r5: 5,
    r6: 6,
    r7: 7,
    lr: 7,
    sp: 6,
};

function immedToStr(i: Immed): string {
    return `#${i.itype == "named" ? i.name : i.value}`;
}

function instrArgsString(a: Instruction): string {
    switch (a.args) {
        case "":
            return "";
        case "rrr":
            return `${a.r0}, ${a.r1}, ${a.r2}`;
        case "rri":
            return `${a.r0}, ${a.r1}, ${immedToStr(a.i)}`;
        case "rr":
            return `${a.r0}, ${a.r1}`;
        case "ri":
            return `${a.r0}, ${immedToStr(a.i)}`;
        case "rX":
            switch (a.index.itype) {
                case "rr":
                    return `${a.r0}, ${a.index.r0}, ${a.index.r1}`;
                case "ri":
                    return `${a.r0}, ${a.index.r0}, #${a.index.i}`;
                case "r":
                    return `${a.r0}, ${a.index.r0}`;
                case "i":
                    return `${a.r0}, ${immedToStr(a.index.i)}`;
            }
        case "r":
            return `${a.r0}`;
        case "rb":
            return `${a.r0}, ${a.name}`;
        case "i":
            return `${immedToStr(a.i)}`;
        case "b":
            return `${a.name}`;
    }
}

const BRANCH_MAP = {
    beq: Instr.brieq,
    bne: Instr.brine,
    bmi: Instr.brimi,
    bpl: Instr.bripl,
    bhs: Instr.brihs,
    blo: Instr.brilo,
    bhi: Instr.brihi,
    bls: Instr.brils,
    br: Instr.bri,
};

export function pass2(
    ast: ASTRoot,
    fc: Record<string, Uint16Array>,
    vars: Record<string, number>
) {
    const chunks = new Map<number, Uint16Array>();
    let activeChunk: number[] = [];
    let pc = 0,
        chunkStart = 0;
    let cinstr: number[] = [];

    function resolveImmed(i: Immed) {
        if (i.itype == "literal") return evalNumber(i.value);
        const v = vars[i.name] as number | undefined;
        if (!v) throw new Error(`unknown var: ${i.name}`);
        return v;
    }

    function pushChunk() {
        if (activeChunk.length > 0)
            chunks.set(chunkStart, new Uint16Array(activeChunk));
    }

    function newChunk(at: number) {
        chunkStart = at;
        activeChunk = new Array();
    }

    function emitOp(i: Instr, rd?: Register, rs?: Register, rt?: Register) {
        const em = instr(
            i - 2,
            REGMAP[rd ?? "r0"],
            REGMAP[rs ?? "r0"],
            REGMAP[rt ?? "r0"]
        );
        // stderr.write(`${em.toString(16).padStart(4, '0')} `);
        cinstr.push(em);
        activeChunk.push(em);
        pc++;
    }
    function emitI(i: number) {
        i = i & 0xffff;
        cinstr.push(i);
        activeChunk.push(i);
        pc++;
    }
    stderr.write(
        `Addr | Binary     | Machine                      | Assembly\n`
    );
    stderr.write(
        `-----+------------+------------------------------+--------------------------\n`
    );
    for (const expr of ast) {
        switch (expr.type) {
            case "AtDirective": {
                pushChunk();
                pc = evalNumber(expr.addr);
                newChunk(pc);
                break;
            }
            case "VarDirective": {
                expr.values.forEach((x) => activeChunk.push(evalNumber(x)));
                pc += expr.values.length;
                break;
            }
            case "IncludeDirective": {
                pushChunk();
                const file = fc[evalString(expr.file)];
                chunks.set(pc, file);
                pc += file.length;
                newChunk(pc);
                break;
            }
            case "StringDirective": {
                pushChunk();
                const strBuf = stringToU16Buf(
                    evalString(expr.string),
                    expr.stype
                );
                chunks.set(pc, strBuf);
                pc += strBuf.length;
                newChunk(pc);
                break;
            }
            case "Instruction": {
                cinstr.length = 0;
                switch (expr.mnemonic) {
                    case "nop":
                        emitOp(Instr.mov);
                        break;

                    case "mov": {
                        if (expr.args == "rr") {
                            emitOp(Instr.mov, expr.r0, expr.r1);
                        } else if (expr.args == "ri") {
                            emitOp(Instr.li, expr.r0);
                            emitI(resolveImmed(expr.i));
                        } else throw new Error("Invalid args");
                        break;
                    }

                    case "li":
                        if (expr.args == "ri") {
                            emitOp(Instr.li, expr.r0);
                            emitI(resolveImmed(expr.i));
                        } else throw new Error("Invalid args");
                        break;

                    case "add":
                    case "sub":
                    case "mul":
                    case "div":
                    case "mod":
                    case "and":
                    case "orr":
                    case "xor":
                    case "nnd":
                    case "nor":
                    case "lsl":
                    case "lsr":
                    case "asr":
                    case "rol":
                    case "ror":
                        if (
                            expr.args == "b" ||
                            expr.args == "i" ||
                            expr.args == "r" ||
                            expr.args == "rX" ||
                            expr.args == "rb" ||
                            expr.args == ""
                        )
                            throw `Invalid args to ALUop (${expr.mnemonic}, ${expr.args})`;
                        {
                            let dst = expr.r0,
                                src = expr.r0,
                                t: Register = "r0",
                                m = expr.mnemonic;
                            if (expr.args == "rri" || expr.args == "rrr") {
                                src = expr.r1;
                            }

                            if (expr.args == "ri" || expr.args == "rri") {
                                emitOp(Instr[`${m}i`], dst, src);
                                emitI(resolveImmed(expr.i));
                            } else {
                                emitOp(
                                    Instr[m],
                                    dst,
                                    src,
                                    (expr as Partial<InstructionRRR>).r2 ??
                                        expr.r1
                                );
                            }
                        }
                        break;

                    case "not":
                        if (expr.args == "r" || expr.args == "rr") {
                            const e = expr as Partial<InstructionRR>;
                            emitOp(Instr.not, expr.r0, e.r1 ?? expr.r0);
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "cmp":
                    case "tst":
                        if (expr.args == "rr") {
                            emitOp(
                                Instr[expr.mnemonic],
                                undefined,
                                expr.r0,
                                expr.r1
                            );
                        } else if (expr.args == "ri") {
                            emitOp(
                                Instr[`${expr.mnemonic}i`],
                                undefined,
                                expr.r0
                            );
                            emitI(resolveImmed(expr.i));
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "addc":
                    case "subc":
                        if (expr.args == "rrr") {
                            emitOp(
                                Instr[expr.mnemonic],
                                expr.r0,
                                expr.r1,
                                expr.r2
                            );
                        } else if (expr.args == "rr") {
                            emitOp(
                                Instr[expr.mnemonic],
                                expr.r0,
                                expr.r0,
                                expr.r1
                            );
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "addco":
                    case "subco":
                        if (expr.args == "rr") {
                            emitOp(Instr[expr.mnemonic], expr.r0, expr.r1);
                        } else if (expr.args == "r") {
                            emitOp(Instr[expr.mnemonic], expr.r0, expr.r0);
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "beq":
                    case "bne":
                    case "bmi":
                    case "bpl":
                    case "bhs":
                    case "blo":
                    case "bhi":
                    case "bls":
                    case "br":
                        if (expr.args == "b") {
                            const target = resolveImmed({
                                type: "immed",
                                itype: "named",
                                name: expr.name,
                            });
                            const offset = target - pc - 2;
                            emitOp(BRANCH_MAP[expr.mnemonic]);
                            emitI(offset);
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "b":
                        if (expr.args == "r") {
                            emitOp(Instr.bar, undefined, expr.r0);
                        } else if (expr.args == "i") {
                            emitOp(Instr.bai);
                            emitI(resolveImmed(expr.i));
                        } else if (expr.args == "b") {
                            emitOp(Instr.bai);
                            emitI(
                                resolveImmed({
                                    type: "immed",
                                    itype: "named",
                                    name: expr.name,
                                })
                            );
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "call":
                        {
                            const lr =
                                expr.args.length == 2
                                    ? (expr as InstructionR).r0
                                    : "lr";
                            switch (expr.args) {
                                case "i":
                                case "ri":
                                    emitOp(Instr.calli, lr);
                                    emitI(resolveImmed(expr.i));
                                    break;

                                case "b":
                                case "rb":
                                    emitOp(Instr.calli, lr);
                                    emitI(
                                        resolveImmed({
                                            type: "immed",
                                            itype: "named",
                                            name: expr.name,
                                        })
                                    );
                                    break;

                                case "r":
                                    emitOp(Instr.call, lr, expr.r0);
                                    break;
                                case "rr":
                                    emitOp(Instr.call, lr, expr.r1);
                                    break;

                                default:
                                    throw new Error(
                                        `Invalid args (${expr.mnemonic}, ${expr.args})`
                                    );
                            }
                        }
                        break;

                    case "lw":
                    case "sw":
                        if (expr.args == "rX") {
                            const idx = expr.index;
                            emitOp(
                                Instr[`${expr.mnemonic}${idx.itype}`],
                                expr.r0,
                                (idx as any).r0,
                                (idx as any).r1
                            );
                            if (idx.itype == "i" || idx.itype == "ri") {
                                emitI(resolveImmed(idx.i));
                            }
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "pop":
                    case "push":
                        if (expr.args == "r") {
                            emitOp(
                                expr.mnemonic == "push"
                                    ? Instr.swrdb
                                    : Instr.lwrti,
                                expr.r0,
                                "sp"
                            );
                        } else if (expr.args == "rr") {
                            emitOp(
                                expr.mnemonic == "push"
                                    ? Instr.swrdb2
                                    : Instr.lwrti2,
                                expr.r0,
                                "sp",
                                expr.r1
                            );
                        } else
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        break;

                    case "swrdb":
                    case "lwrti":
                        if (expr.args != "rr") {
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        }
                        emitOp(
                            expr.mnemonic == "swrdb"
                                ? Instr.swrdb
                                : Instr.lwrti,
                            expr.r1,
                            expr.r0
                        );
                        break;

                    case "lwrti2":
                    case "swrdb2":
                        if (expr.args != "rrr") {
                            throw new Error(
                                `Invalid args (${expr.mnemonic}, ${expr.args})`
                            );
                        }
                        emitOp(
                            expr.mnemonic == "swrdb2"
                                ? Instr.swrdb2
                                : Instr.lwrti2,
                            expr.r1,
                            expr.r0,
                            expr.r2
                        );
                        break;

                    case "inc":
                    case "dec":
                        {
                            if (expr.args !== "r" && expr.args !== "rr")
                                throw new Error(
                                    `Invalid args (${expr.mnemonic}, ${expr.args})`
                                );

                            const rd = expr.r0;
                            const rs = expr.args == "rr" ? expr.r1 : rd;

                            emitOp(
                                expr.mnemonic == "dec" ? Instr.dec : Instr.inc,
                                rd,
                                rs
                            );
                        }
                        break;

                    case "umn":
                    case "umx":
                        {
                            if (expr.args !== "rr" && expr.args !== "rrr")
                                throw new Error(
                                    `Invalid args (${expr.mnemonic}, ${expr.args})`
                                );

                            const rd = expr.r0;
                            const rs = expr.args == "rrr" ? expr.r1 : rd;
                            const rt = expr.args == "rrr" ? expr.r2 : expr.r1;

                            emitOp(
                                expr.mnemonic == "umn" ? Instr.umn : Instr.umx,
                                rd,
                                rs,
                                rt
                            );
                        }
                        break;

                    case "bsp":
                        if (expr.args === "r") {
                            emitOp(Instr.bsp, expr.r0, expr.r0);
                            break;
                        }
                    case "ret":
                        {
                            if (expr.args !== "")
                                throw new Error(
                                    `Invalid args (${expr.mnemonic}, ${expr.args})`
                                );
                            emitOp(Instr.bsp, "sp", "sp");
                        }
                        break;
                }

                stderr.write(
                    `${(pc - cinstr.length)
                        .toString(16)
                        .padStart(4, "0")} | ${cinstr
                        .map((x) => x.toString(16).padStart(4, "0"))
                        .join(" ")
                        .padEnd(10)} | ${disasm(cinstr as any).padEnd(
                        28,
                        " "
                    )} | ${expr.mnemonic.padEnd(8, " ")} ${instrArgsString(
                        expr
                    )}\n`
                );

                break;
            }
        }
    }
    pushChunk();

    return chunks;
}

export function buildImage(chunks: Map<number, Uint16Array>) {
    const size = chunks
        .entries()
        .map(([s, c]) => s + c.length)
        .reduce((p, c) => Math.max(p, c));
    console.assert(size <= 65536, "max image size exceded");
    const image = new Uint16Array(size);

    const orderedChunks = [...chunks.entries()].sort((a, b) => a[0] - b[0]);

    let index = 0;
    for (const [start, buf] of orderedChunks) {
        if (index > start)
            throw new Error(`overlapping contents (${index}, ${start})`);
        image.set(buf, start);
        index += buf.length;
    }

    return image;
}
