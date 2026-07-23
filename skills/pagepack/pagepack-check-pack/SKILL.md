---
name: pagepack-check-pack
description: Run mechanical integrity checks on an existing `.codebase/` pack — source reference existence, router coverage, pack cross-references, cache hygiene. Read-only; reports findings and which capability fixes them.
---

# Pagepack Check Pack

## Overview

Use this skill to verify the integrity of an existing `.codebase/` Codebase Knowledge Pack. The mechanical checks live in `scripts/check-pack.sh`, which is the single source of truth for what is checked; this skill runs the script, interprets findings, and recommends the capability that fixes each finding class. It never writes anything.

`pagepack-apply-suggestion` runs these same checks automatically after every apply (Post-Apply Verification). Run this skill standalone for periodic audits or before publishing pack changes.

## Required Reference

Before checking, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/check-contracts.md` (check classes, severity policy, and fix routing).

## Workflow

1. Locate the repository root: the directory containing `.codebase/`, from the current working directory or an explicit user-provided path. This capability is read-only and agent-neutral; Agent Scope resolution is not required.

2. Run the mechanical checks.
   - Execute `bash scripts/check-pack.sh <repo-root>` (script shipped in this skill's directory; add `--strict` when the user asks warnings to fail).
   - If `.codebase/` is missing, stop and recommend `pagepack-init`.

3. Interpret findings using the check classes in the contract (C1 source references, C2 router coverage, C3 pack cross-references, C4 cache hygiene).

4. Optionally run judgment-level review when the user asks for a thorough audit. Report-only, never patched here:
   - recipes missing source references, confidence, or evidence sections required by the recipe contract;
   - the same checkable fact stated in multiple documents (duplication drifts apart under curation);
   - Page Recipes accumulating cross-cutting behavior sections that belong in a Behavior Recipe.

5. Report result.
   - List findings grouped by severity, with the fix route per class:
     - C1 stale source reference -> `pagepack-suggest-knowledge`, or a manual patch via `pagepack-apply-suggestion`;
     - C2 unrouted document -> `pagepack-suggest-knowledge` (router repair) or `pagepack-suggest-recipes` (rewiring with the recipe);
     - C3 broken pack reference -> fix the referencing document via the owning suggest capability;
     - C4 cache reference -> remove the reference from the Runtime Doc.
   - State the exit code meaning: 0 clean, 1 findings, 2 pack missing.

## Out Of Scope

Do not:

- write or patch any file;
- generate suggestion diffs (recommend the owning `pagepack-suggest-*` capability instead);
- delete or move documents;
- audit project source code itself — only the pack is in scope.

## Failure Rules

Stop and report when:

- `.codebase/` is missing (exit code 2);
- the check script is missing or fails to execute — report the raw error, do not silently reimplement the checks inline.

## Validation Checklist

Before finishing:

- The script actually ran; findings come from its output, not from inference.
- Every reported finding includes its check class and the recommended fix route.
- No file was modified.
- Human-facing output follows the shared Language Policy.
