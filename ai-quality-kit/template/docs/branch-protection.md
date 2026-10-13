# Branch protection: the layer the agent cannot bypass

Everything on the developer's machine (CLAUDE.md, hooks, permission rules) can be switched off by
whoever controls that machine, and hooks match command text, so a determined workaround can slip
past them. GitHub's server-side rules are different: no agent, script or person without admin rights
can merge into `main` without passing them. Set them up once per repository.

Menu names below come from GitHub's documentation as summarised in early 2026; GitHub occasionally
renames things, so if a label differs slightly, look for the closest match.

## Before you start

1. Push `.github/workflows/quality-gates.yml` to `main` and let it run once (open a test pull request).
   GitHub only offers a check in the "required checks" search after it has run at least once.
2. Push `.github/CODEOWNERS` with real users or teams in it. It must be on the base branch.
3. You need admin rights on the repository (or the organization, for org-wide rulesets).

## Option A (recommended): a branch ruleset

Repository -> **Settings** -> **Rules** -> **Rulesets** -> **New ruleset** -> **New branch ruleset**.

| Setting | Value |
|---|---|
| Ruleset name | `protect-main` |
| Enforcement status | **Active** |
| Bypass list | **Leave empty.** Do not add the Claude GitHub App, Dependabot, other bots or "Repository admin" unless you have a written reason. Anyone on this list can merge without the checks. |
| Target branches | **Add target** -> **Include default branch** (add `release/*` etc. if you use them) |

Rules to switch on:

- [x] **Restrict deletions**
- [x] **Block force pushes**
- [x] **Require linear history** (optional; keeps history readable)
- [x] **Require a pull request before merging**
  - Required approvals: **1** (2 for security-sensitive repos)
  - [x] **Dismiss stale pull request approvals when new commits are pushed**
  - [x] **Require review from Code Owners**
  - [x] **Require approval of the most recent reviewable push** (the person who pushed last cannot be the only approver)
  - [x] **Require conversation resolution before merging**
- [x] **Require status checks to pass**
  - [x] **Require branches to be up to date before merging**
  - Add check: **`quality-gate`** (the summary job from `quality-gates.yml`). Where offered, pick
    **GitHub Actions** as the expected source so another app cannot post a fake passing check.
  - Do **not** add `review` from `claude-review.yml`. It is advisory.
- [x] **Require code scanning results** (if you run CodeQL): tool **CodeQL**, alerts threshold **Errors**,
  security alerts threshold **High or higher**.

Click **Create**.

## Option B: classic branch protection

Repository -> **Settings** -> **Branches** -> **Add branch protection rule** (or **Add classic branch protection rule**).

- Branch name pattern: `main`
- [x] Require a pull request before merging -> Require approvals: 1 -> Dismiss stale approvals ->
  Require review from Code Owners -> Require approval of the most recent reviewable push
- [x] Require status checks to pass before merging -> Require branches to be up to date -> add `quality-gate`
- [x] Require conversation resolution before merging
- [x] **Do not allow bypassing the above settings** (otherwise admins, and apps acting as admins, skip them)
- [ ] Allow force pushes: **off**
- [ ] Allow deletions: **off**

## Other repository settings that matter

- **Settings -> Actions -> General -> Workflow permissions**: choose **Read repository contents and
  packages permissions**, and leave **Allow GitHub Actions to create and approve pull requests** unchecked.
  Otherwise a workflow could approve its own pull request.
- **Settings -> Collaborators and teams**: the Claude GitHub App needs write access to comment and push
  branches, never admin. Check **Settings -> GitHub Apps** (or the org's installed apps) for what it can access.
- **Settings -> Code security**: turn on the dependency graph, Dependabot alerts and secret scanning
  (push protection) if available on your plan.

## Check that it works

1. Open a pull request that breaks a unit test. The `quality-gate` check should fail and **Merge** should be
   blocked (greyed out, "Required statuses must pass").
2. Open a pull request that edits a file under `.github/workflows/`. It should ask for a code-owner review.
3. Try `git push --force` to `main` from your machine. It should be rejected by GitHub.
4. In the ruleset page, open **Insights** (rule insights) to see every evaluation, including any bypasses.

## The same ruleset through the API (optional)

Save as `ruleset.json`, edit, then run
`gh api --method POST repos/OWNER/REPO/rulesets --input ruleset.json`.
Field names follow GitHub's REST API for rulesets; check them against the current docs before use.

```json
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {
    "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
  },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [ { "context": "quality-gate" } ]
      }
    }
  ]
}
```
