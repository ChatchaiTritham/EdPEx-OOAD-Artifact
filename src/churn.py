"""Change history by design layer (research question on design stability), from data/churn_counts.json.

For each round and layer: commits that touched the layer and lines added plus deleted, excluding the
baseline import commit. Also the commit-sequence positions at which the rubric configuration and the
scoring engine changed, used for Figure 5.

Output: results/churn.json and figures/figure5_churn.pdf/.png
"""
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from make_figures import OKABE, W, save  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LABELS = {
    "rubric_configuration": "Rubric configuration",
    "scoring_engine": "Scoring engine",
    "schema": "Database schema",
    "oo_core": "Object-oriented core",
    "application_modules": "Application modules",
    "views_and_clients": "Views and clients",
    "tests": "Tests",
    "tooling_and_documents": "Tooling and documents",
    "other": "Other",
}
DESIGN = ["rubric_configuration", "scoring_engine", "schema", "oo_core"]


def summarise(data):
    out = {}
    for rnd, v in data["rounds"].items():
        changes = [c for c in v["commits"] if not c["baseline"]]
        total_lines = sum(n for c in changes for _, n in c["layers"].values())
        layers = {}
        for name in data["layers"]:
            touching = [c for c in changes if name in c["layers"]]
            lines = sum(c["layers"][name][1] for c in touching)
            layers[name] = {"commits": len(touching), "lines_changed": lines,
                            "share_of_lines": round(lines / total_lines, 4),
                            "last_change": touching[-1]["date"] if touching else None}
        out[rnd] = {"head": v["head"], "commits_after_baseline": len(changes), "lines_changed": total_lines,
                    "first_date": changes[0]["date"], "last_date": changes[-1]["date"], "layers": layers,
                    "rubric_change_positions": [i + 1 for i, c in enumerate(changes) if "rubric_configuration" in c["layers"]],
                    "engine_change_positions": [i + 1 for i, c in enumerate(changes) if "scoring_engine" in c["layers"]],
                    "schema_change_positions": [i + 1 for i, c in enumerate(changes) if "schema" in c["layers"]]}
    return out


def statistics(data, s, seed=20260915, boot=5000):
    """Significance of the stability pattern (round 1 unless stated).

    timing    - one-sample Kolmogorov-Smirnov tests of the commit positions that touched the rubric
                configuration, the scoring engine and the schema against a uniform spread over the round, and a
                one-sided Mann-Whitney test that criteria-layer changes occur earlier than schema changes;
    intensity - changed lines per line of each layer at the head commit, with 95% bootstrap confidence
                intervals obtained by resampling commits;
    round 2   - Fisher's exact test comparing the share of commits touching the criteria layers in the two rounds.
    """
    import numpy as np
    from scipy import stats

    rng = np.random.default_rng(seed)
    r1 = s["round1"]
    n = r1["commits_after_baseline"]
    crit_pos = sorted(set(r1["rubric_change_positions"]) | set(r1["engine_change_positions"]))
    timing = {
        "rubric_ks_vs_uniform": _ks(r1["rubric_change_positions"], n, stats),
        "engine_ks_vs_uniform": _ks(r1["engine_change_positions"], n, stats),
        "schema_ks_vs_uniform": _ks(r1["schema_change_positions"], n, stats),
        "criteria_earlier_than_schema_mannwhitney_p": float(stats.mannwhitneyu(crit_pos, r1["schema_change_positions"], alternative="less").pvalue),
        "criteria_commits": len(crit_pos),
        "criteria_median_position": float(np.median(crit_pos)),
        "schema_median_position": float(np.median(r1["schema_change_positions"])),
    }
    changes = [c for c in data["rounds"]["round1"]["commits"] if not c["baseline"]]
    size = data["rounds"]["round1"]["layer_lines_at_head"]
    groups = {"criteria layers": ["rubric_configuration", "scoring_engine"], "object-oriented core": ["oo_core"],
              "database schema": ["schema"], "application modules": ["application_modules"],
              "views and clients": ["views_and_clients"], "tests": ["tests"]}
    lines = np.array([[sum(c["layers"].get(l, [0, 0])[1] for l in ls) for ls in groups.values()] for c in changes], dtype=float)
    sizes = np.array([sum(size.get(l, 0) for l in ls) for ls in groups.values()], dtype=float)
    point = lines.sum(axis=0) / sizes
    idx = rng.integers(0, len(changes), size=(boot, len(changes)))
    samples = np.stack([lines[i].sum(axis=0) / sizes for i in idx])
    intensity = {g: {"lines_at_head": int(sizes[k]), "lines_changed": int(lines[:, k].sum()),
                     "changed_per_line": round(float(point[k]), 3),
                     "ci95": [round(float(np.percentile(samples[:, k], 2.5)), 3), round(float(np.percentile(samples[:, k], 97.5)), 3)]}
                 for k, g in enumerate(groups)}

    def touch(rnd):
        return sum(1 for c in data["rounds"][rnd]["commits"]
                   if not c["baseline"] and ({"rubric_configuration", "scoring_engine"} & set(c["layers"])))

    t1, t2 = touch("round1"), touch("round2")
    fisher = stats.fisher_exact([[t1, n - t1], [t2, s["round2"]["commits_after_baseline"] - t2]])
    return {"timing": timing, "intensity_round1": intensity,
            "criteria_commits_by_round": {"round1": [t1, n], "round2": [t2, s["round2"]["commits_after_baseline"]],
                                          "fisher_p": float(fisher.pvalue)}}


def _ks(positions, n, stats):
    res = stats.kstest([p / n for p in positions], "uniform")
    return {"n": len(positions), "D": round(float(res.statistic), 3), "p": float(res.pvalue)}


def figure(s):
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(W, W * 0.78), gridspec_kw={"height_ratios": [1.25, 1]})
    names = [n for n in LABELS]
    y = range(len(names))
    for off, rnd, colour, label in ((-0.2, "round1", OKABE["blue"], "Round 1"), (0.2, "round2", OKABE["orange"], "Round 2")):
        ax1.barh([i + off for i in y], [100 * s[rnd]["layers"][n]["share_of_lines"] for n in names], height=0.38,
                 color=colour, label=label)
    ax1.set_yticks(list(y))
    ax1.set_yticklabels([LABELS[n] for n in names])
    ax1.invert_yaxis()
    ax1.set_xlabel("Share of changed lines (%)")
    ax1.legend(frameon=False, loc="upper right", bbox_to_anchor=(1.0, 0.72))
    ax1.set_title("(a) Where change went", loc="left")

    r1 = s["round1"]
    n = r1["commits_after_baseline"]
    for key, colour, label in (("schema_change_positions", OKABE["green"], "Database schema"),
                               ("rubric_change_positions", OKABE["blue"], "Rubric configuration"),
                               ("engine_change_positions", OKABE["orange"], "Scoring engine")):
        pos = r1[key]
        ax2.step([0] + pos + [n], [0] + list(range(1, len(pos) + 1)) + [len(pos)], where="post", color=colour, linewidth=1.2, label=label)
    ax2.set_xlim(0, n)
    ax2.set_xlabel("Round 1 commit (in order)")
    ax2.set_ylabel("Cumulative commits touching layer")
    ax2.legend(frameon=False, loc="upper left")
    ax2.set_title("(b) When design layers changed", loc="left")
    fig.subplots_adjust(left=0.27, right=0.98, bottom=0.09, top=0.95, hspace=0.55)
    save(fig, "figure5_churn")


def main():
    data = json.loads((ROOT / "data" / "churn_counts.json").read_text(encoding="utf-8"))
    s = summarise(data)
    s["statistics"] = statistics(data, s)
    (ROOT / "results" / "churn.json").write_text(json.dumps(s, indent=2) + "\n", encoding="utf-8")
    figure(s)
    print(json.dumps(s["statistics"], indent=1))
    for rnd, v in ((k, s[k]) for k in ("round1", "round2")):
        print(rnd, v["commits_after_baseline"], "commits,", v["lines_changed"], "lines")
        for name in LABELS:
            L = v["layers"][name]
            print(f"   {LABELS[name]:24s} commits {L['commits']:4d}  lines {L['lines_changed']:6d}  share {100 * L['share_of_lines']:5.1f}%  last {L['last_change']}")


if __name__ == "__main__":
    main()
