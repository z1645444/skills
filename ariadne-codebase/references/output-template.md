# Output Template For Codebase Guidance

Use this template when creating repo-local session memory such as `docs/ai/CODEBASE.md`, a concise `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` supplement, or a project-specific skill body. Delete sections that do not apply.

For small and medium repositories, one `docs/ai/CODEBASE.md` is usually enough. For large repositories, monorepos, or long-lived brownfield systems, prefer a split map under `docs/ai/` so future sessions can load only the relevant documents.

Every canonical project memory document should preserve this marker header near the top:

```markdown
<!-- ariadne-codebase: project-memory v1 -->
<!-- Purpose: canonical project guidance for Codex, Claude Code, and Gemini CLI sessions. -->
<!-- Last evidence refresh: <date>, commit <sha-or-branch>. -->
```

This marks curated session memory, not generated-only output. Human corrections are allowed.

## Output Mode

Choose one primary output shape before writing:

- Single document: write `docs/ai/CODEBASE.md` with the full section order below. Use this for small and medium repositories.
- Split map: write `docs/ai/CODEBASE.md` as a short entry map, then put detailed guidance in focused files under `docs/ai/`. Use this for large repositories, monorepos, or long-lived systems.
- Entrypoint update only: when a canonical memory document already exists and is current, add or verify a pointer in `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` without replacing existing rules.

Do not duplicate long guidance between `CODEBASE.md` and split files. In split mode, `CODEBASE.md` should contain only fast rules, required reads, map links, and the most important open questions.

## Split Codebase Map

When splitting the map, use these filenames and scopes:

- `CODEBASE.md`: short entry map, highest-impact rules, required reads, and links to split documents.
- `STACK.md`: languages, runtimes, package managers, frameworks, build tools, key dependencies.
- `INTEGRATIONS.md`: external APIs, databases, storage, auth providers, observability, CI/CD, deployment.
- `ARCHITECTURE.md`: system layers, entry points, data flow, core abstractions, cross-cutting concerns.
- `STRUCTURE.md`: directory purposes, naming, where to add new files, special/generated directories.
- `CONVENTIONS.md`: style, imports, module boundaries, wrapper usage, error handling, comments, file granularity.
- `UI_UX.md`: design system, shared components, layout patterns, tables, forms, modals, copy rules, and mature UI examples.
- `TESTING.md`: test tools, file locations, fixtures/mocks, commands, meaningful coverage gaps.
- `CONCERNS.md`: tech debt, fragile areas, performance risks, security risks, dependency risks, missing tests.

In split mode, `CODEBASE.md` must include a task-based read map near the top:

```markdown
## Required Reads By Task

- Any code change: read `STRUCTURE.md` and `CONVENTIONS.md`.
- UI/page change: also read `UI_UX.md`.
- API/integration change: also read `INTEGRATIONS.md`.
- Architecture or cross-module change: also read `ARCHITECTURE.md`.
- Dependency/build tooling change: also read `STACK.md`.
- Test or behavior change: also read `TESTING.md`.
- Risky legacy area or large file: also read `CONCERNS.md`.
```

Keep newly created `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` files short. For existing files, preserve their rules and add only a pointer to the split map or canonical memory document.

## Section Order

For a full single-document `CODEBASE.md`, keep sections in this order:

1. Marker header and title.
2. Fast rules: 3-6 bullets that matter before editing.
3. Scope and authority.
4. Evidence and confidence.
5. Stack and commands.
6. Directory and module shape.
7. Mature examples and example-source ranking.
8. UI/framework and UI/UX memory.
9. Data access, API usage, state, validation, and business logic.
10. Testing and verification.
11. Concerns, sensitive files, do-not rules, and open questions.
12. Documentation and agent-entry rules.

For split maps, keep this same progression across the focused files instead of copying every section into every file.

## Agent Entry Points

Use these root files as pointers to the shared project memory:

- `AGENTS.md`: Codex-compatible agents.
- `CLAUDE.md`: Claude Code.
- `GEMINI.md`: Gemini CLI.

When the file is missing or empty, use a short body. When it already contains project or tool-specific rules, insert or append only this pointer and preserve the rest of the file:

```markdown
Read `docs/ai/CODEBASE.md` before editing. Follow this file and more specific local agent files when they add stricter rules.
```

## Title

```markdown
<!-- ariadne-codebase: project-memory v1 -->
<!-- Purpose: canonical project guidance for Codex, Claude Code, and Gemini CLI sessions. -->
<!-- Last evidence refresh: <date>, commit <sha-or-branch>. -->

# <Project Name> Codebase Guidance
```

Start with 3-6 bullets that a future coding session must know before editing.

## Scope And Authority

- State which directories, packages, or apps the guidance covers.
- Link to existing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, README files, ADRs, or framework docs.
- Link to project-local skills under `.claude/skills/`, `.agents/skills/`, `.codex/skills/`, or `skills/` when they define relevant conventions.
- State the evidence date or commit range if useful.
- State that repository code and local agent files override this document when they conflict.

## Evidence And Confidence

Use confidence labels for rules that affect implementation choices:

- `high confidence`: backed by several current production examples, source types, generated APIs, tests, or enforced tooling.
- `medium confidence`: backed by one or two current examples or documentation that matches the code.
- `low confidence`: inferred from a single example, stale-looking code, copied examples, or mixed evidence.

For important rules, include source paths:

- `<rule>`: `<confidence>`; evidence: `<path>`, `<path>`.
- `<rule>`: `low confidence`; observed `<path>`, but verify before applying broadly.

Do not turn low-confidence observations into mandatory rules. Move conflicts and missing evidence to `Open Questions`.

## Stack And Commands

- Package manager, runtime, framework, language, styling, test runner, build tool.
- Common commands for install, dev, lint, typecheck, test, build, codegen.
- Environment assumptions without copying secrets.

## Directory And Module Shape

- Top-level layout and ownership boundaries.
- Feature/module directory pattern.
- File granularity expectations.
- Naming conventions.
- Where new pages, components, hooks, services, schemas, tests, and styles belong.

## Mature Examples To Follow

List representative modules with one-line reasons:

- `<path>`: mature page/module using current route, request, state, and UI patterns.
- `<path>`: mature shared component or framework wrapper usage.
- `<path>`: mature test or integration example.

Avoid using generated output, copied demos, deprecated modules, and one-off experiments as primary examples.

## Example/Best Practice/Case Sources

- `<path>`: canonical example, actively aligned with production code.
- `<path>`: useful fallback for `<narrow scenario>`, but verify against `<production path>`.
- `<path>`: stale or legacy; do not use for new work except historical context.

If the repository has `example`, `examples`, `best-practice`, `best-practices`, `case`, `cases`, `sample`, `demo`, or `recipe` directories, scan them early but rank them below current production modules unless the project explicitly treats them as canonical.

## UI And Framework Usage

- Shared layout/page shell components.
- Table/list/detail/form/modal patterns.
- Routing and menu metadata.
- Permissions/access control.
- Styling and design system conventions.
- i18n and user-facing text conventions.

For admin systems, describe the internal wrapper API with exact imports and props. Include short examples only when they are copied from or directly derived from real call sites.

## UI/UX Memory

When the repository has user-facing UI, admin pages, or shared design components, keep `UI_UX.md` focused on operational patterns:

- Component library and internal wrappers: exact imports, source files, and when to use each wrapper.
- Layout patterns: page shells, toolbars, filters, sidebars, tabs, detail panes, and responsive behavior.
- Tables and lists: canonical table component, column definitions, search/filter layout, pagination, row actions, bulk actions, loading and empty states.
- Forms and modals: form wrapper, validation style, submit/cancel behavior, modal sizing, drawer usage, field grouping, error display.
- Detail pages: summary/header pattern, metadata placement, action buttons, related lists, audit/status sections.
- Copy and language: user-facing language, terminology, capitalization, units, dates, empty/error text style.
- Visual conventions: spacing, density, colors, icons, button hierarchy, destructive actions, disabled states.
- Mature examples: screens or modules to follow, with one-line reasons and evidence paths.
- Do not recreate: shared components, styles, layouts, or UX flows that already have canonical implementations.

Every UI/UX rule should include evidence paths and a confidence label when the pattern is not enforced by code.

## Data Access And API Usage

- Request client or generated API layer.
- Service function naming and placement.
- Query/mutation hooks or state management.
- Error handling, loading states, auth headers, retries, caching.
- Mocking or local development data.

Add a clear rule such as "Do not call `fetch` directly" only when the repository consistently uses a wrapper or generated client.

## State, Validation, And Business Logic

- Local state versus global store conventions.
- Form validation/schema conventions.
- Domain/business logic placement.
- Date, number, currency, and enum handling.

## Testing And Verification

- Test locations and naming.
- Unit/integration/e2e boundaries.
- What to run for common change types.
- Known slow or flaky checks.

## Concerns And Risk Areas

- Large source files or modules that require careful edits.
- TODO/FIXME/HACK clusters.
- Fragile areas with weak tests.
- Known performance, security, dependency, or maintainability risks.
- Current mitigation and the safest modification path.

## Documentation Rules

- Where to update docs for new public behavior.
- How to update agent guidance without duplicating details between `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and shared docs.

## Sensitive Files

- Note secret-bearing files only by existence, never by content.
- Do not quote `.env`, `.env.*`, `*.env`, `.npmrc`, `.pypirc`, `.netrc`, private keys, certificates, service account JSON, `credentials.*`, `secrets.*`, `*secret*`, `*credential*`, or files under `secrets/` and `.secrets/`.
- Refer to environment variable names only when they are already documented in safe examples such as `.env.example`.

## Do Not Rules

Only include rules that are backed by codebase evidence:

- Do not create a second request client when `<path>` is the central API layer.
- Do not bypass `<framework wrapper>` for admin pages.
- Do not place feature-specific components in shared directories unless reused.

Each do-not rule should include at least one evidence path or be removed.

## Open Questions

List conflicts or weak evidence instead of guessing:

- `<question>`: observed `<path A>` but conflicting `<path B>`.
- `<question>`: `low confidence`; only one current example found at `<path>`.

## Optional Project Skill Shape

When generating a project-specific skill, keep the skill small. Put curated examples in references or assets instead of pasting large modules into `SKILL.md`:

```markdown
---
name: <project-name>-codebase
description: Project-specific coding guidance for <project>. Use when making code changes in this repository, especially for module placement, framework wrappers, request APIs, UI patterns, tests, and agent docs.
---

# <Project Name> Codebase

Read `<repo-relative-path-to-guidance>` before editing. Follow local `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` files first when they are more specific.

## Fast Rules

- <3-8 highest-impact rules>

## Required Reads

- `<path>`: complete codebase guidance.
- `<path>`: framework wrapper source or local API reference.
- `<path>`: mature module example.

## Examples

- `references/examples/<pattern>.md`: readable pattern notes or compact excerpts.
- `assets/templates/<skeleton>/`: copyable starter structure for new modules.
- `examples/<name>/`: only if the user/tooling explicitly expects a root examples folder; link it here.
```

Example resources should be curated and labeled:

- `canonical`: default pattern for new work.
- `fallback`: useful when no mature module covers the task.
- `legacy`: useful only to understand old code.
- `experimental`: not a production convention.
