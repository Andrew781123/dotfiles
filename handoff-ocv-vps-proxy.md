# Handoff: set up `ocv` (VPS proxy) on this machine

**Run this on the target machine** (the one still on opencode v1). Do the two
halves in order: first migrate opencode **v1 → v2**, then wire the proxy.

`ocv` is a shell function that runs opencode with its model traffic leaving from
the Oracle Cloud Tokyo VPS instead of home, so **region-locked models** (the
`muse-spark-*` family) work. If you skip the proxy, those models fail with a
misleading `Authentication failed` error — see *"If a model still fails"* below.

**Full reference (why, the VPS config, verification):** [`docs/ocv-vps-proxy.md`](docs/ocv-vps-proxy.md).
Read it before Step 4. Do not duplicate its commands here — if the two disagree,
the doc wins.

## Prerequisite — on the *primary* machine, before this one

These files must be committed and pushed, or `git pull` here gets an incomplete
repo:

- `.zshrc` containing the `ocv()` function (currently **uncommitted** on the
  primary machine),
- `docs/ocv-vps-proxy.md` and this handoff.

Completion: `git -C ~/.dotfiles status --short` on the primary machine shows
these committed, and `origin` has them.

## Step 1 — Sync the repo

```sh
cd ~/.dotfiles && git pull --rebase
```

Completion: `test -f docs/ocv-vps-proxy.md && grep -q 'ocv()' .zshrc && echo OK`
prints `OK`.

## Step 2 — Migrate opencode v1 → v2

Use the bundled skill: **`opencode-v2-upgrade`** at
`.agents/skills/opencode-v2-upgrade/SKILL.md` in this repo (invoke it if your
agent loads skills; otherwise read and follow the file). It handles the brew
upgrade, `setup.sh` symlinks, skills mirror, and `/connect` auth; its Step 6 is
where you reconnect `commandcode` (credentials never sync — see *Secrets* below).

Completion (the skill's own final check, condensed):

```sh
opencode --version                     # prints 2.x
opencode models | grep -c '^commandcode/'
```

Both must hold before continuing.

## Step 3 — Add the SSH tunnel host

`~/.ssh/config` is **not tracked** in the repo, so add this block by hand. Fill
in `<VPS_PUBLIC_IP>` = the Oracle Tokyo instance's public IP (OCI console →
instance → public IP; or copy the `HostName` from the primary machine's
`~/.ssh/config`).

```
Host vps-open
  HostName <VPS_PUBLIC_IP>
  User ubuntu
  LocalForward 8888 127.0.0.1:8888
  ExitOnForwardFailure yes
  ConnectTimeout 10
  ServerAliveInterval 30
  ServerAliveCountMax 3
```

Completion: `ssh -o BatchMode=yes vps-open true` exits `0` with no password
prompt.

Do not change anything on the VPS: tinyproxy is already provisioned and bound to
loopback (the exact config is in the doc).

## Step 4 — Ensure `ocv` is loaded, then start tunnel + service

The migration step above ran `setup.sh`, which links `.zshrc`. Just load it:

```sh
exec zsh        # or open a new shell — .zshrc was linked in Step 2
type ocv        # -> "ocv is a shell function"
```

Now the important part. In opencode v2 the model calls are made by a background
server (`opencode serve --service`), **not** by the TUI. So the proxy env must be
in that server, not just in the shell that launches the TUI:

```sh
ssh -f -N vps-open             # start the tunnel
HTTPS_PROXY=http://127.0.0.1:8888 \
HTTP_PROXY=http://127.0.0.1:8888 \
NO_PROXY=localhost,127.0.0.1 \
  opencode service restart     # restart the server *inside* the proxy env
```

Completion: the server carries the proxy env —

```sh
ps eww -p "$(pgrep -f 'opencode serve --service' | head -1)" | tr ' ' '\n' | grep -i https_proxy
```

prints `HTTPS_PROXY=http://127.0.0.1:8888`.

Rule to remember: **anything that changes proxy settings needs
`opencode service restart`.** Re-running `ocv` only restarts the TUI and will not
pick up a new proxy.

## Step 5 — Verify end to end

Run the *Verification* section of `docs/ocv-vps-proxy.md`, then:

```sh
ocv                            # launch opencode through the proxy
```

Select a `muse-spark-*` model and send one message. Completion: it answers,
instead of erroring.

## If a model still fails

`Authentication failed. Please check your credentials.` on a `muse-spark-*`
model is **not** a credential problem — it is a `403 permission_error` geo-block
(proven in the doc). Check, in this order:

1. Is the request actually leaving via the VPS? `curl -s -x
   http://127.0.0.1:8888 https://ifconfig.me` must print the VPS IP.
2. Does the server carry the proxy env? Re-run Step 4's `ps eww` check.
3. Is the tunnel alive? `pgrep -fl "ssh -f -N vps-open"`.

Models that are *not* region-locked (for example `deepseek-v4.1-flash`) work
without the proxy, so a failure there points at a different problem.

## Secrets

- The Command Code API key does **not** sync between machines. Reconnect it with
  `/connect` → **Command Code** (Step 2, skill Step 6), or export
  `COMMANDCODE_API_KEY`. It lands in `~/.local/share/opencode/auth.json`.
- `<VPS_PUBLIC_IP>` and the SSH key are machine-local; the key is the default
  `~/.ssh/id_*` (`vps-open` sets no `IdentityFile`).
