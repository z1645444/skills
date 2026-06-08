# React/Admin Framework Checklist

Use this checklist when the repository appears to be a management system, dashboard, CRM, CMS, internal platform, or React project with heavy framework wrappers.

## Detection Signals

Look for these before writing guidance:

- Packages: `antd`, `@ant-design/pro-components`, `@umijs/max`, `umi`, `react-admin`, `@refinedev/*`, `@arco-design/web-react`, `@douyinfe/semi-ui`, `ahooks`, `@tanstack/react-query`, `swr`, `axios`, `umi-request`.
- Directories: `src/pages`, `src/routes`, `src/models`, `src/services`, `src/api`, `src/components`, `src/layouts`, `src/access`, `src/framework`, `src/platform`.
- Files: route/menu config, permission/access config, request client, table/form wrappers, generated API clients, OpenAPI config, mock config.
- Patterns: page metadata, route-based layout, permission fields, generated service functions, table schema config, modal form wrappers, search form/table composition.

## Required Reads

Before documenting or using the framework, inspect:

- The wrapper source and exported types.
- At least three mature call sites for each wrapper pattern.
- Route/menu/permission configuration used by current pages.
- The request client and generated service layer.
- Recent commits touching pages, services, framework components, routes, or permissions.

## Questions To Answer

- Is the project using a public framework directly, an internal wrapper over a public framework, or both?
- What is the canonical way to create a page: route file, config entry, page component, model/store, service file, test?
- How are tables built: direct component, schema config, custom `PageTable`, ProTable wrapper, generated CRUD page?
- How are forms built: direct form component, modal form wrapper, schema-driven form, generated field config?
- How are APIs called: generated clients, `services/*`, a central `request`, React Query/SWR hooks, model effects?
- How are permissions expressed: route metadata, access hooks, backend-driven menus, component guards?
- What imports should future changes use, and which lower-level imports should they avoid?

## Guidance Rules

- Name the exact wrapper imports and props instead of describing the underlying library generally.
- If an internal wrapper exists, make it the default in guidance even when it wraps common libraries like `antd`, ProComponents, React Query, or Axios.
- Do not recommend new request helpers until proving the existing request layer cannot support the use case.
- Do not invent route, menu, or permission metadata. Copy the shape from real config files or exported types.
- Do not infer framework API from package names alone. Source code and existing call sites are higher authority.
- Mark deprecated or legacy framework layers clearly when recent commits show a newer pattern.

## Minimal Evidence Snippet

When writing the final guidance, include a compact evidence block like:

```markdown
Framework evidence:
- Page shell: `<path>` exports `<Component>`; used by `<path>`, `<path>`, `<path>`.
- Table pattern: `<path>` uses `<Wrapper>` with props `<propA>`, `<propB>`.
- API layer: `<path>` centralizes request behavior; services live under `<path>`.
- Route/access: `<path>` defines route metadata; `<path>` handles permissions.
```

Keep snippets short. The goal is to let future agents verify the convention quickly.
