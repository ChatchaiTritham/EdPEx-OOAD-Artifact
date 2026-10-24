# Deviations from the pre-registration (prereg-20261024)

1. 2026-10-24, before any statistic: `prereg/systems.json` writes regex backslashes singly (e.g. `\.ya?ml$`),
   which is not valid JSON. The file is left unchanged; the loaders read each backslash literally, so every
   rule means exactly what is written. No rule, system or threshold was changed.

2. 2026-10-24, before any statistic: the first push of tag `prereg-20261024` reached GitHub pointing at commit 5caa7d4, which was then rebased onto the remote `main` (whose history had been rewritten without content change) as 631b4ca, tagged `prereg-20261024-main`. The `prereg/` files are identical in both commits. The remote tag was not force-moved.
