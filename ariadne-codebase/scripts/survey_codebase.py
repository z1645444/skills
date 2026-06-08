#!/usr/bin/env python3
"""Collect high-signal repository facts for project-specific agent guidance."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


IGNORE_DIRS = {
    ".cache",
    ".git",
    ".hg",
    ".idea",
    ".next",
    ".nuxt",
    ".pnpm-store",
    ".svn",
    ".turbo",
    ".venv",
    ".vscode",
    "__pycache__",
    "build",
    "coverage",
    "dist",
    "node_modules",
    "out",
    "target",
    "vendor",
}

CONFIG_NAMES = {
    "AGENTS.md",
    "CLAUDE.md",
    "README.md",
    "package.json",
    "pnpm-lock.yaml",
    "package-lock.json",
    "yarn.lock",
    "bun.lockb",
    "tsconfig.json",
    "tsconfig.base.json",
    "vite.config.ts",
    "vite.config.js",
    "webpack.config.js",
    "next.config.js",
    "next.config.mjs",
    "eslint.config.js",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.json",
    ".prettierrc",
    ".prettierrc.js",
    "prettier.config.js",
    "biome.json",
    "ruff.toml",
    "pyproject.toml",
    "go.mod",
    "Cargo.toml",
}

TEXT_EXTENSIONS = {
    ".cjs",
    ".css",
    ".go",
    ".html",
    ".js",
    ".json",
    ".jsx",
    ".less",
    ".md",
    ".mjs",
    ".py",
    ".rs",
    ".scss",
    ".toml",
    ".ts",
    ".tsx",
    ".vue",
    ".yaml",
    ".yml",
}

SOURCE_EXTENSIONS = {
    ".c",
    ".cpp",
    ".go",
    ".java",
    ".js",
    ".jsx",
    ".kt",
    ".php",
    ".py",
    ".rb",
    ".rs",
    ".swift",
    ".ts",
    ".tsx",
    ".vue",
}

ADMIN_PACKAGES = {
    "@ant-design/pro-components",
    "@ant-design/pro-layout",
    "@arco-design/web-react",
    "@douyinfe/semi-ui",
    "@refinedev/antd",
    "@refinedev/core",
    "@tanstack/react-query",
    "@umijs/max",
    "ahooks",
    "antd",
    "antd-mobile",
    "axios",
    "dva",
    "ky",
    "react-admin",
    "swr",
    "umi",
    "umi-request",
}

ADMIN_IMPORT_RE = re.compile(
    r"from\s+['\"]("
    r"@ant-design/pro-components|@ant-design/pro-layout|antd|@umijs/max|umi|"
    r"react-admin|@refinedev/(?:core|antd)|@arco-design/web-react|"
    r"@douyinfe/semi-ui|ahooks|@tanstack/react-query|swr|axios|umi-request|ky"
    r")['\"]"
)

REQUEST_HINT_RE = re.compile(r"\b(fetch|axios|request|umi-request|ky|apiClient|httpClient)\b")
REQUEST_PATH_RE = re.compile(r"(request|requests|service|services|api|apis|http|client)", re.I)
EXAMPLE_DIR_RE = re.compile(
    r"^(examples?|best[-_ ]?practices?|cases?|samples?|demos?|recipes?)$",
    re.I,
)
TODO_RE = re.compile(r"\b(TODO|FIXME|HACK|XXX)\b", re.I)

SECRET_SUFFIXES = {
    ".jks",
    ".key",
    ".keystore",
    ".p12",
    ".pem",
    ".pfx",
    ".truststore",
}

SECRET_EXACT_NAMES = {
    ".netrc",
    ".npmrc",
    ".pypirc",
    "serviceaccountkey.json",
}

CONFIG_LIKE_SECRET_SUFFIXES = {
    "",
    ".conf",
    ".config",
    ".env",
    ".ini",
    ".json",
    ".properties",
    ".txt",
    ".yaml",
    ".yml",
}


def run(cmd: list[str], cwd: Path) -> str:
    try:
        result = subprocess.run(
            cmd,
            cwd=str(cwd),
            check=False,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        return ""
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def is_sensitive_path(path: Path) -> bool:
    parts = [part.lower() for part in path.parts]
    name = path.name.lower()
    stem = path.stem.lower()
    suffix = path.suffix.lower()
    config_like = suffix in CONFIG_LIKE_SECRET_SUFFIXES

    if name == ".env" or name.startswith(".env.") or name.endswith(".env"):
        return True
    if name in SECRET_EXACT_NAMES:
        return True
    if suffix in SECRET_SUFFIXES:
        return True
    if name.startswith(("id_rsa", "id_ed25519", "id_dsa")):
        return True
    if config_like and name.startswith(("credentials.", "secrets.")):
        return True
    if name.endswith("-credentials.json"):
        return True
    if config_like and ("secret" in stem or "credential" in stem):
        return True
    if any(part in {"secrets", ".secrets"} for part in parts):
        return True
    return False


def is_priority_file(path: Path) -> bool:
    return (
        path.suffix.lower() in TEXT_EXTENSIONS
        or path.name in CONFIG_NAMES
        or path.name.startswith((".eslint", ".prettier"))
        or is_sensitive_path(path)
    )


def iter_files(root: Path, max_files: int) -> Iterable[Path]:
    priority: list[Path] = []
    fallback: list[Path] = []

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [
            name
            for name in sorted(dirnames)
            if name not in IGNORE_DIRS and not name.endswith(".egg-info")
        ]
        for filename in sorted(filenames):
            path = Path(dirpath) / filename
            if path.is_symlink():
                continue
            if is_priority_file(path):
                if len(priority) < max_files:
                    priority.append(path)
            elif len(fallback) < max_files:
                fallback.append(path)

    for path in priority[:max_files]:
        yield path
    remaining = max_files - len(priority)
    if remaining > 0:
        for path in fallback[:remaining]:
            yield path


def read_text(path: Path, limit: int = 400_000) -> str:
    try:
        if is_sensitive_path(path):
            return ""
        if path.stat().st_size > limit:
            return ""
        return path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def find_configs(files: list[Path], root: Path) -> list[str]:
    configs: list[str] = []
    for path in files:
        if path.name in CONFIG_NAMES or path.name.startswith((".eslint", ".prettier")):
            configs.append(rel(path, root))
    return sorted(configs)


def load_package_jsons(files: list[Path], root: Path) -> tuple[dict[str, list[str]], list[str]]:
    package_scripts: dict[str, list[str]] = {}
    packages: set[str] = set()
    package_files = [path for path in files if path.name == "package.json"][:12]
    for path in package_files:
        try:
            data = json.loads(read_text(path))
        except json.JSONDecodeError:
            continue
        scripts = data.get("scripts") or {}
        if isinstance(scripts, dict):
            package_scripts[rel(path, root)] = sorted(str(key) for key in scripts.keys())
        for field in ("dependencies", "devDependencies", "peerDependencies"):
            deps = data.get(field) or {}
            if isinstance(deps, dict):
                packages.update(str(name) for name in deps.keys())
    return package_scripts, sorted(packages)


def count_top_dirs(files: list[Path], root: Path) -> Counter[str]:
    counts: Counter[str] = Counter()
    for path in files:
        parts = Path(rel(path, root)).parts
        if parts:
            counts[parts[0]] += 1
    return counts


def count_extensions(files: list[Path]) -> Counter[str]:
    counts: Counter[str] = Counter()
    for path in files:
        suffix = path.suffix.lower() or "[no extension]"
        counts[suffix] += 1
    return counts


def candidate_modules(files: list[Path], root: Path) -> Counter[str]:
    bases = {
        ("app",),
        ("apps",),
        ("packages",),
        ("src", "app"),
        ("src", "components"),
        ("src", "features"),
        ("src", "modules"),
        ("src", "pages"),
        ("src", "routes"),
        ("src", "views"),
    }
    counts: Counter[str] = Counter()
    for path in files:
        parts = Path(rel(path, root)).parts
        for base in bases:
            if len(parts) > len(base) and tuple(parts[: len(base)]) == base:
                module_depth = len(base) + 1
                counts["/".join(parts[:module_depth])] += 1
                break
    return counts


def example_directories(files: list[Path], root: Path) -> Counter[str]:
    counts: Counter[str] = Counter()
    for path in files:
        parts = Path(rel(path, root)).parts[:-1]
        for index, part in enumerate(parts):
            if EXAMPLE_DIR_RE.match(part):
                counts["/".join(parts[: index + 1])] += 1
                break
    return counts


def project_skill_files(files: list[Path], root: Path) -> list[str]:
    skill_files: list[str] = []
    for path in files:
        if path.name != "SKILL.md":
            continue
        parts = Path(rel(path, root)).parts
        if len(parts) >= 3 and parts[0] in {".agents", ".claude", ".codex"} and parts[1] == "skills":
            skill_files.append(rel(path, root))
        elif len(parts) >= 3 and parts[0] == "skills":
            skill_files.append(rel(path, root))
    return sorted(skill_files)


def sensitive_files(files: list[Path], root: Path) -> list[str]:
    return sorted(rel(path, root) for path in files if is_sensitive_path(path))


def concern_signals(files: list[Path], root: Path) -> tuple[Counter[str], list[tuple[str, int]]]:
    todos: Counter[str] = Counter()
    large_sources: list[tuple[str, int]] = []

    for path in files:
        if path.suffix.lower() not in SOURCE_EXTENSIONS:
            continue
        text = read_text(path)
        if not text:
            continue
        rel_path = rel(path, root)
        todo_count = len(TODO_RE.findall(text))
        if todo_count:
            todos[rel_path] = todo_count
        large_sources.append((rel_path, len(text.splitlines())))

    large_sources.sort(key=lambda item: item[1], reverse=True)
    return todos, large_sources


def recently_touched_files(root: Path, limit: int) -> Counter[str]:
    output = run(
        ["git", "log", f"-n{limit}", "--name-only", "--pretty=format:"],
        root,
    )
    counts: Counter[str] = Counter()
    for line in output.splitlines():
        line = line.strip()
        if line:
            counts[line] += 1
    return counts


def grep_signals(files: list[Path], root: Path) -> tuple[list[str], list[str], list[str]]:
    admin_imports: list[str] = []
    request_candidates: list[str] = []
    route_candidates: list[str] = []
    for path in files:
        rel_path = rel(path, root)
        if path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        lower_path = rel_path.lower()
        text = read_text(path)
        if not text:
            continue
        if ADMIN_IMPORT_RE.search(text):
            admin_imports.append(rel_path)
        if REQUEST_PATH_RE.search(lower_path) and REQUEST_HINT_RE.search(text):
            request_candidates.append(rel_path)
        if any(part in lower_path for part in ("route", "router", "menu", "permission")):
            if any(token in text for token in ("path", "routes", "menu", "permission", "access")):
                route_candidates.append(rel_path)
    return sorted(set(admin_imports)), sorted(set(request_candidates)), sorted(set(route_candidates))


def format_list(items: Iterable[str], limit: int = 30) -> str:
    rows = list(items)
    if not rows:
        return "- None detected\n"
    visible = rows[:limit]
    suffix = "" if len(rows) <= limit else f"\n- ... {len(rows) - limit} more"
    return "".join(f"- `{item}`\n" for item in visible) + suffix + "\n"


def format_counter(counter: Counter[str], limit: int = 20) -> str:
    if not counter:
        return "- None detected\n"
    return "".join(f"- `{key}`: {value}\n" for key, value in counter.most_common(limit))


def format_line_counts(items: list[tuple[str, int]], limit: int = 20) -> str:
    if not items:
        return "- None detected\n"
    return "".join(f"- `{path}`: {line_count} lines\n" for path, line_count in items[:limit])


def build_report(root: Path, max_files: int, recent_commits: int) -> str:
    root = root.resolve()
    files = list(iter_files(root, max_files=max_files))
    git_root = run(["git", "rev-parse", "--show-toplevel"], root)
    branch = run(["git", "branch", "--show-current"], root)
    recent_log = run(["git", "log", f"-n{recent_commits}", "--oneline", "--decorate"], root)
    configs = find_configs(files, root)
    package_scripts, packages = load_package_jsons(files, root)
    admin_packages = [name for name in packages if name in ADMIN_PACKAGES]
    admin_imports, request_candidates, route_candidates = grep_signals(files, root)
    examples = example_directories(files, root)
    skill_files = project_skill_files(files, root)
    secret_files = sensitive_files(files, root)
    todos, large_sources = concern_signals(files, root)
    touched = recently_touched_files(root, recent_commits) if git_root else Counter()

    lines: list[str] = []
    lines.append(f"# Codebase Survey: `{root}`\n\n")
    lines.append(
        "This survey is raw evidence for agent guidance. Treat it as a map for follow-up inspection, not as final policy.\n\n"
    )
    lines.append("## Repository\n\n")
    lines.append(f"- Root: `{root}`\n")
    lines.append(f"- Git root: `{git_root or 'not detected'}`\n")
    lines.append(f"- Current branch: `{branch or 'not detected'}`\n")
    lines.append(f"- Files scanned: {len(files)} (limit {max_files})\n")
    lines.append(f"- Generated: {datetime.now(timezone.utc).isoformat()}\n\n")

    lines.append("## Top-Level Structure\n\n")
    lines.append(format_counter(count_top_dirs(files, root), 25))
    lines.append("\n## File Types\n\n")
    lines.append(format_counter(count_extensions(files), 25))

    lines.append("\n## Config And Agent Docs\n\n")
    lines.append(format_list(configs, 60))

    lines.append("\n## Project Skill Files\n\n")
    lines.append(format_list(skill_files, 40))

    lines.append("\n## Sensitive Files Present (Not Read)\n\n")
    lines.append(format_list(secret_files, 40))

    lines.append("\n## Package Scripts\n\n")
    if package_scripts:
        for package_file, scripts in package_scripts.items():
            lines.append(f"- `{package_file}`: {', '.join(f'`{script}`' for script in scripts) or 'no scripts'}\n")
    else:
        lines.append("- None detected\n")

    lines.append("\n## Dependency Signals\n\n")
    if packages:
        lines.append(f"- Packages found: {len(packages)}\n")
        if admin_packages:
            lines.append("- React/admin/data packages:\n")
            lines.append(format_list(admin_packages, 50))
        else:
            lines.append("- React/admin/data packages: none from the built-in signal list\n")
    else:
        lines.append("- No package.json dependencies detected\n")

    lines.append("\n## Example/Best Practice/Case Directories\n\n")
    lines.append(format_counter(examples, 30))

    lines.append("\n## Candidate Mature Modules\n\n")
    lines.append(format_counter(candidate_modules(files, root), 30))

    lines.append("\n## Request Or API Wrapper Candidates\n\n")
    lines.append(format_list(request_candidates, 50))

    lines.append("\n## Route/Menu/Permission Candidates\n\n")
    lines.append(format_list(route_candidates, 50))

    lines.append("\n## React/Admin Import Candidates\n\n")
    lines.append(format_list(admin_imports, 50))

    lines.append("\n## TODO/FIXME/HACK Signals\n\n")
    lines.append(format_counter(todos, 30))

    lines.append("\n## Largest Source Files\n\n")
    lines.append(format_line_counts(large_sources, 30))

    lines.append("\n## Recent Commits\n\n")
    if recent_log:
        lines.append("```text\n")
        lines.append(recent_log)
        lines.append("\n```\n")
    else:
        lines.append("- No git history detected\n")

    lines.append("\n## Recently Touched Files\n\n")
    lines.append(format_counter(touched, 40))

    lines.append("\n## Suggested Follow-Up Reads\n\n")
    follow_ups: list[str] = []
    follow_ups.extend(configs[:10])
    follow_ups.extend(skill_files[:10])
    follow_ups.extend([key for key, _ in examples.most_common(10)])
    follow_ups.extend(request_candidates[:10])
    follow_ups.extend(route_candidates[:10])
    follow_ups.extend(admin_imports[:10])
    follow_ups.extend([key for key, _ in todos.most_common(10)])
    follow_ups.extend([key for key, _ in large_sources[:10]])
    follow_ups.extend([key for key, _ in candidate_modules(files, root).most_common(10)])
    lines.append(format_list(dict.fromkeys(follow_ups).keys(), 50))

    return "".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository or project root to survey")
    parser.add_argument("--output", help="Write markdown report to this path")
    parser.add_argument("--max-files", type=int, default=8000, help="Maximum files to scan")
    parser.add_argument("--recent-commits", type=int, default=20, help="Recent commits to inspect")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.repo)
    if not root.exists() or not root.is_dir():
        print(f"error: repo path is not a directory: {root}", file=sys.stderr)
        return 2

    report = build_report(root, max_files=args.max_files, recent_commits=args.recent_commits)
    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(report, encoding="utf-8")
    else:
        print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
