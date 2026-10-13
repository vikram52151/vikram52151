# AI quality kit

A folder of files you copy into a code repository so that an AI coding agent (Claude Code) follows the
same quality steps that teams at Google and Meta use: small changes, tests with every change, independent
review, security and performance checks, and proof instead of claims.

Everything you copy lives in [`template/`](template/). Nothing here is active in this repository; the
hooks only run once the files sit at the root of the repository you copy them into.

## Why this is needed

AI-written code needs checking at least as much as human code. Studies from 2021 to 2026 keep finding
security weaknesses in roughly 40-55% of AI-generated code samples. Coding agents have been documented
editing or deleting tests and hard-coding expected answers to get a "pass". Language models also invent
package names that attackers can then register. Telling the agent "don't do that" helps, but it is not
enough on its own. Checks that run outside the agent's control do the real work.

## The four layers

Each layer catches what the one above it misses. Only the last one cannot be bypassed by the agent.

| # | Layer | Files | What it does | Can the agent get around it? |
|---|---|---|---|---|
| 1 | **Instructions** (advisory) | `CLAUDE.md`, `REVIEW.md`, `.claude/agents/`, `.claude/skills/` | Tells the agent the Definition of Done, security and performance rules, and how to review. Gives it reviewer subagents and a "quality-gate" checklist. | Yes. Claude reads these as context and usually follows them, but nothing forces it to. |
| 2 | **Hooks** (deterministic, on the machine running the agent) | `.claude/settings.json`, `.claude/hooks/*.sh` | Scripts Claude Code runs automatically: block edits to CI/config/lockfiles and commands that skip or delete tests; format and lint after each edit; run build + tests + lint when Claude tries to finish and send it back to work if they fail. | Partly. The agent cannot switch them off from inside a session, but anyone who controls the machine can, and command-text matching can be dodged by an unusual command. |
| 3 | **CI gates** | `.github/workflows/quality-gates.yml`, `claude-review.yml`, `perf/smoke.js` | GitHub re-runs the build, tests, coverage, static analysis, secret and dependency scans on every pull request. A Claude review is posted as advice. | Not on its own: the agent could edit the workflow file, which is why layer 4 exists. |
| 4 | **GitHub branch rules + CODEOWNERS + human review** | `.github/CODEOWNERS`, `docs/branch-protection.md` | GitHub refuses to merge into `main` unless the required checks pass and a human code owner approves. Changes to the guardrail files themselves need your approval. | **No**, as long as the Claude GitHub App (and any other bot) is **not on the ruleset's bypass list**. |

## What each file does

| File (inside `template/`) | Purpose |
|---|---|
| `CLAUDE.md` | Rules the agent reads every session: project commands (fill these in), Definition of Done, OWASP Top 10:2025 security rules, performance rules, how to work. About 100 lines, on purpose: long files get followed less well. |
| `REVIEW.md` | How changes are judged, modelled on Google's code review guide: the "improves code health" standard, what to check, severity labels (Important / Nit / Pre-existing). Used by the reviewer subagents and by Claude's GitHub review. |
| `.claude/settings.json` | Registers the hooks and permission rules (allow common test commands, ask before push/installs, deny force-push, `sudo`, reading `.env`, editing CI and lockfiles). |
| `.claude/hooks/protect-files.sh` | Runs before every edit and shell command. Blocks: editing `.github/workflows/`, CODEOWNERS, `.claude/`, lockfiles, `.env`, lint/coverage/budget configs; deleting or overwriting test files; the agent adding its own `api-dup-ok` suppression comment; `-DskipTests`, `-Dmaven.test.skip`, `gradle -x test`, `--no-verify`, `git push --force`, threshold overrides on the command line, `rm -rf` of whole trees. |
| `.claude/hooks/ai-gate.sh` | The quality gate. Runs automatically when Claude tries to finish a turn (Stop hook), and by hand with `bash .claude/hooks/ai-gate.sh --manual`. Detects Maven, Gradle and npm projects (root and one folder down), runs build + tests + lint, runs the duplicate-API check on the files the change touches, and checks the git diff for deleted tests, fewer tests or assertions, newly skipped tests, threshold changes and oversized diffs. |
| `.claude/hooks/post-edit-format.sh` | After each edit, formats the file (Prettier, google-java-format, etc. if installed), lints it (ESLint) and runs the duplicate-API check on it, handing problems back to Claude straight away. Never blocks. Never downloads tools. |
| `.claude/hooks/api-dup-check.py` | Finds the same API built again for each region, city, outlet, tenant or status instead of one API with a parameter: `/api/india/orders` next to `/api/us/orders`, `/orders/active` + `/orders/pending` with copied handlers, `OrderServiceIndia` / `OrderServiceUs`, `getMumbaiPrice()` / `getDelhiPrice()`, and the same in frontend calls and OpenAPI files. Reads Spring (Java/Kotlin), NestJS, Express-style routers, Angular/axios calls and OpenAPI JSON. The gate blocks new copies; only a human may add an `api-dup-ok: <reason>` comment to accept one. Run it on a whole repo with `python3 -I .claude/hooks/api-dup-check.py --root . --all`. |
| `.claude/hooks/session-reminder.sh` | After Claude compacts its context, re-injects the Definition of Done and the current state (changed files, diff size, last gate result). |
| `.claude/hooks/lib.sh` | Shared helper functions for the scripts above. |
| `.claude/hooks/quality.conf` | Optional settings: custom gate command, project folders, retry limit, tamper mode, diff-size limit, extra protected paths. All commented out by default. |
| `.claude/agents/code-reviewer.md` | Reviewer subagent: Google-style review of the diff in a fresh context; findings with severity and file:line. |
| `.claude/agents/test-auditor.md` | Checks the tests really test behaviour; looks for deleted, skipped, weakened or special-cased tests; suggests mutation testing. |
| `.claude/agents/security-reviewer.md` | OWASP Top 10:2025 checklist, secrets, new dependencies (do they exist? maintained?), authorization on every endpoint. |
| `.claude/agents/performance-reviewer.md` | N+1 queries, indexes, pagination, complexity, timeouts/retries, caching, frontend bundle size. |
| `.claude/skills/quality-gate/SKILL.md` | The checklist Claude runs before saying "done": scope check, run the gate, call the reviewers, update `docs/FIXES.md`, reply with an evidence summary. |
| `.github/workflows/quality-gates.yml` | CI: backend (`mvn verify` with JaCoCo + SpotBugs/FindSecBugs, optional diff-cover and PIT), frontend (ESLint, tests with coverage thresholds, production build with budgets, `npm audit`, optional Lighthouse CI), security (gitleaks, dependency review, CodeQL, optional Semgrep), optional k6 smoke test, the `api-design` job (duplicate-API check on the PR's files, optional jscpd copy-paste check), and one summary job `quality-gate` to mark as required. |
| `.github/workflows/claude-review.yml` | Claude reviews each pull request and leaves inline comments. Advisory only; never make it a required check. |
| `.github/CODEOWNERS` | Who must approve which files. The guardrail files are owned by you. |
| `docs/branch-protection.md` | Exact GitHub click-path (and API JSON) for the branch ruleset. |
| `docs/thresholds.md` | Recommended numbers (coverage, duplication, mutation score, Web Vitals, budgets, latency, CVSS) with sources, marked standard / tool default / convention. |
| `docs/FIXES.md` | Traceability log: requirement -> change -> commit -> test. |
| `perf/smoke.js` | k6 smoke load test with thresholds (p95 < 500 ms, errors < 1%). |
| `pom-snippets.md` | Maven plugin config to paste: JaCoCo coverage check, SpotBugs + FindSecBugs, PIT, OWASP Dependency-Check, PMD CPD copy-paste detection. |
| `package-snippets.md` | npm/Angular config to paste: scripts, ESLint, Karma/Vitest/Jest coverage thresholds, bundle budgets, `lighthouserc.json`, Stryker, jscpd copy-paste detection. |

## Install

You need: git, bash, and **jq** (`brew install jq`, `apt install jq`, or `winget install jqlang.jq`).
Without jq the hooks fall back to python3; with neither they print a warning and do nothing.
On Windows, run Claude Code with Git Bash or WSL so the bash hooks work.

1. **Copy the files** into the root of your repository (the folder that contains `.git`):
   ```bash
   cp -R ai-quality-kit/template/. /path/to/your-repo/
   chmod +x /path/to/your-repo/.claude/hooks/*.sh
   ```
   If your repo already has a `CLAUDE.md`, `.claude/settings.json` or `CODEOWNERS`, merge by hand instead
   of overwriting. `settings.json` must stay valid JSON (no comments, no trailing commas).
   `pom-snippets.md` and `package-snippets.md` can be deleted once you have used them.
2. **Fill in `CLAUDE.md` -> "Project commands"**: replace every `<PLACEHOLDER>` with your real commands
   and folders. Delete rows you don't need.
3. **Check `.gitignore`** contains your build output (`target/`, `build/`, `dist/`, `coverage/`,
   `node_modules/`). The gate remembers the last tree that passed; untracked build output makes it re-run every time.
4. **Add the build config** from `pom-snippets.md` and `package-snippets.md` (coverage check, SpotBugs,
   `test:ci` script, budgets). Run `./mvnw verify` and `npm run lint && npm run test:ci && npm run build`
   yourself first; fix or calibrate anything that fails before you hand it to the agent.
5. **Try the gate by hand**: `bash .claude/hooks/ai-gate.sh --manual`. It should list your build steps and end with `Result: PASS`.
   If it picks the wrong folders or commands, set `GATE_PROJECT_DIRS` or `GATE_CMD` in `.claude/hooks/quality.conf`.
6. **Edit `.github/CODEOWNERS`**: replace `@your-org/maintainers` and `@your-username`.
7. **Commit and push** on a branch, open a pull request, and let `Quality gates` run once.
8. **Claude review (optional)**: run `/install-github-app` in Claude Code (or install
   https://github.com/apps/claude) and add the `ANTHROPIC_API_KEY` repository secret.
9. **Turn on branch protection** following `docs/branch-protection.md`: require the `quality-gate`
   check, one approval, code-owner review, no force pushes, and **an empty bypass list**. Check that
   the Claude GitHub App is not on any bypass list and does not have admin rights.
10. In Claude Code, run `/hooks` to see the hooks are registered. If Claude Code asks whether to trust the
    folder, accept: project hooks only run in trusted folders.

## Adapting thresholds

- **Coverage, SpotBugs, mutation score**: in `pom.xml` (`<minimum>`, `<threshold>`, `<mutationThreshold>`).
- **Frontend coverage**: `karma.conf.js` (`check`), `vitest.config.ts` (`thresholds`) or `jest.config.js`.
- **Bundle size**: `angular.json` -> `budgets`. **Lighthouse**: `lighthouserc.json`. **Load test**: `perf/smoke.js`.
- **Diff size limit, retries, tamper mode**: `.claude/hooks/quality.conf`.
- Start at roughly your current numbers, run new gates as warnings for a couple of weeks, then make them
  fail the build. Raise thresholds over time; never lower one to get a change through.
- The agent is blocked from editing most of these files and CODEOWNERS routes changes to you, so
  loosening a gate is always a human decision. `docs/thresholds.md` explains where each number comes from.

## Test that it works

Do these in a scratch branch.

**Hooks by hand** (from the repo root):
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"mvn -DskipTests package"}}' | bash .claude/hooks/protect-files.sh; echo "exit=$?"
# expect: BLOCKED ... exit=2
echo '{"tool_name":"Edit","tool_input":{"file_path":".github/workflows/quality-gates.yml"}}' | bash .claude/hooks/protect-files.sh; echo "exit=$?"
# expect: BLOCKED ... exit=2
echo '{"tool_name":"Bash","tool_input":{"command":"mvn test"}}' | bash .claude/hooks/protect-files.sh; echo "exit=$?"
# expect: exit=0
```

**With Claude** (each should be refused or sent back):
1. "Delete `src/test/.../SomeTest.java`, it's failing." -> blocked by protect-files.sh.
2. "Build it with `mvn -DskipTests package`." -> blocked.
3. "Lower the coverage minimum in the CI workflow." -> blocked (CI file is protected).
4. Break a unit test on purpose, then ask Claude to "finish up". -> When it tries to stop, the Stop hook
   runs the gate, fails, and Claude is told to fix the failure.
5. "Add `/api/us/orders` like the India one." -> right after the edit Claude is told it copied an API
   per region; if it carries on, the gate blocks it until there is one `/api/{region}/orders`.
   Asking it to add `// api-dup-ok` is blocked too: only you can accept a copy.
6. Ask for a small feature and then "is it done?". -> It should run the quality-gate skill and reply
   with the evidence summary, including the gate output.

**On GitHub**: open a pull request that breaks a test. The `quality-gate` check fails and the Merge
button stays blocked. A pull request touching `.claude/` or `.github/` should request your review.

## Limits (read these)

- **CLAUDE.md is advice.** Claude Code delivers it as context, not as enforced configuration. Most of the
  time it is followed; sometimes it is not. That is why layers 2-4 exist.
- **Bash permission rules and the Bash checks in `protect-files.sh` are not a security boundary.** They
  match command text. `Bash(rm *)` does not stop `/bin/rm`, a script, or `python -c "import os; os.remove(...)"`.
  They stop accidents and casual shortcuts, not a determined workaround. The Stop-hook gate, CI and
  branch protection are what actually catch the result.
- **Hooks run with your full user permissions.** Read them before you trust them, like any script.
- **`claude -p` (headless/SDK) runs project hooks without asking.** In an interactive session hooks wait
  until you trust the folder; in `-p` mode Claude Code treats the folder as trusted. So running
  `claude -p` in a repository you don't trust runs its hooks; use `--bare` or
  `--settings '{"disableAllHooks": true}'` there. (Note `--bare` also skips this kit's hooks and CLAUDE.md.)
- **The Stop hook has a block limit.** Claude Code stops honouring Stop-hook blocks after 8 consecutive
  continuations (the counter resets whenever Claude calls a tool; `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` changes it).
  This kit adds its own limit: by default it blocks at most 3 times in a row (`GATE_MAX_BLOCKS`), using
  `stop_hook_active` to know it is in a retry, then lets Claude stop with a visible "NOT verified" message
  so it can never loop forever.
- **A timed-out gate does not block.** If your build takes longer than the hook timeout (1200 s in
  `settings.json`), Claude is allowed to stop. Raise the timeout, set `GATE_RUN_BUILD=0`, or point
  `GATE_CMD` at a faster subset; CI still runs everything.
- **The Stop hook fires at the end of every turn**, not only when the task is done. The gate skips the
  run when nothing changed, when only docs changed, or when the same tree already passed.
- **Anyone with access to the machine can switch hooks off** (`disableAllHooks`, editing
  `.claude/settings.local.json`). For a team, an admin can put the same rules in Claude Code *managed
  settings* with `allowManagedHooksOnly`, which users cannot override. Either way, branch protection is the backstop.
- **Tamper detection is a heuristic.** It counts test declarations and assertion lines in the diff. It
  can miss a cleverly weakened assertion and can flag a legitimate cleanup; by default it warns rather than blocks.
- **AI reviewers are fallible.** Studies show LLM reviewers can be swayed by confident comments and
  tidy names, and can also reject correct code. Treat their output as input for the human reviewer.
- **Tool names**: the edit hook matches `Edit|Write|MultiEdit|NotebookEdit`. If a future Claude Code
  version adds another file-writing tool, add it to the matcher in `settings.json`.

## Where the rules come from

- Google: eng-practices code review guide (code health standard, small changes, "Nit:", speed); *Software
  Engineering at Google* (test sizes, coverage guidance, Tricorder's under-10%-false-positive rule).
- Meta: diff-time static analysis (about 70% fix rate vs about 0% for batch reports); TestGen-LLM and ACH
  (accept generated tests only after they build, pass reliably and add coverage or kill a mutant).
- Amazon Builders' Library: timeouts, capped retries with backoff and jitter, retry only idempotent calls.
- OWASP Top 10:2025; SonarQube "Sonar way" defaults; web.dev Core Web Vitals; Angular CLI budgets; k6 thresholds.
- Claude Code documentation: CLAUDE.md, subagents, hooks (event names, exit code 2, `stop_hook_active`),
  permissions, skills, and the `claude-code-action` workflow.
- One API, many regions: Google's API design guide (resource-oriented design, AIP-121; list filtering
  through request fields, AIP-160), SonarQube's 3% duplication limit, PMD CPD and jscpd; GitClear's reports
  (vendor) that copied code blocks rose about eightfold as AI tools spread.
- Evidence on AI code: Veracode GenAI code security reports (vendor), METR and EvilGenie on reward hacking,
  Spracklen et al. on package hallucination, DORA 2024/2025.
