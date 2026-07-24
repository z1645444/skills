#!/usr/bin/env bash
# Mechanical integrity checks for a .codebase Codebase Knowledge Pack.
#
# Usage: check-pack.sh [repo-root] [--strict]
#
# Checks:
#   C1  source references     backtick repo paths in pack docs must exist on disk
#   C2  router coverage       every examples/ doc must be explicitly listed in router.md
#   C3  pack cross-references .codebase/*.md references must resolve
#   C4  cache hygiene         Runtime Docs must not reference .last-suggestion.*
#   C5  pack version marker   router.md must start with <!-- pagepack: N -->
#
# Output: one line per finding: "<LEVEL> <CODE> <doc> :: <detail>", then a summary.
# Exit codes: 0 = no errors, 1 = errors (or warnings with --strict), 2 = usage/pack missing.
#
# Compatible with macOS bash 3.2; no associative arrays, no mapfile.
set -u

usage() {
  echo "usage: check-pack.sh [repo-root] [--strict]" >&2
  exit 2
}

root=""
strict=0
for arg in "$@"; do
  case "$arg" in
    --strict) strict=1 ;;
    -h|--help) usage ;;
    -*) usage ;;
    *) if [ -z "$root" ]; then root=$arg; else usage; fi ;;
  esac
done
[ -z "$root" ] && root=$PWD
root=$(cd "$root" 2>/dev/null && pwd -P) || { echo "error: repo root not found: $root" >&2; exit 2; }
pack=$root/.codebase
[ -d "$pack" ] || { echo "error: no .codebase/ under $root" >&2; exit 2; }

findings=$(mktemp /tmp/check-pack.XXXXXX)
trap 'rm -f "$findings"' EXIT

# C1 + C3: scan backtick tokens in every pack markdown file.
find "$pack" -name '*.md' -not -path '*/.git/*' | while IFS= read -r doc; do
  rel_doc=${doc#"$root"/}
  grep -ohE '`[^`]+`' "$doc" 2>/dev/null | sed 's/`//g' | sort -u | while IFS= read -r token; do
    [ -n "$token" ] || continue
    case "$token" in
      # templates, globs, commands, and inline code are not checkable paths
      *' '*|*'<'*|*'>'*|*'{'*|*'}'*|*'*'*|*'['*|*']'*|*'('*|*')'*) continue ;;
      http://*|https://*) continue ;;
    esac
    case "$token" in
      .codebase/*.md)
        # C3: pack cross-reference must resolve
        if [ ! -f "$root/$token" ]; then
          echo "ERROR C3 $rel_doc :: broken pack reference \`$token\`"
        fi
        continue
        ;;
      .codebase/*) continue ;;
    esac
    case "$token" in
      */*) ;;
      *) continue ;;
    esac
    # C1: only judge tokens whose first segment is a real top-level directory,
    # so aliases (@/*), package names, and prose fragments are skipped.
    seg=${token%%/*}
    [ -n "$seg" ] || continue
    [ -d "$root/$seg" ] || continue
    path=${token%/}
    if [ ! -e "$root/$path" ]; then
      echo "ERROR C1 $rel_doc :: missing source path \`$token\`"
    fi
  done
done >> "$findings"

# C2: router coverage for examples docs.
router=$pack/router.md
if [ -f "$router" ]; then
  if [ -d "$pack/examples" ]; then
    # Backtick .codebase tokens in the router, one per line, for exact-match
    # directory-mention checks below.
    router_tokens=$(grep -ohE '`\.codebase/[^`]*`' "$router" 2>/dev/null | sed 's/`//g' | sort -u)
    find "$pack/examples" -name '*.md' -not -path '*/.git/*' | while IFS= read -r ex; do
      rel=${ex#"$root"/}
      if grep -qF "$rel" "$router"; then
        continue
      fi
      # A directory-level mention only counts when the router contains the
      # directory itself as a whole token; a longer file path that merely
      # starts with the directory must not downgrade the finding.
      dir=$(dirname "$rel")
      if printf '%s\n' "$router_tokens" | grep -qxF -e "$dir" -e "$dir/"; then
        echo "WARN C2 $rel :: only directory-level router coverage; add an explicit route link"
      else
        echo "ERROR C2 $rel :: not reachable from router.md (Router Coverage Invariant)"
      fi
    done >> "$findings"
  fi
else
  echo "ERROR C3 .codebase/router.md :: router.md is missing" >> "$findings"
fi

# C4: Runtime Docs must not reference the tool runtime cache.
find "$pack" -name '*.md' -not -path '*/.git/*' | while IFS= read -r doc; do
  rel_doc=${doc#"$root"/}
  if grep -q "last-suggestion" "$doc"; then
    echo "WARN C4 $rel_doc :: Runtime Doc references the tool runtime cache .last-suggestion.*"
  fi
done >> "$findings"

# C5: pack version marker on the first router line.
if [ -f "$router" ] && ! head -n 1 "$router" | grep -q "pagepack:"; then
  echo "WARN C5 .codebase/router.md :: missing pack version marker (<!-- pagepack: 2 -->)" >> "$findings"
fi

sort -u "$findings" > "$findings.sorted" && mv "$findings.sorted" "$findings"
cat "$findings"

errors=$(grep -c '^ERROR ' "$findings") || true
warnings=$(grep -c '^WARN ' "$findings") || true

echo "check-pack: $errors error(s), $warnings warning(s)"
if [ "$errors" -gt 0 ]; then
  exit 1
fi
if [ "$strict" -eq 1 ] && [ "$warnings" -gt 0 ]; then
  exit 1
fi
exit 0
