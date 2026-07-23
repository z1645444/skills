---
name: pagepack-suggest-knowledge
description: Refresh stale Observed Knowledge in `.codebase/knowledge/*.md` and repair router structure for an existing pack. Outputs directly applicable patches; never rewrites hand-curated content wholesale.
---

# Pagepack Suggest Knowledge

## Overview

Use this skill to refresh Observed Knowledge for an existing `.codebase/` pack. It re-collects the four knowledge dimensions from current project source, compares them with the existing `knowledge/*.md` docs, and outputs minimal unified diffs for facts that have gone stale, plus `router.md` structural repair hunks when routes and documents have drifted apart.

This capability closes the maintenance gap left by `pagepack-init`, which only runs when no pack exists. It follows Conservative Merge: it patches facts, it does not regenerate documents.

## Required Reference

Before creating knowledge patches, read `../pagepack-init/references/shared-contracts.md` (family-wide contracts, resolved relative to this skill's directory; if the sibling path cannot be resolved, continue with this skill's own contract and state the missing shared contract in your report) and `references/knowledge-contracts.md` (staleness definition, Conservative Merge rules, router repair scope, and patch output rules).

## Workflow

1. Resolve Agent Scope per the shared contracts. If the current agent is unknown and no explicit scope is provided, stop and ask.

2. Load existing Runtime Docs.
   - Read `.codebase/router.md` and all `.codebase/knowledge/*.md`.
   - If `.codebase/` is missing, stop and recommend `pagepack-init`.

3. Re-collect knowledge dimensions.
   - If the current agent runtime supports subagents, spawn the knowledge agents in parallel, as in `pagepack-init`: `pagepack-overview-agent`, `pagepack-framework-agent`, `pagepack-ui-agent`, `pagepack-granularity-agent`. Otherwise perform the searches inline, covering all four dimensions.
   - Never read or quote secret-bearing files.

4. Detect staleness.
   - Compare each existing knowledge doc against fresh evidence.
   - A fact is stale when current Framework Authority or Project Usage contradicts it: removed paths, renamed modules, changed versions, dead route entries, components that no longer exist.
   - A fact is missing when a load-bearing project change (new app, new shared capability, new routing entry class) has no coverage.
   - Facts that are still supported by evidence are untouched, even if they could be phrased differently.

5. Repair router structure.
   - Detect `examples/` documents not explicitly listed by any route (Router Coverage Invariant) and propose wiring hunks under the fitting existing routes.
   - Detect router lines pointing to documents that no longer exist and propose removal hunks.
   - Do not invent new route types, reorder routes, or rewrite route descriptions.

6. Output the patch.
   - Present minimal unified diffs for affected `knowledge/*.md` and `router.md`.
   - Include `baseHash` for every existing file touched.
   - Do not write files under `.codebase/` directly.

7. Cache the last suggestion per the shared Suggestion Cache Protocol: write the complete combined unified diff to `.codebase/.last-suggestion.diff`, overwriting existing content.

8. Report result.
   - Summarize stale facts found, per-dimension confidence, router repairs, and untouched areas.
   - List suspected-stale facts that lacked strong enough evidence to patch; leave them out of patch output.
   - Include apply instruction: run `pagepack-apply-suggestion` without a patch to apply the cached suggestion from `.codebase/.last-suggestion.diff`, or provide the explicit patch if you want to override.

## Trailing Prompt Guidance

If the user provides trailing text after `pagepack-suggest-knowledge`, treat it as directional guidance. Examples:

- `pagepack-suggest-knowledge focus on framework versions`
- `pagepack-suggest-knowledge only router repairs`
- `pagepack-suggest-knowledge check the routing overview`

The output must still be concrete, applicable patch/diffs, not a freeform conversation response.

## Conservative Merge

Existing knowledge docs may contain hand-curated content. Therefore:

- patch individual stale facts; never regenerate a document wholesale;
- preserve document structure, headings, and hand-written sections that are still accurate;
- when unsure whether a hand-written fact is stale, report it in the summary instead of patching it;
- do not reformat, reorder, or translate untouched content.

## Out Of Scope

Do not:

- directly edit `knowledge/*.md` or `router.md`;
- create or modify `rules/*.md` (use `pagepack-suggest-rules`);
- create or modify `examples/**/*.md` (use `pagepack-suggest-recipes`);
- bootstrap a missing pack (use `pagepack-init`);
- invent facts or framework APIs not supported by evidence;
- apply suggestions.

## Failure Rules

Stop or report blocked refresh when:

- Agent Scope is unknown.
- `.codebase/` is missing.
- fresh evidence collection is too weak to judge staleness.
- every detected difference is below patch confidence.

## Validation Checklist

Before finishing:

- Every patched fact is backed by current source evidence.
- No document was regenerated wholesale; untouched content is byte-identical.
- Router hunks only add or remove document links under existing routes.
- Every existing file touched by the patch has a `baseHash`.
- Confirm the complete unified diff was written to `.codebase/.last-suggestion.diff` before finishing.
- Suspected-stale but unproven facts were reported, not patched.
- Trailing prompt guidance was respected if provided.
- Human-facing output follows the shared Language Policy.
