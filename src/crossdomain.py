"""Pre-registered cross-domain test of criteria-layer settling (prereg/PREREGISTRATION_2026-10-24.md).

Inputs: data/crossdomain/<system>.json (tools/extract_crossdomain.py) and, for EdPEx, the published
round-1 sequence in data/churn_counts.json (criteria = rubric_configuration or scoring_engine).
Output: results/crossdomain.json. Deterministic (seed 20261024).
"""
import json
from datetime import date
from pathlib import Path

import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parent.parent
SEED = 20261024
B = 2000


def load_systems():
    text = (ROOT / "prereg" / "systems.json").read_text(encoding="utf-8")
    return json.loads(text.replace("\\", "\\\\"))["systems"]


def sequence(key):
    """Rows [date, files, criteria] in commit order, root/baseline excluded."""
    if key == "edpex":
        r1 = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))["rounds"]["round1"]
        return [[c["date"], sum(v[0] for v in c["layers"].values()),
                 int(any(k in c["layers"] for k in ("rubric_configuration", "scoring_engine")))]
                for c in r1["commits"] if not c["baseline"]]
    return json.loads((ROOT / "data" / "crossdomain" / f"{key}.json").read_text(encoding="utf-8"))["commits"]


def rank_biserial(a, b):
    u = stats.mannwhitneyu(a, b, alternative="two-sided").statistic   # U of a
    return 2 * u / (len(a) * len(b)) - 1


def metrics(rows, rng, boot=True):
    n = len(rows)
    crit = np.array([r[2] for r in rows], bool)
    pos = np.arange(1, n + 1)
    pc, po = pos[crit], pos[~crit]
    k = int(crit.sum())
    if k < 5 or len(po) < 5:
        return {"n": n, "k": k, "undetermined": True}
    f = int(np.floor(0.2 * n))
    x = int((pc <= f).sum())
    late = int((pc > n - f).sum())
    p_f20 = float(stats.hypergeom.sf(x - 1, n, k, f))
    p_mw = float(stats.mannwhitneyu(pc, po, alternative="less").pvalue)
    r = rank_biserial(pc, po)
    out = {"n": n, "k": k, "first_fifth": x, "F20": round(x / k, 4), "L20": round(late / k, 4),
           "median_rel": round(float(np.median(pc)) / n, 4), "p_F20": p_f20, "r_rb": round(r, 4), "p_MW": p_mw}
    if boot:
        bs = np.empty(B)
        for i in range(B):
            bs[i] = rank_biserial(rng.choice(pc, len(pc)), rng.choice(po, len(po)))
        out["r_ci"] = [round(float(np.percentile(bs, 2.5)), 4), round(float(np.percentile(bs, 97.5)), 4)]
        out["r_se"] = round(float(bs.std(ddof=1)), 5)
    return out


def calendar(rows):
    d = [date.fromisoformat(r[0]).toordinal() for r in rows]
    lo, hi = min(d), max(d)
    crit = [r[2] for r in rows]
    t = np.array([(x - lo) / (hi - lo) for x in d])
    tc, to = t[np.array(crit, bool)], t[~np.array(crit, bool)]
    return {"median_rel_time": round(float(np.median(tc)), 4), "r_rb_time": round(rank_biserial(tc, to), 4),
            "p_MW_time": float(stats.mannwhitneyu(tc, to, alternative="less").pvalue),
            "F20_time": round(float((tc <= 0.2).mean()), 4), "L20_time": round(float((tc >= 0.8).mean()), 4)}


def holm(ps):
    order = np.argsort(ps)
    m, adj, run = len(ps), [0.0] * len(ps), 0.0
    for i, j in enumerate(order):
        run = max(run, min(1.0, (m - i) * ps[j]))
        adj[j] = run
    return adj


def dl(effects, ses):
    e, v = np.array(effects), np.array(ses) ** 2
    w = 1 / v
    fixed = (w * e).sum() / w.sum()
    q = (w * (e - fixed) ** 2).sum()
    tau2 = max(0.0, (q - (len(e) - 1)) / (w.sum() - (w ** 2).sum() / w.sum())) if len(e) > 1 else 0.0
    ws = 1 / (v + tau2)
    mu = (ws * e).sum() / ws.sum()
    se = (1 / ws.sum()) ** 0.5
    i2 = max(0.0, (q - (len(e) - 1)) / q) if q > 0 else 0.0
    return {"k": len(e), "mean_r": round(float(mu), 4), "ci": [round(float(mu - 1.96 * se), 4), round(float(mu + 1.96 * se), 4)],
            "tau2": round(float(tau2), 5), "I2": round(float(i2), 3)}


def main():
    systems = load_systems()
    rng = np.random.default_rng(SEED)
    res = {}
    for key, spec in systems.items():
        rows = sequence(key)
        m = metrics(rows, rng)
        m.update({"mechanism": spec["mechanism"], "closure": spec["closure"], "first_date": rows[0][0], "last_date": rows[-1][0]})
        if not m.get("undetermined"):
            m["S1_calendar"] = calendar(rows)
            bulk = [r for r in rows if r[1] <= 100]
            s2 = metrics(bulk, rng, boot=False)
            m["S2_bulk_filtered"] = {k: s2[k] for k in ("n", "k", "F20", "L20", "r_rb", "p_F20", "p_MW") if k in s2}
        res[key] = m
    det = [k for k in res if not res[k].get("undetermined")]
    ps = [res[k]["p_F20"] for k in det] + [res[k]["p_MW"] for k in det]
    adj = holm(ps)
    for i, k in enumerate(det):
        m = res[k]
        m["p_F20_holm"], m["p_MW_holm"] = adj[i], adj[i + len(det)]
        m["verdict"] = "SETTLES" if (m["p_F20_holm"] < 0.05 and m["p_MW_holm"] < 0.05 and m["L20"] <= 0.10) else "DOES NOT SETTLE"
    pred = {"H1_mechanism": lambda s: s["mechanism"] == "code", "H2_closure": lambda s: s["closure"] == "closed"}
    hyp = {}
    for name, f in pred.items():
        hits = sum((res[k]["verdict"] == "SETTLES") == f(systems[k]) for k in det)
        a = sum(1 for k in det if f(systems[k]) and res[k]["verdict"] == "SETTLES")
        b = sum(1 for k in det if f(systems[k]) and res[k]["verdict"] != "SETTLES")
        c = sum(1 for k in det if not f(systems[k]) and res[k]["verdict"] == "SETTLES")
        d = sum(1 for k in det if not f(systems[k]) and res[k]["verdict"] != "SETTLES")
        p = float(stats.fisher_exact([[a, b], [c, d]], alternative="greater").pvalue)
        hyp[name] = {"correct": hits, "determined": len(det), "table_[[pred_settle&settles,pred_settle&not],[pred_not&settles,pred_not&not]]": [[a, b], [c, d]],
                     "fisher_p": p, "supported": bool(hits >= round(10 / 12 * len(det)) and p < 0.05)}
    pooled = {}
    for field in ("mechanism", "closure"):
        for g in sorted({systems[k][field] for k in det}):
            ks = [k for k in det if systems[k][field] == g]
            pooled[f"{field}={g}"] = dl([res[k]["r_rb"] for k in ks], [res[k]["r_se"] for k in ks])
    out = {"prereg_tag": "prereg-20261024", "seed": SEED, "bootstrap": B, "systems": res, "hypotheses": hyp, "pooled_random_effects": pooled}
    (ROOT / "results" / "crossdomain.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(f"{'system':20s} {'mech':5s} {'clos':6s} {'n':>6s} {'k':>6s} {'F20':>6s} {'L20':>6s} {'med':>6s} {'r':>7s} {'CI':>17s} {'pF':>8s} {'pMW':>8s} verdict | time r, F20t")
    for k in res:
        m = res[k]
        if m.get("undetermined"):
            print(k, "UNDETERMINED", m["n"], m["k"]); continue
        print(f"{k:20s} {m['mechanism']:5s} {m['closure']:6s} {m['n']:6d} {m['k']:6d} {m['F20']:6.3f} {m['L20']:6.3f} {m['median_rel']:6.3f} {m['r_rb']:7.3f} {str(m['r_ci']):>17s} {m['p_F20_holm']:8.1e} {m['p_MW_holm']:8.1e} {m['verdict']} | {m['S1_calendar']['r_rb_time']}, {m['S1_calendar']['F20_time']}")
    print(json.dumps(hyp, indent=1)); print(json.dumps(pooled, indent=1))


if __name__ == "__main__":
    main()
