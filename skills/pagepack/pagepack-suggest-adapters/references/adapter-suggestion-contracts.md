# Pagepack Adapter Suggestion Contracts

This reference defines the v1 suggestion contract for Agent Adapter patches. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, agent names, framework names, component names, identifiers, and suggestion ids.

## Scope

`pagepack-suggest-adapters` plans adapter changes. It may write suggestion JSON/MD under `.codebase/meta/suggestions/`, but it must not directly modify agent entry files.

It reads:

- adapter registry;
- `.codebase/router.md`;
- `.codebase/meta/manifest.json` when present;
- target agent entry files.

It writes:

- `.codebase/meta/suggestions/adapter-*.json`;
- `.codebase/meta/suggestions/adapter-*.md`.

## Agent Scope

Adapter suggestions default to current agent.

```text
current agent
  -> suggest adapter for current agent only

--agent codex
  -> suggest Codex adapter only

--all
  -> suggest adapters for all supported agents

unknown current agent without --agent/--all
  -> stop and ask for explicit scope
```

Do not infer current agent from the mere presence of `AGENTS.md`, `CLAUDE.md`, or other entry files.

## V1 Adapter Registry

```text
codex
  AGENTS.md

claude
  CLAUDE.md

gemini
  GEMINI.md

cursor
  .cursor/rules/*.md
  .cursorrules

antigravity
  registry entry required; if unknown, report unsupported mapping
```

Do not create capability names like `pagepack-suggest-codex-adapter`.

## Router Requirement

`.codebase/router.md` must exist before adapter suggestions are generated.

If missing:

```text
recommend pagepack-init or pagepack-check-pack
do not create adapter suggestion
```

Reason: adapter entry files should point to the real Task Router, not a planned or guessed path.

## Fixed Adapter Boot Instruction

Minimal instruction:

```md
Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
```

Equivalent wording is allowed only when it preserves:

- read `.codebase/router.md` before coding;
- classify task through Task Router;
- load only required Runtime Docs unless broader context is necessary.

Do not include:

- UI rules;
- framework API lists;
- Page Recipes;
- module granularity rules;
- copied `.codebase/` sections.

## Suggestion Schema

Adapter suggestions use the standard v1 schema:

```json
{
  "schemaVersion": "1.0.0",
  "id": "adapter-20260610-001",
  "type": "adapter-patch",
  "createdAt": "2026-06-10T10:00:00Z",
  "createdBy": "pagepack-suggest-adapters",
  "agentScope": ["codex"],
  "risk": "low",
  "sourceFingerprints": {
    ".codebase/router.md": "sha256:..."
  },
  "targetPreconditions": [],
  "operations": [],
  "reviewSummaryPath": ".codebase/meta/suggestions/adapter-20260610-001.md"
}
```

Allowed operation actions:

- `create`;
- `patch`.

Avoid `replace` for agent entry files because they are human/agent maintained.

## Operation Guidance

Use `create` when:

- expected entry file is missing;
- target path is unambiguous;
- parent directory can be created safely by apply.

Use `patch` when:

- entry file exists;
- `baseHash` can be recorded;
- patch insertion point is clear.

Block or mark review-needed when:

- multiple possible Cursor rule files exist and no target is obvious;
- entry file has complex conflicting instructions;
- patch insertion point is unsafe;
- file contains large duplicated project rules that require manual cleanup.

## Target Preconditions

For `create`:

```json
{
  "path": "AGENTS.md",
  "condition": "must_not_exist"
}
```

For `patch`:

```json
{
  "path": "AGENTS.md",
  "condition": "hash_equals",
  "hash": "sha256:..."
}
```

Apply must block when target state changes before application.

## Review Summary

Markdown review summary should include:

- suggestion id;
- target Agent Scope;
- target entry files;
- whether each operation is `create` or `patch`;
- warnings for drift risk or copied rules;
- exact Adapter Boot Instruction to be inserted;
- apply instruction: `pagepack-apply-suggestion <id>`.

## Drift Risk Handling

If an existing entry file copies Runtime Docs, report drift risk in the summary. The suggestion may still add or fix router boot instruction, but it should not silently remove large duplicated sections in v1.

Manual cleanup can be recommended separately.

## Failure And Blocking

Block when:

- Agent Scope is unknown;
- requested agent is unsupported;
- `.codebase/router.md` is missing;
- target mapping is ambiguous;
- existing file is unreadable;
- safe patch insertion is not possible;
- operation would copy Runtime Docs into entry file.
