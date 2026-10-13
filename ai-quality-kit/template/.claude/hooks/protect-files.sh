#!/usr/bin/env bash
# protect-files.sh - Claude Code PreToolUse hook.
#
# Blocks (exit 2, reason on stderr) actions that would weaken the quality bar:
#   * Edit/Write to CI workflows, CODEOWNERS, .claude/ (settings, hooks, agents, skills),
#     lockfiles, lint/coverage/budget config files, .env files, .git/
#   * Bash commands that delete or truncate test files, skip tests or checks
#     (-DskipTests, -Dmaven.test.skip, gradle -x test, ...), bypass git hooks
#     (--no-verify, core.hooksPath, HUSKY=0), force-push, override gate thresholds
#     on the command line, write to protected files, or rm -rf a whole tree.
#   * Adding an 'api-dup-ok' suppression comment (Edit/Write or Bash): only a human may accept a
#     duplicated per-region API, so the agent cannot silence api-dup-check.py itself.
#
# Registered in .claude/settings.json for matcher "Edit|Write|MultiEdit|NotebookEdit" and "Bash".
# Matching is on command text, so it is best effort: CI and branch protection are the real backstop.
#
# Test by hand:
#   echo '{"tool_name":"Bash","tool_input":{"command":"mvn -DskipTests package"}}' | bash .claude/hooks/protect-files.sh; echo "exit=$?"

set -u
set -f   # no filename globbing: command text like 'rm *' must stay literal
HOOK_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HOOK_DIR/lib.sh"

INPUT=$(cat)

if ! qk_can_parse_json; then
  if [ "${PROTECT_FAIL_CLOSED:-0}" = "1" ]; then
    echo "protect-files.sh: neither jq nor python3 is installed and PROTECT_FAIL_CLOSED=1, so this action is blocked. Install jq (https://jqlang.org)." >&2
    exit 2
  fi
  echo "protect-files.sh: neither jq nor python3 is installed, so file protection is OFF. Install jq (https://jqlang.org)." >&2
  exit 1   # non-blocking: the action goes ahead, the user sees the warning
fi

PROJECT_DIR=$(qk_project_dir)
qk_load_config "$PROJECT_DIR"

# Optional extra rules from quality.conf (space-separated shell globs, matched against the repo-relative path)
PROTECT_EXTRA_GLOBS="${PROTECT_EXTRA_GLOBS:-}"
PROTECT_ALLOW_GLOBS="${PROTECT_ALLOW_GLOBS:-}"

block() {
  {
    printf 'BLOCKED by .claude/hooks/protect-files.sh: %s\n' "$1"
    printf '%s\n' "This rule protects the tests and quality gates. Do not look for another way around it."
    printf '%s\n' "If the change is genuinely needed, stop and ask the human to make it or approve it, and explain why."
  } >&2
  exit 2
}

# Normalise a path: strip quotes, turn backslashes into slashes, drop the project prefix and leading ./
normalise_path() {
  # shellcheck disable=SC1003
  _p=$(printf '%s' "$1" | tr -d "\"'" | tr '\\' '/')
  case "$_p" in
    "$PROJECT_DIR"/*) _p=${_p#"$PROJECT_DIR"/} ;;
  esac
  while :; do
    case "$_p" in
      ./*) _p=${_p#./} ;;
      *) break ;;
    esac
  done
  printf '%s' "$_p"
}

# protected_reason PATH -> prints a reason and returns 0 if PATH is protected
protected_reason() {
  _rel=$(normalise_path "$1")
  [ -z "$_rel" ] && return 1
  _base=${_rel##*/}

  if [ -n "$PROTECT_ALLOW_GLOBS" ]; then
    for _g in $PROTECT_ALLOW_GLOBS; do
      # shellcheck disable=SC2254
      case "$_rel" in $_g) return 1 ;; esac
    done
  fi

  case "/$_rel/" in
    */../*) echo "path '$_rel' contains '..'; use a normalised path inside the project"; return 0 ;;
  esac
  # Absolute paths outside this project (scratch files, ~/.claude memory, /tmp) are not our business.
  case "$_rel" in
    /*) return 1 ;;
  esac

  case "$_rel" in
    .github/workflows/*|*/.github/workflows/*)
      echo "'$_rel' is a CI workflow. Agents must not change CI to make checks pass."; return 0 ;;
    CODEOWNERS|.github/CODEOWNERS|docs/CODEOWNERS|*/.github/CODEOWNERS)
      echo "'$_rel' is CODEOWNERS (who must review what)."; return 0 ;;
    .claude|.claude/*|*/.claude/*)
      echo "'$_rel' is Claude Code configuration (settings, hooks, agents, skills). Only humans change the guardrails."; return 0 ;;
    .git/*|*/.git/*)
      echo "'$_rel' is inside .git/."; return 0 ;;
  esac

  case "$_base" in
    package-lock.json|npm-shrinkwrap.json|yarn.lock|pnpm-lock.yaml|bun.lockb|bun.lock|gradle.lockfile|*.lockfile|Pipfile.lock|poetry.lock|uv.lock|Cargo.lock|go.sum)
      echo "'$_rel' is a lockfile. Change dependencies with the package manager (npm install, mvn, gradle), never by hand."; return 0 ;;
    .env.example|.env.sample|.env.template) ;;
    .env|.env.*)
      echo "'$_rel' is an environment/secrets file."; return 0 ;;
    lighthouserc|lighthouserc.*|.lighthouserc|.lighthouserc.*|karma.conf.*|vitest.config.*|vitest.workspace.*|jest.config.*|stryker.conf.*|stryker.config.*|.eslintrc|.eslintrc.*|eslint.config.*|sonar-project.properties|.gitleaks.toml|gitleaks.toml|.semgrep.yml|.semgrep.yaml|.semgrepignore|spotbugs-exclude*.xml|findbugs-exclude*.xml|dependency-check-suppress*.xml|codecov.yml|.codecov.yml|checkstyle*.xml|pmd-ruleset*.xml|.stylelintrc*|.dependency-cruiser.*)
      echo "'$_rel' is a lint/test/coverage/security gate configuration file. Agents must not loosen gates to get a green build."; return 0 ;;
  esac

  if [ -n "$PROTECT_EXTRA_GLOBS" ]; then
    for _g in $PROTECT_EXTRA_GLOBS; do
      # shellcheck disable=SC2254
      case "$_rel" in $_g) echo "'$_rel' matches PROTECT_EXTRA_GLOBS ('$_g') in quality.conf."; return 0 ;; esac
    done
  fi
  return 1
}

is_test_path() {  # also tries PATH/ so a bare directory such as 'src/test' counts
  _tp=$(normalise_path "$1")
  printf '%s\n%s/\n' "$_tp" "$_tp" | grep -Eq "$QK_TEST_PATH_RE"
}

check_file_tool() {
  FILE=$(qk_json_get "$INPUT" '.tool_input.file_path')
  [ -z "$FILE" ] && FILE=$(qk_json_get "$INPUT" '.tool_input.notebook_path')
  [ -z "$FILE" ] && FILE=$(qk_json_get "$INPUT" '.tool_input.path')
  [ -z "$FILE" ] && exit 0
  if reason=$(protected_reason "$FILE"); then
    block "$reason"
  fi
  # Only a human may add an 'api-dup-ok' suppression (count before vs after the edit).
  NEW_TEXT="$(qk_json_get "$INPUT" '.tool_input.new_string')$(qk_json_get "$INPUT" '.tool_input.content')$(qk_json_get "$INPUT" '.tool_input.edits')$(qk_json_get "$INPUT" '.tool_input.new_source')"
  case "$NEW_TEXT" in
    *api-dup-ok*)
      OLD_TEXT=$(qk_json_get "$INPUT" '.tool_input.old_string')
      if [ -z "$OLD_TEXT" ]; then
        case "$FILE" in /*) _f=$FILE ;; *) _f="$PROJECT_DIR/$FILE" ;; esac
        [ -f "$_f" ] && OLD_TEXT=$(cat "$_f" 2>/dev/null)
      fi
      n_new=$(printf '%s' "$NEW_TEXT" | grep -o 'api-dup-ok' | wc -l)
      n_old=$(printf '%s' "$OLD_TEXT" | grep -o 'api-dup-ok' | wc -l)
      if [ "$n_new" -gt "$n_old" ]; then
        block "adding an 'api-dup-ok' comment silences the duplicate-API check. Make one API that takes the region/outlet/status as a parameter instead. If a separate API is truly required (legal, data residency, contract), tell the human the reason; only they may add the comment."
      fi ;;
  esac
  exit 0
}

# Split a shell command into simple segments on ; && || | and newlines (rough, quote-unaware).
segments() {
  printf '%s\n' "$1" | awk '{ gsub(/&&|\|\||;|\||&/, "\n"); print }'
}

check_bash() {
  CMD=$(qk_json_get "$INPUT" '.tool_input.command')
  [ -z "$CMD" ] && exit 0
  FLAT=$(printf '%s' "$CMD" | tr '\n' ' ')

  has() { printf '%s' "$FLAT" | grep -Eq -- "$1"; }

  # 0. Self-suppressing the duplicate-API check from the shell (sed -i, echo >>, tee, perl -i ...)
  if has 'api-dup-ok' && has '(sed|perl)[[:space:]]+(-[A-Za-z]*[[:space:]]+)*-[A-Za-z]*i|>|(^|[[:space:]|])tee([[:space:]]|$)|(cat|printf|echo)[^|;&]*<<'; then
    block "writing an 'api-dup-ok' comment silences the duplicate-API check. Only the human may add it, with a reason."
  fi

  # 1. Bypassing git hooks
  if has '(^|[^A-Za-z0-9_-])--no-verify([^A-Za-z0-9_-]|$)'; then
    block "'--no-verify' skips git hooks (pre-commit/pre-push checks)."
  fi
  if has 'git[[:space:]]([^;&|]*[[:space:]])?commit[^;&|]*[[:space:]]-[A-Za-z]*n[A-Za-z]*([[:space:]]|$)'; then
    block "'git commit -n' is short for --no-verify and skips git hooks."
  fi
  if has 'core\.hooksPath|HUSKY=0|HUSKY_SKIP_HOOKS|SKIP_HOOKS='; then
    block "changing core.hooksPath or setting HUSKY=0 disables git hooks."
  fi

  # 2. Force push / history rewrite on a remote
  if has 'git[[:space:]]([^;&|]*[[:space:]])?push([[:space:]][^;&|]*)?[[:space:]](--force|--force-with-lease|--force-if-includes|--mirror|-[A-Za-z]*f[A-Za-z]*)([[:space:]=]|$)'; then
    block "force-pushing rewrites shared history."
  fi
  if has 'git[[:space:]]([^;&|]*[[:space:]])?push[^;&|]*[[:space:]]\+[A-Za-z0-9_./-]+'; then
    block "'git push <remote> +branch' is a force push."
  fi

  # 3. Skipping tests or checks (Maven -D...skip..., Gradle -x test, pytest deselect, env flags)
  skip_props=$(printf '%s' "$FLAT" | grep -Eo -- '-D[A-Za-z0-9_.-]*[sS]kip[A-Za-z0-9_.-]*(=[^[:space:]]*)?' | grep -v '=false$')
  if [ -n "$skip_props" ]; then
    block "'$(printf '%s' "$skip_props" | head -n 1)' skips tests or checks. Run the full build; fix failures instead of skipping them."
  fi
  if has 'maven\.test\.failure\.ignore|testFailureIgnore|(^|[[:space:]])(--fail-never|-fn)([[:space:]]|$)'; then
    block "ignoring test failures hides broken tests."
  fi
  if has '-D[A-Za-z0-9_.-]*(haltOnFailure|failOnError|failOnViolation|failBuildOnCVSS|[tT]hreshold|minimum|[cC]overedRatio)[A-Za-z0-9_.-]*='; then
    block "overriding a gate threshold on the command line weakens the gate."
  fi
  if has '(gradle|gradlew)[^;&|]*([[:space:]]-x[[:space:]]*:?[^[:space:]]*([tT]est|check|[lL]int|spotbugs|jacoco|pmd|checkstyle|detekt|ktlint|spotless)|--exclude-task)'; then
    block "excluding test/check tasks from Gradle skips the gate."
  fi
  if has '(^|[[:space:]])(--deselect|--no-cov|--testPathIgnorePatterns|--cov-fail-under=)|pytest[^;&|]*-k[[:space:]]*["'"'"']?not[[:space:]]|(^|[[:space:]])-p[[:space:]]+no:|(^|[[:space:]])SKIP_?TESTS?='; then
    block "deselecting or skipping tests hides failures."
  fi

  # 4. Per-segment checks: deleting/truncating tests, writing protected files, rm -rf of whole trees
  segs=$(segments "$CMD")
  while IFS= read -r seg; do
    seg=$(printf '%s' "$seg" | sed 's/^[[:space:]]*//')
    [ -z "$seg" ] && continue
    # drop leading env assignments / sudo / command wrappers
    core=$(printf '%s' "$seg" | sed -E 's/^(([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*|sudo|command|builtin|exec|nohup|time)[[:space:]]+)*//')

    is_delete=0
    if printf '%s' "$core" | grep -Eq '^(/usr/bin/|/bin/)?(rm|unlink|shred|rmdir|trash)([[:space:]]|$)|^git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+rm([[:space:]]|$)|^find[[:space:]].*(-delete|-exec[[:space:]]+(/bin/)?rm)'; then
      is_delete=1
    fi
    is_write=0
    if printf '%s' "$core" | grep -Eq '^(sed[[:space:]]+(-[A-Za-z]*[[:space:]]+)*-i|perl[[:space:]]+-[A-Za-z]*i|tee|truncate|cp|mv|ln|install|chmod|chown|dd|rsync)([[:space:]]|$)|^git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+(checkout|restore|rm|mv)([[:space:]]|$)'; then
      is_write=1
    fi

    # rm -rf on a whole tree
    if printf '%s' "$core" | grep -Eq '^(/usr/bin/|/bin/)?rm[[:space:]]+(-[A-Za-z]*[rR][A-Za-z]*[[:space:]]+|--recursive[[:space:]]+)'; then
      for tok in $core; do
        # literal patterns on purpose: we match the text the agent typed, not its expansion
        # shellcheck disable=SC2088,SC2016
        case "$tok" in
          '/'|'/*'|'~'|'~/'|'~/*'|'$HOME'|'$HOME/'|'${HOME}'|'.'|'./'|'./*'|'*'|'..'|'../')
            block "'$seg' would delete a whole directory tree." ;;
        esac
      done
    fi

    # Arguments (rough tokenisation; quotes stripped)
    if [ "$is_delete" = 1 ] || [ "$is_write" = 1 ]; then
      first=1
      for tok in $(printf '%s' "$core" | tr -d "\"'"); do
        if [ "$first" = 1 ]; then first=0; continue; fi
        case "$tok" in -*) continue ;; esac
        if [ "$is_delete" = 1 ] && is_test_path "$tok"; then
          block "'$seg' deletes test files. Tests are only removed by a human, with a reason."
        fi
        if reason=$(protected_reason "$tok"); then
          block "'$seg' modifies a protected file: $reason"
        fi
      done
    fi

    # find ... -delete with a test pattern anywhere in the segment
    if [ "$is_delete" = 1 ] && printf '%s' "$core" | grep -Eq '^find' && printf '%s' "$core" | grep -Eq 'src/test|__tests__|Test\.|\.spec\.|\.test\.|test_|_test\.'; then
      block "'$seg' deletes test files."
    fi

    # Redirect targets: '> file' (truncate) into tests or protected files; '>>' into protected files
    targets=$(printf '%s' "$seg" | grep -Eo '(^|[^>0-9&])>>?[[:space:]]*[^[:space:]&|;<>]+' | sed -E 's/^[^>]*//')
    if [ -n "$targets" ]; then
      while IFS= read -r t; do
        mode=">"
        case "$t" in '>>'*) mode=">>" ;; esac
        path=$(printf '%s' "$t" | sed -E 's/^>>?[[:space:]]*//')
        case "$path" in /dev/null|/dev/stderr|/dev/stdout|'&'*) continue ;; esac
        if [ "$mode" = ">" ] && is_test_path "$path"; then
          block "'$seg' overwrites a test file through a shell redirect. Use the Edit/Write tools so the change is visible."
        fi
        if reason=$(protected_reason "$path"); then
          block "'$seg' writes to a protected file: $reason"
        fi
      done <<EOF
$targets
EOF
    fi
  done <<EOF
$segs
EOF
  exit 0
}

TOOL=$(qk_json_get "$INPUT" '.tool_name')
case "$TOOL" in
  Bash) check_bash ;;
  *) check_file_tool ;;
esac
