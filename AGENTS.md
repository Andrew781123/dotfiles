# AGENTS.md

Cross-agent context for this dotfiles repo. Read this before making changes.

## Layout

- `setup.sh` — Brewfile + symlinks. Run on a fresh machine.
- `Brewfile` — Homebrew packages (includes `tuicr`).
- `.agents/skills/` — Mirror of agent skills installed at `~/.agents/skills/`. Keeps a portable copy for provisioning other machines.
- `GEMINI.md` — Gemini-specific notes (model preference).
- `AGENTS.global.md` — Global agent rules (all repos, all machines). `setup.sh` symlinks it to both `~/AGENTS.md` and `~/.config/opencode/AGENTS.md`. This file is the single source of truth; edit it, never the symlinks.
- `env.secrets.age` — Age-encrypted secrets. Decrypted by `setup.sh` when `key.txt` is present.

## Global rules

`~/.config/opencode/AGENTS.md` is what opencode loads as global instructions; `~/AGENTS.md` covers other tools and directory traversal. Both are symlinks to `AGENTS.global.md`, so editing the symlink edits the repo copy. opencode does **not** parse `@file` references in `AGENTS.md` — symlinks are the mechanism, not `@`.

## Skills

Bundled skills live under `.agents/skills/` and are installed to `~/.agents/skills/<name>/` on this machine. Tools that read `~/.agents/skills/` (Codex, Gemini, opencode, Goose, Claude Code, etc.) discover them automatically.

| Skill | Source | Notes |
|-------|--------|-------|
| `glance-config-skill` | local | Glance dashboard config assistant |
| `tuicr` | upstream: `agavra/tuicr` | TUI code-review CLI wrapper for tmux/cmux/Zellij/Herdr |

## Install skills on another machine

From this repo:

```bash
# Mirror everything bundled here
cp -R .agents/skills/* ~/.agents/skills/
chmod +x ~/.agents/skills/tuicr/tuicr-wrapper*.sh

# Tool-specific paths (opencode reads from here too)
cp -R .agents/skills/tuicr ~/.config/opencode/skills/tuicr
```

Or pull `tuicr` fresh from upstream:

```bash
gh repo clone agavra/tuicr /tmp/tuicr
cp -R /tmp/tuicr/skills/tuicr ~/.agents/skills/tuicr
chmod +x ~/.agents/skills/tuicr/tuicr-wrapper*.sh
```

## Refreshing the `tuicr` mirror

```bash
gh repo clone agavra/tuicr /tmp/tuicr -- --depth 1
cp -R /tmp/tuicr/skills/tuicr/* .agents/skills/tuicr/
chmod +x .agents/skills/tuicr/tuicr-wrapper*.sh
cp -R /tmp/tuicr/skills/tuicr/* ~/.agents/skills/tuicr/
```