---
name: srt-zht
description: Convert Simplified Chinese (zhs / zh-Hans) subtitles to Traditional (zht / zh-Hant), one file or a whole batch. Use when asked to convert subtitles to Traditional Chinese, batch-convert .srt files, produce a Taiwan or Hong Kong variant, or fix a machine-converted subtitle.
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# Convert subtitles to Traditional Chinese (zhs → zht)

Simplified → Traditional is a deterministic dictionary conversion, **not translation**. Run OpenCC for the bulk pass. Reach for the model only on the `hard lines` — the few cues a dictionary cannot resolve.

If `opencc` is missing: `brew install opencc`. Then `export PATH="/opt/homebrew/bin:$PATH"` — a non-interactive shell commonly lacks Homebrew's bin, so a bare `opencc` reads as "command not found" even when installed.

## 1. Pick the variant

| User means | Config |
|---|---|
| Taiwan, glyphs **and** vocabulary (default) | `s2twp.json` |
| Taiwan glyphs only | `s2tw.json` |
| Hong Kong | `s2hk.json` |
| Neutral OpenCC standard | `s2t.json` |

Only `s2twp.json` converts vocabulary (软件 → 軟體, 鼠标 → 滑鼠); `s2tw.json` changes glyphs only. When the user says "Traditional" with no region, use `s2twp.json` and state that choice.

## 2. Bulk convert

```
opencc -c s2twp.json -i IN.srt -o OUT.srt
```

Batch a folder, skipping files already converted:

```bash
find . -type f -name '*.zhs.srt' -print0 | while IFS= read -r -d '' f; do
  out="${f%.zhs.srt}.zht.srt"
  [ -e "$out" ] && continue
  if opencc -c s2twp.json -i "$f" -o "$out" && [ -s "$out" ]; then
    echo "ok   $f"
  else
    echo "FAIL $f"; rm -f "$out"
  fi
done
```

The cue index and `HH:MM:SS,mmm --> HH:MM:SS,mmm` lines are pure ASCII, so a whole-file pass leaves every structural line **byte-identical**. No SRT parser is needed.

## 3. Verify

Done when every output exists and is non-empty, and every structural line is byte-identical to its input. Both checks below print nothing on success:

```bash
diff <(grep -- '-->' IN.srt) <(grep -- '-->' OUT.srt)
diff <(grep -E '^[0-9]+$' IN.srt) <(grep -E '^[0-9]+$' OUT.srt)
find . -name '*.zht.srt' -size 0        # non-UTF-8 input: OpenCC exits 1, writes an empty file
```

Re-encode non-UTF-8 input before converting: `iconv -f GBK -t UTF-8 IN.srt | opencc -c s2twp.json -o OUT.srt`.

## 4. Hard lines

Most files are correct after step 2. A file that must be perfect, or genuine translation from another language, gets a model pass — hand it the file and pin the shape:

```bash
opencode run --auto --file OUT.zht.srt "Fix only cue texts where the traditional form is wrong in context (后/後, 干/乾/幹, 发/發/髮, 製/制). Rewrite only the cue text; keep every cue index and timestamp byte-identical. Output only the corrected SRT."
```

OpenCC can be wrong on one-to-many characters it has no context for: it turned `外國製` into `外國制` and `了解` into `瞭解`. `opencc -c s2twp.json --ambiguities -i IN.srt` streams JSONL of those spans, but it is noisy (127 hits on one 21 KB episode, mostly 了 / 麼 / 回) — read it as a hint list, not an automatic LLM queue.
