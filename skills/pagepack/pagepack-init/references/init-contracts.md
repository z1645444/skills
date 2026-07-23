# Pagepack Init Contracts

This reference defines the bootstrap-specific contract for `pagepack-init`. Read `references/shared-contracts.md` first for the family-wide contracts: Agent Scope, Single Pack Invariant, Pack Lifecycle, Practical Core Structure, and Language Policy.

`pagepack-init` is a direct bootstrap capability when no `.codebase/` exists. It creates Runtime Docs immediately and does not produce intermediate artifacts such as a manifest, evidence files, suggestion bundles, or candidate files.

## Bootstrap State Rules

Handle existing pack state as follows:

```text
No .codebase/
  -> directly create initial Codebase Knowledge Pack

.codebase/ exists
  -> stop init; recommend pagepack-suggest-knowledge for stale knowledge,
     pagepack-suggest-recipes / pagepack-suggest-rules for additions,
     and pagepack-check-pack for integrity review
```

## Bootstrap Source Minimum

Inspect these source classes before creating an initial pack:

- Project identity: `package.json`, lockfile, TypeScript/build config.
- Routing/page entries: routes, pages/views/modules, menu config.
- Framework Authority: package metadata, type declarations, exports, official/internal docs when available.
- Project Usage: imports, JSX usage, hooks, wrappers, request/service patterns.
- UI/style usage: UI components, wrapper components, stylesheets, `className`, inline styles.
- Module granularity: file tree, services, hooks, constants, schemas, types.

If evidence is weak, lower confidence in the generated Runtime Docs. Do not generate a full-trust pack from blind inference.

## Direct Bootstrap Output

For the no-existing-pack bootstrap path, create the complete Practical Core pack directly, following the structure defined in shared contracts. `examples/behaviors/` may stay empty at bootstrap; create behavior docs only when evidence is high-confidence.

Do not create:

```text
.codebase/meta/
.codebase/meta/manifest.json
.codebase/meta/evidence/
.codebase/meta/suggestions/
.codebase/meta/candidates/
.codebase/meta/change-log.md
```

The final user-facing summary must include:

- created files
- skipped or low-confidence areas
- framework, UI, module granularity, and Page Recipe confidence
- recommended next command: `pagepack-suggest-adapters`

## Practical Core Routes

Generate `.codebase/router.md` from stable route types:

- UI/Layout Change
- Framework/API Usage
- Page Feature Iteration
- Debug Existing Page
- New Page/Module
- Style/CSS Change

Fill links dynamically based on available Runtime Docs. Every created `examples/` document must be explicitly wired into at least one route (Router Coverage Invariant). Do not invent project-specific route categories during bootstrap.

## UI Decision Ladder

Style/CSS tasks must route agents through this order:

1. Check Page Recipes or same-type pages.
2. Check existing framework/design-system components.
3. Check component props.
4. Check project wrapper components.
5. Check accepted local patterns.
6. Add custom styles only when the above are insufficient.

Custom style must stay local, avoid duplicating design-system behavior, and not create a new visual language.

## Framework Guidance

Use Framework Authority to validate API existence and Project Usage to identify project defaults.

- Confirmed API + high project usage -> Runtime Docs candidate.
- Missing authority + project import pattern -> uncertainty, not confirmed guidance.
- Deprecated API -> note as risk, not automatic Runtime Rule.
- Project wrapper is preferred when it is the common project path.
- Do not infer complex prop semantics unless backed by clear docs or repeated safe usage.
