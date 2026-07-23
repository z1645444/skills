# Pagepack Knowledge Contracts

This reference defines the contract for Observed Knowledge refresh patches. Read `../../pagepack-init/references/shared-contracts.md` first for Agent Scope, Pack Lifecycle, Suggestion Cache Protocol, Router Coverage Invariant, and Language Policy.

## Scope

`pagepack-suggest-knowledge` refreshes an existing pack. It does not bootstrap packs, does not write suggestion bundles under `.codebase/`, and does not directly modify Runtime Docs.

It reads:

- `.codebase/router.md`;
- all `.codebase/knowledge/*.md`;
- project source for fresh evidence (same source classes as the Bootstrap Source Minimum in the init contracts).

It outputs:

- minimal unified diff patch blocks for stale `.codebase/knowledge/*.md` facts;
- `router.md` structural repair hunks;
- `baseHash` for every existing file touched;
- a concise human-facing summary including suspected-but-unproven staleness.

## Staleness Definition

A fact in a knowledge doc is stale only when current evidence contradicts it:

```text
stale
  referenced file/directory no longer exists
  recorded version differs from current package metadata
  recorded route/entry no longer present in routing source
  recorded component/wrapper no longer exported or used
  recorded command no longer defined in package scripts

not stale
  fact is still supported, but could be phrased differently
  fact covers an area the refresh did not re-verify
  fact is hand-written commentary without a checkable claim
```

Missing coverage is a second patch class: a load-bearing project change (new app, new shared capability, new routing entry class) with no mention in any knowledge doc may be added as a new fact under the fitting existing section.

## Conservative Merge

Curated packs contain hand-written content that must survive refresh:

- patch the smallest span that fixes the stale fact;
- never regenerate a document, section order, or heading structure;
- keep untouched lines byte-identical — no reformatting, reflowing, or translation;
- when a hand-written claim cannot be verified either way, report it in the summary as suspected-stale; do not patch it;
- when a whole document has drifted beyond fact-level patching, report that finding and recommend a manual rewrite; do not attempt it in patch output.

## Router Repair Scope

Router repair enforces the Router Coverage Invariant and dead-link hygiene:

```text
unrouted document
  an examples/ doc not explicitly listed by any route
  -> add its path under the fitting existing route(s)

dead route link
  a router line pointing to a nonexistent document
  -> remove the line

out of scope
  new route types, route reordering, route description rewrites,
  knowledge/rules link redesign
```

When no existing route fits an unrouted document, report it instead of inventing a route.

## Patch Output Format

The skill outputs one combined unified diff. Example:

```diff
--- .codebase/knowledge/overview.md
+++ .codebase/knowledge/overview.md
@@ -4,7 +4,7 @@
 ## Project Identity

-- Tech stack: `React 18`, `TypeScript`, `Vite`
+- Tech stack: `React 19`, `TypeScript`, `Vite`
--- .codebase/router.md
+++ .codebase/router.md
@@ -30,7 +30,6 @@
 ## Page Feature Iteration

 - Read `.codebase/examples/page-types/list-page.md`
-- Read `.codebase/examples/page-types/removed-doc.md`
```

Include `baseHash` for every touched file.

## Confidence Gate

```text
patchable
  contradiction is directly checkable against current source
  (path existence, package metadata, export presence, route presence)

summary only
  contradiction is inferred, partial, or depends on unverified assumptions
```

Never promote summary-only findings into patch output.

## Trailing Prompt Guidance

Trailing text narrows the refresh. Examples:

- `pagepack-suggest-knowledge focus on framework versions`
- `pagepack-suggest-knowledge only router repairs`

The output must still be concrete patch/diffs.

## Blocking Conditions

Block or report no-op when:

- Agent Scope is unknown;
- `.codebase/` is missing;
- fresh evidence is too weak to judge staleness;
- all detected differences are summary-only.
