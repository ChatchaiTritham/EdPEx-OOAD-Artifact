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
| `tools/extract_churn.py`, `data/churn_counts.json`, `src/churn.py`, `results/churn.json`, `figures/figure5_churn.*`, `figures/figure6_intensity.*` | Change metadata by layer, the statistics of Table 2, and Figures 1 and 2 of the article (files figure5_churn and figure6_intensity) |
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

`src/churn.py` also reports, in `results/churn.json` under `statistics`, Kolmogorov-Smirnov tests of when the rubric configuration, scoring engine and schema changed, a Mann-Whitney test that criteria-layer changes came earlier than schema changes, changed lines per line of each layer with bootstrap confidence intervals, and Fisher's exact test comparing rounds (v1.4).

`src/sensitivity.py` (v1.6) tests whether those findings survive other analysis choices and writes `results/sensitivity.json`: timing on calendar days instead of commit positions, dropping commits above the 95th percentile of changed lines, criteria-layer timing against every other layer (Holm-adjusted), line shares of product code only, and the intensity of the rubric configuration and scoring engine separately. Layer sizes at each head commit are line counts from `git diff --numstat` against the empty tree.

## Mapping sensitivity and second coding (v1.7.0)

`tools/extract_churn_altmap.py` re-extracts the same `git log --numstat` metadata from both code bases
under an alternative layer convention: every code file that the published mapping places in tooling and
documents because of its directory is reassigned to the layer its language implies, so that only
Markdown, YAML, text and lock files remain tooling. It writes `data/churn_counts_v6.json`, and
`src/altmap_check.py` recomputes the layer shares and the timing statistics from it into
`results/altmap_v6.json`. This is variant V6 of the sensitivity analysis.

`tools/second_coder.py` codes the layer of each changed file a second time, independently of its path:
it reads the file as it stood at the analysed head and labels it from language and content signals
alone. It writes `results/second_coding.json`, which reports Cohen's kappa against the published path
mapping for both deployments, before and after the content coder was given rules for the client
languages and plain-text notes, and the per-layer breakdown of where the two codings disagree.

## Exact timing statistics (v1.8.1)

`src/timing_exact.py` recomputes the RQ2 timing results with statistics that are defensible at the
sample sizes involved (nine rubric-configuration commits and seven scoring-engine commits). It refers
the one-sample Kolmogorov-Smirnov statistic to its exact null, drawing each layer's commit positions
uniformly without replacement from the deployment's commit sequence 200,000 times; it adds an exact
binomial test of the share of a layer's commits falling in the first fifth of the sequence; and it
reports the criteria-versus-schema comparison with a rank-biserial correlation and a bootstrap
confidence interval for that effect size. Results in `results/timing_exact.json`.

## Journal figures (v1.8.2)

`src/jsep_figures.py` redraws Figures 1-4 of the Journal of Software: Evolution and Process article
at the Wiley one-column text width from `results/churn.json` and `snapshot/`, the same data as
`src/churn.py` and `src/make_figures.py`. Only the presentation differs: panel B of Figure 1 shows the
cumulative share of each layer's commits against an even spread, the quantity the Kolmogorov-Smirnov
test uses. PDF metadata dates are suppressed, so the output in `figures/jsep/` is byte-identical on
rerun with the same Matplotlib version.

## Review checks of the timing result (v1.9.0)

`src/review_checks.py` answers objections to the RQ2 timing tests without resampling: it varies the
first-fifth cut-off from 0.1 to 0.5, applies the first-fifth test to every layer with at least five
commits (base rate of a front-loaded build), Holm-adjusts the eight tests of Table 2 as one family,
reports the share of changed lines carried by commits above the 95th percentile, the size of the
criteria-bearing commits and their presence at the import, and the probability of observing no
criteria-bearing commit in the second deployment's 37 commits. Results in `results/review_checks.json`.