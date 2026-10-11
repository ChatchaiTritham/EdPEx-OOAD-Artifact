"""Activity-matched null model for the RQ2 timing result.

The uniform null of src/timing_exact.py ignores that the build as a whole was front-loaded. Here the
16 criteria-bearing commits are compared with random sets of 16 commits drawn without replacement from
the commits that touched other product layers (schema, object-oriented core, application modules, views
and clients, tests), and separately from the most front-loaded layer alone (application modules). The
statistics are the median position and the number of commits in the first fifth.
Output: results/null_model.json. Seed fixed; 100,000 draws.
"""
import json
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
CRIT = {"rubric_configuration", "scoring_engine"}
PRODUCT = {"schema", "oo_core", "application_modules", "views_and_clients", "tests"}
SEED, DRAWS = 20261011, 100_000


def test(obs, pool, n, rng):
    pool = np.array(pool)
    med = np.empty(DRAWS)
    fifth = np.empty(DRAWS)
    for t in range(DRAWS):
        s = rng.choice(pool, size=len(obs), replace=False)
        med[t] = np.median(s)
        fifth[t] = (s <= 0.2 * n).sum()
    om, of = float(np.median(obs)), int(sum(p <= 0.2 * n for p in obs))
    return {"pool_size": len(pool), "observed_median": om, "null_median_mean": round(float(med.mean()), 1),
            "p_median": float((np.sum(med <= om) + 1) / (DRAWS + 1)),
            "observed_first_fifth": of, "null_first_fifth_mean": round(float(fifth.mean()), 2),
            "p_first_fifth": float((np.sum(fifth >= of) + 1) / (DRAWS + 1))}


def main():
    data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    ch = [c for c in data["rounds"]["round1"]["commits"] if not c["baseline"]]
    n = len(ch)
    crit = [i + 1 for i, c in enumerate(ch) if CRIT & set(c["layers"])]
    other = [i + 1 for i, c in enumerate(ch) if PRODUCT & set(c["layers"]) and not CRIT & set(c["layers"])]
    app = [i + 1 for i, c in enumerate(ch) if "application_modules" in c["layers"] and not CRIT & set(c["layers"])]
    rng = np.random.default_rng(SEED)
    out = {"draws": DRAWS, "seed": SEED, "commits": n,
           "vs_other_product_commits": test(crit, other, n, rng),
           "vs_application_module_commits": test(crit, app, n, rng)}
    (ROOT / "results" / "null_model.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
