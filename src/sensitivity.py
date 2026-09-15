"""Robustness of the change-history findings to analysis choices, from data/churn_counts.json.

Every variant is computed on the first deployment, excluding the baseline import commit:

  V1 calendar time   - timing tests on commit dates (days since the first change) instead of commit positions;
  V2 large commits   - commits whose total changed lines exceed the 95th percentile are dropped (tangled or bulk commits);
  V3 comparison      - criteria-bearing commits earlier than the commits touching each non-criteria layer
                       (one-sided Mann-Whitney, Holm-adjusted);
  V4 product code    - line shares recomputed without the tooling-and-documents and other layers;
  V5 criteria split  - intensity of the rubric configuration and the scoring engine separately.

Output: results/sensitivity.json
"""
import json
from datetime import date
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
CRIT = {"rubric_configuration", "scoring_engine"}
SEED, BOOT = 20260915, 5000


def ks(values, lo, hi):
    res = stats.kstest([(v - lo) / (hi - lo) for v in values], "uniform")
    return {"n": len(values), "D": round(float(res.statistic), 3), "p": float(res.pvalue)}


def positions(changes, pred):
    return [i + 1 for i, c in enumerate(changes) if pred(set(c["layers"]))]


def intensity(changes, size, layers, rng):
    lines = np.array([sum(c["layers"].get(l, [0, 0])[1] for l in layers) for c in changes], dtype=float)
    denom = sum(size.get(l, 0) for l in layers)
    idx = rng.integers(0, len(changes), size=(BOOT, len(changes)))
    samples = lines[idx].sum(axis=1) / denom
    return {"lines_at_head": denom, "changed_per_line": round(float(lines.sum() / denom), 3),
            "ci95": [round(float(np.percentile(samples, 2.5)), 3), round(float(np.percentile(samples, 97.5)), 3)]}


def holm(pvals):
    order = sorted(range(len(pvals)), key=lambda i: pvals[i])
    adj, running = [0.0] * len(pvals), 0.0
    for rank, i in enumerate(order):
        running = max(running, min(1.0, (len(pvals) - rank) * pvals[i]))
        adj[i] = running
    return adj


def main():
    data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    r1 = data["rounds"]["round1"]
    changes = [c for c in r1["commits"] if not c["baseline"]]
    size = r1["layer_lines_at_head"]
    n = len(changes)
    rng = np.random.default_rng(SEED)
    out = {}

    # V1 calendar time
    days = [(date.fromisoformat(c["date"]) - date.fromisoformat(changes[0]["date"])).days for c in changes]
    span = max(days) or 1
    pick = lambda pred: [days[i] for i, c in enumerate(changes) if pred(set(c["layers"]))]  # noqa: E731
    crit_d, schema_d = pick(lambda s: bool(s & CRIT)), pick(lambda s: "schema" in s)
    out["V1_calendar_time"] = {
        "span_days": span,
        "rubric_ks": ks(pick(lambda s: "rubric_configuration" in s), 0, span),
        "engine_ks": ks(pick(lambda s: "scoring_engine" in s), 0, span),
        "schema_ks": ks(schema_d, 0, span),
        "criteria_earlier_than_schema_p": float(stats.mannwhitneyu(crit_d, schema_d, alternative="less").pvalue),
    }

    # V2 drop large commits
    totals = np.array([sum(v[1] for v in c["layers"].values()) for c in changes])
    cut = float(np.percentile(totals, 95))
    kept = [c for c, t in zip(changes, totals) if t <= cut]
    m = len(kept)
    crit_p = positions(kept, lambda s: bool(s & CRIT))
    schema_p = positions(kept, lambda s: "schema" in s)
    out["V2_without_large_commits"] = {
        "threshold_lines": round(cut, 1), "commits_kept": m, "commits_dropped": n - m,
        "rubric_ks": ks(positions(kept, lambda s: "rubric_configuration" in s), 0, m),
        "engine_ks": ks(positions(kept, lambda s: "scoring_engine" in s), 0, m),
        "criteria_earlier_than_schema_p": float(stats.mannwhitneyu(crit_p, schema_p, alternative="less").pvalue),
        "intensity_criteria": intensity(kept, size, CRIT, rng),
        "intensity_schema": intensity(kept, size, ["schema"], rng),
    }

    # V3 criteria earlier than every other layer
    crit_all = positions(changes, lambda s: bool(s & CRIT))
    others = ["schema", "oo_core", "application_modules", "views_and_clients", "tests", "tooling_and_documents"]
    raw = {}
    for layer in others:
        pos = positions(changes, lambda s, l=layer: l in s)
        raw[layer] = {"n": len(pos), "median_position": float(np.median(pos)),
                      "p": float(stats.mannwhitneyu(crit_all, pos, alternative="less").pvalue)}
    for layer, p in zip(others, holm([raw[l]["p"] for l in others])):
        raw[layer]["p_holm"] = p
    out["V3_criteria_earlier_than_each_layer"] = {"criteria_n": len(crit_all),
                                                  "criteria_median_position": float(np.median(crit_all)),
                                                  "layers": raw}

    # V4 product-code shares
    product = [l for l in data["layers"] if l not in ("tooling_and_documents", "other")]
    total = sum(c["layers"].get(l, [0, 0])[1] for c in changes for l in product)
    out["V4_product_code_shares"] = {l: round(sum(c["layers"].get(l, [0, 0])[1] for c in changes) / total, 4) for l in product}

    # V5 criteria layers separately
    out["V5_criteria_split_intensity"] = {l: intensity(changes, size, [l], rng) for l in sorted(CRIT)}

    (ROOT / "results" / "sensitivity.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
