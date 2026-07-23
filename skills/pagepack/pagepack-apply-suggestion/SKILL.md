---
name: pagepack-apply-suggestion
description: Apply a reviewed unified diff patch safely. Checks file existence and baseHash, applies the patch, then automatically runs pack integrity checks and reports any findings the patch introduced.
---

# Pagepack Apply Suggestion

## Overview

Use this skill to apply a reviewed patch safely. It accepts a unified diff (inline or referenced). When no patch is provided, it reads the tool runtime cache `.codebase/.last-suggestion.diff` written by `pagepack-suggest-*` skills. The skill runs a minimal guard, applies the patch, and then automatically runs Post-Apply Verification: the `pagepack-check-pack` mechanical checks in baseline-diff mode, so findings introduced by the patch are separated from pre-existing debt. It does not read a manifest, ownership map, or persisted suggestion bundles.

## Required Reference

Before applying, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/apply-contracts.md` (input format, guard rules, Post-Apply Verification, and failure behavior).

## Workflow

1. Resolve Agent Scope per the shared contracts. If the current agent is unknown and no explicit scope is provided, stop and ask.

2. Accept the patch.
   - If the user provides an explicit unified diff, use it.
   - Otherwise, read the tool runtime cache `.codebase/.last-suggestion.diff` (not a Runtime Doc).
   - Optionally accept a `baseHash` for the target file.
   - Do not locate or parse persisted suggestion JSON/MD bundles.

3. Run Apply Guard before writing anything.
   - Verify target file existence matches the patch expectation (existing for `patch`, absent for `create`).
   - If `baseHash` is provided, compute the current file hash and compare.
   - If the last-suggestion cache is missing, empty, or malformed, and no explicit patch was given, stop and recommend running a `pagepack-suggest-*` skill first.
   - If any guard fails, report the blocking reason and write nothing.

4. Record the verification baseline.
   - If `.codebase/` exists, run `bash ../pagepack-check-pack/scripts/check-pack.sh <repo-root>` (path resolved relative to this skill's directory) and keep its output as the baseline.
   - If the pack or the script is unavailable, note that verification will be skipped and continue.

5. Apply the patch.
   - Apply the unified diff to the target file.
   - If the patch does not apply cleanly, stop and report failure.

6. Run Post-Apply Verification.
   - Run the same check script again and compare with the baseline.
   - Findings only in the post-apply run were introduced by this patch: report them prominently with the fix routing from the check contracts.
   - Findings in both runs are pre-existing debt: report them as notes.
   - Findings only in the baseline were fixed by this patch: report them as resolved.
   - Never roll the patch back; the patch was human-reviewed. Recommend a follow-up patch for introduced findings.

7. Report result.
   - Summarize applied files and the verification outcome (introduced / pre-existing / resolved counts, or the reason verification was skipped).
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
- `.codebase/.last-suggestion.diff` is missing when no explicit patch is provided.
- target file existence does not match patch expectation.
- `baseHash` does not match current file hash.
- patch does not apply cleanly.

A Post-Apply Verification finding is not a blocking condition; it is reported, not rolled back.

## Validation Checklist

Before finishing:

- Confirm no write occurred before the guard passed.
- Confirm changed files match the patch.
- Confirm Post-Apply Verification ran, or its skip reason was reported.
- Findings introduced by the patch are clearly separated from pre-existing debt.
- Confirm no `.codebase-*` variants were created.
- Confirm `.codebase/.last-suggestion.diff` was treated only as a tool runtime cache, not as a Runtime Doc or agent-readable source.
- Human-facing output follows the shared Language Policy.
