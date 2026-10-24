"""Exploratory sensitivity analyses of the cross-domain test (NOT pre-registered; added 2026-10-24 after review).

1. Verdict-rule grid: alpha x late-share threshold -> number of settling systems and H1/H2 accuracy.
2. Closure recoding: flip each system's closure code in turn (single-coder threat) -> H2 accuracy, Fisher p,
   pooled closed/open r.
3. Pooled effects with Hartung-Knapp-Sidik-Jonkman (HKSJ) intervals and 95% prediction intervals.
4. Leave-one-out of the closed group.
Reads results/crossdomain.json only. Output: results/crossdomain_sensitivity.json. Deterministic.
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent


def load():
    r = json.loads((ROOT / "results" / "crossdomain.json").read_text(encoding="utf-8"))["systems"]
    return r


def verdicts(r, alpha, late):
    return {k: (m["p_F20_holm"] < alpha and m["p_MW_holm"] < alpha and (late is None or m["L20"] <= late)) for k, m in r.items()}


def accuracy(r, v, pred):
    hits = sum(v[k] == pred(k) for k in r)
    a = sum(1 for k in r if pred(k) and v[k]); b = sum(1 for k in r if pred(k) and not v[k])
    c = sum(1 for k in r if not pred(k) and v[k]); d = sum(1 for k in r if not pred(k) and not v[k])
    return hits, float(stats.fisher_exact([[a, b], [c, d]], alternative="greater").pvalue)


def pool(effects, ses):
    e, v = np.array(effects, float), np.array(ses, float) ** 2
    k = len(e)
    w = 1 / v
    fixed = (w * e).sum() / w.sum()
    q = (w * (e - fixed) ** 2).sum()
    tau2 = max(0.0, (q - (k - 1)) / (w.sum() - (w ** 2).sum() / w.sum())) if k > 1 else 0.0
    ws = 1 / (v + tau2)
    mu = (ws * e).sum() / ws.sum()
    out = {"k": k, "mean_r": round(float(mu), 4)}
    if k > 1:
        se_hk = np.sqrt((ws * (e - mu) ** 2).sum() / ((k - 1) * ws.sum()))
        t = stats.t.ppf(0.975, k - 1)
        out["hksj_ci"] = [round(float(mu - t * se_hk), 4), round(float(mu + t * se_hk), 4)]
        if k > 2:
            tp = stats.t.ppf(0.975, k - 2)
            pi = tp * np.sqrt(tau2 + 1 / ws.sum())
            out["prediction_interval"] = [round(float(mu - pi), 4), round(float(mu + pi), 4)]
    return out


def main():
    r = load()
    mech = lambda k: r[k]["mechanism"] == "code"
    out = {"note": "exploratory, not pre-registered", "verdict_grid": [], "closure_recoding": [], "pooled_hksj": {}, "closed_leave_one_out": {}}
    for alpha in (0.05, 0.01):
        for late in (0.10, 0.15, 0.20, None):
            v = verdicts(r, alpha, late)
            h1 = accuracy(r, v, mech)
            h2 = accuracy(r, v, lambda k: r[k]["closure"] == "closed")
            out["verdict_grid"].append({"alpha": alpha, "late_max": late, "settling": sorted(k for k in v if v[k]),
                                        "H1_correct": h1[0], "H1_fisher_p": h1[1], "H2_correct": h2[0], "H2_fisher_p": h2[1]})
    v0 = verdicts(r, 0.05, 0.10)
    for flip in r:
        clos = {k: (r[k]["closure"] == "closed") != (k == flip) for k in r}
        h2 = accuracy(r, v0, lambda k: clos[k])
        closed = [k for k in r if clos[k]]
        opened = [k for k in r if not clos[k]]
        out["closure_recoding"].append({"flipped": flip, "H2_correct": h2[0], "H2_fisher_p": h2[1],
                                        "closed": pool([r[k]["r_rb"] for k in closed], [r[k]["r_se"] for k in closed]),
                                        "open": pool([r[k]["r_rb"] for k in opened], [r[k]["r_se"] for k in opened])})
    for field in ("mechanism", "closure"):
        for g in sorted({m[field] for m in r.values()}):
            ks = [k for k in r if r[k][field] == g]
            out["pooled_hksj"][f"{field}={g}"] = pool([r[k]["r_rb"] for k in ks], [r[k]["r_se"] for k in ks])
    closed = [k for k in r if r[k]["closure"] == "closed"]
    for k in closed:
        rest = [x for x in closed if x != k]
        out["closed_leave_one_out"][f"without_{k}"] = pool([r[x]["r_rb"] for x in rest], [r[x]["r_se"] for x in rest])
    (ROOT / "results" / "crossdomain_sensitivity.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    for g in out["verdict_grid"]:
        print(g["alpha"], g["late_max"], len(g["settling"]), g["settling"], "H1", g["H1_correct"], round(g["H1_fisher_p"], 3), "H2", g["H2_correct"], round(g["H2_fisher_p"], 3))
    for c in out["closure_recoding"]:
        print("flip", c["flipped"], "H2", c["H2_correct"], round(c["H2_fisher_p"], 3), "closed", c["closed"]["mean_r"], c["closed"].get("hksj_ci"), "open", c["open"]["mean_r"])
    print(json.dumps(out["pooled_hksj"], indent=0))
    print(out["closed_leave_one_out"])


if __name__ == "__main__":
    main()
