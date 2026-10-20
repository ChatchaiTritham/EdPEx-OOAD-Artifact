"""Robustness checks requested in review round 4 for the RQ2 timing and intensity results.

  a. First-fifth test with the exact hypergeometric null: a layer's k commits are k positions drawn
     without replacement from the 609 commits after baseline; the count falling in the first fifth
     (positions <= 609/5, the same cut-off as src/timing_exact.py) is hypergeometric. Compared with
     the published binomial p-values.
  b. Moving-block bootstrap (circular, block lengths 5, 10 and 20 consecutive commits, 5,000
     resamples) of the intensity confidence intervals (changed lines / layer lines at head, as in
     src/churn.py) for the criteria-bearing layers and the schema, and of the rank-biserial
     correlation of criteria-bearing against schema positions. Block resampling keeps short-range
     dependence between neighbouring commits that the iid bootstrap ignores.
     Sign convention (as src/timing_exact.py): r = 2*U/(n_a*n_b) - 1 with U the Mann-Whitney count of
     pairs where a criteria position exceeds a schema position; NEGATIVE r = criteria changes EARLIER.
  c. Percentile against BCa intervals for the iid rank-biserial bootstrap (scipy.stats.bootstrap).

Writes results/robustness_r4.json. Existing result files are not touched.
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from scipy import stats as st

import churn

ROOT = Path(__file__).resolve().parents[1]
SEED = 20260915
BOOT = 5000
BLOCKS = (5, 10, 20)
PUBLISHED = {"criteria_intensity": [0.71, 0.14, 1.60], "schema_intensity": [0.89, 0.59, 1.22],
             "rank_biserial": [-0.524, -0.804, -0.187]}
CRIT = {"rubric_configuration", "scoring_engine"}


def rank_biserial(a, b) -> float:
    u = st.mannwhitneyu(a, b, alternative="less").statistic
    return float(2.0 * u / (len(a) * len(b)) - 1.0)


def binom_p(pos, n) -> float:
    k = sum(1 for p in pos if p <= n / 5.0)
    return float(st.binomtest(k, len(pos), 0.2, alternative="greater").pvalue)


def hyper_fifth(pos, n) -> dict:
    cut = int(n / 5.0)  # positions <= n/5, identical to timing_exact.first_fifth
    k = sum(1 for p in pos if p <= cut)
    return {"n": len(pos), "in_first_fifth": k, "cutoff_position": cut,
            "p_exact_hypergeometric": float(st.hypergeom.sf(k - 1, n, cut, len(pos))),
            "p_binomial": binom_p(pos, n)}


def block_indices(n, length, rng):
    starts = rng.integers(0, n, size=int(np.ceil(n / length)))
    return (np.concatenate([np.arange(s, s + length) for s in starts]) % n)[:n]


def r3(x) -> float:
    return round(float(x), 3)


def ci(x) -> list:
    return [r3(np.percentile(x, 2.5)), r3(np.percentile(x, 97.5))]


def main() -> None:
    data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    r1 = churn.summarise(data)["round1"]
    n = r1["commits_after_baseline"]
    rubric, engine, schema = r1["rubric_change_positions"], r1["engine_change_positions"], r1["schema_change_positions"]
    criteria = sorted(set(rubric) | set(engine))
    fifth = {"rubric_configuration": hyper_fifth(rubric, n), "scoring_engine": hyper_fifth(engine, n),
             "schema": hyper_fifth(schema, n), "criteria_bearing": hyper_fifth(criteria, n)}

    changes = [c for c in data["rounds"]["round1"]["commits"] if not c["baseline"]]
    size = data["rounds"]["round1"]["layer_lines_at_head"]
    groups = [["rubric_configuration", "scoring_engine"], ["schema"]]
    lines = np.array([[sum(c["layers"].get(l, [0, 0])[1] for l in ls) for ls in groups] for c in changes], float)
    sizes = np.array([sum(size.get(l, 0) for l in ls) for ls in groups], float)
    point = lines.sum(axis=0) / sizes
    is_crit = np.array([bool(CRIT & set(c["layers"])) for c in changes])
    is_sch = np.array(["schema" in c["layers"] for c in changes])
    posn = np.arange(1, n + 1)

    rng = np.random.default_rng(SEED)
    blocks = {}
    for length in BLOCKS:
        inten, rb = [], []
        for _ in range(BOOT):
            idx = block_indices(n, length, rng)
            inten.append(lines[idx].sum(axis=0) / sizes)
            a, b = posn[idx][is_crit[idx]], posn[idx][is_sch[idx]]
            if len(a) and len(b):
                rb.append(rank_biserial(a, b))
        inten = np.array(inten)
        blocks[f"L{length}"] = {"block_length": length,
                                "criteria_intensity_ci95": ci(inten[:, 0]),
                                "schema_intensity_ci95": ci(inten[:, 1]),
                                "rank_biserial_ci95": ci(rb),
                                "rank_biserial_valid_resamples": len(rb)}

    brng = np.random.default_rng(SEED)
    iid = {}
    for method in ("percentile", "BCa"):
        b = st.bootstrap((np.array(criteria), np.array(schema)), rank_biserial, paired=False, vectorized=False,
                         n_resamples=BOOT, confidence_level=0.95, method=method, random_state=brng)
        iid[method] = [r3(b.confidence_interval.low), r3(b.confidence_interval.high)]

    out = {"seed": SEED, "resamples": BOOT, "commits_excluding_baseline": n,
           "first_fifth_hypergeometric": fifth,
           "point_estimates": {"criteria_intensity": r3(point[0]), "schema_intensity": r3(point[1]),
                               "rank_biserial": r3(rank_biserial(criteria, schema))},
           "published_iid": PUBLISHED,
           "sign_convention": "rank_biserial = 2U/(n_a n_b) - 1, a = criteria-bearing positions, "
                              "b = schema positions; negative = criteria changes earlier",
           "moving_block_bootstrap_circular": blocks,
           "rank_biserial_iid_percentile_vs_bca": iid}
    path = ROOT / "results" / "robustness_r4.json"
    path.write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
