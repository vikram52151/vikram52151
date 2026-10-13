# Google's Practices for Code Quality, Correctness and Maintainability at Scale

> Research notes, compiled 2026-10-13. Method note: outbound fetching of google.github.io, abseil.io, sre.google, testing.googleblog.com, research.google, arxiv.org and acm.org was blocked by the sandbox's egress proxy. Primary text was obtained directly in two ways: (1) the `google/eng-practices` GitHub repo, which is the source of google.github.io/eng-practices (cloned and read verbatim), and (2) the `abseil/abseil.github.io` GitHub repo, which holds the full HTML of *Software Engineering at Google* (SWE book, O'Reilly 2020, served at abseil.io/resources/swe-book). Everything else comes from web-search result snippets, which are marked as such. Claims I could not verify in this session are under **Gaps**. The SWE book was published in 2020 and describes practice from about 2014 to 2019. Treat its numbers as dated.

## 1. Code review: what Google's eng-practices say, and what the 2018 case study measured

### Takeaway
Google's single senior rule for review is to approve a CL once it *definitely improves overall code health*, even if it isn't perfect. Reviewers check design, functionality, complexity (especially over-engineering), tests, naming, comments, style, consistency and docs, and they read every line. Changes are small (median 24 lines changed), usually have one approver, and reviews are fast: one business day is the maximum time to respond, and median end-to-end review latency was under 4 hours in 2014–2016.

### Cited Findings
**The standard (eng-practices, "The Standard of Code Review")**
- "The primary purpose of code review is to make sure that the overall code health of Google's code base is improving over time." — [eng-practices: standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)
- Senior principle: "**In general, reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system being worked on, even if the CL isn't perfect.**" A reviewer may still reject a well-written CL for a feature they don't want in their system. — [standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)
- "There is no such thing as 'perfect' code—there is only _better_ code." Reviewers should seek "continuous improvement" rather than perfection. Non-critical polish or purely educational comments get the prefix "Nit:". "Nothing in this document justifies checking in CLs that definitely _worsen_ the overall code health," except in emergencies. — [standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)
- Principles: "Technical facts and data overrule opinions and personal preferences." The style guide is "the absolute authority" on style, and a style point not in the guide is personal preference. Design is "almost never a pure style issue". If the author shows that several approaches are equally valid, the reviewer accepts the author's choice. Otherwise the reviewer may ask for consistency with the existing codebase, as long as that doesn't worsen code health. — [standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)
- Conflicts: first seek consensus based on the guides, then a face-to-face or video meeting, and record the outcome as a comment on the CL. — [standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)

**What reviewers look for ("What to look for in a code review")**
- Summary checklist, verbatim: the code is well-designed; the functionality is good for the users of the code; UI changes are sensible; "any parallel programming is done safely"; "the code isn't more complex than it needs to be"; the developer isn't implementing things they *might* need in the future; there are appropriate unit tests; the tests are well-designed; names are clear; comments are "clear and useful, and mostly explain *why* instead of *what*"; code is documented (generally in g3doc); the code conforms to the style guides. Reviewers should read "**every line**", look at the **context**, make sure they're **improving code health**, and compliment **good things**. — [eng-practices: looking-for.md](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- Complexity: "Too complex" usually means "can't be understood quickly by code readers" or "developers are likely to introduce bugs when they try to call or modify this code." Reviewers should be "especially vigilant about over-engineering" and should encourage solving "the problem they know needs to be solved *now*, not the problem that the developer speculates *might* need to be solved in the future." — [looking-for.md](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- Tests: tests should be added "in the same CL as the production code unless the CL is handling an emergency". Reviewers ask: "Will the tests actually fail when the code is broken? If the code changes beneath them, will they start producing false positives? Does each test make simple and useful assertions?" "Tests do not test themselves… a human must ensure that tests are valid." "Don't accept complexity in tests just because they aren't part of the main binary." — [looking-for.md](https://google.github.io/eng-practices/review/reviewer/looking-for.html)

**Small CLs ("Small CLs")**
- The right size is "**one self-contained change**". "100 lines is usually a reasonable size for a CL, and 1000 lines is usually too large", and file spread counts too: "A 200-line change in one file might be okay, but spread across 50 files it would usually be too large." "When in doubt, write CLs that are smaller than you think you need to write. Reviewers rarely complain about getting CLs that are too small." — [eng-practices: small-cls.md](https://google.github.io/eng-practices/review/developer/small-cls.html)
- Refactorings go in a separate CL from feature or behavior changes, though small cleanups such as renaming a local variable are fine inline. Related test code belongs in the same CL. "Tests are expected for all Google changes." Pure refactorings should also be covered by tests, ideally existing ones. Reviewers may reject a CL "for the sole reason of it being too large." Large CLs generated by automated refactoring tools are an accepted exception. — [small-cls.md](https://google.github.io/eng-practices/review/developer/small-cls.html)

**Speed ("Speed of Code Reviews")**
- "At Google, we optimize for the speed at which a team of developers can produce a product together", not for individual speed. "**One business day is the maximum time it should take to respond** to a code review request (i.e., first thing the next morning)." "A typical CL should get multiple rounds of review (if needed) within a single day." — [eng-practices: speed.md](https://google.github.io/eng-practices/review/reviewer/speed.html)
- Don't interrupt focused coding to review; respond at the next break point. What matters is *response* time, and "Most complaints about the code review process are actually resolved by making the process faster." — [speed.md](https://google.github.io/eng-practices/review/reviewer/speed.html)
- "LGTM with comments" is appropriate when the reviewer trusts the author to address the comments, when the comments are optional, or when they are minor (sort imports, fix a typo, apply a suggested fix, remove an unused dep). For a CL that is too large, ask for it to be split, or at least comment on the overall design. "Don't compromise on the code review standards… for an imagined improvement in velocity." — [speed.md](https://google.github.io/eng-practices/review/reviewer/speed.html)

**Modern Code Review: A Case Study at Google (Sadowski et al., ICSE-SEIP 2018; data from Jan 2014 to Jul 2016)** (from search snippets; PDF not opened)
- Dataset: about 9M changes, about 13M comments, more than 25k developers, January 2014 to July 2016. — [ACM PDF](https://dl.acm.org/doi/pdf/10.1145/3183519.3183525) (via search snippet)
- Median change modified **24 lines**. More than 35% of changes touched a single file, and about 90% touched fewer than 10 files. — [ACM PDF](https://dl.acm.org/doi/pdf/10.1145/3183519.3183525) (search snippet)
- Median of **1 approver**. Fewer than 25% of changes have more than one. — [ACM PDF](https://dl.acm.org/doi/pdf/10.1145/3183519.3183525) (search snippet)
- Median time to first feedback is **under 1 hour** for small changes and about **5 hours** for very large ones. Median overall review latency, across all sizes, is **under 4 hours**. — [ACM PDF](https://dl.acm.org/doi/pdf/10.1145/3183519.3183525) (search snippet)
- The median developer authors about 3 changes a week (80% author fewer than 7) and reviews about 4 a week. — [ACM PDF](https://dl.acm.org/doi/pdf/10.1145/3183519.3183525) (search snippet)
- A Hacker News commenter who said they had worked at Google questioned the latency numbers from personal experience (3–4 hours for small CLs, 1–2 days for larger ones). This is anecdotal. — [HN thread](https://news.ycombinator.com/item?id=26649784)

**Review mechanics (SWE book, ch. 9 "Code Review")**
- A change needs an LGTM from another engineer, which acts as the "permissions bit". "Only one LGTM is required by default." It also needs OWNERS approval for the directory and **readability** approval for the language. One person can play all three roles, and an author who is an owner with readability needs only one LGTM from another engineer. — [SWE book ch. 9](https://abseil.io/resources/swe-book/html/ch09.html)

### Inferences
- For an AI agent, the most transferable rules are: one self-contained change of about 100 lines (never more than about 1,000) per CL; tests in the same CL; refactors separate from behavior changes; "Nit:" to mark optional comments; reject speculative generality; and the rule "approve if it definitely improves code health, never if it worsens it".
- One approver is the norm at Google because readability and OWNERS checks are layered on top. A small team that lacks those layers may want more reviewers, or automated checks, to make up the difference.

### Gaps
- I couldn't open the 2018 paper's full text, so its hours-per-week reviewing figure and its motivations breakdown (education, maintaining norms, gatekeeping, accident prevention) are unverified here. I also couldn't verify the widely quoted figure of 97% developer satisfaction with Critique, which I saw only in a secondary newsletter.

## 2. Readability certification, OWNERS and style guides

### Takeaway
Three approvals gate every change: an LGTM, an owner, and readability. Readability is a company-wide mentoring program in which about 20% of engineers take part at any time and about 1–2% are readability reviewers. Style guides are the authority on style and are built on principles such as "optimize for the reader", "be consistent" and "rules must pull their weight", and they are enforced mainly by formatters, linters and analyzers.

### Cited Findings
- Readability approval comes "from someone with language 'readability'… that the code conforms to the language's style and best practices". It can be implicit if the author holds readability. — [SWE book ch. 9](https://abseil.io/resources/swe-book/html/ch09.html)
- OWNERS: "Google's codebase is a tree structure with hierarchical owners of particular directories… Owners act as gatekeepers for their particular directories." Anyone can propose a change and anyone can LGTM it, "but an owner of the directory in question must also approve". — [SWE book ch. 9](https://abseil.io/resources/swe-book/html/ch09.html)
- Readability is "a standardized, Google-wide mentorship process for disseminating programming language best practices", covering "language idioms, code structure, API design, appropriate use of common libraries, documentation, and test coverage." — [SWE book ch. 3](https://abseil.io/resources/swe-book/html/ch03.html)
- "Around 20% of Google engineers are participating in the readability process at any given time." "Around 1 to 2% of Google engineers are readability reviewers. All reviewers are volunteers", and they are expected to have an "aptitude for teaching through code review." — [SWE book ch. 3](https://abseil.io/resources/swe-book/html/ch03.html)
- Style guide principles listed in ch. 8: "Rules must pull their weight", "Optimize for the reader", "Be consistent" (among others). — [SWE book ch. 8](https://abseil.io/resources/swe-book/html/ch08.html)
- eng-practices makes the public style guide (google.github.io/styleguide) the "absolute authority" on style in review. — [standard.md](https://google.github.io/eng-practices/review/reviewer/standard.html)
- OWNERS files also drive automated reviewer selection for large-scale changes. Rosie uses an "owners detection service" that weights owners by their expected ability to review, and adds reviewers when an owner is unresponsive. — [SWE book ch. 22](https://abseil.io/resources/swe-book/html/ch22.html)

### Inferences
- An agent-oriented equivalent would be an OWNERS or CODEOWNERS file per directory, a written style guide whose rules each justify their cost, and auto-formatters and linters so that review time isn't spent on style.

### Gaps
- I didn't retrieve how long readability certification takes or how many CLs it requires. The SWE book's ch. 3 readability case study has data on this, but I didn't extract it. I also couldn't confirm the exact enforcement mechanisms (formatters per language) from a primary source in this session.

## 3. Testing: sizes, mix, Beyoncé rule, coverage, mutation testing, flakiness, TAP, hermeticity

### Takeaway
Google classifies tests by **size**, meaning the resources a test may use, and enforces it in infrastructure: small tests run in one process with no network, disk or sleep; medium tests run on one machine with localhost only; large tests can run anywhere. It aims for about **80/15/5** unit/integration/E2E tests (the SWE book's figure; "70/20/10" is the 2015 blog-era heuristic). Coverage guidance is **60% acceptable, 75% commendable, 90% exemplary**, with no mandate. Mutation testing is surfaced in code review. About **1.5% of test runs** are flaky and about **16% of tests** have some flakiness (2016). TAP runs presubmit fast tests and asynchronous postsubmit, with a Build Cop who prefers rollbacks.

### Cited Findings
**Sizes and mix**
- "Small tests run in a single process, medium tests run on a single machine, and large tests run wherever they want." Some of these limits are "encoded as constraints the testing infrastructure can enforce". Google prefers sizes over "unit/integration" because "the most important qualities we want from our test suite are speed and determinism." — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- Small tests may not "sleep, perform I/O operations, or make any other blocking calls… aren't allowed to access the network or disk", so they use test doubles. Hermetic in-memory filesystems are an allowed exception. Medium tests can span processes and use threads, but can make network calls only to localhost. — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- "Our large tests have a default timeout of 15 minutes or 1 hour," and some run for hours or days. Google also has an "enormous" size class. — [SWE book ch. 14](https://abseil.io/resources/swe-book/html/ch14.html), [ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- Scope mix: "we tend to aim to have a mix of around **80%** of our tests being narrow-scoped unit tests…; **15%** medium-scoped integration tests…; and **5%** end-to-end tests." — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- "70/20/10": the Google Testing Blog post "Just Say No to More End-to-End Tests" (Mike Wacker, 22 April 2015) argues for a pyramid and, per a reader comment, says "the exact mix will be different for each team". I could not confirm the 70/20/10 wording itself from the post text, and one conference article attributes 70/20/10 to the pyramid model in general. — [Testing Blog 2015](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html); [EuroSTAR](https://conference.eurostarsoftwaretesting.com/?p=36478)
- Case study: before Google invested in testing, one team (GWS, in the book) reached a point where "more than 80% of production pushes contained user-affecting bugs that had to be rolled back." — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)

**Beyoncé Rule and culture**
- "If you liked it, then you shoulda put a test on it." If an unrelated infrastructure change passes your tests but breaks your product, "you are on the hook for fixing it and adding the additional tests." — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- Three initiatives built the testing culture: Orientation Classes, the **Test Certified** program and **Testing on the Toilet**. — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)

**Coverage**
- "No ideal code coverage number" exists. As general guidelines, "60% as 'acceptable', 75% as 'commendable' and 90% as 'exemplary'." Google avoids top-down mandates. Teams should focus on getting from 30% to 70% and "always making sure new code meets our desired threshold"; returns flatten beyond a point. (Arguelles, Ivanković, Bender, August 2020.) — [Testing Blog: Code Coverage Best Practices](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html) (via search snippet)
- The SWE book warns that a coverage bar such as 80% turns from a floor into a ceiling: "engineers treat it like a ceiling." — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- "Code Coverage at Google" (Ivanković, Petrović, Just, Fraser; ESEC/FSE 2019) covers 5 years of data and surveyed 3,000 developers (512 responses). Per IEEE Spectrum, 45% use coverage frequently when authoring changes and 40% when reviewing. — [research.google](https://research.google/pubs/code-coverage-at-google/); [IEEE Spectrum](https://spectrum.ieee.org/qa-how-google-implements-code-coverage-at-massive-scale)
- Older data (2014): median project coverage was 78%, the 75th percentile 85%, the 90th percentile 90%. — [Testing Blog 2014](https://testing.googleblog.com/2014/07/measuring-coverage-at-google.html) (search snippet)

**Mutation testing**
- "State of Mutation Testing at Google" (Petrović and Ivanković, ICSE-SEIP 2018): diff-based, with **at most one mutant per covered line**, surfaced in code review. About 6,000 engineers used it, there were about 150,000 actionable findings across more than 70,000 diffs, and the evaluation covered 1.1M mutants. Through the feedback loop, reported usefulness rose from **20% to 80%**. Mutants a developer judges irrelevant are ignored rather than counted against the suite. — [research.google PDF 46584](https://research.google.com/pubs/archive/46584.pdf) (search snippet)
- "Practical Mutation Testing at Scale: A view from Google" (Petrović, Ivanković, Fraser, Just; IEEE TSE, 2021). — [arXiv 2102.11378](https://arxiv.org/pdf/2102.11378)
- A reviewer can click "Please fix" on a surviving mutant, which posts a review comment asking the author to add a test. — [MuRS, arXiv 2306.09130](https://arxiv.org/html/2306.09130) (search snippet)

**Flakiness**
- "About **1.5%** of all test runs reporting a 'flaky' result" (pass and fail on the same code). "Almost **16%** of our tests have some level of flakiness." (John Micco, Google Testing Blog, May 2016; dated.) — [Testing Blog, May 2016](https://testing.googleblog.com/2016/05/) (search snippet)
- Arithmetic from the SWE book: with a 0.1% flake rate per test and 10,000 test runs per day, you investigate 10 flakes a day. — [SWE book ch. 11](https://abseil.io/resources/swe-book/html/ch11.html)
- A claim that "84% of pass-to-fail transitions are flaky" circulates, but I found it only in secondary sources, so it is unverified.

**TAP, presubmit and postsubmit, hermetic tests (SWE book ch. 23, about 2020)**
- TAP handles "more than 50,000 unique changes and running more than four billion individual test cases" every day. — [SWE book ch. 23](https://abseil.io/resources/swe-book/html/ch23.html)
- Each team defines a **fast presubmit subset**, usually unit tests run before review. "A change that passes the presubmit has a very high likelihood (**95%+**) of passing the rest of the tests." After submission, TAP runs all affected tests, including large ones, asynchronously. The average wait to submit is **about 11 minutes**. — [SWE book ch. 23](https://abseil.io/resources/swe-book/html/ch23.html)
- Norm: don't commit on top of known-failing tests. Each team has a **Build Cop** who "drop[s] whatever they are doing and fix[es] the build", and **rollback is "the preferred solution"** over a forward fix. TAP batches changes, so it auto-splits failing batches and offers binary-search culprit finding. — [SWE book ch. 23](https://abseil.io/resources/swe-book/html/ch23.html)
- "Most teams at Google run their small tests (like unit tests) on presubmit." For larger presubmit tests, "hermetic testing is a proven approach to reducing their inherent instability". The alternative is to let them be unreliable and "disable them aggressively when they start failing." — [SWE book ch. 23](https://abseil.io/resources/swe-book/html/ch23.html)

### Inferences
- For an agent workflow, the main lessons are to enforce size limits mechanically (no network, sleep or real disk in unit tests), run a fast deterministic presubmit before asking for review, prefer rollback to fix-forward, and use mutation testing on changed lines as a check on test quality rather than chasing coverage numbers.

### Gaps
- I didn't retrieve the exact per-size timeout table from ch. 11 or the Test Certified levels (Levels 1–5 and their criteria). Neither appeared in the text I extracted, so they are unverified here.

## 4. Static analysis: Tricorder, Error Prone, ClangTidy, and the CACM 2018 lessons

### Takeaway
Google shows analyzer results **inside code review**, in Critique via Tricorder, and requires every check to be understandable, actionable, high-impact and below **10% effective false positives**. An "effective false positive" is any finding developers took no positive action on. A "Not useful" button feeds results back to analyzer authors. The most serious, unambiguous checks are compile errors in Error Prone (Java) and clang-tidy (C++).

### Cited Findings
- Tricorder criteria, verbatim from SWE book ch. 20: "Be understandable"; "Be actionable and easy to fix… the result should include guidance as to how the issue might indeed be fixed"; "**Produce less than 10% effective false positives** — Developers should feel the check is pointing out an actual issue at least 90% of the time"; "Have the potential for significant impact on code quality." — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html)
- Effective false positive: an issue counts as one "if developers did not take some positive action after seeing the issue". A technically wrong finding that developers fix anyway does not count. A real bug that developers ignore because they didn't understand it does count. — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html)
- Tricorder "came out of several failed attempts", and its key difference was "relentless focus on having Tricorder deliver only valuable results". Its warnings appear in Critique's diff view as gray comments, and it uses a microservices design. — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html)
- Feedback loop: a "Not useful" button lets developers file a bug against the analyzer author. Before clear feedback channels existed, "many developers would just ignore analysis results they did not understand." Rewording an Error Prone message alone stopped a weekly flow of "Not useful" reports. — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html)
- Google removed per-user settings for confidence level and suppression from Critique. The old per-user customization was a cause of failure; for example, the FindBugs integration was abandoned because of false positives and per-user warning settings. — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html); [paper review summary](https://medium.com/sourcedtech/paper-review-lessons-from-building-static-analysis-tools-at-google-cc71a43bdee)
- "Error Prone and clang-tidy extend the compiler to identify AST antipatterns for Java and C++." Example: a hash of a `long` field in which a right shift by 32 is a no-op, so the field is XORed with itself; Google fixed 31 occurrences of this bug in its codebase when it enabled the check as a compiler error. — [SWE book ch. 20](https://abseil.io/resources/swe-book/html/ch20.html)
- "Lessons from Building Static Analysis Tools at Google" (Sadowski, Aftandilian, Eagle, Miller-Cushon, Jaspan; CACM April 2018): developers must feel they benefit from the tool; developers, not tool authors, decide the perceived false-positive rate; as of January 2018 Tricorder analyzed about 50,000 code review changes per day; Google chose correctness checks over style or best-practice checks for the most aggressive surfacing. — [CACM](https://cacm.acm.org/research/lessons-from-building-static-analysis-tools-at-google/); [review summary](https://medium.com/sourcedtech/paper-review-lessons-from-building-static-analysis-tools-at-google-cc71a43bdee) (search snippets)
- Tricorder paper: "Tricorder: Building a Program Analysis Ecosystem" (Sadowski et al., ICSE 2015). — [research.google PDF 43322](https://research.google.com/pubs/archive/43322.pdf)

### Inferences
- An agent's lints and checks should run at review or PR time, carry a suggested fix, be removed or tuned if fewer than about 90% of findings get acted on, and offer no per-developer suppression knobs.

### Gaps
- I didn't verify the ICSE 2015 Tricorder paper's exact operational rule (analyzers whose "Not useful" rate exceeds 10% are put on probation or disabled). That figure comes from memory, so I left it out of the findings above.

## 5. Code health: LSCs and Rosie, deprecation, and the SWE book's core principles

### Takeaway
The SWE book defines software engineering as "programming integrated over time". **Hyrum's Law** makes every observable behavior a de facto contract, which is why the Beyoncé rule, centralized large-scale changes (Rosie), and *compulsory* rather than merely advisory deprecation are needed. "Shifting left", meaning catching issues earlier in the pipeline, ties together the tooling.

### Cited Findings
- "Within Google, we sometimes say, 'Software engineering is programming integrated over time.'" — [SWE book ch. 1](https://abseil.io/resources/swe-book/html/ch01.html)
- Hyrum's Law: "With a sufficient number of users of an API, it does not matter what you promise in the contract: all observable behaviors of your system will be depended on by somebody." — [SWE book ch. 1](https://abseil.io/resources/swe-book/html/ch01.html)
- "Shifting Left" is a named section of ch. 1: finding problems earlier in the developer workflow (static analysis, code review and tests before commit) makes them cheaper. — [SWE book ch. 1](https://abseil.io/resources/swe-book/html/ch01.html)
- As a codebase grows, "the largest atomic change possible counterintuitively decreases." Rosie "takes a large change and shards it based upon project boundaries and ownership rules into changes that can be submitted atomically", and runs each shard through "an independent test-mail-submit pipeline". In the largest cases Google has "touched millions of references." Centralizing migrations with infrastructure teams is preferred because consuming teams lack context. — [SWE book ch. 22](https://abseil.io/resources/swe-book/html/ch22.html)
- Deprecation is either **advisory** or **compulsory**. "Deprecation warnings can help prevent new uses, but rarely lead to migration of existing systems"; "hope is not a strategy." Advisory deprecation "rarely leads to teams actively migrating." — [SWE book ch. 15](https://abseil.io/resources/swe-book/html/ch15.html)

### Inferences
- For agents: treat any observable behavior change as potentially breaking (Hyrum's Law), do migrations in owner-scoped shards with each shard tested independently, and pair any deprecation with an owned migration plan.

### Gaps
- I didn't extract specific technical-debt metrics or Google's "code health" group practices beyond these points.

## 6. Production readiness: SRE practices (SLOs, error budgets, launch checklists, PRR, canarying, postmortems)

### Takeaway
SRE practice ties release velocity to **SLOs and error budgets**. In the published example policy, exceeding the budget over a 4-week window freezes all changes except P0 and security fixes until the service is back within its SLO. Further controls are staged and canary rollouts, launch checklists, production readiness reviews before SRE takes on a service, and blameless postmortems.

### Cited Findings
- Example Error Budget Policy (SRE Workbook, Appendix B): when a service is at or above its SLO, releases proceed normally. If it has exceeded its error budget over the preceding four-week window, all changes and releases other than P0 issues or security fixes halt until the service is back within its SLO. The team must prioritize reliability work if a code bug or procedural error caused the miss, but not for causes such as a company-wide networking outage. — [sre.google workbook: error-budget-policy](https://sre.google/workbook/error-budget-policy/) (search snippet)
- A Google CRE case study shows the freeze can be applied with nuance: their policy leaned toward velocity and paused releases only when a root cause stayed unknown. — [Google Cloud blog: applying the escalation policy](https://cloud.google.com/blog/products/gcp/applying-the-escalation-policy-cre-life-lessons/) (search snippet)
- The SRE Workbook includes chapters titled "Canarying Releases" (ch. 16) and "Postmortem Culture: Learning from Failure" (ch. 10). — [SRE Workbook TOC](https://sre.google/workbook/table-of-contents/)
- "100% is the wrong reliability target for basically everything" (SRE book summary); error budgets let phased rollouts and 1% experiments proceed within tolerable error levels. — [danluu summary of SRE book](https://danluu.com/google-sre-book/) (secondary)

### Inferences
- An agent-run project can adopt one SLO per user-facing path, a written error-budget policy that freezes feature merges when the budget is exhausted, a canary or staged deploy step, and a blameless postmortem template.

### Gaps
- sre.google was unreachable, so I couldn't verify the text of the launch checklist (SRE book ch. 27, "Reliable Product Launches at Scale"), the PRR process (ch. 32, "The Evolving SRE Engagement Model"), or the specific canary percentages and durations. The report writer should cite these chapters only with care.

## 7. ML and AI in code review and code authoring at Google

### Takeaway
Google uses ML to resolve review comments: by 2023–24, **7.5% of all reviewer comments** were addressed by applying an ML-suggested edit. It uses AutoCommenter to flag violations of best practices, and LLMs for large migrations: in 2025 they generated about 74% of migration code changes with an estimated 50% time saving. Pichai said in April 2026 that **75% of new code at Google is AI-generated**, up from about 50% in fall 2025 and more than 25% in October 2024, and that every line is "reviewed and approved by engineers".

### Cited Findings
- ML-resolved review comments: Google Research blog "Resolving code review comments with ML" (May 2023), plus the ICSE-SEIP 2024 paper. In deployment, authors address **7.5% of all reviewer comments** by applying an ML-suggested edit; a secondary source puts v1 at about 5%. (Exact UI flow not verified in this session; per the blog title and summary, the author chooses whether to apply a suggested edit, so humans stay in the loop.) — [Google Research blog](https://research.google/blog/resolving-code-review-comments-with-ml/); [paper](https://research.google/pubs/resolving-code-review-comments-with-machine-learning/); [co-author on X](https://x.com/jacobaustin132/status/1748863834423468469)
- AutoCommenter (AIware 2024): an LLM predicts the location of a best-practice violation and links the relevant guideline URL. It runs in the IDE and in code review, posts comments on new review snapshots, and was rolled out in stages (team, early adopters, A/B test, GA) for C++, Java, Python and Go. — [arXiv 2405.13565](https://arxiv.org/pdf/2405.13565) (search snippet)
- LLM code migrations: "Migrating Code At Scale With LLMs At Google" (FSE 2025) is a 12-month study of **39 migrations**, 595 code changes and 93,574 edits. About **74.45% of code changes** and **69.46% of edits** were LLM-generated, and developers estimated a **50% reduction** in total time (a self-reported estimate). Generated changes go to developers for verification and acceptance. An earlier preprint said humans often had to revert some model edits. — [arXiv 2504.09691](https://arxiv.org/pdf/2504.09691); [arXiv 2501.06972](https://arxiv.org/pdf/2501.06972); [Slashdot summary](https://developers.slashdot.org/story/25/01/17/2156235/google-reports-halving-code-migration-time-with-ai-help)
- Share of AI-generated code, as stated by Google: "more than a quarter" (Q3 2024 earnings call, October 2024); about 50% by fall 2025; **75%** of new code "AI-generated and approved by engineers" (Pichai, April 2026, around Cloud Next 2026). At Cloud Next he said: "Every line of that code is reviewed and approved by engineers." These are self-reported figures; Semafor notes they are hard to verify independently. — [Semafor, 24 April 2026](https://www.semafor.com/article/04/24/2026/google-ceo-says-75-of-companys-new-code-is-ai-generated); [Fast Company](https://www.fastcompany.com/91531519/google-ceo-says-75-of-the-companys-code-is-ai-generated); [Fortune, October 2024](https://www.fortune.com/2024/10/30/googles-code-ai-sundar-pichai)

### Inferences
- Google's pattern is that AI writes or suggests, the standard review gates (LGTM, OWNERS, readability, Tricorder, TAP presubmit) stay unchanged, and humans approve. AI output is held to the same review standard rather than a separate one.
- For an AI agent on a small team, the analogous setup is to have the agent produce small, tested CLs that pass presubmit checks and include their rationale, and to keep a human LGTM mandatory.

### Gaps
- I couldn't retrieve the AutoCommenter paper's accuracy and adoption numbers. I found no primary Google statement on how the "75%" metric is defined (for example, characters accepted versus lines), so it should be treated as a company-reported figure with an unclear definition. I didn't find any 2026 Google publication on AI code review beyond these.
