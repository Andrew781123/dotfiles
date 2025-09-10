- The user prefers the "pro" model.
- The user wants me to avoid using `@ts-ignore` or the `any` type. I should find type-safe solutions instead.

- When creating tables in Prisma schema files, always group columns by type (e.g., primary keys, timestamps, relations) and separate each group with a blank line for readability.

## Translations

When working on translation files, always follow the existing conventions of the file you are editing.

### Web (`apps/web`)

-   **Path:** `apps/web/public/locales/<language>/<namespace>.json`
-   **Languages:** `en`, `zh-Hant`, `zh-Hans`

### App (`apps/app`)

-   **Path:** `apps/app/src/assets/lang/<language>/<namespace>.json`
-   **Languages:** `en`, `zh-Hant`, `zh-Hans`

### Workflow

Typically, new text will be hardcoded in both English (`en`) and Traditional Chinese (`zh-Hant`). Your task is to move these to the appropriate `en` and `zh-Hant` translation files and also provide the Simplified Chinese (`zh-Hans`) translation. If the source text is not available in the code, ask for it or perform the translation yourself. Don't update any other translations beside the translations in scope. One json file should only contains one language, make sure not to include multiple languages in the same json file since multiple languages are usually hardcoded in component at the beginning, be sure to separate them
