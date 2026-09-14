"""ExtensionChecker: decide whether a framework definition can join the Baldrige family by
configuration alone (Algorithm 2 of the article).

Invariants of a Baldrige-family framework F (Section "Design", invariants I1-I6):
  I1  exactly seven categories, whose roles are the seven Baldrige roles
  I2  exactly one category has the results role; the other six are process categories
  I3  every category has at least one item
  I4  item points sum to 1,000
  I5  item codes are unique
  I6  process categories use ADLI and the results category uses LeTCI

Inputs: the rubric configuration files in snapshot/round2/config/ and a structural description of
AUN-QA version 4.0 (data/aunqa_v4_structure.json, transcribed from the official guide).
Output: results/extension_check.json
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ROLES = ["leadership", "strategy", "customers", "measurement", "workforce", "operations", "results"]


def check(defn):
    cats = defn.get("categories", [])
    items = [i for c in cats for i in c.get("items", [])]
    failed = []
    if len(cats) != 7 or sorted(c.get("key") for c in cats) != sorted(ROLES):
        failed.append("I1 seven Baldrige category roles")
    if sum(1 for c in cats if c.get("key") == "results") != 1:
        failed.append("I2 one results category")
    if any(not c.get("items") for c in cats):
        failed.append("I3 non-empty categories")
    if sum(i.get("points", 0) for i in items) != 1000:
        failed.append("I4 points sum to 1,000")
    codes = [i.get("code") for i in items]
    if len(codes) != len(set(codes)):
        failed.append("I5 unique item codes")
    if any((c.get("key") == "results") != (c.get("scoring") == "LeTCI") for c in cats):
        failed.append("I6 ADLI for processes, LeTCI for results")
    return {
        "categories": len(cats),
        "items_per_category": [len(c.get("items", [])) for c in cats],
        "category_points": [sum(i.get("points", 0) for i in c.get("items", [])) for c in cats],
        "total_points": sum(i.get("points", 0) for i in items),
        "failed_invariants": failed,
        "verdict": "configuration-only" if not failed else "requires dedicated model",
    }


def main():
    cfg = ROOT / "snapshot" / "round2" / "config"
    defs = {
        "EdPEx 2024-2027": json.loads((cfg / "edpex.json").read_text(encoding="utf-8")),
        "PMQA 2019": json.loads((cfg / "pmqa.json").read_text(encoding="utf-8")),
        "AUN-QA v4.0": json.loads((ROOT / "data" / "aunqa_v4_structure.json").read_text(encoding="utf-8")),
    }
    out = {name: check(d) for name, d in defs.items()}
    (ROOT / "results").mkdir(exist_ok=True)
    (ROOT / "results" / "extension_check.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    for name, r in out.items():
        print(f"{name:16s} {r['verdict']:28s} failed={r['failed_invariants']}")


if __name__ == "__main__":
    main()
