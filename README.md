# Skills

一组让开发生活稍微轻松愉快点的 skills :D

## Install

```bash
# 安装到所有支持的 runtimes
scripts/install.sh

# 安装到特定 runtime
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

- [Pagepack](docs/pagepack-quickstart.md): 为 management system frontend 项目生成仓库本地的 `.codebase/` 运行时认知文档。

