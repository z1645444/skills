#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [all|codex|claude|gemini ...]

Installs every repository skill into one or more agent runtimes.
With no arguments, installs to all supported runtimes.

Targets:
  codex   -> ${CODEX_SKILLS_TARGET:-${SKILLS_TARGET:-${CODEX_HOME:-$HOME/.codex}/skills}}
  claude  -> ${CLAUDE_SKILLS_TARGET:-${CLAUDE_HOME:-$HOME/.claude}/skills}
  gemini  -> ${GEMINI_EXTENSIONS_TARGET:-${GEMINI_HOME:-$HOME/.gemini}/extensions}

For a single target, SKILLS_TARGET can override that target for compatibility
with older versions of this script.
EOF
}

skill_dirs=()
while IFS= read -r -d '' skill_file; do
  skill_dirs+=("$(dirname "$skill_file")")
done < <(find "$repo_root" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0)

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "No skills found under $repo_root" >&2
  exit 1
fi

platforms=()
if [[ $# -eq 0 ]]; then
  platforms=(codex claude gemini)
else
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        exit 0
        ;;
      all)
        platforms=(codex claude gemini)
        ;;
      codex|claude|gemini)
        platforms+=("$arg")
        ;;
      *)
        echo "Unknown target: $arg" >&2
        usage >&2
        exit 2
        ;;
    esac
  done
fi

unique_platforms=()
for platform in "${platforms[@]}"; do
  found=false
  if [[ ${#unique_platforms[@]} -gt 0 ]]; then
    for existing in "${unique_platforms[@]}"; do
      if [[ "$existing" == "$platform" ]]; then
        found=true
        break
      fi
    done
  fi
  if [[ "$found" == false ]]; then
    unique_platforms+=("$platform")
  fi
done
platforms=("${unique_platforms[@]}")

single_platform=false
if [[ ${#platforms[@]} -eq 1 ]]; then
  single_platform=true
fi

target_for_platform() {
  local platform="$1"
  local legacy_target=""

  if [[ "$single_platform" == true ]]; then
    legacy_target="${SKILLS_TARGET:-}"
  fi

  case "$platform" in
    codex)
      echo "${CODEX_SKILLS_TARGET:-${legacy_target:-${CODEX_HOME:-$HOME/.codex}/skills}}"
      ;;
    claude)
      echo "${CLAUDE_SKILLS_TARGET:-${legacy_target:-${CLAUDE_HOME:-$HOME/.claude}/skills}}"
      ;;
    gemini)
      echo "${GEMINI_EXTENSIONS_TARGET:-${legacy_target:-${GEMINI_HOME:-$HOME/.gemini}/extensions}}"
      ;;
    *)
      echo "Unknown target: $platform" >&2
      return 2
      ;;
  esac
}

normalize_target_root() {
  local target_root="$1"
  local action="$2"

  if [[ -z "$target_root" || "$target_root" == "/" ]]; then
    echo "Refusing to $action unsafe target: ${target_root:-<empty>}" >&2
    return 1
  fi

  mkdir -p "$target_root"
  cd "$target_root" && pwd -P
}

tmp_dir=""
cleanup() {
  if [[ -n "$tmp_dir" && -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

copy_tree_atomically() {
  local source_dir="$1"
  local target_dir="$2"

  if [[ -d "$target_dir" ]]; then
    local target_real
    target_real="$(cd "$target_dir" && pwd -P)"
    if [[ "$target_real" == "$source_dir" ]]; then
      echo "Skipping $(basename "$source_dir"); source and target are the same directory"
      return 0
    fi
  fi

  tmp_dir="$(dirname "$target_dir")/.$(basename "$target_dir").install.$$"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  cp -R "$source_dir/." "$tmp_dir/"
}

finish_atomic_copy() {
  local target_dir="$1"

  rm -rf "$target_dir"
  mv "$tmp_dir" "$target_dir"
  tmp_dir=""
}

install_skill_runtime() {
  local platform="$1"
  local target_root="$2"

  for source_dir in "${skill_dirs[@]}"; do
    source_dir="$(cd "$source_dir" && pwd -P)"
    local skill_name
    skill_name="$(basename "$source_dir")"
    local target_dir="$target_root/$skill_name"

    copy_tree_atomically "$source_dir" "$target_dir"
    if [[ -z "$tmp_dir" ]]; then
      continue
    fi

    finish_atomic_copy "$target_dir"
    echo "Installed $skill_name for $platform -> $target_dir"
  done
}

install_gemini_extension() {
  local target_root="$1"

  for source_dir in "${skill_dirs[@]}"; do
    source_dir="$(cd "$source_dir" && pwd -P)"
    local skill_name
    skill_name="$(basename "$source_dir")"
    local target_dir="$target_root/$skill_name"

    copy_tree_atomically "$source_dir" "$target_dir"
    if [[ -z "$tmp_dir" ]]; then
      continue
    fi

    cat > "$tmp_dir/gemini-extension.json" <<EOF
{
  "name": "$skill_name",
  "version": "0.1.0",
  "contextFileName": "GEMINI.md"
}
EOF

    {
      echo "# $skill_name"
      echo
      echo "This Gemini CLI extension adapts the repository skill in \`SKILL.md\`."
      echo "Follow the skill instructions below when the user asks for this capability."
      echo
      echo "## Skill Instructions"
      echo
      sed -n '1,$p' "$source_dir/SKILL.md"
    } > "$tmp_dir/GEMINI.md"

    finish_atomic_copy "$target_dir"
    echo "Installed $skill_name for gemini -> $target_dir"
  done
}

for platform in "${platforms[@]}"; do
  target_root="$(target_for_platform "$platform")"
  target_root="$(normalize_target_root "$target_root" "install into")"

  case "$platform" in
    codex|claude)
      install_skill_runtime "$platform" "$target_root"
      ;;
    gemini)
      install_gemini_extension "$target_root"
      ;;
  esac
done
