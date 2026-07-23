# Pagepack Shared Contracts

This reference is the family-wide contract for all Pagepack capabilities. Every `pagepack-*` skill must read this file before its capability-specific contract. From another skill directory, resolve it as `../pagepack-init/references/shared-contracts.md` relative to that skill's own directory; the Pagepack family is installed together, so this sibling path is stable.

## Agent Scope

Every Pagepack capability that writes or proposes changes needs an explicit Agent Scope.

- Default to the current agent only when it is reliably known.
- Use `--agent <codex|claude>` for a specific agent.
- Use `--all` only to expand agent compatibility or adapter scope.
- If current agent is unknown and no explicit scope is provided, stop and ask for scope.
- Agent Scope must not create agent-specific `.codebase-*` variants.
- Exception: `pagepack-check-pack` is read-only and agent-neutral; it runs without Agent Scope resolution.

## Single Pack Invariant

A repository has exactly one Codebase Knowledge Pack at `.codebase/`.

Do not create:

```text
.codebase-codex/
.codebase-claude/
```

## Pack Lifecycle

A pack has two states:

```text
Bootstrap
  No .codebase/ exists. pagepack-init creates Runtime Docs directly.
  This is the only direct-write path in the family.

Curated Maintenance
  .codebase/ exists. Pagepack-driven changes go through
  pagepack-suggest-* patches, reviewed and applied via
  pagepack-apply-suggestion. Maintainers may also hand-edit Runtime
  Docs directly; pagepack-check-pack keeps both channels honest.
```

A curated pack may be version-controlled (as its own git repository or committed to the host repository) and hand-edited by maintainers. Treat hand-written content as first-class:

- produce minimal diffs against current file content, never wholesale rewrites;
- always include `baseHash` for existing files;
- do not regenerate a document from scratch when patching a few facts is enough.

Gitignoring `.codebase/` remains valid for solo throwaway usage; version control is the recommended default once the pack accumulates hand-curated content.

## Suggestion Cache Protocol

Every `pagepack-suggest-*` capability, after presenting its patch:

- writes the complete unified diff to `.codebase/.last-suggestion.diff`;
- combines multiple file patches into one diff;
- overwrites existing cache content without prompting.

`.codebase/.last-suggestion.diff` is a tool runtime cache, not a Runtime Doc. Coding agents must not read or reference it during normal tasks. Only the most recent suggestion is cached; running another `pagepack-suggest-*` capability overwrites it. `pagepack-apply-suggestion` reads this cache when no explicit patch is provided.

## Router Coverage Invariant

Every Runtime Doc under `.codebase/examples/` must be explicitly reachable from `.codebase/router.md`: at least one route lists the document's own path. A directory-level mention does not count as explicit coverage.

Consequences:

- any patch that creates, deletes, or renames a document under `examples/` must include `router.md` hunks in the same combined diff so the invariant stays true;
- router hunks wire documents into existing Practical Core routes; they do not invent new route types;
- `pagepack-check-pack` enforces this invariant.

## Runtime Docs Ownership

Each Runtime Doc area has a named maintaining capability:

```text
.codebase/router.md
  wiring hunks: pagepack-suggest-recipes / pagepack-suggest-rules
  structural refresh: pagepack-suggest-knowledge

.codebase/knowledge/*.md
  pagepack-suggest-knowledge

.codebase/rules/*.md
  pagepack-suggest-rules

.codebase/examples/**/*.md
  pagepack-suggest-recipes

agent entry files (AGENTS.md / CLAUDE.md)
  pagepack-suggest-adapters

pack integrity
  pagepack-check-pack, run standalone or automatically after every
  pagepack-apply-suggestion application
```

Hand edits by maintainers are allowed everywhere; ownership names the capability responsible for keeping an area from going stale, not an exclusive writer.

## Practical Core Structure

```text
.codebase/
  router.md
  knowledge/
    overview.md
    framework-usage.md
    ui-patterns.md
    module-granularity.md
  rules/
    ui.md
    framework-api.md
    file-structure.md
  examples/
    page-types/          # Page Recipes: recurring page shapes
    behaviors/           # Behavior Recipes: cross-cutting behavior conventions
```

`examples/page-types/` holds Page Recipes for recurring page shapes. `examples/behaviors/` holds Behavior Recipes: conventions that cut across page shapes, such as query/table behavior, request lifecycle, or shared interaction constraints. Both doc types follow the same evidence, confidence, and Router Coverage requirements.

Do not create `.codebase/meta/`, manifest, evidence, suggestion bundles, or candidate files.

## Language Policy

Pagepack generated content uses the user's preferred language, defaulting to English. Preserve file paths, command names, API names, framework names, identifiers, component names, and other technical proper nouns in their original form.
