"""Replication of the layer-share and timing tests on CISO Assistant (data/churn_counts_ciso.json).

Mirrors src/churn.py: share of changed lines by layer, one-sample KS of change positions against a
uniform spread, one-sided Mann-Whitney that criteria-layer changes come earlier than schema changes,
and the all-but-one settling position used in src/quiescence.py. The criteria layer here is the
framework library only (no file-level scoring module exists).

Output: results/replication_ciso.json
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent


def main():
    data = json.loads((ROOT / "data" / "churn_counts_ciso.json").read_text(encoding="utf-8"))
    v = data["rounds"]["ciso"]
    changes = [c for c in v["commits"] if not c["baseline"]]
    n = len(changes)
    total = sum(x[1] for c in changes for x in c["layers"].values())
    layers = {}
    for name in data["layers"]:
        touching = [c for c in changes if name in c["layers"]]
        lines = sum(c["layers"][name][1] for c in touching)
        size = v["layer_lines_at_head"].get(name, 0)
        layers[name] = {"commits": len(touching), "lines_changed": lines, "share_of_lines": round(lines / total, 4),
                        "lines_at_head": size, "changed_per_line": round(lines / size, 3) if size else None,
                        "last_change": touching[-1]["date"] if touching else None}
    pos = {k: [i + 1 for i, c in enumerate(changes) if k in c["layers"]] for k in ("rubric_configuration", "schema")}

    def ks(p):
        r = stats.kstest([x / n for x in p], "uniform")
        return {"n": len(p), "D": round(float(r.statistic), 3), "p": float(r.pvalue), "median_rel": round(float(np.median(p)) / n, 3)}

    def all_but_one(p):
        return round(p[-2] / n, 3) if len(p) > 1 else None

    out = {"head": v["head"], "commits_after_baseline": n, "first_date": changes[0]["date"], "last_date": changes[-1]["date"],
           "lines_changed": total, "layers": layers,
           "timing": {"rubric_ks_vs_uniform": ks(pos["rubric_configuration"]), "schema_ks_vs_uniform": ks(pos["schema"]),
                      "criteria_earlier_than_schema_mannwhitney_p": float(stats.mannwhitneyu(pos["rubric_configuration"], pos["schema"], alternative="less").pvalue),
                      "criteria_later_than_schema_mannwhitney_p": float(stats.mannwhitneyu(pos["rubric_configuration"], pos["schema"], alternative="greater").pvalue),
                      "all_but_one_position": {k: all_but_one(p) for k, p in pos.items()}}}
    (ROOT / "results" / "replication_ciso.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: out[k] for k in ("commits_after_baseline", "first_date", "last_date", "timing")}, indent=1))
    for name, L in layers.items():
        print(f"  {name:22s} commits {L['commits']:5d} lines {L['lines_changed']:9d} share {100*L['share_of_lines']:5.1f}% per-line {L['changed_per_line']}")


if __name__ == "__main__":
    main()
