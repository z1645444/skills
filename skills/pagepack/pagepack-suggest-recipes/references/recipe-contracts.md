# Pagepack Recipe Contracts

This reference defines the v1 suggestion contract for Page Recipe Candidates. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, page type names, and suggestion ids.

## Scope

`pagepack-suggest-recipes` discovers and proposes Page Recipe Candidates. It may write suggestion JSON/MD under `.codebase/meta/suggestions/`, but it must not directly modify Runtime Docs.

It reads:

- `.codebase/meta/manifest.json` when present;
- page inventory evidence;
- project usage evidence;
- UI usage evidence;
- module granularity evidence;
- existing `examples/page-types/` docs when present.

It writes:

- `.codebase/meta/suggestions/recipes-*.json`;
- `.codebase/meta/suggestions/recipes-*.md`.

## Agent Scope

Every Pagepack capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple packs or per-agent recipes.

## Evidence Requirements

Do not create a recipe candidate without source references.

Useful evidence:

```text
page inventory
  route entries, page files, menu entries, page names

project usage
  imports, JSX usage, hooks, request calls, wrapper components

UI usage
  table/form/modal/drawer/detail components, className, stylesheets

module granularity
  file layout, services, hooks, constants, schemas, types
```

One example is a lead, not a rule. Mixed evidence should reduce confidence.

## Page Types

Common management-system page types:

```text
list-page
form-page
detail-page
modal-operation
drawer-operation
import-export
dashboard
workflow-page
```

Do not classify from file name alone. Use multiple signals such as component usage, route role, data requests, and module layout.

## Representative Page Selection

Representative Page candidates should be real source pages that are:

- typical of similar pages;
- complete enough to show the implementation shape;
- simple enough to generalize;
- aligned with framework APIs and project wrappers;
- recent when history evidence exists;
- not dominated by one-off business rules.

Penalize:

- excessive custom styles;
- deprecated framework APIs;
- direct use of underlying libraries when project wrappers are standard;
- copied demo code;
- unusually large or special-case modules;
- conflicting patterns.

v1 does not implement a full scoring model. Use explicit evidence and confidence labels.

## Confidence Gate

```text
high confidence
  Several similar current pages agree on shape, source references are clear, and representative page is aligned with framework/project wrappers.
  May propose Runtime Doc under .codebase/examples/page-types/*.md.

medium confidence
  Pattern is visible but evidence is limited or mixed.
  Must stay under .codebase/meta/candidates/page-recipes.md or review-only suggestion.

low confidence
  Too few pages, conflicting implementation, or weak references.
  Report as lead or blocked candidate; do not create recipe doc.
```

Do not promote Page Recipe Candidates into Runtime Docs unless they pass the Confidence Gate.

## Candidate Content

A candidate should include:

- page type;
- when to use;
- observed canonical shape;
- Representative Page candidates;
- source references;
- confidence;
- evidence summary;
- caveats and legacy risks;
- whether it is recommended for Runtime Docs.

Avoid large code dumps. If a minimal snippet is included, it must be derived from real source patterns and kept compact.

## Suggestion Schema

Recipe suggestions use the standard v1 schema:

```json
{
  "schemaVersion": "1.0.0",
  "id": "recipes-20260610-001",
  "type": "recipe-candidate",
  "createdAt": "2026-06-10T10:00:00Z",
  "createdBy": "pagepack-suggest-recipes",
  "agentScope": ["codex"],
  "risk": "medium",
  "sourceFingerprints": {},
  "targetPreconditions": [],
  "operations": [],
  "reviewSummaryPath": ".codebase/meta/suggestions/recipes-20260610-001.md"
}
```

Allowed operation actions:

- `create`;
- `replace` for generated candidate files only with `baseHash`;
- `patch` for reviewed existing recipe docs.

## Operation Guidance

Use operations targeting `.codebase/meta/candidates/page-recipes.md` for:

- medium confidence candidates;
- low-confidence leads worth preserving;
- conflicting patterns;
- Representative Page candidates needing review.

Use operations targeting `.codebase/examples/page-types/*.md` only for:

- high-confidence recipes;
- clear source references;
- generated ownership or reviewed apply path.

If an existing example is reviewed/manual, do not replace it. Use patch or review suggestion.

## Review Summary

Markdown review summary should include:

- suggestion id;
- discovered page types;
- candidate count by confidence;
- Representative Page candidates;
- source references;
- high-confidence recipe docs proposed;
- candidates kept in cold path;
- risks and unresolved questions;
- apply instruction: `pagepack-apply-suggestion <id>`.

## Blocking Conditions

Block or report no-op when:

- Agent Scope is unknown;
- page inventory evidence is missing;
- source references are unavailable;
- there are too few similar pages for meaningful grouping;
- all candidates are legacy or one-off;
- candidate would require invented framework APIs or generated code not supported by source evidence.
