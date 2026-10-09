import { mkdir, readFile, writeFile, stat, access } from "node:fs/promises"
import { join, dirname, basename, extname, resolve } from "node:path"

/**
 * Gemini image tools, ported from the V1 `tool/gemini` directory to the V2
 * plugin API. The `.env` lookup helper that used to live in `tool/env` is
 * folded in here, since gemini was its only consumer.
 */

const DEFAULT_ENV_PATHS = ["./.env", "../.env", "../../.env", "../plugin/.env", "../../../.env"]

function isTestMode(): boolean {
  return process.env.GEMINI_TEST_MODE === "true"
}

async function loadEnvVariables(searchPaths: string[] = DEFAULT_ENV_PATHS): Promise<Record<string, string>> {
  const loadedVars: Record<string, string> = {}

  for (const envPath of searchPaths) {
    try {
      const content = await readFile(resolve(envPath), "utf8")
      for (const line of content.split("\n")) {
        const trimmed = line.trim()
        if (trimmed && !trimmed.startsWith("#") && trimmed.includes("=")) {
          const [key, ...valueParts] = trimmed.split("=")
          const value = valueParts.join("=").trim().replace(/^["']|["']$/g, "")
          if (key && value && !process.env[key]) {
            process.env[key] = value
            loadedVars[key] = value
          }
        }
      }
    } catch {
      // File doesn't exist or can't be read, continue to next
    }
  }

  return loadedVars
}

async function getGeminiApiKey(): Promise<string> {
  if (isTestMode()) {
    return "test-api-key"
  }
  if (process.env.GEMINI_API_KEY) {
    return process.env.GEMINI_API_KEY
  }
  const loaded = await loadEnvVariables()
  const key = loaded.GEMINI_API_KEY || process.env.GEMINI_API_KEY
  if (!key) {
    throw new Error("GEMINI_API_KEY not found. Set it in the environment or a .env file.")
  }
  return key
}

interface ImageConfig {
  outputDir?: string
  useTimestamp?: boolean
  preserveOriginal?: boolean
  customName?: string
}

const MIME_BY_EXTENSION: Record<string, string> = {
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
}

async function parseImageInput(input: string): Promise<{ mime: string; base64: string }> {
  if (input.startsWith("data:")) {
    const base64 = input.split(",")[1]
    const mime = input.substring(5, input.indexOf(";"))
    return { mime, base64 }
  }
  const buffer = await readFile(input)
  const mime = MIME_BY_EXTENSION[extname(input).toLowerCase()] || "image/png"
  return { mime, base64: buffer.toString("base64") }
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await access(path)
    return true
  } catch {
    return false
  }
}

function getDateBasedPath(baseDir?: string): string {
  if (!baseDir) {
    baseDir = resolve(process.cwd(), "../../assets/images")
  }
  const today = new Date().toISOString().split("T")[0]
  return join(baseDir, today)
}

async function getUniqueFilename(
  directory: string,
  baseName: string,
  extension: string,
  isEdit: boolean = false,
): Promise<string> {
  await mkdir(directory, { recursive: true })

  if (!isEdit) {
    const baseFilename = join(directory, `${baseName}${extension}`)
    if (!(await fileExists(baseFilename))) {
      return baseFilename
    }
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
    return join(directory, `${baseName}_${timestamp}${extension}`)
  }

  let counter = 1
  let filename: string
  do {
    const editSuffix = `_edit_${counter.toString().padStart(3, "0")}`
    filename = join(directory, `${baseName}${editSuffix}${extension}`)
    counter++
  } while (await fileExists(filename))

  return filename
}

function stripImageExtension(name: string): string {
  return /\.(png|jpe?g)$/i.test(name) ? name.substring(0, name.lastIndexOf(".")) : name
}

function buildImageBody(prompt: string, image?: { mime: string; base64: string }) {
  const parts: Record<string, unknown>[] = [{ text: prompt }]
  if (image) {
    parts.push({ inlineData: { mimeType: image.mime, data: image.base64 } })
  }
  return JSON.stringify({ contents: [{ parts }] })
}

async function requestGemini(model: string, body: string): Promise<any> {
  const apiKey = await getGeminiApiKey()
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body,
    },
  )
  if (!res.ok) {
    throw new Error(`API error (${res.status}): ${await res.text()}`)
  }
  const json = await res.json()
  const candidates = json?.candidates
  if (!candidates || candidates.length === 0) {
    throw new Error("No candidates in response")
  }
  return candidates[0]
}

function imagePartOf(candidate: any): string | null {
  const parts = candidate?.content?.parts
  if (!parts || parts.length === 0) {
    throw new Error("No parts in response")
  }
  for (const part of parts) {
    if (part.inlineData?.data) {
      return part.inlineData.data
    }
  }
  return null
}

async function saveImage(b64: string, outputPath: string, label: string): Promise<string> {
  console.log(`Saving ${label} to: ${outputPath}`)
  await writeFile(outputPath, Buffer.from(b64, "base64"))
  if (!(await fileExists(outputPath))) {
    throw new Error(`Failed to save file to ${outputPath}`)
  }
  const stats = await stat(outputPath)
  return outputPath + ` (${stats.size} bytes)`
}

export async function generateImage(prompt: string, config: ImageConfig = {}): Promise<string> {
  const baseName = stripImageExtension(config.customName || "generated")
  const generationsDir = join(config.outputDir || getDateBasedPath(), "generations")
  const outputPath = await getUniqueFilename(generationsDir, baseName, ".png", false)

  if (isTestMode()) {
    return `[TEST MODE] Would generate image: ${outputPath} for prompt: "${prompt.substring(0, 50)}..."`
  }

  const b64 = imagePartOf(await requestGemini("gemini-2.5-flash-image-preview", buildImageBody(prompt)))
  if (!b64) {
    throw new Error("No image data returned from Nano Banana model")
  }
  return `Generated image saved: ${await saveImage(b64, outputPath, "generated image")}`
}

export async function editImage(imagePath: string, prompt: string, config: ImageConfig = {}): Promise<string> {
  const originalName = basename(imagePath, extname(imagePath))
  const baseName = stripImageExtension(config.customName || originalName)
  const editsDir = join(config.outputDir || getDateBasedPath(), "edits")
  const outputPath = await getUniqueFilename(editsDir, baseName, ".png", true)

  if (isTestMode()) {
    return `[TEST MODE] Would edit image: ${imagePath} -> ${outputPath} with prompt: "${prompt.substring(0, 50)}..."`
  }

  const image = await parseImageInput(imagePath)
  const b64 = imagePartOf(await requestGemini("gemini-2.5-flash-image-preview", buildImageBody(prompt, image)))
  if (!b64) {
    throw new Error("No image data returned from Nano Banana model")
  }
  return `Edited image saved: ${await saveImage(b64, outputPath, "edited image")}`
}

export async function analyzeImage(imagePath: string, question: string): Promise<string> {
  if (isTestMode()) {
    return `[TEST MODE] Would analyze image: ${imagePath} with question: "${question.substring(0, 50)}..." - Mock analysis: This is a test image analysis response.`
  }

  const image = await parseImageInput(imagePath)
  const candidate = await requestGemini("gemini-1.5-flash", buildImageBody(question, image))
  const text = candidate?.content?.parts?.[0]?.text
  if (!text) {
    throw new Error("No analysis returned")
  }
  return text
}

function jsonSchema(properties: Record<string, unknown>, required: string[]) {
  return { type: "object", properties, required, additionalProperties: false }
}

export default {
  id: "gemini-image",
  async setup(ctx: { tool: { transform(editor: any): Promise<void> } }) {
    await ctx.tool.transform((editor: any) => {
      editor.add({
        name: "gemini_generate",
        description: "Generate an image using Gemini Nano Banana from text prompt",
        input: jsonSchema(
          {
            prompt: { type: "string", description: "Text description of the image to generate" },
            outputDir: { type: "string", description: "Custom output directory (default: assets/images/YYYY-MM-DD/)" },
            filename: { type: "string", description: "Custom filename (default: generated)" },
          },
          ["prompt"],
        ),
        async execute(input: { prompt: string; outputDir?: string; filename?: string }) {
          try {
            return { content: await generateImage(input.prompt, { outputDir: input.outputDir, customName: input.filename }) }
          } catch (error: any) {
            return { content: `Error: ${error.message}` }
          }
        },
      })

      editor.add({
        name: "gemini_edit",
        description: "Edit an existing image using Gemini Nano Banana",
        input: jsonSchema(
          {
            image: { type: "string", description: "File path or data URL of image to edit" },
            prompt: { type: "string", description: "Edit instruction" },
            outputDir: { type: "string", description: "Custom output directory (default: assets/images/YYYY-MM-DD/)" },
            filename: { type: "string", description: "Custom filename (default: original name with _edit_XXX)" },
          },
          ["image", "prompt"],
        ),
        async execute(input: { image: string; prompt: string; outputDir?: string; filename?: string }) {
          try {
            return { content: await editImage(input.image, input.prompt, { outputDir: input.outputDir, customName: input.filename }) }
          } catch (error: any) {
            return { content: `Error: ${error.message}` }
          }
        },
      })

      editor.add({
        name: "gemini_analyze",
        description: "Analyze an image using Gemini (text analysis only)",
        input: jsonSchema(
          {
            image: { type: "string", description: "File path or data URL of image to analyze" },
            question: { type: "string", description: "What to analyze about the image" },
          },
          ["image", "question"],
        ),
        async execute(input: { image: string; question: string }) {
          try {
            return { content: await analyzeImage(input.image, input.question) }
          } catch (error: any) {
            return { content: `Error: ${error.message}` }
          }
        },
      })
    })
  },
}
