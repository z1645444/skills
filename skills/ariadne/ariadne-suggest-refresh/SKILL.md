---
name: ariadne-suggest-refresh
description: Generate a reviewable Ariadne refresh suggestion for an existing `.codebase/` Codebase Knowledge Pack. Use when `ariadne-check-freshness` reports stale source classes or when project/framework/UI/module-layout changes require updating generated Evidence Artifacts, generated Runtime Docs, candidates, or reviewed-rule patches without directly modifying Runtime Docs or agent entry files.
---

# Ariadne Suggest Refresh

## Overview

Use this skill to plan `.codebase/` refresh changes. It reads manifest state, source fingerprints, current evidence, Runtime Docs, and file ownership, then writes a refresh suggestion JSON/MD under `.codebase/meta/suggestions/`.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, source class names, and other technical proper nouns.

## Required Reference

Before creating a refresh suggestion, read `references/refresh-contracts.md`. It defines the fixed source-to-doc mapping, ownership behavior, Refresh Conflict handling, and suggestion output requirements.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Verify pack readiness.
   - Read `.codebase/meta/manifest.json`.
   - Verify supported schema major version.
   - Verify `sources` and `files` ownership map exist.
   - If pack structure is invalid, stop and recommend `ariadne-check-pack`.

3. Determine stale source classes.
   - Use prior `ariadne-check-freshness` result when provided.
   - Otherwise recompute current source fingerprints and compare with manifest.
   - Use only fixed v1 source classes and source-to-doc mapping.
   - If no source classes are stale, report no refresh suggestion is needed.

4. Re-analyze affected source classes.
   - Project identity changes update identity evidence and may affect overview/framework detection.
   - Framework authority changes update authority evidence, framework usage docs, and framework candidates.
   - Project usage changes update project usage evidence and affected framework/UI/module knowledge.
   - Routing/page entry changes update page inventory, module granularity, and Page Recipe candidates.
   - UI/style usage changes update UI usage evidence, UI patterns, and UI risk candidates.
   - Module layout changes update module granularity evidence and outlier candidates.

5. Build refresh operations.
   - `generated` files may use `replace` with `baseHash` guard.
   - `reviewed` and `manual` files must use `patch` or candidate/review suggestions.
   - Runtime `rules/*.md` are not replaced automatically.
   - Refresh suggestions must preserve Current Snapshot and must not append historical deltas to Runtime Docs.

6. Handle Refresh Conflict.
   - If a generated file's current hash differs from manifest recorded base hash, do not overwrite it.
   - Generate a conflict suggestion that explains choices such as accept regeneration, keep current and mark reviewed/manual, or inspect diff manually.
   - Do not attempt section-level merge in v1.

7. Write suggestion artifacts.
   - Write `.codebase/meta/suggestions/refresh-*.json`.
   - Write `.codebase/meta/suggestions/refresh-*.md`.
   - Do not directly modify Runtime Docs, Evidence Artifacts, candidates, manifest, or agent entry files outside the suggestion operations.

8. Report result.
   - Summarize stale sources, affected docs, conflicts, risk, and suggestion id.
   - Include apply instruction: `ariadne-apply-suggestion <id>`.

## Suggestion Requirements

The refresh suggestion must:

- follow v1 Suggestion Schema;
- include source fingerprints and target preconditions;
- use only `create`, `replace`, and `patch`;
- include a Markdown review summary;
- include File Ownership-aware operations;
- keep low-confidence findings in `meta/candidates/`;
- route reviewed/manual changes through patch or review candidates.

## Out Of Scope

Do not:

- directly write Runtime Docs;
- directly update `.codebase/meta/manifest.json`;
- directly update Evidence Artifacts;
- directly patch agent entry files;
- apply the suggestion;
- perform automatic deprecated API migration;
- perform automatic refactoring or section-level merge.

## Failure Rules

Stop or generate a blocked/conflict suggestion when:

- Agent Scope is unknown.
- pack check would fail.
- manifest schema is unsupported.
- required source evidence cannot be recomputed.
- source evidence is too weak for requested refresh.
- generated target file has Refresh Conflict.
- requested refresh would require overwriting reviewed/manual Runtime Rules.

## Validation Checklist

Before finishing:

- Suggestion JSON and Markdown summary were written under `.codebase/meta/suggestions/`.
- No Runtime Docs or agent entry files were directly modified.
- Fixed source-to-doc mapping was used.
- Refresh Conflict was not overwritten.
- Reviewed/manual files were not replaced.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
