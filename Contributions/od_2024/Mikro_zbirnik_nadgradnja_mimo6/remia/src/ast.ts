import type { MatchResult } from "ohm-js";
import { toAST } from "ohm-js/extras";

export type ASTRoot = TopLevelExpr[];

export type TopLevelExpr = ConstDef | Directive | Instruction | Label;

export interface Label {
    type: "Label"
    name: string
}

export interface ConstDef {
    type: "ConstDef",
    name: string,
    value: string,
}

export type Directive = AtDirective | VarDirective | IncludeDirective | StringDirective;

export interface AtDirective {
    type: "AtDirective",
    addr: string
}

export interface VarDirective {
    type: "VarDirective",
    values: string[],
}

export interface IncludeDirective {
    type: "IncludeDirective"
    file: string,
}

export interface StringDirective {
    type: "StringDirective"
    stype: ".ascii" | ".asciz" | ".utf16",
    string: string
}

export type Instruction =
    InstructionRRR |
    InstructionRRI |
    InstructionRR |
    InstructionRI |
    InstructionRX |
    InstructionR |
    InstructionI |
    InstructionB |
    InstructionRB |
    InstructionArgless;

interface InstructionBase {
    type: "Instruction",
    mnemonic: Mnemonic,
}

export interface InstructionRRR extends InstructionBase {
    args: 'rrr',
    r0: Register
    r1: Register
    r2: Register
}
export interface InstructionRRI extends InstructionBase {
    args: 'rri',
    r0: Register
    r1: Register
    i: Immed
}
export interface InstructionRR extends InstructionBase {
    args: 'rr',
    r0: Register
    r1: Register
}
export interface InstructionRI extends InstructionBase {
    args: 'ri',
    r0: Register
    i: Immed
}
export interface InstructionRX extends InstructionBase {
    args: "rX",
    r0: Register,
    index: Index
}
export interface InstructionR extends InstructionBase {
    args: 'r',
    r0: Register
}
export interface InstructionI extends InstructionBase {
    args: 'i',
    i: Immed
}

export interface InstructionB extends InstructionBase {
    args: 'b',
    name: string
}

export interface InstructionRB extends InstructionBase {
    args: 'rb',
    name: string
    r0: Register
}

export interface InstructionArgless extends InstructionBase {
    args: ''
}

export type Index =
    { itype: "r", r0: Register } |
    { itype: "i", i: Immed } |
    { itype: "rr", r0: Register, r1: Register } |
    { itype: "ri", r0: Register, i: Immed }

export type Immed = {
    type: "immed"
    itype: "literal"
    value: string
} | {
    type: "immed"
    itype: "named"
    name: string
};

export type Register = `r${0 | 1 | 2 | 3 | 4 | 5 | 6 | 7}` | "sp" | "lr";

export type Mnemonic = 'mov' |
    'li' |
    'add' |
    'addc' |
    'addco' |
    'sub' |
    'subc' |
    'subco' |
    'cmp' |
    'mul' |
    'div' |
    'tst' |
    'mod' |
    'and' |
    'orr' |
    'xor' |
    'nnd' |
    'nor' |
    'not' |
    'not' |
    'lsl' |
    'lsr' |
    'asr' |
    'rol' |
    'ror' |
    'b' |
    'br' |
    'beq' |
    'bne' |
    'bmi' |
    'bpl' |
    'bhs' |
    'blo' |
    'bhi' |
    'bls' |
    'call' |
    'lw' |
    'sw' |
    'lwrti' |
    'swrdb' |
    'lwrti2' |
    'swrdb2' |
    'push' |
    'pop' |
    'inc' |
    'dec' |
    'umn' |
    'umx' |
    'bsp' |
    'ret' |
    'nop';

export function getAst(r: MatchResult) {
    return (toAST(r, {
        Assembler: { content: 0 },
        Program: { content: 0 },

        Label: { type: "Label", name: ([x]: any) => x.toAST({}).slice(0, -1), },

        ConstDef: {
            type: "ConstDef",
            name: ([x]: any) => x.toAST({}).slice(1),
            value: 1
        },

        AtDirective: { addr: 1 },
        VarDirective: { values: 1 },
        IncludeDirective: { file: 1 },
        StringDirective: { stype: 0, string: 1 },

        Instruction_rrr: {
            type: "Instruction",
            args: 'rrr',
            mnemonic: 0,
            r0: 1,
            r1: 3,
            r2: 5,
        },
        Instruction_rri: {
            type: "Instruction",
            mnemonic: 0,
            args: 'rri',
            r0: 1,
            r1: 3,
            i: 5
        },
        Instruction_rX: {
            type: "Instruction",
            mnemonic: 0,
            args: 'rX',
            r0: 1,
            index: 3
        },
        Instruction_rr: {
            type: "Instruction",
            mnemonic: 0,
            args: 'rr',
            r0: 1,
            r1: 3,
        },
        Instruction_ri: {
            type: "Instruction",
            mnemonic: 0,
            args: 'ri',
            r0: 1,
            i: 3
        },
        Instruction_r: {
            type: "Instruction",
            mnemonic: 0,
            args: 'r',
            r0: 1,
        },
        Instruction_i: {
            type: "Instruction",
            mnemonic: 0,
            args: 'i',
            i: 1,
        },
        Instruction_b: {
            type: "Instruction",
            mnemonic: 0,
            args: 'b',
            name: 1,
        },
        Instruction_rb: {
            type: "Instruction",
            mnemonic: 0,
            args: 'rb',
            r0: 1,
            name: 3,
        },
        Instruction_n: {
            type: "Instruction",
            mnemonic: 0,
            args: '',
        },
        Immed_named: {
            type: "immed",
            itype: "named",
            name: ([x]: any) => x.toAST({}).substring(1)
        },
        Immed_literal: {
            type: "immed",
            itype: "literal",
            value: ([x]: any) => x.toAST({}).substring(1),
        },
        FullIndex_R: { itype: "r", r0: 0 },
        FullIndex_I: { itype: "i", i: 1 },
        FullIndex_RR: { itype: "rr", r0: 1, r1: 3 },
        FullIndex_RI: { itype: "ri", r0: 1, i: 3 },
    }) as any).content as ASTRoot;
}