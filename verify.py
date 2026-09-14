"""Recompute every count, check and figure datum reported in the articles and compare with results/.

Checks results/metrics.json (src/repo_metrics.py) and results/figure_data.json
(src/make_figures.py; needs matplotlib) and results/churn.json (src/churn.py).
Exit status 0 means everything reproduces exactly.
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CHECKS = [("metrics.json", "repo_metrics.py"), ("figure_data.json", "make_figures.py"), ("churn.json", "churn.py")]


def main():
    failed = []
    for result, script in CHECKS:
        path = ROOT / "results" / result
        committed = path.read_bytes()
        subprocess.run([sys.executable, str(ROOT / "src" / script)], check=True, stdout=subprocess.DEVNULL, cwd=ROOT / "src")
        fresh = path.read_bytes()
        path.write_bytes(committed)
        if json.loads(fresh) != json.loads(committed):
            failed.append(result)
    if failed:
        print("NOT reproduced:", ", ".join(failed))
        return 1
    print(f"All {len(CHECKS)} result files reproduced exactly from snapshot/ and data/.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
