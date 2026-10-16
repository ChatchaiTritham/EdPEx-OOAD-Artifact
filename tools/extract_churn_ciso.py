"""Replication: per-layer change history of a public criteria-driven assessment system (CISO Assistant).

Same procedure as tools/extract_churn.py (git log --numstat metadata only; baseline import excluded),
applied to https://github.com/intuitem/ciso-assistant-community. The repository moved its Django apps
under backend/ during its history, so a leading "backend/" is stripped before matching.
CISO Assistant has no file-level scoring module (scores are computed inside core/models.py), so the
scoring_engine layer is empty by construction and the criteria layer is the framework library alone.

Usage: python tools/extract_churn_ciso.py <path-to-clone>
Output: data/churn_counts_ciso.json
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEST = ("tests/", "app_tests/", "frontend/tests/", "frontend/src/tests/")
# ordered: first match wins
LAYERS = [
    ("rubric_configuration", lambda p: p.startswith("library/libraries/") and p.endswith((".yaml", ".yml"))),
    ("scoring_engine", lambda p: False),
    ("schema", lambda p: "/migrations/" in p),
    ("tests", lambda p: p.startswith(TEST) or "/tests/" in p or p.split("/")[-1].startswith("test_") or ".test." in p or ".spec." in p),
    ("oo_core", lambda p: p.endswith("/models.py") or p.endswith("/base_models.py")),
    ("views_and_clients", lambda p: p.startswith(("frontend/", "static/")) or "/templates/" in p or "/static/" in p),
    ("tooling_and_documents", lambda p: p.startswith((".github/", "docs/", "documentation/", "tools/", "charts/", "config/", ".claude/", "cli/", "scripts/"))
     or p.endswith(".md") or p.split("/")[-1].startswith(("docker-compose", "Dockerfile"))),
    ("application_modules", lambda p: p.endswith(".py")),
]


def layer(path):
    p = path.replace("\\", "/")
    p = p[len("backend/"):] if p.startswith("backend/") else p
    for name, match in LAYERS:
        if match(p):
            return name
    return "other"


def git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, encoding="utf-8", errors="replace", check=True).stdout


def main(repo):
    root_commit = git(repo, "rev-list", "--max-parents=0", "HEAD").split()[0]
    head = git(repo, "rev-parse", "HEAD").strip()
    commits, cur = [], None
    for line in git(repo, "log", "--reverse", "--numstat", "--no-renames", "--format=@%H %ad", "--date=short").splitlines():
        if line.startswith("@"):
            h, date = line[1:].split()
            cur = {"commit": h[:9], "date": date, "baseline": h == root_commit, "layers": {}}
            commits.append(cur)
        elif line.strip():
            added, deleted, path = line.split("\t", 2)
            lines = 0 if added == "-" else int(added) + int(deleted)
            entry = cur["layers"].setdefault(layer(path), [0, 0])
            entry[0] += 1
            entry[1] += lines
    sizes = {}
    for line in git(repo, "diff", "--numstat", "4b825dc642cb6eb9a060e54bf8d69288fbee4904", head).splitlines():
        added, _, path = line.split("\t", 2)
        if added != "-":
            sizes[layer(path)] = sizes.get(layer(path), 0) + int(added)
    out = {"source": "https://github.com/intuitem/ciso-assistant-community", "layers": [n for n, _ in LAYERS] + ["other"],
           "rounds": {"ciso": {"head": head[:9], "layer_lines_at_head": sizes, "commits": commits}}}
    (ROOT / "data" / "churn_counts_ciso.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(len(commits), "commits, head", head[:9])


if __name__ == "__main__":
    main(Path(sys.argv[1]))
