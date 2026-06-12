---
name: ariadne-suggest-rules
description: Generate reviewable Ariadne Coding Rule candidates for `.codebase/rules/ui.md`, `.codebase/rules/framework-api.md`, and `.codebase/rules/file-structure.md`. Use when observed knowledge, evidence artifacts, framework candidates, UI anti-patterns, or module granularity guidance should be proposed as reviewed Runtime Rules without automatically promoting legacy patterns or replacing curated rule files.
---

# Ariadne Suggest Rules

## Overview

Use this skill to propose Coding Rules updates from existing `.codebase/` knowledge and evidence. It may write rules suggestion JSON/MD under `.codebase/meta/suggestions/`, but must not directly modify Runtime Rules or promote low-confidence observations into required agent behavior.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, rule target names, and other technical proper nouns.

## Required Reference

Before creating rule suggestions, read `references/rule-contracts.md`. It defines rule targets, ownership behavior, candidate promotion rules, Component-First UI boundaries, framework candidate handling, and suggestion output requirements.

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Select rule target.
   - `ui` targets `.codebase/rules/ui.md`.
   - `framework-api` targets `.codebase/rules/framework-api.md`.
   - `file-structure` targets `.codebase/rules/file-structure.md`.
   - If no target is specified, evaluate all three Practical Core rule areas.

3. Load pack evidence.
   - Read `.codebase/meta/manifest.json` and file ownership map.
   - Read `knowledge/*` relevant to the target.
   - Read Evidence Artifacts.
   - Read existing `rules/*.md`.
   - Read `meta/candidates/*` when present.
   - Stop or report blocked candidates if evidence is missing.

4. Separate observations from rules.
   - Observed Knowledge describes current code.
   - Coding Rules express expected agent behavior.
   - High-frequency legacy code is not automatically a rule.
   - Low-confidence observations stay in candidates.

5. Generate rule candidates.
   - UI candidates should enforce Component-First UI and UI Decision Ladder.
   - Framework candidates should prevent invented APIs, wrong import paths, bypassed wrappers, or unchecked deprecated APIs.
   - File-structure candidates should turn Module Granularity Profile into Granularity Guidance without auto-refactor rules.
   - Framework best practices and deprecated migrations remain Framework Candidates until reviewed.

6. Build suggestion operations.
   - Runtime `rules/*.md` are `reviewed` by default.
   - Use `patch` for existing reviewed/manual rule files.
   - Use `create` only when a rule file is missing and target path is unambiguous.
   - Do not use `replace` for Runtime Rules in v1.
   - Put uncertain candidates under `meta/candidates/*`.

7. Write suggestion artifacts.
   - Write `.codebase/meta/suggestions/rules-*.json`.
   - Write `.codebase/meta/suggestions/rules-*.md`.
   - Do not directly modify Runtime Rules, candidates, manifest, or evidence outside suggestion operations.

8. Report result.
   - Summarize target rules, candidate count, confidence, risks, blocked promotions, and suggestion id.
   - Include apply instruction: `ariadne-apply-suggestion <id>`.

## Rule Promotion Boundaries

Promote only when:

- evidence is current and source-backed;
- rule expresses desired agent behavior, not merely current code state;
- rule does not conflict with confirmed Ariadne suite rules;
- rule is scoped to a Practical Core target;
- user/team review is expected before Runtime Rule application.

Do not promote:

- legacy patterns;
- one-off page choices;
- high-frequency custom CSS that bypasses components;
- deprecated framework APIs;
- unverified framework best practices;
- file splitting based only on line count.

## Out Of Scope

Do not:

- directly edit `rules/*.md`;
- replace reviewed/manual rule files;
- generate Page Recipes;
- perform framework migration;
- perform UI redesign or screenshot audit;
- perform automatic refactoring;
- apply suggestions.

## Failure Rules

Stop or report blocked candidates when:

- Agent Scope is unknown.
- requested rule target is unsupported.
- evidence for requested target is missing.
- target rule file ownership blocks safe update.
- candidate would promote low-confidence or legacy pattern.
- candidate requires framework API claims that are not evidenced.

## Validation Checklist

Before finishing:

- Suggestion JSON and Markdown summary were written under `.codebase/meta/suggestions/`.
- No Runtime Rule was directly modified.
- Existing Runtime Rules are patched, not replaced.
- Low-confidence observations remain candidates.
- Framework best practice and deprecated migration remain candidates unless reviewed.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
