---
name: ariadne-suggest-adapters
description: Generate reviewable Ariadne Adapter Suggestions for agent entry files such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/*.md`, or `.cursorrules`. Use when an agent entry file is missing, weak, does not point to `.codebase/router.md`, lacks Task Router instructions, or duplicates Runtime Docs, and a non-mutating patch suggestion is needed before `ariadne-apply-suggestion`.
---

# Ariadne Suggest Adapters

## Overview

Use this skill to propose thin Agent Adapter patches. It writes adapter suggestion JSON/MD under `.codebase/meta/suggestions/`, but must not directly modify `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, Cursor rules, or any agent entry file.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, agent names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before creating an adapter suggestion, read `references/adapter-suggestion-contracts.md`. It defines supported agents, fixed Adapter Boot Instruction, patch rules, scope handling, and suggestion output requirements.

## Workflow

1. Resolve Agent Scope.
   - Default to current agent only when reliably known.
   - If current agent is unknown and neither `--agent` nor `--all` is provided, stop and ask for explicit scope.
   - `--all` expands adapter suggestion scope only; it must not create multiple `.codebase/` variants.

2. Verify pack entry.
   - `.codebase/router.md` must exist before suggesting adapter patches.
   - If router is missing, stop and recommend `ariadne-suggest-init` or `ariadne-check-pack`.
   - Read `.codebase/meta/manifest.json` if present to include pack context, but do not require full freshness analysis.

3. Select target agents.
   - Current agent by default.
   - Specific agent when `--agent <name>` is provided.
   - All supported v1 agents when `--all` is provided.

4. Inspect target entry files.
   - `codex`: `AGENTS.md`.
   - `claude`: `CLAUDE.md`.
   - `gemini`: `GEMINI.md`.
   - `cursor`: `.cursor/rules/*.md` or `.cursorrules`, according to current project layout.
   - `antigravity`: use registry entry when defined; otherwise report unsupported/unknown mapping.

5. Build adapter patch suggestion.
   - Use the fixed Adapter Boot Instruction.
   - Adjust only file format and relative path where needed.
   - Use `patch` for existing entry files with `baseHash`.
   - Use `create` for missing entry files when the target path is unambiguous.
   - Do not copy UI rules, framework API lists, Page Recipes, module granularity rules, or other Runtime Docs into the entry file.

6. Write suggestion artifacts.
   - Write `.codebase/meta/suggestions/adapter-*.json`.
   - Write `.codebase/meta/suggestions/adapter-*.md`.
   - Do not directly modify agent entry files.

7. Report result.
   - Summarize target agents, entry files, patch/create operations, warnings, and suggestion id.
   - Include apply instruction: `ariadne-apply-suggestion <id>`.

## Adapter Boot Instruction

Use this minimal behavior, with equivalent wording allowed only when it preserves the same meaning:

```md
Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
```

## Out Of Scope

Do not:

- directly edit agent entry files;
- generate or refresh `.codebase/` Runtime Docs;
- copy `.codebase/` content into entry files;
- inspect source freshness;
- apply suggestions;
- create per-agent pack variants.

## Failure Rules

Stop or report blocked suggestion when:

- Agent Scope is unknown and no explicit scope is provided.
- requested agent is unsupported.
- `.codebase/router.md` is missing.
- target entry file exists but cannot be safely patched.
- target agent mapping is ambiguous.
- patch would duplicate Runtime Docs instead of pointing to router.

## Validation Checklist

Before finishing:

- Suggestion JSON and Markdown summary were written under `.codebase/meta/suggestions/`.
- No agent entry file was directly modified.
- Suggested content is a thin Adapter Boot Instruction.
- Default scope only targets current agent.
- `--all` affects adapters only, not pack variants.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
