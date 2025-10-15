import sys
import re

Opcode = {
    "add": [0, 'dst'],
    "sub": [1, 'dst'],
    "mul": [2, 'dst'],
    "div": [3, 'dst'],
    "rem": [4, 'dst'],
    "and": [5, 'dst'],
    "or": [6, 'dst'],
    "xor": [7, 'dst'],
    "nand": [8, 'dst'],
    "nor": [9, 'dst'],
    "not": [10, 'ds'],
    "lsl": [11, 'dst'],
    "lsr": [12, 'dst'],
    "asr": [13, 'dst'],
    "rol": [14, 'dst'],
    "ror": [15, 'dst'],
    "addi": [16, 'dsi'],
    "subi": [17, 'dsi'],
    "muli": [18, 'dsi'],
    "divi": [19, 'dsi'],
    "remi": [20, 'dsi'],
    "andi": [21, 'dsi'],
    "ori": [22, 'dsi'],
    "xori": [23, 'dsi'],
    "nandi": [24, 'dsi'],
    "nori": [25, 'dsi'],
    "lsli": [26, 'dsi'],
    "lsri": [27, 'dsi'],
    "asri": [28, 'dsi'],
    "roli": [29, 'dsi'],
    "rori": [30, 'dsi'],
    "addc": [31, 'dstI'],
    "subc": [32, 'dstI'],
    "jeq": [33, 'sti'],
    "jne": [34, 'sti'],
    "jgt": [35, 'sti'],
    "jle": [36, 'sti'],
    "jlt": [37, 'sti'],
    "jge": [38, 'sti'],
    "jeqz": [39, 'si'],
    "jnez": [40, 'si'],
    "jgtz": [41, 'si'],
    "jlez": [42, 'si'],
    "jltz": [43, 'si'],
    "jgez": [44, 'si'],
    "jmp": [45, 'i'],
    "beq": [46, 'stI'],
    "bne": [47, 'stI'],
    "bgt": [48, 'stI'],
    "ble": [49, 'stI'],
    "blt": [50, 'stI'],
    "bge": [51, 'stI'],
    "beqz": [52, 'sI'],
    "bnez": [53, 'sI'],
    "bgtz": [54, 'sI'],
    "blez": [55, 'sI'],
    "bltz": [56, 'sI'],
    "bgez": [57, 'sI'],
    "br": [58, 'I'],
    "jsr": [59, 'i'],
    "rts": [60, ''],
    "inc": [61, 's'],
    "dec": [62, 's'],
    "li": [63, 'di'],
    "lw": [64, 'di'],
    "sw": [65, 'di'],
    "lwi": [66, 'dsi'],
    "swi": [67, 'dsi'],
    "push": [68, 'd'],
    "pop": [69, 'd'],
    "move": [70, 'ds'],
    "clr": [71, 's'],
    "neg": [72, 's'],
    "lwri": [73, 'dst'],
    "swri": [74, 'dst'],
}


Label = {}
OriginalLine = []
LType = []
MCode = []
PC = 0

with open(sys.argv[1]) as f:
    for line in f.readlines():

        line = re.sub("\s*#.*", "", line)
        line = re.sub("\t\t", "\t", line)
        line = line.strip()

        if re.match("^\s*$", line):
            continue

        OriginalLine.append(line)

        LType.append(0)

        hadImmed = 0

        # Deal with labels
        tmp = re.match("(.*):\s+(.*)", line)
        if tmp:
            Label[tmp.group(1)] = PC
            line = tmp.group(2)

        # Trim leading whitespace
        line = re.sub("^\s+", "", line)

        # Split the line up into the opcode and the arguments
        tmp = re.split("\s+", line, 1)
        opcode = tmp[0]
        if len(tmp) > 1:
            args = tmp[1]
        else:
            args = ""

        # Check that the opcode exists
        if not opcode in Opcode:
            sys.exit("Unknown opcode: " + opcode + "\n")

        # Fill in the opcode of the machine instruction
        opc = Opcode[opcode][0]
        MCode.append(opc << 9)
        if opc == 59 or opc == 60 or opc == 68 or opc == 69:
            MCode[PC] += 7 << 3


        # Get the arguments as a list
        if len(args) != 0:
            argsList = re.split(",\s*", args)
        else:
            argsList = []

        # Check the correct # of arguments
        if len(Opcode[opcode][1]) != len(argsList):
            sys.exit("Bad # args: " + OriginalLine[PC] + "\n")

        # Process the arguments
        argId = 0

        for atype in list(Opcode[opcode][1]):

            # Get the arg
            arg = argsList[argId].strip()
            argId += 1

            # D-reg
            if atype == 'd':
                arg = re.sub("^\D*", "", arg)
                MCode[PC] += (int(arg) & 7)
                continue

            # D-reg, S-reg is D-reg
            if atype == 'D':
                arg = re.sub("^\D*", "", arg)
                MCode[PC] += (int(arg) & 7)
                MCode[PC] += (int(arg) & 7) << 3
                continue

            # S-reg
            if atype == 's':
                arg = re.sub("^\D*", "", arg)
                MCode[PC] += (int(arg) & 7) << 3
                continue

            # T-reg
            if atype == 't':
                arg = re.sub("^\D*", "", arg)
                MCode[PC] += (int(arg) & 7) << 6
                continue

            # Absolute immediate
            if atype == 'i':
                if re.match("^0x", arg):
                    arg = int(arg, 16)
                PC += 1
                MCode.append(arg)
                LType.append(1)
                OriginalLine.append("")
                continue

            # Relative immediate
            if atype == 'I':
                if re.match("^0x", arg):
                    arg = int(arg, 16)
                PC += 1
                MCode.append(arg)
                LType.append(2)
                OriginalLine.append("")
                continue

        PC += 1
f.close()


for i in range(0, len(MCode)):
    if LType[i] == 0:
        continue

    label = MCode[i]

    if not re.match("^-?\d+$", label):
        if not label in Label:
            sys.exit("Undefined label " + label + "\n")
        label = int(Label[label])

    if LType[i] == 2:
        label = int(label) - i

    MCode[i] = int(label) & 0xffff

for i in range(0, len(MCode)):
    print("{0}: {1} {2} {3}".format(hex(i)[2:].zfill(4), hex(MCode[i])[2:].zfill(8), "{0:016b}".format(MCode[i]), OriginalLine[i]))

outfile = sys.argv[1]
outfile = re.sub("\.[^\.*]$", ".ram", outfile)
with open(outfile, 'w') as f:
    f.write("v2.0 raw\n")
    for i in range(0, len(MCode)):
        f.write("{0} ".format(hex(MCode[i])[2:]))
        if i % 8 == 7:
            f.write("\n")
    f.write("\n")
f.close()
sys.exit(0)
