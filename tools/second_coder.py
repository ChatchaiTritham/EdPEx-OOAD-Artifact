"""Independent second coding of the layer assignment, from file CONTENT rather than path.

Coder A (published rules, tools/extract_churn.py) labels a changed file by its path.
Coder B (this script) never sees the path: it reads the file as it stood at the analysed head
and labels it from content signals alone. Agreement between the two codings is reported as
Cohen's kappa with a per-layer breakdown, so readers can judge how much the RQ1/RQ2 layer
counts depend on the path convention.

Run:  python tools/second_coder.py            (writes results/second_coding.json)
"""
from __future__ import annotations

import json
import random
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS = {
    "round1": (Path("D:/xampp/htdocs/sciutk.prompt.in.th"), "86c5040"),
    "round2": (Path("D:/xampp/htdocs/edpex.prompt.in.th/utkic"), None),  # head recorded in churn_counts
}
SAMPLE = 100
SEED = 42

# ---- Coder A: the published path rules (copied verbatim from tools/extract_churn.py) ----
LAYERS_A = [
    ("rubric_configuration", lambda p: p in ("config/edpex.json", "config/cat7_evidence_map.json")),
    ("scoring_engine", lambda p: p == "app/scoring.php"),
    ("schema", lambda p: p.startswith("schema/")),
    ("oo_core", lambda p: p.startswith("src/")),
    ("application_modules", lambda p: p.startswith(("app/", "api/", "eservice/", "etl/", "admission/", "auth/")) or p == "index.php"),
    ("views_and_clients", lambda p: p.startswith(("views/", "clients/", "assets/"))),
    ("tests", lambda p: p.startswith("tests/")),
    ("tooling_and_documents", lambda p: p.startswith((".claude/", "tools/", "docs/", ".docs/", "\".docs/", "Manuscript/", "contract/", "deploy/", "scripts/", "phpstan/", ".github/", ".phpunit.cache/")) or p.endswith(".md")),
]


def coder_a(path: str) -> str:
    for name, match in LAYERS_A:
        if match(path):
            return name
    return "other"


# ---- Coder B: content signals only (no path information) ----
def coder_b(text: str, refined: bool = True) -> str:
    """Label a file from its content. `refined` adds rules for the client languages and
    plain-text notes that the first version of this coder had no rule for (it sent them to
    'other'); both codings are reported."""
    t = text[:200_000]
    low = t.lower()
    if refined:
        if re.search(r"^\s*(import|export)\s+[\w{*]|:\s*(string|number|boolean)\b|interface\s+\w+\s*\{|useState\(|React", t, re.M):
            return "views_and_clients"
        if re.search(r"^[A-Z0-9_]+=", t, re.M) and not re.search(r"<\?php|function\s+\w+\s*\(", t):
            return "tooling_and_documents"
        if re.search(r"^#{1,6}\s+\S|^\s*[-*]\s+\S", t, re.M) and not re.search(r"<\?php|\bclass\s+\w+", t):
            return "tooling_and_documents"
    if re.search(r"extends\s+TestCase|PHPUnit\\Framework|function test[A-Z_]|assertSame\(|assertEquals\(", t):
        return "tests"
    if re.search(r"\bCREATE\s+TABLE\b|\bALTER\s+TABLE\b|\bCREATE\s+INDEX\b", t, re.I):
        return "schema"
    if low.lstrip().startswith(("{", "[")) and re.search(r'"(adli|letci|bands?|criteri|categories)"', low):
        return "rubric_configuration"
    if re.search(r"function\s+scoring[A-Za-z]*\s*\(|LeTCI|ADLI", t) and re.search(r"\bfunction\b", t):
        return "scoring_engine"
    if re.search(r"^\s*namespace\s+\w|^\s*(final\s+)?(abstract\s+)?(class|interface|trait)\s+\w", t, re.M):
        return "oo_core"
    if re.search(r"<(!doctype|html|div|table|form|script|style)\b", low) or re.search(r"\$\(document\)|addEventListener\(|^\s*\.[\w-]+\s*\{", t, re.M):
        return "views_and_clients"
    if re.search(r"^#\s|\bjobs:\s|\bsteps:\s|^---\s*$|\bworkflow_dispatch\b", t, re.M):
        return "tooling_and_documents"
    if re.search(r"^<\?php", t) or re.search(r"\brequire(_once)?\b|\binclude(_once)?\b|\$_(GET|POST|SESSION)\b", t):
        return "application_modules"
    return "other"


def git(repo: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True,
                          encoding="utf-8", errors="replace", check=True).stdout


def kappa(a: list[str], b: list[str]) -> float:
    labels = sorted(set(a) | set(b))
    n = len(a)
    po = sum(x == y for x, y in zip(a, b)) / n
    pe = sum((a.count(l) / n) * (b.count(l) / n) for l in labels)
    return (po - pe) / (1 - pe) if pe < 1 else 1.0


def main() -> None:
    churn = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    out = {"sample_size_per_round": SAMPLE, "seed": SEED, "rounds": {}}
    for rnd, (repo, pinned) in REPOS.items():
        head = pinned or churn["rounds"][rnd]["head"]
        paths = sorted(set(p for p in git(repo, "log", "--name-only", "--pretty=format:", head).splitlines() if p.strip()))
        rng = random.Random(SEED)
        sample = paths if len(paths) <= SAMPLE else rng.sample(paths, SAMPLE)
        a_labels, b_labels, b0_labels, rows = [], [], [], []
        for p in sample:
            try:
                text = git(repo, "show", f"{head}:{p}")
            except subprocess.CalledProcessError:
                continue  # deleted before the analysed head
            la, lb = coder_a(p), coder_b(text, refined=True)
            lb0 = coder_b(text, refined=False)
            a_labels.append(la); b_labels.append(lb); b0_labels.append(lb0)
            rows.append({"path": p, "coder_a": la, "coder_b": lb, "coder_b_unrefined": lb0})
        k = kappa(a_labels, b_labels)
        agree = sum(x == y for x, y in zip(a_labels, b_labels))
        per_layer = {}
        for l in sorted(set(a_labels)):
            idx = [i for i, x in enumerate(a_labels) if x == l]
            per_layer[l] = {"n": len(idx), "agreed": sum(a_labels[i] == b_labels[i] for i in idx)}
        k0 = kappa(a_labels, b0_labels)
        agree0 = sum(x == y for x, y in zip(a_labels, b0_labels))
        out["rounds"][rnd] = {
            "head": head, "files_in_history": len(paths), "coded": len(a_labels),
            "agreement": round(agree / len(a_labels), 4), "cohen_kappa": round(k, 4),
            "agreement_unrefined_coder_b": round(agree0 / len(a_labels), 4),
            "cohen_kappa_unrefined_coder_b": round(k0, 4),
            "per_layer_coder_a": per_layer,
            "disagreements": [r for r in rows if r["coder_a"] != r["coder_b"]][:40],
        }
        print(f'{rnd}: coded {len(a_labels)} files; refined kappa {k:.3f} (agreement {agree/len(a_labels):.3f}); first-version kappa {k0:.3f} (agreement {agree0/len(a_labels):.3f})')
    (ROOT / "results" / "second_coding.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("wrote results/second_coding.json")


if __name__ == "__main__":
    main()
