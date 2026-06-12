---
name: ariadne-check-pack
description: Read-only structural and contract check for an Ariadne `.codebase/` Codebase Knowledge Pack. Use when verifying Single Pack Invariant, `.codebase/router.md`, `.codebase/meta/manifest.json`, supported schema version, file ownership map, router-linked Runtime Docs, and suggestion store readiness without checking freshness or generating suggestions.
---

# Ariadne Check Pack

## Overview

Use this skill to verify whether a repository-local `.codebase/` pack is structurally valid and readable by Ariadne capabilities. It must never regenerate docs, create suggestions, update manifests, or check source freshness.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before checking a pack, read `references/pack-check-contracts.md`. It defines the v1 Pack Check scope, status levels, manifest requirements, router link checks, and out-of-scope freshness checks.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Check Single Pack Invariant.
   - Verify there is exactly one `.codebase/`.
   - Report `.codebase-*` variants as errors.
   - Do not merge, delete, or normalize variants.

3. Check required pack files.
   - `.codebase/router.md` must exist and be readable.
   - `.codebase/meta/manifest.json` must exist and be readable.
   - `.codebase/meta/suggestions/` should exist or be clearly creatable by later suggest capabilities.

4. Validate manifest contract.
   - Verify supported `schemaVersion`.
   - Verify required manifest fields exist.
   - Verify `files` ownership map is readable.
   - Verify ownership values are known: `generated`, `reviewed`, or `manual`.

5. Validate router-linked Runtime Docs.
   - Parse or inspect `.codebase/router.md` for referenced `.codebase/` Runtime Docs.
   - Check referenced files exist.
   - Do not require candidates or optional examples unless the router treats them as required.

6. Report status.
   - Default to human-readable summary.
   - If `--json` is requested, emit machine-readable status.
   - Clearly separate `error`, `warning`, and `ok`.

## Out Of Scope

Do not check:

- source freshness;
- framework upgrades;
- page inventory changes;
- UI/style usage drift;
- adapter entry files;
- suggestion validity;
- evidence accuracy.

Those belong to `ariadne-check-freshness`, `ariadne-check-adapters`, `ariadne-apply-suggestion`, or `ariadne-explain`.

## Failure Rules

Stop or report error when:

- Agent Scope is unknown.
- `.codebase/` is missing.
- multiple pack variants exist.
- router is missing.
- manifest is missing.
- manifest schema is unsupported.
- ownership map is unreadable or invalid.
- router references required Runtime Docs that do not exist.

## Validation Checklist

Before finishing:

- No file was written.
- No suggestion was created.
- No freshness analysis was performed.
- Output distinguishes errors, warnings, and ok checks.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
