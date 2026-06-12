# Ariadne Pack Check Contracts

This reference defines the v1 read-only pack check contract. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, and other technical proper nouns.

## Scope

`ariadne-check-pack` checks `.codebase/` structure and machine-readable contracts only.

It checks:

- Single Pack Invariant;
- required pack files;
- manifest schema support;
- manifest `files` ownership map;
- router-linked Runtime Docs;
- suggestion store readiness.

It does not check:

- source freshness;
- framework/package updates;
- page inventory changes;
- UI/style drift;
- adapter entry files;
- whether a suggestion can be applied;
- whether evidence is semantically correct.

## Agent Scope

Every Ariadne capability needs Agent Scope.

- If current agent is known, use it as default.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple packs.

## Status Levels

Use three status levels:

```text
error
  The pack is not usable by Ariadne until fixed.

warning
  The pack is usable, but later capabilities may have reduced behavior.

ok
  The check passed.
```

Examples:

- missing `.codebase/router.md` -> `error`
- unsupported `schemaVersion` -> `error`
- missing optional `examples/page-types/` -> `warning` or omitted, depending on router requirements
- router reference exists -> `ok`

## Required Files

Minimum usable pack:

```text
.codebase/
  router.md
  meta/
    manifest.json
    suggestions/
```

`meta/suggestions/` is the Suggestion Store. If absent, report warning or error based on whether later suggest capabilities can create it without ambiguity. Do not create it during check.

## Single Pack Invariant

Valid:

```text
.codebase/
```

Invalid:

```text
.codebase/
.codebase-codex/
.codebase-claude/
```

Report agent-specific pack variants as errors. Do not remove or merge them.

## Manifest Requirements

`.codebase/meta/manifest.json` must be JSON and include:

```json
{
  "schemaVersion": "1.0.0",
  "packVersion": "2026-06-10T00:00:00Z",
  "generatedBy": "ariadne-init",
  "agentScope": ["codex"],
  "sources": {
    "projectIdentity": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/project-identity.json",
      "inputs": ["package.json"]
    }
  },
  "files": {}
}
```

Required fields:

- `schemaVersion`
- `packVersion`
- `generatedBy`
- `agentScope`
- `sources`
- `files`

v1 supports schema major version `1` only. Unknown major versions are errors.

`packVersion` should be an ISO-8601 timestamp string. A numeric pack version is a warning because later freshness and refresh tooling expects a timestamp-like pack generation id.

`generatedBy` should be `ariadne-init` for newly bootstrapped packs. Existing packs that still record the legacy value `ariadne-suggest-init` are compatible v1 packs; report the legacy value as a warning or provenance note, not an error.

`sources` must be an object. Every present source entry must include:

- `fingerprint`: string beginning with `sha256:`
- `evidencePath`: optional path to the corresponding Evidence Artifact
- `inputs`: optional list of source files or globs used for the fingerprint

Source entries that exist without `fingerprint` are errors because freshness and refresh cannot compare them. Expected source keys may be absent when bootstrap evidence was weak; report missing important keys as warnings, not as fresh.

Stable source keys:

```text
projectIdentity
frameworkAuthority
projectUsage
routingPageEntries
uiStyleUsage
moduleLayout
```

## File Ownership Map

`files` maps pack paths to ownership metadata.

Known owners:

```text
generated
reviewed
manual
```

Invalid owner values are errors. Missing ownership for required Runtime Docs is a warning or error depending on whether the file is referenced as required by router.

Runtime `rules/*.md` should generally be `reviewed`, not `generated`.

## Router Link Check

Inspect `.codebase/router.md` for `.codebase/` references.

Rules:

- Required Runtime Docs referenced by router must exist.
- Optional candidates may be missing only when clearly marked optional.
- Do not require every possible Practical Core file if router does not link it.
- Do not validate the semantic quality of routes in v1.

Runtime Docs include:

```text
.codebase/router.md
.codebase/knowledge/*.md
.codebase/rules/*.md
.codebase/examples/**/*.md
```

Cold-path files such as `meta/evidence/*`, `meta/candidates/*`, and `meta/suggestions/*` are not Runtime Docs unless router explicitly routes to them.

## Human Summary

Default output should include:

- overall status;
- repository path;
- Agent Scope;
- errors;
- warnings;
- ok checks;
- recommended next command.

Recommended next command examples:

```text
Missing pack
  -> ariadne-init

Pack valid but stale not checked
  -> ariadne-check-freshness

Adapter status unknown
  -> ariadne-check-adapters
```

## JSON Output

When `--json` is requested, output a stable structure:

```json
{
  "status": "error",
  "agentScope": ["codex"],
  "checks": [
    {
      "id": "single-pack-invariant",
      "status": "ok",
      "message": "Found exactly one .codebase pack."
    },
    {
      "id": "router-exists",
      "status": "error",
      "path": ".codebase/router.md",
      "message": "Router is missing."
    }
  ],
  "recommended": ["ariadne-init"]
}
```

Do not write this JSON to the repository during check unless the user explicitly redirects output outside the skill.

## Security

Never read or print secret-bearing files. Pack Check should only inspect `.codebase/` metadata, router links, and filesystem existence.
