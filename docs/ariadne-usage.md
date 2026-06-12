# Ariadne 使用说明

Ariadne 是一组以 `ariadne-` 开头的可组合 skills，用于为 management system frontend project 生成和维护仓库本地的 `.codebase/` 项目认知文档。

它的目标不是替代 coding agent，而是让 Codex、Claude Code、Gemini CLI 等 agent 在改代码前先读取同一份项目上下文，减少 UI/UX 漂移、framework API 猜测和文件切分粒度错误。

## 安装

在本仓库根目录执行：

```bash
scripts/install.sh
```

默认会安装到 Codex、Claude Code 和 Gemini CLI。

只安装到单个运行时：

```bash
scripts/install.sh codex
scripts/install.sh claude
scripts/install.sh gemini
```

## 推荐使用流程

首次在某个项目中使用：

1. 运行 `ariadne-init`。
2. `ariadne-init` 会在没有 `.codebase/` 时直接创建初始 Codebase Knowledge Pack，不需要再运行 `ariadne-apply-suggestion`。
3. 运行 `ariadne-check-pack` 检查 `.codebase/` 是否完整。
4. 运行 `ariadne-suggest-adapters`，为当前 agent entry file 生成接入 `.codebase/router.md` 的建议。
5. review adapter suggestion。
6. 确认后使用 `ariadne-apply-suggestion <suggestion-id>` 应用 adapter 建议。

日常 coding 前：

1. agent 读取 `.codebase/router.md`。
2. 根据当前任务类型，只加载 router 要求的 Runtime Docs。
3. 优先遵守 `rules/`、`knowledge/` 和 `examples/` 中当前有效的项目约定。

项目或 framework 变化后：

1. 运行 `ariadne-check-freshness` 检查 `.codebase/` 是否可能过期。
2. 如果有 stale source classes，运行 `ariadne-suggest-refresh`。
3. review refresh suggestion。
4. 通过 `ariadne-apply-suggestion <suggestion-id>` 应用确认后的刷新。

## 常用 skills

- `ariadne-init`：在没有 `.codebase/` 时直接创建初始 Codebase Knowledge Pack。
- `ariadne-apply-suggestion`：应用已经 review 的 suggestion。
- `ariadne-check-pack`：只读检查 `.codebase/` 结构和契约是否完整。
- `ariadne-check-adapters`：检查 agent entry file 是否接入 `.codebase/router.md`。
- `ariadne-check-freshness`：检查项目源码变化是否让 `.codebase/` 过期。
- `ariadne-suggest-refresh`：生成 `.codebase/` 刷新建议。
- `ariadne-suggest-adapters`：生成 Codex、Claude Code、Gemini CLI 等 entry file 的接入建议。
- `ariadne-suggest-recipes`：发现常见页面类型和 Page Recipe Candidates。
- `ariadne-suggest-rules`：生成 UI、framework API、file structure 相关规则候选。
- `ariadne-explain`：解释 route、rule、doc 或 suggestion 的来源和状态。

## 安全模型

Ariadne 使用 `check / suggest / apply` 三段式模型：

- `check` 只读，不写文件。
- 除初始 bootstrap 外，`suggest` 只生成可 review 的建议，默认写入 `.codebase/meta/suggestions/`。
- `apply` 只应用用户明确选择的 suggestion。

`ariadne-init` 是唯一 direct-write 例外：当项目没有 `.codebase/` 时，它可以直接创建初始 Runtime Docs 和 manifest。已有 `.codebase/` 的 recovery、refresh、rules、recipes、adapter 等后续增量变更仍必须先 review suggestion，再通过 `ariadne-apply-suggestion` 应用。

## 语言策略

Ariadne 面向人的输出默认使用简体中文。

以下内容保持原文：

- 文件路径和目录名
- command name
- API name
- framework name
- component name
- identifier
- agent/tool name

例如：`.codebase/router.md`、`Task Router`、`Codebase Knowledge Pack`、`Agent Adapter`、`ariadne-init` 都保持原文。

## 关键约束

- 一个项目只能有一份 `.codebase/`。
- `.codebase/router.md` 是 Task Router，不是普通目录索引。
- agent entry file 只应该指向 `.codebase/router.md`，不要复制 Runtime Docs 内容。
- Runtime Docs 表达 Current Snapshot，不追加历史 delta。
- 低置信度发现应进入 `meta/candidates/` 或 suggestions，不能直接升级成规则。
- UI 变更应优先使用已有组件、props、wrappers 和 Page Recipes，避免默认新增 custom styles。
