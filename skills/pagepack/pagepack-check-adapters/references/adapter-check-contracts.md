# Pagepack Adapter Check Contracts

This reference defines the v1 read-only adapter check contract. Human-facing output defaults to Simplified Chinese; preserve file paths, command names, API names, agent names, framework names, component names, identifiers, and other technical proper nouns.

## Scope

`pagepack-check-adapters` checks whether agent entry files are thin Agent Adapters pointing to `.codebase/router.md`.

It checks:

- Agent Scope;
- expected entry file presence;
- explicit `.codebase/router.md` reference;
- instruction to follow Task Router routes before coding;
- copied or duplicated Runtime Docs that could drift.

It does not:

- generate adapter suggestions;
- modify entry files;
- inspect source freshness;
- validate Runtime Docs content;
- apply patches.

## Agent Scope

Every adapter check needs an explicit scope.

```text
current agent
  -> check only current agent

--agent codex
  -> check Codex entry only

--all
  -> check all supported agent entries

unknown current agent without --agent/--all
  -> stop and ask for explicit scope
```

Do not use generic fallback. Do not infer current agent from the mere presence of an entry file.

## V1 Adapter Registry

```text
codex
  AGENTS.md

claude
  CLAUDE.md

gemini
  GEMINI.md

cursor
  .cursor/rules/*.md
  .cursorrules

antigravity
  registry entry required; if unknown, report unsupported mapping
```

Do not create per-agent capability names such as `pagepack-check-codex-adapter`.

## Connected Adapter Criteria

An adapter is `ok` only when all criteria pass:

1. Entry file exists.
2. Entry file is readable.
3. Entry file explicitly references `.codebase/router.md`.
4. Entry file instructs the agent to follow Task Router routes before coding.
5. Entry file does not duplicate substantial Runtime Docs or project rules.

Minimal acceptable instruction:

```md
Before coding, read `.codebase/router.md` and follow the task route for the current request. Load only the Runtime Docs required by that route unless broader context is necessary.
```

Equivalent wording is acceptable if it preserves the same behavior.

## Status Levels

```text
ok
  Adapter is connected and thin.

warning
  Adapter exists but is weak, ambiguous, or contains drift risk.

error
  Adapter is missing, unreadable, unsupported, or does not point to router.
```

Examples:

- `AGENTS.md` missing -> `error`
- `AGENTS.md` says "read .codebase" but not `router.md` -> `warning` or `error` depending on strictness
- `AGENTS.md` points to `docs/ai/CODEBASE.md` only -> `warning`
- `AGENTS.md` copies UI/framework rules -> `warning`
- `AGENTS.md` references `.codebase/router.md` and task routes -> `ok`

## Drift Risk Detection

Report drift risk when an entry file includes:

- copied UI rules;
- copied framework API guidance;
- copied Page Recipe content;
- copied module granularity guidance;
- detailed rules that should live under `.codebase/`;
- guidance that conflicts across agent entry files.

The expected adapter is thin. It should point to router, not become a knowledge source.

## Human Summary

Default output should include:

- overall status;
- checked agents;
- entry files inspected;
- per-agent adapter status;
- errors;
- warnings;
- recommended next command.

Recommended command when adapter is missing or weak:

```text
pagepack-suggest-adapters
```

Use `pagepack-suggest-adapters --agent <name>` when the user checked a specific agent.

## JSON Output

When `--json` is requested, output a stable structure:

```json
{
  "status": "warning",
  "agentScope": ["codex"],
  "adapters": [
    {
      "agent": "codex",
      "entryFile": "AGENTS.md",
      "status": "warning",
      "routerReferenced": true,
      "taskRouteInstruction": false,
      "driftRisk": false,
      "message": "Entry references router but does not require following task routes before coding."
    }
  ],
  "recommended": ["pagepack-suggest-adapters --agent codex"]
}
```

Do not write JSON output to the repository unless the user explicitly redirects it outside the skill.

## Security

Only inspect known agent entry files. Do not read secret-bearing files. If an entry file contains credential-like values, do not print them.
