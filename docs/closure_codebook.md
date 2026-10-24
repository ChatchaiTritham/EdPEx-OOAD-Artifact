# Closure codebook (written 2026-10-24 after review; codes themselves were frozen at prereg-20261024)

Closure describes the criteria set a system's criteria layer encodes, judged from the project's own README/documentation.

- **closed**: the layer implements one enumerated, versioned criteria set (or a fixed small set of editions) issued by an
  external body, and the project does not describe adding further frameworks/checks as its purpose.
  Indicators: a fixed list of numbered criteria (e.g. WCAG success criteria, EdPEx items); new work is tied to a new edition.
- **open**: the layer is a catalogue the project grows as new standards, platforms, products or checks appear.
  Indicators: contribution guides for adding checks/policies/frameworks; multiple standards or vendor variants; per-release
  lists of new rules.

Borderline cases noted by the coder: kube-bench (one directory per CIS edition; coded open because new editions and vendor
variants are added continuously), HTML_CodeSniffer (WCAG 2.0 plus Section 508 and later 2.1 additions; coded closed).
Single coder (author C. Tritham). Sensitivity to recoding any one system: src/crossdomain_sensitivity.py.
