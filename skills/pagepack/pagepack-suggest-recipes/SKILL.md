---
name: pagepack-suggest-recipes
description: Discover recurring management-system page types and cross-cutting behavior conventions, then output directly applicable patches for `.codebase/examples/**/*.md` with router wiring included. No persistent suggestion bundles.
---

# Pagepack Suggest Recipes

## Overview

Use this skill to discover recurring page implementation patterns and propose Page Recipe or Behavior Recipe updates. It outputs directly applicable unified diffs for `.codebase/examples/page-types/*.md` and `.codebase/examples/behaviors/*.md`, including the `router.md` wiring hunks required by the Router Coverage Invariant, without writing JSON/MD suggestion bundles under `.codebase/`.

## Required Reference

Before creating recipe patches, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/recipe-contracts.md` (Page Recipe requirements, Representative Page selection, Confidence Gate behavior, Router Sync Rule, and patch output rules).

## Workflow

1. Resolve Agent Scope per the shared contracts. If the current agent is unknown and no explicit scope is provided, stop and ask.

2. Load existing Runtime Docs.
   - Read `.codebase/router.md` and existing `.codebase/examples/**/*.md` when present.
   - Read `.codebase/knowledge/*.md` for context.
   - If `.codebase/` is missing, stop and recommend `pagepack-init`.

3. Discover recurring patterns.
   - Page types: list/table pages, form pages, detail pages, modal/drawer operations, import/export flows, dashboards, or workflow pages.
   - Behavior conventions: cross-cutting behaviors shared by multiple page types, such as query/table behavior, request lifecycle, or interaction constraints.
   - Use project source such as route/page entries, imports, JSX components, framework hooks, request calls, style usage, and file layout.
   - Do not classify based on filename alone.
   - If the current agent runtime supports subagents, spawn the corresponding knowledge subagents from the runtime adapter directory (e.g., `.claude/agents/pagepack-overview-agent.md` and `.claude/agents/pagepack-ui-agent.md` for Claude Code) in parallel to collect route and UI signals. Otherwise, perform the search inline.

4. Select Representative Page candidates.
   - Prefer real pages that are typical, complete, simple, recent when evidence exists, and aligned with framework/project wrappers.
   - Penalize one-off pages, legacy patterns, excessive custom styles, deprecated APIs, or unusually complex business flows.
   - Every candidate must include source references.

5. Apply Confidence Gate.
   - High confidence can propose `examples/page-types/*.md` or `examples/behaviors/*.md` Runtime Docs.
   - Medium/low confidence should be reported in the summary and skipped from patch output unless explicitly requested.
   - Do not promote a recipe if source evidence is sparse or conflicting.

6. Output the patch.
   - Present unified diffs for proposed `examples/**/*.md` files.
   - Apply the Router Sync Rule: when the patch creates, deletes, or renames a document, include `router.md` hunks in the same combined diff that wire it into (or remove it from) existing routes.
   - Include `baseHash` for every existing file touched by the patch.
   - Do not write files under `.codebase/` directly.

7. Cache the last suggestion per the shared Suggestion Cache Protocol: write the combined unified diff to `.codebase/.last-suggestion.diff` and the `baseHash` lines for touched existing files to `.codebase/.last-suggestion.meta`, overwriting both.

8. Report result.
   - Summarize discovered patterns, Representative Page candidates, confidence, source references, and proposed files.
   - Include apply instruction: run `pagepack-apply-suggestion` without a patch to apply the cached suggestion from `.codebase/.last-suggestion.diff`, or provide the explicit patch if you want to override.

## Trailing Prompt Guidance

If the user provides trailing text after `pagepack-suggest-recipes`, treat it as directional guidance. Examples:

- `pagepack-suggest-recipes focus on list pages with filters`
- `pagepack-suggest-recipes only dashboard patterns`
- `pagepack-suggest-recipes extract shared table behaviors`

The output must still be concrete, applicable patch/diffs, not a freeform conversation response.

## Recipe Boundaries

Page Recipes are compact project-derived implementation patterns for a recurring page shape. Behavior Recipes are compact project-derived conventions that cut across page shapes. Neither is:

- a generic template;
- a scaffold generator;
- a copied full production module;
- an LLM-invented example;
- a replacement for Coding Rules.

Each recipe should explain:

- when to use it;
- canonical shape;
- minimal implementation shape when evidence supports it;
- source files;
- confidence;
- known caveats or legacy risks.

## Out Of Scope

Do not:

- directly create or edit `examples/**/*.md` or `router.md`;
- generate recipes without source references;
- infer framework APIs that are not evidenced;
- promote low-confidence candidates into Runtime Docs;
- perform full Representative Page scoring models;
- rewrite existing pages;
- invent new router route types;
- apply suggestions.

## Failure Rules

Stop or report blocked recipe generation when:

- Agent Scope is unknown.
- `.codebase/` is missing.
- project source is too weak for meaningful grouping.
- source references are unavailable.
- candidate representative pages are mostly legacy, one-off, or conflicting.

## Validation Checklist

Before finishing:

- A concrete unified diff was output for each proposed recipe file.
- Every created, deleted, or renamed `examples/` document has matching `router.md` wiring hunks in the same combined diff (Router Coverage Invariant).
- Every existing file touched by the patch has a `baseHash`.
- Confirm the complete unified diff was written to `.codebase/.last-suggestion.diff` before finishing.
- Every proposed recipe has source references.
- Low-confidence candidates were reported but not promoted to patch output unless requested.
- No Runtime Doc was directly modified.
- No template was invented without evidence.
- Trailing prompt guidance was respected if provided.
- Human-facing output follows the shared Language Policy.
