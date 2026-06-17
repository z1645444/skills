# Pagepack Apply Contracts

This reference defines the simplified application contract for Pagepack patches. Human-facing output uses the user's preferred language, defaulting to English; preserve file paths, command names, API names, framework names, component names, identifiers, and other technical proper nouns.

## Execution Order

Apply runs in this order:

```text
1. Resolve Agent Scope
2. Accept patch input
3. Run Apply Guard
4. Apply patch
5. Report result
```

No file write may happen before the guard passes.

## Agent Scope

Every apply run needs Agent Scope.

- If current agent is known, use it as the default scope.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- `--all` expands compatibility/adapter scope, not pack count.

## Input Format

The skill accepts a unified diff patch directly from the user. It does not read persisted suggestion JSON/MD bundles or a manifest.

Example:

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

An optional `baseHash` may accompany the patch for the target file. It is the only safety guard beyond file existence and clean patch application.

## Supported Operations

The input is always a unified diff. The diff implies one of:

- `create` semantics: source path is `/dev/null`;
- `patch` semantics: source path is an existing file.

Reject delete, move, chmod, shell commands, environment mutation, network actions, or hidden side effects. If a patch contains such operations, block and report.

## Apply Guard

Apply Guard blocks stale or unsafe application. It checks:

### File Existence

Verify that target file existence matches the patch:

- `create` semantics: target must not exist.
- `patch` semantics: target must exist.

If the user explicitly requests overwrite, treat it as a manual exception and report it clearly.

### Base Hash

If a `baseHash` is provided:

- compute the current target file hash;
- compare with the provided `baseHash`;
- mismatch -> block;
- missing target unexpectedly -> block.

If no `baseHash` is provided, proceed with file existence and clean patch checks only. This is allowed in the lightweight MVP, but callers are encouraged to provide `baseHash` when available.

## Patch Application

Apply the unified diff to the target file.

- Attempt clean application.
- If the patch fails, stop and report failure without leaving a partial file when possible.
- Parent directories may be created for new files.

## Reporting

Success summary should include:

- target file;
- whether the file was created or patched;
- any `baseHash` that was verified.

Blocked summary should include:

- failed guard;
- path involved;
- expected and current state when safe to show;
- recommendation to regenerate the patch.

Never print secrets or credential values when reporting hashes, files, or diffs.
