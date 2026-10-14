# opencode agent stops mid-task on the Command Code provider (muse-spark)

**Goal.** Explain why the agent stops mid-task with no error, then hands control back
to the user, when running `muse-spark-1.3-contributor` through the custom
`commandcode` provider. State the cause, the evidence, and what to do about it.

**Status:** diagnosed 2026-10-14. Cause is the model, not the provider. Workaround:
use a different model.

## Symptom

During a multi-step task the agent runs one or more tool calls, then emits a short
line that *announces the next step* and stops:

> "Let me check the full sequence around seq 692 and the server log at that moment."

No error is shown. The session goes `idle`. The user must type "continue" to make it
resume — and when it resumes, it does the work it had just announced.

This is not the same as a crash or a failed request: nothing is broken, the stream
ends normally.

## Cause

`muse-spark-1.3-contributor` sometimes writes its intention to call a tool as
**plain text**, in a turn that contains **no tool calls**, and ends that turn with
finish reason `stop`.

opencode's loop then behaves correctly. Its rule is: if the turn finished with
`stop` (not `tool-calls`) and the last user message is older than this assistant
turn, the turn is complete — so the loop exits. There is nothing to execute, and
the assistant turn is a normal completion. The agent looks "quit" only because the
model's text promised more work than it delivered.

### Terms

- **finish reason** — the field that says why the model stopped generating. `stop`
  means "I am done"; `tool-calls` means "I want tools run before I continue".
- **text-only turn** — an assistant turn whose content is text and no tool calls.

## Evidence

### 1. Session records show the exact shape

Session `ses_ec6775c53ffeaBXBtnGkaoOn2F` (directory `/Users/andrew/.dotfiles`), the
session where the user reported the quits. Stored in
`~/.local/share/opencode/opencode.db`, table `session_message`.

Every reported quit is an assistant turn with `finish: "stop"`, no `tool` part, and
26–40 output tokens of text that announces the next action. Examples:

| seq | finish | output tokens | text |
|---|---|---|---|
| 569 | `stop` | 26 | "Both keys rejected. Let me get the exact failure point…" |
| 594 | `stop` | 40 | "geo-block is NOT active… Full frame capture next." |
| 692 | `stop` | 33 | "…Let me check how many tool calls preceded each quit…" |
| 727 | `stop` | 33 | "Now I can see this session's quit pattern clearly. Let me check…" |

Each is immediately followed by `idle (outcome: succeeded)`, then the user's
"continue", then a `tool-calls` turn that performs the announced work.

Turn census for that session:

| Model | Assistant turns | Tool-call turns | Text-only `stop` turns |
|---|---|---|---|
| `muse-spark-1.3-contributor` (medium) | 13 | 7 | **6** |
| `deepseek-v4.1-flash` (high) | 6 | 6 | **0** |

A second session (`ses_ec68b73abffe2D7qzvlKbAxnPq`, seq 65 → 82) shows the same
shape: the agent edited three files, then in the next turn wrote "Confirming the new
values are live everywhere." and stopped, without running the confirming tools.

### 2. The server log shows no failure

At each quit the opencode server log
(`~/.local/share/opencode/log/opencode.log`) contains only file-watcher lines. No
error, no dropped stream, no `exiting loop` entry tied to a fault.

### 3. Live gateway captures rule out the provider

Raw Server-Sent Events (SSE) frames were captured directly from
`https://api.commandcode.ai/alpha/generate` for `meta/muse-spark-1.3-contributor`,
in three turn shapes. The provider (`commandcode-go-opencode-provider`) maps every
shape correctly:

| Turn shape | Gateway frames (tail) | Provider stream parts |
|---|---|---|
| Tool call | `tool-call → finish-step(tool-calls) → finish(tool-calls)` | `… → tool-call → finish(tool-calls/tool-calls)` |
| Text only | `text-end → finish-step(stop) → finish(stop)` | `… → text-end → finish(stop/stop)` |
| Text, tools offered but unused | `text-end → finish-step(stop) → finish(stop)` | `… → text-end → finish(stop/stop)` |

The same three shapes were captured on `deepseek/deepseek-v4-flash` with identical
results. So the gateway always sends `finish-step` with a correct reason, and the
provider forwards it correctly. When tools are present the reason is `tool-calls`
and the loop continues. The quits are the "text only" row.

The three suspicious spots in the provider (`finish` event dropped as a no-op, a
missing `finishReason` defaulting to `stop`, and no synthetic `finish` on stream
close) are real code observations but are **not** triggered by this gateway: a
`finish-step` event always arrives and already produces the `finish` part. Changing
them is unnecessary and would risk the working contract.

## Environment at diagnosis

- opencode `v2.0.25`, service at `http://127.0.0.1:49374` (macOS).
- Provider: `commandcode-go-opencode-provider`, loaded by opencode from its package
  cache (npm **v0.4.0**). The local checkout `~/repos/opencode-commandcode-provider`
  is **v0.5.0** and unpublished, so editing the checkout alone does not change runtime
  behaviour.
- Model: `muse-spark-1.3-contributor`, variant `medium`.
- The Muse Spark geo-block was **not** active on this date: the model returned HTTP
  200 straight from Hong Kong. If it ever fails with `Authentication failed`, that is
  the unrelated geo-block — see `ocv-vps-proxy.md`.

## Workaround

Switch model. `deepseek-v4.1-flash` (variant `high`) ran the same multi-step task with
6 tool-call turns and zero text-only stops. Any model that reliably emits structured
tool calls instead of narrating them avoids the problem.

Prompt hints that reduce it on muse-spark: ask for tool calls without preamble, and
consider a higher effort variant.

## Relationship to upstream reports

This is not a new opencode bug, but it is **not** the issue that already has an open
fix, either.

- `#14972` "Agent stops after tool execution with OpenAI-compatible providers" —
  same *symptom*, different *mechanism*: there a tool call **does** execute and the
  provider wrongly reports `stop`, so the tool result is never processed. Fixed by
  PR `#14973` (checks for tool parts before breaking on `stop`). Our case has no tool
  call in the turn at all, so that fix does not apply.
- `#14842` (closed as stale, not fixed), `#8877` (generation terminated when
  `<tool_call>` appears in the stream), `#14063` (Gemini subagent stops immediately),
  `#15315` (tool intent emitted as plain text instead of structured parts — closest
  to our case).

If this is worth reporting upstream, it is a **model-output** report (tool intent sent
as text), with this session's seq numbers and the capture method below as evidence.

## Reproducing the frame capture

Reads the API key from the auth stores at runtime; does not print it.

```sh
KEY=$(python3 -c "import json;print(json.load(open('$HOME/.local/share/opencode/auth.json'))['commandcode']['key'])")
curl -sN https://api.commandcode.ai/alpha/generate \
  -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' \
  -H 'x-command-code-version: 0.26.20' \
  -H 'x-cli-environment: production' \
  -H 'x-project-slug: opencode' \
  -d '{"params":{"model":"meta/muse-spark-1.3-contributor","messages":[{"role":"user","content":"hi"}],"tools":[],"system":"","max_tokens":8,"stream":true},"config":{"workingDir":"/tmp","date":"2026-01-01","environment":"test","structure":[],"isGitRepo":false,"currentBranch":"","mainBranch":"","gitStatus":"","recentCommits":[]},"memory":"","taste":"","skills":null,"permissionMode":"standard"}'
```

Then feed the captured bytes through `parseStreamEvents()` from the provider's
`src/stream.ts` and check the part sequence, as the diagnosis script did.

## If it recurs

1. Confirm the turn is text-only: `finish: "stop"`, no `tool` part, low output token
   count. Query:
   ```sh
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT seq, data FROM session_message WHERE session_id='<session>' AND type='assistant';"
   ```
2. Check the model. If a different model does not quit on the same task, it is model
   output, not opencode.
3. Only if the frames show a tool call present **and** `finish-step(stop)`, or a
   missing `finish-step`, is there something for the provider or opencode to fix.

## Not investigated

- Whether a specific muse-spark prompt or effort variant removes the behaviour.
- The aggregate `bun test tests/unit/` hang in the provider repo (all 10 files pass
  individually; the combined run hangs after the banner). Separate issue.
