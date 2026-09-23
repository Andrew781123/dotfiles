---
name: workmux-upgrade
description: >-
  Upgrade the locally patched workmux without losing the Unicode tmux-target
  patch. Use when upgrading or bumping workmux, running brew upgrade, or when
  non-ASCII (e.g. Chinese) branch names show up transliterated to pinyin in tmux
  session titles again (the patch is gone).
license: MIT
metadata:
  author: dotfiles
  version: 1.0.0
  created: 2026-09-22
---

# workmux-upgrade — keep the Unicode tmux-target patch across upgrades

## Why this exists

Upstream workmux slugifies the branch name into both the worktree directory and
the tmux target, and `slug::slugify` transliterates Unicode — so `feature/中文分支`
becomes `feature-zhong-wen-fen-zhi`. The local patch keeps the directory ASCII
but lets the tmux session/window name keep the branch's own characters
(`feature-中文分支`).

The patch: `workmux-unicode-tmux-target.patch` (in this skill's directory). It
touches `src/naming.rs` (new `slugify_keep_unicode` + `derive_mux_target_name`)
and `src/command/add.rs` (default the target to the branch name).

## Where the binary lives

| Path | State |
|------|-------|
| `~/.cargo/bin/workmux` | **patched**, built from source |
| `/opt/homebrew/bin/workmux` | unpatched Homebrew formula |

`~/.cargo/bin` must precede `/opt/homebrew/bin` in `PATH` for the patched binary
to win. The dotfiles `.zshrc` enforces this with
`export PATH="$HOME/.cargo/bin:$PATH"`, placed after the Homebrew prepends. On a
new machine, add that line, then `exec zsh` and restart the tmux server
(`tmux kill-server`) so panes inherit the corrected order. `brew upgrade workmux`
replaces only the Homebrew copy, so the patch survives — it is shadowed.

Existing sessions keep the names they were created with; the patch only affects
newly created targets. Rename or recreate old ones separately.

**Never run `workmux update`** — it self-updates the running binary in place,
overwriting `~/.cargo/bin/workmux` with unpatched upstream.

## Upgrade procedure

```bash
VER=v0.1.264                       # target tag; see https://github.com/raine/workmux/releases
SKILL=~/.dotfiles/.agents/skills/workmux-upgrade

# 1. Fresh source at the tag (or main/master for latest)
git clone --depth 1 --branch "$VER" https://github.com/raine/workmux /tmp/workmux-src

# 2. Apply the patch
git -C /tmp/workmux-src apply "$SKILL/workmux-unicode-tmux-target.patch"

# 3. Build
cargo build --release --manifest-path /tmp/workmux-src/Cargo.toml

# 4. Install over the patched binary
install -m 755 /tmp/workmux-src/target/release/workmux ~/.cargo/bin/workmux
```

If step 2 fails, upstream changed the surrounding code — see *Patch drift*.

## Verify (completion criterion)

```bash
which -a workmux                              # ~/.cargo/bin/workmux must be first
workmux add "feature/中文分支" --dry-run       # Target must read: feature-中文分支
```

Both must hold: the patched binary resolves first, and the dry-run `Target:`
line preserves the Chinese characters instead of `zhong-wen-fen-zhi`.

## Patch drift

The patch is small and local. If `git apply` rejects it after an upstream
change, re-derive by hand:

- `src/naming.rs` — add `slugify_keep_unicode` (keep `char::is_alphanumeric`
  chars, collapse other runs to `-`) and `derive_mux_target_name`; leave
  `derive_handle` using ASCII `slug::slugify` so directories stay slugified.
- `src/command/add.rs` — when no `--target-name` and no `--name` and not
  multi-worktree, set `options.target_session_name`/`target_window_name` to
  `derive_mux_target_name(branch_name)`.

Then test with the dry-run check above, rebuild, and regenerate the patch with
`git -C /tmp/workmux-src diff > "$SKILL/workmux-unicode-tmux-target.patch"`.

Worktree lifecycle stays consistent because the target name is persisted in git
config (`workmux.worktree.<handle>.target-session`) and read back by
`open`/`close`/`list`/`remove` — no wrapper or manual `tmux rename-session`.
