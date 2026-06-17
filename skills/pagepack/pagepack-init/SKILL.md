---
name: pagepack-init
description: Create the initial lightweight `.codebase/` Runtime Docs when no pack exists. Generates router, knowledge, rules, and examples for management-system frontend projects.
---

# Pagepack Init

## Overview

Use this skill to create the initial `.codebase/` Codebase Knowledge Pack when no `.codebase/` exists. This is the only capability that writes `.codebase/` directly; it creates only Runtime Docs and does not produce a manifest, evidence artifacts, suggestion bundles, or candidate files.

`.codebase/` is treated as local output and should normally be gitignored. Generated human-facing content must use the user's preferred language. If unspecified, default to English. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before creating an initial pack, read `references/shared-contracts.md`. It defines bootstrap rules, source classes, router routes, and output requirements.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user to provide `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Inspect existing pack state.
   - If no `.codebase/` exists, continue with Direct Pack Bootstrap.
   - If `.codebase/` already exists, stop and recommend reviewing or regenerating it manually.

3. Collect Bootstrap Source Minimum.
   - Project identity: `package.json`, lockfile, TypeScript/build config.
   - Routing/page entries: routes, pages/views/modules, menu config.
   - Framework Authority: framework package metadata, type declarations, exports, official/internal docs when available.
   - Project Usage: imports, JSX usage, hooks, wrappers, request/service patterns.
   - UI/style usage: UI components, wrappers, stylesheets, `className`, inline styles.
   - Module granularity: page directory layout, services, hooks, constants, schemas, types.
   - Never read or quote secret-bearing files.

4. Build observed knowledge.
   - Use Framework Authority to verify API existence; use Project Usage to identify default project paths and wrappers.
   - Treat missing Framework Authority as a detection uncertainty, not as confirmed API guidance.
   - Separate observed knowledge from coding rules.

5. Directly create the initial Runtime Docs.
   - Prepare router, knowledge, rules, and high-confidence examples before writing.
   - Create the complete Practical Core structure in one bootstrap pass.
   - Write `.codebase/router.md`, `.codebase/knowledge/*`, `.codebase/rules/*`, and high-confidence `.codebase/examples/page-types/*` when evidence permits.
   - Do not create `meta/`, `manifest.json`, evidence files, suggestion bundles, or candidate files.
   - Do not modify `AGENTS.md` or `CLAUDE.md`.

6. Summarize outcome.
   - Report created files and any skipped areas.
   - State confidence for framework, UI, module granularity, and Page Recipe findings.
   - State recommended next commands: `pagepack-suggest-adapters` if adapter setup is needed.

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
```

## Failure Rules

Stop instead of guessing when:

- Agent Scope is unknown.
- Bootstrap Source Minimum is too weak to form a credible pack.
- `.codebase/` already exists.
- framework API guidance would require inventing unverified APIs.

## Validation Checklist

Before finishing:

- `.codebase/router.md` and at least the core Runtime Docs exist after bootstrap.
- No `meta/`, `manifest.json`, evidence, suggestion, or candidate files were created.
- Agent entry files were not modified.
- Human-facing output uses the user's preferred language, defaulting to English, with technical proper nouns preserved.
- Low-confidence framework, UI, module granularity, or Page Recipe findings are reported honestly rather than promoted to Runtime Rules.
