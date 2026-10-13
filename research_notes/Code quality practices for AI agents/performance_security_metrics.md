# Proving Software Is Performant, Secure and Delivered Well: Vendor-Neutral Standards, Thresholds and CI Gates (as of Oct 2026)

> **Method note for the report writer:** In this session the sandbox egress proxy blocked direct page fetches (WebFetch and curl) to owasp.org, dora.dev, web.dev, slsa.dev, csrc.nist.gov and docs.sonarsource.com with "connect_rejected". Findings below come from (a) web-search result summaries of those primary pages, labelled **[search-verified]**, or (b) the canonical primary page for well-established facts I could not re-fetch this session, labelled **[canonical, not re-fetched]**. Where secondary sources disagree, that is noted. Treat **[canonical, not re-fetched]** items as high-confidence but worth a spot check before publication.

## Performance: budgets, SLOs, load testing, DB performance, and regression gates

### Takeaway
A web app's performance can be proven with numbers. Use field Core Web Vitals at the 75th percentile (LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1). In CI, enforce those as lab proxies with Lighthouse CI and Angular bundle budgets. For backend latency, set p95/p99 SLOs and enforce them with k6 or Gatling thresholds, which return a non-zero exit code on failure. Watch DB behaviour through query counts, EXPLAIN and slow-query logs. Use the golden signals, RED and USE for production dashboards and alerting rather than for CI.

### Cited Findings

**Core Web Vitals (Google / web.dev; INP replaced FID as a Core Web Vital in March 2024)**
- Thresholds: LCP "good" ≤ 2.5 s, "poor" > 4.0 s; INP "good" ≤ 200 ms, "poor" > 500 ms; CLS "good" ≤ 0.1, "poor" > 0.25 **[search-verified]**. — [web.dev: Defining the Core Web Vitals thresholds](https://web.dev/articles/defining-core-web-vitals-thresholds)
- All three are judged at the **75th percentile** of page loads. A site counts as "good" for a metric if at least 75 % of page views meet the "good" threshold **[search-verified]**. — [web.dev: Defining the Core Web Vitals thresholds](https://web.dev/articles/defining-core-web-vitals-thresholds); [web.dev: Web Vitals](https://web.dev/articles/vitals)
- A perfect Lighthouse score in the lab can still fail CWV in the field (CrUX). Lab budgets are therefore only a proxy for field pass or fail. — [Mintlify / web-quality-skills: CWV thresholds](https://www.mintlify.com/addyosmani/web-quality-skills/concepts/thresholds) (secondary)
- INP cannot be measured in a lab run with no user interaction. Lighthouse uses **Total Blocking Time (TBT)** as the lab proxy for it **[canonical, not re-fetched]**. — [web.dev: INP](https://web.dev/articles/inp); [web.dev: TBT](https://web.dev/articles/tbt)
- Lighthouse CI (`@lhci/cli`): `lhci autorun` with an `assert` block. Assertions are set per audit (`minScore` for category scores, `maxNumericValue` for metrics such as `largest-contentful-paint`, `cumulative-layout-shift`, `total-blocking-time`) at levels `error`, `warn` or `off`. Presets are `lighthouse:recommended` and `lighthouse:no-pwa`. It supports `numberOfRuns` (median of N runs) to reduce noise, and it fails the CI step on `error` assertions **[canonical, not re-fetched]**. — [Lighthouse CI configuration docs](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md)

**Bundle size budgets (Angular CLI)**
- Default `angular.json` budgets for new projects: `initial` warns at **500 kB** and errors at **1 MB**; `anyComponentStyle` warns at **2 kB** and errors at **4 kB**. The official docs example uses a stricter `initial` budget of 250 kB warn / 500 kB error. Budgets can be absolute (bytes, kb, mb) or a percentage against a baseline. A `maximumError` breach fails `ng build` **[search-verified]**. — [Angular build docs (v20)](https://v20.angular.dev/tools/cli/build); [Angular build docs (v19)](https://v19.angular.dev/tools/cli/build)
- Budget types include `bundle`, `initial`, `allScript`, `all`, `anyComponentStyle`, `anyScript` and `any` **[canonical, not re-fetched]**. — [Angular build docs](https://angular.dev/tools/cli/build)

**Backend latency SLOs and the monitoring frameworks behind them**
- **Four golden signals** (Google SRE Book, ch. 6 "Monitoring Distributed Systems", 2016): latency, traffic, errors and saturation. They are symptom-oriented. Latency and error ratio are the most common SLIs. The book stresses separating the latency of successful requests from that of failed ones, and using percentiles or histograms rather than means **[search-verified via secondary; canonical source]**. — [Google SRE Book ch. 6](https://sre.google/sre-book/monitoring-distributed-systems/); [ClickHouse: golden signals](https://clickhouse.com/resources/engineering/golden-signals) (secondary)
- **SLO practice** (SRE Workbook, 2018): define SLIs as the ratio of good events to valid events. Set SLOs such as "99 % of requests < X ms" (p99) and "90 %/95 % < Y ms". Manage risk with an **error budget** (1 − SLO) and burn-rate alerts **[canonical, not re-fetched]**. — [Google SRE Workbook: Implementing SLOs](https://sre.google/workbook/implementing-slos/); [Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- **RED** (Rate, Errors, Duration; Tom Wilkie, Grafana/Weaveworks, 2018) is per-service. **USE** (Utilization, Saturation, Errors; Brendan Gregg) is per-resource (CPU, memory, disk, connection pool). One way to put it: golden signals and RED tell you whether the *service* works, and USE tells you whether its *resources* work. — [SolarWinds THWACK](https://thwack.solarwinds.com/discussion/149927/the-four-golden-signals-for-monitoring-distributed-systems) (secondary); [Dash0: golden signals](https://www.dash0.com/knowledge/what-are-the-four-golden-signals) (secondary); primary sources **[canonical, not re-fetched]**: [Brendan Gregg: The USE Method](https://www.brendangregg.com/usemethod.html), [Grafana: The RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- For Spring Boot: Micrometer and Actuator expose `http.server.requests` timers. Percentile histograms (`management.metrics.distribution.percentiles-histogram.http.server.requests=true`) allow p95/p99 to be computed in Prometheus **[canonical, not re-fetched]**. — [Spring Boot Actuator metrics docs](https://docs.spring.io/spring-boot/reference/actuator/metrics.html)

**Load testing as a CI gate**
- **k6 thresholds** are pass/fail criteria on metrics, for example `http_req_duration: ['p(95)<500']` and `http_req_failed: ['rate<0.01']`. When a threshold fails, k6 exits non-zero, "which is what makes thresholds work in CI/CD pipelines". The documented exit code for failed thresholds is **99**; one secondary page says 1. `abortOnFail: true` (object form) stops the test early, and `delayAbortEval` sets a warm-up period. In k6 Cloud, thresholds are evaluated every 60 s **[search-verified]**. — [Grafana k6 docs: Thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/); [Grafana k6 learning hub: when thresholds fail](https://grafana.com/docs/learning-hub/k6-performance-testing/03-establishing-a-baseline/19b-when-thresholds-fail/); [qaskills k6 abortOnFail reference](https://qaskills.sh/blog/k6-thresholds-abortonfail-delayaborteval-reference) (secondary)
- **Gatling assertions** (for example `global().responseTime().percentile(95).lt(500)`, `global().failedRequests().percent().lt(1.0)`) make the Maven or Gradle plugin fail the build when they are not met **[canonical, not re-fetched]**. — [Gatling docs: Assertions](https://docs.gatling.io/reference/script/core/assertions/)
- **JMeter** has no native pass/fail SLA gate. Pipelines usually add the Maven/Gradle plugin plus a results-analysis step, or BlazeMeter/Taurus `passfail` criteria **[canonical, not re-fetched]**. — [Taurus pass/fail criteria](https://gettaurus.org/docs/PassFail/)

**Database performance (Spring/Hibernate + MySQL)**
- MySQL slow query log: `slow_query_log=ON`, `long_query_time` (default **10 s**; usually lowered to around 0.5–1 s in non-production), and `log_queries_not_using_indexes`. `EXPLAIN` / `EXPLAIN ANALYZE` (MySQL 8.0.18+) shows access type. `type=ALL` means a full table scan **[canonical, not re-fetched]**. — [MySQL 8.4 Ref: The Slow Query Log](https://dev.mysql.com/doc/refman/8.4/en/slow-query-log.html); [MySQL 8.4 Ref: EXPLAIN](https://dev.mysql.com/doc/refman/8.4/en/explain.html)
- Hibernate statistics: `hibernate.generate_statistics=true` exposes query counts, entity fetch counts and second-level-cache hit/miss. Tests can assert the number of SQL statements per use case to catch N+1 regressions. Libraries such as Hypersistence Utils `SQLStatementCountValidator` and datasource-proxy are commonly used for this **[canonical, not re-fetched]**. — [Hibernate ORM User Guide: Statistics](https://docs.jboss.org/hibernate/orm/6.6/userguide/html_single/Hibernate_User_Guide.html#statistics); [Vlad Mihalcea: detect N+1 with datasource-proxy](https://vladmihalcea.com/how-to-detect-the-n-plus-one-query-problem-during-testing/)
- HikariCP (Spring Boot's default pool) pool-sizing guidance: start from `connections = (core_count × 2) + effective_spindle_count`. A small pool with waiting threads outperforms a large one. Default `maximumPoolSize` is 10 **[canonical, not re-fetched]**. — [HikariCP wiki: About Pool Sizing](https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing)

**Microbenchmarks and benchmark noise**
- For Java microbenchmarks, JMH (OpenJDK) handles JIT warm-up, forks and dead-code elimination. Naive timing loops are unreliable **[canonical, not re-fetched]**. — [OpenJDK JMH](https://github.com/openjdk/jmh)

### Inferences
- **Blocking CI gates (cheap and deterministic enough):** Angular `maximumError` budgets; Lighthouse CI on 3–5 runs (median) with `error` on LCP > 2500 ms, CLS > 0.1, TBT > 200–300 ms and performance score < 0.9 (TBT standing in for INP); k6 or Gatling smoke-load thresholds on a fixed-capacity environment, for example `p(95)<500ms`, `p(99)<1000ms`, error rate < 1 %; and N+1 guards (SQL statement-count assertions) in integration tests.
- **Dashboards/alerts, not merge gates:** field CWV from CrUX/RUM, production p95/p99 SLO burn rate, golden signals/RED/USE, slow-query-log trends, and connection-pool saturation. These are noisy, lag behind changes, or only exist in production.
- **Handling noise:** compare against a baseline (relative regression of more than about 10–20 %) rather than absolute numbers for backend benchmarks. Use medians of several runs, dedicated runners and warm-up. Make the gate "warn" first and promote it to "error" once the variance is known. These are common practices; no single standard sets them.

### Gaps
- No vendor-neutral *standard* numeric backend latency SLO exists. Values such as p95 < 500 ms are conventions (k6 docs examples) and should be set per product. I found no authoritative standard for benchmark-noise thresholds in CI.
- I could not re-fetch the Lighthouse CI, Gatling, Hibernate, HikariCP or MySQL docs this session (proxy). Those details come from canonical documentation knowledge.

## Security: standards (OWASP, NIST SSDF, SLSA, CISA) and scanning tools as CI gates

### Takeaway
The current baselines are the OWASP Top 10:2025 (supply chain is now #3), OWASP ASVS 5.0.0 (May 2025) as the verification standard, the OWASP Top 10 for LLM Applications 2025, NIST SSDF SP 800-218 v1.1 plus its generative-AI profile SP 800-218A (July 2024), SLSA v1.1/v1.2 build levels, SBOMs, and the CISA Secure by Design pledge. They map onto an automated chain of SCA, SAST, secrets scanning, DAST and SBOM/provenance.

### Cited Findings

**OWASP Top 10:2025** (final list published by OWASP; Invicti noted in Nov 2025 that it was then a release candidate with only editorial changes pending)
- A01 Broken Access Control (now includes **SSRF**, merged in); A02 Security Misconfiguration (up from #5); **A03 Software Supply Chain Failures** (new/expanded; replaces 2021 A06 Vulnerable and Outdated Components); A04 Cryptographic Failures; A05 Injection; A06 Insecure Design; A07 Authentication Failures; A08 Software or Data Integrity Failures; A09 Security Logging & Alerting Failures; **A10 Mishandling of Exceptional Conditions** (entirely new) **[search-verified]**. — [OWASP Top 10:2025 Introduction](https://owasp.org/Top10/2025/0x00_2025-Introduction/); [Qualys, Jun 2026](https://blog.qualys.com/qualys-insights/2026/06/15/what-changed-in-owasp-top-10-2025-and-recommendations-for-each-category); [Invicti](https://invicti.com/blog/web-security/owasp-top-10)
- For comparison, the 2021 list: A01 Broken Access Control, A02 Cryptographic Failures, A03 Injection, A04 Insecure Design, A05 Security Misconfiguration, A06 Vulnerable & Outdated Components, A07 Identification & Authentication Failures, A08 Software & Data Integrity Failures, A09 Security Logging & Monitoring Failures, A10 SSRF **[canonical, not re-fetched]**. — [OWASP Top 10:2021](https://owasp.org/Top10/2021/)

**OWASP ASVS**
- ASVS **5.0.0 is dated 2025-05-30**. The v4.0.3 L1 was positioned as the "bare minimum". In v5.0, meaningful verification needs access to internal artifacts (black-box testing alone is not enough), and L3 is considerably larger in scope **[search-verified]**. — [SoftwareMill: What's new in ASVS 5.0](https://softwaremill.com/whats-new-in-asvs-5-0/) (secondary); [OWASP ASVS project](https://owasp.org/www-project-application-security-verification-standard/)
- Levels: L1 is the baseline for all apps, L2 is the recommended standard for most apps that handle sensitive data, and L3 is for high-value or critical apps **[canonical, not re-fetched]**. — [OWASP ASVS project](https://owasp.org/www-project-application-security-verification-standard/)

**OWASP Top 10 for LLM Applications 2025** (OWASP GenAI Security Project)
- LLM01 Prompt Injection; LLM02 Sensitive Information Disclosure; LLM03 Supply Chain; LLM04 Data and Model Poisoning; LLM05 Improper Output Handling; LLM06 Excessive Agency; LLM07 System Prompt Leakage (new); LLM08 Vector and Embedding Weaknesses (new); LLM09 Misinformation; LLM10 Unbounded Consumption **[search-verified]**. — [HCL AppScan: OWASP Top 10 for LLM 2025](https://help.hcl-software.com/appscan/Enterprise/10.10.0/topics/r_owasp_top_10_for_llm.html); [OWASP GenAI project](https://genai.owasp.org/llm-top-10/)

**NIST SSDF**
- SP 800-218 **SSDF v1.1** (Feb 2022) groups practices as PO (Prepare the Organization), PS (Protect the Software), PW (Produce Well-Secured Software) and RV (Respond to Vulnerabilities) **[canonical, not re-fetched]**. — [NIST SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final)
- **SP 800-218A**, "Secure Software Development Practices for Generative AI and Dual-Use Foundation Models: An SSDF Community Profile", was finalised in **July 2024** (announced 26 July 2024; draft 29 April 2024). It adds AI-specific practices and tasks to SSDF 1.1 and is meant to be used alongside it **[search-verified]**. — [NIST SP 800-218A final](https://csrc.nist.gov/pubs/sp/800/218/a/final); [NIST news](https://csrc.nist.gov/News/2024/nist-publishes-sp-800-218a)

**SLSA (Supply-chain Levels for Software Artifacts)**
- Build track (the same in v1.0, v1.1 and v1.2):
  - **L1:** provenance exists. It can be unsigned, guards against mistakes and is easy to forge.
  - **L2:** a hosted build platform generates and **signs** provenance, which protects against tampering after the build.
  - **L3:** a hardened build platform, which protects against tampering during the build.
  **[search-verified]** — [SLSA v1.1 Security levels](https://slsa.dev/spec/v1.1/levels); [SLSA v1.2 Build track basics](https://slsa.dev/spec/v1.2/build-track-basics)
- **SLSA v1.2** brings back a **Source track** (L2: history and provenance; L3: continuous enforcement of technical controls). A Level 4 requiring two-party review appears only in third-party summaries and is **unverified**. v1.2 is reportedly backwards compatible with v1.0/v1.1 Build claims. — [SLSA v1.2 spec](https://slsa.dev/spec/v1.2/onepage)
- GitHub Actions can reach Build L3 through `slsa-framework/slsa-github-generator` or GitHub artifact attestations **[canonical, not re-fetched]**. — [slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator)

**SBOM**
- The two standard formats are SPDX (ISO/IEC 5962:2021) and CycloneDX (ECMA-424). NTIA's "Minimum Elements for an SBOM" (July 2021) set the baseline fields **[canonical, not re-fetched]**. — [NTIA Minimum Elements (2021)](https://www.ntia.gov/report/2021/minimum-elements-software-bill-materials-sbom); [CycloneDX](https://cyclonedx.org/specification/overview/); [SPDX](https://spdx.dev/)
- Typical generators: CycloneDX Maven plugin (`cyclonedx-maven-plugin`), `@cyclonedx/cyclonedx-npm`, Syft **[canonical, not re-fetched]**. — [CycloneDX tool center](https://cyclonedx.org/tool-center/)

**CISA Secure by Design (pledge, May 2024)**
- The pledge has seven goals for signatories to show measurable progress on within one year: MFA (phishing-resistant preferred), elimination of default passwords, reduction of entire vulnerability classes (for example SQL injection, XSS, memory safety), increased customer patch uptake, a published vulnerability disclosure policy, CVE transparency (including CWE/CPE fields), and customer ability to collect evidence of intrusions. 68 manufacturers signed at launch **[search-verified]**. — [CISA Secure by Design Pledge PDF](https://www.cisa.gov/sites/default/files/2024-05/CISA%20Secure%20by%20Design%20Pledge_508c.pdf); [Industrial Cyber](https://industrialcyber.co/supply-chain-security/68-software-manufacturers-commit-to-cisas-secure-by-design-pledge-for-enhanced-product-security/)

**Scanning tools (CI-automatable)**
- **SCA / dependencies:** Dependabot (GitHub-native PRs and alerts); OSV-Scanner (Google, queries OSV.dev, lockfile-aware for Maven `pom.xml` and `package-lock.json`, exits non-zero when it finds vulnerabilities); `npm audit --audit-level=high` (non-zero exit at or above the level); OWASP Dependency-Check for Maven (`failBuildOnCVSS`, for example 7) **[canonical, not re-fetched]**. — [OSV-Scanner](https://google.github.io/osv-scanner/); [npm audit docs](https://docs.npmjs.com/cli/commands/npm-audit); [OWASP Dependency-Check Maven](https://jeremylong.github.io/DependencyCheck/dependency-check-maven/configuration.html)
- **SAST:** CodeQL (GitHub code scanning; `security-extended` query suite; Java/Kotlin and JavaScript/TypeScript); Semgrep (OSS rules, `semgrep ci` fails on blocking findings); SpotBugs with the **Find Security Bugs** plugin for Java bytecode (OWASP Top 10 / CWE rules) **[canonical, not re-fetched]**. — [CodeQL docs](https://codeql.github.com/docs/); [Semgrep CI docs](https://semgrep.dev/docs/deployment/core-deployment); [Find Security Bugs](https://find-sec-bugs.github.io/)
- **Secrets:** gitleaks (`gitleaks git` / `gitleaks dir`, exit code 1 on leaks, pre-commit hook plus CI) **[canonical, not re-fetched]**. — [gitleaks](https://github.com/gitleaks/gitleaks)
- **DAST:** OWASP ZAP, now "ZAP by Checkmarx". Its *baseline* scan (passive, about 1 minute of spidering) suits PR gates. *Full* and *API* scans (active) suit nightly runs. Rules can be set to IGNORE, WARN or FAIL in a config file, and the scan exits non-zero on FAIL **[canonical, not re-fetched]**. — [ZAP Baseline Scan](https://www.zaproxy.org/docs/docker/baseline-scan/)
- **Threat modelling:** STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) is a Microsoft-originated technique. The OWASP Threat Modeling Cheat Sheet and the Threat Modeling Manifesto are the vendor-neutral references. Threat modelling is a design-review activity, not a CI gate **[canonical, not re-fetched]**. — [OWASP Threat Modeling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html); [Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/)

### Inferences
- **Blocking gates (recommended):**
  - Secrets: gitleaks, 0 findings.
  - SCA: OSV-Scanner / Dependency-Check / `npm audit --audit-level=high` fail on **new** Critical/High (CVSS ≥ 7.0) with a fix available, with an allow-list that requires expiry and justification.
  - SAST: CodeQL/Semgrep fail on new High/Critical findings (error severity), and SpotBugs+FSB fails on new findings.
  - DAST: ZAP baseline at FAIL level on a deployed ephemeral environment.
  - SBOM: generate one on every release build and fail if generation fails.
  - Provenance: SLSA Build L2+ on the release pipeline.
- **Dashboard / periodic (not per-PR blocking):** full or active ZAP scans (nightly), Medium/Low SCA backlog, ASVS L2 coverage, threat-model currency, CISA pledge goals, and LLM Top 10 red-team results.
- The OWASP 2025 move of supply chain to #3, plus SLSA, SSDF PS/PW and the SBOM practices, all point to the same thing: dependency hygiene and build integrity are now first-class requirements rather than optional extras.
- For AI-generated code, SSDF 800-218A and LLM Top 10 items LLM05 (Improper Output Handling) and LLM06 (Excessive Agency) apply to AI *features*. Scanning AI-*authored* code relies on the same SAST, SCA and secrets gates.

### Gaps
- I could not confirm whether NIST has published an SSDF v1.2 / SP 800-218 Rev. 1 draft as of Oct 2026. The search returned nothing.
- The full SLSA v1.2 Source-track level text and the exact L3 requirement wording were not retrieved.
- I could not confirm whether CISA has revised or replaced the 2024 pledge, or the status of an updated (2025) CISA SBOM minimum-elements document.
- OWASP Top 10:2025: the status of the final versus RC label as of Oct 2026 was not confirmed directly (proxy blocked owasp.org), although the list itself is consistent across sources.

## Delivery and code-health metrics: DORA (2024/2025), SPACE, maintainability, mutation testing, debt

### Takeaway
DORA now tracks five delivery metrics. Throughput covers deployment frequency, change lead time and failed deployment recovery time. Instability covers change fail rate and deployment rework rate. The 2024 report found AI adoption was associated with *lower* throughput (−1.5 %) and stability (−7.2 %). The 2025 report found AI now correlates with *higher* throughput but still with higher instability, with "AI as an amplifier" of existing practices. Code-health gates are best set on *new code*: Sonar way requires coverage ≥ 80 %, duplication ≤ 3 %, no new issues and all hotspots reviewed. Mutation score works best as a ratcheting threshold.

### Cited Findings

**DORA metrics (dora.dev)**
- History: the four original keys were deployment frequency, lead time for changes, MTTR and change fail rate. In **2023**, MTTR was renamed **failed deployment recovery time** to exclude failures not caused by a change (for example a data-centre outage). In **2024**, a fifth metric, **deployment rework rate** (unplanned deployments made to fix user-facing issues ÷ total deployments), was added **[search-verified]**. — [dora.dev: History of DORA's metrics](https://dora.dev/guides/dora-metrics/history/); [Qodo glossary](https://www.qodo.ai/glossary/what-is-dora-metrics/) (secondary)
- Grouping (2024+): **Throughput** = change lead time, deployment frequency and failed deployment recovery time. **Instability** = change fail rate and deployment rework rate. Some secondary sources still list recovery time under "stability", so the classification differs between sources. — [IBM: DORA metrics](https://www.ibm.com/think/topics/dora-metrics); [Octopus: DORA metrics](https://octopus.com/devops/metrics/dora-metrics) (older grouping)
- **DORA 2024 (Accelerate State of DevOps):** AI adoption was associated with an estimated **−1.5 % delivery throughput** and **−7.2 % delivery stability**, while individual flow, productivity and job satisfaction improved. 39 % of respondents had little or no trust in AI-generated code. Nathen Harvey (DORA lead): increased AI adoption "is actually detrimental to their software delivery performance metrics". Another secondary source cites a "14 %" stability figure, which does not match; prefer 7.2 %. Reported sample sizes also vary (about 3,000 per The New Stack; InfoQ cites over 39,000 total across the programme's history) **[search-verified]**. — [InfoQ, Nov 2024](https://www.infoq.com/news/2024/11/2024-dora-report/); [The New Stack](https://thenewstack.io/dora-2024-ai-and-platform-engineering-fall-short/); [RedMonk](https://redmonk.com/rstephens/2024/11/26/dora2024/)
- **DORA 2025: "State of AI-assisted Software Development"** (about 5,000 respondents; with IT Revolution, GitHub, GitLab and others):
  - About **90 %** of respondents use AI at work, and about 30 % don't trust AI-generated code.
  - AI adoption now **positively correlates with throughput** but **still correlates with higher instability** (more change failures and rework). The bottlenecks shift to testing, code review and QA.
  - Teams fall into **seven team profiles/clusters**. Only some, such as "Pragmatic performers" and "Harmonious high-achievers", gain throughput without more instability.
  - The core message is "AI is an amplifier".
  **[search-verified; secondary summaries, primary is Google Cloud]** — [Google Cloud: 2025 DORA report](https://cloud.google.com/resources/content/2025-dora-ai-assisted-software-development-report); [Splunk review](https://www.splunk.com/en_us/blog/learn/state-of-devops.html); [DevOps.com](https://devops.com/dora-2025-faster-but-are-we-any-better/); [Rob Bowley](https://blog.robbowley.net/2025/10/01/dora-2025-ai-assisted-dev-report-some-benefit-most-dont/)
- **DORA AI Capabilities Model (2025):** seven foundational capabilities that amplify AI's benefits, including a clear and communicated AI stance, healthy data ecosystems and a user-centric focus. Other capabilities named in DORA materials are AI-accessible internal data, strong version control, working in small batches and quality internal platforms, but the full list was not confirmed against the report. 90 % of organisations have internal platforms and 76 % have dedicated platform teams. Value Stream Management is recommended. — [Google Cloud: DORA AI Capabilities Model report](https://cloud.google.com/resources/content/2025-dora-ai-capabilities-model-report)

**SPACE framework**
- Forsgren, Storey, Maddila, Zimmermann, Houck and Butler (ACM Queue, 2021): Satisfaction & well-being, Performance, Activity, Communication & collaboration, Efficiency & flow. Measure at least three dimensions and mix perceptual (survey) with system data. Never use a single metric, such as LOC or commit count, to judge productivity **[canonical, not re-fetched]**. — [ACM Queue: The SPACE of Developer Productivity](https://queue.acm.org/detail.cfm?id=3454124)

**SonarQube quality gate: "Sonar way" / Clean as You Code**
- Default, read-only "Sonar way" gate on **new code**: **no new issues**; **all new Security Hotspots reviewed**; **coverage ≥ 80.0 %**; **duplicated lines ≤ 3.0 %**. SonarQube Cloud / older docs express the issue condition as Reliability, Security and Maintainability ratings of A on new code **[search-verified]**. — [SonarQube Server 2025.4: Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/2025.4/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates); [SonarQube Cloud: quality gates](https://docs.sonarsource.com/sonarqube-cloud/standards/managing-quality-gates/introduction-to-quality-gates)
- **"Fudge factor":** coverage and duplication conditions are ignored until new code has at least **20 new lines**. It is on by default and can be overridden by admins **[search-verified]**. — [SonarQube Community Build: quality gates](https://docs.sonarsource.com/sonarqube-community-build/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates)
- Cognitive complexity (Sonar rule S3776, G. Ann Campbell's 2017 white paper) has a default per-method threshold of **15**. Cyclomatic complexity (McCabe, 1976) is commonly flagged above 10 per method **[canonical, not re-fetched]**. — [Sonar rule S3776](https://rules.sonarsource.com/java/RSPEC-3776/); [SonarSource Cognitive Complexity white paper](https://www.sonarsource.com/docs/CognitiveComplexity.pdf)
- Technical debt in Sonar is estimated remediation time. The **technical debt ratio** = remediation cost ÷ (development cost per line × LOC). Maintainability rating A is ≤ 5 %, B 6–10 %, C 11–20 %, D 21–50 % and E > 50 % **[canonical, not re-fetched]**. — [SonarQube metric definitions](https://docs.sonarsource.com/sonarqube-server/latest/user-guide/code-metrics/metrics-definition/)

**Mutation testing**
- **Stryker (JS/TS):** `thresholds: { high, low, break }`. `high`/`low` (defaults **80/60**) only colour the report. **`break`** (default `null`) fails the run when the score drops below it. Community setups often use `break: 50` or 60. Incremental mode (`--incremental`) reduces CI cost **[search-verified for semantics; defaults canonical]**. — [Stryker blog (thresholds.break)](https://stryker-mutator.io/blog/stryker-0-8-0/); [Stryker config docs](https://stryker-mutator.io/docs/stryker-js/configuration/); [OneUptime guide](https://oneuptime.com/blog/post/2026-01-25-mutation-testing-with-stryker/view) (secondary)
- **PIT (Java):** `mutationThreshold` and `coverageThreshold` (default 0, meaning not enforced) fail the Maven/Gradle build when not met. Use `withHistory` / incremental analysis and `scmMutationCoverage` (changed code only) for PRs. The Arcmutate plugin adds Git-diff-scoped PR analysis **[canonical, not re-fetched]**. — [PIT Maven quickstart](https://pitest.org/quickstart/maven/); [PIT incremental analysis](https://pitest.org/quickstart/incremental_analysis/)

### Inferences
- **Blocking gates:** the Sonar way gate (or equivalent) on new code (coverage ≥ 80 %, duplication ≤ 3 %, 0 new Blocker/High issues, 100 % hotspots reviewed); cognitive complexity ≤ 15 per method as a new-code rule; and mutation score on changed code (Stryker `break` / PIT `mutationThreshold`) around **60–70 % to start, ratcheting upward**. Run full-project mutation testing nightly because it is expensive.
- **Dashboards only (never per-PR gates):** the DORA five metrics, SPACE survey data, technical debt ratio trend and overall coverage. DORA itself warns against using these as targets or for comparing teams. Gating on them would invite gaming (Goodhart's law).
- DORA 2025 bears directly on AI coding agents. AI raises throughput, but instability rises unless review, testing and small-batch practices keep pace. That argues for strict automated gates on AI-authored changes, mutation testing to check that AI-written tests actually assert behaviour, and tracking rework rate as the AI-specific health signal.
- Commonly cited DORA "elite" benchmarks are on-demand deployment, lead time < 1 day, CFR around 5 % or lower and recovery < 1 hour. These come from 2023/2024 cluster analyses and shift every year, so present them as reference points, not standards.

### Gaps
- I could not access the primary 2024 and 2025 DORA report PDFs. The figures come from secondary coverage. Exact 2025 cluster names and percentages (other than the two named), and the full list of seven AI capabilities, are unconfirmed.
- No DORA 2026 report findings were found. A 2026 report may not have been published yet, or the search did not surface it.
- The current Sonar "AI Code Assurance" quality-gate thresholds for AI-generated code were not retrieved.
- The PIT and Stryker default values could not be re-fetched from the official docs this session.

## Which items should be blocking CI gates vs dashboards, with recommended thresholds

### Takeaway
Block merges only on deterministic, change-scoped and cheap checks: new-code quality, security findings, budgets and smoke-load thresholds. Track outcome and trend metrics on dashboards with alerting: DORA/SPACE, field CWV, production SLOs and full scans. All thresholds below come from the cited standards and tool defaults above. Where a number is a convention rather than a standard, it says so.

### Cited Findings
| Area | Check / tool | Recommended threshold | Gate type | Basis |
|---|---|---|---|---|
| Frontend perf | Angular budgets | initial warn 500 kB / error 1 MB (default; tighten to 250/500 kB); anyComponentStyle 2/4 kB | Block | [Angular build docs](https://v20.angular.dev/tools/cli/build) |
| Frontend perf | Lighthouse CI (median of 3–5 runs) | LCP ≤ 2500 ms, CLS ≤ 0.1, TBT ≤ 200 ms (INP proxy), perf score ≥ 0.9 | Block (error) after a warn period | [web.dev CWV thresholds](https://web.dev/articles/defining-core-web-vitals-thresholds); [LHCI config](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md) |
| Frontend perf | Field CWV (CrUX/RUM) | p75 LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1 | Dashboard/alert | [web.dev](https://web.dev/articles/defining-core-web-vitals-thresholds) |
| Backend perf | k6 / Gatling smoke-load | p95 < 500 ms, p99 < 1000 ms, error rate < 1 % (convention, set per SLO) | Block (pre-release / nightly) | [k6 thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/) |
| Backend perf | Production SLOs, golden signals / RED / USE | SLO e.g. 99.9 % availability, p99 latency target; burn-rate alerts | Dashboard/alert | [SRE Book ch. 6](https://sre.google/sre-book/monitoring-distributed-systems/); [SRE Workbook](https://sre.google/workbook/implementing-slos/) |
| DB perf | SQL statement-count assertions (N+1) | Exact expected count per use case | Block | [Hibernate statistics](https://docs.jboss.org/hibernate/orm/6.6/userguide/html_single/Hibernate_User_Guide.html#statistics) |
| DB perf | Slow query log / EXPLAIN review | `long_query_time` ≤ 1 s in test env; no `type=ALL` on large tables | Dashboard + review | [MySQL slow log](https://dev.mysql.com/doc/refman/8.4/en/slow-query-log.html) |
| Security | gitleaks | 0 secrets | Block | [gitleaks](https://github.com/gitleaks/gitleaks) |
| Security | OSV-Scanner / Dependency-Check / npm audit | 0 new Critical/High (CVSS ≥ 7) with a fix available | Block | [OSV-Scanner](https://google.github.io/osv-scanner/); [npm audit](https://docs.npmjs.com/cli/commands/npm-audit) |
| Security | CodeQL / Semgrep / SpotBugs+FSB | 0 new High/Critical | Block | [CodeQL](https://codeql.github.com/docs/); [Find Security Bugs](https://find-sec-bugs.github.io/) |
| Security | ZAP baseline | 0 FAIL-level alerts | Block (on ephemeral env) | [ZAP baseline](https://www.zaproxy.org/docs/docker/baseline-scan/) |
| Security | ZAP full/API scan, ASVS L2 coverage, threat model | — | Nightly / dashboard / design review | [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/) |
| Supply chain | SBOM (CycloneDX/SPDX) + SLSA provenance | SBOM on every release; Build L2+ (L3 target) | Block on release pipeline | [SLSA v1.1 levels](https://slsa.dev/spec/v1.1/levels) |
| Code health | Sonar way (new code) | coverage ≥ 80 %, duplication ≤ 3 %, 0 new issues, 100 % hotspots reviewed (≥ 20 new lines) | Block | [Sonar quality gates](https://docs.sonarsource.com/sonarqube-server/2025.4/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates) |
| Code health | Cognitive complexity | ≤ 15 per method | Block (new code) | [Sonar S3776](https://rules.sonarsource.com/java/RSPEC-3776/) |
| Test quality | PIT / Stryker on changed code | mutation score ≥ 60–70 % (convention), ratchet up | Block (incremental), full run nightly | [PIT](https://pitest.org/quickstart/maven/); [Stryker](https://stryker-mutator.io/docs/stryker-js/configuration/) |
| Delivery | DORA five metrics, SPACE | Trend, not target | Dashboard only | [dora.dev](https://dora.dev/guides/dora-metrics/history/); [ACM Queue SPACE](https://queue.acm.org/detail.cfm?id=3454124) |

### Inferences
- Make every blocking gate **new-code / diff-scoped** (Clean as You Code). This keeps legacy debt from blocking all work and gives AI agents a clear, local pass/fail signal.
- Roll out each new gate in **warn mode first**, then switch to error once the false-positive rate and noise are measured. This applies especially to Lighthouse and load tests.
- Any suppression should need a recorded justification and an expiry date: allow-listed CVEs, `// NOSONAR`, or ZAP IGNORE rules.
- For AI-assisted teams, DORA 2025's finding that AI raises instability suggests treating **deployment rework rate** and **change fail rate** as the key dashboard signals for whether the gates are working.

### Gaps
- No single vendor-neutral standard prescribes the numeric CI thresholds for backend latency, mutation score or SCA severity cut-offs. The table's numbers are tool defaults or widely used conventions, labelled as such.
