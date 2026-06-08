---
name: ariadne-codebase
description: Create or refresh project-specific session memory for AI coding agents by analyzing a real codebase's mature module structure, configuration, dependency stack, recent git history, request/data-access patterns, framework wrappers, and UI/UX conventions. Use when Codex, Claude Code, or Gemini CLI needs repo-local CODEBASE guidance, AGENTS.md/CLAUDE.md/GEMINI.md entry points, or a project-specific skill to reduce coding drift around file granularity, component usage, API/request functions, React/admin framework usage, and product UI patterns.
---

# Ariadne Codebase

## Overview

Generate evidence-backed project session memory that future coding agents can load before making changes. Prefer documenting real conventions from the repository over inventing generic best practices.

The intended durable output is a curated project memory layer for Codex, Claude Code, and Gemini CLI sessions, not just a one-time scan report. Keep raw survey output disposable, then write concise repo-local guidance that captures code format, module boundaries, component usage, request/data-access patterns, and existing UI/UX conventions.

## Workflow

1. Establish the target output.
   - If the user asks for "codebase docs", "project memory", or session guidance, create or update the default repo-local memory file at `docs/ai/CODEBASE.md`.
   - If the repository already has an equivalent guidance location, update that file instead and keep the entry points pointing to it.
   - If the user asks to guide Codex, Claude Code, or Gemini CLI, update the appropriate short entry point and point it to the shared guidance file when possible:
     - `AGENTS.md` for Codex-compatible agents.
     - `CLAUDE.md` for Claude Code.
     - `GEMINI.md` for Gemini CLI.
   - If the user asks for a reusable project skill, create a focused skill that loads the generated guidance and any project-specific references.
   - For large or long-lived repositories, prefer a split project memory map under `docs/ai/` over one huge document: `CODEBASE.md`, `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `UI_UX.md`, `TESTING.md`, and `CONCERNS.md`.

2. Collect repository evidence before writing guidance.
   - Run the bundled survey script from this skill directory when a repository is available. Keep this raw survey as temporary evidence, usually outside the repository:

     ```bash
     python3 scripts/survey_codebase.py <repo-root> --output /tmp/codebase-survey.md
     ```

   - Read the generated survey, then inspect the high-signal files it identifies. Do not treat `/tmp/codebase-survey.md` as durable project memory.
   - Also inspect existing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, README files, package/build configs, route/menu definitions, request clients, API/service folders, shared UI components, and representative mature feature modules.
   - If `.claude/skills/`, `.agents/skills/`, `.codex/skills/`, or `skills/` exists in the project, read each local `SKILL.md` as a lightweight index before inferring conventions. Load deeper skill references only when relevant.
   - Do a quick pass over detected `example`, `examples`, `best-practice`, `best-practices`, `case`, `cases`, `sample`, `demo`, or `recipe` directories. Treat them as useful leads, then verify whether current production code still follows them.
   - Use recent git history to distinguish current direction from legacy code. Prefer recently maintained mature modules over isolated old examples.

3. Identify the project's actual coding contract.
   - Document directory boundaries, module granularity, file naming, component/hook/service splits, request/data-access wrappers, form/table patterns, routing, permissions, state management, styling, i18n, error handling, validation, tests, and codegen/typegen conventions.
   - For repositories with user-facing UI, admin pages, or shared design components, create or update `docs/ai/UI_UX.md` when using a split project memory map.
   - In `UI_UX.md`, record the component library, internal wrappers, page layout patterns, table/list patterns, form validation and modal patterns, detail page conventions, copy language, empty/loading/error states, and mature screens to follow.
   - Document components, styles, or UX patterns that should not be recreated when a shared implementation already exists.
   - Include file references for every important claim. If a convention is inferred from one example only, label it low confidence.
   - Assign confidence to important rules:
     - `high confidence`: backed by several current production examples, source types, or enforced tooling.
     - `medium confidence`: backed by one or two current examples or consistent docs that do not conflict with code.
     - `low confidence`: inferred from a single example, stale-looking code, copied examples, or mixed evidence.
   - Write low-confidence observations as leads for future verification, not as mandatory rules.
   - Separate observed conventions from recommendations. Do not present personal preference as project policy.

4. Handle React/admin systems carefully.
   - If the project looks like an admin/management system, determine whether it uses a wrapped framework or internal platform layer before proposing code.
   - Read `references/admin-framework-checklist.md` when React, admin UI packages, route/menu metadata, generated APIs, or internal wrapper components are present.
   - Base guidance on the real framework API, source types, and existing call sites. Do not invent request helpers, page layouts, table/form APIs, permission hooks, or route metadata shapes.
   - For admin systems, make `UI_UX.md` operational: name the canonical table, form, modal, layout, permission, and navigation patterns with exact imports or source files.

5. Write concise, operational guidance.
   - Use `references/output-template.md` when creating a new guidance document.
   - Put the canonical project memory in `docs/ai/CODEBASE.md` unless the repository already has a clear local equivalent.
   - Add this marker header near the top of every canonical project memory document, before the title when possible:

     ```markdown
     <!-- ariadne-codebase: project-memory v1 -->
     <!-- Purpose: canonical project guidance for Codex, Claude Code, and Gemini CLI sessions. -->
     <!-- Last evidence refresh: <date>, commit <sha-or-branch>. -->
     ```

   - This header marks curated session memory, not generated-only output. Human corrections are allowed and should preserve the marker.
   - Keep `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` as short entry points. They should tell the agent to read the canonical project memory and avoid duplicating detailed rules:

     ```markdown
     Read `docs/ai/CODEBASE.md` before editing. Follow more specific local agent files when present.
     ```

   - Keep the top of the document short enough for future sessions to scan quickly.
   - For split maps, write separate focused documents instead of duplicating one large overview: `CODEBASE.md`, `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `UI_UX.md`, `TESTING.md`, and `CONCERNS.md`.
   - Add "do not" rules only when the codebase gives clear evidence, such as an existing request wrapper or generated API layer.
   - If examples or best-practice folders exist, document which ones are canonical, stale, generated, or only useful as narrow fallback references.
   - Record unresolved questions instead of guessing when evidence conflicts.
   - For every rule that affects where code goes, how APIs are called, or which UI patterns are allowed, include source paths or state why the evidence is incomplete.

6. Validate the result.
   - Check that the guidance would answer: where to put a new feature, how large files should be, how to call APIs, how to use shared framework components, and which commands/tests to run.
   - Verify links and file paths.
   - Ensure no secrets, tokens, or `.env` values were copied into the output.
   - If modifying `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`, keep those files short and point to the detailed shared document to avoid drift.

## Project Skill Example Resources

When generating a project-specific skill, include examples only when they reduce repeated coding drift around structure, wrappers, or boilerplate.

- Prefer `references/examples/` for concise, readable pattern notes or small excerpts that agents should inspect before coding.
- Prefer `assets/templates/` for copyable skeletons, starter files, or boilerplate that the agent may duplicate into the project.
- A root `examples/` or `example/` folder is acceptable only when the user or target tool convention explicitly wants that shape. Link it from `SKILL.md`; do not assume agents will discover it automatically.
- Keep examples curated. Include common page/module skeletons, request/service patterns, table/form patterns, and test patterns; avoid dumping entire production modules.
- For every example, state whether it is canonical, fallback-only, legacy, or experimental, and point to the production source that justifies it.

## Evidence Standards

- Prefer three or more consistent examples for a convention. One example is a lead, not a rule.
- Prefer source code and types over README claims when they conflict.
- Prefer local wrappers over underlying libraries. For example, document the project's `request`, `http`, `apiClient`, table, form, layout, and permission abstractions before mentioning `fetch`, `axios`, `antd`, or router primitives.
- Treat generated files, copied demos, and deprecated modules as low-authority unless the repo clearly uses them as the current pattern.
- Mark confidence explicitly when evidence is weak or mixed. Use `low confidence` and `open question` rather than converting uncertainty into policy.
- Preserve existing user or agent docs. Extend them surgically instead of replacing them wholesale.

## Sensitive File Rules

- Never read or quote secret-bearing files such as `.env`, `.env.*`, `*.env`, `.npmrc`, `.pypirc`, `.netrc`, `credentials.*`, `secrets.*`, `*secret*`, `*credential*`, private keys, certificates, keystores, service account JSON, or files under `secrets/` and `.secrets/`.
- It is acceptable to note that such files exist and that environment configuration is required.
- Never copy tokens, keys, passwords, or credential-like values into generated guidance.

## Resource Guide

- `scripts/survey_codebase.py`: Generate a markdown survey of structure, configs, dependencies, recent commits, recently touched files, local project skills, sensitive file existence, example/best-practice/case directories, candidate mature modules, request wrappers, React/admin signals, TODO/FIXME signals, and large source files.
- `references/output-template.md`: Use when drafting `CODEBASE.md`, agent guidance, or a project-specific skill body.
- `references/admin-framework-checklist.md`: Use when the project may have a React/admin framework wrapper or internal platform layer.
