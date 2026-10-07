"""Exact and effect-size statistics for the RQ2 timing results.

The asymptotic one-sample Kolmogorov-Smirnov p-values reported earlier rest on n = 9 and n = 7
commits, which is too few for the asymptotic null distribution to be trusted. This script replaces
them with statistics that are defensible at that sample size:

  * an exact Monte-Carlo test of the KS statistic, drawing the positions uniformly without
    replacement from the deployment's commit sequence (the actual null: which commits of the
    sequence touched the layer), with 200,000 draws and a Clopper-Pearson interval on the p-value;
  * the share of each layer's commits that fall in the first fifth of the sequence, with an exact
    binomial test against the 1/5 expected under the same null;
  * the Mann-Whitney comparison of criteria-bearing against schema positions reported with its
    rank-biserial correlation and a bootstrap confidence interval for that effect size, not only a
    p-value.

Writes results/timing_exact.json. Reads data/churn_counts.json through src.churn, so the positions
are exactly those the paper reports.
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from scipy import stats as st

import churn

ROOT = Path(__file__).resolve().parents[1]
SEED = 20260915
DRAWS = 200_000
BOOT = 10_000


def ks_stat(pos: list[int], n: int) -> float:
    """One-sample KS statistic of normalised positions against an even spread."""
    x = np.sort(np.asarray(pos, dtype=float) / n)
    k = len(x)
    i = np.arange(1, k + 1)
    return float(max((i / k - x).max(), (x - (i - 1) / k).max()))


def exact_ks(pos: list[int], n: int, rng: np.random.Generator) -> dict:
    """Monte-Carlo exact test: positions drawn without replacement from 1..n."""
    observed = ks_stat(pos, n)
    k = len(pos)
    hits = 0
    for _ in range(DRAWS):
        draw = rng.choice(n, size=k, replace=False) + 1
        if ks_stat(list(draw), n) >= observed:
            hits += 1
    lo, hi = st.beta.ppf([0.025, 0.975], hits + 0.5, DRAWS - hits + 0.5)
    return {'n': k, 'D': round(observed, 3), 'p_exact_mc': (hits + 1) / (DRAWS + 1),
            'p_ci95': [round(float(lo), 5), round(float(hi), 5)], 'draws': DRAWS}


def first_fifth(pos: list[int], n: int) -> dict:
    """How many of a layer's commits fall in the first fifth of the sequence."""
    cut = n / 5.0
    k = sum(1 for p in pos if p <= cut)
    res = st.binomtest(k, len(pos), 0.2, alternative='greater')
    return {'n': len(pos), 'in_first_fifth': k, 'share': round(k / len(pos), 3),
            'p_exact_binomial': float(res.pvalue),
            'ci95': [round(float(x), 3) for x in res.proportion_ci(0.95)]}


def rank_biserial(a: list[int], b: list[int]) -> float:
    """Rank-biserial correlation for the Mann-Whitney comparison a < b."""
    u = st.mannwhitneyu(a, b, alternative='less').statistic
    return float(2.0 * u / (len(a) * len(b)) - 1.0)


def compare(a: list[int], b: list[int], rng: np.random.Generator) -> dict:
    p = float(st.mannwhitneyu(a, b, alternative='less').pvalue)
    r = rank_biserial(a, b)
    boots = [rank_biserial(list(rng.choice(a, len(a), replace=True)),
                           list(rng.choice(b, len(b), replace=True))) for _ in range(BOOT)]
    lo, hi = np.percentile(boots, [2.5, 97.5])
    return {'n_a': len(a), 'n_b': len(b), 'p_mannwhitney_one_sided': p,
            'rank_biserial': round(r, 3),
            'rank_biserial_ci95': [round(float(lo), 3), round(float(hi), 3)],
            'median_a': float(np.median(a)), 'median_b': float(np.median(b))}


def main() -> None:
    rng = np.random.default_rng(SEED)
    data = json.loads((ROOT / 'data' / 'churn_counts.json').read_text(encoding='utf-8'))
    s = churn.summarise(data)
    r1 = s['round1']
    n = r1['commits_after_baseline']
    rubric = r1['rubric_change_positions']
    engine = r1['engine_change_positions']
    schema = r1['schema_change_positions']
    criteria = sorted(set(rubric) | set(engine))

    out = {
        'seed': SEED, 'commits_excluding_baseline': n,
        'positions': {'rubric_configuration': rubric, 'scoring_engine': engine,
                      'criteria_bearing': criteria, 'schema': schema},
        'exact_ks': {'rubric_configuration': exact_ks(rubric, n, rng),
                     'scoring_engine': exact_ks(engine, n, rng),
                     'schema': exact_ks(schema, n, rng)},
        'first_fifth': {'rubric_configuration': first_fifth(rubric, n),
                        'scoring_engine': first_fifth(engine, n),
                        'schema': first_fifth(schema, n)},
        'criteria_earlier_than_schema': compare(criteria, schema, rng),
    }
    path = ROOT / 'results' / 'timing_exact.json'
    path.write_text(json.dumps(out, indent=1) + '\n', encoding='utf-8')
    print(json.dumps(out['exact_ks'], indent=1))
    print(json.dumps(out['first_fifth'], indent=1))
    print(json.dumps(out['criteria_earlier_than_schema'], indent=1))
    print('written', path)


if __name__ == '__main__':
    main()
