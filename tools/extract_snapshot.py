"""Build the public snapshot from the two private system repositories (run by the authors only).

The production repositories cannot be published: they hold credentials and migration files that
seed personal data. This script copies only what the article's measurements need and removes
everything else:

- rubric configuration: config/edpex.json, config/pmqa.json (round 2), config/cat7_evidence_map.json;
- database schema as DDL only: CREATE/ALTER/DROP TABLE|INDEX|VIEW statements from schema/*.sql,
  with every INSERT/UPDATE/DELETE (and therefore every seeded record) dropped;
- object-oriented source: src/**/*.php;
- derived counts for files that stay private (test methods, TQF mentions and tenant call sites in
  application code, version-control statistics), each with the SHA-256 of the file it was
  counted from, so a reviewer with access can confirm them.

Usage (authors):  python tools/extract_snapshot.py
"""
import datetime
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS = {
    "round1": (Path("D:/xampp/htdocs/sciutk.prompt.in.th"), None),
    "round2": (Path("D:/xampp/htdocs/edpex.prompt.in.th/utkic"), None),
}
CONFIG = ["edpex.json", "pmqa.json", "cat7_evidence_map.json"]
DDL = re.compile(r"^\s*(CREATE|ALTER|DROP)\s+(TABLE|INDEX|UNIQUE\s+INDEX|VIEW|OR\s+REPLACE\s+VIEW)\b", re.I)
TEST_METHOD = re.compile(r"^\s*public\s+function\s+(?!setUp|tearDown|setUpBeforeClass|tearDownAfterClass)\w+\s*\(\s*\)\s*:\s*void", re.M)
PII = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|\b0[689][0-9]{8}\b|\b[A-Z]{1,2}[0-9]{7,8}\b|\bIC6\d{6}\b")


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, encoding="utf-8").stdout.strip()


def statements(sql):
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.S)
    sql = "\n".join(line for line in sql.splitlines() if not line.strip().startswith("--"))
    return [st.strip() + ";" for st in sql.split(";") if DDL.match(st)]


def main():
    derived = {}
    for name, (repo, commit) in REPOS.items():
        out = ROOT / "snapshot" / name
        if out.exists():
            shutil.rmtree(out)
        (out / "config").mkdir(parents=True)
        for c in CONFIG:
            if (repo / "config" / c).exists():
                shutil.copy2(repo / "config" / c, out / "config" / c)
        ddl_dir = out / "schema_ddl"
        ddl_dir.mkdir()
        for f in sorted((repo / "schema").glob("*.sql")):
            text = f.read_text(encoding="utf-8", errors="ignore")
            kept = statements(text)
            (ddl_dir / f.name).write_text(f"-- DDL extracted from {f.name} (sha256 {sha(f)})\n" + "\n\n".join(kept) + "\n",
                                          encoding="utf-8")
        for f in (repo / "src").rglob("*.php"):
            dest = out / "src" / f.relative_to(repo / "src")
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(f, dest)

        tests = {str(f.relative_to(repo)).replace("\\", "/"): {"sha256": sha(f), "test_methods": len(TEST_METHOD.findall(f.read_text(encoding="utf-8", errors="ignore")))}
                 for f in sorted((repo / "tests").rglob("*Test.php"))}
        app_php = [f for f in repo.rglob("*.php") if "vendor" not in f.parts and "node_modules" not in f.parts]
        tqf = {str(f.relative_to(repo)).replace("\\", "/"): len(re.findall(r"TQF|มคอ", f.read_text(encoding="utf-8", errors="ignore")))
               for f in sorted((repo / "app").glob("*.php"))}
        tenant_calls = sum(len(re.findall(r"appTenant\(\)", f.read_text(encoding="utf-8", errors="ignore")))
                           - len(re.findall(r"function appTenant\(\)", f.read_text(encoding="utf-8", errors="ignore")))
                           for f in app_php)
        derived[name] = {
            "head_commit": git(repo, "rev-parse", "--short", "HEAD"),
            "snapshot_basis": "working tree on the extraction date (HEAD plus uncommitted changes)",
            "uncommitted_paths": len(git(repo, "status", "--porcelain").splitlines()),
            "git": {
                "commits": int(git(repo, "rev-list", "--count", "HEAD")),
                "first_commit_date": git(repo, "log", "--reverse", "--format=%ad", "--date=short", "HEAD").split("\n")[0],
                "last_commit_date": git(repo, "log", "-1", "--format=%ad", "--date=short", "HEAD"),
            },
            "tests": tests,
            "tqf_mentions_app": {k: v for k, v in tqf.items() if v},
            "tqf_mentions_config_schema_app_total": sum(
                len(re.findall(r"tqf|มคอ", f.read_text(encoding="utf-8", errors="ignore"), re.I))
                for pattern in ("config/*.json", "schema/*.sql", "app/*.php") for f in repo.glob(pattern)),
            "tenant_id_migration_files": sum(1 for f in (repo / "schema").glob("*.sql")
                                             if "tenant_id" in f.read_text(encoding="utf-8", errors="ignore")),
            "migration_files": len(list((repo / "schema").glob("*.sql"))),
            "app_tenant_call_sites_all_php": tenant_calls,
        }
        if name == "round2":
            derived[name]["pmqa_commit_ab9c30e_files"] = git(repo, "show", "--name-only", "--format=", "ab9c30e").splitlines()

    derived["extracted_on"] = datetime.date.today().isoformat()
    (ROOT / "data").mkdir(exist_ok=True)
    (ROOT / "data" / "derived_counts.json").write_text(json.dumps(derived, indent=2, ensure_ascii=False), encoding="utf-8")

    leaks = []
    for f in (ROOT / "snapshot").rglob("*"):
        if f.is_file():
            for m in PII.finditer(f.read_text(encoding="utf-8", errors="ignore")):
                leaks.append((str(f.relative_to(ROOT)), m.group(0)))
    print("snapshot written; PII-pattern matches:", len(leaks))
    for l in leaks[:20]:
        print("  ", l)


if __name__ == "__main__":
    main()
