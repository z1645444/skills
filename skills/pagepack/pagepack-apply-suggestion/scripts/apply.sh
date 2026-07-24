#!/usr/bin/env bash
# Mechanized apply for Pagepack suggestion patches.
#
# Usage: apply.sh [repo-root] [--patch <file>] [--dry-run]
#
# Pipeline:
#   parse diff headers -> existence guard -> baseHash guard (cache meta only)
#   -> dry-run precheck -> check-pack baseline -> apply -> check-pack again
#   -> report INTRODUCED / RESOLVED / PRE-EXISTING findings.
#
# Without --patch, applies the tool runtime cache .codebase/.last-suggestion.diff
# and consults .codebase/.last-suggestion.meta for base hashes. An explicit
# --patch never uses the cached meta.
#
# Exit codes:
#   0  applied cleanly, no findings introduced (or verification skipped)
#   3  applied, but the patch introduced new check findings
#   1  guard blocked or apply failed (guard blocks write nothing)
#   2  usage error
#
# Compatible with macOS bash 3.2. Uses POSIX patch(1); does not require git.
set -u

usage() {
  echo "usage: apply.sh [repo-root] [--patch <file>] [--dry-run]" >&2
  exit 2
}

root=""
patch_file=""
dry_run=0
while [ $# -gt 0 ]; do
  case "$1" in
    --patch) [ $# -ge 2 ] || usage; patch_file=$2; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage ;;
    -*) usage ;;
    *) if [ -z "$root" ]; then root=$1; shift; else usage; fi ;;
  esac
done
[ -z "$root" ] && root=$PWD
root=$(cd "$root" 2>/dev/null && pwd -P) || { echo "error: repo root not found: $root" >&2; exit 2; }

script_dir=$(cd "$(dirname "$0")" && pwd -P)
check_script=$script_dir/../../pagepack-check-pack/scripts/check-pack.sh

cache_diff=$root/.codebase/.last-suggestion.diff
cache_meta=$root/.codebase/.last-suggestion.meta

from_cache=0
if [ -z "$patch_file" ]; then
  patch_file=$cache_diff
  from_cache=1
fi

if [ ! -f "$patch_file" ] || [ ! -s "$patch_file" ]; then
  echo "BLOCKED: patch file missing or empty: $patch_file"
  exit 1
fi

tmp_prefix=$(mktemp /tmp/pagepack-apply.XXXXXX)
targets=$tmp_prefix.targets
base_out=$tmp_prefix.base
post_out=$tmp_prefix.post
trap 'rm -f "$tmp_prefix" "$targets" "$base_out" "$post_out" "$base_out.f" "$post_out.f" 2>/dev/null' EXIT

# --- Parse unified diff headers into "old<TAB>new" pairs.
awk '
  /^--- / { old=$2; next }
  /^\+\+\+ / { if (old != "") { print old "\t" $2 }; old="" }
' "$patch_file" > "$targets"

if [ ! -s "$targets" ]; then
  echo "BLOCKED: no file headers found in patch (not a unified diff?)"
  exit 1
fi

# --- Detect prefix style: git-style a/ b/ headers need -p1, plain paths -p0.
p_level=0
if awk -F'\t' '
  $1 != "/dev/null" && $1 !~ /^a\// { plain=1 }
  $1 ~ /^a\// { pref=1 }
  $2 ~ /^b\// { pref=1 }
  END { exit !(pref && !plain) }
' "$targets"; then
  p_level=1
fi

strip_prefix() {
  case "$1" in
    a/*) [ "$p_level" -eq 1 ] && printf '%s' "${1#a/}" || printf '%s' "$1" ;;
    b/*) [ "$p_level" -eq 1 ] && printf '%s' "${1#b/}" || printf '%s' "$1" ;;
    *) printf '%s' "$1" ;;
  esac
}

# --- Existence guard.
guard_fail=0
while IFS=$'\t' read -r old new; do
  old=$(strip_prefix "$old")
  new=$(strip_prefix "$new")
  if [ "$new" = "/dev/null" ]; then
    echo "BLOCKED: delete operations are not supported (target: $old)"
    guard_fail=1
    continue
  fi
  if [ "$old" = "/dev/null" ]; then
    if [ -e "$root/$new" ]; then
      echo "BLOCKED: create target already exists: $new"
      guard_fail=1
    fi
  else
    if [ ! -f "$root/$old" ]; then
      echo "BLOCKED: patch target missing: $old"
      guard_fail=1
    fi
  fi
done < "$targets"

# --- baseHash guard (cache-sourced patches only).
hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -c1-12
  else
    sha256sum "$1" | cut -c1-12
  fi
}

if [ "$from_cache" -eq 1 ] && [ -f "$cache_meta" ]; then
  while read -r kw path hash; do
    [ "$kw" = "baseHash" ] || continue
    if [ ! -f "$root/$path" ]; then
      echo "BLOCKED: baseHash target missing: $path"
      guard_fail=1
      continue
    fi
    cur=$(hash_file "$root/$path")
    if [ "$cur" != "$hash" ]; then
      echo "BLOCKED: baseHash mismatch for $path (expected $hash, current $cur)"
      guard_fail=1
    fi
  done < "$cache_meta"
fi

if [ "$guard_fail" -ne 0 ]; then
  echo "apply: blocked by guard; nothing written"
  exit 1
fi

# --- Dry-run precheck. GNU patch has --dry-run; BSD patch has -C.
if patch --help 2>&1 | grep -q -- --dry-run; then
  dry_flag=--dry-run
else
  dry_flag=-C
fi

if ! (cd "$root" && patch "-p$p_level" -N -s "$dry_flag" < "$patch_file" >/dev/null 2>&1); then
  echo "BLOCKED: patch does not apply cleanly (dry run failed)"
  exit 1
fi

if [ "$dry_run" -eq 1 ]; then
  echo "dry-run: guard passed and patch applies cleanly; nothing written"
  exit 0
fi

# --- Verification baseline.
have_check=0
if [ -f "$check_script" ] && [ -d "$root/.codebase" ]; then
  bash "$check_script" "$root" > "$base_out" 2>/dev/null
  have_check=1
fi

# --- Apply.
if ! (cd "$root" && patch "-p$p_level" -N -s < "$patch_file"); then
  echo "FAILED: patch application failed after clean dry run; inspect *.rej files"
  exit 1
fi

applied=$(awk -F'\t' '{print $2}' "$targets" | sed 's|^b/||' | sort -u | tr '\n' ' ')
echo "applied: $applied"

# --- Post-apply verification.
if [ "$have_check" -eq 0 ]; then
  echo "verification: skipped (check script or .codebase/ unavailable)"
  exit 0
fi

bash "$check_script" "$root" > "$post_out" 2>/dev/null

grep -E '^(ERROR|WARN) ' "$base_out" | sort > "$base_out.f" || true
grep -E '^(ERROR|WARN) ' "$post_out" | sort > "$post_out.f" || true

introduced=$(comm -13 "$base_out.f" "$post_out.f")
resolved=$(comm -23 "$base_out.f" "$post_out.f")
preexisting=$(comm -12 "$base_out.f" "$post_out.f")

count_lines() {
  if [ -z "$1" ]; then echo 0; else printf '%s\n' "$1" | grep -c .; fi
}

echo "INTRODUCED ($(count_lines "$introduced"))"
[ -n "$introduced" ] && printf '%s\n' "$introduced" | sed 's/^/  /'
echo "RESOLVED ($(count_lines "$resolved"))"
[ -n "$resolved" ] && printf '%s\n' "$resolved" | sed 's/^/  /'
echo "PRE-EXISTING ($(count_lines "$preexisting"))"
[ -n "$preexisting" ] && printf '%s\n' "$preexisting" | sed 's/^/  /'

if [ -n "$introduced" ]; then
  exit 3
fi
exit 0
