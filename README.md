一些自用 skills。

## Ariadne

Ariadne 是一组用于创建、检查和维护 `.codebase/` Codebase Knowledge Pack 的 skills。

中文使用说明见 [docs/ariadne-usage.md](docs/ariadne-usage.md)。

## 安装

安装所有 skills 到 Codex、Claude Code 和 Gemini CLI：

```bash
scripts/install.sh
```

只安装到指定 runtime：

```bash
scripts/install.sh codex
scripts/install.sh claude gemini
```

默认目标路径：

- Codex: `${CODEX_HOME:-$HOME/.codex}/skills`
- Claude Code: `${CLAUDE_HOME:-$HOME/.claude}/skills`
- Gemini CLI: `${GEMINI_HOME:-$HOME/.gemini}/extensions`

覆盖目标路径：

```bash
CODEX_SKILLS_TARGET=/path/to/codex/skills scripts/install.sh codex
CLAUDE_SKILLS_TARGET=/path/to/claude/skills scripts/install.sh claude
GEMINI_EXTENSIONS_TARGET=/path/to/gemini/extensions scripts/install.sh gemini
```

只指定单个 target 时，也可以使用 `SKILLS_TARGET` 作为 legacy override。

## 卸载

从所有支持的 runtimes 卸载本仓库 skills：

```bash
scripts/uninstall.sh
```

只从指定 runtimes 卸载：

```bash
scripts/uninstall.sh codex
scripts/uninstall.sh claude gemini
```

## 快速使用

```bash
scripts/install.sh
scripts/uninstall.sh
```

