# Pagepack Explain Contracts

This reference defines the v1 read-only traceability contract for Pagepack Explain. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, route names, and suggestion ids.

## Scope

`pagepack-explain` explains existing pack objects. It reads `.codebase/` state and reports traceability.

It reads:

- `.codebase/router.md`;
- `.codebase/meta/manifest.json`;
- `.codebase/meta/evidence/*` when relevant;
- `.codebase/knowledge/*`;
- `.codebase/rules/*`;
- `.codebase/examples/**/*`;
- `.codebase/meta/suggestions/*`.

It writes:

- nothing.

It does not:

- generate suggestions;
- mutate pack files;
- check freshness;
- check adapters;
- apply suggestions;
- answer freeform project Q&A.

## Agent Scope

Every Pagepack capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not change the pack being explained.

## Supported Object Kinds

```text
route
rule
doc
suggestion
```

Unsupported kinds must block. Do not reinterpret arbitrary user questions as new object kinds.

## Explain Route

Input:

```text
pagepack-explain route <route-name>
```

Read:

- `.codebase/router.md`;
- linked Runtime Docs;
- manifest entries for linked docs when available.

Explain:

- route name;
- task type it serves;
- required Runtime Docs;
- optional docs/candidates;
- why these docs are loaded;
- missing linked docs if any;
- related Practical Core route if recognizable.

Do not evaluate whether the route is semantically perfect unless evidence in router/manifest supports the claim.

## Explain Rule

Input:

```text
pagepack-explain rule <path-or-id>
```

Read:

- target `.codebase/rules/*.md`;
- manifest `files` ownership entry;
- source keys listed in manifest;
- related Evidence Artifacts or candidates when referenced.

Explain:

- rule path or id;
- rule text or concise summary;
- ownership: `reviewed`, `manual`, or `generated` if present;
- review state;
- supporting evidence/candidates;
- source fingerprints;
- whether it is a Runtime Rule or candidate;
- missing evidence or unresolved review state.

Rules express desired behavior, not merely observed code. If the explanation cannot prove review state, say so.

## Explain Doc

Input:

```text
pagepack-explain doc <path>
```

Read:

- target Runtime Doc;
- manifest file entry;
- source keys and fingerprints;
- related Evidence Artifacts when available.

Explain:

- doc path;
- whether it is Runtime Doc or cold-path metadata;
- ownership;
- generated/reviewed/manual status;
- source classes;
- last known generation or review metadata;
- affected routes if discoverable from `router.md`;
- freshness caveat if fingerprints are old or missing.

Do not recompute freshness. Recommend `pagepack-check-freshness` when needed.

## Explain Suggestion

Input:

```text
pagepack-explain suggestion <id-or-path>
```

Read:

- `.codebase/meta/suggestions/<id>.json`;
- companion Markdown review summary if present;
- target files only if needed to explain preconditions;
- manifest ownership map when explaining replace/patch safety.

Explain:

- suggestion id;
- suggestion type;
- createdBy;
- agentScope;
- risk;
- source fingerprints;
- target preconditions;
- operations by file;
- review summary path;
- likely Apply Guard checks;
- why it appears applyable or blocked based on available evidence.

Do not apply the suggestion. Recommend `pagepack-apply-suggestion <id>` when appropriate.

## Output Shape

Human-readable output should include:

- object kind and id;
- status;
- evidence sources;
- ownership/review state when available;
- missing evidence;
- recommended next command if useful.

When `--json` is requested:

```json
{
  "objectKind": "suggestion",
  "objectId": "adapter-20260610-001",
  "status": "ok",
  "agentScope": ["codex"],
  "evidence": [
    ".codebase/meta/suggestions/adapter-20260610-001.json"
  ],
  "ownership": null,
  "missingEvidence": [],
  "recommended": ["pagepack-apply-suggestion adapter-20260610-001"]
}
```

Do not write JSON output to the repository unless the user explicitly redirects it outside the skill.

## Missing Evidence

When evidence is missing:

- say which file or metadata is missing;
- explain which part of the trace cannot be proven;
- avoid guessing;
- recommend the relevant check/suggest command.

Examples:

```text
manifest missing
  -> pagepack-check-pack

source freshness unknown
  -> pagepack-check-freshness

adapter status unknown
  -> pagepack-check-adapters

suggestion applyability needs guard
  -> pagepack-apply-suggestion <id>
```

## Security

Do not read or print secret-bearing files. If Runtime Docs or suggestions contain credential-like values, do not repeat them in the explanation.
