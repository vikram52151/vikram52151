# shellcheck shell=bash
# Shared helpers for the AI quality kit hooks.
# This file is sourced by the other scripts; it is not run on its own.
# Written for bash 3.2+ (macOS default) and Linux. No GNU-only flags.

qk_have() { command -v "$1" >/dev/null 2>&1; }

# True when we have something that can read JSON (jq preferred, python3 as fallback).
qk_can_parse_json() { qk_have jq || qk_have python3; }

# qk_json_get JSON PATH
# PATH is a simple dotted path such as .tool_input.file_path
# Prints the value, or nothing when the field is missing or null.
qk_json_get() {
  if qk_have jq; then
    printf '%s' "$1" | jq -r "$2 // empty" 2>/dev/null
  elif qk_have python3; then
    printf '%s' "$1" | python3 -I -c '
import json, sys
path = [p for p in sys.argv[1].lstrip(".").split(".") if p]
try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)
for k in path:
    if isinstance(d, dict) and k in d:
        d = d[k]
    else:
        sys.exit(0)
if d is None:
    sys.exit(0)
if isinstance(d, bool):
    print("true" if d else "false")
elif isinstance(d, (dict, list)):
    print(json.dumps(d))
else:
    print(d)
' "$2" 2>/dev/null
  fi
}

# qk_emit_json EVENT CONTEXT_FOR_CLAUDE MESSAGE_FOR_USER
# Prints one JSON object on stdout. Either text may be empty.
# additionalContext is capped at 10,000 characters by Claude Code, so we trim to 9,000.
qk_emit_json() {
  _ev="$1"; _ctx="$2"; _sys="$3"
  _ctx=$(printf '%s' "$_ctx" | head -c 9000)
  if qk_have jq; then
    jq -nc --arg ev "$_ev" --arg ctx "$_ctx" --arg sys "$_sys" '
      (if $ctx != "" then {hookSpecificOutput: {hookEventName: $ev, additionalContext: $ctx}} else {} end)
      + (if $sys != "" then {systemMessage: $sys} else {} end)'
  elif qk_have python3; then
    python3 -I -c '
import json, sys
ev, ctx, sysmsg = sys.argv[1], sys.argv[2], sys.argv[3]
out = {}
if ctx:
    out["hookSpecificOutput"] = {"hookEventName": ev, "additionalContext": ctx}
if sysmsg:
    out["systemMessage"] = sysmsg
print(json.dumps(out))
' "$_ev" "$_ctx" "$_sys"
  fi
}

# Project root: CLAUDE_PROJECT_DIR (set by Claude Code for hooks), else git top level, else cwd.
qk_project_dir() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}" ]; then
    printf '%s\n' "$CLAUDE_PROJECT_DIR"
  elif git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    pwd
  fi
}

# Optional per-repo overrides live in .claude/hooks/quality.conf (shell variable assignments).
qk_load_config() {
  _conf="${1:-.}/.claude/hooks/quality.conf"
  if [ -f "$_conf" ]; then
    # shellcheck disable=SC1090
    . "$_conf"
  fi
}

qk_in_git() { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }

# Name of the ref we compare against (for display).
qk_base_ref_name() {
  if [ -n "${GATE_BASE_REF:-}" ]; then printf '%s\n' "$GATE_BASE_REF"; return; fi
  for _r in origin/HEAD origin/main origin/master main master; do
    if git rev-parse --verify -q "${_r}^{commit}" >/dev/null 2>&1; then
      printf '%s\n' "$_r"; return
    fi
  done
  printf '%s\n' "HEAD"
}

# Commit to diff against: merge-base of HEAD and the base ref, so committed and
# uncommitted work on a branch are both covered. Falls back to HEAD, then to the
# empty tree for a repo with no commits.
qk_base_rev() {
  _ref=$(qk_base_ref_name)
  _mb=$(git merge-base HEAD "$_ref" 2>/dev/null)
  if [ -n "$_mb" ]; then printf '%s\n' "$_mb"; return; fi
  if git rev-parse --verify -q HEAD >/dev/null 2>&1; then git rev-parse HEAD; return; fi
  printf '%s\n' "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
}

# Where the gate keeps its small state files (inside .git so they are never committed).
qk_state_dir() {
  if qk_in_git; then
    _gd=$(git rev-parse --absolute-git-dir 2>/dev/null || git rev-parse --git-dir)
    _sd="$_gd/ai-quality-kit"
  else
    _sd="${TMPDIR:-/tmp}/ai-quality-kit-$(printf '%s' "$PWD" | cksum | cut -d' ' -f1)"
  fi
  mkdir -p "$_sd" 2>/dev/null
  printf '%s\n' "$_sd"
}

# Regular expression (ERE) for test file paths. Used by protect-files.sh and ai-gate.sh.
# shellcheck disable=SC2034
QK_TEST_PATH_RE='(^|/)(src/test|test|tests|__tests__|spec|e2e)/|[A-Za-z0-9_]+(Test|Tests|IT|Spec)\.(java|kt|groovy|scala)$|\.(spec|test)\.(ts|tsx|js|jsx|mjs|cjs)$|(^|/)test_[^/]*\.py$|_test\.(py|go)$'
