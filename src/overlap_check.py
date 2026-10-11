"""Disjointness check of the criteria-bearing vs schema Mann-Whitney comparison (post hoc).

Two first-deployment commits touch both a criteria-bearing layer and the schema, so they appear in
both samples of the main comparison. This script repeats the one-sided Mann-Whitney test and the
rank-biserial correlation (with the same 5,000-resample bootstrap interval as src/timing_exact.py)
after removing the shared commits from the schema sample, and from both samples.
Reads data/churn_counts.json; prints JSON, writes nothing.
"""
import json
from pathlib import Path

import numpy as np
from scipy import stats as st

ROOT = Path(__file__).resolve().parents[1]


def rb(a, b):
    return 2 * st.mannwhitneyu(a, b, alternative='less').statistic / (len(a) * len(b)) - 1


def compare(a, b, rng):
    boots = [rb(list(rng.choice(a, len(a))), list(rng.choice(b, len(b)))) for _ in range(5000)]
    return {'n': [len(a), len(b)], 'p_one_sided': float(st.mannwhitneyu(a, b, alternative='less').pvalue),
            'rank_biserial': round(float(rb(a, b)), 3),
            'ci95': [round(float(np.quantile(boots, q)), 3) for q in (0.025, 0.975)]}


def main():
    data = json.loads((ROOT / 'data' / 'churn_counts.json').read_text(encoding='utf-8'))
    ch = [c for c in data['rounds']['round1']['commits'] if not c['baseline']]
    crit = [i + 1 for i, c in enumerate(ch) if {'rubric_configuration', 'scoring_engine'} & set(c['layers'])]
    schema = [i + 1 for i, c in enumerate(ch) if 'schema' in c['layers']]
    shared = sorted(set(crit) & set(schema))
    rng = np.random.default_rng(20260915)
    out = {'shared_positions': shared,
           'as_published': compare(crit, schema, rng),
           'shared_removed_from_schema': compare(crit, [p for p in schema if p not in shared], rng),
           'shared_removed_from_both': compare([p for p in crit if p not in shared],
                                               [p for p in schema if p not in shared], rng)}
    print(json.dumps(out, indent=1))


if __name__ == '__main__':
    main()
