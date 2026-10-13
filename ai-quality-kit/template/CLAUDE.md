# CLAUDE.md

Working rules for AI agents in this repository. They are backed by checks: hooks in
`.claude/settings.json` block some actions and run the quality gate when you stop, CI re-runs the
checks on every pull request, and a human approves every merge. Review rules are in REVIEW.md.

## Project commands (replace the placeholders for this repo)

| Purpose | Command |
|---|---|
| Quality gate (run before saying "done") | `bash .claude/hooks/ai-gate.sh --manual` |
| Backend build + all tests | `<BACKEND_VERIFY>` e.g. `./mvnw -B -ntp verify` (Spring Boot / Maven) |
| One backend test | `<BACKEND_ONE_TEST>` e.g. `./mvnw -B test -Dtest=OrderServiceTest` |
| Frontend lint | `<FRONTEND_LINT>` e.g. `npm run lint` (Angular: `ng lint`) |
| Frontend unit tests | `<FRONTEND_TEST>` e.g. `npm run test:ci` |
| Frontend production build (checks bundle budgets) | `<FRONTEND_BUILD>` e.g. `npm run build` |
| Run locally | `<RUN>` e.g. `./mvnw spring-boot:run` and `npm start` |
| DB migrations live in | `<MIGRATIONS_DIR>` e.g. `src/main/resources/db/migration` (Flyway) |

Layout: backend in `<backend/>`, frontend in `<frontend/>`. Main branch: `<main>`.

## Definition of Done

A task is done only when all of these are true. If one cannot be met, say which and why. Do not claim done.

1. **Small change.** One self-contained change, about 400 changed lines or less (lockfiles and
   generated files excluded). If it will be bigger, propose a split into smaller steps first.
2. **Refactor separately.** Do not mix refactoring (renames, moves, restructuring) with behaviour
   changes. A refactor keeps the existing tests passing without editing them.
3. **Tests in the same change.** Every behaviour change has tests in the same change, and those tests
   would fail if the code were broken. Assert on outcomes (return values, saved state, HTTP status and
   body), not only on mocks being called.
4. **Bug fixes start with a failing test.** Write a test that reproduces the bug, run it and show it
   failing, then fix the code, then show it passing. Keep both outputs for the summary.
5. **IMPORTANT: never weaken the checks.** Do not delete, skip, disable or loosen tests or assertions.
   Do not special-case test inputs or hard-code expected values in production code. Do not edit CI
   workflows, `.claude/`, lint/coverage/budget configuration or lockfiles to get a pass. If a test
   looks wrong, stop and explain why to the human.
6. **Evidence, not claims.** Run `bash .claude/hooks/ai-gate.sh --manual` and paste its report.
   Never say "tests pass" without output that shows it.
7. **Independent review.** Run the `quality-gate` skill. It sends the change to the reviewer subagents
   (code-reviewer, test-auditor, security-reviewer, performance-reviewer). Fix every Important finding
   or explain, with evidence, why you disagree.
8. **Dependencies are checked.** No new dependency unless it is needed and you have checked that it
   exists under that exact name in the official registry (`npm view <name>`, Maven Central), is
   maintained (recent releases, real source repository) and is not a look-alike name. AI tools invent
   package names; attackers register them. Add dependencies only through the package manager.
9. **Traceability.** Add a line to `docs/FIXES.md`: requirement or issue -> what changed -> commit ->
   test(s) that prove it.
10. **Root cause.** Fix causes, not symptoms. No empty catch blocks, no swallowed errors, no sleeps or
    retries added to make a flaky test pass.
11. **One API, many regions.** Before adding an endpoint, service, class or method, search for an
    existing one that does the same job (see "Reuse before you add"). Never copy one per region,
    city, outlet, tenant, status or plan. The gate runs `api-dup-check.py` and blocks these copies.

## Reuse before you add (one API, many regions)

- First list what exists: `grep -rn "@\(Get\|Post\|Put\|Delete\|Patch\|Request\)Mapping" src/main`
  (or `bash .claude/hooks/ai-gate.sh --manual`). Say in your plan which existing endpoint or service
  you extend, or why none fits.
- The thing that varies is a **parameter**, not a new API: `GET /api/{region}/orders` or
  `GET /api/orders?region=IN&status=active`, not `/api/india/orders` + `/api/us/orders` or
  `/orders/active` + `/orders/pending`.
- Region differences (price, tax, currency, timezone, language, features) live in **data or
  configuration** (a table, `application.yml`, a `Map<Region, Strategy>` of beans), not in copied
  classes like `OrderServiceIndia` / `OrderServiceUs` or methods like `getMumbaiPrice()`.
- New region = new row or config entry, not new code. Validate the parameter (enum or allow-list) and
  check the caller may access that region (A01).
- Frontend: one service method that takes the region, not one per region.
- If a separate endpoint is truly required (legal, data residency, a partner contract), stop and tell
  the human why. Only they may add the `api-dup-ok: <reason, ticket>` comment (a hook blocks you).

## Security rules (OWASP Top 10:2025)

- **A01 Access control (incl. SSRF):** authorise every endpoint on the server, deny by default. Check
  that the caller owns the object (user/tenant), not just that they are logged in. Fetch user-supplied
  URLs only through an allow-list.
- **A02 Misconfiguration:** no stack traces or debug info in responses; Actuator endpoints secured;
  no `*` CORS with credentials; no default passwords; keep security headers.
- **A03 Supply chain:** see rule 8. Pin versions, commit lockfiles, never `curl | sh`.
- **A04 Cryptography:** no home-made crypto. Passwords via bcrypt/argon2 (Spring `PasswordEncoder`).
  Secrets come from environment or a secret manager, never from code, config in git, or logs.
- **A05 Injection:** parameterised queries only (JPA parameters, `JdbcTemplate` with `?`), never
  string-built SQL/JPQL. No shell commands built from input. Angular: no `innerHTML` or
  `bypassSecurityTrust*` with user data.
- **A06 Insecure design:** validate input at the boundary (`@Valid`, size limits). Rate-limit login,
  signup, password reset and expensive endpoints. Consider abuse cases (negative amounts, replays, races).
- **A07 Authentication:** use the framework (Spring Security). Check JWT signature, algorithm, expiry, audience.
- **A08 Integrity:** never deserialise untrusted data into arbitrary types. Verify webhook signatures.
- **A09 Logging:** log security events (failed login, access denied) without secrets or personal data.
  Strip CR/LF from user input written to logs.
- **A10 Exceptional conditions:** fail closed. Catch specific exceptions. Do not leak internals in error
  responses. Make sure transactions roll back and resources are released on error paths.

## Performance rules

- No database or HTTP calls inside loops (N+1). Use joins (`JOIN FETCH`, `@EntityGraph`) or batched
  `IN` queries. When you change data access, add a test that asserts the SQL statement count.
- Every column you filter, join or sort on in a growing table has an index, added by a migration in
  the same change. A full table scan (`type=ALL` in `EXPLAIN`) on a large table is a bug.
- List endpoints paginate (`Pageable`) with a maximum page size. Never load a whole table into memory.
- Every outbound call has connect and read timeouts. Retry only idempotent calls, with a cap and
  exponential backoff with jitter, at one layer only. No remote calls inside DB transactions.
- No O(n^2) work on input that can grow; use maps and sets for lookups.
- Frontend: stay within the `angular.json` budgets; lazy-load feature routes; use `track`/`trackBy`
  in lists; import only what you use; size and lazy-load images.
- Cache only with a clear key, a TTL or size limit, and an invalidation rule.

## How to work

- Explore, plan, implement, verify. For anything bigger than a one-sentence change, write the plan
  first and keep to it. Do not change things the task does not need.
- Search for an existing helper before writing a new one. Follow the patterns in surrounding code.
- Build what is needed now, not what might be needed later.
- After two failed attempts at the same fix, stop and report what you tried and what you saw.
- When compacting, keep: the task, the list of modified files, test commands, and the last gate result.

## Protected by hooks (ask the human instead of working around them)

- Editing `.github/workflows/`, `.claude/`, CODEOWNERS, lockfiles, `.env*`, lint/test/coverage/budget configs.
- `--no-verify`, `-DskipTests`, `-Dmaven.test.skip`, `gradle -x test`, `git push --force`, deleting test files.
- Copies of an API per region/outlet/status: flagged right after the edit and blocked by the gate.
- The Stop hook runs the gate when you finish a turn. If it blocks you, fix the failures it reports.
