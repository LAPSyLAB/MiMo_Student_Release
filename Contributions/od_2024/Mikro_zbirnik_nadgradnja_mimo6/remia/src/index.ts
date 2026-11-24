import { parseArgs } from "util";
import { file, inspect } from "bun";
import remia from "./remia.ohm-bundle";
import * as AST from "./ast"
import { evalString, v3HexWordsPlain } from "./util";
import { dirname } from "path"
import { buildFileCache, buildImage, pass1, pass2 } from "./assembler";

const { values, positionals } = parseArgs({
    args: Bun.argv,
    options: {},
    strict: true,
    allowPositionals: true,
});

console.assert(positionals.length == 3, 'remia <program>')

const inPath = positionals[2];
const contents = await file(inPath).text();
const baseDir = dirname(inPath);

const r = remia.match(contents);

if (!r.succeeded()) {
    console.error('Parse failed:', r.message);
    process.exit(1);
}

const ast = AST.getAst(r);
const fc = await buildFileCache(ast, baseDir);
const constsAndLabels = pass1(ast, fc);
const chunks = pass2(ast, fc, constsAndLabels);
const image = buildImage(chunks);
// console.log(constsAndLabels)
// console.log(chunks)
console.log(v3HexWordsPlain(image));
