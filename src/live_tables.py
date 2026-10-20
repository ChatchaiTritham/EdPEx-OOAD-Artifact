"""Count table definitions and the tables that remain after DROP/RENAME statements.

Replays the data-definition statements of each deployment's migration files
(snapshot/<round>/schema_ddl/*.sql, in file-name order) and writes
results/live_tables.json.
"""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
PATTERN = re.compile(
    r"(CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+`?(\w+)`?)"
    r"|(DROP\s+TABLE(?:\s+IF\s+EXISTS)?\s+`?(\w+)`?)"
    r"|(RENAME\s+TABLE\s+`?(\w+)`?\s+TO\s+`?(\w+)`?)"
    r"|(ALTER\s+TABLE\s+`?(\w+)`?\s+RENAME\s+TO\s+`?(\w+)`?)",
    re.I,
)


def replay(round_name):
    files = sorted((ROOT / "snapshot" / round_name / "schema_ddl").glob("*.sql"))
    live, counts = set(), {"create": 0, "drop": 0, "rename": 0}
    for f in files:
        for m in PATTERN.finditer(f.read_text(encoding="utf-8", errors="ignore")):
            if m.group(2):
                counts["create"] += 1
                live.add(m.group(2).lower())
            elif m.group(4):
                counts["drop"] += 1
                live.discard(m.group(4).lower())
            else:
                old, new = (m.group(6), m.group(7)) if m.group(6) else (m.group(9), m.group(10))
                counts["rename"] += 1
                live.discard(old.lower())
                live.add(new.lower())
    return {"migration_files": len(files), "create_table_statements": counts["create"],
            "drop_table_statements": counts["drop"], "rename_statements": counts["rename"],
            "tables_at_head": len(live)}


if __name__ == "__main__":
    out = {r: replay(r) for r in ("round1", "round2")}
    (ROOT / "results" / "live_tables.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(out, indent=2))
