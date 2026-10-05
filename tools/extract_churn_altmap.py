"""Re-extract the change history under an ALTERNATIVE layer mapping (V6).

The published mapping assigns a changed file to a layer by its path prefix, which encodes the
file's role in the deployment. An independent content-based coding of the same files agrees
only moderately with it (tools/second_coder.py), because a PHP tool under tools/ and a view
with embedded logic read like application code. V6 therefore moves every *code* file out of
tooling-and-documents into the layer its language suggests, keeps only non-code artefacts
(Markdown, YAML, text, lock files) as tooling, and re-runs the extraction, so that the
sensitivity of the RQ1 shares and the RQ2 ordering to that convention can be measured.

Output: data/churn_counts_v6.json (same shape as data/churn_counts.json).
"""
from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS = {
    "round1": Path("D:/xampp/htdocs/sciutk.prompt.in.th"),
    "round2": Path("D:/xampp/htdocs/edpex.prompt.in.th/utkic"),
}
CODE = (".php", ".ts", ".tsx", ".js", ".jsx", ".sql", ".py")
CLIENT = (".ts", ".tsx", ".js", ".jsx", ".css", ".scss", ".vue")

LAYERS = [
    ("rubric_configuration", lambda p: p in ("config/edpex.json", "config/cat7_evidence_map.json")),
    ("scoring_engine", lambda p: p == "app/scoring.php"),
    ("schema", lambda p: p.startswith("schema/") or p.endswith(".sql")),
    ("oo_core", lambda p: p.startswith("src/")),
    ("views_and_clients", lambda p: p.startswith(("views/", "clients/", "assets/")) or p.endswith(CLIENT)
        or "/views/" in p),
    ("tests", lambda p: p.startswith("tests/") or "/tests/" in p),
    # V6: code under tooling paths counts as application code, not tooling
    ("application_modules", lambda p: p.startswith(("app/", "api/", "eservice/", "etl/", "admission/", "auth/"))
        or p == "index.php" or p.endswith(CODE)),
    ("tooling_and_documents", lambda p: p.startswith((".claude/", "tools/", "docs/", ".docs/", "\".docs/",
                                                      "Manuscript/", "contract/", "deploy/", "scripts/",
                                                      "phpstan/", ".github/", ".phpunit.cache/"))
        or p.endswith((".md", ".yml", ".yaml", ".txt", ".lock", ".example"))),
]


def layer(path: str) -> str:
    for name, match in LAYERS:
        if match(path):
            return name
    return "other"


def git(repo: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True,
                          encoding="utf-8", errors="replace", check=True).stdout


def main() -> None:
    published = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    out = {"layers": [n for n, _ in LAYERS] + ["other"], "mapping": "V6 alternative (code out of tooling)", "rounds": {}}
    for rnd, repo in REPOS.items():
        head = published["rounds"][rnd]["head"]
        root_commit = git(repo, "rev-list", "--max-parents=0", head).split()[0]
        commits, cur = [], None
        for line in git(repo, "log", "--reverse", "--numstat", "--format=@%H %ad", "--date=short", head).splitlines():
            if line.startswith("@"):
                sha, date = line[1:].split()
                cur = {"commit": sha[:7], "date": date, "baseline": sha.startswith(root_commit[:7]), "layers": {}}
                commits.append(cur)
            elif line.strip() and cur is not None:
                parts = line.split("\t")
                if len(parts) == 3 and parts[0] != "-":
                    add, dele, path = int(parts[0]), int(parts[1]), parts[2]
                    l = layer(path)
                    f, lines = cur["layers"].get(l, [0, 0])
                    cur["layers"][l] = [f + 1, lines + add + dele]
        sizes = {}
        for path in sorted(set(p for p in git(repo, "ls-tree", "-r", "--name-only", head).splitlines() if p.strip())):
            try:
                n = len(git(repo, "show", f"{head}:{path}").splitlines())
            except subprocess.CalledProcessError:
                continue
            l = layer(path)
            sizes[l] = sizes.get(l, 0) + n
        out["rounds"][rnd] = {"head": head, "layer_lines_at_head": sizes, "commits": commits}
        print(f'{rnd}: {len(commits)} commits, {sum(sizes.values())} lines at head')
    (ROOT / "data" / "churn_counts_v6.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("wrote data/churn_counts_v6.json")


if __name__ == "__main__":
    main()
