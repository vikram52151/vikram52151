#!/usr/bin/env bash
# ai-gate.sh - the quality gate.
#
# Two ways to run it:
#   1. As the Claude Code Stop hook (configured in .claude/settings.json). It reads the hook JSON
#      on stdin. If the build, tests or lint fail it exits 2 and the failure output (stderr) is fed
#      back to Claude, which has to keep working. It honours stop_hook_active so it cannot loop forever.
#   2. By hand, or by Claude before claiming "done":
#         bash .claude/hooks/ai-gate.sh --manual
#      Prints an evidence report. Exit 0 = pass, 1 = fail.
#
# What it runs (auto-detected at the repo root and one directory down, e.g. backend/ and frontend/):
#   Maven  : ./mvnw (or mvn) -B -ntp verify      (tests, JaCoCo check, SpotBugs... whatever your pom binds to verify)
#   Gradle : ./gradlew (or gradle) build          (assemble + check)
#   npm    : lint, test:ci (or test), build        (scripts that exist in package.json; pnpm/yarn detected by lockfile)
#   Make   : make check                            (only when nothing else is detected and a 'check' target exists)
# Override everything with GATE_CMD in .claude/hooks/quality.conf.
#
# Duplicate-API check (api-dup-check.py): the same endpoint, class or method copied per region,
#   outlet, tenant or status instead of one API that takes it as a parameter. Only findings in files
#   this change touches count. API_DUP_MODE=block (default) fails the gate, warn only reports, off skips.
#
# Best-effort tamper checks (git diff against the merge-base with the main branch):
#   deleted test files, fewer test declarations or assertions, newly skipped/focused tests,
#   trivially true assertions, threshold/skip changes in build config, diff size over the limit.
#   By default these are warnings shown to Claude and to you; GATE_TAMPER_MODE=block makes them fail the gate.

set -u
HOOK_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HOOK_DIR/lib.sh"

MODE=hook
case "${1:-}" in
  --manual|-m) MODE=manual ;;
  --help|-h) sed -n '2,24p' "$0"; exit 0 ;;
esac

INPUT=""
if [ "$MODE" = hook ]; then
  INPUT=$(cat)
  if ! qk_can_parse_json; then
    echo "ai-gate.sh: neither jq nor python3 is installed, so the quality gate did not run. Install jq." >&2
    exit 1   # non-blocking
  fi
fi

PROJECT_DIR=$(qk_project_dir)
cd "$PROJECT_DIR" || { echo "ai-gate.sh: cannot cd to $PROJECT_DIR" >&2; exit 1; }
qk_load_config "$PROJECT_DIR"

GATE_MAX_BLOCKS="${GATE_MAX_BLOCKS:-3}"        # consecutive Stop blocks before letting Claude stop anyway
GATE_TAMPER_MODE="${GATE_TAMPER_MODE:-warn}"   # warn | block
GATE_MAX_DIFF_LINES="${GATE_MAX_DIFF_LINES:-400}"
GATE_RUN_BUILD="${GATE_RUN_BUILD:-1}"          # 0 = skip 'npm run build' (faster local loop; CI still builds)
GATE_CMD="${GATE_CMD:-}"
GATE_PROJECT_DIRS="${GATE_PROJECT_DIRS:-}"     # e.g. "backend frontend" to skip auto-detection of locations
GATE_LOG_TAIL="${GATE_LOG_TAIL:-60}"
GATE_SKIP_DOCS_ONLY="${GATE_SKIP_DOCS_ONLY:-1}"
API_DUP_MODE="${API_DUP_MODE:-block}"          # block | warn | off
API_DUP_EXTRA_WORDS="${API_DUP_EXTRA_WORDS:-}"  # more region-like words, e.g. "mumbai-west outlet7"
API_DUP_SIMILARITY="${API_DUP_SIMILARITY:-0.85}"

STATE_DIR=$(qk_state_dir)
SESSION="manual"
ACTIVE="false"
if [ "$MODE" = hook ]; then
  SESSION=$(qk_json_get "$INPUT" '.session_id' | tr -d '\n' | tr -c 'A-Za-z0-9_-' '_' | cut -c1-80)
  [ -z "$SESSION" ] && SESSION="unknown"
  ACTIVE=$(qk_json_get "$INPUT" '.stop_hook_active')
fi
COUNTER_FILE="$STATE_DIR/blocks-$SESSION"

# ---------------------------------------------------------------- loop protection
if [ "$MODE" = hook ]; then
  if [ "$ACTIVE" = "true" ]; then
    count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    case "$count" in ''|*[!0-9]*) count=0 ;; esac
    if [ "$count" -ge "$GATE_MAX_BLOCKS" ]; then
      rm -f "$COUNTER_FILE"
      qk_emit_json "Stop" "" "AI quality gate: still failing after blocking $count time(s) in a row (GATE_MAX_BLOCKS=$GATE_MAX_BLOCKS), so Claude is allowed to stop. The work is NOT verified. Run: bash .claude/hooks/ai-gate.sh --manual"
      exit 0
    fi
  else
    rm -f "$COUNTER_FILE"
  fi
fi

# ---------------------------------------------------------------- what changed
IN_GIT=0
qk_in_git && IN_GIT=1
BASE=""
BASE_NAME="(not a git repo)"
CHANGED=""
if [ "$IN_GIT" = 1 ]; then
  BASE=$(qk_base_rev)
  BASE_NAME=$(qk_base_ref_name)
  CHANGED=$( { git diff --name-only "$BASE" -- 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | sort -u | sed '/^$/d')
fi

if [ "$MODE" = hook ] && [ "$IN_GIT" = 1 ]; then
  if [ -z "$CHANGED" ]; then
    rm -f "$COUNTER_FILE"
    exit 0   # nothing changed: nothing to verify
  fi
  if [ "$GATE_SKIP_DOCS_ONLY" = 1 ]; then
    code_changes=$(printf '%s\n' "$CHANGED" | grep -Ev '\.(md|txt|adoc|rst)$|^docs/|(^|/)LICENSE' || true)
    if [ -z "$code_changes" ]; then rm -f "$COUNTER_FILE"; exit 0; fi
  fi
fi

fingerprint() {
  {
    printf '%s\n' "$BASE"
    git diff "$BASE" -- 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null | git hash-object --stdin-paths 2>/dev/null
  } | git hash-object --stdin
}
FP=""
if [ "$IN_GIT" = 1 ]; then
  FP=$(fingerprint)
  if [ "$MODE" = hook ] && [ "$FP" = "$(cat "$STATE_DIR/last-pass" 2>/dev/null)" ]; then
    rm -f "$COUNTER_FILE"
    exit 0   # this exact tree already passed the gate
  fi
fi

# ---------------------------------------------------------------- run the checks
LOG_DIR="$STATE_DIR/logs"
mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR"/*.log 2>/dev/null
RESULTS=""        # lines: STATUS|label|command|seconds
FAILED_LOGS=""    # paths of logs for failed steps
NOT_RUN=""        # human-readable notes about checks that could not run
step_no=0

run_step() {  # run_step LABEL DIR COMMAND...
  label="$1"; dir="$2"; shift 2
  step_no=$((step_no + 1))
  log="$LOG_DIR/$step_no.log"
  start=$(date +%s)
  ( cd "$dir" && CI=true "$@" ) >"$log" 2>&1
  rc=$?
  secs=$(( $(date +%s) - start ))
  if [ "$rc" -eq 0 ]; then
    RESULTS="${RESULTS}PASS|$label|$*|${secs}s
"
  else
    RESULTS="${RESULTS}FAIL|$label|$* (exit $rc)|${secs}s
"
    FAILED_LOGS="$FAILED_LOGS $log"
  fi
}

note_not_run() { NOT_RUN="${NOT_RUN}- $1
"; }

has_npm_script() {  # has_npm_script DIR NAME
  s=""
  if qk_have jq; then
    s=$(jq -r --arg n "$2" '.scripts[$n] // empty' "$1/package.json" 2>/dev/null)
  elif qk_have python3; then
    s=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("scripts",{}).get(sys.argv[2],""))' "$1/package.json" "$2" 2>/dev/null)
  fi
  case "$s" in ''|*'no test specified'*) return 1 ;; esac
  NPM_SCRIPT_BODY="$s"
  return 0
}

touched() {  # touched DIR -> true if the change touches DIR (always true for '.' or manual mode)
  [ "$MODE" = manual ] && return 0
  [ "$1" = "." ] && return 0
  [ "$IN_GIT" = 0 ] && return 0
  printf '%s\n' "$CHANGED" | grep -q "^$1/"
}

gate_maven() {
  d="$1"
  if [ -x "$d/mvnw" ]; then run_step "maven verify ($d)" "$d" ./mvnw -B -ntp verify
  elif qk_have mvn; then run_step "maven verify ($d)" "$d" mvn -B -ntp verify
  else note_not_run "Maven project in '$d' but neither ./mvnw nor mvn is available"; fi
}

gate_gradle() {
  d="$1"
  if [ -x "$d/gradlew" ]; then run_step "gradle build ($d)" "$d" ./gradlew build --console=plain
  elif qk_have gradle; then run_step "gradle build ($d)" "$d" gradle build --console=plain
  else note_not_run "Gradle project in '$d' but neither ./gradlew nor gradle is available"; fi
}

gate_node() {
  d="$1"
  pm=npm
  [ -f "$d/pnpm-lock.yaml" ] && pm=pnpm
  [ -f "$d/yarn.lock" ] && pm=yarn
  # a package.json with none of these scripts is tooling only (e.g. husky at the repo root): nothing to gate
  if ! has_npm_script "$d" lint && ! has_npm_script "$d" test && ! has_npm_script "$d" test:ci && ! has_npm_script "$d" build; then
    return
  fi
  if ! qk_have "$pm"; then note_not_run "Node project in '$d' but '$pm' is not installed"; return; fi
  if [ ! -d "$d/node_modules" ]; then note_not_run "Node project in '$d' has no node_modules; run '$pm install' (or 'npm ci') first"; return; fi
  if has_npm_script "$d" lint; then run_step "$pm lint ($d)" "$d" "$pm" run lint; fi
  if has_npm_script "$d" test:ci; then
    run_step "$pm test:ci ($d)" "$d" "$pm" run test:ci
  elif has_npm_script "$d" test; then
    case "$NPM_SCRIPT_BODY" in
      *"ng test"*) if [ "$pm" = npm ]; then run_step "$pm test ($d)" "$d" npm test -- --watch=false
                   else run_step "$pm test ($d)" "$d" "$pm" run test --watch=false; fi ;;
      *) run_step "$pm test ($d)" "$d" "$pm" run test ;;
    esac
  else
    note_not_run "No 'test' or 'test:ci' script in $d/package.json"
  fi
  if [ "$GATE_RUN_BUILD" = 1 ] && has_npm_script "$d" build; then run_step "$pm build ($d)" "$d" "$pm" run build; fi
}

gate_dir() {  # detect build systems in one directory
  d="$1"; found=0
  if [ -f "$d/pom.xml" ]; then gate_maven "$d"; found=1
  elif [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ]; then gate_gradle "$d"; found=1; fi
  if [ -f "$d/package.json" ]; then gate_node "$d"; found=1; fi
  [ "$found" = 1 ]
}

if [ -n "$GATE_CMD" ]; then
  run_step "custom gate (GATE_CMD)" "." sh -c "$GATE_CMD"
else
  detected=0
  if [ -n "$GATE_PROJECT_DIRS" ]; then
    for d in $GATE_PROJECT_DIRS; do
      if touched "$d"; then gate_dir "$d" && detected=1; else detected=1; fi
    done
  else
    gate_dir "." && detected=1
    for d in */; do
      d=${d%/}
      case "$d" in node_modules|target|build|dist|out|coverage|vendor|'*') continue ;; esac
      [ -d "$d" ] || continue
      # skip sub-builds already covered by a root build of the same kind (multi-module Maven etc.)
      if [ -f "$d/pom.xml" ] && [ -f pom.xml ]; then continue; fi
      if { [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ]; } && { [ -f build.gradle ] || [ -f build.gradle.kts ] || [ -f settings.gradle ] || [ -f settings.gradle.kts ]; }; then continue; fi
      # a root package.json with "workspaces" already runs the sub-packages' scripts
      if [ -f "$d/package.json" ] && [ -f package.json ] && grep -q '"workspaces"' package.json && [ ! -f "$d/pom.xml" ]; then continue; fi
      if [ -f "$d/pom.xml" ] || [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ] || [ -f "$d/package.json" ]; then
        detected=1
        touched "$d" && gate_dir "$d"
      fi
    done
  fi
  if [ "$detected" = 0 ]; then
    if [ -f Makefile ] && grep -q '^check:' Makefile; then
      run_step "make check" "." make check
    else
      note_not_run "No Maven, Gradle, npm or Makefile 'check' target found. Set GATE_CMD in .claude/hooks/quality.conf"
    fi
  fi
fi

# ---------------------------------------------------------------- duplicate API check
WARNINGS=""
TAMPER=""
warn() { WARNINGS="${WARNINGS}- $1
"; }
tamper() { TAMPER="${TAMPER}- $1
"; }
if [ "$API_DUP_MODE" != off ]; then
  if qk_have python3; then
    set -- python3 -I "$HOOK_DIR/api-dup-check.py" --root . --extra-words "$API_DUP_EXTRA_WORDS" --similarity "$API_DUP_SIMILARITY"
    if [ "$IN_GIT" = 1 ]; then set -- "$@" --base "$BASE"; else set -- "$@" --all; fi
    if [ "$API_DUP_MODE" = block ]; then
      run_step "duplicate API check (one API, many regions)" "." "$@"
    else
      dup_out=$("$@" 2>&1) || warn "Duplicate APIs found (API_DUP_MODE=warn):
$(printf '%s\n' "$dup_out" | sed -n '/^NEW findings/,/^existing/p' | grep -v '^existing' | head -n 30)"
    fi
  else
    note_not_run "Duplicate API check needs python3"
  fi
fi
set --

# ---------------------------------------------------------------- tamper and size checks (best effort)

count_re() {  # count_re REGEX < text
  grep -Ec -- "$1" 2>/dev/null || true
}

TEST_DECL_RE='@Test([^A-Za-z]|$)|@ParameterizedTest|@RepeatedTest|@TestFactory|(^|[^A-Za-z0-9_.])(it|test)[[:space:]]*\(|def test_|func Test[A-Z_]'
ASSERT_RE='assert[A-Za-z]*[[:space:]]*\(|assertThat|Assertions\.|expect[[:space:]]*\(|verify[[:space:]]*\(|\.should|(^|[[:space:]])assert[[:space:]]'
SKIP_RE='@Disabled|@Ignore([^A-Za-z]|$)|(^|[^A-Za-z0-9_])(xit|xdescribe|xtest|fit|fdescribe)[[:space:]]*\(|\.(skip|only)[[:space:]]*\(|@pytest\.mark\.skip|t\.Skip\(|assumeTrue\([[:space:]]*false'
TRIVIAL_RE='assertTrue\([[:space:]]*true[[:space:]]*\)|assertEquals\(([^,()]+),[[:space:]]*\1[[:space:]]*\)|expect\([[:space:]]*true[[:space:]]*\)\.toBe\([[:space:]]*true|assert[[:space:]]+True([[:space:]]|$)'
CONFIG_FILES_RE='(^|/)(pom\.xml|build\.gradle(\.kts)?|package\.json|angular\.json|karma\.conf\.[a-z]+|vitest\.config\.[a-z]+|jest\.config\.[a-z]+|lighthouserc[.a-z]*|\.lighthouserc[.a-z]*|stryker\.(conf|config)\.[a-z]+|sonar-project\.properties|eslint\.config\.[a-z]+|\.eslintrc[.a-z]*)$'
CONFIG_KEY_RE='minimum|threshold|[cC]overedRatio|haltOnFailure|failOnViolation|failOnError|failBuildOnCVSS|maximumError|maximumWarning|budget|skip|"break"|minScore|maxNumericValue|"off"|testFailureIgnore'

if [ "$IN_GIT" = 1 ] && [ -n "$CHANGED" ]; then
  TEST_FILES=$(printf '%s\n' "$CHANGED" | grep -E "$QK_TEST_PATH_RE" || true)

  deleted_tests=$(git diff --name-only --diff-filter=D "$BASE" -- 2>/dev/null | grep -E "$QK_TEST_PATH_RE" || true)
  if [ -n "$deleted_tests" ]; then
    tamper "Test files deleted: $(printf '%s' "$deleted_tests" | tr '\n' ' ')"
  fi

  if [ -n "$TEST_FILES" ]; then
    # shellcheck disable=SC2086
    tdiff=$(printf '%s\n' "$TEST_FILES" | tr '\n' '\0' | xargs -0 git diff -U0 "$BASE" -- 2>/dev/null)
    removed=$(printf '%s\n' "$tdiff" | grep -E '^-' | grep -Ev '^---' || true)
    added=$(printf '%s\n' "$tdiff" | grep -E '^\+' | grep -Ev '^\+\+\+' || true)
    # new, untracked test files count as added lines
    untracked_tests=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E "$QK_TEST_PATH_RE" || true)
    if [ -n "$untracked_tests" ]; then
      added_new=$(printf '%s\n' "$untracked_tests" | while IFS= read -r f; do [ -f "$f" ] && cat "$f"; done)
      added="$added
$added_new"
    fi
    rt=$(printf '%s\n' "$removed" | count_re "$TEST_DECL_RE"); at=$(printf '%s\n' "$added" | count_re "$TEST_DECL_RE")
    ra=$(printf '%s\n' "$removed" | count_re "$ASSERT_RE");    aa=$(printf '%s\n' "$added" | count_re "$ASSERT_RE")
    if [ "$rt" -gt "$at" ]; then tamper "Test count dropped: $rt test declarations removed, $at added (net -$((rt - at)))."; fi
    if [ "$ra" -gt "$aa" ]; then tamper "Assertions dropped: $ra assertion lines removed, $aa added (net -$((ra - aa)))."; fi
    skips=$(printf '%s\n' "$added" | grep -E -- "$SKIP_RE" | head -n 5 || true)
    if [ -n "$skips" ]; then tamper "Tests newly skipped/disabled/focused: $(printf '%s' "$skips" | sed 's/^[+[:space:]]*//' | tr '\n' ' ')"; fi
    trivial=$(printf '%s\n' "$added" | grep -E -- "$TRIVIAL_RE" | head -n 3 || true)
    if [ -n "$trivial" ]; then tamper "Trivially true assertions added: $(printf '%s' "$trivial" | sed 's/^[+[:space:]]*//' | tr '\n' ' ')"; fi
  fi

  CONFIG_CHANGED=$(printf '%s\n' "$CHANGED" | grep -E "$CONFIG_FILES_RE" || true)
  if [ -n "$CONFIG_CHANGED" ]; then
    cdiff=$(printf '%s\n' "$CONFIG_CHANGED" | tr '\n' '\0' | xargs -0 git diff -U0 "$BASE" -- 2>/dev/null | grep -E '^[-+]' | grep -Ev '^(---|\+\+\+)' | grep -E -- "$CONFIG_KEY_RE" | head -n 6 || true)
    if [ -n "$cdiff" ]; then
      tamper "Gate-related settings changed in build config ($(printf '%s' "$CONFIG_CHANGED" | tr '\n' ' ')): $(printf '%s' "$cdiff" | tr '\n' ' ' | cut -c1-400)"
    fi
  fi

  # diff size, ignoring lockfiles and generated/binary files
  diff_lines=$(git diff --numstat "$BASE" -- 2>/dev/null \
    | grep -Ev '(package-lock\.json|npm-shrinkwrap\.json|yarn\.lock|pnpm-lock\.yaml|\.lockfile|\.lock)$' \
    | awk '$1 != "-" { s += $1 + $2 } END { print s + 0 }')
  untracked_lines=$(git ls-files --others --exclude-standard 2>/dev/null \
    | grep -Ev '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|\.lock)$' \
    | while IFS= read -r f; do [ -f "$f" ] && grep -Iq . "$f" 2>/dev/null && wc -l < "$f"; done \
    | awk '{ s += $1 } END { print s + 0 }')
  DIFF_LINES=$((diff_lines + untracked_lines))
  if [ "$DIFF_LINES" -gt "$GATE_MAX_DIFF_LINES" ]; then
    warn "Change is $DIFF_LINES lines (limit $GATE_MAX_DIFF_LINES, lockfiles excluded). Split it into smaller self-contained changes, or explain why it cannot be split."
  fi
else
  DIFF_LINES="?"
fi

# ---------------------------------------------------------------- report
FAIL=0
printf '%s' "$RESULTS" | grep -q '^FAIL|' && FAIL=1
if [ "$GATE_TAMPER_MODE" = block ] && [ -n "$TAMPER" ]; then FAIL=1; fi
NOTHING_RAN=0
[ -z "$RESULTS" ] && NOTHING_RAN=1

n_changed=$(printf '%s\n' "$CHANGED" | sed '/^$/d' | wc -l | tr -d ' ')
REPORT=$(
  echo "AI quality gate report"
  echo "Repo: $PROJECT_DIR"
  if [ "$IN_GIT" = 1 ]; then
    echo "Compared with: $BASE_NAME (merge-base $(printf '%s' "$BASE" | cut -c1-10)), branch $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  fi
  echo "Changed files: $n_changed   Diff size: $DIFF_LINES lines (limit $GATE_MAX_DIFF_LINES)"
  echo "Checks:"
  if [ -n "$RESULTS" ]; then
    printf '%s' "$RESULTS" | awk -F'|' '{ printf "  [%s] %s: %s (%s)\n", $1, $2, $3, $4 }'
  else
    echo "  (no checks ran)"
  fi
  if [ -n "$NOT_RUN" ]; then echo "Could not run:"; printf '%s' "$NOT_RUN" | sed 's/^/  /'; fi
  if [ -n "$TAMPER" ]; then echo "Possible test or gate tampering (mode: $GATE_TAMPER_MODE):"; printf '%s' "$TAMPER" | sed 's/^/  /'; fi
  if [ -n "$WARNINGS" ]; then echo "Warnings:"; printf '%s' "$WARNINGS" | sed 's/^/  /'; fi
  if [ "$FAIL" = 1 ]; then echo "Result: FAIL"
  elif [ "$NOTHING_RAN" = 1 ]; then echo "Result: NOT VERIFIED (no checks ran)"
  else echo "Result: PASS"; fi
)

TAILS=""
for lf in $FAILED_LOGS; do
  TAILS="$TAILS
----- last $GATE_LOG_TAIL lines of $lf -----
$(tail -n "$GATE_LOG_TAIL" "$lf")"
done

printf '%s\n%s\n' "$REPORT" "$TAILS" > "$STATE_DIR/last-report.txt"
date '+%Y-%m-%d %H:%M:%S' > "$STATE_DIR/last-run"

record_pass() {
  if [ "$IN_GIT" = 1 ] && [ "$NOTHING_RAN" = 0 ] && [ -z "$NOT_RUN" ]; then
    printf '%s\n' "$FP" > "$STATE_DIR/last-pass"
  fi
}

GUIDANCE="Fix the root cause. Do not skip, delete, disable or weaken tests, assertions or gate configuration, and do not special-case test inputs. If a test itself is wrong, stop and explain why to the human instead of changing it."

if [ "$MODE" = manual ]; then
  printf '%s\n' "$REPORT"
  [ -n "$TAILS" ] && printf '%s\n' "$TAILS"
  if [ "$FAIL" = 1 ]; then exit 1; fi
  record_pass
  exit 0
fi

# hook mode
if [ "$FAIL" = 1 ]; then
  count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
  case "$count" in ''|*[!0-9]*) count=0 ;; esac
  echo $((count + 1)) > "$COUNTER_FILE"
  {
    printf '%s\n' "$REPORT"
    printf '%s\n' "$TAILS"
    printf '\n%s\n' "$GUIDANCE"
  } >&2
  exit 2
fi

rm -f "$COUNTER_FILE"
record_pass
if [ -n "$TAMPER" ] || [ -n "$WARNINGS" ] || [ -n "$NOT_RUN" ] || [ "$NOTHING_RAN" = 1 ]; then
  if [ -n "$NOT_RUN" ] || [ "$NOTHING_RAN" = 1 ]; then
    user_msg="AI quality gate: NOT VERIFIED - some checks could not run (see .git/ai-quality-kit/last-report.txt)."
  else
    user_msg="AI quality gate: checks passed with warnings (see .git/ai-quality-kit/last-report.txt)."
  fi
  qk_emit_json "Stop" "$REPORT

Tell the user about every item above in your reply. Do not describe the work as verified while any of them is open." "$user_msg"
else
  qk_emit_json "Stop" "" "AI quality gate: PASS ($(printf '%s' "$RESULTS" | grep -c '^PASS|') checks)."
fi
exit 0
