---
name: pagepack-init
description: Create the initial lightweight `.codebase/` Runtime Docs when no pack exists. Generates router, knowledge, rules, and examples for management-system frontend projects.
---

# Pagepack Init

## Overview

Use this skill to create the initial `.codebase/` Codebase Knowledge Pack when no `.codebase/` exists. This is the only capability that writes `.codebase/` directly; it creates only Runtime Docs and does not produce a manifest, evidence artifacts, suggestion bundles, or candidate files.

Pack lifecycle, versioning guidance, and the Language Policy are defined in the shared contracts.

## Required Reference

Before creating an initial pack, read `references/shared-contracts.md` (family-wide contracts) and `references/init-contracts.md` (bootstrap rules, source classes, router routes, and output requirements).

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user to provide `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Inspect existing pack state.
   - If no `.codebase/` exists, continue with Direct Pack Bootstrap.
   - If `.codebase/` already exists, stop and recommend `pagepack-suggest-knowledge` for stale knowledge, `pagepack-suggest-recipes` / `pagepack-suggest-rules` for additions, and `pagepack-check-pack` for integrity review.

3. Collect Bootstrap Source Minimum.
   - If the current agent runtime supports subagents, spawn the following knowledge agents in parallel. Each returns a structured summary for one knowledge dimension; otherwise perform the searches inline.
     - `pagepack-overview-agent`: project identity, routing/page entries, menu config.
     - `pagepack-framework-agent`: framework package metadata, exports, project wrapper/hook/service usage, deprecated API risks.
     - `pagepack-ui-agent`: UI components, wrappers, page compositions, style distribution, UI Anti-Pattern candidates.
     - `pagepack-granularity-agent`: page directory layout, file splits, locations of services/hooks/constants/schemas/types.
   - If running inline, still cover all four dimensions above.
   - Never read or quote secret-bearing files.

4. Build observed knowledge.
   - Use Framework Authority to verify API existence; use Project Usage to identify default project paths and wrappers.
   - Treat missing Framework Authority as a detection uncertainty, not as confirmed API guidance.
   - Separate observed knowledge from coding rules.

5. Directly create the initial Runtime Docs.
   - Synthesize the four knowledge summaries into `.codebase/knowledge/*.md`.
   - Derive `.codebase/rules/*.md` directly from the knowledge summaries and Confidence Gate. The main agent holds full context for rule synthesis; do not spawn a separate rules subagent.
   - Prepare router and high-confidence examples before writing.
   - Create the complete Practical Core structure in one bootstrap pass.
   - Write `.codebase/router.md` (starting with the pack version marker), `.codebase/knowledge/*`, `.codebase/rules/*`, and high-confidence `.codebase/examples/page-types/*` (plus `examples/behaviors/*` when cross-cutting behavior evidence is high-confidence).
   - Wire every created `examples/` document into at least one router route (Router Coverage Invariant).
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
    behaviors/
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
- Every created `examples/` document is explicitly wired into at least one router route.
- No `meta/`, `manifest.json`, evidence, suggestion, or candidate files were created.
- Agent entry files were not modified.
- Human-facing output uses the user's preferred language, defaulting to English, with technical proper nouns preserved.
- Low-confidence framework, UI, module granularity, or Page Recipe findings are reported honestly rather than promoted to Runtime Rules.
