---
name: ariadne-suggest-init
description: Generate a reviewable Ariadne Bootstrap Suggestion Bundle for creating an agent-neutral `.codebase/` Codebase Knowledge Pack. Use when a management-system frontend project needs initial `.codebase/` setup, Task Router bootstrap, manifest/evidence scaffolding, framework/UI/module-granularity observed knowledge, or a non-mutating init plan before `ariadne-apply-suggestion`.
---

# Ariadne Suggest Init

## Overview

Use this skill to propose the initial `.codebase/` Codebase Knowledge Pack without directly creating Runtime Docs or modifying agent entry files. It produces a Bootstrap Suggestion Bundle in `.codebase/meta/suggestions/` plus a Markdown review summary.

Generated human-facing content must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before creating or editing an init suggestion, read `references/shared-contracts.md`. It defines the Suggestion Schema, allowed operations, file ownership, source classes, router routes, and bootstrap output requirements.

## Workflow

1. Resolve Agent Scope.
   - Use current agent when reliably known.
   - If unknown, stop and ask the user to provide `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Inspect existing pack state.
   - If no `.codebase/` exists, continue with Pack Bootstrap.
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

5. Create one Bootstrap Suggestion Bundle.
   - Write `init-*.json` and matching `init-*.md` under `.codebase/meta/suggestions/`.
   - The bundle should contain file operations for the complete initial pack, not per-file standalone suggestions.
   - Use only `create`, `replace`, and `patch` operations.
   - Do not directly write `.codebase/router.md`, `.codebase/knowledge/*`, `.codebase/rules/*`, `.codebase/examples/*`, or agent entry files outside the suggestion bundle.

6. Summarize outcome.
   - Report the suggestion id and review summary path.
   - State confidence for framework, UI, module granularity, and Page Recipe candidates.
   - State the apply command: `ariadne-apply-suggestion <id>`.

## Runtime Docs To Propose

The bootstrap bundle should propose this Practical Core structure when evidence permits:

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
- applying changes would be required; this skill may only suggest.

## Validation Checklist

Before finishing:

- The suggestion has both JSON and Markdown review summary.
- The JSON follows the v1 Suggestion Schema.
- Every operation is `create`, `replace`, or `patch`.
- Runtime Docs are only proposed inside the bundle.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
- Low-confidence framework, UI, module granularity, or Page Recipe findings remain candidates.
