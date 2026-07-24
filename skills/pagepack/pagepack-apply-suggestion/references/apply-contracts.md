# Pagepack Apply Contracts

This reference defines the application contract for Pagepack patches. Read `../../pagepack-init/references/shared-contracts.md` first for Agent Scope, Suggestion Cache Protocol, and Language Policy.

## Script Contract

`scripts/apply.sh` is the single source of truth for apply behavior. The skill never reimplements its steps inline.

```text
usage: apply.sh [repo-root] [--patch <file>] [--dry-run]

pipeline
  1. parse unified diff headers (create vs patch semantics per file)
  2. existence guard: create targets must not exist, patch targets must
  3. baseHash guard: cache-sourced patches verify .last-suggestion.meta
     (sha256, first 12 hex chars); explicit patches skip this guard
  4. dry-run precheck: the whole diff must apply cleanly before any write
  5. verification baseline: run check-pack before writing
  6. apply the diff (POSIX patch; -p0 or -p1 auto-detected from headers)
  7. rerun check-pack; diff findings against the baseline
  8. report INTRODUCED / RESOLVED / PRE-EXISTING sections

exit codes
  0  applied cleanly; no findings introduced (or verification skipped,
     stated in output)
  3  applied, but the patch introduced new check findings
  1  guard blocked (BLOCKED: lines, nothing written) or apply failed
  2  usage error
```

Delete and rename operations are rejected by the guard. Renames are expressed as create plus router rewiring in suggest patches; stale documents are removed manually or via a dedicated cleanup patch reviewed by the maintainer.

## Input Sources

1. An explicit unified diff from the user, passed via `--patch <file>`. The cached meta is never consulted for explicit patches, so their baseHash safety depends on the user providing a fresh diff.
2. The tool runtime cache `.codebase/.last-suggestion.diff` with `.codebase/.last-suggestion.meta`, written by `pagepack-suggest-*` skills per the shared Suggestion Cache Protocol. This is the default and the only path with mechanical hash verification.

Example of an explicit patch:

```diff
--- AGENTS.md
+++ AGENTS.md
@@ -1,5 +1,8 @@
 # Agent Instructions

+Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
+
 ## Coding Style

 ...
```

For a new file the source path is `/dev/null` (create semantics).

## Guard Rules

The guard blocks stale or unsafe application before anything is written:

- create semantics: target must not exist (explicit user-confirmed overwrite is a manual exception, applied outside the script and reported clearly);
- patch semantics: target must exist;
- cache-sourced patches: every `baseHash` line in `.last-suggestion.meta` must match the current file hash;
- the full diff must pass a dry-run precheck;
- a missing, empty, or malformed cache with no explicit patch blocks with a recommendation to run a `pagepack-suggest-*` skill first.

## Post-Apply Verification

After a successful apply, the script reruns the `pagepack-check-pack` mechanical checks and compares against the pre-apply baseline:

```text
INTRODUCED    findings only in the post-apply run
              -> caused by this patch; report prominently with fix
                 routing from the check contracts
RESOLVED      baseline findings gone after apply -> fixed by this patch
PRE-EXISTING  findings in both runs -> prior debt, reported as notes
```

Rules:

- verification is automatic on every successful apply;
- if `.codebase/` or the check script is unavailable, verification is skipped and the output says so;
- verification never blocks or rolls back the applied patch — the patch was human-reviewed before apply; introduced findings get a recommended follow-up patch instead;
- adapter patches targeting files outside `.codebase/` still trigger verification; the pack state should be unchanged, and the baseline diff proves it.

## Reporting

Success summary should include:

- applied files, and whether each was created or patched;
- verification outcome: INTRODUCED / RESOLVED / PRE-EXISTING counts, or the skip reason.

Blocked summary should include:

- the `BLOCKED:` reasons verbatim;
- the recommendation to regenerate the patch via the owning `pagepack-suggest-*` capability.

Never print secrets or credential values when reporting hashes, files, or diffs.
