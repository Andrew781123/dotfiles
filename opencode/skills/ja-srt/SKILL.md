---
name: ja-srt
description: Transcribe Japanese audio/video to zh-TW (Taiwan) subtitles with whisper.cpp, or fix subtitles that linger on screen during silence. Use when asked to subtitle Japanese content, transcribe Japanese speech to SRT, translate Japanese subtitles to Traditional Chinese, or when subtitle text stays visible through silent pauses.
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# Japanese audio/video → zh-TW subtitles

Pipeline: whisper.cpp transcribes (`-l ja`), the model translates against a fixed name glossary, Silero VAD snaps cue edges to real speech. Timing is machine-fixed; text is human-checked once.

## 0. Models (once)

```bash
mkdir -p ~/Models/whisper
curl -L -o ~/Models/whisper/ggml-large-v3-turbo.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
curl -L -o ~/Models/whisper/ggml-silero-v5.1.2.bin https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin
```

`large-v3-turbo` matches full `large-v3` on Japanese (5.8% vs 6.6% CER) at ~4–8x the speed; smaller models mangle proper nouns. Done when both files exist (~1.5 GB + 864 KB).

## 1. Glossary before anything else

Collect character/cast names and their fixed zh-TW forms first — whisper hears sound, not kanji (it wrote 笠谷 for 粕屋, 松島 for 松嶋), so names get fixed at translation, never in the Japanese SRT. Done when a table like `神野桜子=神野櫻子, 中原欧介=中原歐介` exists; pass it to step 3 verbatim, plus domain terms (合コン=聯誼, 客室乗務員=空姐).

## 2. Transcribe

whisper-cli reads wav/flac/mp3/ogg, so extract first (keep the wav for step 4):

```bash
ffmpeg -y -v error -i IN.mkv -vn -ac 1 -ar 16000 IN.wav
whisper-cli -m ~/Models/whisper/ggml-large-v3-turbo.bin -l ja -t 8 \
  --output-srt --output-file IN.ja \
  --prompt "<character and cast names in Japanese>" -f IN.wav
```

`-l ja` forces Japanese (short clips misdetect otherwise); `--prompt` with names biases proper nouns. Batch a folder by repeating these two lines per file. Done when each `.ja.srt` is non-empty with monotonic timestamps.

## 3. Translate ja → zht

Real translation, not OpenCC (OpenCC only remaps Simplified↔Traditional glyphs; it cannot read Japanese). Hand the model the `.ja.srt` with the step-1 glossary:

```
Translate every Japanese cue into Traditional Chinese (Taiwan). Glossary (fixed, use exactly): .... Keep cue indices and 'HH:MM:SS,mmm --> HH:MM:SS,mmm' lines byte-identical; translate only text lines. Output to IN.zht.srt. Report uncertain names.
```

## 4. Retime with VAD

whisper.cpp chains cues end-to-start, so text lingers through silence. Its token timestamps mirror the segment edges — no timing signal there — so snap to Silero speech bursts instead (script lives beside this file):

```bash
whisper-vad-speech-segments -vm ~/Models/whisper/ggml-silero-v5.1.2.bin -f IN.wav 2>&1 | grep "VAD segment" > vad.txt
python3 ~/.config/opencode/skills/ja-srt/vad_retime.py IN.ja.srt IN.timed.ja.srt vad.txt
python3 ~/.config/opencode/skills/ja-srt/vad_retime.py IN.zht.srt IN.timed.zht.srt vad.txt
```

The script moves only times: cue edges snap to the overlapping speech burst ±150ms, minimum 80ms gap. Room-noise audio defeats energy-based silence detection (`silencedetect` finds nothing); that is exactly when VAD is needed. Done when the script reports gaps >300ms and step 5 passes; then `mv` the timed files over the originals and delete the wav.

## 5. Verify

```bash
diff <(grep -- '-->' IN.ja.srt) <(grep -- '-->' IN.zht.srt) && echo "SYNC OK"
diff <(grep -v -- '-->' IN.ja.srt | grep -vE '^[0-9]+$') <(grep -v -- '-->' IN.timed.ja.srt | grep -vE '^[0-9]+$') && echo "TEXT OK"
```

SYNC OK means ja/zht timestamps match; TEXT OK means retiming moved no words. Cue count must be unchanged throughout.
