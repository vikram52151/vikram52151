# Recommended thresholds

Starting values for the gates in this kit, where each number comes from, and whether it is a published
standard, a tool default or just a widely used convention. There is no vendor-neutral standard for most
CI thresholds; treat conventions as starting points and tune them to your product.

How to read the "Type" column:
- **Standard**: published by a standards body or the metric's owner (e.g. web.dev for Core Web Vitals).
- **Tool default**: the default of a widely used tool.
- **Company practice**: published practice of a large engineering organisation.
- **Convention**: common practice with no single authoritative source. This kit's choice.

## General rules for any gate

1. **Gate new code, not the whole codebase.** Apply thresholds to the change ("clean as you code"), so old
   debt does not block every pull request and the agent gets a clear, local pass/fail signal.
2. **Warn first, then block.** Run a new gate in warning mode for a couple of weeks, look at the false
   alarms and the noise, then switch it to failing. Especially for Lighthouse and load tests.
3. **The Tricorder rule for custom checks.** Google requires every static-analysis check it shows to
   developers to have under 10% "effective false positives" (findings nobody acts on). If people ignore a
   check's findings more than about 1 time in 10, fix the check or remove it. Every finding should say how to fix it.
4. **A floor, not a target.** Google's testing book warns that a coverage bar like 80% tends to become a
   ceiling. Don't write tests just to reach a number; use mutation testing to check test quality.
5. **Suppressions need a reason and an expiry date** (allow-listed CVEs, `@SuppressFBWarnings`, `// eslint-disable`,
   `// NOSONAR`, ZAP IGNORE rules).
6. **Ratchet.** When the real value is well above a threshold, raise the threshold. Never lower one to make a change pass.

## Change size and process

| Metric | Starting value | Blocks? | Type | Source |
|---|---|---|---|---|
| Lines changed per PR (excl. lockfiles) | about 400 or less (warn) | Warn | Convention | Google eng-practices: ~100 lines "usually reasonable", 1,000 "usually too large"; Google's 2018 study measured a median of 24 lines. 400 is this kit's pragmatic middle; claims that "200-400 line PRs have fewer defects" have no traceable source. |
| Tests in the same change as the code | always | Review | Company practice | Google eng-practices ("Small CLs", "What to look for") |
| Refactor separate from behaviour change | always | Review | Company practice | Google eng-practices ("Small CLs") |
| Bug fix has a failing-first test | always | Review | Company practice | Anthropic Claude Code best practices ("write a failing test that reproduces the issue, then fix it") |
| Human approval | 1 approver (2 for sensitive code) + code owners | Block | Company practice | Google: 1 LGTM + OWNERS (median 1 approver) |
| Time to first review response | 1 business day maximum | No (team norm) | Company practice | Google eng-practices ("Speed of code reviews") |

## Tests and code health

| Metric | Starting value | Blocks? | Type | Source |
|---|---|---|---|---|
| Line coverage on new code | 80% or more | Block | Tool default | SonarQube "Sonar way" quality gate (new code); applies once there are 20+ new lines |
| Overall coverage | track; 60% acceptable / 75% commendable / 90% exemplary | Dashboard | Company practice (guideline) | Google Testing Blog, "Code Coverage Best Practices" (2020). Google sets no mandate. |
| Duplicated lines on new code | 3% or less | Block | Tool default | SonarQube "Sonar way"; PMD CPD (100 tokens) and jscpd (`threshold: 3`) in this kit |
| Same API copied per region/outlet/status | 0 new copies | Block | This kit's rule | `api-dup-check.py` in the gate and CI. Only a human may accept one with `api-dup-ok: <reason>`. Follows Google's API design guide: resource-oriented design (AIP-121), with list filtering through request fields (AIP-160). |
| New issues / security hotspots on new code | 0 new issues, 100% hotspots reviewed | Block | Tool default | SonarQube "Sonar way" |
| Cognitive complexity per method | 15 or less | Block (new code) | Tool default | Sonar rule S3776 |
| Cyclomatic complexity per method | 10 or less | Warn | Convention | McCabe (1976), common linter default |
| Mutation score on changed code | 60-70% to start, ratchet up | Block (incremental) | Convention | PIT `mutationThreshold` (default 0 = off); Stryker `thresholds.break` (default off; high/low 80/60 only colour the report) |
| Full mutation run | nightly | Dashboard | Convention | Mutation testing is slow; Google runs it diff-based in code review |
| Flaky tests | rerun once to detect, quarantine with an owner and an issue | Process | Company practice | Microsoft flaky-test management; Google: ~1.5% of test runs flaky (2016) |
| Test mix | mostly fast unit tests (Google aims ~80/15/5 unit/integration/E2E) | No | Company practice | Software Engineering at Google, ch. 11 |

## Security

| Metric | Starting value | Blocks? | Type | Source |
|---|---|---|---|---|
| Secrets in the repo (gitleaks) | 0 | Block | Convention | gitleaks exits 1 on any finding |
| New dependencies with known vulnerabilities | 0 new with CVSS 7.0 or higher (High/Critical) and a fix available | Block | Convention | GitHub dependency-review `fail-on-severity: high`; OWASP Dependency-Check `failBuildOnCVSS` = 7; `npm audit --audit-level=high` |
| SAST findings (CodeQL / Semgrep / SpotBugs + FindSecBugs) | 0 new High/Critical | Block | Convention | Tool severity levels |
| DAST (OWASP ZAP baseline scan, on a test environment) | 0 FAIL-level alerts | Block (pre-release) | Convention | ZAP baseline scan; full/active scans nightly |
| Security baseline | OWASP Top 10:2025 in review; ASVS 5.0 Level 2 for apps with sensitive data | Review | Standard | OWASP |
| SBOM and build provenance | SBOM (CycloneDX or SPDX) on every release; SLSA Build Level 2+ | Block (release) | Standard | CycloneDX / SPDX; SLSA v1.1 |
| New dependency exists and is maintained | checked by a human or reviewer | Review | Convention | Package hallucination study (Spracklen et al., USENIX Security 2025): ~20% of LLM-suggested packages did not exist |

## Frontend performance

| Metric | Starting value | Blocks? | Type | Source |
|---|---|---|---|---|
| Largest Contentful Paint (field, 75th percentile) | 2.5 s or less | Dashboard / alert | Standard | web.dev Core Web Vitals |
| Interaction to Next Paint (field, p75) | 200 ms or less | Dashboard / alert | Standard | web.dev (INP replaced FID in March 2024) |
| Cumulative Layout Shift (field, p75) | 0.1 or less | Dashboard / alert | Standard | web.dev |
| Lighthouse CI (lab, median of 3-5 runs) | LCP 2,500 ms or less, CLS 0.1 or less, TBT 200 ms or less (stands in for INP), performance score 0.9 or more | Warn, then block | Convention | Derived from Core Web Vitals; Lighthouse CI assertions |
| Angular `initial` bundle budget | warn 500 kB / error 1 MB (default); tighten to 250 kB / 500 kB | Block (`ng build` fails) | Tool default | Angular CLI defaults and docs example |
| Angular `anyComponentStyle` budget | warn 2 kB / error 4 kB | Block | Tool default | Angular CLI default |

## Backend performance

| Metric | Starting value | Blocks? | Type | Source |
|---|---|---|---|---|
| Smoke load test p95 latency | under 500 ms (p99 under 1,000 ms) | Block (pre-release / nightly) | Convention | Matches the k6 docs examples and the report. Set from your SLOs; run on fixed-size infrastructure. |
| Smoke load test p99 latency | under 1,000 ms | Block (pre-release) | Convention | k6 / Gatling practice |
| Error rate under load | under 1% | Block (pre-release) | Convention | k6 thresholds (`http_req_failed: rate<0.01`) |
| SQL statements per use case | exact expected count asserted in tests | Block | Convention | Hibernate statistics / datasource-proxy (catches N+1) |
| Slow query log in test environments | `long_query_time` 1 s or less; no full scans (`type=ALL`) on large tables | Review / dashboard | Convention | MySQL slow query log and EXPLAIN |
| Benchmark regression | more than 10-20% slower than baseline, median of several runs | Warn | Convention | No standard; compare with a baseline, not absolute numbers |
| Production latency and availability | SLOs (e.g. 99.9% availability, p99 target) with error-budget burn alerts | Dashboard / alert | Company practice | Google SRE Book and Workbook |

## Delivery metrics (dashboards only, never gates)

DORA's five metrics (deployment frequency, change lead time, failed deployment recovery time, change
fail rate, deployment rework rate) and SPACE survey data show whether the process is working. DORA
itself warns against using them as targets. With AI-written code, DORA 2024 and 2025 found delivery
instability rising, so watch **change fail rate** and **deployment rework rate** in particular.
