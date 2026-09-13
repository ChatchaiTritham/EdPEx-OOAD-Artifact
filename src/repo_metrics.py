"""Recompute every count reported in the article from the public snapshot.

Counts that come from published files are recomputed here; counts that come from files that
must stay private (tests, application code, version history) are read from
data/derived_counts.json, which records the SHA-256 of each source file.

Output: results/metrics.json
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SNAP = ROOT / "snapshot"
OO_TYPE = re.compile(r"^\s*((final|abstract|readonly)\s+)*(class|interface|enum|trait)\s+\w+", re.M)


def rubric(path):
    if not path.exists():
        return None
    d = json.loads(path.read_text(encoding="utf-8"))
    cats = d.get("categories", [])
    items = [i for c in cats for i in c.get("items", [])]
    out = {"categories": len(cats), "items": len(items), "points": sum(i.get("points", 0) for i in items)}
    if any("kpi" in i for i in items):
        out["indicator_references"] = sum(len(i.get("kpi") or []) for i in items)
        out["indicator_references_category7"] = sum(len(i.get("kpi") or []) for c in cats if str(c.get("n", c.get("id"))) == "7" for i in c["items"])
        out["category_points"] = {str(c.get("n", c.get("id"))): sum(i.get("points", 0) for i in c["items"]) for c in cats}
    return out


def main():
    derived = json.loads((ROOT / "data" / "derived_counts.json").read_text(encoding="utf-8"))
    metrics = {}
    for rnd in ("round1", "round2"):
        s = SNAP / rnd
        ddl = list((s / "schema_ddl").glob("*.sql"))
        evidence_map = json.loads((s / "config" / "cat7_evidence_map.json").read_text(encoding="utf-8"))["map"]
        linked = {code for codes in evidence_map.values() for code in codes}
        dv = derived[rnd]
        metrics[rnd] = {
            "rubric_edpex": rubric(s / "config" / "edpex.json"),
            "rubric_pmqa": rubric(s / "config" / "pmqa.json"),
            "process_items_linked_to_results": len(evidence_map),
            "distinct_results_indicators_linked": len(linked),
            "create_table_statements": sum(len(re.findall(r"^\s*CREATE\s+TABLE", f.read_text(encoding="utf-8"), re.I | re.M)) for f in ddl),
            "migration_files": len(ddl),
            "aunqa_schema_files": sum(1 for f in ddl if "aunqa" in f.name),
            "oo_types_src": sum(len(OO_TYPE.findall(f.read_text(encoding="utf-8"))) for f in (s / "src").rglob("*.php")),
            # from private files, with provenance hashes in data/derived_counts.json
            "tenant_id_migration_files": dv["tenant_id_migration_files"],
            "test_methods": sum(t["test_methods"] for t in dv["tests"].values()),
            "tqf_mentions_config_schema_app": dv["tqf_mentions_config_schema_app_total"],
            "app_tenant_call_sites": dv["app_tenant_call_sites_all_php"],
            "git": dv["git"],
        }
    metrics["round2"]["pmqa_addition_files"] = derived["round2"]["pmqa_commit_ab9c30e_files"]
    metrics["round2"]["pmqa_addition_touched_scoring_engine"] = "app/scoring.php" in derived["round2"]["pmqa_commit_ab9c30e_files"]
    (ROOT / "results").mkdir(exist_ok=True)
    (ROOT / "results" / "metrics.json").write_text(json.dumps(metrics, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(metrics, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
