# Skills

个人 skill hub，为 Claude Code、Codex、Gemini CLI 和 Antigravity 提供可复用的 agent skills。

## 安装与卸载

```bash
# 安装到所有支持的 runtimes
scripts/install.sh

# 只安装到指定 runtime
scripts/install.sh claude
scripts/install.sh codex
scripts/install.sh gemini
scripts/install.sh antigravity

# 卸载
scripts/uninstall.sh
```

安装目标路径：

- Claude Code: `${CLAUDE_HOME:-$HOME/.claude}/skills`
- Codex: `${CODEX_HOME:-$HOME/.codex}/skills`
- Gemini CLI: `${GEMINI_HOME:-$HOME/.gemini}/extensions`
- Antigravity: `${GEMINI_HOME:-$HOME/.gemini}/antigravity/skills`

Claude、Codex 和 Antigravity 使用符号链接；Gemini CLI 需要复制并生成适配文件。

## Skills

### Pagepack

Pagepack 是一组以 `pagepack-` 开头的可组合 skills，用于为 management system frontend project 生成仓库本地的 `.codebase/` 项目认知文档。

`.codebase/` 是本地输出，建议加入 `.gitignore`。

- `pagepack-init`：首次创建 `.codebase/`
- `pagepack-suggest-adapters`：生成 agent entry file 接入 patch
- `pagepack-suggest-recipes`：生成常见页面类型 patch
- `pagepack-suggest-rules`：生成 UI / framework / 结构规则 patch
- `pagepack-apply-suggestion`：应用已 review 的 patch

所有 `pagepack-suggest-*` 支持 trailing prompt text，例如：

```text
pagepack-suggest-rules focus on forms and tables
pagepack-suggest-recipes focus on list pages with filters
pagepack-suggest-adapters add note about SSR
```

### Adapter Subagents

部分 agent runtime 支持将 broad codebase sweep 委托给 `pagepack-explorer` 子代理：

- Claude Code: `~/.claude/agents/pagepack-explorer.md`
- Codex CLI: `~/.codex/agents/pagepack-explorer.toml`
- Gemini CLI: `~/.gemini/agents/pagepack-explorer.md`（experimental adapter）

这些子代理定义随相关 skill 一起安装，不属于 `.codebase/`。Pagepack skill 中的指引为条件式：当前 runtime 支持子代理时可委托 broad sweep，否则 inline 搜索。

快速开始见 [docs/pagepack-quickstart.md](docs/pagepack-quickstart.md)。

## 添加新 Skill

1. 在 `skills/` 下选择或创建 group 目录。
2. 创建 `skills/<group>/<skill-name>/SKILL.md`。
3. 按需添加 `agents/` 和 `references/`。
4. 更新本 README。
5. 运行 `scripts/install.sh`。

更多约定见 [CONTEXT.md](CONTEXT.md)。

## 目录结构

```text
skills/<group>/<skill-name>/
  SKILL.md       # 必填，skill 定义，包含 YAML frontmatter
  agents/        # 可选，agent 专属配置
  references/    # 可选，合约、schema 或参考文档
```
