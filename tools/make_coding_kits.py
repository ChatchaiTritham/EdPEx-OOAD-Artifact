"""Build the two human-coding kits answering review objections (run by the authors only).

Kit A  layer coding: a seeded random sample of 100 files changed in each deployment's history, without the
       layer the path rules assign, for a co-author to label by the role each file plays.
Kit B  independent trace: the twelve criteria-level requirements of Table 5, without the authors' trace,
       for a co-author who did not build the system to trace to code, storage and tests.
Filled sheets are scored by src/human_agreement.py. Output folder given as the first argument.
"""
import csv
import random
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from extract_churn import REPOS  # noqa: E402

SEED = 20261011
LAYERS = ["rubric_configuration", "scoring_engine", "schema", "oo_core", "application_modules",
          "views_and_clients", "tests", "tooling_and_documents", "other"]
REQUIREMENTS = [
    "Seven categories, 17 items, 1,000 points",
    "Process and results scoring schemes",
    "Permitted percentages within bands",
    "Weakest factor caps the band",
    "Evidence required for credit",
    "Approved cycles are final",
    "Item, category and overall scores",
    "Results as levels over time",
    "Integration of processes and results",
    "Access by role and data class",
    "Programme-level assessment (AUN-QA)",
    "Programme and course documents (TQF)",
]


def changed_files(repo):
    out = subprocess.run(["git", "-C", str(repo), "log", "--format=", "--name-only"],
                         capture_output=True, text=True, encoding="utf-8", check=True).stdout
    return sorted({p for p in out.splitlines() if p.strip()})


def main(out_dir):
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    rng = random.Random(SEED)
    for rnd, repo in REPOS.items():
        files = changed_files(repo)
        with open(out / f"kitA_layer_coding_{rnd}.csv", "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(["path", "layer", "notes"])
            for p in rng.sample(files, 100):
                w.writerow([p, "", ""])
    with open(out / "kitB_independent_trace.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["requirement", "code_and_storage", "test_methods", "has_test_evidence(yes/no)",
                    "conforms_to_EdPEx(yes/no/unsure)", "minutes_spent", "notes"])
        for r in REQUIREMENTS:
            w.writerow([r, "", "", "", "", "", ""])
    (out / "README_CODERS.md").write_text(
        "# Instructions for the independent coder\n\n"
        "Work alone and do not consult the manuscript, Table 1/Table 5, or the authors' coding.\n\n"
        "## Kit A - layer coding (kitA_layer_coding_round1.csv, kitA_layer_coding_round2.csv)\n"
        "Open each file in its repository and write ONE layer in column `layer`, chosen by the role the file "
        "plays in the deployment: " + ", ".join(LAYERS) + ".\n"
        "rubric_configuration = files holding the EdPEx rubric or evidence map; scoring_engine = the module that "
        "computes scores; schema = database migrations; oo_core = object-oriented domain/service classes; "
        "application_modules = procedural application, API, ETL, e-service, authentication code; "
        "views_and_clients = server-rendered pages, web/mobile clients, static assets; tests = automated tests; "
        "tooling_and_documents = build/dev tooling, AI-assistant configuration, documentation; other = anything else.\n\n"
        "## Kit B - independent trace (kitB_independent_trace.csv)\n"
        "For each requirement, find in the code of BOTH deployments where it is implemented (code and storage) "
        "and which automated test methods exercise that code. Answer whether test evidence exists, and whether "
        "the implemented rule conforms to the EdPEx 2024-2027 guidelines. Record minutes spent.\n",
        encoding="utf-8")
    print("kits written to", out)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "human_coding")
