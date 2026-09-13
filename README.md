# EdPEx information platform — design and evaluation artifact

Reproducibility artifact for two articles about one EdPEx (Baldrige-based) quality information
platform, built in two rounds at a Thai public university:

- *From quality criteria to a relational core: object-oriented analysis and design of an EdPEx
  information system across two institutional deployments* (PeerJ Computer Science, in preparation);
- *From excellence criteria to an operational quality system: designing an EdPEx information
  platform for a Thai university* (The TQM Journal, submitted) — Table III.

## What is here

| Path | Content |
|---|---|
| `snapshot/round1/`, `snapshot/round2/` | Rubric configuration (`edpex.json`, `pmqa.json`, `cat7_evidence_map.json`), database schema as DDL only, and the object-oriented source (`src/`) of each round |
| `data/derived_counts.json` | Counts taken from files that cannot be published (automated tests, application code, version history), each test file with its SHA-256 |
| `src/repo_metrics.py` | Recomputes every count reported in the articles |
| `results/metrics.json` | The counts as reported |
| `verify.py` | Recomputes and compares with `results/metrics.json` |
| `tools/extract_snapshot.py` | How the snapshot was produced from the private repositories (authors only) |
| `MANIFEST.sha256` | SHA-256 of every file in `snapshot/`, `data/` and `src/` |

## What is not here, and why

The production repositories are not public. They contain credentials and migration files that seed
records about real students and staff, which Thailand's Personal Data Protection Act protects. The
snapshot therefore keeps only DDL statements (`CREATE`, `ALTER`, `DROP` for tables, indexes and
views); every `INSERT`, `UPDATE` and `DELETE` was removed, and the snapshot was scanned for e-mail
addresses, telephone numbers and identity-document patterns (0 matches). Automated tests and
application code are summarised in `data/derived_counts.json` rather than published, and the test
suites are not runnable here because they need the live database.

## Reproduce

Requirements: Python 3.9 or later; no third-party packages.

```bash
python verify.py
```

Expected output: `All counts in results/metrics.json reproduced exactly from snapshot/ and data/.`

## Key counts (`results/metrics.json`)

| | Round 1 (faculty) | Round 2 (international college) |
|---|---|---|
| Commits; date span | 610; 2026-06-11 to 2026-06-28 | 38; 2026-06-27 to 2026-09-08 |
| EdPEx rubric | 7 categories, 17 items, 1,000 points | same |
| Indicator references (category 7) | 220 (107) | 220 (107) |
| PMQA-2562 rubric | – | 7 categories, 12 items, 1,000 points |
| Process items linked to results indicators | 5 items to 40 indicators | 12 items to 61 indicators |
| Migration files; `CREATE TABLE` statements | 92; 120 | 146; 260 |
| Migration files with `tenant_id` | 59 | 89 |
| Object-oriented types in `src/` | 14 | 18 |
| Test methods | 340 | 45 |
| TQF / มคอ mentions (configuration, schema, application) | 26 | 46 |
| `appTenant()` call sites | 99 | 115 |

The PMQA-2562 addition (commit `ab9c30e`) changed four files — `config/pmqa.json`,
`schema/156_pmqa.sql`, `tests/Pmqa/PmqaScoringTest.php` and the test workflow — and did not change
the scoring engine.

## Licence

- Code (`src/`, `tools/`, `verify.py`) and the source files in `snapshot/*/src/`: MIT — see `LICENSE`.
- Data (`snapshot/*/config/`, `snapshot/*/schema_ddl/`, `data/`, `results/`): CC BY 4.0 — see `LICENSE-DATA`.

## Citation

See `CITATION.cff`.
