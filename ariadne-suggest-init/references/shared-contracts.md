# Ariadne Shared Contracts

This reference defines the v1 contracts used by `ariadne-suggest-init`. Human-facing generated content defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, and other technical proper nouns.

`ariadne-suggest-init` is a direct bootstrap capability when no `.codebase/` exists. It creates the initial pack immediately instead of producing an init suggestion for `ariadne-apply-suggestion`. Recovery, migration, refresh, adapter, rule, and recipe changes remain reviewable suggestions.

## Agent Scope

Every Ariadne capability needs an explicit Agent Scope.

- Default to the current agent only when it is reliably known.
- Use `--agent <codex|claude|gemini|cursor|antigravity>` for a specific agent.
- Use `--all` only to expand agent compatibility or adapter scope.
- If current agent is unknown and no explicit scope is provided, stop and ask for scope.
- Agent Scope must not create agent-specific `.codebase-*` variants.

## Single Pack Invariant

A repository has exactly one Codebase Knowledge Pack at `.codebase/`.

Do not create:

```text
.codebase-codex/
.codebase-claude/
.codebase-cursor/
```

## Bootstrap State Rules

Handle existing pack state as follows:

```text
No .codebase/
  -> directly create initial Codebase Knowledge Pack

.codebase/ exists with compatible manifest
  -> stop init and recommend ariadne-suggest-refresh

.codebase/ exists without manifest
  -> generate Pack Recovery suggestion

.codebase/ exists with incompatible schema major
  -> stop normal init and generate migration-needed report or suggestion

Multiple .codebase-* variants exist
  -> report Single Pack Invariant violation; do not merge automatically
```

## Bootstrap Source Minimum

Inspect these source classes before creating an initial pack:

- Project identity: `package.json`, lockfile, TypeScript/build config.
- Routing/page entries: routes, pages/views/modules, menu config.
- Framework Authority: package metadata, type declarations, exports, official/internal docs when available.
- Project Usage: imports, JSX usage, hooks, wrappers, request/service patterns.
- UI/style usage: UI components, wrapper components, stylesheets, `className`, inline styles.
- Module granularity: file tree, services, hooks, constants, schemas, types.

If evidence is weak, lower confidence or produce candidates. Do not generate a full-trust pack from blind inference.

## Direct Bootstrap Output

For the no-existing-pack bootstrap path, do not create `init-*.json` or require `ariadne-apply-suggestion`.

Create the complete Practical Core pack directly:

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
    page-types/
  meta/
    manifest.json
    evidence/
    suggestions/
    candidates/
    change-log.md
```

The final user-facing summary must include:

- created files
- skipped or candidate-only areas
- framework, UI, module granularity, and Page Recipe confidence
- recommended next checks, especially `ariadne-check-pack`
- optional adapter next step: `ariadne-suggest-adapters`

## Suggestion Schema For Non-Bootstrap Paths

Pack Recovery, migration-needed, refresh, adapter, rule, and recipe suggestions still use `ariadne-apply-suggestion`. v1 suggestion JSON must include the apply-required fields:

```json
{
  "schemaVersion": "1.0.0",
  "id": "refresh-20260610-001",
  "type": "refresh-pack",
  "createdAt": "2026-06-10T10:00:00Z",
  "createdBy": "ariadne-suggest-refresh",
  "agentScope": ["codex"],
  "risk": "medium",
  "sourceFingerprints": {},
  "targetPreconditions": [],
  "operations": [],
  "reviewSummaryPath": ".codebase/meta/suggestions/refresh-20260610-001.md"
}
```

Keep detailed confidence, evidence, and diff metadata in `metadata`, Evidence Artifacts, or the Markdown review summary instead of required schema fields.

## Suggestion Operations

For non-bootstrap suggestions, v1 supports only these operation actions:

```json
{
  "action": "create",
  "path": ".codebase/router.md",
  "content": "..."
}
```

```json
{
  "action": "replace",
  "path": ".codebase/knowledge/ui-patterns.md",
  "baseHash": "sha256:...",
  "content": "..."
}
```

```json
{
  "action": "patch",
  "path": "AGENTS.md",
  "baseHash": "sha256:...",
  "patch": "unified diff..."
}
```

Do not include delete, move, chmod, shell commands, or hidden side effects.

## File Ownership

Record file ownership in `.codebase/meta/manifest.json`.

```json
{
  "files": {
    ".codebase/knowledge/framework-usage.md": {
      "owner": "generated",
      "generatedBy": "ariadne-suggest-init",
      "sourceKeys": ["frameworkAuthority", "projectUsage"]
    },
    ".codebase/rules/ui.md": {
      "owner": "reviewed",
      "generatedBy": "ariadne-suggest-rules",
      "sourceKeys": ["uiUsage"]
    }
  }
}
```

Rules:

- `generated` may be replaced with `baseHash` guard.
- `reviewed` requires patch or explicit review.
- `manual` requires patch or user editing.
- `unknown` blocks replace.
- v1 supports file-level ownership only.

Runtime `rules/*.md` are `reviewed` by default because they express expected behavior, not regenerated facts.

## Practical Core Routes

Generate `.codebase/router.md` from stable route types:

- UI/Layout Change
- Framework/API Usage
- Page Feature Iteration
- Debug Existing Page
- New Page/Module
- Style/CSS Change

Fill links dynamically based on available Runtime Docs and candidates. Do not invent project-specific route categories during v1 bootstrap.

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
- Missing authority + project import pattern -> Framework Detection Candidate.
- Deprecated API -> Framework Candidate or migration suggestion, not automatic Runtime Rule.
- Project wrapper is preferred when it is the common project path.
- Do not infer complex prop semantics unless backed by clear docs or repeated safe usage.

## Runtime Docs Ownership Defaults

Recommended bootstrap ownership:

```text
.codebase/knowledge/*.md
  generated

.codebase/rules/*.md
  reviewed

.codebase/examples/page-types/*.md
  generated only when high confidence; otherwise candidate

.codebase/meta/evidence/*.json
  generated

.codebase/meta/candidates/*.md
  generated or reviewed-candidate metadata as appropriate
```

## Review Summary For Suggestions

Every non-bootstrap suggestion JSON needs a Markdown review summary with:

- suggestion id
- target Agent Scope
- proposed files
- confidence summary
- risks and conflicts
- candidates requiring review
- apply instruction: `ariadne-apply-suggestion <id>`
