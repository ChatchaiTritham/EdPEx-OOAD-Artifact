"""Extract the commit sequence of each external system for the pre-registered cross-domain test.

Reads only `git log --name-only` metadata (commit date and touched paths) from a partial clone
(`git clone --bare --filter=blob:none`); no file contents, messages or author identities are stored.
Path rules come from prereg/systems.json (frozen at tag prereg-20261024).

Usage: python tools/extract_crossdomain.py <system-key> <path-to-clone>
Output: data/crossdomain/<system-key>.json  (one row per non-merge commit: [date, files, touches_criteria])
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_systems():
    """The frozen file writes regex backslashes singly (not valid JSON escapes); read them literally."""
    text = (ROOT / "prereg" / "systems.json").read_text(encoding="utf-8")
    return json.loads(text.replace("\\", "\\\\"))["systems"]


def main(key, repo):
    spec = load_systems()[key]
    inc = re.compile(spec["criteria"])
    exc = re.compile(spec["exclude"]) if spec["exclude"] else None

    def is_criteria(p):
        return bool(inc.search(p)) and not (exc and exc.search(p))

    def git(*a):
        return subprocess.run(["git", "-C", str(repo), *a], capture_output=True, text=True,
                              encoding="utf-8", errors="replace", check=True).stdout

    head = git("rev-parse", "HEAD").strip()
    roots = set(git("rev-list", "--max-parents=0", "HEAD").split())
    rows, cur = [], None
    for line in git("log", "--reverse", "--no-merges", "--no-renames", "--name-only",
                    "--format=@%H %ad", "--date=short", "HEAD").splitlines():
        if line.startswith("@"):
            h, date = line[1:].split()
            cur = None if h in roots else [date, 0, 0]
            if cur is not None:
                rows.append(cur)
        elif line.strip() and cur is not None:
            cur[1] += 1
            if is_criteria(line.strip().replace("\\", "/")):
                cur[2] = 1
    out = {"system": key, "source": spec["source"], "head": head[:12], "rule": spec["criteria"],
           "exclude": spec["exclude"], "commits": rows}
    (ROOT / "data" / "crossdomain" / f"{key}.json").write_text(json.dumps(out, separators=(",", ":")) + "\n", encoding="utf-8")
    print(key, head[:12], len(rows), "commits,", sum(r[2] for r in rows), "criteria commits")


if __name__ == "__main__":
    main(sys.argv[1], Path(sys.argv[2]))
