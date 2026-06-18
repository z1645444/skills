# Pagepack 快速开始

Pagepack 是一组以 `pagepack-` 开头的可组合 skills，用于为 management system frontend project 生成仓库本地的 `.codebase/` 项目认知文档。

它的目标不是替代 coding agent，而是让 Codex、Claude Code、Gemini CLI 等 agent 在改代码前先读取同一份项目上下文，减少 UI/UX 漂移、framework API 猜测和文件切分粒度错误。

`.codebase/` 是本地输出，建议加入 `.gitignore`。

## 安装

```bash
scripts/install.sh
```

默认安装到 Codex、Claude Code 和 Gemini CLI。只安装单个运行时：

```bash
scripts/install.sh codex
scripts/install.sh claude
scripts/install.sh gemini
```

## 首次使用

1. 在项目根目录运行 `pagepack-init`，直接创建初始 `.codebase/` Runtime Docs。
2. 运行 `pagepack-suggest-adapters`，为当前 agent entry file 生成接入 `.codebase/router.md` 的 patch。
3. review patch 后，用 `pagepack-apply-suggestion` 应用，或直接让 agent 应用该 diff。

## 日常使用

- 改代码前让 agent 读取 `.codebase/router.md`，按任务类型加载所需 Runtime Docs。
- 需要更新规则或示例时，运行 `pagepack-suggest-rules` 或 `pagepack-suggest-recipes`，review patch 后应用。

## 常用命令速查

| skill                       | 作用                                       |
| --------------------------- | ------------------------------------------ |
| `pagepack-init`             | 首次创建 `.codebase/` Runtime Docs         |
| `pagepack-suggest-adapters` | 生成 agent entry file 接入 patch           |
| `pagepack-suggest-recipes`  | 发现常见页面类型 patch                     |
| `pagepack-suggest-rules`    | 生成 UI / framework / 结构规则 patch       |
| `pagepack-apply-suggestion` | 应用已 review 的 patch                     |

## Trailing Prompt

所有 `pagepack-suggest-*` 支持 trailing prompt text，用于定向生成 patch：

```text
pagepack-suggest-rules focus on forms and tables
pagepack-suggest-recipes focus on list pages with filters
pagepack-suggest-adapters add note about SSR
```

### Adapter Subagents

Claude Code、Codex CLI 和 Gemini CLI（experimental）支持在 `pagepack-init` 中按 knowledge 维度并行委托子代理：

- `pagepack-overview-agent`
- `pagepack-framework-agent`
- `pagepack-ui-agent`
- `pagepack-granularity-agent`

规则由主 agent 统一推导，不单独委托。`pagepack-suggest-recipes` 可复用 `pagepack-overview-agent` 和 `pagepack-ui-agent`。若当前 runtime 不支持子代理，skill 会自动回退到 inline 搜索。

## 安全模型

- `pagepack-suggest-*` 只输出 unified diff patch，不写文件。
- `pagepack-apply-suggestion` 检查文件存在性和可选 `baseHash` 后应用 patch。
- `pagepack-init` 在没有 `.codebase/` 时直接创建 Runtime Docs。
