"""Redraw Figures 1-4 of the JSEP article at the Wiley NJD one-column text width.

Reads only published files of EdPEx-OOAD-Artifact (results/churn.json, snapshot/). Same data as the
artefact's churn.py / make_figures.py; changes are presentation only: deployment wording instead of
"Round", upper-case panel labels matching the captions, serif type matching the body, and panel B of
Figure 1 drawn as the normalised cumulative share against an even spread (the quantity the KS test uses).
Usage: python src/jsep_figures.py   (writes figures/jsep/figure1_churn.pdf ... figure4_linkage.pdf)
"""
import json
import re
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402

ART = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
OUT = ART / "figures" / "jsep"
W = 6.69  # Wiley NJD Times1COL text width (~170 mm)
C = {"blue": "#0072B2", "orange": "#E69F00", "green": "#009E73", "grey": "#6B6B6B", "verm": "#D55E00"}
plt.rcParams.update({"font.family": "serif", "font.serif": ["Times New Roman", "Nimbus Roman", "DejaVu Serif"],
                     "mathtext.fontset": "stix", "font.size": 8, "axes.labelsize": 8, "axes.titlesize": 8,
                     "xtick.labelsize": 8, "ytick.labelsize": 8, "legend.fontsize": 8, "pdf.fonttype": 42,
                     "axes.spines.top": False, "axes.spines.right": False, "axes.linewidth": 0.6,
                     "xtick.major.width": 0.6, "ytick.major.width": 0.6})
LABELS = {"rubric_configuration": "Rubric configuration", "scoring_engine": "Scoring engine",
          "schema": "Database schema", "oo_core": "Object-oriented core",
          "application_modules": "Application modules", "views_and_clients": "Views and clients",
          "tests": "Tests", "tooling_and_documents": "Tooling and documents", "other": "Other"}
DEP = ("First deployment (faculty)", "Second deployment (college)")


def save(fig, name):
    OUT.mkdir(exist_ok=True)
    fig.savefig(OUT / f"{name}.pdf", metadata={"CreationDate": None, "Creator": None, "Producer": None})
    plt.close(fig)


def panel(ax, letter):
    ax.text(-0.21, 1.02, letter, transform=ax.transAxes, fontweight="bold", fontsize=9, ha="right", va="bottom")


def figure1(s):
    fig, (a, b) = plt.subplots(2, 1, figsize=(W, W * 0.72), gridspec_kw={"height_ratios": [1.1, 1]})
    names = list(LABELS)
    y = np.arange(len(names))
    for off, rnd, col, lab in ((-0.2, "round1", C["blue"], DEP[0]), (0.2, "round2", C["orange"], DEP[1])):
        a.barh(y + off, [100 * s[rnd]["layers"][n]["share_of_lines"] for n in names], height=0.38, color=col, label=lab)
    a.set_yticks(y, [LABELS[n] for n in names])
    a.invert_yaxis()
    a.set_xlabel("Share of changed lines (%)")
    a.legend(frameon=False, loc="upper right")
    panel(a, "A")

    r1 = s["round1"]
    n = r1["commits_after_baseline"]
    b.axvspan(0, 0.2, color=C["grey"], alpha=0.10, lw=0)
    b.text(0.1, 0.94, "first fifth", ha="center", fontsize=7, color=C["grey"])
    b.plot([0, 1], [0, 1], ls="--", lw=0.8, color=C["grey"], label="Even spread")
    for key, col, lab in (("rubric_change_positions", C["blue"], "Rubric configuration"),
                          ("engine_change_positions", C["verm"], "Scoring engine"),
                          ("schema_change_positions", C["green"], "Database schema")):
        pos = np.array(r1[key]) / n
        k = len(pos)
        b.step(np.r_[0, pos, 1], np.r_[0, np.arange(1, k + 1) / k, 1], where="post", color=col, lw=1.3,
               label=f"{lab} ($n={k}$)")
    b.set_xlim(0, 1)
    b.set_ylim(0, 1.02)
    b.set_xlabel(f"Commit position in the first deployment (share of {n} commits)")
    b.set_ylabel("Cumulative share of the layer's commits")
    b.legend(frameon=False, loc="lower right")
    panel(b, "B")
    fig.subplots_adjust(left=0.19, right=0.98, bottom=0.08, top=0.96, hspace=0.38)
    save(fig, "figure1_churn")


def figure2(stats):
    rows = sorted(stats["intensity_round1"].items(), key=lambda kv: kv[1]["changed_per_line"])
    fig, ax = plt.subplots(figsize=(W, W * 0.3))
    crit = stats["intensity_round1"]["criteria layers"]["ci95"]
    ax.axvspan(crit[0], crit[1], color=C["blue"], alpha=0.08, lw=0)
    for i, (name, v) in enumerate(rows):
        col = C["blue"] if name == "criteria layers" else C["grey"]
        ax.plot(v["ci95"], [i, i], color=col, lw=1.4)
        ax.plot([v["changed_per_line"]], [i], "o", color=col, ms=4)
    lab = {"criteria layers": "Criteria-bearing layers"}
    ax.set_yticks(range(len(rows)), [lab.get(n, n[0].upper() + n[1:]) for n, _ in rows])
    ax.set_xlabel("Changed lines per line of layer (95% bootstrap interval)")
    ax.set_xlim(0, None)
    fig.subplots_adjust(left=0.2, right=0.98, bottom=0.2, top=0.97)
    save(fig, "figure2_intensity")


def figure3():
    fig, ax = plt.subplots(figsize=(W, W * 0.36))
    for rnd, col, lab in (("round1", C["blue"], DEP[0]), ("round2", C["orange"], DEP[1])):
        files = sorted((ART / "snapshot" / rnd / "schema_ddl").glob("*.sql"))
        cum = np.cumsum([len(re.findall(r"^\s*CREATE\s+TABLE", f.read_text(encoding="utf-8"), re.I | re.M)) for f in files])
        ax.step(np.arange(1, len(cum) + 1), cum, where="post", color=col, lw=1.3, label=lab)
        ax.annotate(f"{cum[-1]} tables, {len(files)} files", (len(cum), cum[-1]), xytext=(-4, 4),
                    textcoords="offset points", ha="right", va="bottom", color=col)
    ax.set_xlabel("Migration file (in execution order)")
    ax.set_ylabel("Cumulative table definitions")
    ax.legend(frameon=False, loc="upper left")
    ax.set_xlim(0, None)
    ax.set_ylim(0, 300)
    fig.subplots_adjust(left=0.09, right=0.98, bottom=0.17, top=0.97)
    save(fig, "figure3_schema_growth")


def figure4():
    cfg = json.loads((ART / "snapshot" / "round2" / "config" / "edpex.json").read_text(encoding="utf-8"))
    emap = json.loads((ART / "snapshot" / "round2" / "config" / "cat7_evidence_map.json").read_text(encoding="utf-8"))["map"]
    res = [i["code"] for c in cfg["categories"] if c["key"] == "results" for i in c["items"]]
    proc = [i["code"] for c in cfg["categories"] if c["key"] != "results" for i in c["items"]]
    mat = np.zeros((len(proc), len(res)), dtype=int)
    for r, item in enumerate(proc):
        for code in emap.get(item, []):
            mat[r, res.index(f"7.{code.split('-')[1]}")] += 1
    fig, ax = plt.subplots(figsize=(W * 0.55, W * 0.55))
    im = ax.imshow(mat, cmap="Blues", aspect="auto", vmin=0)
    ax.set_xticks(range(len(res)), res)
    ax.set_yticks(range(len(proc)), proc)
    ax.set_xlabel("Results item (category 7)")
    ax.set_ylabel("Process item (categories 1–6)")
    for (r, c), v in np.ndenumerate(mat):
        if v:
            ax.text(c, r, str(v), ha="center", va="center", color="white" if v > mat.max() * 0.55 else "black")
    cb = fig.colorbar(im, ax=ax, fraction=0.05, pad=0.03)
    cb.set_label("Linked indicators")
    cb.outline.set_linewidth(0.6)
    for sp in ax.spines.values():
        sp.set_visible(False)
    fig.subplots_adjust(left=0.16, right=0.88, bottom=0.12, top=0.98)
    save(fig, "figure4_linkage")
    assert int((mat.sum(axis=1) > 0).sum()) == 12 and int(mat.sum()) > 0


if __name__ == "__main__":
    s = json.loads((ART / "results" / "churn.json").read_text(encoding="utf-8"))
    figure1(s)
    figure2(s["statistics"])
    figure3()
    figure4()
    print("figures written to", OUT)
