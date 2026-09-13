"""Recompute the article's counts from the public snapshot and compare with results/metrics.json.

Exit status 0 means every count reproduces exactly.
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def main():
    committed = json.loads((ROOT / "results" / "metrics.json").read_text(encoding="utf-8"))
    subprocess.run([sys.executable, str(ROOT / "src" / "repo_metrics.py")], check=True, stdout=subprocess.DEVNULL)
    fresh = json.loads((ROOT / "results" / "metrics.json").read_text(encoding="utf-8"))
    (ROOT / "results" / "metrics.json").write_text(json.dumps(committed, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if fresh != committed:
        print("NOT reproduced: results/metrics.json differs from a fresh computation")
        return 1
    print("All counts in results/metrics.json reproduced exactly from snapshot/ and data/.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
