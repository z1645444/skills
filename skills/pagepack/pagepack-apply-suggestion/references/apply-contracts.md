# Pagepack Apply Contracts

This reference defines the v1 application contract for Pagepack Suggestions. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, framework names, component names, identifiers, and suggestion ids.

## Execution Order

Apply must always run in this order:

```text
1. Resolve Agent Scope
2. Locate suggestion JSON and review summary
3. Parse Suggestion Schema
4. Run Apply Guard
5. Execute Bundle Apply
6. Report result
```

No file write may happen before Apply Guard passes.

## Agent Scope

Every apply run needs Agent Scope.

- If current agent is known, use it as the default scope.
- If current agent is unknown, stop and ask for `--agent` or `--all`.
- A suggestion scoped to `codex` must not be applied under `claude` unless the user explicitly passes `--agent codex` or an allowed `--all` flow.
- `--all` expands compatibility/adapter scope, not pack count.

## Suggestion Schema

v1 suggestion JSON must include:

```json
{
  "schemaVersion": "1.0.0",
  "id": "refresh-20260610-001",
  "type": "refresh-pack",
  "createdAt": "2026-06-10T10:00:00Z",
  "createdBy": "pagepack-suggest-refresh",
  "agentScope": ["codex"],
  "risk": "medium",
  "sourceFingerprints": {},
  "targetPreconditions": [],
  "operations": [],
  "reviewSummaryPath": ".codebase/meta/suggestions/refresh-20260610-001.md"
}
```

Reject:

- unsupported schema major version;
- missing required fields;
- unsupported suggestion type;
- unsupported operation action;
- ambiguous or missing `agentScope`.

## Supported Suggestion Types

v1 apply may support these types as they are implemented:

```text
pack-recovery
refresh-pack
adapter-patch
recipe-candidate
rules-candidate
```

If a type is unknown, block instead of guessing.

## Supported Operations

`create`:

```json
{
  "action": "create",
  "path": ".codebase/router.md",
  "content": "..."
}
```

`replace`:

```json
{
  "action": "replace",
  "path": ".codebase/knowledge/ui-patterns.md",
  "baseHash": "sha256:...",
  "content": "..."
}
```

`patch`:

```json
{
  "action": "patch",
  "path": "AGENTS.md",
  "baseHash": "sha256:...",
  "patch": "unified diff..."
}
```

Reject delete, move, chmod, shell commands, environment mutation, network actions, or hidden side effects.

## Apply Guard

Apply Guard blocks stale or unsafe application. It checks:

### Source Fingerprints

Recompute each source fingerprint in `sourceFingerprints`.

- If all match, continue.
- If any differ, block and recommend rerunning the producing `pagepack-suggest-*` capability.
- Do not use time as the primary expiry signal. Time may be a warning only.

### Target Preconditions

Check every precondition before writing. Common v1 conditions:

```json
{
  "path": ".codebase/router.md",
  "condition": "must_not_exist"
}
```

```json
{
  "path": "AGENTS.md",
  "condition": "hash_equals",
  "hash": "sha256:..."
}
```

If a target file changed after the suggestion was created, block.

### Base Hash

For `replace` and `patch`, current target hash must equal `baseHash`.

- mismatch -> block;
- missing `baseHash` -> block unless operation type explicitly does not need it;
- target missing unexpectedly -> block.

### File Ownership

Read `.codebase/meta/manifest.json` when available.

Rules:

- `generated` may be replaced with `baseHash` guard.
- `reviewed` blocks replace; use patch or explicit review.
- `manual` blocks replace; use patch or user edit.
- `unknown` blocks replace.

For initial bootstrap before manifest exists, ownership is established by the bundle. Existing target files still require preconditions.

### Contract Compatibility

Check that current apply capability understands:

- suggestion schema;
- suggestion type;
- operation actions;
- target precondition conditions;
- agent scope.

Unknown contract elements block apply.

## Bundle Apply

Bundle Apply is the final application step.

- Execute only after all guards pass.
- Treat operations as one logical bundle.
- Do not skip one failing operation and continue.
- Prefer preflight checks for all operations before writing the first file.
- If a write fails despite preflight, stop and report exact partial state.

## Reporting

Success summary should include:

- suggestion id;
- suggestion type;
- applied operations;
- changed files;
- manifest changes if any.

Blocked summary should include:

- failed guard;
- path or source key involved;
- expected value and current value when safe to show;
- recommended next command.

Never print secrets or credential values when reporting hashes, files, or diffs.
