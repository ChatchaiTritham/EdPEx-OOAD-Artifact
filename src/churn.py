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
    (ROOT / "results" / "churn.json").write_text(json.dumps(s, indent=2) + "\n", encoding="utf-8")
    figure(s)
    for rnd, v in s.items():
        print(rnd, v["commits_after_baseline"], "commits,", v["lines_changed"], "lines")
        for name in LABELS:
            L = v["layers"][name]
            print(f"   {LABELS[name]:24s} commits {L['commits']:4d}  lines {L['lines_changed']:6d}  share {100 * L['share_of_lines']:5.1f}%  last {L['last_change']}")


if __name__ == "__main__":
    main()
