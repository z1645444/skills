---
name: pagepack-suggest-adapters
description: Generate a directly applicable patch for agent entry files `AGENTS.md` or `CLAUDE.md` so they point to `.codebase/router.md`. Outputs a unified diff for review and direct application.
---

# Pagepack Suggest Adapters

## Overview

Use this skill to propose thin Agent Adapter patches. It outputs a directly applicable unified diff for the target agent entry file, without writing JSON/MD suggestion bundles under `.codebase/`.

Generated human-facing output must use the user's preferred language. If unspecified, default to English. Preserve file paths, command names, API names, agent names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before creating an adapter patch, read `references/adapter-suggestion-contracts.md`. It defines supported agents, fixed Adapter Boot Instruction, patch rules, and scope handling.

## Workflow

1. Resolve Agent Scope.
   - Default to current agent only when reliably known.
   - If current agent is unknown and neither `--agent` nor `--all` is provided, stop and ask for explicit scope.
   - `--all` expands adapter suggestion scope only; it must not create multiple `.codebase/` variants.

2. Verify pack entry.
   - `.codebase/router.md` must exist before suggesting adapter patches.
   - If router is missing, stop and recommend `pagepack-init`.

3. Select target agents.
   - Current agent by default.
   - Specific agent when `--agent <name>` is provided.
   - All supported v1 agents when `--all` is provided.

4. Inspect target entry files.
   - `codex`: `AGENTS.md`.
   - `claude`: `CLAUDE.md`.

5. Build adapter patch.
   - Use the fixed Adapter Boot Instruction.
   - Adjust only file format and relative path where needed.
   - Use `create` semantics for missing entry files.
   - Use `patch` semantics for existing entry files, with an optional `baseHash` for safety.
   - Do not copy UI rules, framework API lists, Page Recipes, module granularity rules, or other Runtime Docs into the entry file.

6. Output the patch.
   - Present the unified diff directly to the user.
   - Include target file, optional `baseHash`, and a concise summary of changes.
   - Do not write files under `.codebase/` or modify agent entry files directly.

7. Report result.
   - Summarize target agents, entry files, create/patch operations, and warnings.
   - Include apply instruction: use `pagepack-apply-suggestion` with the provided patch, or apply the diff directly if reviewed.

## Trailing Prompt Guidance

If the user provides trailing text after `pagepack-suggest-adapters`, treat it as directional guidance for the patch. Examples:

- `pagepack-suggest-adapters use relative path for monorepo`
- `pagepack-suggest-adapters add note about SSR`

The output must still be a concrete, applicable patch/diff, not a freeform conversation response.

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
- apply suggestions.

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

- A concrete unified diff was output for each target agent entry file.
- No agent entry file was directly modified.
- Suggested content is a thin Adapter Boot Instruction.
- Default scope only targets current agent.
- `--all` affects adapters only, not pack variants.
- Trailing prompt guidance was respected if provided.
- Human-facing output uses the user's preferred language, defaulting to English, with technical proper nouns preserved.
