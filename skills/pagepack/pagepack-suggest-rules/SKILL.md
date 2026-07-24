---
name: pagepack-suggest-rules
description: Generate directly applicable patch recommendations for `.codebase/rules/ui.md`, `.codebase/rules/framework-api.md`, and `.codebase/rules/file-structure.md`. No persistent suggestion bundles.
---

# Pagepack Suggest Rules

## Overview

Use this skill to propose Coding Rules updates. It outputs directly applicable unified diffs for `.codebase/rules/*.md`, without writing JSON/MD suggestion bundles under `.codebase/`.

## Required Reference

Before creating rule patches, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/rule-contracts.md` (rule targets, candidate promotion rules, Component-First UI boundaries, framework candidate handling, and patch output requirements).

## Workflow

1. Resolve Agent Scope per the shared contracts. If the current agent is unknown and no explicit scope is provided, stop and ask.

2. Select rule target.
   - `ui` targets `.codebase/rules/ui.md`.
   - `framework-api` targets `.codebase/rules/framework-api.md`.
   - `file-structure` targets `.codebase/rules/file-structure.md`.
   - If no target is specified, evaluate all three Practical Core rule areas.

3. Load pack context.
   - Read `.codebase/router.md` and `.codebase/knowledge/*` relevant to the target.
   - Read existing `rules/*.md`.
   - If `.codebase/` is missing, stop and recommend `pagepack-init`.

4. Separate observations from rules.
   - Observed Knowledge describes current code.
   - Coding Rules express expected agent behavior.
   - High-frequency legacy code is not automatically a rule.
   - Low-confidence observations stay in the summary, not in patch output.

5. Generate rule patches.
   - UI patches should reinforce Component-First UI and UI Decision Ladder.
   - Framework patches should prevent invented APIs, wrong import paths, bypassed wrappers, or unchecked deprecated APIs.
   - File-structure patches should turn Module Granularity Profile into Granularity Guidance without auto-refactor rules.
   - Framework best practices and deprecated migrations remain candidates unless evidence is strong.

6. Output the patch.
   - Present unified diffs for affected `.codebase/rules/*.md` files.
   - Use `patch` semantics for existing rule files.
   - Use `create` semantics for missing rule files; when creating a rule file, include `router.md` hunks in the same combined diff that wire it into the relevant existing routes.
   - Include `baseHash` for every existing file touched by the patch.
   - Do not write files under `.codebase/` directly.

7. Cache the last suggestion per the shared Suggestion Cache Protocol: write the combined unified diff to `.codebase/.last-suggestion.diff` and the `baseHash` lines for touched existing files to `.codebase/.last-suggestion.meta`, overwriting both.

8. Report result.
   - Summarize target rules, confidence, risks, blocked promotions, and affected files.
   - Include apply instruction: run `pagepack-apply-suggestion` without a patch to apply the cached suggestion from `.codebase/.last-suggestion.diff`, or provide the explicit patch if you want to override.

## Trailing Prompt Guidance

If the user provides trailing text after `pagepack-suggest-rules`, treat it as directional guidance. Examples:

- `pagepack-suggest-rules focus on forms and tables`
- `pagepack-suggest-rules add rules about API error handling`
- `pagepack-suggest-rules for the admin module only`

The output must still be concrete, applicable patch/diffs, not a freeform conversation response.

## Rule Promotion Boundaries

Promote only when:

- evidence is current and source-backed;
- rule expresses desired agent behavior, not merely current code state;
- rule does not conflict with existing reviewed rules;
- rule is scoped to a Practical Core target;
- user review is expected before rule application.

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
- replace reviewed/manual rule files wholesale;
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
- candidate would promote legacy or low-confidence pattern.
- candidate requires framework API claims that are not evidenced.

## Validation Checklist

Before finishing:

- A concrete unified diff was output for each affected rule file.
- Newly created rule files have matching `router.md` wiring hunks in the same combined diff.
- Every existing file touched by the patch has a `baseHash`.
- Confirm the complete unified diff was written to `.codebase/.last-suggestion.diff` before finishing.
- No Runtime Rule was directly modified.
- Existing Runtime Rules are patched, not replaced wholesale.
- Low-confidence observations remain in the summary, not patch output.
- Framework best practice and deprecated migration remain candidates unless evidence is strong.
- Trailing prompt guidance was respected if provided.
- Human-facing output follows the shared Language Policy.
