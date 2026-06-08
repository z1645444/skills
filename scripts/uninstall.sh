#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

usage() {
  cat <<'EOF'
Usage: scripts/uninstall.sh [all|codex|claude|gemini ...]

Uninstalls every repository skill from one or more agent runtimes.
With no arguments, uninstalls from all supported runtimes.

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
  for existing in "${unique_platforms[@]}"; do
    if [[ "$existing" == "$platform" ]]; then
      found=true
      break
    fi
  done
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

normalize_existing_target_root() {
  local target_root="$1"
  local action="$2"

  if [[ -z "$target_root" || "$target_root" == "/" ]]; then
    echo "Refusing to $action unsafe target: ${target_root:-<empty>}" >&2
    return 1
  fi

  if [[ ! -d "$target_root" ]]; then
    echo ""
    return 0
  fi

  cd "$target_root" && pwd -P
}

uninstall_from_platform() {
  local platform="$1"
  local target_root="$2"

  if [[ -z "$target_root" ]]; then
    echo "Nothing to uninstall for $platform; target does not exist"
    return 0
  fi

  for source_dir in "${skill_dirs[@]}"; do
    source_dir="$(cd "$source_dir" && pwd -P)"
    local skill_name
    skill_name="$(basename "$source_dir")"
    local target_dir="$target_root/$skill_name"

    if [[ ! -e "$target_dir" && ! -L "$target_dir" ]]; then
      echo "Not installed for $platform: $skill_name"
      continue
    fi

    if [[ -d "$target_dir" ]]; then
      local target_real
      target_real="$(cd "$target_dir" && pwd -P)"
      if [[ "$target_real" == "$source_dir" ]]; then
        echo "Refusing to remove $skill_name for $platform; source and target are the same directory" >&2
        continue
      fi
    fi

    rm -rf "$target_dir"
    echo "Uninstalled $skill_name for $platform from $target_root"
  done
}

for platform in "${platforms[@]}"; do
  target_root="$(target_for_platform "$platform")"
  target_root="$(normalize_existing_target_root "$target_root" "uninstall from")"
  uninstall_from_platform "$platform" "$target_root"
done
