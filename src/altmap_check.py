"""Compare the published layer mapping with the alternative V6 mapping on the RQ1 shares and
the RQ2 ordering (when each layer's changes occur in the first deployment's commit sequence).

Output: results/altmap_v6.json
"""
from __future__ import annotations

import json
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parent.parent
CRIT = ("rubric_configuration", "scoring_engine")


def load(name):
    return json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))


def analyse(data, rnd="round1"):
    commits = [c for c in data["rounds"][rnd]["commits"] if not c.get("baseline")]
    total = sum(sum(v[1] for v in c["layers"].values()) for c in commits)
    shares, pos, last = {}, {}, {}
    for i, c in enumerate(commits, start=1):
        for l, (_, lines) in c["layers"].items():
            shares[l] = shares.get(l, 0) + lines
            pos.setdefault(l, []).append(i)
            last[l] = i
    return {
        "n_commits": len(commits),
        "total_lines": total,
        "shares": {l: round(100 * v / total, 1) for l, v in sorted(shares.items(), key=lambda x: -x[1])},
        "median_position": {l: median(v) for l, v in sorted(pos.items())},
        "last_position": last,
    }


def main() -> None:
    pub, alt = analyse(load("churn_counts.json")), analyse(load("churn_counts_v6.json"))
    out = {"published": pub, "v6_alternative": alt}
    for name, a in (("published", pub), ("v6_alternative", alt)):
        crit_last = max(a["last_position"].get(l, 0) for l in CRIT)
        others = {l: v for l, v in a["last_position"].items() if l not in CRIT and l != "other"}
        out[name]["criteria_last_change_position"] = crit_last
        out[name]["criteria_settle_before_every_other_layer"] = all(crit_last < v for v in others.values())
        out[name]["other_layers_last_position"] = others
    print(json.dumps({k: {kk: vv for kk, vv in v.items() if kk in
                          ("shares", "criteria_last_change_position",
                           "criteria_settle_before_every_other_layer")}
                      for k, v in out.items()}, indent=2))
    (ROOT / "results" / "altmap_v6.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("wrote results/altmap_v6.json")


if __name__ == "__main__":
    main()
