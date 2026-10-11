"""Robustness checks for the JSEP article's RQ2 timing result, answering likely review objections.

1. Threshold choice: share of each layer's commits in the first q of the sequence, exact binomial, q = 0.1 ... 0.5.
2. Multiplicity: Holm adjustment over the eight tests of Table 2.
3. Base rate: first-fifth test and median position for every layer with at least five commits.
4. Bulk commits: share of changed lines carried by commits above the 95th percentile.
5. Content of criteria commits: changed lines per commit, co-touch with the schema, presence at the import.
6. Power of the deployment comparison: probability of zero criteria commits in 37 at the first deployment's rate.
Writes results/review_checks.json. Deterministic (no resampling).
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
CRIT = {"rubric_configuration", "scoring_engine"}


def main():
    data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    r1 = data["rounds"]["round1"]
    base = [c for c in r1["commits"] if c["baseline"]][0]
    ch = [c for c in r1["commits"] if not c["baseline"]]
    n = len(ch)
    layers = sorted({l for c in ch for l in c["layers"]})
    pos = {l: [i + 1 for i, c in enumerate(ch) if l in c["layers"]] for l in layers}
    pos["criteria_bearing"] = [i + 1 for i, c in enumerate(ch) if CRIT & set(c["layers"])]
    out = {"commits": n}

    out["threshold"] = {}
    for l in ("rubric_configuration", "scoring_engine", "criteria_bearing", "schema"):
        row = {}
        for q in (0.1, 0.2, 0.25, 0.3, 1 / 3, 0.4, 0.5):
            k = sum(p <= q * n for p in pos[l])
            row[f"{q:.2f}"] = {"in": k, "n": len(pos[l]),
                               "p": float(stats.binomtest(k, len(pos[l]), q, alternative="greater").pvalue)}
        out["threshold"][l] = row

    t = json.loads((ROOT / "results" / "timing_exact.json").read_text(encoding="utf-8"))
    raw = {"rubric_ks": t["exact_ks"]["rubric_configuration"]["p_exact_mc"],
           "rubric_fifth": t["first_fifth"]["rubric_configuration"]["p_exact_binomial"],
           "engine_ks": t["exact_ks"]["scoring_engine"]["p_exact_mc"],
           "engine_fifth": t["first_fifth"]["scoring_engine"]["p_exact_binomial"],
           "schema_ks": t["exact_ks"]["schema"]["p_exact_mc"],
           "schema_fifth": t["first_fifth"]["schema"]["p_exact_binomial"],
           "criteria_vs_schema": t["criteria_earlier_than_schema"]["p_mannwhitney_one_sided"],
           "fisher_deployments": 1.0}
    keys = sorted(raw, key=raw.get)
    adj, run = {}, 0.0
    for rank, k in enumerate(keys):
        run = max(run, min(1.0, (len(keys) - rank) * raw[k]))
        adj[k] = run
    out["holm_table2"] = {k: {"raw": raw[k], "holm": adj[k]} for k in raw}

    out["base_rate"] = {}
    for l in layers + ["criteria_bearing"]:
        p = pos[l]
        if len(p) >= 5:
            k = sum(x <= 0.2 * n for x in p)
            out["base_rate"][l] = {"n": len(p), "first_fifth": k, "share": round(k / len(p), 3),
                                   "median_position": float(np.median(p)),
                                   "p": float(stats.binomtest(k, len(p), 0.2, alternative="greater").pvalue)}

    tot = np.array([sum(v[1] for v in c["layers"].values()) for c in ch], dtype=float)
    cut = float(np.percentile(tot, 95))
    out["bulk"] = {"cut": cut, "commits_above": int((tot > cut).sum()),
                   "share_of_lines": round(float(tot[tot > cut].sum() / tot.sum()), 3),
                   "median_lines_per_commit": float(np.median(tot))}

    cl = {l: [c["layers"][l][1] for c in ch if l in c["layers"]] for l in CRIT}
    out["criteria_commits"] = {l: {"lines": v, "median": float(np.median(v))} for l, v in cl.items()}
    out["co_touch_schema"] = sorted(set(pos["criteria_bearing"]) & set(pos["schema"]))
    out["present_at_import"] = {l: base["layers"].get(l, [0, 0]) for l in ("rubric_configuration", "scoring_engine", "schema")}

    rate = len(pos["criteria_bearing"]) / n
    out["deployment_power"] = {"rate": round(rate, 4), "expected_in_37": round(37 * rate, 2),
                               "p_zero_in_37": round((1 - rate) ** 37, 3)}

    (ROOT / "results" / "review_checks.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
