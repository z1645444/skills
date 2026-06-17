---
name: pagepack-apply-suggestion
description: Apply a reviewed unified diff patch safely. Checks file existence and optional baseHash, then applies the patch. No manifest or ownership lookups.
---

# Pagepack Apply Suggestion

## Overview

Use this skill to apply a reviewed patch safely. It accepts a unified diff (inline or referenced), runs a minimal guard, and applies the patch. It does not read a manifest, ownership map, or persisted suggestion bundles.

Generated human-facing output must use the user's preferred language. If unspecified, default to English. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before applying, read `references/apply-contracts.md`. It defines the simplified input format, guard rules, and failure behavior.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not fall back to generic/manual mode.

2. Accept the patch.
   - Accept an explicit unified diff block from the user.
   - Optionally accept a `baseHash` for the target file.
   - Do not locate or parse persisted suggestion JSON/MD bundles.

3. Run Apply Guard before writing anything.
   - Verify target file existence matches the patch expectation (existing for `patch`, absent for `create`).
   - If `baseHash` is provided, compute the current file hash and compare.
   - If any guard fails, report the blocking reason and write nothing.

4. Apply the patch.
   - Apply the unified diff to the target file.
   - If the patch does not apply cleanly, stop and report failure.

5. Report result.
   - Summarize applied files.
   - If blocked, state which guard failed and recommend regenerating the patch.

## Input Format

A unified diff block:

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

For a new file:

```diff
--- /dev/null
+++ CLAUDE.md
@@ -0,0 +1,3 @@
+# Project Context
+
+Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
```

## Operation Rules

`create` semantics:
- Target path must not exist unless the user explicitly confirms overwrite.
- Parent directories may be created as part of applying the patch.

`patch` semantics:
- Target file must exist.
- Patch must apply cleanly.
- If `baseHash` is provided, target file must match it.

## Blocking Conditions

Stop without writing when:

- Agent Scope is unknown.
- patch is missing or malformed.
- target file existence does not match patch expectation.
- `baseHash` does not match current file hash.
- patch does not apply cleanly.

## Validation Checklist

Before finishing:

- Confirm no write occurred before the guard passed.
- Confirm changed files match the patch.
- Confirm no `.codebase-*` variants were created.
- Confirm human-facing result uses the user's preferred language, defaulting to English, with technical proper nouns preserved.
