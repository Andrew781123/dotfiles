# `ocv` — route opencode through the VPS HTTP proxy

**Goal.** Make opencode's model traffic leave from the Oracle Cloud **Tokyo**
VPS instead of the home connection in **Hong Kong**, so that models which are
**region-locked** to Hong Kong can be used.

**Status:** live. VPS proxy + client tunnel + env all in place (2026-10-11).

## Why this exists (the symptom)

Selecting `commandcode/muse-spark-1.3-contributor` (or any **Muse Spark** model)
fails with:

```
Error: Authentication failed. Please check your credentials.
```

That message is **misleading — it is not a credential problem.**

| Where the request leaves from | Result for `meta/muse-spark-1.3-contributor` |
|---|---|
| Home connection, Hong Kong | **HTTP 403** `{"error":{"message":"Authentication failed. Please check your credentials.","type":"permission_error"}}` |
| Through the VPS, Tokyo | **HTTP 200**, generates normally |

The `type` is `permission_error`, not `authentication_error`; a genuinely bad
key gives a *different* body (`401 {"error":{"message":"Invalid 'Authorization'
header or token.","type":"authentication_error"}}`). So this is a geo/entitlement
block wearing an auth error's wording.

Other models are not blocked. `deepseek/deepseek-v4.1-flash` returns **200** even
from Hong Kong and works with no proxy at all. The whole Muse Spark family
(`meta/muse-spark-*`, including the non-`contributor` ones) is blocked from Hong
Kong. The `opencode-go` provider happens to describe the same block clearly:
"This model is not available in your country".

## Architecture

| Piece | Value |
|---|---|
| Proxy | `tinyproxy` 1.11 on Ubuntu 22.04 |
| VPS | Oracle Cloud, Tokyo (`ap-tokyo-1`), **the same instance as the WireGuard VPN** (see the homeserver repo's `vpn.md`); hostname `vpn-vnic` |
| Proxy address on the VPS | `127.0.0.1:8888` (loopback only) |
| Client tunnel | SSH `LocalForward 8888 127.0.0.1:8888`, host alias `vps-open` |
| Client env | `ocv()` in `.zshrc` sets `HTTP_PROXY`/`HTTPS_PROXY=http://127.0.0.1:8888` |

Flow: `opencode` → `127.0.0.1:8888` (local SSH forward) → SSH → VPS
`127.0.0.1:8888` (tinyproxy) → `api.commandcode.ai`.

## Part 1 — VPS side (already provisioned)

Effective lines in `/etc/tinyproxy/tinyproxy.conf` (`#` lines omitted):

```conf
User tinyproxy
Group tinyproxy
Port 8888
Listen 127.0.0.1
Allow 127.0.0.1
ConnectPort 443
ConnectPort 80
Timeout 600
```

`Listen 127.0.0.1` + `Allow 127.0.0.1` means only connections arriving on the
VPS's own loopback may use the proxy — i.e. only the SSH tunnel. It is **not**
exposed to the internet, so no VCN/security-list change is needed.

On a fresh VPS:

```sh
sudo apt-get update && sudo apt-get install -y tinyproxy
sudo tee /etc/tinyproxy/tinyproxy.conf >/dev/null <<'EOF'
User tinyproxy
Group tinyproxy
PidFile "/run/tinyproxy/tinyproxy.pid"
Port 8888
Listen 127.0.0.1
Allow 127.0.0.1
ConnectPort 443
ConnectPort 80
Timeout 600
EOF
sudo systemctl enable --now tinyproxy
```

### Gotcha: the systemd unit reports `failed` while the proxy works

The shipped unit is `Type=forking` with `PIDFile=/run/tinyproxy/tinyproxy.pid`.
The default config has **no `PidFile` line**, so the file is never written,
systemd times out waiting for it, and `systemctl is-active tinyproxy` says
`failed` (observed: `Result: timeout`) — even though `tinyproxy` is running and
serving. **Check the port, not the unit state:**

```sh
ss -ltn | grep 8888      # LISTEN 127.0.0.1:8888
```

Adding the `PidFile` line above (and starting the unit) makes the state clean.
The unit has no `Restart=`, so if the process dies the tunnel stays up but every
proxied request fails until tinyproxy is restarted.

## Part 2 — Client side

### `~/.ssh/config`

This file is **not tracked in the repo** — add it by hand on each machine:

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

`LocalForward` turns the Mac's `127.0.0.1:8888` into a door to port 8888 **on the
VPS**. `ExitOnForwardFailure yes` makes `ssh` fail loudly if the local port is
already taken, instead of silently running with no tunnel.

`<VPS_PUBLIC_IP>` = the Oracle Tokyo instance's public IP (OCI console → instance
→ public IP; on an already-provisioned machine it is the `HostName` in the
existing `~/.ssh/config`).

### `.zshrc` (tracked)

```zsh
ocv() {
  if ! lsof -nP -iTCP:8888 -sTCP:LISTEN >/dev/null 2>&1; then
    ssh -f -N vps-open || { echo "ocv: could not start SSH tunnel to vps-open" >&2; return 1; }
  fi
  HTTPS_PROXY=http://127.0.0.1:8888 \
  HTTP_PROXY=http://127.0.0.1:8888 \
  NO_PROXY=localhost,127.0.0.1 \
  opencode "$@"
}
```

`ocv` starts the tunnel once and then runs `opencode` with the proxy env. `ssh -f
-N` backgrounds the tunnel (`-N` = no remote command, `-f` = go to background).

## The trap: in opencode v2 a *background server* makes the model calls

Setting `HTTP_PROXY` for the TUI is **not enough**. opencode v2 delegates the
provider (LLM) HTTP calls to a separate, long-lived background server
(`opencode serve --service`) that the TUI only talks to. If that server was
started **without** the proxy variables, its requests still leave from Hong Kong
and get the 403 — and re-running `ocv` (which restarts only the TUI) does **not**
fix it, because the server keeps running.

Restart the server **inside the proxy environment**:

```sh
HTTPS_PROXY=http://127.0.0.1:8888 \
HTTP_PROXY=http://127.0.0.1:8888 \
NO_PROXY=localhost,127.0.0.1 \
  opencode service restart
```

`NO_PROXY=localhost,127.0.0.1` must stay: opencode talks to its own server on
`127.0.0.1`, and that traffic must not be proxied.

Rule of thumb: **anything that changes proxy settings needs
`opencode service restart`, not just a TUI restart.**

## Verification

```sh
# tunnel up?
pgrep -fl "ssh -f -N vps-open"
lsof -nP -iTCP:8888 -sTCP:LISTEN          # -> ssh

# egress really goes through the VPS (prints the VPS public IP)
curl -s -x http://127.0.0.1:8888 https://ifconfig.me

# which server serves your session, and does it carry the proxy env?
opencode service status                    # -> http://127.0.0.1:<port>
ps -o pid,lstart,command -p <pid>
ps eww -p <pid> | tr ' ' '\n' | grep -i proxy
```

To reproduce the geo-block itself, compare the two egress points with the
Command Code API (key read from opencode's auth store; do not print it):

```sh
KEY=$(python3 -c "import json;print(json.load(open('$HOME/.local/share/opencode/auth.json'))['commandcode']['key'])")
BODY='{"model":"meta/muse-spark-1.3-contributor","max_tokens":8,"messages":[{"role":"user","content":"hi"}]}'
# via the VPS -> 200
curl -s -o /dev/null -w '%{http_code}\n' -x http://127.0.0.1:8888 \
  https://api.commandcode.ai/provider/v1/chat/completions \
  -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' -d "$BODY"
# straight out (Hong Kong) -> 403 permission_error
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  curl -s -o /dev/null -w '%{http_code}\n' \
  https://api.commandcode.ai/provider/v1/chat/completions \
  -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' -d "$BODY"
```

## Provision a second machine

1. Copy this repo and run `setup.sh` — this links `.zshrc` (so `ocv` exists).
2. Add the `vps-open` block to `~/.ssh/config`, filling in `<VPS_PUBLIC_IP>`.
3. `ssh vps-open true` — proves the SSH key works. `ocv` starts the tunnel on
   first use afterwards.
4. Restart the opencode service with the proxy env (see *The trap* above).
   **This is the step that catches people out.**
5. Verify with the commands above; then select the region-locked model.

## Limits / notes

- The `ocv` guard (`lsof` on port 8888) only checks that *something* is
  listening; a stale, unrelated listener would make it skip starting the tunnel.
  If the model still fails, check `pgrep -fl "ssh -f -N vps-open"`.
- If the VPS is down, the proxied opencode service loses **all** provider access
  until it is restarted without the proxy env.
- The VPS also serves the WireGuard VPN (homeserver `vpn.md`); tinyproxy and
  WireGuard are independent and do not share ports.

## Where the secrets live

| Value | Lives in |
|---|---|
| VPS public IP | OCI console; `~/.ssh/config` (`HostName`) |
| SSH private key | `~/.ssh/` on the client (default key; `vps-open` sets no `IdentityFile`) |
| Command Code API key | opencode auth store `~/.local/share/opencode/auth.json`; mirrored to `~/.commandcode/auth.json` |

Nothing here is committed: `~/.ssh/config` is untracked, and the API key is only
read at runtime into a shell variable.
