Just some skills.

## Install

Install all skills for Codex, Claude Code, and Gemini CLI:

```bash
scripts/install.sh
```

Install for selected runtimes:

```bash
scripts/install.sh codex
scripts/install.sh claude gemini
```

Default targets:

- Codex: `${CODEX_HOME:-$HOME/.codex}/skills`
- Claude Code: `${CLAUDE_HOME:-$HOME/.claude}/skills`
- Gemini CLI: `${GEMINI_HOME:-$HOME/.gemini}/extensions`

Target overrides:

```bash
CODEX_SKILLS_TARGET=/path/to/codex/skills scripts/install.sh codex
CLAUDE_SKILLS_TARGET=/path/to/claude/skills scripts/install.sh claude
GEMINI_EXTENSIONS_TARGET=/path/to/gemini/extensions scripts/install.sh gemini
```

For a single selected target, `SKILLS_TARGET` is also accepted as a legacy override.

## Uninstall

Uninstall all repository skills from all supported runtimes:

```bash
scripts/uninstall.sh
```

Uninstall from selected runtimes:

```bash
scripts/uninstall.sh codex
scripts/uninstall.sh claude gemini
```

## Quick Usage

```bash
scripts/install.sh
scripts/uninstall.sh
```

