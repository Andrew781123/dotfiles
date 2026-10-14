import re, sys

# Snap whisper.cpp SRT cue boundaries to Silero VAD speech bursts.
# Usage: python3 vad_retime.py IN.srt OUT.srt vad_segments.txt
# vad_segments.txt: lines from `whisper-vad-speech-segments ... | grep "VAD segment"`
# Text is never touched; only start/end times move.

def parse_srt(path):
    with open(path, encoding='utf-8') as f:
        content = f.read().strip()
    cues = []
    for b in content.split('\n\n'):
        lines = b.splitlines()
        m = re.match(r'(\d+:\d+:\d+,\d+) --> (\d+:\d+:\d+,\d+)', lines[1])
        cues.append((m.group(1), m.group(2), '\n'.join(lines[2:])))
    return cues

def to_s(s):
    h, m, rest = s.split(':')
    sec, ms = rest.split(',')
    return int(h)*3600 + int(m)*60 + int(sec) + int(ms)/1000

def to_ts(s):
    ms = int(round(s*1000))
    h, ms = divmod(ms, 3600000); m, ms = divmod(ms, 60000); sec, ms = divmod(ms, 1000)
    return f'{h:02d}:{m:02d}:{sec:02d},{ms:03d}'

def load_vad(path):
    segs = []
    pat = re.compile(r'start = ([\d.]+), end = ([\d.]+)')
    with open(path) as f:
        for line in f:
            m = pat.search(line)
            if m:
                segs.append((float(m.group(1)), float(m.group(2))))
    return segs

def overlapping(vad, s, e, tol=0.05):
    return [v for v in vad if v[0] < e - tol and v[1] > s + tol]

def retime(srt_path, vad, out_path, pad=0.15, min_gap=0.08, min_dur=0.8):
    cues = parse_srt(srt_path)
    starts = [to_s(s) for s, _, _ in cues]
    ends = [to_s(e) for _, e, _ in cues]
    out = []
    prev_end = 0.0
    for i, (s, e, text) in enumerate(zip(starts, ends, [c[2] for c in cues])):
        ov = overlapping(vad, s, e)
        if ov:
            cand_start = max(ov[0][0] - pad, 0.0)
            cand_start = max(cand_start, s - 1.0)  # don't drift more than 1s early
            ns = max(cand_start, prev_end + (min_gap if prev_end > 0 else 0.0))
            cand_end = ov[-1][1] + pad
        else:
            ns = max(s, prev_end + min_gap)
            cand_end = e
        limit = (starts[i+1] if i+1 < len(starts) else e + 30) - min_gap
        ne = min(cand_end, limit)
        if ne < ns + min_dur:
            ne = min(ns + min_dur, limit if limit > ns else ns + min_dur)
        out.append((ns, ne, text))
        prev_end = ne
    with open(out_path, 'w', encoding='utf-8') as f:
        for i, (ns, ne, text) in enumerate(out, 1):
            f.write(f'{i}\n{to_ts(ns)} --> {to_ts(ne)}\n{text}\n\n')
    gaps = [(out[i+1][0]-out[i][1]) for i in range(len(out)-1)]
    big = [g for g in gaps if g > 0.3]
    print(f'{out_path}: {len(out)} cues, {len(big)} gaps >300ms, '
          f'max gap {max(gaps):.2f}s, on-screen {sum(ne-ns for ns,ne,_ in out):.0f}s')

if __name__ == '__main__':
    vad = load_vad(sys.argv[3])
    print(f'loaded {len(vad)} VAD segments')
    retime(sys.argv[1], vad, sys.argv[2])
