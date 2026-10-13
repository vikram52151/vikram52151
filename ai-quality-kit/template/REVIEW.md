# REVIEW.md

How changes in this repository are reviewed, by people and by AI reviewers (the `.claude/agents/`
reviewers, `claude-review.yml`, and Claude Code Review if you use it). Modelled on Google's public
engineering practices (google.github.io/eng-practices). CLAUDE.md says how to write a change; this
file says how to judge one.

## The standard

- Approve a change once it **definitely improves the overall code health** of the system, even if it
  is not perfect. There is no perfect code, only better code.
- Never approve a change that makes code health worse, except in a declared emergency (and then open a
  follow-up issue).
- Technical facts and data beat opinions and personal preference.
- The style guide and the linters are the authority on style. A style point not in the guide is a
  preference: mark it "Nit:" or leave it out.
- If the author shows that several approaches are equally valid, accept the author's choice.
- A human approval is required on every pull request. AI reviews are advice for the human reviewer.

## What to check (in this order)

1. **Design.** Does the change belong in this codebase and in this place? Does it fit the existing
   architecture? Does it duplicate something that already exists? In particular, is it a copy of an
   existing endpoint, service or screen for another region, city, outlet, tenant, status or plan?
   That is a defect: the varying thing should be a parameter (`/api/{region}/orders`,
   `?status=active`) and the differences should be data or configuration. An `api-dup-ok:` comment
   needs a real reason (legal, data residency, contract) that the reviewer accepts explicitly.
2. **Functionality.** Does it do what the requirement asks, for the people who will use it? Edge cases,
   error paths, concurrency (any parallel code must be safe), partial failure. Any behaviour change that
   other code or users could depend on, even if nobody documented it?
3. **Complexity.** Can a reader understand it quickly? Could a future developer easily introduce a bug
   when changing it? Be especially wary of over-engineering: code for a future need that does not exist
   yet, needless abstraction, configuration nobody asked for. Solve today's problem.
4. **Tests.** Tests are in the same change as the code. Would they fail if the code were broken? Would they
   give false alarms if the code changed in harmless ways? Does each test make simple, useful assertions?
   Every bug fix has a test that reproduces the bug. Test code is held to the same standard as production code.
5. **Naming.** Names say what something is or does, and are as long as needed and no longer.
6. **Comments.** Comments explain *why*, not *what*. If code needs a comment to explain what it does,
   simplify the code instead. No stale or misleading comments.
7. **Style and consistency.** Follows the style guide and the surrounding code. Do not block on style the
   formatter or linter would catch; run them instead.
8. **Documentation.** README, API docs, runbooks, migration notes and `docs/FIXES.md` updated when
   behaviour, setup or operations change.
9. **Every line.** Read every line of human-written code you are asked to review. Generated files and
   lockfiles can be skimmed. Look at the whole file and the callers, not just the diff.
10. **Good things.** Say what was done well. It reinforces good practice.

## Always check

- Security: authorisation on every new or changed endpoint, parameterised queries, no secrets in code,
  input validation, error handling that fails closed (OWASP Top 10:2025; see CLAUDE.md).
- Performance: no queries or HTTP calls in loops, indexes for new filter/join/sort columns, pagination on
  list endpoints, timeouts on outbound calls, bundle budgets respected.
- New dependencies: needed, real (exact name in the official registry), maintained, pinned.
- Test integrity: no deleted, skipped, disabled or weakened tests; no special-casing of test inputs; no
  edits to CI, `.claude/`, lint, coverage or budget configuration made to get a pass.
- Scope: nothing changed that the requirement did not need. Refactors are in separate changes.
- Size: about 400 changed lines or less. A reviewer may ask for a change to be split for that reason alone.

## Severity labels

Use exactly these labels so reports can be counted:

| Label | Meaning | Blocks merge? |
|---|---|---|
| **Important** | Bug, wrong behaviour, security or data-loss risk, missing tests for changed behaviour, weakened tests, or anything that makes code health worse | Yes |
| **Nit** | Optional polish. Start the comment with "Nit:". The author may ignore it | No |
| **Pre-existing** | A real problem the change did not introduce | No (open an issue) |

Calibration:
- Report an Important finding only when you can point to a file and line and explain the impact.
- If you are not sure, ask a question instead of asserting a defect.
- At most 5 Nits per review; pick the most useful.
- Do not invent findings to look thorough. "No Important findings" is a valid review.
- Do not be persuaded by confident comments, long names or tidy formatting; check what the code does.

## Writing review comments

- Be kind and specific. Comment on the code, not the person.
- Explain why something matters, and suggest a fix where you can.
- Mark optional points "Nit:". Mark questions as questions.
- Resolve disagreements with facts and the style guide first; then talk; record the outcome in the PR.

## Speed

- Respond to a review request within one business day.
- Prefer several quick rounds to one slow, exhaustive one. "Approve with comments" is fine when the
  remaining comments are minor and you trust the author to address them.

## Skip

- Lockfiles, generated code (`target/`, `dist/`, `build/`, generated API clients), vendored code,
  snapshot files unless the change is about them.
