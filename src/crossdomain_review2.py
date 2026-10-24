"""Exploratory checks added after the second simulated review (2026-10-24; NOT pre-specified).

1. Exact binomial (Clopper-Pearson) 95% CI of the late share L20 per system.
2. Minimum attainable one-sided Fisher p for each moderator's 2x2 design (12 systems).
3. RQ2 without the EdPEx system; H1 with EdPEx recoded as 'data' (its rubric is a JSON configuration).
4. Author-date inversions in each commit sequence (commits whose date precedes the previous commit's).
Output: results/crossdomain_review2.json.
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
SEED = 20261024


def sequence(key):
    if key == "edpex":
        r1 = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))["rounds"]["round1"]
        return [[c["date"], 0, int(any(k in c["layers"] for k in ("rubric_configuration", "scoring_engine")))]
                for c in r1["commits"] if not c["baseline"]]
    return json.loads((ROOT / "data" / "crossdomain" / f"{key}.json").read_text(encoding="utf-8"))["commits"]


def fisher_min(n_pred, n_total):
    best = 1.0
    for s in range(1, n_total + 1):
        for a in range(0, min(s, n_pred) + 1):
            b, c = n_pred - a, s - a
            d = n_total - n_pred - c
            if b < 0 or c < 0 or d < 0:
                continue
            best = min(best, float(stats.fisher_exact([[a, b], [c, d]], alternative="greater").pvalue))
    return best


def acc(res, keys, pred):
    hits = sum((res[k]["verdict"] == "SETTLES") == pred(k) for k in keys)
    a = sum(1 for k in keys if pred(k) and res[k]["verdict"] == "SETTLES")
    b = sum(1 for k in keys if pred(k) and res[k]["verdict"] != "SETTLES")
    c = sum(1 for k in keys if not pred(k) and res[k]["verdict"] == "SETTLES")
    d = sum(1 for k in keys if not pred(k) and res[k]["verdict"] != "SETTLES")
    return {"correct": hits, "of": len(keys), "fisher_p": float(stats.fisher_exact([[a, b], [c, d]], alternative="greater").pvalue)}


def main():
    res = json.loads((ROOT / "results" / "crossdomain.json").read_text(encoding="utf-8"))["systems"]
    out = {"note": "exploratory, not pre-specified", "systems": {}}
    for k, m in res.items():
        rows = sequence(k)
        n, kk = len(rows), sum(r[2] for r in rows)
        f = n // 5
        late = int(round(m["L20"] * kk))
        ci = stats.binomtest(late, kk).proportion_ci(method="exact")
        inv = sum(1 for i in range(1, n) if rows[i][0] < rows[i - 1][0])
        out["systems"][k] = {"late": late, "k": kk, "L20_ci95": [round(ci.low, 3), round(ci.high, 3)],
                             "date_inversions": inv}
    out["fisher_min_p"] = {"H1_mechanism (5 predicted of 12)": fisher_min(5, 12), "H2_closure (2 predicted of 12)": fisher_min(2, 12)}
    keys = [k for k in res if k != "edpex"]
    out["without_edpex"] = {"H1": acc(res, keys, lambda k: res[k]["mechanism"] == "code"),
                            "H2": acc(res, keys, lambda k: res[k]["closure"] == "closed")}
    out["H1_edpex_as_data"] = acc(res, list(res), lambda k: res[k]["mechanism"] == "code" and k != "edpex")
    (ROOT / "results" / "crossdomain_review2.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
