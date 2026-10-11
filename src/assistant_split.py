"""Split the first deployment's commits by AI-assistant co-author trailer and re-test the RQ2 timing result.

Inputs: data/churn_counts.json, data/assistant_trailers.json. Output: results/assistant_split.json.
Reports trailer coverage overall and per layer, and repeats the first-fifth binomial tests and the one-sided
Mann-Whitney comparison (criteria-bearing vs schema) on trailer-bearing commits only, with positions kept
in the full 609-commit sequence.
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
CRIT = {"rubric_configuration", "scoring_engine"}


def main():
    churn = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    tr = json.loads((ROOT / "data" / "assistant_trailers.json").read_text(encoding="utf-8"))
    out = {}
    for rnd in ("round1", "round2"):
        ch = [c for c in churn["rounds"][rnd]["commits"] if not c["baseline"]]
        flags = [tr[rnd].get(c["commit"]) is not None for c in ch]
        lines = np.array([sum(v[1] for v in c["layers"].values()) for c in ch], dtype=float)
        f = np.array(flags)
        layers = sorted({l for c in ch for l in c["layers"]})
        out[rnd] = {"commits": len(ch), "with_trailer": int(f.sum()),
                    "share_of_lines_with_trailer": round(float(lines[f].sum() / lines.sum()), 3),
                    "per_layer": {l: {"commits": sum(l in c["layers"] for c in ch),
                                      "with_trailer": sum(l in c["layers"] and fl for c, fl in zip(ch, flags))}
                                  for l in layers}}
        if rnd != "round1":
            continue
        n = len(ch)
        no_tr = [i + 1 for i, fl in enumerate(flags) if not fl]
        out[rnd]["positions_without_trailer"] = no_tr
        crit = [i + 1 for i, (c, fl) in enumerate(zip(ch, flags)) if fl and CRIT & set(c["layers"])]
        schema = [i + 1 for i, (c, fl) in enumerate(zip(ch, flags)) if fl and "schema" in c["layers"]]
        sub = {}
        for name, pos in (("criteria_bearing", crit), ("schema", schema)):
            k = sum(p <= 0.2 * n for p in pos)
            sub[name] = {"n": len(pos), "first_fifth": k, "median": float(np.median(pos)),
                         "p_binomial": float(stats.binomtest(k, len(pos), 0.2, alternative="greater").pvalue)}
        mw = stats.mannwhitneyu(crit, schema, alternative="less")
        sub["criteria_earlier_than_schema"] = {"p_mannwhitney_one_sided": float(mw.pvalue),
                                               "rank_biserial": round(float(2 * mw.statistic / (len(crit) * len(schema)) - 1), 3)}
        out[rnd]["trailer_only"] = sub
    (ROOT / "results" / "assistant_split.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
