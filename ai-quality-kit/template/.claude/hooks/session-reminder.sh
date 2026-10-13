#!/usr/bin/env bash
# session-reminder.sh - Claude Code SessionStart hook (matcher "compact").
#
# After a context compaction, earlier conversation detail can be lost. The project-root CLAUDE.md
# is re-read automatically, but this hook also re-injects the short Definition of Done plus the
# current state of the work (changed files, diff size, last gate result). For SessionStart,
# plain stdout is added to Claude's context. Never blocks.

set -u
HOOK_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
. "$HOOK_DIR/lib.sh"

cat >/dev/null 2>&1   # consume the hook JSON; nothing in it is needed

PROJECT_DIR=$(qk_project_dir)
cd "$PROJECT_DIR" 2>/dev/null || exit 0
qk_load_config "$PROJECT_DIR"
LIMIT="${GATE_MAX_DIFF_LINES:-400}"

cat <<'EOF'
Reminder after compaction - Definition of Done (full version in CLAUDE.md):
1. One small, self-contained change (about 400 changed lines or less). Refactors go in a separate change.
2. Every behaviour change has tests in the same change. Every bug fix starts with a test that fails before the fix.
3. Never delete, skip, disable or weaken tests or assertions, and never edit CI, .claude/, lockfiles or gate config to get a pass.
4. Before saying "done": run `bash .claude/hooks/ai-gate.sh --manual` and paste its result, then run the quality-gate skill (reviewer subagents).
5. No new dependency without checking it exists, is maintained and is needed. Record requirement -> commit -> test in docs/FIXES.md.
EOF

if qk_in_git; then
  base=$(qk_base_rev)
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  files=$( { git diff --name-only "$base" -- 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | sort -u | sed '/^$/d')
  n=$(printf '%s\n' "$files" | sed '/^$/d' | wc -l | tr -d ' ')
  lines=$(git diff --numstat "$base" -- 2>/dev/null | awk '$1 != "-" { s += $1 + $2 } END { print s + 0 }')
  echo
  echo "Current state: branch $branch, $n changed file(s), about $lines changed lines in tracked files (limit $LIMIT)."
  if [ "$n" -gt 0 ]; then
    echo "Changed files:"
    printf '%s\n' "$files" | head -n 30 | sed 's/^/  /'
    [ "$n" -gt 30 ] && echo "  ... and $((n - 30)) more"
  fi
  state=$(qk_state_dir)
  if [ -f "$state/last-report.txt" ]; then
    result=$(grep -E '^Result:' "$state/last-report.txt" | tail -n 1)
    echo "Last gate run: $(cat "$state/last-run" 2>/dev/null) - ${result:-unknown}"
  else
    echo "The quality gate has not been run in this checkout yet."
  fi
fi
exit 0
