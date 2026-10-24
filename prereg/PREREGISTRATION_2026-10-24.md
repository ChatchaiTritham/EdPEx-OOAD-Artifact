# Pre-registration: cross-domain test of criteria-layer settling (2026-10-24)

Committed and tagged (`prereg-20261024`) before any positional statistic was computed for the
eleven external systems. Systems, path rules and moderators are frozen in `prereg/systems.json`.

## Background
The JSEP manuscript (SMR-26-01311, desk-rejected) found early settling of the criteria-bearing
layer in one EdPEx system and its absence in CISO Assistant. The editor asked for a test of the
refined hypothesis across several systems with different criteria-encoding mechanisms.

## Hypotheses
Unit: one repository; sequence = non-merge commits reachable from the default-branch HEAD in
`git log --reverse --no-merges` order, root commit excluded (EdPEx: the published round-1 sequence,
baseline excluded; round 2 is not used because it is not independent of round 1).
Criteria layer C = files matching the frozen rule; a commit is a C-commit if it touches any C file.

- **H1 (primary moderator = encoding mechanism).** The criteria layer settles early when criteria are
  encoded as program code; it does not settle when criteria are kept as a data library (YAML/JSON
  frameworks) or as a policy/measure DSL library.
  Predicted SETTLES: edpex, html_codesniffer, axe_core, lynis, checkov.
  Predicted DOES NOT SETTLE: ciso_assistant, kube_bench, complianceascode, gatekeeper_library,
  kyverno_policies, trivy_checks, ecqm_content_r4.
- **H2 (competing moderator = closure of the criteria set).** The criteria layer settles only when it
  encodes one fixed, enumerated external criteria set (closed); it keeps changing when the criteria
  set is an open, growing catalogue, whatever the encoding.
  Predicted SETTLES: edpex, html_codesniffer. All other ten: DOES NOT SETTLE.
- **H0.** C-commit positions are exchangeable with other commits (no settling anywhere).

## Metrics (per system)
1. F20 = share of C-commits in the first fifth (positions <= floor(0.2 n)); exact one-sided
   hypergeometric test of X >= observed.
2. Rank-biserial r = 2U/(n_c n_o) - 1 from Mann-Whitney of C-commit positions against positions of
   commits touching no C file (negative = criteria earlier); one-sided p (less); 95% percentile
   bootstrap CI, 2,000 stratified resamples, seed 20261024.
3. L20 = share of C-commits in the last fifth (descriptive and part of the verdict).
4. Median relative position of C-commits.

## Verdict rule (fixed)
SETTLES iff Holm-adjusted p(F20) < 0.05 AND Holm-adjusted p(MWU) < 0.05 AND L20 <= 0.10.
Holm correction over all 24 per-system tests (12 systems x 2). Otherwise DOES NOT SETTLE.
Systems with fewer than 5 C-commits are reported as UNDETERMINED.

## Hypothesis-level decisions
- Accuracy of each moderator = verdicts matching its predictions / determined systems.
  A moderator is SUPPORTED if accuracy >= 10/12 (or the same proportion of determined systems) and
  the one-sided Fisher exact test of verdict x predicted class gives p < 0.05.
- Pooled effect: DerSimonian-Laird random-effects mean of r per mechanism group and per closure
  group, with bootstrap SEs; reported with 95% CI.
- If neither moderator is supported, the paper reports that the hypothesis fails.

## Secondary (exploratory, not used for verdicts)
- S1 calendar time: positions replaced by (date - first) / (last - first).
- S2 bulk filter: commits touching > 100 files removed.
- S3 external-release alignment: dates of C-commits near known criteria releases (descriptive).

## Deviations
Any change after this tag is listed in `prereg/DEVIATIONS.md` with reason.
