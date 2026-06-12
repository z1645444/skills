---
name: ariadne-suggest-recipes
description: Generate reviewable Ariadne Page Recipe Candidates from existing page inventory, project usage, UI usage, and module granularity evidence. Use when recurring management-system page types need candidate recipes, Representative Page suggestions, confidence summaries, and source references without inventing templates or directly modifying Runtime Docs.
---

# Ariadne Suggest Recipes

## Overview

Use this skill to discover recurring page implementation patterns and propose Page Recipe Candidates. It may write recipe suggestion JSON/MD under `.codebase/meta/suggestions/`, but must not directly modify Runtime Docs or promote low-confidence examples into `examples/page-types/`.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, page type names, and other technical proper nouns.

## Required Reference

Before creating recipe suggestions, read `references/recipe-contracts.md`. It defines Page Recipe Candidate requirements, Representative Page selection, Confidence Gate behavior, source references, and suggestion output rules.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Load pack and evidence.
   - Read `.codebase/meta/manifest.json` when present.
   - Read page inventory evidence.
   - Read project usage evidence.
   - Read UI usage evidence.
   - Read module granularity evidence.
   - Read existing `examples/page-types/` when present.
   - If evidence is missing, stop or generate a blocked summary rather than inventing recipes.

3. Discover recurring page types.
   - Identify management-system page types such as list/table pages, form pages, detail pages, modal/drawer operations, import/export flows, dashboards, or workflow pages.
   - Use feature evidence such as route/page entries, imports, JSX components, framework hooks, request calls, style usage, and file layout.
   - Do not classify based on filename alone.

4. Select Representative Page candidates.
   - Prefer real pages that are typical, complete, simple, recent when evidence exists, and aligned with framework/project wrappers.
   - Penalize one-off pages, legacy patterns, excessive custom styles, deprecated APIs, or unusually complex business flows.
   - Every candidate must include source references.

5. Apply Confidence Gate.
   - High confidence can propose `examples/page-types/*.md` Runtime Docs.
   - Medium/low confidence stays in `.codebase/meta/candidates/page-recipes.md` or review-only suggestions.
   - Do not promote a recipe if source evidence is sparse or conflicting.

6. Write suggestion artifacts.
   - Write `.codebase/meta/suggestions/recipes-*.json`.
   - Write `.codebase/meta/suggestions/recipes-*.md`.
   - Use operations targeting `meta/candidates/page-recipes.md` for normal candidates.
   - Use operations targeting `examples/page-types/*.md` only for high-confidence recipes.
   - Do not directly modify Runtime Docs.

7. Report result.
   - Summarize discovered page types, Representative Page candidates, confidence, source references, and suggestion id.
   - Include apply instruction: `ariadne-apply-suggestion <id>`.

## Recipe Boundaries

Page Recipes are compact project-derived implementation patterns. They are not:

- generic templates;
- scaffold generators;
- copied full production modules;
- LLM-invented examples;
- replacements for Coding Rules.

Each recipe candidate should explain:

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

Stop or report blocked candidate generation when:

- Agent Scope is unknown.
- page inventory evidence is missing.
- project usage, UI usage, or module granularity evidence is too weak.
- there are too few similar pages for meaningful grouping.
- source references are unavailable.
- candidate representative pages are mostly legacy, one-off, or conflicting.

## Validation Checklist

Before finishing:

- Suggestion JSON and Markdown summary were written under `.codebase/meta/suggestions/`.
- Every candidate has source references.
- Ordinary candidates target `meta/candidates/page-recipes.md`.
- Only high-confidence candidates target `examples/page-types/*.md`.
- No Runtime Doc was directly modified.
- No template was invented without evidence.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
