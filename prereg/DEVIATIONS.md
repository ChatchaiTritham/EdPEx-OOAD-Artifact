# Deviations from the pre-registration (prereg-20261024)

1. 2026-10-24, before any statistic: `prereg/systems.json` writes regex backslashes singly (e.g. `\.ya?ml$`),
   which is not valid JSON. The file is left unchanged; the loaders read each backslash literally, so every
   rule means exactly what is written. No rule, system or threshold was changed.
