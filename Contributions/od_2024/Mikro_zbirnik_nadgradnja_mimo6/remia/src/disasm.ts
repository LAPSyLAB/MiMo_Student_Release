import { Instr } from "../../fu/src/isa";

/**
 *  rd rs rt imm
 */
type TInstrArgs = `${'x'|' '}${'x'|' '}${'x'|' '}${'x'|' '}`;

const INSTR_PARAMS_MAP: Record<Instr, TInstrArgs> = {
    [Instr.mov]: "xx  ",
    [Instr.li]: "x  x",

    [Instr.add]: "xxx ",
    [Instr.sub]: "xxx ",
    [Instr.mul]: "xxx ",
    [Instr.div]: "xxx ",
    [Instr.mod]: "xxx ",
    [Instr.and]: "xxx ",
    [Instr.orr]: "xxx ",
    [Instr.xor]: "xxx ",
    [Instr.nnd]: "xxx ",
    [Instr.nor]: "xxx ",
    [Instr.not]: "xxx ",
    [Instr.lsl]: "xxx ",
    [Instr.lsr]: "xxx ",
    [Instr.asr]: "xxx ",
    [Instr.rol]: "xxx ",
    [Instr.ror]: "xxx ",

    [Instr.addi]: "xx x",
    [Instr.subi]: "xx x",
    [Instr.muli]: "xx x",
    [Instr.divi]: "xx x",
    [Instr.modi]: "xx x",
    [Instr.andi]: "xx x",
    [Instr.orri]: "xx x",
    [Instr.xori]: "xx x",
    [Instr.nndi]: "xx x",
    [Instr.nori]: "xx x",
    [Instr.noti]: "xx x",
    [Instr.lsli]: "xx x",
    [Instr.lsri]: "xx x",
    [Instr.asri]: "xx x",
    [Instr.roli]: "xx x",
    [Instr.rori]: "xx x",


    [Instr.bar]:   " x  ",
    [Instr.bai]:   "   x",
    [Instr.call]:  "xx  ",
    [Instr.calli]: "x  x",
    [Instr.bri]:   "   x",
    [Instr.brieq]: "   x",
    [Instr.brine]: "   x",
    [Instr.brimi]: "   x",
    [Instr.bripl]: "   x",
    [Instr.brihs]: "   x",
    [Instr.brilo]: "   x",
    [Instr.brihi]: "   x",
    [Instr.brils]: "   x",

    [Instr.cmp]:  " xx ",
    [Instr.tst]:  " xx ",

    [Instr.cmpi]: " x x",
    [Instr.tsti]: " x x",


    [Instr.lwi]:  "x  x",
    [Instr.swi]:  "x  x",
    [Instr.lwr]:  "xx  ",
    [Instr.swr]:  "xx  ",
    [Instr.lwri]: "xx x",
    [Instr.swri]: "xx x",
    [Instr.lwrr]: "xxx ",
    [Instr.swrr]: "xxx ",
    
    [Instr.lwrti]: "xx  ",
    [Instr.swrdb]: "xx  ",
    
    [Instr.lwrti2]: "xxx ",
    [Instr.swrdb2]: "xxx ",

    [Instr.inc]: "xx  ",
    [Instr.dec]: "xx  ",

    [Instr.umn]: "xxx ",
    [Instr.umx]: "xxx ",

    [Instr.bsp]: " x  ",

    [Instr.addc]: "xxx ",
    [Instr.subc]: "xxx ",
    
    [Instr.addco]: "xx  ",
    [Instr.subco]: "xx  "
};

export function disasm(instr: number[]) {
    if (instr.length == 0) return '';

    const ucodeIndex = (instr[0] >> 9) + 2;
    const regs = [(instr[0]) & 0x7, (instr[0] >> 3) & 0x7, (instr[0] >> 6) & 0x7];

    if (!(ucodeIndex in Instr)) {
        return instr.map(x => x.toString(16).padStart(4, '0')).join(' ');
    }

    const params = INSTR_PARAMS_MAP[ucodeIndex as Instr];
    const args = regs.filter((_,i)=>params.charAt(i) == 'x').map(x=>`r${x}`);
    if (params.endsWith('x')) args.push(`#${instr[1].toString(16).padStart(4, '0')}`)

    return `${Instr[ucodeIndex].padEnd(8)} ${args.join(', ')}`;
}