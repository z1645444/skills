一些自用 skills。

## 安装与卸载

```bash
# 安装到所有支持的 runtimes
scripts/install.sh

# 只安装到指定 runtime
scripts/install.sh codex

# 卸载
scripts/uninstall.sh
```

安装目标路径：

- Codex: `${CODEX_HOME:-$HOME/.codex}/skills`
- Claude Code: `${CLAUDE_HOME:-$HOME/.claude}/skills`
- Gemini CLI: `${GEMINI_HOME:-$HOME/.gemini}/extensions`

更多安装选项见 `scripts/install.sh --help`。

## Skills

- [Ariadne](docs/ariadne-quickstart.md)：创建、检查和维护 `.codebase/` Codebase Knowledge Pack，让多个 coding agent 共享同一份项目上下文。

