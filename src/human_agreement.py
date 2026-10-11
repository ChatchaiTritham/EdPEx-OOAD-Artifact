"""Score the filled human-coding kits against the published coding.

Kit A: Cohen's kappa between the human layer label and the path-rule layer (tools/extract_churn.py).
Kit B: agreement and Cohen's kappa on "has test evidence" against Table 5 of the article.
Usage: python src/human_agreement.py <folder-with-filled-kits>. Output: results/human_agreement.json.
"""
import csv
import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
from extract_churn import layer  # noqa: E402

# Table 5 of the article: test evidence present for the first ten requirements, absent for the last two
AUTHORS_TEST_EVIDENCE = [True] * 10 + [False] * 2
AUTHORS_TEST_EVIDENCE[8] = False  # integration: count reproduced from configuration, no test method


def kappa(a, b):
    n = len(a)
    po = sum(x == y for x, y in zip(a, b)) / n
    ca, cb = Counter(a), Counter(b)
    pe = sum(ca[k] * cb[k] for k in set(ca) | set(cb)) / n ** 2
    return {"n": n, "agreement": round(po, 3), "kappa": round((po - pe) / (1 - pe), 3) if pe < 1 else None}


def main(folder):
    folder = Path(folder)
    out = {}
    for rnd in ("round1", "round2"):
        f = folder / f"kitA_layer_coding_{rnd}.csv"
        rows = [r for r in csv.DictReader(open(f, encoding="utf-8")) if r["layer"].strip()]
        if rows:
            out[f"layer_{rnd}"] = kappa([r["layer"].strip() for r in rows], [layer(r["path"]) for r in rows])
    f = folder / "kitB_independent_trace.csv"
    rows = list(csv.DictReader(open(f, encoding="utf-8")))
    human = [r["has_test_evidence(yes/no)"].strip().lower() for r in rows]
    if all(h in ("yes", "no") for h in human):
        out["trace_test_evidence"] = kappa([h == "yes" for h in human], AUTHORS_TEST_EVIDENCE)
        out["trace_nonconforming_flagged"] = [r["requirement"] for r in rows
                                              if r["conforms_to_EdPEx(yes/no/unsure)"].strip().lower() == "no"]
    (ROOT / "results" / "human_agreement.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    main(sys.argv[1])
