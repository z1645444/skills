# Skill Hub Context

This repository is a personal skill hub. Each skill defines how coding agents should behave when invoked.

## Repository Layout

```text
skills/<group>/<skill-name>/
  SKILL.md       # Required. Skill definition with YAML frontmatter.
  agents/        # Optional. Agent-specific prompts or configs.
  references/    # Optional. Contracts, schemas, or reference docs.
```

## Skill Naming

- Directory name equals the invocation name, e.g. `pagepack-init`.
- Group directories collect related skills, e.g. `skills/pagepack/`.

## SKILL.md Format

```yaml
---
name: skill-name
description: One-line description of what this skill does.
---

# Skill Title

## Overview
...
```

## Adding a Skill

1. Create `skills/<group>/<skill-name>/SKILL.md`.
2. Add optional `agents/` and `references/` as needed.
3. Run `scripts/install.sh` to deploy to local agent runtimes.

## Supported Agents

- Claude Code: `~/.claude/skills/`
- Codex: `~/.codex/skills/`
- Gemini CLI: `~/.gemini/extensions/`
- Antigravity: `~/.gemini/antigravity/skills/`

Claude, Codex, and Antigravity use symlinks. Gemini requires copied directories with generated adapter files.
