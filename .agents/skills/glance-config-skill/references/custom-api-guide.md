# Custom API Widget Guide

Complete guide to building `custom-api` widgets with Go templates and gjson selectors.

## Overview

The `custom-api` widget fetches JSON from any URL and renders it using Go's `html/template` with gjson selectors for JSON access.

```yaml
- type: custom-api
  title: My Widget
  url: https://api.example.com/data
  cache: 5m
  template: |
    <ul class="list">
      {{ range .JSON.Array "items" }}
        <li>{{ .String "name" }}</li>
      {{ end }}
    </ul>
```

## Widget Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `url` | string | no* | — | URL to fetch JSON from |
| `template` | string | **yes** | — | Go html/template with gjson selectors |
| `headers` | map | no | — | Request headers |
| `method` | string | no | `GET` | HTTP method |
| `body-type` | string | no | `json` | `json` or `string` |
| `body` | any | no | — | Request body |
| `frameless` | boolean | no | `false` | Remove border/padding |
| `allow-insecure` | boolean | no | `false` | Ignore SSL errors |
| `skip-json-validation` | boolean | no | `false` | For NDJSON/JSON Lines |
| `options` | map | no | — | User-configurable values |
| `parameters` | map | no | — | Query parameters |
| `subrequests` | map | no | — | Concurrent additional requests |

## Template Data Access

### JSON Access (`.JSON.*`)

The response JSON is accessed via gjson selectors on `.JSON`:

```go
{{ .JSON.String "key" }}           // string value
{{ .JSON.Int "key" }}              // integer value
{{ .JSON.Float "key" }}            // float value
{{ .JSON.Bool "key" }}             // boolean value
{{ .JSON.Array "items" }}          // array (iterate with range)
{{ .JSON.String "nested.key" }}    // nested via dot notation
{{ .JSON.String "items.0.name" }}  // array index access
```

### Array Iteration

```go
{{ range .JSON.Array "items" }}
  {{ .String "name" }}
  {{ .Int "count" }}
{{ end }}
```

Within a `range`, use `.String`, `.Int`, `.Float`, `.Bool` without `.JSON` prefix.

### Options Access (`.Options.*`)

User-configurable values from the `options` map:

```go
{{ .Options.StringOr "view" "default" }}    // string with default
{{ .Options.IntOr "limit" 10 }}             // int with default
{{ .Options.FloatOr "threshold" 0.5 }}      // float with default
{{ .Options.BoolOr "detailed" false }}      // bool with default
```

### Subrequests (`.Subrequest`)

Concurrent additional requests. Each key maps to a request config:

```yaml
subrequests:
  transfer:
    url: http://service/api/transfer
  torrents:
    url: http://service/api/torrents
    parameters:
      filter: downloading
```

Access in template:

```go
{{ $transfer := .Subrequest "transfer" }}
{{ $torrents := .Subrequest "torrents" }}

{{ $transfer.JSON.Float "speed" }}
{{ $transfer.Response.StatusCode }}

{{ range $torrents.JSON.Array "" }}
  {{ .String "name" }}
{{ end }}
```

### In-Template Requests (`newRequest`)

Make additional API calls from within the template:

```go
{{ $req := newRequest "https://api.example.com/data" }}
{{ $req = $req | withHeader "Accept" "application/json" }}
{{ $req = $req | withHeader "Authorization" (printf "Bearer %s" $token) }}
{{ $data := $req | getResponse }}

{{ $data.JSON.String "result" }}
{{ $data.Response.StatusCode }}
```

### Response Status

```go
{{ .Response.StatusCode }}
{{ if eq .Response.StatusCode 200 }}
  OK
{{ else }}
  Error
{{ end }}
```

## Template Functions

### String Functions

```go
{{ printf "%.1f MB/s" $speed }}      // formatted print
{{ replaceAll "old" "new" $str }}    // string replace
{{ trimSuffix "day" $str }}          // trim suffix
{{ toInt $float }}                    // convert to int
{{ len $array }}                      // array length
{{ div $a $b }}                       // division
{{ mul $a $b }}                       // multiplication
{{ add $a $b }}                       // addition
{{ sub $a $b }}                       // subtraction
{{ mod $a $b }}                       // modulo
```

### Time Functions

```go
{{ now }}                                    // current time
{{ now | formatTime "2006-01-02" }}          // format time (Go layout)
{{ $t := parseTime "RFC3339" $dateStr }}     // parse time string
{{ $t := parseLocalTime "RFC3339" $str }}    // parse in local timezone
{{ $t.In now.Location }}                     // convert to local timezone
{{ $t.Format "1/2 03:04PM" }}                // format display
{{ offsetNow "+24h" }}                       // relative time
```

Go time layout reference: `2006-01-02 15:04:05` = Year-Month-Day Hour:Min:Sec.

### Sorting

```go
{{ range $data.JSON.Array "records" | sortByTime "date" "rfc3339" "desc" }}
  {{ .String "name" }}
{{ end }}
```

### Safe CSS

```go
{{ $color | safeCSS }}   // mark string as safe CSS value
```

## CSS Classes

Glance provides utility classes for styling:

### Colors
- `color-primary` / `color-primary-if-not-visited` — primary theme color
- `color-highlight` / `color-text-highlight` — emphasized text
- `color-subdue` / `color-text-subdue` — dimmed text
- `color-positive` / `color-negative` — green/red indicators
- `color-paragraph` — normal text color

### Layout
- `flex` — flexbox container
- `justify-between` — space-between
- `items-center` / `items-start` — alignment
- `gap-10` — gap (10px)
- `shrink` / `min-width-0` — flex shrinking

### Typography
- `size-h3` / `size-h4` / `size-h5` / `size-h6` — heading sizes
- `size-sm` — small text
- `text-truncate` — single line truncate
- `text-truncate-2-lines` — two line truncate
- `text-very-compact` — reduced line height
- `block` — display block

### Lists
- `list` — styled list
- `list-gap-10` / `list-gap-14` — list gap
- `list-horizontal-text` — inline list items

### Interactive
- `collapsible-container` — enables collapse behavior
- `data-collapse-after="5"` — items before "SHOW MORE"

### Special
- `widget-type-{name}` — widget type class for CSS targeting
- `attachments` — tag/badge styling
- `bookmarks-link` — bookmark link styling
- `thumbnail` / `thumbnail-container` / `thumbnail-parent` — image thumbnails

### CSS Variables
- `--color-positive` — green
- `--color-negative` — red
- `--color-primary` — primary color
- `--color-text-highlight` — highlight text
- `--color-text-subdue` — dimmed text
- `--color-paragraph` — normal text
- `--color-separator` — separator lines
- `--bghs` / `--bgl` — background HSL components

## Common Patterns

### Error Handling

```go
{{ if eq .Response.StatusCode 200 }}
  {{ range .JSON.Array "data" }}
    {{ .String "name" }}
  {{ end }}
{{ else }}
  <div class="color-negative text-center">
    <p>Error fetching data.</p>
    <p class="size-sm">Check URL and authentication settings.</p>
  </div>
{{ end }}
```

### Conditional Display

```go
{{ $isDetailed := eq (.Options.StringOr "view" "basic") "detailed" }}
{{ if $isDetailed }}
  <div>Detailed view</div>
{{ else }}
  <div>Basic view</div>
{{ end }}
```

### Progress Bars

```go
<div style="background: rgba(128, 128, 128, 0.2); border-radius: 5px; height: 6px; overflow: hidden;">
  <div style="width: {{ mul (.Float "progress") 100 }}%; background-color: var(--color-positive); height: 100%; border-radius: 5px;"></div>
</div>
```

### Collapsible Lists

```go
<ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
  {{ range .JSON.Array "items" }}
    <li>{{ .String "name" }}</li>
  {{ end }}
</ul>
```

### Size Formatting

```go
{{ $bytes := .Float "size" }}
{{ if lt $bytes 1048576.0 }}
  {{ printf "%.0f KiB" (div $bytes 1024.0) }}
{{ else }}
  {{ printf "%.1f MiB" (div $bytes 1048576.0) }}
{{ end }}
```

### Speed Formatting

```go
{{ $speed := .Float "speed" }}
{{ if lt $speed 1000.0 }}
  --
{{ else if lt $speed 1048576.0 }}
  {{ printf "%.0f KiB/s" (div $speed 1024.0) }}
{{ else }}
  {{ printf "%.1f MiB/s" (div $speed 1048576.0) }}
{{ end }}
```

### Popover Tooltips

```go
<div data-popover-type="html" data-popover-position="above" data-popover-show-delay="500">
  <div data-popover-html>
    <strong>{{ $title }}</strong>
    <p>{{ $description }}</p>
  </div>
  <img src="{{ $imageUrl }}" style="width: 100%; height: 100%; object-fit: cover;">
</div>
```

## Best Practices

1. **Always handle errors** — check `Response.StatusCode` before accessing JSON
2. **Use `options` for configurability** — service URLs, view modes, thresholds
3. **Use `${ENV_VAR}` for secrets** — never hardcode tokens or passwords
4. **Use `subrequests` for multi-API calls** — they run concurrently
5. **Cache appropriately** — `10s` for live data, `1h` for infrequent updates, `24h` for daily
6. **Use `frameless: true`** for full-width widgets that need no border
7. **Place complex widgets in separate files** — use `$include: widgets/my-widget.yml`
8. **Use `auto-invert` prefix for icons** on dark themes: `icon: auto-invert https://...`
