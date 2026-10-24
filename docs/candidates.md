# Candidate log (RETROSPECTIVE, written 2026-10-24 after the analysis)

Candidates were identified on 24 October 2026 from the authors' knowledge of the domains and by browsing GitHub
topics (compliance, compliance-as-code, accessibility, wcag, policy-as-code, opa, kyverno, cis-benchmark, cql, ecqm).
This was not a systematic search; no hit counts were recorded. 22 candidates were considered, 12 included, 10 excluded.

| # | Candidate | Decision | Reason |
|---|---|---|---|
| 1 | EdPEx system, deployment 1 | included | originating case |
| 2 | squizlabs/HTML_CodeSniffer | included | code, closed |
| 3 | dequelabs/axe-core | included | code, open |
| 4 | CISOfy/lynis | included | code, open |
| 5 | bridgecrewio/checkov | included | code, open |
| 6 | intuitem/ciso-assistant-community | included | data, open |
| 7 | aquasecurity/kube-bench | included | data, open |
| 8 | ComplianceAsCode/content | included | data, open |
| 9 | open-policy-agent/gatekeeper-library | included | DSL, open |
| 10 | kyverno/policies | included | DSL, open |
| 11 | aquasecurity/trivy-checks | included | DSL, open |
| 12 | cqframework/ecqm-content-r4 | included | DSL (CQL), open |
| 13 | EdPEx system, deployment 2 | excluded | not independent of deployment 1 |
| 14 | prowler-cloud/prowler | excluded | mechanisms mixed in one layout; domain covered |
| 15 | IBMa/equal-access | excluded | domain duplicated (accessibility); history split across branches |
| 16 | OpenSCAP (scanner) | excluded | engine without criteria content (content = ComplianceAsCode) |
| 17 | open-policy-agent/opa | excluded | engine without criteria content |
| 18 | kyverno/kyverno (engine) | excluded | engine without criteria content |
| 19 | ESLint core rules | excluded | rules are project conventions, not externally issued criteria |
| 20 | Semgrep rules registry | excluded | as 19 |
| 21 | OpenCDS | excluded | no maintained public history located |
| 22 | Moodle / Open edX quality plugins | excluded | no external criteria layer separable by path |
