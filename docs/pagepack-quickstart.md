# Pagepack 快速开始

Pagepack 是一组以 `pagepack-` 开头的可组合 skills，用于为 management system frontend project 生成和维护仓库本地的 `.codebase/` 项目认知文档。

它的目标不是替代 coding agent，而是让 Codex、Claude Code、Gemini CLI 等 agent 在改代码前先读取同一份项目上下文，减少 UI/UX 漂移、framework API 猜测和文件切分粒度错误。

完整参考见 [pagepack-usage.md](pagepack-usage.md)。

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

1. 在项目根目录运行 `pagepack-init`，直接创建初始 `.codebase/` Codebase Knowledge Pack。
2. 运行 `pagepack-check-pack` 检查结构是否完整。
3. 运行 `pagepack-suggest-adapters`，为当前 agent entry file 生成接入 `.codebase/router.md` 的建议。
4. review suggestion 后，用 `pagepack-apply-suggestion <suggestion-id>` 应用。

## 日常使用

- 改代码前让 agent 读取 `.codebase/router.md`，按任务类型加载所需 Runtime Docs。
- 项目或 framework 变化后，先 `pagepack-check-freshness`；发现过期就 `pagepack-suggest-refresh`，review 后再 `pagepack-apply-suggestion`。

## 常用命令速查

| skill                      | 作用                                  |
| -------------------------- | ------------------------------------- |
| `pagepack-init`             | 首次创建 `.codebase/`                 |
| `pagepack-check-pack`       | 只读检查 `.codebase/` 结构完整性      |
| `pagepack-check-adapters`   | 检查 agent entry file 是否接入 router |
| `pagepack-check-freshness`  | 检查 `.codebase/` 是否可能过期        |
| `pagepack-suggest-adapters` | 生成 agent entry file 接入建议        |
| `pagepack-suggest-refresh`  | 生成 `.codebase/` 刷新建议            |
| `pagepack-suggest-recipes`  | 发现常见页面类型候选                  |
| `pagepack-suggest-rules`    | 生成 UI / framework / 结构规则候选    |
| `pagepack-apply-suggestion` | 应用已 review 的建议                  |
| `pagepack-explain`          | 解释 route、rule 或 suggestion 的来源 |

## 安全模型

- `check` 只读，不写文件。
- 除首次 `pagepack-init` 外，所有变更都先 `suggest` 生成可 review 的建议，再由用户显式 `apply`。

