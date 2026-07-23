# Pagepack Check Contracts

This reference defines the integrity check contract for `pagepack-check-pack`. Read `../../pagepack-init/references/shared-contracts.md` first for the family-wide contracts, in particular the Router Coverage Invariant and Pack Lifecycle.

## Scope

`pagepack-check-pack` is read-only and agent-neutral. It runs mechanical checks from `scripts/check-pack.sh` and reports findings with fix routing. It does not produce patches; each finding names the `pagepack-suggest-*` capability responsible for the fix.

The script is the single source of truth for mechanical check behavior. Skill-level judgment review (missing confidence sections, duplicated facts, misplaced behavior content) is additive and report-only.

## Check Classes

```text
C1  source references
  Backtick tokens in pack docs that look like repository paths
  (first path segment is an existing top-level directory) must exist
  on disk. Catches citation drift after source refactors.
  Severity: ERROR.

C2  router coverage
  Every .codebase/examples/**/*.md must be explicitly listed by at
  least one route in router.md (Router Coverage Invariant).
  Directory-level mention only: WARN. No mention at all: ERROR.

C3  pack cross-references
  Every `.codebase/...*.md` reference inside pack docs must resolve
  to an existing file. A missing router.md is also reported here.
  Severity: ERROR.

C4  cache hygiene
  Runtime Docs must not reference .last-suggestion.diff; it is a tool
  runtime cache that coding agents should never read.
  Severity: WARN.
```

Tokens containing spaces, angle brackets, braces, globs, brackets, or parentheses are treated as templates or inline code and skipped. Tokens whose first segment is not an existing top-level directory (aliases like `@/...`, package names) are skipped. This keeps C1 free of false positives at the cost of missing exotic reference styles; prefer plain repo-relative paths in pack docs.

## Severity Policy

```text
ERROR  invariant broken; pack is lying to agents or unreachable
WARN   quality drift; pack still functions but decays without action
```

Exit codes: `0` no errors, `1` errors present (or warnings with `--strict`), `2` pack missing or usage error.

## Fix Routing

```text
C1 -> pagepack-suggest-knowledge (stale fact refresh) or a targeted
      manual patch applied via pagepack-apply-suggestion
C2 -> pagepack-suggest-knowledge (router repair) or
      pagepack-suggest-recipes (rewiring alongside recipe changes)
C3 -> the suggest capability owning the referencing document
C4 -> remove the cache reference from the Runtime Doc
```

## Post-Apply Verification

`pagepack-apply-suggestion` runs the script before and after applying a patch:

- the pre-apply run is the baseline;
- findings present only in the post-apply run were introduced by the patch and must be reported prominently;
- findings present in both runs are pre-existing debt, reported as notes;
- findings present only in the baseline were fixed by the patch.

Verification never rolls the patch back: the patch was human-reviewed before apply. Introduced findings get a recommended follow-up instead.
