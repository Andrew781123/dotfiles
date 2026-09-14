---
name: tmux-env-setup
description: >-
  Machine-specific environment variable setup for tmux keybinds.
  Documents how .tmux.local configures repo paths for
  tmux-sessionizer bindings, and how to port to another machine.
disable-model-invocation: true
license: MIT
metadata:
  author: dotfiles
  version: 1.0.0
  created: 2026-09-10
---

# tmux-env-setup — Machine-specific tmux keybind paths

## How it works

`.tmux.conf` sources `~/.tmux.local` at startup if it exists. That file
defines tmux environment variables (`setenv -g`) that the sessionizer
keybinds reference via `$VAR`.

```
# .tmux.conf (top)
if-shell 'test -f ~/.tmux.local' 'source ~/.tmux.local'
```

## Bind map

| Key   | Variable          | Default               |
|-------|-------------------|-----------------------|
| `C-a j` | `$PRINCESS_DATING` | `~/repos/princess-dating` |
| `C-a J` | `$NEORG`           | `~/neorg`                 |
| `C-a k` | `$PRINCESS_CMS`    | `~/repos/princess-cms`    |
| `C-a l` | `$DOTFILES`        | `~/.dotfiles`             |

## Files

- `.tmux.local` — machine-specific paths (gitignored, symlinked to `~/.tmux.local`)
- `.tmux.local.example` — template to copy on a new machine

## Porting to another machine

```bash
cp .tmux.local.example .tmux.local
# edit paths to match the new machine
tmux source-file ~/.tmux.conf
```
