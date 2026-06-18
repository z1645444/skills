#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd -P)
target=${1:-all}

usage() {
  echo "Usage: $0 [all|claude|codex|gemini|antigravity]" >&2
}

skill_names() {
  find "$repo_root"/skills -mindepth 2 -maxdepth 3 -type f -name SKILL.md -print0 |
    while IFS= read -r -d '' skill_file; do
      basename "$(dirname "$skill_file")"
    done
}

remove_if_exists() {
  local path=$1
  if [ -e "$path" ] || [ -L "$path" ]; then
    rm -rf "$path"
    echo "removed: $path"
  fi
}

subagent_names() {
  find "$repo_root"/skills -mindepth 2 -maxdepth 3 -type f \( -name '*.md' -o -name '*.toml' \) -print0 |
    while IFS= read -r -d '' subagent_file; do
      basename "$subagent_file"
    done
}

uninstall_subagents_from() {
  local root=$1
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    remove_if_exists "$root/$name"
  done < <(subagent_names)
}

uninstall_from() {
  local root=$1
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    remove_if_exists "$root/$name"
  done < <(skill_names)
}

uninstall_claude() {
  local root=${CLAUDE_HOME:-$HOME/.claude}/skills
  uninstall_from "$root"
  uninstall_subagents_from "${CLAUDE_HOME:-$HOME/.claude}/agents"
}

uninstall_codex() {
  local root=${CODEX_HOME:-$HOME/.codex}/skills
  uninstall_from "$root"
  uninstall_subagents_from "${CODEX_HOME:-$HOME/.codex}/agents"
}

uninstall_gemini() {
  local root=${GEMINI_HOME:-$HOME/.gemini}/extensions
  uninstall_from "$root"
  uninstall_subagents_from "${GEMINI_HOME:-$HOME/.gemini}/agents"
}

uninstall_antigravity() {
  local root=${GEMINI_HOME:-$HOME/.gemini}/antigravity/skills
  uninstall_from "$root"
  uninstall_subagents_from "${GEMINI_HOME:-$HOME/.gemini}/antigravity/agents"
}

case "$target" in
all)
  uninstall_claude
  uninstall_codex
  uninstall_gemini
  uninstall_antigravity
  ;;
claude) uninstall_claude ;;
codex) uninstall_codex ;;
gemini) uninstall_gemini ;;
antigravity) uninstall_antigravity ;;
-h | --help)
  usage
  exit 0
  ;;
*)
  usage
  exit 1
  ;;
esac

