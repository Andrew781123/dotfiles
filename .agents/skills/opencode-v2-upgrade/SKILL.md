---
name: opencode-v2-upgrade
description: >-
  Upgrade opencode to v2 on a machine provisioned from these dotfiles. Use when
  upgrading opencode, migrating a machine from opencode v1 to v2, running brew
  upgrade opencode, or when a machine's opencode setup lags the repo after the
  v2 migration.
license: MIT
metadata:
  author: dotfiles
  version: 1.0.0
  created: 2026-10-09
---

# opencode-v2-upgrade — bring a dotfiles machine to opencode 2.x

## Why this exists

Homebrew's `opencode` stable is v2 (2.0.20+); v1 (1.18.x) is no longer in the
formula and the two are not installed side by side. All opencode config is
symlinked from this repo (`~/.config/opencode` → `~/.dotfiles/opencode`), so the
config migration happened once, in the repo, on the primary machine. A secondary
machine only needs: pull, provision, upgrade, reconnect auth.

Preconditions — stop if unmet:

- The repo has `opencode/cli.json` and `opencode/opencode.json` containing
  `plugins` (native v2 shape). Without these, the repo predates the migration;
  do not upgrade — restore the repo first.
- `brew` manages `opencode`.
- Working tree clean (commit or stash first).

## Repo state vs machine-local state

| State | Lives where | Synced by |
|---|---|---|
| JSON/CLI config, themes, skills, AGENTS.md | repo (`opencode/`) | `git pull` |
| Provider credentials | `~/.local/share/opencode/auth.json` | nothing — reconnect per machine |
| npm plugin cache | `~/.cache/opencode/` | auto-installs on first start |
| opencode binary | Homebrew | `brew upgrade` |

Credentials never sync. Expect `/connect` work on a fresh machine even when the
other machine is already signed in.

## Procedure

1. Sync the repo and confirm the precondition.

   ```bash
   cd ~/.dotfiles && git pull --rebase
   test -f opencode/cli.json && rg -q '"plugins"' opencode/opencode.json && echo OK
   ```

   Completion: `OK` printed.

2. Optional rollback insurance — copy the current (v1) binary:

   ```bash
   cp "$(readlink -f "$(command -v opencode)")" ~/opencode-v1-backup
   ```

   Rollback is not graceful (see *Rollback*); prefer validating v2 on one
   machine before touching the rest.

3. Upgrade and provision.

   ```bash
   brew upgrade opencode
   ~/.dotfiles/setup.sh
   ```

   Completion: `opencode --version` reports 2.x, and `readlink ~/.config/opencode`
   points at the dotfiles repo.

4. Check symlink health (v2 reads `~/.config/opencode/AGENTS.md`):

   ```bash
   find -L ~/.config/opencode -maxdepth 3 -type l ! -exec test -e {} \; -print
   ```

   Completion: no output.

5. Mirror the bundled skills so agents discover them:

   ```bash
   cp -R ~/.dotfiles/.agents/skills/* ~/.agents/skills/
   ```

6. Reconnect auth. Run `opencode auth list`; for each missing provider, open
   `opencode` and run `/connect` (or `opencode auth login <provider>`).
   `commandcode` needs `@brainervirus/opencode-commandcode` loaded (already in
   repo config); it also accepts `COMMANDCODE_API_KEY`.

7. Verify (all must hold):

   ```bash
   opencode debug config > /tmp/oc-v2.json
   jq -r '.provider | keys[]' /tmp/oc-v2.json | head   # providers present, no error
   ```

   Then in the TUI: `/models` lists models, `/mcps` connects, one short message
   completes on the default model, the moonfly theme renders, and a workmux pane
   status flips working → done during that message.

## Rollback

v1 cannot read native v2 config, and brew no longer ships v1. If v2 fails on a
machine: put `~/opencode-v1-backup` back on `PATH`, and in the repo
`git checkout <pre-migration-commit> -- opencode/`. Keep the pre-migration
commit reachable; do not rewrite it away.

## Gotchas

- v1 and v2 share config paths — never run v1 against the migrated config.
- `cli.json` is CLI-owned: v2 rewrites it on settings changes. It is tracked in
  the repo on purpose (cross-machine parity); commit its changes deliberately.
- First v2 start installs npm plugins into `~/.cache/opencode`; a slow first
  launch is normal.
- `opencode/opencode.json` carries no MCP servers after the migration; add
  machine-specific ones with `opencode mcp add --global`.
- `.ponytail-active` and the notifier state file are runtime state inside the
  symlinked config dir. Leave them alone.
