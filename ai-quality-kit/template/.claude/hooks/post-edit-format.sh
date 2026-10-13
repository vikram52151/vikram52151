#!/usr/bin/env bash
# post-edit-format.sh - Claude Code PostToolUse hook for Edit/Write/MultiEdit.
#
# Formats the file Claude just changed and lints it. Never blocks (always exits 0):
# the edit has already happened, so lint findings are handed back to Claude as
# additionalContext so it can fix them in its next step.
#
# Uses only tools already installed in the project (node_modules/.bin) or on PATH.
# It never downloads anything (no 'npx <package>' that could fetch an unknown package).
#   *.ts/js/html/css/scss/json/md/yml : prettier --write, then eslint (ts/js only)
#   *.java : google-java-format --replace (if on PATH)
#   *.kt   : ktlint -F (if on PATH)
#   *.py   : ruff format + ruff check (if on PATH)
#   *.go   : gofmt -w (if on PATH)
# Turn parts off in .claude/hooks/quality.conf: FORMAT_ON_EDIT=0, LINT_ON_EDIT=0

set -u
HOOK_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HOOK_DIR/lib.sh"

INPUT=$(cat)
qk_can_parse_json || exit 0

PROJECT_DIR=$(qk_project_dir)
qk_load_config "$PROJECT_DIR"
FORMAT_ON_EDIT="${FORMAT_ON_EDIT:-1}"
LINT_ON_EDIT="${LINT_ON_EDIT:-1}"

FILE=$(qk_json_get "$INPUT" '.tool_input.file_path')
[ -z "$FILE" ] && FILE=$(qk_json_get "$INPUT" '.tool_input.notebook_path')
[ -z "$FILE" ] && exit 0
case "$FILE" in /*) ;; *) FILE="$PROJECT_DIR/$FILE" ;; esac
[ -f "$FILE" ] || exit 0
case "$FILE" in "$PROJECT_DIR"/*) ;; *) exit 0 ;; esac   # only files inside the project
case "$FILE" in */node_modules/*|*/target/*|*/dist/*|*/build/*) exit 0 ;; esac

LINT_OUT=""

# nearest directory (walking up from the file) that has node_modules/.bin/<tool>
find_node_bin() {
  _dir=$(dirname "$FILE")
  while :; do
    if [ -x "$_dir/node_modules/.bin/$1" ]; then printf '%s\n' "$_dir"; return 0; fi
    if [ "$_dir" = "$PROJECT_DIR" ] || [ "$_dir" = "/" ]; then return 1; fi
    _dir=$(dirname "$_dir")
  done
}

ext=${FILE##*.}
case "$ext" in
  ts|tsx|js|jsx|mjs|cjs|html|css|scss|less|json|md|yml|yaml)
    if [ "$FORMAT_ON_EDIT" = 1 ] && root=$(find_node_bin prettier); then
      ( cd "$root" && node_modules/.bin/prettier --write "$FILE" ) >/dev/null 2>&1
    fi
    case "$ext" in
      ts|tsx|js|jsx|mjs|cjs)
        if [ "$LINT_ON_EDIT" = 1 ] && root=$(find_node_bin eslint); then
          out=$(cd "$root" && node_modules/.bin/eslint --no-color "$FILE" 2>&1)
          rc=$?
          # rc 1 = lint problems; rc 2 = eslint itself failed (config error, ignored file) - stay quiet
          [ "$rc" -eq 1 ] && LINT_OUT=$(printf '%s\n' "$out" | head -n 40)
        fi ;;
    esac ;;
  java)
    if [ "$FORMAT_ON_EDIT" = 1 ] && qk_have google-java-format; then
      google-java-format --replace "$FILE" >/dev/null 2>&1
    fi ;;
  kt|kts)
    if [ "$FORMAT_ON_EDIT" = 1 ] && qk_have ktlint; then
      out=$(ktlint -F "$FILE" 2>&1) || LINT_OUT=$(printf '%s\n' "$out" | head -n 40)
    fi ;;
  py)
    if qk_have ruff; then
      [ "$FORMAT_ON_EDIT" = 1 ] && ruff format "$FILE" >/dev/null 2>&1
      if [ "$LINT_ON_EDIT" = 1 ]; then
        out=$(ruff check "$FILE" 2>&1) || LINT_OUT=$(printf '%s\n' "$out" | head -n 40)
      fi
    fi ;;
  go)
    if [ "$FORMAT_ON_EDIT" = 1 ] && qk_have gofmt; then gofmt -w "$FILE" >/dev/null 2>&1; fi ;;
esac

if [ -n "$LINT_OUT" ]; then
  rel=${FILE#"$PROJECT_DIR"/}
  qk_emit_json "PostToolUse" "Lint findings in $rel after your edit. Fix them (do not disable the rule or add ignore comments unless you explain why):
$LINT_OUT" ""
fi
exit 0
