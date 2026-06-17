# Pagepack Adapter Suggestion Contracts

This reference defines the contract for Agent Adapter patches. Human-facing output uses the user's preferred language, defaulting to English; preserve file paths, command names, API names, agent names, framework names, component names, identifiers, and other technical proper nouns.

## Scope

`pagepack-suggest-adapters` produces directly applicable patches for agent entry files. It does not write suggestion bundles under `.codebase/` and does not directly modify agent entry files.

It reads:

- adapter registry;
- `.codebase/router.md`;
- target agent entry files.

It outputs:

- unified diff patch blocks for `AGENTS.md` and/or `CLAUDE.md`;
- optional `baseHash` for existing files;
- a concise human-facing summary.

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

Do not infer current agent from the mere presence of `AGENTS.md` or `CLAUDE.md`.

## V1 Adapter Registry

```text
codex
  AGENTS.md

claude
  CLAUDE.md
```

Do not create capability names like `pagepack-suggest-codex-adapter`.

## Router Requirement

`.codebase/router.md` must exist before adapter suggestions are generated.

If missing:

```text
recommend pagepack-init
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

## Patch Output Format

The skill outputs a unified diff for each target entry file. For a missing file, the patch represents a `create` operation. For an existing file, it represents a `patch` operation.

Example for a missing `CLAUDE.md`:

```diff
--- /dev/null
+++ CLAUDE.md
@@ -0,0 +1,3 @@
+# Project Context
+
+Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
```

Example for an existing `AGENTS.md`:

```diff
--- AGENTS.md
+++ AGENTS.md
@@ -1,5 +1,8 @@
 # Agent Instructions

+Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
+
 ## Coding Style

 ...
```

For existing files, include an optional `baseHash` so `pagepack-apply-suggestion` can guard against stale application.

## Operation Guidance

Use `create` semantics when:

- expected entry file is missing;
- target path is unambiguous;
- parent directory can be created safely by apply.

Use `patch` semantics when:

- entry file exists;
- `baseHash` can be recorded;
- patch insertion point is clear.

Block or mark review-needed when:

- multiple possible rule files exist and no target is obvious;
- entry file has complex conflicting instructions;
- patch insertion point is unsafe;
- file contains large duplicated project rules that require manual cleanup.

## Trailing Prompt Guidance

Trailing text narrows the adapter patch. Examples:

- `pagepack-suggest-adapters use relative path for monorepo`
- `pagepack-suggest-adapters add note about SSR`

The patch must still be concrete and directly applicable.

## Drift Risk Handling

If an existing entry file copies Runtime Docs, report drift risk in the summary. The patch may still add or fix router boot instruction, but it should not silently remove large duplicated sections in v1.

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
