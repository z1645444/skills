# Pagepack Recipe Contracts

This reference defines the contract for Page Recipe and Behavior Recipe patches. Read `../../pagepack-init/references/shared-contracts.md` first for Agent Scope, Pack Lifecycle, Suggestion Cache Protocol, Router Coverage Invariant, and Language Policy.

## Scope

`pagepack-suggest-recipes` discovers and proposes recipe updates. It does not write suggestion bundles under `.codebase/` and does not directly modify Runtime Docs.

It reads:

- `.codebase/router.md`;
- existing `.codebase/examples/**/*.md` docs when present;
- `.codebase/knowledge/*.md` for context;
- project source for evidence.

It outputs:

- unified diff patch blocks for `.codebase/examples/page-types/*.md` and `.codebase/examples/behaviors/*.md`;
- `router.md` wiring hunks in the same combined diff whenever a document is created, deleted, or renamed (Router Sync Rule);
- `baseHash` for every existing file touched;
- a concise human-facing summary.

## Evidence Requirements

Do not create a recipe without source references.

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

## Doc Types

`examples/page-types/*.md` holds Page Recipes for recurring page shapes:

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

`examples/behaviors/*.md` holds Behavior Recipes for conventions that cut across page shapes, for example:

```text
query-table-behaviors     # first-query responsibility, range limits, column alignment
request-lifecycle         # dedup, retry, error surfacing conventions
interaction-constraints   # confirmation flows, unsaved-changes handling
```

Choose the doc type by scope: if the convention applies regardless of which page shape hosts it, it is a Behavior Recipe, not a section inside one Page Recipe. Do not let a Page Recipe accumulate cross-cutting behavior sections; propose extraction into a Behavior Recipe instead.

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
  May propose Runtime Doc under .codebase/examples/**/*.md.

medium confidence
  Pattern is visible but evidence is limited or mixed.
  Report in summary; do not include in patch output unless user explicitly asks for exploratory candidates.

low confidence
  Too few pages, conflicting implementation, or weak references.
  Report as lead or blocked candidate; do not create recipe doc.
```

Do not promote Recipe Candidates into Runtime Docs unless they pass the Confidence Gate.

## Recipe Content

A recipe should include:

- doc type (page type or behavior);
- when to use;
- observed canonical shape;
- Representative Page candidates;
- source references;
- confidence;
- evidence summary;
- caveats and legacy risks.

Avoid large code dumps. If a minimal snippet is included, it must be derived from real source patterns and kept compact.

Keep each fact in one authoritative document. When a fact is needed by several recipes (for example a shared component's size table), state it once in the owning document and reference it from the others; duplicated statements drift apart under curation.

## Router Sync Rule

The Router Coverage Invariant (shared contracts) requires every `examples/` document to be explicitly listed by at least one route in `router.md`.

Therefore:

- creating a document -> the same combined diff must add its path under at least one existing Practical Core route;
- deleting a document -> the same combined diff must remove its router lines;
- renaming a document -> both of the above.

Router hunks only add or remove document links under existing routes. They must not invent new route types, reorder routes, or rewrite route descriptions.

## Patch Output Format

The skill outputs one combined unified diff. For a new recipe file with its router wiring:

```diff
--- /dev/null
+++ .codebase/examples/page-types/list-page.md
@@ -0,0 +1,12 @@
+# List Page
+
+Use for pages that display a searchable, paginated table.
+
+## Canonical Shape
+
+- `SearchForm` + `PageTable` inside `PageContainer`.
+- `useList` hook for data fetching.
+- Columns defined in a separate `columns.tsx` when the table has more than five columns.
+
+## Source References
+
+- `src/pages/users/index.tsx`
--- .codebase/router.md
+++ .codebase/router.md
@@ -12,6 +12,7 @@
 ## Page Feature Iteration

 - Read `.codebase/rules/file-structure.md`
+- For searchable tables, read `.codebase/examples/page-types/list-page.md`
```

For existing files, include `baseHash`.

## Trailing Prompt Guidance

Trailing text narrows recipe discovery. Examples:

- `pagepack-suggest-recipes focus on list pages with filters`
- `pagepack-suggest-recipes only dashboard patterns`
- `pagepack-suggest-recipes extract shared table behaviors`

The output must still be concrete patch/diffs.

## Blocking Conditions

Block or report no-op when:

- Agent Scope is unknown;
- `.codebase/` is missing;
- source references are unavailable;
- there are too few similar pages for meaningful grouping;
- all candidates are legacy or one-off;
- candidate would require invented framework APIs or generated code not supported by source evidence.
