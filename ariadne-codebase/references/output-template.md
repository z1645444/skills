# Output Template For Codebase Guidance

Use this template when creating repo-local guidance such as `CODEBASE.md`, `docs/ai/CODEBASE.md`, a concise `AGENTS.md`/`CLAUDE.md` supplement, or a project-specific skill body. Delete sections that do not apply.

For small and medium repositories, one `CODEBASE.md` is usually enough. For large repositories, monorepos, or long-lived brownfield systems, prefer a split map so future sessions can load only the relevant documents.

## Split Codebase Map

When splitting the map, use these filenames and scopes:

- `STACK.md`: languages, runtimes, package managers, frameworks, build tools, key dependencies.
- `INTEGRATIONS.md`: external APIs, databases, storage, auth providers, observability, CI/CD, deployment.
- `ARCHITECTURE.md`: system layers, entry points, data flow, core abstractions, cross-cutting concerns.
- `STRUCTURE.md`: directory purposes, naming, where to add new files, special/generated directories.
- `CONVENTIONS.md`: style, imports, module boundaries, wrapper usage, error handling, comments, file granularity.
- `TESTING.md`: test tools, file locations, fixtures/mocks, commands, meaningful coverage gaps.
- `CONCERNS.md`: tech debt, fragile areas, performance risks, security risks, dependency risks, missing tests.

Keep `AGENTS.md` and `CLAUDE.md` short. Point them to the split map instead of duplicating details.

## Title

`# <Project Name> Codebase Guidance`

Start with 3-6 bullets that a future coding session must know before editing.

## Scope And Authority

- State which directories, packages, or apps the guidance covers.
- Link to existing `AGENTS.md`, `CLAUDE.md`, README files, ADRs, or framework docs.
- Link to project-local skills under `.claude/skills/`, `.agents/skills/`, `.codex/skills/`, or `skills/` when they define relevant conventions.
- State the evidence date or commit range if useful.
- State that repository code and local agent files override this document when they conflict.

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
- How to update agent guidance without duplicating details between `AGENTS.md`, `CLAUDE.md`, and shared docs.

## Sensitive Files

- Note secret-bearing files only by existence, never by content.
- Do not quote `.env`, `.env.*`, `*.env`, `.npmrc`, `.pypirc`, `.netrc`, private keys, certificates, service account JSON, `credentials.*`, `secrets.*`, `*secret*`, `*credential*`, or files under `secrets/` and `.secrets/`.
- Refer to environment variable names only when they are already documented in safe examples such as `.env.example`.

## Do Not Rules

Only include rules that are backed by codebase evidence:

- Do not create a second request client when `<path>` is the central API layer.
- Do not bypass `<framework wrapper>` for admin pages.
- Do not place feature-specific components in shared directories unless reused.

## Open Questions

List conflicts or weak evidence instead of guessing:

- `<question>`: observed `<path A>` but conflicting `<path B>`.

## Optional Project Skill Shape

When generating a project-specific skill, keep the skill small. Put curated examples in references or assets instead of pasting large modules into `SKILL.md`:

```markdown
---
name: <project-name>-codebase
description: Project-specific coding guidance for <project>. Use when making code changes in this repository, especially for module placement, framework wrappers, request APIs, UI patterns, tests, and agent docs.
---

# <Project Name> Codebase

Read `<repo-relative-path-to-guidance>` before editing. Follow local `AGENTS.md` or `CLAUDE.md` files first when they are more specific.

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
