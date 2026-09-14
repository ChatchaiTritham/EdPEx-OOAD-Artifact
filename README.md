# Version-history study of an EdPEx assessment information system — reproducibility artifact

Data and scripts for the article *When does criteria-bearing code settle? Mining the version history of an
assessment information system across two deployments* (PeerJ Computer Science, submitted). The system was
deployed twice at a Thai public university, first for a faculty (round 1) and then for an international
college (round 2).

## What is here

| Path | Content |
|---|---|
| `snapshot/round1/`, `snapshot/round2/` | Rubric configuration as found in each code base (`edpex.json`, `cat7_evidence_map.json`, and in round 2 `pmqa.json`), database schema as DDL only, and the object-oriented source (`src/`) of each round |
| `data/derived_counts.json` | Counts taken from files that cannot be published (automated tests, application code, version history), each test file with its SHA-256 |
| `src/repo_metrics.py` | Recomputes every count reported in the articles |
| `results/metrics.json` | The counts as reported |
| `src/make_figures.py`, `figures/`, `results/figure_data.json` | Figures 3 and 4 of the article and the data behind them |
| `tools/extract_churn.py`, `data/churn_counts.json`, `src/churn.py`, `results/churn.json`, `figures/figure5_churn.*` | Change metadata by layer, the statistics of Table 2 and Figure 5 |
| `verify.py` | Recomputes all result files and compares them with the committed versions |
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

Requirements: Python 3.9 or later; `pip install -r requirements.txt` (NumPy and Matplotlib, used only for the figures).

```bash
python verify.py
```

Expected output: `All 2 result files reproduced exactly from snapshot/ and data/.`

## Key counts (`results/metrics.json`)

| | Round 1 (faculty) | Round 2 (international college) |
|---|---|---|
| Commits; date span | 610; 2026-06-11 to 2026-06-28 | 38; 2026-06-27 to 2026-09-08 |
| EdPEx rubric | 7 categories, 17 items, 1,000 points | same |
| Indicator references (category 7) | 220 (107) | 220 (107) |
| Process items linked to results indicators | 5 items to 40 indicators | 12 items to 61 indicators |
| Migration files; `CREATE TABLE` statements | 92; 120 | 146; 260 |
| Migration files with `tenant_id` | 59 | 89 |
| Object-oriented types in `src/` | 14 | 18 |
| Test methods | 340 | 45 |
| TQF / มคอ mentions (configuration, schema, application) | 26 | 46 |
| `appTenant()` call sites | 99 | 115 |


## Licence

- Code (`src/`, `tools/`, `verify.py`) and the source files in `snapshot/*/src/`: MIT — see `LICENSE`.
- Data (`snapshot/*/config/`, `snapshot/*/schema_ddl/`, `data/`, `results/`): CC BY 4.0 — see `LICENSE-DATA`.

## Citation

See `CITATION.cff`.

## Change history by design layer (v1.3.0)

`tools/extract_churn.py` read `git log --numstat` metadata from the two private code bases (commit hash, date, lines added and deleted per path; no file contents, messages or author identities) into `data/churn_counts.json`. `src/churn.py` classifies each path into a design layer, excludes each repository's baseline import commit, and writes `results/churn.json` and Figure 5 (`figures/figure5_churn`).

`src/churn.py` also reports, in `results/churn.json` under `statistics`, Kolmogorov-Smirnov tests of when the rubric configuration, scoring engine and schema changed, a Mann-Whitney test that criteria-layer changes came earlier than schema changes, changed lines per line of each layer with bootstrap confidence intervals, and Fisher's exact test comparing rounds (v1.4). Layer sizes at each head commit are line counts from `git diff --numstat` against the empty tree.
