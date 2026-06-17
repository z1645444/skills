# Pagepack Rule Contracts

This reference defines the v1 suggestion contract for Coding Rule candidates. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, rule target names, and suggestion ids.

## Scope

`pagepack-suggest-rules` proposes Runtime Rule updates. It may write suggestion JSON/MD under `.codebase/meta/suggestions/`, but it must not directly modify Runtime Rules.

It reads:

- `.codebase/meta/manifest.json`;
- manifest `files` ownership map;
- `.codebase/knowledge/*`;
- `.codebase/meta/evidence/*`;
- `.codebase/meta/candidates/*`;
- existing `.codebase/rules/*.md`.

It writes:

- `.codebase/meta/suggestions/rules-*.json`;
- `.codebase/meta/suggestions/rules-*.md`.

## Agent Scope

Every Pagepack capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create per-agent rules or pack variants.

## Rule Targets

Supported v1 targets:

```text
ui
  .codebase/rules/ui.md

framework-api
  .codebase/rules/framework-api.md

file-structure
  .codebase/rules/file-structure.md
```

If no target is specified, evaluate all three.

Unsupported targets should block instead of creating ad hoc rule files.

## Runtime Rule Ownership

Runtime `rules/*.md` are `reviewed` by default. They express expected agent behavior, not regenerated observations.

Rules:

- Do not `replace` Runtime Rules in v1.
- Use `patch` for existing rule files.
- Use `create` for missing rule files only when target path is unambiguous.
- Put uncertain or low-confidence findings in `meta/candidates/*`.
- Never auto-promote current legacy code into a rule.

## Observed Knowledge vs Coding Rules

Observed Knowledge:

```text
The project currently has many custom CSS files.
Several pages import a deprecated table wrapper.
List pages often keep columns in the page file.
```

Coding Rules:

```text
Prefer framework/design-system components and props before adding custom styles.
Do not use deprecated framework APIs without review.
Match same-type page file layout before creating new structure.
```

The second category requires review before Runtime Rule application.

## UI Rule Candidates

UI rules should reinforce:

- Component-First UI;
- UI Decision Ladder;
- custom style as an exception path;
- project wrappers before lower-level design-system primitives when wrappers are standard;
- UI Anti-Pattern warnings when evidence is strong.

Do not turn frequent custom CSS into a rule. Frequent custom CSS may indicate risk or legacy drift.

Do not perform visual redesign, screenshot audit, or subjective aesthetics review in v1.

## Framework API Rule Candidates

Framework rules should prevent:

- invented framework APIs;
- wrong import paths;
- bypassing standard project wrappers;
- unchecked deprecated APIs;
- freeform prop semantics not supported by docs or repeated safe usage.

Framework best practices and deprecated API migrations are Framework Candidates by default. They require review before Runtime Rule application.

## File Structure Rule Candidates

File-structure rules should convert Module Granularity Profile into Granularity Guidance:

- match same-type page layout first;
- do not split files based only on line count;
- use existing module locations for services, types, hooks, constants, schemas;
- keep private logic local unless shared by multiple pages;
- do not create layer directories that the project does not use.

Do not suggest automatic refactors or mandatory splits in v1.

## Promotion Criteria

A candidate may be proposed as a Runtime Rule patch only when:

- evidence is current and source-backed;
- it represents intended future behavior;
- it does not conflict with existing reviewed rules;
- it has clear scope and wording;
- it avoids encoding one-off business cases;
- it does not rely on unsupported framework claims.

Otherwise keep it under `meta/candidates/*`.

## Suggestion Schema

Rule suggestions use the standard v1 schema:

```json
{
  "schemaVersion": "1.0.0",
  "id": "rules-20260610-001",
  "type": "rules-candidate",
  "createdAt": "2026-06-10T10:00:00Z",
  "createdBy": "pagepack-suggest-rules",
  "agentScope": ["codex"],
  "risk": "medium",
  "sourceFingerprints": {},
  "targetPreconditions": [],
  "operations": [],
  "reviewSummaryPath": ".codebase/meta/suggestions/rules-20260610-001.md"
}
```

Allowed operation actions:

- `create`;
- `patch`;
- `replace` only for generated candidate files, not Runtime Rules.

## Operation Guidance

Use `patch` for:

- `.codebase/rules/ui.md`;
- `.codebase/rules/framework-api.md`;
- `.codebase/rules/file-structure.md`.

Use `create` for:

- missing rule file with clear path;
- new candidate file.

Use `replace` only for:

- generated candidate files with `baseHash` guard.

Do not replace reviewed/manual rule files.

## Review Summary

Markdown review summary should include:

- suggestion id;
- target rule areas;
- proposed rule candidates;
- evidence summary;
- confidence/risk;
- blocked promotions and reasons;
- affected Runtime Rule files;
- candidate files;
- apply instruction: `pagepack-apply-suggestion <id>`.

## Blocking Conditions

Block or report review-only candidates when:

- Agent Scope is unknown;
- requested target is unsupported;
- evidence is missing;
- candidate promotes legacy or low-confidence pattern;
- candidate conflicts with existing reviewed rules;
- target operation would replace reviewed/manual Runtime Rules;
- rule depends on unverified framework API behavior.
