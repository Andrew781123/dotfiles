# glance-config-skill

Expert assistant for configuring [Glance](https://github.com/glanceapp/glance) self-hosted dashboards. Generates, validates, and modifies `glance.yml` configurations.

## Features

- All 28 built-in widget types with full property reference
- Go template custom-api widget guide with patterns and examples
- Community widget catalog (100+ widgets indexed by category)
- Config validation (YAML syntax, widget types, column constraints, $includes)
- 14 preset themes (Catppuccin, Gruvbox, Dracula, etc.)
- Starter template for new dashboards

## Install

### Universal (recommended)

```bash
git clone https://github.com/YOUR_USERNAME/glance-config-skill.git ~/.agents/skills/glance-config-skill
```

### Claude Code

```bash
git clone https://github.com/YOUR_USERNAME/glance-config-skill.git ~/.claude/skills/glance-config-skill
```

### GitHub Copilot (project-level)

```bash
git clone https://github.com/YOUR_USERNAME/glance-config-skill.git .github/skills/glance-config-skill
```

### Cursor

```bash
git clone https://github.com/YOUR_USERNAME/glance-config-skill.git .cursor/rules/glance-config-skill
```

### OpenCode

```bash
git clone https://github.com/YOUR_USERNAME/glance-config-skill.git ~/.config/opencode/skills/glance-config-skill
```

### Using install.sh

```bash
./install.sh                          # Auto-detect platform
./install.sh --platform opencode      # Target OpenCode
./install.sh --project                # Project-level install
./install.sh --all                    # Install to all detected platforms
```

## Use

Open a new session and type:

```
/glance-config-skill Add a homelab page with Docker containers and server stats
```

## Validate Config

```bash
python3 scripts/validate_config.py path/to/glance.yml
```
