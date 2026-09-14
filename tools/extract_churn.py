"""Extract per-layer change history from the two private code bases (run by the authors only).

Reads `git log --numstat` metadata: commit hash, date, and lines added/deleted per path. No file
contents, commit messages or author identities are read or stored. The initial commit of each
repository is a baseline import and is recorded separately rather than counted as change.

Output: data/churn_counts.json (committed; recomputed into results by src/churn.py)
"""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS = {
    "round1": Path("D:/xampp/htdocs/sciutk.prompt.in.th"),
    "round2": Path("D:/xampp/htdocs/edpex.prompt.in.th/utkic"),
}
# ordered: first match wins
LAYERS = [
    ("rubric_configuration", lambda p: p in ("config/edpex.json", "config/cat7_evidence_map.json")),
    ("scoring_engine", lambda p: p == "app/scoring.php"),
    ("schema", lambda p: p.startswith("schema/")),
    ("oo_core", lambda p: p.startswith("src/")),
    ("application_modules", lambda p: p.startswith(("app/", "api/", "eservice/", "etl/", "admission/", "auth/")) or p == "index.php"),
    ("views_and_clients", lambda p: p.startswith(("views/", "clients/", "assets/"))),
    ("tests", lambda p: p.startswith("tests/")),
    ("tooling_and_documents", lambda p: p.startswith((".claude/", "tools/", "docs/", ".docs/", "\".docs/", "Manuscript/", "contract/", "deploy/", "scripts/", "phpstan/", ".github/", ".phpunit.cache/")) or p.endswith(".md")),
]


def layer(path):
    for name, match in LAYERS:
        if match(path):
            return name
    return "other"


def git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, encoding="utf-8", check=True).stdout


def main():
    out = {"layers": [n for n, _ in LAYERS] + ["other"], "rounds": {}}
    for rnd, repo in REPOS.items():
        root_commit = git(repo, "rev-list", "--max-parents=0", "HEAD").split()[0]
        head = git(repo, "rev-parse", "HEAD").strip()
        commits = []
        cur = None
        for line in git(repo, "log", "--reverse", "--numstat", "--format=@%H %ad", "--date=short").splitlines():
            if line.startswith("@"):
                h, date = line[1:].split()
                cur = {"commit": h[:7], "date": date, "baseline": h == root_commit, "layers": {}}
                commits.append(cur)
            elif line.strip():
                added, deleted, path = line.split("\t", 2)
                lines = 0 if added == "-" else int(added) + int(deleted)   # binary files count as 0 lines
                entry = cur["layers"].setdefault(layer(path.replace("\\", "/")), [0, 0])
                entry[0] += 1
                entry[1] += lines
        # size of each layer at the head commit: lines per file from a diff against the empty tree
        sizes = {}
        for line in git(repo, "diff", "--numstat", "4b825dc642cb6eb9a060e54bf8d69288fbee4904", head).splitlines():
            added, _, path = line.split("\t", 2)
            if added != "-":
                name = layer(path.replace("\\", "/"))
                sizes[name] = sizes.get(name, 0) + int(added)
        out["rounds"][rnd] = {"head": head[:7], "layer_lines_at_head": sizes, "commits": commits}
    (ROOT / "data" / "churn_counts.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    for rnd, v in out["rounds"].items():
        print(rnd, len(v["commits"]), "commits, head", v["head"])


if __name__ == "__main__":
    main()
