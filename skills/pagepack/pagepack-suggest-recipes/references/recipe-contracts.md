# Pagepack Recipe Contracts

This reference defines the contract for Page Recipe patches. Human-facing output uses the user's preferred language, defaulting to English; preserve file paths, command names, API names, framework names, component names, identifiers, page type names, and other technical proper nouns.

## Scope

`pagepack-suggest-recipes` discovers and proposes Page Recipe updates. It does not write suggestion bundles under `.codebase/` and does not directly modify Runtime Docs.

It reads:

- `.codebase/router.md`;
- existing `.codebase/examples/page-types/` docs when present;
- `.codebase/knowledge/*.md` for context;
- project source for evidence.

It outputs:

- unified diff patch blocks for `.codebase/examples/page-types/*.md`;
- optional `baseHash` for existing files;
- a concise human-facing summary.

## Agent Scope

Every Pagepack capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple packs or per-agent recipes.

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
  Report in summary; do not include in patch output unless user explicitly asks for exploratory candidates.

low confidence
  Too few pages, conflicting implementation, or weak references.
  Report as lead or blocked candidate; do not create recipe doc.
```

Do not promote Page Recipe Candidates into Runtime Docs unless they pass the Confidence Gate.

## Recipe Content

A recipe should include:

- page type;
- when to use;
- observed canonical shape;
- Representative Page candidates;
- source references;
- confidence;
- evidence summary;
- caveats and legacy risks.

Avoid large code dumps. If a minimal snippet is included, it must be derived from real source patterns and kept compact.

## Patch Output Format

The skill outputs unified diffs. For a new recipe file:

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
```

For existing files, include optional `baseHash`.

## Trailing Prompt Guidance

Trailing text narrows recipe discovery. Examples:

- `pagepack-suggest-recipes focus on list pages with filters`
- `pagepack-suggest-recipes only dashboard patterns`

The output must still be concrete patch/diffs.

## Blocking Conditions

Block or report no-op when:

- Agent Scope is unknown;
- `.codebase/` is missing;
- source references are unavailable;
- there are too few similar pages for meaningful grouping;
- all candidates are legacy or one-off;
- candidate would require invented framework APIs or generated code not supported by source evidence.
