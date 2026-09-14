"""Data figures for the PeerJ Computer Science article, drawn only from files in this repository.

Figure 3  schema growth: cumulative CREATE TABLE statements along the migration sequence (both rounds)
Figure 4  process-to-results linkage: EdPEx process items x results items, count of linked indicators
Figure 2  framework structure: category points by Baldrige role, EdPEx 2024-2027 vs PMQA 2019

Authored at the PeerJ text width (415 pt = 14.64 cm) with an 8 pt type floor; colour-blind-safe
Okabe-Ito palette. Output: figures/*.pdf and *.png (600 dpi).
"""
import json
import re
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "figures"
W = 415 / 72.27
OKABE = {"blue": "#0072B2", "orange": "#E69F00", "green": "#009E73", "grey": "#6B6B6B"}
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 8, "axes.titlesize": 8, "axes.labelsize": 8,
                     "xtick.labelsize": 8, "ytick.labelsize": 8, "legend.fontsize": 8, "pdf.fonttype": 42,
                     "axes.spines.top": False, "axes.spines.right": False, "axes.linewidth": 0.6,
                     "xtick.major.width": 0.6, "ytick.major.width": 0.6})
ROLE_LABEL = ["Leadership", "Strategy", "Customers", "Measurement,\nknowledge", "Workforce", "Operations", "Results"]


def save(fig, name):
    OUT.mkdir(exist_ok=True)
    fig.savefig(OUT / f"{name}.pdf", bbox_inches=None)
    fig.savefig(OUT / f"{name}.png", dpi=600, bbox_inches=None)
    plt.close(fig)


def schema_growth():
    fig, ax = plt.subplots(figsize=(W, W * 0.42))
    for rnd, colour, label in (("round1", OKABE["blue"], "Round 1 (faculty)"),
                               ("round2", OKABE["orange"], "Round 2 (international college)")):
        files = sorted((ROOT / "snapshot" / rnd / "schema_ddl").glob("*.sql"))
        counts = [len(re.findall(r"^\s*CREATE\s+TABLE", f.read_text(encoding="utf-8"), re.I | re.M)) for f in files]
        cum = np.cumsum(counts)
        ax.step(np.arange(1, len(cum) + 1), cum, where="post", color=colour, linewidth=1.2, label=label)
        ax.annotate(f"{cum[-1]} tables, {len(files)} files", (len(cum), cum[-1]), xytext=(-4, 4),
                    textcoords="offset points", ha="right", va="bottom", fontsize=8, color=colour)
    ax.set_xlabel("Migration file (in execution order)")
    ax.set_ylabel("Cumulative tables")
    ax.legend(frameon=False, loc="upper left")
    ax.set_xlim(0, None)
    ax.set_ylim(0, 300)
    fig.subplots_adjust(left=0.11, right=0.98, bottom=0.2, top=0.97)
    save(fig, "figure3_schema_growth")


def linkage_heatmap():
    cfg = json.loads((ROOT / "snapshot" / "round2" / "config" / "edpex.json").read_text(encoding="utf-8"))
    emap = json.loads((ROOT / "snapshot" / "round2" / "config" / "cat7_evidence_map.json").read_text(encoding="utf-8"))["map"]
    results_items = [i["code"] for c in cfg["categories"] if c["key"] == "results" for i in c["items"]]
    process_items = [i["code"] for c in cfg["categories"] if c["key"] != "results" for i in c["items"]]
    # indicator code 7-k-nnn belongs to results item 7.k
    mat = np.zeros((len(process_items), len(results_items)), dtype=int)
    for r, item in enumerate(process_items):
        for code in emap.get(item, []):
            k = code.split("-")[1]
            mat[r, results_items.index(f"7.{k}")] += 1
    fig, ax = plt.subplots(figsize=(W * 0.62, W * 0.62))
    im = ax.imshow(mat, cmap="Blues", aspect="auto", vmin=0)
    ax.set_xticks(range(len(results_items)), results_items)
    ax.set_yticks(range(len(process_items)), process_items)
    ax.set_xlabel("Results item (category 7)")
    ax.set_ylabel("Process item (categories 1-6)")
    for (r, c), v in np.ndenumerate(mat):
        ax.text(c, r, str(v) if v else "", ha="center", va="center", fontsize=8,
                color="white" if v > mat.max() * 0.55 else "black")
    cb = fig.colorbar(im, ax=ax, fraction=0.05, pad=0.03)
    cb.set_label("Linked indicators")
    cb.outline.set_linewidth(0.6)
    for s in ax.spines.values():
        s.set_visible(False)
    fig.subplots_adjust(left=0.14, right=0.86, bottom=0.12, top=0.98)
    save(fig, "figure4_linkage")
    return mat, process_items, results_items


def framework_structure():
    cfg = ROOT / "snapshot" / "round2" / "config"
    data = {}
    for name, f in (("EdPEx 2024-2027", "edpex.json"), ("PMQA 2019", "pmqa.json")):
        d = json.loads((cfg / f).read_text(encoding="utf-8"))
        by_role = {c["key"]: sum(i["points"] for i in c["items"]) for c in d["categories"]}
        items = {c["key"]: len(c["items"]) for c in d["categories"]}
        data[name] = ([by_role[k] for k in ("leadership", "strategy", "customers", "measurement", "workforce", "operations", "results")],
                      [items[k] for k in ("leadership", "strategy", "customers", "measurement", "workforce", "operations", "results")])
    y = np.arange(7)[::-1]
    fig, ax = plt.subplots(figsize=(W, W * 0.5))
    for off, (name, colour) in zip((0.2, -0.2), (("EdPEx 2024-2027", OKABE["blue"]), ("PMQA 2019", OKABE["green"]))):
        pts, n_items = data[name]
        bars = ax.barh(y + off, pts, height=0.38, color=colour, label=name)
        for b_, p_, n_ in zip(bars, pts, n_items):
            ax.text(p_ + 5, b_.get_y() + b_.get_height() / 2, f"{p_} ({n_} item{'s' if n_ > 1 else ''})",
                    va="center", ha="left", fontsize=8)
    ax.set_yticks(y, ROLE_LABEL)
    ax.set_xlabel("Points")
    ax.set_xlim(0, 560)
    ax.legend(frameon=False, loc="lower center", bbox_to_anchor=(0.5, 1.0), ncol=2)
    fig.subplots_adjust(left=0.19, right=0.98, bottom=0.12, top=0.9)
    save(fig, "figure2_framework_structure")
    return data


if __name__ == "__main__":
    schema_growth()
    mat, p, r = linkage_heatmap()
    data = framework_structure()
    summary = {"linkage_matrix": {"process_items": p, "results_items": r, "counts": mat.tolist(),
                                  "total_links": int(mat.sum()), "process_items_linked": int((mat.sum(axis=1) > 0).sum())},
               "framework_structure": {k: {"points": v[0], "items": v[1]} for k, v in data.items()}}
    (ROOT / "results" / "figure_data.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary["linkage_matrix"], indent=None)[:400])
