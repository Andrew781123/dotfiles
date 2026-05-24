# Glance Widget Reference

Complete reference for all 28 widget types in Glance. Each widget is configured via the `type` property.

## Shared Properties (all widgets)

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `type` | string | **yes** | — | Widget type identifier |
| `title` | string | no | widget-defined | Custom title |
| `title-url` | string | no | widget-defined | URL when clicking title |
| `hide-header` | boolean | no | `false` | Hide the header/title |
| `cache` | string | no | widget-defined | Cache duration (`30s`, `5m`, `2h`, `1d`) |
| `css-class` | string | no | — | Custom CSS classes |

---

## 1. RSS (`type: rss`)

Display articles from multiple RSS/Atom feeds.

```yaml
- type: rss
  title: News
  style: horizontal-cards
  feeds:
    - url: https://feeds.bloomberg.com/markets/news.rss
      title: Bloomberg
    - url: https://example.com/rss.xml
      limit: 4
  limit: 25
  collapse-after: 5
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `style` | string | no | `vertical-list` | `vertical-list`, `detailed-list`, `horizontal-cards`, `horizontal-cards-2` |
| `feeds` | array | **yes** | — | Array of feed objects |
| `thumbnail-height` | float | no | `10` | Height in rem (`horizontal-cards` only) |
| `card-height` | float | no | `27` | Height in rem (`horizontal-cards-2` only) |
| `limit` | integer | no | `25` | Max articles |
| `preserve-order` | boolean | no | `false` | Keep feed ordering |
| `single-line-titles` | boolean | no | `false` | Truncate titles to one line |
| `collapse-after` | integer | no | `5` | Items before "SHOW MORE"; `-1` = never |

**Feed sub-properties:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `url` | string | **yes** | RSS/Atom feed URL |
| `title` | string | no | Override feed title |
| `limit` | integer | no | Max articles from this feed |
| `hide-categories` | boolean | no | Hide categories (`detailed-list` only) |
| `hide-description` | boolean | no | Hide description (`detailed-list` only) |
| `item-link-prefix` | string | no | Prefix for broken item links |
| `headers` | map | no | Custom request headers |

---

## 2. Videos (`type: videos`)

Display latest videos from YouTube channels or playlists.

```yaml
- type: videos
  channels:
    - UCXuqSBlHAE6Xw-yeJA0Tunw
  playlists:
    - PL8mG-RkN2uTyZZ00ObwZxxoG_nJbs3qec
  style: grid-cards
  collapse-after-rows: 4
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `channels` | array | no* | — | YouTube channel IDs |
| `playlists` | array | no* | — | YouTube playlist IDs |
| `limit` | integer | no | `25` | Max videos |
| `style` | string | no | `horizontal-cards` | `horizontal-cards`, `vertical-list`, `grid-cards` |
| `collapse-after` | integer | no | `7` | For `vertical-list` |
| `collapse-after-rows` | integer | no | `4` | For `grid-cards` |
| `include-shorts` | boolean | no | `false` | Include YouTube Shorts |
| `video-url-template` | string | no | youtube.com URL | Supports `{VIDEO-ID}` placeholder |

*Must provide at least `channels` or `playlists`.

---

## 3. Hacker News (`type: hacker-news`)

Display posts from news.ycombinator.com.

```yaml
- type: hacker-news
  limit: 15
  sort-by: top
  extra-sort-by: engagement
  collapse-after: 5
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `limit` | integer | no | `15` | Max posts |
| `collapse-after` | integer | no | `5` | `-1` = never |
| `sort-by` | string | no | `top` | `top`, `new`, `best` |
| `extra-sort-by` | string | no | — | `engagement` |
| `comments-url-template` | string | no | HN URL | Supports `{POST-ID}` |

---

## 4. Lobsters (`type: lobsters`)

Display posts from lobste.rs or other instances.

```yaml
- type: lobsters
  sort-by: hot
  tags:
    - go
    - security
  limit: 15
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `instance-url` | string | no | `https://lobste.rs/` | Alternate instance URL |
| `custom-url` | string | no | — | Custom URL; overrides other settings |
| `limit` | integer | no | `15` | Max posts |
| `collapse-after` | integer | no | `5` | `-1` = never |
| `sort-by` | string | no | `hot` | `hot`, `new` |
| `tags` | array | no | — | Filter by tags (forces `hot` sort) |

---

## 5. Reddit (`type: reddit`)

Display posts from a subreddit.

```yaml
- type: reddit
  subreddit: technology
  show-thumbnails: true
  sort-by: hot
  limit: 15
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subreddit` | string | **yes** | — | Target subreddit |
| `style` | string | no | `vertical-list` | `vertical-list`, `horizontal-cards`, `vertical-cards` |
| `show-thumbnails` | boolean | no | `false` | `vertical-list` only |
| `show-flairs` | boolean | no | `false` | Show post flairs |
| `limit` | integer | no | `15` | Max posts |
| `collapse-after` | integer | no | `5` | Not for card styles; `-1` = never |
| `sort-by` | string | no | `hot` | `hot`, `new`, `top`, `rising` |
| `top-period` | string | no | `day` | `hour`, `day`, `week`, `month`, `year`, `all` |
| `search` | string | no | — | Search keywords |
| `extra-sort-by` | string | no | — | `engagement` |
| `comments-url-template` | string | no | — | Supports `{POST-PATH}`, `{POST-ID}`, `{SUBREDDIT}` |
| `request-url-template` | string | no | — | Proxy URL; supports `{REQUEST-URL}` |
| `proxy` | string/object | no | — | HTTP proxy URL or `{url, allow-insecure, timeout}` |
| `app-auth` | object | no | — | `{name, id, secret}` for Reddit app auth |

**Note**: Reddit blocks VPS IPs. Use `app-auth`, `proxy`, or VPN.

---

## 6. Search (`type: search`)

Search bar with multiple engines and bang shortcuts.

```yaml
- type: search
  search-engine: duckduckgo
  autofocus: true
  bangs:
    - title: GitHub
      shortcut: gh
      url: https://github.com/search?q={QUERY}
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `search-engine` | string | no | `duckduckgo` | `duckduckgo`, `google`, `bing`, `perplexity`, `kagi`, `startpage`, or custom URL with `{QUERY}` |
| `new-tab` | boolean | no | `false` | Open in new tab |
| `autofocus` | boolean | no | `false` | Auto-focus on page load |
| `target` | string | no | `_blank` | `_blank`, `_self`, `_parent`, `_top` |
| `placeholder` | string | no | "Type here to search..." | Custom placeholder |
| `bangs` | array | no | — | Bang shortcut objects |

**Bang sub-properties**: `title` (opt), `shortcut` (req), `url` (req, uses `{QUERY}`).

**Keyboard shortcuts**: S = focus, Enter = search same tab, Ctrl+Enter = new tab, Escape = unfocus, Up = recall last query.

---

## 7. Group (`type: group`)

Group widgets into tabs. Cannot nest group or split-column inside.

```yaml
- type: group
  widgets:
    - type: hacker-news
    - type: lobsters
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `widgets` | array | **yes** | — | Any widgets except `group` and `split-column` |

---

## 8. Split Column (`type: split-column`)

Split a full column into side-by-side widgets.

```yaml
- type: split-column
  max-columns: 4
  widgets:
    - type: group
      widgets:
        - type: clock
        - type: calendar
    - type: group
      widgets:
        - type: rss
        - type: hacker-news
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `widgets` | array | **yes** | — | Any widgets (group ok, but no split-column inside group) |
| `max-columns` | integer | no | `2` | Number of columns (2, 3, 4, 5, etc.) |

---

## 9. Custom API (`type: custom-api`)

Fetch JSON from any API and render with Go templates. See `custom-api-guide.md` for full template syntax.

```yaml
- type: custom-api
  title: My Service
  cache: 5m
  url: https://api.example.com/v1/data
  options:
    view: detailed
  template: |
    <ul class="list">
      {{ range .JSON.Array "items" }}
        <li>{{ .String "name" }} - {{ .Int "count" }}</li>
      {{ end }}
    </ul>
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `url` | string | no* | — | URL to fetch JSON from |
| `template` | string | **yes** | — | Go html/template with gjson selectors |
| `headers` | map | no | — | Request headers |
| `method` | string | no | `GET` | `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `HEAD` |
| `body-type` | string | no | `json` | `json` or `string` |
| `body` | any | no | — | Request body |
| `frameless` | boolean | no | `false` | Remove border and padding |
| `allow-insecure` | boolean | no | `false` | Ignore invalid certs |
| `skip-json-validation` | boolean | no | `false` | For JSON Lines/NDJSON |
| `options` | map | no | — | Key-value options via `.Options.*` |
| `parameters` | map | no | — | Query parameters |
| `subrequests` | map | no | — | Concurrent additional requests via `.Subrequest "key"` |

---

## 10. Extension (`type: extension`)

Display a widget from an external/3rd party source.

```yaml
- type: extension
  url: https://example.com/widget.html
  parameters:
    theme: dark
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `url` | string | **yes** | — | Extension URL |
| `fallback-content-type` | string | no | — | Currently only `html` |
| `allow-potentially-dangerous-html` | boolean | no | `false` | **Security risk** — trusted extensions only |
| `headers` | map | no | — | Request headers |
| `parameters` | map | no | — | Query parameters |

---

## 11. Weather (`type: weather`)

Weather from open-meteo.com. Updates hourly (cache cannot be changed).

```yaml
- type: weather
  location: London, United Kingdom
  units: metric
  hour-format: 12h
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `location` | string | **yes** | — | "City, Country" format |
| `units` | string | no | `metric` | `metric` (C) or `imperial` (F) |
| `hour-format` | string | no | `12h` | `12h` or `24h` |
| `hide-location` | boolean | no | `false` | Hide location name |
| `show-area-name` | boolean | no | `false` | Show state/admin area |

---

## 12. To-Do (`type: to-do`)

Simple to-do list in browser local storage.

```yaml
- type: to-do
  id: my-tasks
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `id` | string | no | — | Unique ID for separate lists; same ID = shared tasks |

**Keyboard**: Enter = add bottom, Ctrl+Enter = add top, Down = focus last task, Escape = focus input.

---

## 13. Monitor (`type: monitor`)

Site reachability via GET requests. 200 = online, else error.

```yaml
- type: monitor
  style: compact
  show-failing-only: false
  sites:
    - title: My Site
      url: https://example.com
      icon: si:nginx
    - title: API
      url: https://api.example.com/health
      check-url: https://api.example.com/internal/ping
      alt-status-codes: [201, 204]
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sites` | array | **yes** | — | Array of site objects |
| `style` | string | no | — | `compact` |
| `show-failing-only` | boolean | no | `false` | Only show failing |

**Site sub-properties**: `title` (req), `url` (req), `check-url` (opt), `error-url` (opt), `icon` (opt), `timeout` (opt, `3s`), `allow-insecure` (opt), `same-tab` (opt), `alt-status-codes` (opt array), `basic-auth` (opt: `username` + `password`).

---

## 14. Releases (`type: releases`)

Latest releases from GitHub, GitLab, Codeberg, or Docker Hub.

```yaml
- type: releases
  token: ${GITHUB_TOKEN}
  show-source-icon: true
  repositories:
    - glanceapp/glance
    - gitlab:go-gitea/gitea
    - codeberg:codeberg/codeberg
    - dockerhub:nginx
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `repositories` | array | **yes** | — | `owner/repo`, `gitlab:owner/repo`, `codeberg:owner/repo`, `dockerhub:owner/repo`, `dockerhub:nginx` (official), `dockerhub:nginx:tag` |
| `show-source-icon` | boolean | no | `false` | Show platform icon |
| `token` | string | no | — | GitHub read-only token |
| `gitlab-token` | string | no | — | GitLab token |
| `limit` | integer | no | `10` | Max releases |
| `collapse-after` | integer | no | `5` | `-1` = never |

Object form supports `include-prereleases` (GitHub only).

---

## 15. Docker Containers (`type: docker-containers`)

Status of Docker containers. Requires `docker.sock` access.

```yaml
- type: docker-containers
  format-container-names: true
  running-only: false
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `hide-by-default` | boolean | no | `false` | If true, must set `glance.hide: false` label |
| `format-container-names` | boolean | no | `false` | Auto-format names |
| `sock-path` | string | no | `/var/run/docker.sock` | Docker socket path |
| `category` | string | no | — | Filter by `glance.category` label |
| `running-only` | boolean | no | `false` | Only running containers |
| `containers` | map | no | — | YAML-defined container config |

**Docker labels**: `glance.name`, `glance.icon`, `glance.url`, `glance.same-tab`, `glance.description`, `glance.hide`, `glance.id`, `glance.parent`, `glance.category`.

Parent/child grouping: set `glance.id` on parent, `glance.parent` on children.

---

## 16. DNS Stats (`type: dns-stats`)

Stats from AdGuard Home, Pi-hole, or Technitium.

```yaml
- type: dns-stats
  service: pihole-v6
  url: http://192.168.1.100
  token: ${PIHOLE_TOKEN}
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `service` | string | no | `pihole` | `adguard`, `technitium`, `pihole`, `pihole-v6` |
| `url` | string | **yes** | — | Base URL |
| `username` | string | cond. | — | Required for AdGuard |
| `password` | string | cond. | — | Required for AdGuard, Pi-hole v6+ |
| `token` | string | cond. | — | Required for Pi-hole v5, Technitium |
| `allow-insecure` | boolean | no | `false` | Ignore invalid certs |
| `hide-graph` | boolean | no | `false` | Hide queries graph |
| `hide-top-domains` | boolean | no | `false` | Hide top blocked domains |
| `hour-format` | string | no | `12h` | `12h` or `24h` |

---

## 17. Server Stats (`type: server-stats`)

CPU, memory, disk of local or remote servers. Remote requires Glance Agent.

```yaml
- type: server-stats
  servers:
    - type: local
      name: My Server
    - type: remote
      name: Remote Box
      url: http://192.168.1.50:8080
      token: ${AGENT_TOKEN}
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `servers` | array | no | — | If omitted, shows local stats |

**Server sub-properties**: `type` (req: `local`/`remote`), `name` (opt), `hide-swap` (opt), `cpu-temp-sensor` (opt, local), `hide-mountpoints-by-default` (opt, local), `mountpoints` (opt, local: path → `{name, hide}`), `url` (req, remote), `token` (opt, remote), `timeout` (opt, `3s`, remote).

CPU temp >80C triggers flame icon and red indicators.

---

## 18. Repository (`type: repository`)

GitHub repo info + PRs, issues, commits.

```yaml
- type: repository
  repository: glanceapp/glance
  token: ${GITHUB_TOKEN}
  pull-requests-limit: 3
  issues-limit: 3
  commits-limit: 5
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `repository` | string | **yes** | — | `owner/repo` |
| `token` | string | no | — | GitHub read-only token |
| `pull-requests-limit` | integer | no | `3` | `-1` = hide |
| `issues-limit` | integer | no | `3` | `-1` = hide |
| `commits-limit` | integer | no | `-1` | `-1` = hide (hidden by default) |

---

## 19. Bookmarks (`type: bookmarks`)

Grouped links with icons and colors.

```yaml
- type: bookmarks
  groups:
    - title: Dev Tools
      color: 200 50 50
      links:
        - title: GitHub
          url: https://github.com
          icon: si:github
          description: Code hosting
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `groups` | array | **yes** | — | Array of group objects |

**Group sub-properties**: `title` (opt), `color` (opt, HSL), `links` (req), `same-tab` (opt), `hide-arrow` (opt), `target` (opt).

**Link sub-properties**: `title` (req), `url` (req), `description` (opt), `icon` (opt), `same-tab` (opt), `hide-arrow` (opt), `target` (opt).

---

## 20. ChangeDetection.io (`type: change-detection`)

Watches from a changedetection.io instance.

```yaml
- type: change-detection
  instance-url: https://changedetection.example.com
  token: ${CHANGEDETECTION_TOKEN}
  limit: 10
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `instance-url` | string | no | `https://www.changedetection.io` | Your instance |
| `token` | string | no | — | API access token |
| `limit` | integer | no | `10` | Max watches |
| `collapse-after` | integer | no | `5` | `-1` = never |
| `watches` | array | no | — | Specific watch UUIDs |

---

## 21. Clock (`type: clock`)

Current time with optional timezones.

```yaml
- type: clock
  hour-format: 24h
  timezones:
    - timezone: Europe/London
      label: London
    - timezone: Asia/Hong_Kong
      label: HK
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `hour-format` | string | no | `24h` | `12h` or `24h` |
| `timezones` | array | no | — | Timezone objects |

**Timezone sub-properties**: `timezone` (req, tz identifier), `label` (opt, display name).

---

## 22. Calendar (`type: calendar`)

Calendar widget.

```yaml
- type: calendar
  first-day-of-week: monday
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `first-day-of-week` | string | no | `monday` | Any weekday name |

---

## 23. Calendar Legacy (`type: calendar-legacy`)

Deprecated calendar. May be removed in future.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `start-sunday` | boolean | no | `false` | Weeks start on Sunday |

---

## 24. Markets (`type: markets`)

Stock/crypto from Yahoo Finance with 21-day mini chart.

```yaml
- type: markets
  sort-by: change
  markets:
    - symbol: SPY
      name: S&P 500
    - symbol: BTC-USD
      name: Bitcoin
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `markets` | array | **yes** | — | Market objects |
| `sort-by` | string | no | defined order | `change` or `absolute-change` |
| `chart-link-template` | string | no | — | `{SYMBOL}` placeholder |
| `symbol-link-template` | string | no | — | `{SYMBOL}` placeholder |

**Market sub-properties**: `symbol` (req), `name` (opt), `symbol-link` (opt), `chart-link` (opt).

---

## 25. Twitch Channels (`type: twitch-channels`)

Twitch channel live status and viewer counts.

```yaml
- type: twitch-channels
  channels:
    - theprimeagen
    - cohhcarnage
  sort-by: viewers
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `channels` | array | **yes** | — | Channel names |
| `collapse-after` | integer | no | `5` | `-1` = never |
| `sort-by` | string | no | `viewers` | `viewers` or `live` |

---

## 26. Twitch Top Games (`type: twitch-top-games`)

Games with most viewers on Twitch.

```yaml
- type: twitch-top-games
  exclude:
    - just-chatting
  limit: 10
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `exclude` | array | no | — | Category slugs to exclude |
| `limit` | integer | no | `10` | Max games |
| `collapse-after` | integer | no | `5` | `-1` = never |

---

## 27. iframe (`type: iframe`)

Embed an iframe.

```yaml
- type: iframe
  source: https://grafana.example.com/d-solo/abc
  height: 400
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `source` | string | **yes** | — | iframe source URL |
| `height` | integer | no | `300` | Height in pixels (min 50) |

---

## 28. HTML (`type: html`)

Raw HTML embed.

```yaml
- type: html
  source: |
    <div style="text-align: center;">
      <h2>Custom Content</h2>
      <p>Any HTML here</p>
    </div>
```

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `source` | string | **yes** | — | Raw HTML content |
