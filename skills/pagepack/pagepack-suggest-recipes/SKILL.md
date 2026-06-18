---
name: pagepack-suggest-recipes
description: Discover recurring management-system page types and output directly applicable patches for `.codebase/examples/page-types/*.md`. No persistent suggestion bundles.
---

# Pagepack Suggest Recipes

## Overview

Use this skill to discover recurring page implementation patterns and propose Page Recipe updates. It outputs directly applicable unified diffs for `.codebase/examples/page-types/*.md`, without writing JSON/MD suggestion bundles under `.codebase/`.

Generated human-facing output must use the user's preferred language. If unspecified, default to English. Preserve file paths, command names, API names, framework names, identifiers, component names, page type names, and other technical proper nouns.

## Required Reference

Before creating recipe patches, read `references/recipe-contracts.md`. It defines Page Recipe requirements, Representative Page selection, Confidence Gate behavior, source references, and patch output rules.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Load existing Runtime Docs.
   - Read `.codebase/router.md` and existing `.codebase/examples/page-types/*.md` when present.
   - Read `.codebase/knowledge/*.md` for context.
   - If `.codebase/` is missing, stop and recommend `pagepack-init`.

3. Discover recurring page types.
   - Identify management-system page types such as list/table pages, form pages, detail pages, modal/drawer operations, import/export flows, dashboards, or workflow pages.
   - Use project source such as route/page entries, imports, JSX components, framework hooks, request calls, style usage, and file layout.
   - Do not classify based on filename alone.
   - If the current agent runtime supports subagents, spawn `pagepack-overview-agent` and `pagepack-ui-agent` in parallel to collect route and UI signals. Otherwise, perform the search inline.

4. Select Representative Page candidates.
   - Prefer real pages that are typical, complete, simple, recent when evidence exists, and aligned with framework/project wrappers.
   - Penalize one-off pages, legacy patterns, excessive custom styles, deprecated APIs, or unusually complex business flows.
   - Every candidate must include source references.

5. Apply Confidence Gate.
   - High confidence can propose `examples/page-types/*.md` Runtime Docs.
   - Medium/low confidence should be reported in the summary and skipped from patch output unless explicitly requested.
   - Do not promote a recipe if source evidence is sparse or conflicting.

6. Output the patch.
   - Present unified diffs for proposed `examples/page-types/*.md` files.
   - Include optional `baseHash` for existing files.
   - Do not write files under `.codebase/` directly.

7. Report result.
   - Summarize discovered page types, Representative Page candidates, confidence, source references, and proposed files.
   - Include apply instruction: use `pagepack-apply-suggestion` with the provided patch, or apply the diff directly if reviewed.

## Trailing Prompt Guidance

If the user provides trailing text after `pagepack-suggest-recipes`, treat it as directional guidance. Examples:

- `pagepack-suggest-recipes focus on list pages with filters`
- `pagepack-suggest-recipes only dashboard patterns`

The output must still be concrete, applicable patch/diffs, not a freeform conversation response.

## Recipe Boundaries

Page Recipes are compact project-derived implementation patterns. They are not:

- generic templates;
- scaffold generators;
- copied full production modules;
- LLM-invented examples;
- replacements for Coding Rules.

Each recipe should explain:

- when to use it;
- canonical shape;
- minimal implementation shape when evidence supports it;
- source files;
- confidence;
- known caveats or legacy risks.

## Out Of Scope

Do not:

- directly create or edit `examples/page-types/*.md`;
- generate recipes without source references;
- infer framework APIs that are not evidenced;
- promote low-confidence candidates into Runtime Docs;
- perform full Representative Page scoring models;
- rewrite existing pages;
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
- Every proposed recipe has source references.
- Low-confidence candidates were reported but not promoted to patch output unless requested.
- No Runtime Doc was directly modified.
- No template was invented without evidence.
- Trailing prompt guidance was respected if provided.
- Human-facing output uses the user's preferred language, defaulting to English, with technical proper nouns preserved.
