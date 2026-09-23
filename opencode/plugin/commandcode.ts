import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs"
import { homedir } from "os"
import { join, dirname } from "path"
import type { Plugin } from "@opencode-ai/plugin"

const CATALOG_URL = "https://api.commandcode.ai/provider/v1/models"
const CACHE = join(homedir(), ".cache", "opencode", "commandcode-catalog.json")

function apiKey(): string | undefined {
  if (process.env.COMMANDCODE_API_KEY) return process.env.COMMANDCODE_API_KEY
  for (const p of [
    join(homedir(), ".commandcode", "auth.json"),
    join(homedir(), ".pi", "agent", "auth.json"),
  ]) {
    if (!existsSync(p)) continue
    try {
      const j = JSON.parse(readFileSync(p, "utf-8"))
      const v = j["command-code"] ?? j.commandcode
      const key = typeof v === "string" ? v : v?.key ?? v?.access
      if (key) return key
    } catch {}
  }
}

interface ApiModel {
  id: string
  name: string
  context_length?: number
  supported_endpoints?: string[]
}

async function catalog(): Promise<ApiModel[]> {
  try {
    const res = await fetch(CATALOG_URL, { signal: AbortSignal.timeout(5000) })
    const data = ((await res.json()) as { data: ApiModel[] }).data
    if (!Array.isArray(data) || !data.length) throw new Error("empty catalog")
    mkdirSync(dirname(CACHE), { recursive: true })
    writeFileSync(CACHE, JSON.stringify(data))
    return data
  } catch {
    try {
      return JSON.parse(readFileSync(CACHE, "utf-8"))
    } catch {
      return []
    }
  }
}

// ponytail: denylist of models known to be non-reasoning; everything else is
// treated as reasoning-capable. Add here if a model unexpectedly returns none.
const NON_REASONING =
  /haiku|GLM-5$|GLM-5\.1|glm-5\.2-Fast|Kimi-K2\.[56]|MiniMax-M2\.|mimo-v2\.5/i

function entry(m: ApiModel) {
  return {
    name: m.name,
    reasoning: !NON_REASONING.test(m.id),
    // The provider accepts image parts for every model (text-only models just
    // ignore them), so advertising vision everywhere avoids blocking capable
    // models. opencode gates image input on `modalities.input`, not `attachment`.
    attachment: true,
    modalities: { input: ["text", "image"], output: ["text"] },
    ...(/^gpt-6(?:[.-]|$)/i.test(m.id)
      ? { variants: { xhigh: { reasoningEffort: "xhigh" }, max: { reasoningEffort: "max" } } }
      : {}),
    ...(m.context_length
      ? { limit: { context: m.context_length, output: 65536 } }
      : {}),
  }
}

export const CommandCode: Plugin = async () => ({
  async config(config) {
    const key = apiKey()
    const models = await catalog()
    if (!models.length) return

    const chat: Record<string, unknown> = {}
    const messages: Record<string, unknown> = {}
    for (const m of models) {
      const eps =
        m.supported_endpoints ??
        (m.id.startsWith("claude-") ? ["/messages"] : ["/chat/completions"])
      ;(eps.includes("/messages") ? messages : chat)[m.id] = entry(m)
    }

    const providers: Record<string, unknown> = {
      ...config.provider,
      commandcode: {
        npm: "@ai-sdk/openai-compatible",
        name: "Command Code",
        options: {
          baseURL: "https://api.commandcode.ai/provider/v1",
          ...(key ? { apiKey: key } : {}),
        },
        models: chat,
      },
    }
    if (Object.keys(messages).length) {
      providers["commandcode-claude"] = {
        npm: "@ai-sdk/anthropic",
        name: "Command Code (Claude)",
        options: {
          baseURL: "https://api.commandcode.ai/provider/v1",
          ...(key ? { apiKey: key } : {}),
        },
        models: messages,
      }
    }
    config.provider = providers
  },
})
