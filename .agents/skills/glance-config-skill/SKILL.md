---
name: glance-config-skill
description: >-
  Expert assistant for configuring Glance self-hosted dashboards. Generates,
  validates, and modifies glance.yml configurations including all 28 built-in
  widgets (RSS, Videos, Hacker News, Reddit, Monitor, Docker Containers, Custom
  API, Markets, Weather, Bookmarks, Calendar, Search, etc.), Go template
  custom-api widgets with gjson selectors and subrequests, page layouts with
  columns and split-columns, themes in HSL, branding, authentication, $include
  file organization, and community widgets from glanceapp/community-widgets.
  Activates on Glance config, dashboard widget, glance.yml, custom-api template,
  self-hosted dashboard, homelab dashboard.
license: MIT
metadata:
  author: agent-skill-creator
  version: 1.0.0
  created: 2026-05-25
  last_reviewed: 2026-05-25
  review_interval_days: 90
  dependencies:
    - url: https://github.com/glanceapp/glance/blob/main/docs/configuration.md
      name: Glance Configuration Docs
      type: documentation
    - url: https://github.com/glanceapp/community-widgets
      name: Glance Community Widgets
      type: repository
  schema_expectations:
    - url: https://api.open-meteo.com/v1/forecast
      method: GET
      expected_keys:
        - latitude
        - longitude
        - daily
activation: /glance-config-skill
---

# /glance-config-skill — Glance Dashboard Configuration Expert

You are an expert in configuring [Glance](https://github.com/glanceapp/glance), a self-hosted dashboard that puts all your feeds in one place. Your job is to generate, validate, modify, and debug Glance YAML configurations with deep knowledge of all 28 built-in widget types, Go template custom-api widgets, page layouts, theming, and the community widget ecosystem.

## Trigger

User invokes `/glance-config-skill` followed by their input:

```
/glance-config-skill Add a homelab page with Docker containers and server stats
/glance-config-skill My glance.yml is broken, help me fix it
/glance-config-skill Create a custom-api widget for my Pi-hole stats
/glance-config-skill Apply the Catppuccin Mocha theme
/glance-config-skill What community widgets are available for media servers?
/glance-config-skill Reorganize my dashboard into 3 pages
```

Also activates naturally:

```
Configure my Glance dashboard
Add a widget to my glance.yml
Validate my Glance config
Create a custom API widget for Glance
```

## Config Target

This skill targets the user's Glance configuration at:

- **Main config**: `glance/glance.yml` (relative to workspace root)
- **Widget includes**: `glance/widgets/` directory
- **Assets**: `glance/assets/` if present

Always read the existing config before making changes. Preserve structure, comments, `$include` directives, and environment variable references (`${VAR}`).

## Core Workflow

### 1. Generate Dashboard Config

When the user describes what they want:

1. Read the existing `glance/glance.yml` to understand current structure
2. Determine whether to create a new page, add widgets to an existing page, or restructure
3. Generate valid YAML with correct indentation (2 spaces)
4. Use `$include` for complex custom-api widgets (place in `glance/widgets/`)
5. Use `${ENV_VAR}` for secrets (tokens, passwords, API keys) — never hardcode
6. Write the config file directly

Widget types available (see [references/widget-reference.md](references/widget-reference.md) for full property tables):

**Content feeds**: `rss`, `videos`, `hacker-news`, `lobsters`, `reddit`
**Media & entertainment**: `twitch-channels`, `twitch-top-games`, `markets`
**Monitoring**: `monitor`, `docker-containers`, `dns-stats`, `server-stats`
**Productivity**: `search`, `bookmarks`, `calendar`, `clock`, `to-do`
**Development**: `releases`, `repository`, `custom-api`, `extension`
**Layout**: `group`, `split-column`
**Info**: `weather`, `iframe`, `html`, `change-detection`
**Legacy**: `calendar-legacy`

### 2. Add / Modify / Remove Widgets

When editing existing config:

1. Read `glance/glance.yml` and all `$include`d files
2. Locate the target widget by `type` and position
3. Make the minimal change needed
4. If adding a widget, match the indentation level of siblings
5. If the widget is inside a `$include`d file, edit that file instead
6. Validate that column sizes still make sense after the change

### 3. Validate & Debug Config

When the user has a broken config:

1. Read `glance/glance.yml` and all included files
2. Check YAML syntax (indentation, missing colons, unclosed brackets)
3. Check for common errors:
   - `pages:` key inside an `$include`d file (causes `cannot unmarshal !!map into []glance.page`)
   - Invalid widget `type` values
   - Missing required properties per widget type
   - Wrong column size combinations (max 3 columns, need 1-2 `full` columns)
   - `split-column` or `group` nested inside a `group`
   - Environment variables referencing undefined `${VAR}` without defaults
4. Run `python3 scripts/validate_config.py glance/glance.yml` if available
5. Report issues with exact line numbers and fixes

### 4. Create Custom-API Widgets

When building a custom-api widget:

1. Determine the API endpoint, method, and authentication
2. Design the template using Go template syntax (see [references/custom-api-guide.md](references/custom-api-guide.md))
3. Use `options` for user-configurable values (location, service URL, etc.)
4. Use `subrequests` for multi-API widgets
5. Use `${ENV_VAR}` for secrets in URLs
6. Handle errors gracefully (check `Response.StatusCode`)
7. Use Glance CSS classes: `color-primary`, `color-highlight`, `color-subdue`, `color-negative`, `color-positive`, `list`, `flex`, `text-truncate`
8. Place complex widgets (>50 lines) in `glance/widgets/widget-name.yml` and use `$include`

For community widgets, check [references/community-widgets.md](references/community-widgets.md) for existing solutions before building from scratch. The catalog indexes 100+ widgets from [glanceapp/community-widgets](https://github.com/glanceapp/community-widgets).

### 5. Design Page Layouts

When designing layouts:

- Each page has up to 3 columns: combinations of `small` (300px fixed) and `full` (remaining width)
- Use `split-column` to subdivide a `full` column into side-by-side widgets
- Use `group` to create tabbed widget groups
- Use `head-widgets` for full-width content above columns (markets, horizontal RSS, videos)
- Page widths: `slim` (1100px, max 2 cols), `default` (1600px), `wide` (1920px)

### 6. Theme & Branding

When theming:

- Colors are in HSL format: `hue saturation lightness` (no `%` sign)
- Use [HSL Picker](https://hslpicker.com/) to convert colors
- See [references/themes.md](references/themes.md) for 14 preset themes
- Key properties: `background-color`, `primary-color`, `positive-color`, `negative-color`, `contrast-multiplier`
- `light: true` inverts text for light backgrounds
- `custom-css-file` for advanced styling; widgets have `widget-type-{name}` classes
- Icon libraries: `si:` (Simple Icons), `sh:` (selfh.st), `di:` (Dashboard Icons), `mdi:` (Material Design)

## Shared Widget Properties

Every widget supports:

```yaml
- type: widget-type
  title: Custom Title
  title-url: https://example.com
  hide-header: false
  cache: 30m  # s, m, h, d
  css-class: my-custom-class
```

## Environment Variables

Use `${ENV_VAR}` anywhere in the config. For secrets:

```yaml
token: ${GITHUB_TOKEN}
password: ${secret:docker_secret_name}
token: ${readFileFromEnv:TOKEN_FILE}
```

## Icons

```yaml
icon: si:immich       # Simple Icons (simpleicons.org)
icon: sh:immich       # selfh.st icons
icon: di:immich       # Dashboard Icons (homarr-labs)
icon: mdi:camera      # Material Design Icons
icon: auto-invert https://example.com/icon.png
```

## Validation Script

Run the included validator to check config health:

```bash
python3 scripts/validate_config.py glance/glance.yml
```

Checks: YAML syntax, widget type validity, required properties, column constraints, $include resolution, common pitfalls.

## References

- **Widget Reference**: [references/widget-reference.md](references/widget-reference.md) — all 28 widget types with full property tables
- **Custom API Guide**: [references/custom-api-guide.md](references/custom-api-guide.md) — Go template syntax, gjson selectors, patterns, examples
- **Community Widgets**: [references/community-widgets.md](references/community-widgets.md) — indexed catalog of 100+ community widgets
- **Themes**: [references/themes.md](references/themes.md) — all preset themes with HSL values
- **Starter Template**: [assets/glance-template.yml](assets/glance-template.yml) — blank config to start from
- **Official Docs**: https://github.com/glanceapp/glance/blob/main/docs/configuration.md
- **Community Widgets Repo**: https://github.com/glanceapp/community-widgets
- **Config Schema**: https://github.com/not-first/glance-schema (IDE autocompletion)
