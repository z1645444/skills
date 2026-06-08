---
name: ariadne-codebase
description: Create or update project-specific AI coding guidance by analyzing a real codebase's mature module structure, configuration, dependency stack, recent git history, request/data-access patterns, and framework wrappers. Use when Codex needs to generate CODEBASE.md, AGENTS.md/CLAUDE.md guidance, or a project-specific skill to reduce coding style drift around file granularity, directory layout, API/request functions, React/admin framework usage, and implementation conventions.
---

# Ariadne Codebase

## Overview

Generate evidence-backed project guidance that future coding agents can use before making changes. Prefer documenting real conventions from the repository over inventing generic best practices.

## Workflow

1. Establish the target output.
   - If the user asks for "codebase docs", create or update a repo-local guidance file such as `CODEBASE.md`, `docs/ai/CODEBASE.md`, or the existing local equivalent.
   - If the user asks to guide Codex or Claude Code, update the appropriate short entry point (`AGENTS.md` for Codex-compatible agents, `CLAUDE.md` for Claude Code) and point it to the shared guidance file when possible.
   - If the user asks for a reusable project skill, create a focused skill that loads the generated guidance and any project-specific references.
   - For large or long-lived repositories, prefer a split codebase map over one huge document: stack, integrations, architecture, structure, conventions, testing, and concerns.

2. Collect repository evidence before writing guidance.
   - Run the bundled survey script from this skill directory when a repository is available:

     ```bash
     python3 scripts/survey_codebase.py <repo-root> --output /tmp/codebase-survey.md
     ```

   - Read the generated survey, then inspect the high-signal files it identifies.
   - Also inspect existing `AGENTS.md`, `CLAUDE.md`, README files, package/build configs, route/menu definitions, request clients, API/service folders, shared UI components, and representative mature feature modules.
   - If `.claude/skills/`, `.agents/skills/`, `.codex/skills/`, or `skills/` exists in the project, read each local `SKILL.md` as a lightweight index before inferring conventions. Load deeper skill references only when relevant.
   - Do a quick pass over detected `example`, `examples`, `best-practice`, `best-practices`, `case`, `cases`, `sample`, `demo`, or `recipe` directories. Treat them as useful leads, then verify whether current production code still follows them.
   - Use recent git history to distinguish current direction from legacy code. Prefer recently maintained mature modules over isolated old examples.

3. Identify the project's actual coding contract.
   - Document directory boundaries, module granularity, file naming, component/hook/service splits, request/data-access wrappers, form/table patterns, routing, permissions, state management, styling, i18n, error handling, validation, tests, and codegen/typegen conventions.
   - Include file references for every important claim. If a convention is inferred from one example only, label it low confidence.
   - Separate observed conventions from recommendations. Do not present personal preference as project policy.

4. Handle React/admin systems carefully.
   - If the project looks like an admin/management system, determine whether it uses a wrapped framework or internal platform layer before proposing code.
   - Read `references/admin-framework-checklist.md` when React, admin UI packages, route/menu metadata, generated APIs, or internal wrapper components are present.
   - Base guidance on the real framework API, source types, and existing call sites. Do not invent request helpers, page layouts, table/form APIs, permission hooks, or route metadata shapes.

5. Write concise, operational guidance.
   - Use `references/output-template.md` when creating a new guidance document.
   - Keep the top of the document short enough for future sessions to scan quickly.
   - For split maps, write separate focused documents instead of duplicating one large overview: `STACK.md`, `INTEGRATIONS.md`, `ARCHITECTURE.md`, `STRUCTURE.md`, `CONVENTIONS.md`, `TESTING.md`, and `CONCERNS.md`.
   - Add "do not" rules only when the codebase gives clear evidence, such as an existing request wrapper or generated API layer.
   - If examples or best-practice folders exist, document which ones are canonical, stale, generated, or only useful as narrow fallback references.
   - Record unresolved questions instead of guessing when evidence conflicts.

6. Validate the result.
   - Check that the guidance would answer: where to put a new feature, how large files should be, how to call APIs, how to use shared framework components, and which commands/tests to run.
   - Verify links and file paths.
   - Ensure no secrets, tokens, or `.env` values were copied into the output.
   - If modifying `AGENTS.md` or `CLAUDE.md`, keep those files short and point to the detailed shared document to avoid drift.

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
- Preserve existing user or agent docs. Extend them surgically instead of replacing them wholesale.

## Sensitive File Rules

- Never read or quote secret-bearing files such as `.env`, `.env.*`, `*.env`, `.npmrc`, `.pypirc`, `.netrc`, `credentials.*`, `secrets.*`, `*secret*`, `*credential*`, private keys, certificates, keystores, service account JSON, or files under `secrets/` and `.secrets/`.
- It is acceptable to note that such files exist and that environment configuration is required.
- Never copy tokens, keys, passwords, or credential-like values into generated guidance.

## Resource Guide

- `scripts/survey_codebase.py`: Generate a markdown survey of structure, configs, dependencies, recent commits, recently touched files, local project skills, sensitive file existence, example/best-practice/case directories, candidate mature modules, request wrappers, React/admin signals, TODO/FIXME signals, and large source files.
- `references/output-template.md`: Use when drafting `CODEBASE.md`, agent guidance, or a project-specific skill body.
- `references/admin-framework-checklist.md`: Use when the project may have a React/admin framework wrapper or internal platform layer.
