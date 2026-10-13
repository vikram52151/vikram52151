---
name: quality-gate
description: Run before claiming any coding task is done. Runs the project's quality gate script, sends the change to the reviewer subagents (code-reviewer, test-auditor, security-reviewer, performance-reviewer), and produces an evidence summary with real command output.
when_to_use: Use when you are about to say a task is finished, before committing or opening a pull request, or when the user asks "is it done?", "verify", "check your work" or "run the quality gate".
---

# Quality gate: verify, review, then report with evidence

Do not claim a task is done until every step below is complete. Report what actually happened,
including failures. A claim without pasted command output does not count as evidence.

## Current state

Changed files (working tree vs HEAD):
!`git status --short`

Diff size vs HEAD:
!`git diff --stat HEAD | tail -n 1`

## Step 1: scope check

- Is the change one self-contained piece of work of about 400 changed lines or less (lockfiles excluded)?
  If not, stop and propose how to split it.
- Does it mix a refactor with a behaviour change? If so, say so and propose separating them.
- Did anything change that the task did not need? Revert it or justify it.

## Step 2: run the gate

Run exactly:

```
bash .claude/hooks/ai-gate.sh --manual
```

- If it fails, fix the root cause and run it again. Never skip, delete, disable or weaken tests,
  assertions, lint rules, coverage or budget settings to get a pass. If you believe a test is wrong,
  stop and explain why to the user instead of changing it.
- If it reports "Possible test or gate tampering" or warnings, address each item or explain it in the summary.
- If it reports "Could not run", say so in the summary: the work is not verified.
- Keep the final report block (from "AI quality gate report" to "Result:") for the summary.

For a bug fix you should already have output showing the new test failing before the fix. If not,
temporarily revert the fix (e.g. `git stash push -- <production files>`), run that single test, record
the failure, restore the fix, and run it again.

## Step 3: reviewer subagents

Delegate to the reviewers in fresh contexts. Give each one: the task description in one or two sentences,
the requirement or issue ID, and the instruction "Review the diff against the main branch. Report only
findings that affect correctness, the requirements or code health." They can run in parallel.

| Reviewer | When |
|---|---|
| code-reviewer | always |
| test-auditor | whenever production code or tests changed |
| security-reviewer | endpoints, auth, input handling, queries, files, network, config, dependencies, LLM calls |
| performance-reviewer | database access, loops over collections, outbound calls, list endpoints, caching, frontend deps/routes |

Then:
- Fix every **Important** finding, or explain to the user why you disagree (with evidence).
- Nits are optional; fix the cheap ones.
- If you changed code after the reviews, run Step 2 again.

## Step 4: traceability

Add or update a line in `docs/FIXES.md` (create it from the template if missing):
`| date | requirement or issue | what changed | commit (or "uncommitted") | test(s) that prove it |`

## Step 5: evidence summary

Reply to the user with this structure, filled with real data:

```
## Evidence summary
Task: <one sentence>
Requirement -> change -> test: <ID or description> -> <files / commit> -> <test class#method or spec name>

Gate: PASS | FAIL | NOT VERIFIED
<paste the gate report block from Step 2>

Failing-first test (bug fixes only):
<command and the key failure line before the fix> / <same test passing after>

Reviews:
- code-reviewer: <verdict>, <n> Important (fixed: ... / disputed: ...), <n> Nit
- test-auditor: <verdict>, ...
- security-reviewer: <verdict or "not needed: reason">
- performance-reviewer: <verdict or "not needed: reason">

Diff: <n> files, <n> lines. New dependencies: <none | name@version, checked how>
Not verified / open risks: <anything not covered, or "none">
```

Never write "all tests pass" unless the pasted gate output shows it.
