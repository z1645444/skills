---
name: pagepack-check-freshness
description: Read-only freshness check for an Pagepack `.codebase/` Codebase Knowledge Pack. Use when verifying whether project sources, framework authority, routing/page entries, UI/style usage, project usage, or module layout changed since the manifest fingerprints were recorded, and to report stale source classes and affected Runtime Docs without generating refresh suggestions or modifying files.
---

# Pagepack Check Freshness

## Overview

Use this skill to diagnose whether `.codebase/` knowledge may be stale. It compares manifest source fingerprints with current source fingerprints and reports affected documents; it must not regenerate Runtime Docs, write Evidence Artifacts, or create suggestions.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, source class names, and other technical proper nouns.

## Required Reference

Before checking freshness, read `references/freshness-check-contracts.md`. It defines source classes, fixed source-to-doc mapping, output shape, and strict boundaries between `pagepack-check-freshness` and `pagepack-suggest-refresh`.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Load pack manifest.
   - Read `.codebase/meta/manifest.json`.
   - Verify supported schema major version.
   - Verify `sources` exists and is readable.
   - If manifest is missing or invalid, stop and recommend `pagepack-check-pack`.

3. Recompute current source fingerprints.
   - Recompute only source classes recorded in manifest unless the user explicitly requests a broader check.
   - Use the stable manifest source keys: `projectIdentity`, `frameworkAuthority`, `projectUsage`, `routingPageEntries`, `uiStyleUsage`, and `moduleLayout`.
   - If a required source fingerprint cannot be recomputed, report an error for that source class.

4. Compare freshness.
   - Mark source classes as `fresh`, `stale`, `missing`, or `error`.
   - Use the fixed source-to-doc mapping to list affected docs for stale source classes.
   - Do not update manifest fingerprints.

5. Report result.
   - Default to human-readable summary.
   - If `--json` is requested, emit machine-readable result.
   - Recommend `pagepack-suggest-refresh` when stale sources exist.
   - Recommend `pagepack-check-pack` when structural pack problems block freshness checks.

## Out Of Scope

Do not:

- write `.codebase/meta/suggestions/`;
- update `.codebase/meta/manifest.json`;
- regenerate Runtime Docs;
- update Evidence Artifacts;
- resolve Refresh Conflicts;
- inspect adapter entry files;
- apply suggestions.

## Failure Rules

Stop or report error when:

- Agent Scope is unknown.
- `.codebase/meta/manifest.json` is missing or unreadable.
- manifest schema major version is unsupported.
- manifest `sources` is missing or malformed.
- a required source fingerprint cannot be recomputed.

## Validation Checklist

Before finishing:

- No file was written.
- No suggestion was created.
- No Runtime Doc was regenerated.
- Stale source classes use the fixed source-to-doc mapping.
- Output includes affected docs and recommended next command.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
