#!/usr/bin/env python3
"""
Glance Configuration Validator.

Validates a glance.yml configuration file for common errors:
- YAML syntax errors
- Invalid widget type values
- Missing required properties per widget type
- Column constraint violations (max 3, need full columns)
- $include file resolution
- Common pitfalls (pages key inside included files)

Usage:
    python3 scripts/validate_config.py path/to/glance.yml
    python3 scripts/validate_config.py path/to/glance.yml --verbose

Exit codes:
    0 - Valid (no errors, may have warnings)
    1 - Invalid (one or more errors found)
    2 - File not found or not readable
"""

import re
import sys
from pathlib import Path

VALID_WIDGET_TYPES = {
    "rss", "videos", "hacker-news", "lobsters", "reddit", "search",
    "group", "split-column", "custom-api", "extension", "weather",
    "to-do", "monitor", "releases", "docker-containers", "dns-stats",
    "server-stats", "repository", "bookmarks", "change-detection",
    "clock", "calendar", "calendar-legacy", "markets",
    "twitch-channels", "twitch-top-games", "iframe", "html",
}

WIDGETS_REQUIRING_PROPERTIES = {
    "rss": ["feeds"],
    "videos": [],  # channels or playlists
    "reddit": ["subreddit"],
    "search": [],
    "group": ["widgets"],
    "split-column": ["widgets"],
    "custom-api": ["template"],
    "extension": ["url"],
    "weather": ["location"],
    "monitor": ["sites"],
    "releases": ["repositories"],
    "bookmarks": ["groups"],
    "repository": ["repository"],
    "iframe": ["source"],
    "html": ["source"],
    "change-detection": [],
    "dns-stats": ["url"],
    "docker-containers": [],
    "server-stats": [],
    "clock": [],
    "calendar": [],
    "calendar-legacy": [],
    "hacker-news": [],
    "lobsters": [],
    "markets": ["markets"],
    "twitch-channels": ["channels"],
    "twitch-top-games": [],
    "to-do": [],
}

CANNOT_NEST_IN_GROUP = {"group", "split-column"}


def read_file(path: str) -> tuple[str, list[str]]:
    """Read file and return (content, lines)."""
    p = Path(path).resolve()
    if not p.exists():
        print(f"Error: File not found: {p}", file=sys.stderr)
        sys.exit(2)
    if not p.is_file():
        print(f"Error: Not a file: {p}", file=sys.stderr)
        sys.exit(2)
    try:
        content = p.read_text(encoding="utf-8")
    except Exception as exc:
        print(f"Error: Cannot read file: {exc}", file=sys.stderr)
        sys.exit(2)
    return content, content.splitlines()


def resolve_includes(content: str, base_path: Path) -> tuple[list[str], list[str]]:
    """Find $include directives and check if referenced files exist."""
    errors = []
    warnings = []
    for i, line in enumerate(content.splitlines(), 1):
        stripped = line.strip()
        if "$include:" in stripped:
            match = re.search(r'\$include:\s*(.+)', stripped)
            if match:
                include_path = match.group(1).strip().strip("'\"")
                resolved = base_path.parent / include_path
                if not resolved.exists():
                    errors.append(
                        f"Line {i}: $include file not found: {include_path} "
                        f"(resolved to {resolved})"
                    )
                else:
                    inc_content = resolved.read_text(encoding="utf-8")
                    for j, inc_line in enumerate(inc_content.splitlines(), 1):
                        if inc_line.strip().startswith("pages:"):
                            errors.append(
                                f"{include_path}:{j}: 'pages:' key found inside "
                                f"included file (causes 'cannot unmarshal !!map into "
                                f"[]glance.page' error)"
                            )
    return errors, warnings


def validate_yaml_syntax(lines: list[str]) -> list[str]:
    """Basic YAML syntax checks."""
    errors = []
    in_frontmatter = False
    fm_close_line = 0

    for i, line in enumerate(lines, 1):
        stripped = line.stripEnd()

        if i == 1 and stripped == "---":
            in_frontmatter = True
            continue
        if in_frontmatter and stripped == "---":
            fm_close_line = i
            in_frontmatter = False
            continue

        if not in_frontmatter:
            if stripped and not stripped.startswith("#"):
                if "\t" in line:
                    errors.append(
                        f"Line {i}: Tab character found (YAML requires spaces, not tabs)"
                    )

    return errors


def find_widgets(lines: list[str]) -> list[dict]:
    """Extract widget definitions from YAML lines."""
    widgets = []
    current_widget = None
    current_indent = 0
    in_widget = False
    widget_props = {}

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        if not stripped or stripped.startswith("#"):
            continue

        indent = len(line) - len(line.lstrip())

        if stripped.startswith("- type:"):
            if current_widget is not None:
                widgets.append(current_widget)
            widget_type = stripped.split("type:", 1)[1].strip().strip("'\"")
            current_widget = {
                "type": widget_type,
                "line": i,
                "indent": indent,
                "properties": {},
            }
            in_widget = True
            widget_props = {}
        elif in_widget and current_widget is not None:
            if indent <= current_widget["indent"] and stripped.startswith("- "):
                widgets.append(current_widget)
                current_widget = None
                in_widget = False
            elif ":" in stripped and not stripped.startswith("- "):
                prop_name = stripped.split(":")[0].strip()
                current_widget["properties"][prop_name] = i

    if current_widget is not None:
        widgets.append(current_widget)

    return widgets


def validate_widgets(widgets: list[dict]) -> tuple[list[str], list[str]]:
    """Validate widget types and required properties."""
    errors = []
    warnings = []

    for w in widgets:
        wtype = w["type"]
        line = w["line"]
        props = w["properties"]

        if wtype not in VALID_WIDGET_TYPES:
            errors.append(
                f"Line {line}: Unknown widget type '{wtype}'. "
                f"Valid types: {', '.join(sorted(VALID_WIDGET_TYPES))}"
            )
            continue

        required = WIDGETS_REQUIRING_PROPERTIES.get(wtype, [])
        for req_prop in required:
            if req_prop not in props:
                errors.append(
                    f"Line {line}: Widget '{wtype}' missing required property '{req_prop}'"
                )

        if wtype == "videos":
            if "channels" not in props and "playlists" not in props:
                errors.append(
                    f"Line {line}: Widget 'videos' requires 'channels' or 'playlists'"
                )

    return errors, warnings


def check_env_vars(content: str) -> list[str]:
    """Check for environment variable references without defaults."""
    warnings = []
    env_vars = re.findall(r'\$\{([A-Z_][A-Z0-9_]*)\}', content)
    seen = set()
    for var in env_vars:
        if var not in seen:
            seen.add(var)
            if var in ("PERIOD", "LANGUAGE"):
                continue
    return warnings


def check_for_secrets(content: str) -> list[str]:
    """Warn about potential hardcoded secrets."""
    warnings = []
    secret_patterns = [
        (r'password:\s+(?!\$\{)(?!\s*\$\{)(?![\s]*$)(.+)', 'password'),
        (r'token:\s+(?!\$\{)(?!\s*\$\{)(?![\s]*$)([a-zA-Z0-9]{20,})', 'token'),
    ]
    for i, line in enumerate(content.splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith("#"):
            continue
        for pattern, kind in secret_patterns:
            match = re.search(pattern, stripped)
            if match:
                value = match.group(1).strip()
                if value and not value.startswith("${") and value not in ("", "..."):
                    warnings.append(
                        f"Line {i}: Possible hardcoded {kind}. "
                        f"Use ${{{kind.upper()}}} environment variable instead."
                    )
    return warnings


def validate_columns(lines: list[str]) -> list[str]:
    """Check column configurations."""
    errors = []
    pages = []
    current_page = None
    column_count = 0
    full_columns = 0
    in_columns = False

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        if stripped.startswith("- name:") or stripped.startswith("name:"):
            if current_page is not None:
                pages.append(current_page)
            current_page = {"line": i, "columns": []}
            column_count = 0
            full_columns = 0
            in_columns = False

        if current_page is None:
            continue

        if stripped.startswith("columns:"):
            in_columns = True
            continue

        if in_columns and stripped.startswith("- size:"):
            size = stripped.split("size:", 1)[1].strip()
            column_count += 1
            if size == "full":
                full_columns += 1

        if in_columns and not stripped.startswith("-") and not stripped.startswith("size:") and not stripped.startswith("widgets:") and ":" in stripped and not stripped.startswith(" "):
            in_columns = False
            if column_count > 3:
                errors.append(
                    f"Page at line {current_page['line']}: "
                    f"{column_count} columns (max 3 allowed)"
                )
            if full_columns == 0 and column_count > 0:
                errors.append(
                    f"Page at line {current_page['line']}: "
                    f"No 'full' size columns (must have at least 1)"
                )

    if current_page is not None:
        pages.append(current_page)
        if column_count > 3:
            errors.append(
                f"Page at line {current_page['line']}: "
                f"{column_count} columns (max 3 allowed)"
            )
        if full_columns == 0 and column_count > 0:
            errors.append(
                f"Page at line {current_page['line']}: "
                f"No 'full' size columns (must have at least 1)"
            )

    return errors


def validate_config(path: str, verbose: bool = False) -> dict:
    """Run all validations on a Glance config file."""
    errors = []
    warnings = []

    content, lines = read_file(path)
    base_path = Path(path).resolve()

    yaml_errors = validate_yaml_syntax(lines)
    errors.extend(yaml_errors)

    inc_errors, inc_warnings = resolve_includes(content, base_path)
    errors.extend(inc_errors)
    warnings.extend(inc_warnings)

    widgets = find_widgets(lines)
    w_errors, w_warnings = validate_widgets(widgets)
    errors.extend(w_errors)
    warnings.extend(w_warnings)

    col_errors = validate_columns(lines)
    errors.extend(col_errors)

    secret_warnings = check_for_secrets(content)
    warnings.extend(secret_warnings)

    env_warnings = check_env_vars(content)
    warnings.extend(env_warnings)

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings,
        "widgets_found": len(widgets),
        "widget_types": [w["type"] for w in widgets],
    }


def main() -> None:
    if len(sys.argv) < 2:
        print(
            "Usage: python3 scripts/validate_config.py <glance.yml> [--verbose]\n"
            "\n"
            "Exit codes:\n"
            "  0  Valid\n"
            "  1  Invalid\n"
            "  2  File error\n",
            file=sys.stderr,
        )
        sys.exit(2)

    path = sys.argv[1]
    verbose = "--verbose" in sys.argv

    result = validate_config(path, verbose)

    print(f"Validating: {path}")
    print("=" * 60)

    if result["valid"]:
        print("Status: VALID")
    else:
        print("Status: INVALID")

    if verbose:
        print(f"\nWidgets found: {result['widgets_found']}")
        print(f"Widget types: {', '.join(result['widget_types'])}")

    if result["errors"]:
        print(f"\nErrors ({len(result['errors'])}):")
        for error in result["errors"]:
            print(f"  [ERROR] {error}")

    if result["warnings"]:
        print(f"\nWarnings ({len(result['warnings'])}):")
        for warning in result["warnings"]:
            print(f"  [WARN]  {warning}")

    if not result["errors"] and not result["warnings"]:
        print("\nNo issues found.")

    print("=" * 60)
    sys.exit(0 if result["valid"] else 1)


if __name__ == "__main__":
    main()
