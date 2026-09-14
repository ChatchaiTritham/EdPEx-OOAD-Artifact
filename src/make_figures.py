"""Data figures for the PeerJ Computer Science article, drawn only from files in this repository.

Figure 3  schema growth: cumulative CREATE TABLE statements along the migration sequence (both rounds)
Figure 4  process-to-results linkage: EdPEx process items x results items, count of linked indicators

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


if __name__ == "__main__":
    schema_growth()
    mat, p, r = linkage_heatmap()
    summary = {"linkage_matrix": {"process_items": p, "results_items": r, "counts": mat.tolist(),
                                  "total_links": int(mat.sum()), "process_items_linked": int((mat.sum(axis=1) > 0).sum())}}
    (ROOT / "results" / "figure_data.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary["linkage_matrix"], indent=None)[:400])
