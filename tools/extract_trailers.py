"""Extract, per commit, whether its message carries an AI-assistant co-author trailer (run by the authors only).

Reads only the `Co-Authored-By:` trailer lines of each commit message in the two private code bases and
records commit hash -> assistant name (or null). No other message text, author identity or content is
kept. Output: data/assistant_trailers.json.
"""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS = {
    "round1": Path("D:/xampp/htdocs/sciutk.prompt.in.th"),
    "round2": Path("D:/xampp/htdocs/edpex.prompt.in.th/utkic"),
}
TRAILER = re.compile(r"^Co-Authored-By:\s*(Claude[^<]*?|.*?(?:Copilot|GPT|Codex|Gemini)[^<]*?)\s*<", re.I | re.M)


def main():
    out = {}
    for rnd, repo in REPOS.items():
        log = subprocess.run(["git", "-C", str(repo), "log", "--reverse", "--format=%x1e%h%x1f%B"],
                             capture_output=True, text=True, encoding="utf-8", check=True).stdout
        rows = {}
        for rec in log.split("\x1e")[1:]:
            sha, body = rec.split("\x1f", 1)
            m = TRAILER.search(body)
            rows[sha.strip()] = m.group(1).strip() if m else None
        out[rnd] = rows
    (ROOT / "data" / "assistant_trailers.json").write_text(json.dumps(out, indent=1) + "\n", encoding="utf-8")
    print({r: sum(v is not None for v in rows.values()) for r, rows in out.items()},
          {r: len(rows) for r, rows in out.items()})


if __name__ == "__main__":
    main()
