---
name: pagepack-explain
description: Trace Pagepack Codebase Knowledge Pack routes, Runtime Rules, Runtime Docs, or suggestions back to manifest metadata, file ownership, source fingerprints, evidence artifacts, and review state. Use when a user asks why a Task Router route loads certain docs, where a rule came from, what evidence backs a Runtime Doc, or why a suggestion can or cannot be applied, without generating new suggestions or performing freeform project Q&A.
---

# Pagepack Explain

## Overview

Use this skill to explain existing Pagepack pack decisions and traceability. It reads `.codebase/` metadata, Runtime Docs, Evidence Artifacts, and suggestions, then reports why an object exists and what evidence or ownership supports it.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, framework names, identifiers, component names, route names, suggestion ids, and other technical proper nouns.

## Required Reference

Before explaining an object, read `references/explain-contracts.md`. It defines supported object kinds, required evidence, output shape, and boundaries against freeform Q&A or suggestion generation.

## Supported Objects

```text
pagepack-explain route <route-name>
  Explain why a Task Router route points to specific Runtime Docs.

pagepack-explain rule <path-or-id>
  Explain a Runtime Rule's source, File Ownership, review state, and supporting evidence.

pagepack-explain doc <path>
  Explain a Runtime Doc's source fingerprints, ownership, generated/reviewed status, and related Evidence Artifacts.

pagepack-explain suggestion <id-or-path>
  Explain a suggestion's operations, risk, target preconditions, source fingerprints, and why it can or cannot be applied.
```

## Workflow

1. Resolve Agent Scope.
   - Use current agent only when reliably known.
   - If unknown, stop and ask the user for `--agent` or `--all`.
   - Do not continue in a generic fallback mode.

2. Parse object kind and identifier.
   - Supported kinds are `route`, `rule`, `doc`, and `suggestion`.
   - If kind is missing or unsupported, stop and ask for a supported kind.
   - Do not answer arbitrary project questions outside these object kinds.

3. Load pack metadata.
   - Read `.codebase/meta/manifest.json`.
   - Read relevant manifest `files` ownership entry.
   - Read source fingerprints when relevant.
   - Read Evidence Artifacts only when needed for the requested explanation.

4. Load target object.
   - For `route`, read `.codebase/router.md`.
   - For `rule`, read the target `rules/*.md` or rule id context when available.
   - For `doc`, read the target Runtime Doc and manifest entry.
   - For `suggestion`, read `.codebase/meta/suggestions/<id>.json` and companion Markdown summary when present.

5. Explain traceability.
   - State what the object is.
   - State its ownership and review/generated status when available.
   - State source fingerprints or evidence artifacts that support it.
   - State confidence/review status when available.
   - For suggestions, state Apply Guard considerations and likely apply blockers.

6. Report result.
   - Default to human-readable explanation.
   - If `--json` is requested, emit machine-readable result.
   - Do not write files.

## Out Of Scope

Do not:

- generate new suggestions;
- modify Runtime Docs, manifest, evidence, or entry files;
- perform source freshness checks;
- perform adapter checks;
- answer freeform project Q&A;
- infer facts that are not present in `.codebase/` metadata, Runtime Docs, evidence, or suggestions.

## Failure Rules

Stop or report blocked explanation when:

- Agent Scope is unknown.
- object kind is unsupported.
- object id/path is missing.
- target object is not found.
- manifest or evidence required for the explanation is missing.
- explanation would require new analysis rather than tracing existing evidence.

## Validation Checklist

Before finishing:

- No file was written.
- No suggestion was created.
- Explanation stayed within `route`, `rule`, `doc`, or `suggestion`.
- Ownership, source fingerprints, confidence/review status are included where available.
- Missing evidence is called out instead of guessed.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
