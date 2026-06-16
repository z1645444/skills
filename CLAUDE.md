# CLAUDE.md

This repository is a personal skill hub. It contains skill definitions consumed by Claude Code, Codex, Gemini CLI, and Antigravity.

## Working with Skills

- Skill definitions live under `skills/<group>/<skill-name>/`.
- Every skill must have a `SKILL.md` with YAML frontmatter containing `name` and `description`.
- Optional directories: `agents/` for agent-specific config, `references/` for contracts or schemas.
- Read `CONTEXT.md` for repository conventions before adding or modifying skills.

## After Changing Skills

Run the install script to deploy changes to local agent runtimes:

```bash
scripts/install.sh
```

To remove installed skills:

```bash
scripts/uninstall.sh
```

## Adding a New Skill

1. Pick or create a group directory under `skills/`.
2. Create `skills/<group>/<skill-name>/SKILL.md`.
3. Add `agents/` and `references/` if needed.
4. Update `README.md` if the skill is meant for general use.
5. Run `scripts/install.sh`.

## What Not to Do

- Do not put implementation code or distribute binaries in this repository.
- Do not rename existing ariadne skills; their names match agent invocation commands.
- Do not commit secrets, credentials, or generated agent adapter files.
