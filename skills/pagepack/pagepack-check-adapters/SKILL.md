---
name: pagepack-check-adapters
description: Read-only check for Pagepack Agent Adapters. Use when verifying whether Codex, Claude Code, Gemini CLI, Cursor, Antigravity, or another supported coding agent has an entry file that explicitly points to `.codebase/router.md` and instructs the agent to follow Task Router routes before coding, without generating adapter suggestions or modifying entry files.
---

# Pagepack Check Adapters

## Overview

Use this skill to verify that agent entry files connect to the shared `.codebase/router.md` Task Router. It checks adapter wiring only; it must not create patches, modify entry files, duplicate Runtime Docs, or inspect pack freshness.

Generated human-facing output must use Simplified Chinese by default. Preserve file paths, command names, API names, agent names, framework names, identifiers, component names, and other technical proper nouns.

## Required Reference

Before checking adapters, read `references/adapter-check-contracts.md`. It defines Agent Scope handling, v1 agent entry files, success criteria, drift-risk detection, and JSON output shape.

## Workflow

1. Resolve Agent Scope.
   - Default to current agent only when reliably known.
   - If current agent is unknown and neither `--agent` nor `--all` is provided, stop and ask for explicit scope.
   - `--all` expands adapter check scope only; it must not create multiple `.codebase/` variants.

2. Select target agents.
   - Current agent by default.
   - Specific agent when `--agent <name>` is provided.
   - All supported v1 agents when `--all` is provided.

3. Locate entry files.
   - `codex`: `AGENTS.md`.
   - `claude`: `CLAUDE.md`.
   - `gemini`: `GEMINI.md`.
   - `cursor`: `.cursor/rules/*.md` or `.cursorrules`, according to current project layout.
   - `antigravity`: use registry entry when defined; otherwise report unsupported/unknown mapping.

4. Evaluate adapter quality.
   - Entry file exists and is readable.
   - It explicitly references `.codebase/router.md`.
   - It instructs the agent to follow Task Router routes before coding.
   - It does not copy large `.codebase/` Runtime Docs into the entry file.

5. Report status.
   - Default to a human-readable summary.
   - If `--json` is requested, emit machine-readable status.
   - Clearly separate `ok`, `warning`, and `error`.
   - Recommend `pagepack-suggest-adapters` when a patch is needed.

## Success Criteria

An adapter is connected only when all are true:

- expected entry file exists;
- entry file references `.codebase/router.md`;
- entry file tells the agent to read by task route before coding;
- entry file stays thin and does not duplicate Runtime Docs.

## Drift Risk Warnings

Warn when:

- the entry file copies UI/framework/module rules instead of pointing to router;
- the entry file points to `.codebase/` but not `.codebase/router.md`;
- the entry file references stale docs such as `docs/ai/CODEBASE.md` as the primary source of truth;
- multiple agent entry files contain inconsistent project guidance.

## Out Of Scope

Do not:

- write or patch entry files;
- create `.codebase/`;
- generate `.codebase/meta/suggestions/`;
- check source freshness;
- validate the semantic quality of Runtime Docs;
- apply adapter suggestions.

## Failure Rules

Stop or report error when:

- Agent Scope is unknown and no explicit scope is provided;
- requested agent is unsupported;
- expected entry file exists but is unreadable;
- entry file is missing;
- entry file fails the router instruction criteria.

## Validation Checklist

Before finishing:

- No file was written.
- No suggestion was created.
- Target agent scope is clear.
- The check did more than file-exists detection.
- Output explains whether `.codebase/router.md` is explicitly used.
- Human-facing output is Simplified Chinese with technical proper nouns preserved.
