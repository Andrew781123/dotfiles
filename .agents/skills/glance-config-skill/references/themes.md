# Glance Themes Reference

All preset themes from the official Glance docs. Colors are in HSL format (`hue saturation lightness`, no `%`).

Source: https://github.com/glanceapp/glance/blob/main/docs/themes.md

## Using a Theme

```yaml
theme:
  background-color: 240 21 15
  primary-color: 217 92 83
  contrast-multiplier: 1.2
```

Or define presets users can switch between:

```yaml
theme:
  background-color: 240 8 9
  primary-color: 43 50 70
  presets:
    my-dark:
      background-color: 240 21 15
      primary-color: 217 92 83
    my-light:
      light: true
      background-color: 220 23 95
      primary-color: 220 91 54
```

## Theme Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `light` | boolean | `false` | Light mode (inverts text) |
| `background-color` | HSL | `240 8 9` | Page/widget background |
| `primary-color` | HSL | `43 50 70` | Links, accent |
| `positive-color` | HSL | same as primary | Green/positive indicators |
| `negative-color` | HSL | `0 70 70` | Red/negative indicators |
| `contrast-multiplier` | number | `1` | Text contrast (>1 = lighter/darker) |
| `text-saturation-multiplier` | number | `1` | Text saturation |
| `custom-css-file` | string | — | Path to custom CSS |
| `disable-picker` | boolean | `false` | Hide theme picker |
| `presets` | object | — | Additional theme presets |

## Dark Themes

### Teal City
```yaml
theme:
  background-color: 225 14 15
  primary-color: 157 47 65
  contrast-multiplier: 1.1
```

### Catppuccin Frappe
```yaml
theme:
  background-color: 229 19 23
  contrast-multiplier: 1.2
  primary-color: 222 74 74
  positive-color: 96 44 68
  negative-color: 359 68 71
```

### Catppuccin Macchiato
```yaml
theme:
  background-color: 232 23 18
  contrast-multiplier: 1.2
  primary-color: 220 83 75
  positive-color: 105 48 72
  negative-color: 351 74 73
```

### Catppuccin Mocha
```yaml
theme:
  background-color: 240 21 15
  contrast-multiplier: 1.2
  primary-color: 217 92 83
  positive-color: 115 54 76
  negative-color: 347 70 65
```

### Camouflage
```yaml
theme:
  background-color: 186 21 20
  contrast-multiplier: 1.2
  primary-color: 97 13 80
```

### Gruvbox Dark
```yaml
theme:
  background-color: 0 0 16
  primary-color: 43 59 81
  positive-color: 61 66 44
  negative-color: 6 96 59
```

### Kanagawa Dark
```yaml
theme:
  background-color: 240 13 14
  primary-color: 51 33 68
  negative-color: 358 100 68
  contrast-multiplier: 1.2
```

### Tucan
```yaml
theme:
  background-color: 50 1 6
  primary-color: 24 97 58
  negative-color: 209 88 54
```

### Dracula
```yaml
theme:
  background-color: 231 15 21
  primary-color: 265 89 79
  contrast-multiplier: 1.2
  positive-color: 135 94 66
  negative-color: 0 100 67
```

### Shades of Purple
```yaml
theme:
  background-color: 243 33 25
  contrast-multiplier: 1.2
  primary-color: 50 100 49
  positive-color: 98 82 71
  negative-color: 12 77 52
```

### Neon Pink
```yaml
theme:
  background-color: 240 27 11
  contrast-multiplier: 1.5
  primary-color: 321 100 71
  positive-color: 165 78 51
  negative-color: 360 100 71
```

## Light Themes

### Catppuccin Latte
```yaml
theme:
  light: true
  background-color: 220 23 95
  contrast-multiplier: 1.0
  primary-color: 220 91 54
  positive-color: 109 58 40
  negative-color: 347 87 44
```

### Peachy
```yaml
theme:
  light: true
  background-color: 28 40 77
  primary-color: 155 100 20
  negative-color: 0 100 60
  contrast-multiplier: 1.1
  text-saturation-multiplier: 0.5
```

### Zebra
```yaml
theme:
  light: true
  background-color: 0 0 95
  primary-color: 0 0 10
  negative-color: 0 90 50
```

## HSL Color Picker

Use [HSL Picker](https://hslpicker.com/) to convert hex/RGB colors to HSL format.

Format: `hue saturation lightness` — numbers only, no `%` sign.
Example: Pure blue = `240 100 50`, warm orange = `25 100 50`.

## Custom CSS

For advanced styling, create a CSS file in your assets path and reference it:

```yaml
theme:
  custom-css-file: /assets/my-style.css
```

Target specific widgets using `.widget-type-{name}` class:

```css
.widget-type-rss a {
    font-size: 1.5rem;
}
```

Each widget also supports `css-class` for instance-specific styling:

```yaml
- type: rss
  css-class: my-custom-rss
```

```css
.my-custom-rss {
    border: 1px solid red;
}
```
