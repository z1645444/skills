#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd -P)
target=${1:-all}

usage() {
  echo "Usage: $0 [all|claude|codex|gemini|antigravity]" >&2
}

skill_dirs() {
  find "$repo_root"/skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0 |
    while IFS= read -r -d '' skill_file; do
      dirname "$skill_file"
    done
}

link_skill() {
  local src=$1 dst_root=$2
  local name
  name=$(basename "$src")
  local dst=$dst_root/$name

  if [ -L "$dst" ] || [ -e "$dst" ]; then
    local current
    if current=$(readlink "$dst" 2>/dev/null) && [ "$current" = "$src" ]; then
      echo "unchanged: $name"
      return 0
    fi
    rm -rf "$dst"
  fi

  ln -s "$src" "$dst"
  echo "$name"
}

install_claude() {
  local root=${CLAUDE_HOME:-$HOME/.claude}/skills
  mkdir -p "$root"
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    echo "claude: $(link_skill "$src" "$root")"
  done < <(skill_dirs)
}

install_codex() {
  local root=${CODEX_HOME:-$HOME/.codex}/skills
  mkdir -p "$root"
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    echo "codex: $(link_skill "$src" "$root")"
  done < <(skill_dirs)
}

install_gemini() {
  local root=${GEMINI_HOME:-$HOME/.gemini}/extensions
  mkdir -p "$root"
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    local name
    name=$(basename "$src")
    local dst=$root/$name

    rm -rf "$dst"
    cp -R "$src" "$dst"

    printf '%s\n' '{"name":"'"$name"'","version":"0.1.0","contextFileName":"GEMINI.md"}' \
      >"$dst/gemini-extension.json"

    {
      echo "# $name"
      echo
      echo "Follow the skill instructions below when the user asks for this capability."
      echo
      cat "$src/SKILL.md"
    } >"$dst/GEMINI.md"

    echo "gemini: $name"
  done < <(skill_dirs)
}

install_antigravity() {
  local root=${GEMINI_HOME:-$HOME/.gemini}/antigravity/skills
  mkdir -p "$root"
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    echo "antigravity: $(link_skill "$src" "$root")"
  done < <(skill_dirs)
}

case "$target" in
all)
  install_claude
  install_codex
  install_gemini
  install_antigravity
  ;;
claude) install_claude ;;
codex) install_codex ;;
gemini) install_gemini ;;
antigravity) install_antigravity ;;
-h | --help)
  usage
  exit 0
  ;;
*)
  usage
  exit 1
  ;;
esac

