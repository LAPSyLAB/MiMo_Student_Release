export function evalString(str: string) {
    return JSON.parse(str) as string
}

export function evalNumber(int: string) {
    return parseInt(int);
}

export function stringToU16Buf(s: string, type: '.ascii' | '.asciz' | '.utf16'): Uint16Array {
    if (type === '.utf16') {
        const utf16Array = [];
        for (const char of s) {
            const code = char.codePointAt(0)!;
            if (code > 0xffff) {
                // Handle surrogate pairs for non-BMP characters
                const highSurrogate = 0xd800 + ((code - 0x10000) >> 10);
                const lowSurrogate = 0xdc00 + ((code - 0x10000) & 0x3ff);
                utf16Array.push(highSurrogate, lowSurrogate);
            } else {
                utf16Array.push(code);
            }
        }
        if (utf16Array.length % 2 !== 0) {
            utf16Array.push(0);
        }
        return new Uint16Array(utf16Array);
    } else {
        const byteArray = [];
        for (let i = 0; i < s.length; i++) {
            let code = s.charCodeAt(i);
            if (code > 0x7f) {
                code = '?'.charCodeAt(0);
            }
            byteArray.push(code);
        }

        if (type === '.asciz') {
            byteArray.push(0);
        }

        if (byteArray.length % 2 !== 0) {
            byteArray.push(0);
        }

        const u16Array = new Uint16Array(byteArray.length / 2);
        for (let i = 0; i < byteArray.length; i += 2) {
            const high = byteArray[i] || 0;
            const low = byteArray[i + 1] || 0;
            u16Array[i / 2] = (high << 8) | low;
        }
        return u16Array;
    }
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
