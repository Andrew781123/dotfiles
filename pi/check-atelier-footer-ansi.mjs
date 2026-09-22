#!/usr/bin/env node
// Guards a one-line local patch to pi-atelier.
//
// pi-atelier paints extension statuses with its own palette, so it must strip
// the extension's own ANSI first. Its `sanitize` used to only replace control
// chars, which turned ESC into a space and left "[38;2;102;102;102m" visible.
// Upstream main fixed footer.ts but no release contains it yet.
//
// Run after installing/updating pi packages. Exits 1 if the patch is gone.

import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const FOOTER = join(homedir(), ".pi/agent/npm/node_modules/pi-atelier/src/footer.ts");

// Exactly what ponytail's extension puts into ctx.ui.setStatus (theme.fg = truecolor ANSI).
const DIM = "\u001b[38;2;102;102;102m";
const RESET = "\u001b[39m";
const PONYTAIL_STATUS = `${DIM}○${RESET} 🐴 ${DIM}ponytail: ${RESET}${DIM}⚡ FULL${RESET}`;

const source = readFileSync(FOOTER, "utf8");
const match = source.match(/const sanitize = \(text: string\): string =>\s*text([\s\S]*?\.trim\(\);)/);
if (!match) {
	console.error(`FAIL: could not find pi-atelier's footer sanitize in ${FOOTER}`);
	process.exit(2);
}

// Evaluate the file's real sanitize chain, not a copy of it.
const sanitize = new Function("text", `return text${match[1]}`);

const got = sanitize(PONYTAIL_STATUS);

// eslint-disable-next-line no-control-regex
if (/[\u0000-\u001f]/.test(got) || /\[\d+(;\d+)*m/.test(got)) {
	console.error(`FAIL: ANSI leaked into the footer status line.\n  got: ${JSON.stringify(got)}`);
	console.error(`  fix: add .replace(/\\u001b\\[[0-?]*[ -/]*[@-~]/g, "") as the first call in ${FOOTER}`);
	process.exit(1);
}

const expected = "○ 🐴 ponytail: ⚡ FULL";
if (got !== expected) {
	console.error(`FAIL: unexpected sanitize output.\n  got:      ${JSON.stringify(got)}\n  expected: ${JSON.stringify(expected)}`);
	process.exit(1);
}

console.log(`ok: status renders clean -> ${JSON.stringify(got)}`);
