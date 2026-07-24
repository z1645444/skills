# Pagepack 快速开始

Pagepack 是一组以 `pagepack-` 开头的可组合 skills，用于为 management system frontend project 生成仓库本地的 `.codebase/` 项目认知文档。

它的目标不是替代 coding agent，而是让 Codex、Claude Code、Gemini CLI 等 agent 在改代码前先读取同一份项目上下文，减少 UI/UX 漂移、framework API 猜测和文件切分粒度错误。

`.codebase/` 支持两种用法：solo 一次性使用可加入 `.gitignore`；持续维护（Curated Pack）推荐纳入版本管理，手工编辑与 pagepack patch 共存。

## 安装

```bash
scripts/install.sh
```

默认安装到所有支持的 runtimes。只安装单个运行时：

```bash
scripts/install.sh codex
scripts/install.sh claude
scripts/install.sh gemini
scripts/install.sh antigravity
```

## 首次使用

1. 在项目根目录运行 `pagepack-init`，直接创建初始 `.codebase/` Runtime Docs。
2. 运行 `pagepack-suggest-adapters`，为当前 agent entry file 生成接入 `.codebase/router.md` 的 patch。
3. review patch 后，运行 `pagepack-apply-suggestion` 应用缓存的 patch（它会读取 `.codebase/.last-suggestion.diff`）；也可以直接提供 diff 给 `pagepack-apply-suggestion` 以覆盖缓存。

## 日常使用

- 改代码前让 agent 读取 `.codebase/router.md`，按任务类型加载所需 Runtime Docs。
- 完成一段有沉淀价值的开发（新页面、踩坑解法、首次使用的组件组合）后，用定向 trailing prompt 做增量沉淀：`pagepack-suggest-recipes focus on the modules touched by recent commits`，review 后运行 `pagepack-apply-suggestion`。
- 需要更新规则或示例时，运行 `pagepack-suggest-rules` 或 `pagepack-suggest-recipes`，review patch 后运行 `pagepack-apply-suggestion` 应用缓存的 patch。
- 源码重构后或定期，运行 `pagepack-check-pack` 校验 pack 完整性；发现过时事实时运行 `pagepack-suggest-knowledge` 生成刷新 patch。
- 每次 `pagepack-apply-suggestion` 都会自动做基线对比校验，报告补丁引入的问题。

## 常用命令速查

| skill                        | 作用                                             |
| ---------------------------- | ------------------------------------------------ |
| `pagepack-init`              | 首次创建 `.codebase/` Runtime Docs               |
| `pagepack-suggest-adapters`  | 生成 agent entry file 接入 patch                 |
| `pagepack-suggest-recipes`   | 发现页面类型 / 行为约定 patch（含 router 接线）  |
| `pagepack-suggest-rules`     | 生成 UI / framework / 结构规则 patch             |
| `pagepack-suggest-knowledge` | 刷新过时 knowledge 事实并修复 router 结构        |
| `pagepack-apply-suggestion`  | 应用已 review 的 patch 并自动校验                |
| `pagepack-check-pack`        | 只读校验 pack 完整性                             |

## Trailing Prompt

所有 `pagepack-suggest-*` 支持 trailing prompt text，用于定向生成 patch：

```text
pagepack-suggest-rules focus on forms and tables
pagepack-suggest-recipes focus on list pages with filters
pagepack-suggest-recipes focus on the modules touched by recent commits
pagepack-suggest-adapters add note about SSR
```

### Adapter Subagents

Claude Code、Codex CLI 和 Gemini CLI（experimental）支持在 `pagepack-init` 中按 knowledge 维度并行委托子代理：

- `pagepack-overview-agent`
- `pagepack-framework-agent`
- `pagepack-ui-agent`
- `pagepack-granularity-agent`

规则由主 agent 统一推导，不单独委托。`pagepack-suggest-recipes` 可复用对应 runtime adapter 目录下的 knowledge 子代理（如 `.claude/agents/pagepack-overview-agent.md` 和 `.claude/agents/pagepack-ui-agent.md`）来收集信号。若当前 runtime 不支持子代理，skill 会自动回退到 inline 搜索。

## 已有 pack 升级到 v2

旧版本创建的 pack（无版本标记）不需要重建，也不会因不升级而损坏；新能力面对它按 v1 旧布局保守处理。升级是一次体检：

1. 运行 `pagepack-check-pack`，一次跑出全部欠账。
2. 修复 C1/C3（失效引用）与 C2（未被 router 显式列出的 examples 文档）：让 agent 出 patch 走 `pagepack-apply-suggestion`，或手工修改。
3. 确认结构符合 v2 预期后，在 `router.md` 首行加 `<!-- pagepack: 2 -->`。
4. 若该项目把 `.codebase/` 纳入了版本管理，把 `.codebase/.gitignore` 中的 `.last-suggestion.diff` 放宽为 `.last-suggestion.*`（否则新的 meta 缓存会被误提交）。

不需要重跑 `pagepack-init` 或 `pagepack-suggest-adapters`：pack 内容格式兼容，agent entry file 的接入指令未变。`examples/behaviors/` 目录只在真的沉淀了横切行为约定时才需要。

## 安全模型

- `pagepack-suggest-*` 输出 unified diff patch，并把同一份 diff 与记录 `baseHash`（sha256 前 12 位）的 `.last-suggestion.meta` 一起写入 `.codebase/` 作为工具运行时缓存，不直接修改 Runtime Docs。
- `pagepack-apply-suggestion` 的 guard、hash 校验、应用与基线对比校验由 `apply.sh` 脚本机械执行：默认读取缓存并校验 meta 中的 hash（跨会话生效）；显式提供的 patch 跳过缓存 meta。apply 成功后自动区分补丁引入问题（INTRODUCED）与存量欠账（PRE-EXISTING），只报告不回滚。
- `pagepack-check-pack` 只读，不产出 patch；发现的问题按类别路由到对应的 `pagepack-suggest-*` 能力修复。
- `pagepack-init` 在没有 `.codebase/` 时直接创建 Runtime Docs，并在 `router.md` 首行写入版本标记 `<!-- pagepack: 2 -->`。
