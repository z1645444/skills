# Ariadne Freshness Check Contracts

This reference defines the v1 read-only freshness check contract. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, and source class names.

## Scope

`ariadne-check-freshness` compares manifest source fingerprints with current source fingerprints.

It checks:

- project identity changes;
- framework authority changes;
- project usage changes;
- routing/page entry changes;
- UI/style usage changes;
- module layout changes.

It does not:

- write suggestions;
- refresh Runtime Docs;
- update Evidence Artifacts;
- mutate manifest fingerprints;
- inspect adapter entry files;
- apply changes.

## Agent Scope

Every Ariadne capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple packs or multiple freshness states.

## Manifest Requirements

Read `.codebase/meta/manifest.json`.

Required for freshness:

```json
{
  "schemaVersion": "1.0.0",
  "sources": {
    "projectIdentity": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/project-identity.json",
      "inputs": ["package.json", "pnpm-lock.yaml", "tsconfig.json"]
    },
    "frameworkAuthority": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/framework-authority.json",
      "inputs": ["package.json", "node_modules/<framework>/package.json"]
    },
    "projectUsage": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/project-usage.json",
      "inputs": ["src/**/*.{ts,tsx,js,jsx}"]
    },
    "routingPageEntries": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/page-inventory.json",
      "inputs": ["src/**/routes*", "src/**/pages/**", "src/**/views/**", "src/**/menu*"]
    },
    "uiStyleUsage": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/ui-usage.json",
      "inputs": ["src/**/*.{css,less,scss,tsx,jsx}"]
    },
    "moduleLayout": {
      "fingerprint": "sha256:...",
      "evidencePath": ".codebase/meta/evidence/module-granularity.json",
      "inputs": ["src/**"]
    }
  }
}
```

Source keys may be absent when the pack was bootstrapped with weak evidence. Missing source keys should be reported as `missing` or `warning`, not silently treated as fresh.

For each present source entry, read `sources.<key>.fingerprint` as the manifest fingerprint. If an older manifest stores `sources.<key>` directly as a string hash, treat it as a legacy shape: compare the hash but warn that the manifest should be refreshed to the structured `sources.<key>.fingerprint` form. If a present source entry has no fingerprint, report `error`.

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

Recommended inputs:

```text
projectIdentity
  package.json, lockfile, tsconfig/jsconfig, build config

frameworkAuthority
  framework package version, type declarations, exports, docs source

projectUsage
  imports, JSX usage, hooks, wrappers, request/service usage

routingPageEntries
  routes, pages/views/modules directories, menu config

uiStyleUsage
  stylesheets, className, inline styles, UI component imports

moduleLayout
  file tree, service/types/hooks/constants/schema layout
```

Do not read secret-bearing files when computing fingerprints.

## Source Status

```text
fresh
  Current fingerprint matches manifest.

stale
  Current fingerprint differs from manifest.

missing
  Manifest lacks this source key or source files no longer exist.

error
  Fingerprint could not be recomputed.
```

Overall status:

- `ok` when all checked source classes are fresh.
- `stale` when at least one source class is stale.
- `error` when manifest or recomputation problems block reliable checking.

## Fixed Source-To-Doc Mapping

Use this v1 mapping to report affected docs.

```text
projectIdentity changed
  affects:
    .codebase/meta/evidence/project-identity.json
    .codebase/knowledge/overview.md
    framework detection state

frameworkAuthority changed
  affects:
    .codebase/meta/evidence/framework-authority.json
    .codebase/knowledge/framework-usage.md
    .codebase/meta/candidates/framework-best-practices.md
    deprecated migration suggestions
    possible rules/framework-api.md patch after review

projectUsage changed
  affects:
    .codebase/meta/evidence/project-usage.json
    .codebase/knowledge/framework-usage.md
    .codebase/knowledge/ui-patterns.md
    .codebase/knowledge/module-granularity.md

routingPageEntries changed
  affects:
    .codebase/meta/evidence/page-inventory.json
    .codebase/knowledge/module-granularity.md
    .codebase/meta/candidates/page-recipes.md

uiStyleUsage changed
  affects:
    .codebase/meta/evidence/ui-usage.json
    .codebase/knowledge/ui-patterns.md
    .codebase/meta/candidates/ui-style-risks.md
    possible rules/ui.md patch after review

moduleLayout changed
  affects:
    .codebase/meta/evidence/module-granularity.json
    .codebase/knowledge/module-granularity.md
    .codebase/meta/candidates/granularity-outliers.md
```

Do not invent project-specific mapping in v1.

## Human Summary

Default output should include:

- overall freshness status;
- Agent Scope;
- source class statuses;
- stale source classes;
- affected docs;
- warnings for missing source keys;
- recommended next command.

Recommended next command:

```text
ariadne-suggest-refresh
```

If manifest or structure blocks the check:

```text
ariadne-check-pack
```

## JSON Output

When `--json` is requested, output a stable structure:

```json
{
  "status": "stale",
  "agentScope": ["codex"],
  "sources": [
    {
      "key": "frameworkAuthority",
      "status": "stale",
      "manifestFingerprint": "sha256:old",
      "currentFingerprint": "sha256:new",
      "affectedDocs": [
        ".codebase/knowledge/framework-usage.md",
        ".codebase/meta/candidates/framework-best-practices.md"
      ]
    }
  ],
  "recommended": ["ariadne-suggest-refresh"]
}
```

Do not write JSON output to the repository unless the user explicitly redirects it outside the skill.

## Boundary With Suggest Refresh

`ariadne-check-freshness` diagnoses.

`ariadne-suggest-refresh` plans changes.

Freshness Check must not create `.codebase/meta/suggestions/refresh-*.json` or `.md`.
