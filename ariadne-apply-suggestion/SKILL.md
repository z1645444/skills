---
name: ariadne-apply-suggestion
description: Safely apply an explicit Ariadne Suggestion from `.codebase/meta/suggestions/` by parsing the v1 Suggestion Schema, running Apply Guard, and executing the bundle only when source fingerprints, target preconditions, file ownership, schema compatibility, and Agent Scope all match. Use after reviewing a suggestion produced by `ariadne-suggest-refresh`, `ariadne-suggest-adapters`, `ariadne-suggest-recipes`, or `ariadne-suggest-rules`; initial bootstrap uses `ariadne-init` directly and does not produce an applicable init suggestion.
---

# Ariadne Apply Suggestion

## Overview

Use this skill to apply a reviewed Ariadne Suggestion safely. It must never infer missing intent, regenerate project knowledge, or best-effort apply a partial bundle.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, suggestion ids, and other technical proper nouns.

## Required Reference

Before applying or evaluating a suggestion, read `references/apply-contracts.md`. It defines Apply Guard, supported operations, target preconditions, ownership checks, and failure behavior.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not fall back to generic/manual mode.

2. Locate the suggestion.
   - Accept an explicit suggestion id or path.
   - Prefer `.codebase/meta/suggestions/<id>.json`.
   - Read the companion Markdown review summary when present.
   - If the suggestion is missing, stop.

3. Parse Suggestion Schema.
   - Verify `schemaVersion`, `id`, `type`, `createdBy`, `agentScope`, `sourceFingerprints`, `targetPreconditions`, `operations`, and `reviewSummaryPath`.
   - Reject unsupported schema major versions, unsupported suggestion types, and unsupported operation actions.
   - v1 supports only `create`, `replace`, and `patch`.

4. Run Apply Guard before writing anything.
   - Verify current Agent Scope is allowed by the suggestion.
   - Recompute source fingerprints and compare with the suggestion.
   - Check all target preconditions.
   - Check `baseHash` for `replace` and `patch` operations.
   - Check File Ownership for `replace` operations.
   - If any guard fails, report the blocking reason and write nothing.

5. Execute Bundle Apply.
   - Apply all operations as one logical bundle only after all guard checks pass.
   - Do not skip failed operations and continue.
   - If a write fails, stop and report the partial state clearly. Prefer preventing partial state through preflight checks before writing.
   - Do not execute delete, move, chmod, shell commands, or hidden side effects.

6. Report result.
   - Summarize applied operations.
   - Include changed files.
   - If blocked, state which guard failed and recommend rerunning the relevant `ariadne-suggest-*` capability.

## Operation Rules

`create`:
- Target path must not exist unless a precondition explicitly allows safe idempotence.
- Parent directories may be created as part of applying the operation.

`replace`:
- Target file must exist unless the suggestion explicitly combines safe creation semantics, which v1 should avoid.
- Target file must match `baseHash`.
- Target file must be `generated` according to `.codebase/meta/manifest.json`.
- `reviewed`, `manual`, or `unknown` ownership blocks replace.

`patch`:
- Target file must match `baseHash`.
- Patch must apply cleanly.
- Use patch for agent entry files and reviewed/manual content.

## Blocking Conditions

Stop without writing when:

- Agent Scope is unknown.
- suggestion id/path is not explicit.
- suggestion JSON is missing or invalid.
- schema major version is unsupported.
- suggestion type is unsupported.
- any operation action is unsupported.
- source fingerprints do not match.
- target preconditions fail.
- `baseHash` does not match.
- `replace` targets non-generated ownership.
- patch does not apply cleanly.
- the bundle contains destructive operations or shell commands.

## Validation Checklist

Before finishing:

- Confirm no write occurred before Apply Guard passed.
- Confirm every operation was supported.
- Confirm changed files match the suggestion operations.
- Confirm no `.codebase-*` variants were created.
- Confirm human-facing result is Simplified Chinese with technical proper nouns preserved.
