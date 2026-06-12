---
name: ariadne-suggest-init
description: Directly create the initial agent-neutral `.codebase/` Codebase Knowledge Pack when no pack exists. Use when a management-system frontend project needs first-time `.codebase/` setup, Task Router bootstrap, manifest/evidence scaffolding, and framework/UI/module-granularity observed knowledge; existing packs, recovery, refresh, rules, recipes, and adapter changes still use reviewable suggestions.
---

# Ariadne Suggest Init

## Overview

Use this skill to directly create the initial `.codebase/` Codebase Knowledge Pack when no `.codebase/` exists. Initial bootstrap is the only direct-write exception in Ariadne v1 because there is no existing pack knowledge to overwrite.

This skill must not modify agent entry files. Adapter changes still go through `ariadne-suggest-adapters` and `ariadne-apply-suggestion`. Existing packs, recovery, refresh, rules, and recipes also remain reviewable suggestions.

Generated human-facing content must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before creating an initial pack, read `references/shared-contracts.md`. It defines direct bootstrap rules, file ownership, source classes, router routes, and output requirements.

## Workflow

1. Resolve Agent Scope.
   - Use current agent when reliably known.
   - If unknown, stop and ask the user to provide `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Inspect existing pack state.
   - If no `.codebase/` exists, continue with Direct Pack Bootstrap.
   - If compatible `.codebase/meta/manifest.json` exists, stop and recommend `ariadne-suggest-refresh`.
   - If `.codebase/` exists but manifest is missing, create a Pack Recovery suggestion instead of overwriting.
   - If schema major version is incompatible, stop normal init and create a migration-needed report or migration suggestion.
   - If `.codebase-*` variants exist, report Single Pack Invariant violation and do not merge automatically.

3. Collect Bootstrap Source Minimum.
   - Project identity: `package.json`, lockfile, TypeScript/build config.
   - Routing/page entries: routes, pages/views/modules, menu config when present.
   - Framework Authority: framework package metadata, type declarations, exports, docs source when available.
   - Project Usage: imports, JSX usage, hooks, wrappers, request/service patterns.
   - UI/style usage: UI components, wrappers, stylesheets, `className`, inline styles.
   - Module granularity: page directory layout, services, hooks, constants, schemas, types.
   - Never read or quote secret-bearing files.

4. Build evidence-backed current snapshot candidates.
   - Use Framework Authority to verify API existence; use Project Usage to identify default project paths and wrappers.
   - Treat missing Framework Authority as a Framework Detection Candidate, not as confirmed API guidance.
   - Separate Observed Knowledge from Coding Rules.
   - Put low-confidence rules and Page Recipe findings into candidates, not Runtime Rules.

5. Directly create the initial pack.
   - Prepare all Runtime Docs, Evidence Artifacts, manifest, candidates, and metadata before writing.
   - Create the complete Practical Core `.codebase/` structure in one bootstrap pass.
   - Write `.codebase/router.md`, `.codebase/knowledge/*`, `.codebase/rules/*`, `.codebase/meta/*`, and high-confidence `.codebase/examples/*` when evidence permits.
   - Write `.codebase/meta/manifest.json` with the v1 Pack Manifest Schema: ISO-8601 string `packVersion`, top-level `generatedBy`, `agentScope`, canonical `sources` entries with `fingerprint`, and `files` ownership.
   - Do not create `init-*.json` or require `ariadne-apply-suggestion` for the first bootstrap.
   - Do not modify `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/`, or other agent entry files.

6. Summarize outcome.
   - Report created files and any skipped or candidate-only areas.
   - State confidence for framework, UI, module granularity, and Page Recipe candidates.
   - State recommended next commands: `ariadne-check-pack` and, if adapter setup is needed, `ariadne-suggest-adapters`.

## Runtime Docs To Create

Direct bootstrap should create this Practical Core structure when evidence permits:

```text
.codebase/
  router.md
  knowledge/
    overview.md
    framework-usage.md
    ui-patterns.md
    module-granularity.md
  rules/
    ui.md
    framework-api.md
    file-structure.md
  examples/
    page-types/
  meta/
    manifest.json
    evidence/
    suggestions/
    candidates/
    change-log.md
```

`knowledge/*.md` are usually `generated`. Runtime `rules/*.md` are `reviewed` by default; project-inferred rules go to `meta/candidates/` or suggestions until confirmed.

## Failure Rules

Stop instead of guessing when:

- Agent Scope is unknown.
- Bootstrap Source Minimum is too weak to form a credible pack.
- an existing compatible pack should be refreshed instead of initialized.
- multiple pack variants violate Single Pack Invariant.
- framework API guidance would require inventing unverified APIs.
- recovery, migration, adapter, refresh, rules, or recipe changes would be required; those must use reviewable suggestions.

## Validation Checklist

Before finishing:

- `.codebase/router.md` and `.codebase/meta/manifest.json` exist after bootstrap.
- The manifest satisfies the same required fields checked by `ariadne-check-pack`.
- The manifest records file ownership in `files`.
- The manifest records freshness fingerprints in canonical `sources` entries.
- Stable source keys use `projectIdentity`, `frameworkAuthority`, `projectUsage`, `routingPageEntries`, `uiStyleUsage`, and `moduleLayout`.
- No init suggestion is required for first bootstrap.
- Agent entry files were not modified.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
- Low-confidence framework, UI, module granularity, or Page Recipe findings remain candidates.
