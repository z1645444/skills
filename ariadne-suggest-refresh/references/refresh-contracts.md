# Ariadne Refresh Contracts

This reference defines the v1 suggestion contract for refreshing an existing `.codebase/` pack. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, and source class names.

## Scope

`ariadne-suggest-refresh` plans changes. It may write suggestion JSON/MD under `.codebase/meta/suggestions/`, but it must not directly modify Runtime Docs, Evidence Artifacts, manifest, candidates, or agent entry files outside suggestion operations.

It reads:

- `.codebase/meta/manifest.json`;
- manifest `sources`;
- manifest `files` ownership map;
- current source classes;
- existing Runtime Docs;
- existing Evidence Artifacts.

It writes:

- `.codebase/meta/suggestions/refresh-*.json`;
- `.codebase/meta/suggestions/refresh-*.md`.

## Agent Scope

Every Ariadne capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple `.codebase/` packs.

## Preconditions

Before producing a refresh suggestion:

1. Pack must pass structural readiness equivalent to `ariadne-check-pack`.
2. Manifest schema major version must be supported.
3. Manifest `sources` must be readable.
4. Manifest `files` ownership map must be readable.
5. At least one source class must be stale or explicitly requested for refresh.

If no sources are stale, report that no refresh suggestion is needed.

## Source Classes

Use stable source class names:

```text
projectIdentity
frameworkAuthority
projectUsage
routingPageEntries
uiStyleUsage
moduleLayout
```

Do not invent project-specific source classes in v1.

## Fixed Source-To-Doc Mapping

Use this mapping for affected docs and operations.

```text
projectIdentity changed
  update candidates/operations for:
    .codebase/meta/evidence/project-identity.json
    .codebase/knowledge/overview.md
    framework detection state

frameworkAuthority changed
  update candidates/operations for:
    .codebase/meta/evidence/framework-authority.json
    .codebase/knowledge/framework-usage.md
    .codebase/meta/candidates/framework-best-practices.md
    deprecated migration suggestions
    possible rules/framework-api.md patch after review

projectUsage changed
  update candidates/operations for:
    .codebase/meta/evidence/project-usage.json
    .codebase/knowledge/framework-usage.md
    .codebase/knowledge/ui-patterns.md
    .codebase/knowledge/module-granularity.md

routingPageEntries changed
  update candidates/operations for:
    .codebase/meta/evidence/page-inventory.json
    .codebase/knowledge/module-granularity.md
    .codebase/meta/candidates/page-recipes.md

uiStyleUsage changed
  update candidates/operations for:
    .codebase/meta/evidence/ui-usage.json
    .codebase/knowledge/ui-patterns.md
    .codebase/meta/candidates/ui-style-risks.md
    possible rules/ui.md patch after review

moduleLayout changed
  update candidates/operations for:
    .codebase/meta/evidence/module-granularity.json
    .codebase/knowledge/module-granularity.md
    .codebase/meta/candidates/granularity-outliers.md
```

## File Ownership Behavior

Use manifest `files` ownership map:

```text
generated
  may be replaced with baseHash guard

reviewed
  must not be replaced; use patch or review candidate

manual
  must not be replaced; use patch or user edit recommendation

unknown
  blocks replace
```

Runtime `rules/*.md` are `reviewed` by default. Project-inferred rules must first enter `meta/candidates/` or a rules suggestion.

v1 supports file-level ownership only. Do not attempt section-level ownership or section merge.

## Refresh Conflict

Refresh Conflict occurs when a generated file's current hash differs from the hash recorded in manifest or expected by the refresh operation.

When this happens:

- do not overwrite the file;
- do not silently merge;
- create a conflict suggestion or mark the refresh suggestion as blocked for that file;
- explain options in the Markdown review summary:
  - accept regeneration;
  - keep current file and mark reviewed/manual;
  - inspect diff manually.

## Suggestion Schema

Refresh suggestions use the standard v1 schema:

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

Allowed operations:

- `create`;
- `replace`;
- `patch`.

Reject delete, move, chmod, shell commands, environment mutation, or hidden side effects.

## Operation Guidance

Use `replace` for:

- generated evidence files;
- generated knowledge files when `baseHash` and ownership allow it.

Use `patch` for:

- reviewed Runtime Rules;
- manual files;
- small reviewable changes to existing human-curated docs.

Use `create` for:

- new candidates;
- new evidence artifacts;
- new high-confidence generated docs that do not already exist.

Do not directly update agent entry files in refresh suggestions. Adapter changes belong to `ariadne-suggest-adapters`.

## Current Snapshot Rule

Runtime Docs should represent the current valid state. Do not append migration history or old deltas into Runtime Docs.

Historical notes, low-confidence candidates, and audit information belong under `meta/` cold paths.

## Review Summary

Markdown review summary should include:

- suggestion id;
- stale source classes;
- affected docs;
- operations by file;
- ownership decisions;
- conflicts;
- risk level;
- candidates requiring review;
- apply instruction: `ariadne-apply-suggestion <id>`.

## Failure And Blocking

Block or generate conflict report when:

- Agent Scope is unknown;
- pack structure is invalid;
- schema major is unsupported;
- required fingerprints cannot be recomputed;
- source evidence is too weak;
- generated target has Refresh Conflict;
- requested operation would replace reviewed/manual/unknown ownership.
