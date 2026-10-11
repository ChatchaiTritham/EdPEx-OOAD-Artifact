"""Quiescence check: position by which all but one commit of a layer occurred,
its exact probability under an even spread, and the longest commit-free run.
Reads data/churn_counts.json (first deployment, baseline import excluded)."""
import json
from math import comb
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
commits = [c for c in data["rounds"]["round1"]["commits"] if not c["baseline"]]
N = len(commits)
out = {}
for layer in data["layers"]:
    pos = [i + 1 for i, c in enumerate(commits) if layer in c["layers"]]
    n = len(pos)
    if n < 5:
        continue
    q = pos[-2]
    # P(at most one of n positions drawn without replacement lies after q)
    p = (comb(q, n) + comb(q, n - 1) * (N - q)) / comb(N, n)
    gap = max(b - a for a, b in zip([0] + pos, pos + [N + 1])) - 1
    out[layer] = {"n": n, "all_but_one_by": q, "fraction": round(q / N, 3),
                  "p_exact": p, "longest_gap": gap, "gap_fraction": round(gap / N, 3)}
print(json.dumps(out, indent=1))
