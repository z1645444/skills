# Pagepack Rule Contracts

This reference defines the contract for Coding Rule patches. Human-facing output uses the user's preferred language, defaulting to English; preserve file paths, command names, API names, framework names, component names, identifiers, rule target names, and other technical proper nouns.

## Scope

`pagepack-suggest-rules` proposes Runtime Rule updates. It does not write suggestion bundles under `.codebase/` and does not directly modify Runtime Rules.

After outputting the patch, it writes the same unified diff to `.codebase/.last-suggestion.diff` so `pagepack-apply-suggestion` can apply it by default. This file is a tool runtime cache, not a Runtime Doc; agents should not read or reference it.

It reads:

- `.codebase/router.md`;
- `.codebase/knowledge/*`;
- existing `.codebase/rules/*.md`;
- project source for evidence.

It outputs:

- unified diff patch blocks for `.codebase/rules/*.md`;
- optional `baseHash` for existing files;
- a concise human-facing summary including blocked candidates.

## Agent Scope

Every Pagepack capability needs Agent Scope.

- Use current agent only when reliably known.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` does not create multiple packs or per-agent rules.

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

Runtime `rules/*.md` express expected agent behavior, not regenerated observations. Treat them as reviewed by default.

Rules:

- Do not `replace` Runtime Rules wholesale in v1.
- Use `patch` for existing rule files.
- Use `create` for missing rule files only when target path is unambiguous.
- Put uncertain or low-confidence findings in the summary, not patch output.
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

Framework best practices and deprecated API migrations remain candidates unless evidence is strong.

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

Otherwise report it in the summary as blocked or low-confidence.

## Patch Output Format

The skill outputs unified diffs. For a missing rule file:

```diff
--- /dev/null
+++ .codebase/rules/ui.md
@@ -0,0 +1,6 @@
+# UI Rules
+
+## Component-First UI
+
+Prefer framework/design-system components and props before adding custom styles.
```

For existing files, use `patch` semantics and include optional `baseHash`.

## Trailing Prompt Guidance

Trailing text narrows rule generation. Examples:

- `pagepack-suggest-rules focus on forms and tables`
- `pagepack-suggest-rules add rules about API error handling`
- `pagepack-suggest-rules for the admin module only`

The output must still be concrete patch/diffs.

## Blocking Conditions

Block or report review-only candidates when:

- Agent Scope is unknown;
- requested target is unsupported;
- evidence is missing;
- candidate promotes legacy or low-confidence pattern;
- target operation would replace reviewed/manual Runtime Rules wholesale;
- rule depends on unverified framework API behavior.
