---
name: pagepack-apply-suggestion
description: Apply a reviewed unified diff patch safely via the mechanized apply script — existence and baseHash guards, dry-run precheck, then automatic baseline-diff integrity verification.
---

# Pagepack Apply Suggestion

## Overview

Use this skill to apply a reviewed patch safely. The guard, patch application, and Post-Apply Verification are mechanized in `scripts/apply.sh`, which is the single source of truth for apply behavior; this skill locates the patch, runs the script, and interprets the result. It does not read a manifest, ownership map, or persisted suggestion bundles.

Without an explicit patch, the script applies the tool runtime cache `.codebase/.last-suggestion.diff` written by `pagepack-suggest-*` skills and verifies base hashes from `.codebase/.last-suggestion.meta`. After a successful apply it automatically reruns the `pagepack-check-pack` mechanical checks and separates findings introduced by the patch from pre-existing debt.

## Required Reference

Before applying, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/apply-contracts.md` (script contract, input format, guard rules, Post-Apply Verification semantics).

## Workflow

1. Resolve Agent Scope per the shared contracts. If the current agent is unknown and no explicit scope is provided, stop and ask.

2. Locate the patch.
   - If the user provides an explicit unified diff, write it verbatim to a temporary file outside `.codebase/` — never into the suggestion cache, which would fake cache provenance and pair it with stale meta.
   - Otherwise the script defaults to the cache; do not pre-read or validate the cache yourself.

3. Run the script.
   - Cached suggestion: `bash scripts/apply.sh <repo-root>` (script shipped in this skill's directory).
   - Explicit patch: add `--patch <temp-file>`.
   - Preview without writing: add `--dry-run` when the user asks for a guard check only.

4. Interpret the result by exit code.
   - `0`: applied; no findings introduced (or verification was skipped — the output says which).
   - `3`: applied, but the INTRODUCED section is non-empty; report those findings prominently with the fix routing from the check contracts, and recommend a follow-up patch. Never roll the applied patch back.
   - `1`: guard blocked (`BLOCKED:` lines say why; nothing was written) or the apply itself failed; recommend regenerating the patch via the owning `pagepack-suggest-*` capability.
   - `2`: usage error; fix the invocation.

5. Report result.
   - Summarize applied files and the verification outcome: INTRODUCED / RESOLVED / PRE-EXISTING counts, or the reason verification was skipped.
   - If blocked, state the guard reason verbatim and the recommended regeneration step.

## Out Of Scope

Do not:

- reimplement guard, hashing, patching, or verification inline — run the script; if it is missing or fails to execute, report the raw error instead of improvising;
- write the user's explicit patch into `.codebase/.last-suggestion.diff` or `.meta`;
- roll back an applied patch because verification reported findings;
- read `.last-suggestion.*` as content sources — they are tool runtime caches.

## Validation Checklist

Before finishing:

- The script actually ran; the report reflects its output and exit code, not inference.
- An explicit user patch went through a temporary file, not the suggestion cache.
- Introduced findings are clearly separated from pre-existing debt in the report.
- No `.codebase-*` variants were created.
- Human-facing output follows the shared Language Policy.
