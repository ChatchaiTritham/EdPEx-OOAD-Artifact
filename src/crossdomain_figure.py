"""Forest plot of the pre-registered cross-domain test (results/crossdomain.json -> figures/jsep/figure_crossdomain.pdf)."""
import json
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
LABEL = {"edpex": "EdPEx system", "html_codesniffer": "HTML_CodeSniffer", "axe_core": "axe-core", "lynis": "Lynis",
         "checkov": "Checkov", "ciso_assistant": "CISO Assistant", "kube_bench": "kube-bench",
         "complianceascode": "ComplianceAsCode", "gatekeeper_library": "Gatekeeper library",
         "kyverno_policies": "Kyverno policies", "trivy_checks": "trivy-checks", "ecqm_content_r4": "eCQM content (R4)"}
MARK = {"code": ("o", "black"), "data": ("s", "0.45"), "dsl": ("^", "0.7")}
NAME = {"code": "criteria as code", "data": "criteria as data library", "dsl": "criteria as policy/measure DSL"}


def main():
    plt.rcParams.update({"font.family": "serif", "font.size": 8, "svg.hashsalt": "x"})
    res = json.loads((ROOT / "results" / "crossdomain.json").read_text(encoding="utf-8"))["systems"]
    keys = list(res)
    fig, ax = plt.subplots(figsize=(5.4, 3.9))
    seen = set()
    for i, k in enumerate(reversed(keys)):
        m = res[k]
        mk, col = MARK[m["mechanism"]]
        ax.plot(m["r_ci"], [i, i], color=col, lw=1.2)
        ax.plot(m["r_rb"], i, mk, color=col, mfc="white" if m["closure"] == "open" else col, ms=5,
                label=None if m["mechanism"] in seen else NAME[m["mechanism"]])
        seen.add(m["mechanism"])
        if m["verdict"] == "SETTLES":
            ax.text(m["r_ci"][1] + 0.03, i, "settles (verdict rule)", va="center", fontsize=6.5)
    ax.axvline(0, color="0.5", lw=0.6, ls="--")
    ax.set_yticks(range(len(keys)), [LABEL[k] for k in reversed(keys)])
    ax.set_xlim(-0.9, 0.9)
    ax.set_xlabel("rank-biserial r, criteria commits vs other commits\n(negative = criteria changes earlier in the sequence)")
    ax.legend(loc="upper right", fontsize=6.5, frameon=False, title="filled marker = closed criteria set", title_fontsize=6.5)
    fig.tight_layout()
    out = ROOT / "figures" / "jsep"
    fig.savefig(out / "figure_crossdomain.pdf", metadata={"CreationDate": None, "Creator": None, "Producer": None})
    fig.savefig(out / "figure_crossdomain.png", dpi=300)


if __name__ == "__main__":
    main()
