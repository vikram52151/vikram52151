# Making Claude Code Reliably Follow a Team's Quality Steps (CLAUDE.md, subagents, hooks, skills, permissions, CI)

Research date: 2026-10-13. Primary sources are the official Claude Code docs at code.claude.com/docs/en/* as fetched today. Version numbers quoted (e.g. "v2.1.283") come from those pages. docs.github.com and agents.md were blocked by the network proxy in this session, so the GitHub and AGENTS.md findings rely on search-result summaries of those pages, and I flag them as such.

**Overall layering, from the docs.** Instructions (CLAUDE.md, rules, skills) are advisory context. Hooks and permission rules are deterministic, enforced by the client. Managed settings are org-level and can't be overridden. In CI, GitHub required status checks and rulesets are the layer the agent can't bypass. The Claude Code Review product itself never blocks a merge (its check run always completes "neutral").

---

## 1. CLAUDE.md: locations, loading, writing guidance, limits

### Takeaway
CLAUDE.md is loaded every session as context, delivered as a user message after the system prompt. It is not enforced configuration. Keep it under about 200 lines, specific and verifiable, and move anything that must happen every time into hooks or permissions. The project-root CLAUDE.md is re-read after compaction. Nested and path-scoped rules reload only on demand.

### Cited Findings
- **Not enforced:** "Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead." — [Memory docs](https://code.claude.com/docs/en/memory)
- **Delivery mechanism:** "CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself. Claude reads it and tries to follow it, but there's no guarantee of strict compliance, especially for vague or conflicting instructions." For system-prompt-level instructions, use `--append-system-prompt`, which is better suited to scripts and automation. — [Memory docs](https://code.claude.com/docs/en/memory)
- **Locations, in load order from broadest to most specific:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - Managed policy:
    - macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
    - Linux and WSL: `/etc/claude-code/CLAUDE.md`
    - Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`
    - This file "cannot be excluded by individual settings."
  - User: `~/.claude/CLAUDE.md`
  - Project: `./CLAUDE.md` or `./.claude/CLAUDE.md`
  - Local: `./CLAUDE.local.md`. Personal; add it to `.gitignore`.
  - Managed content can also be inlined with the `claudeMd` key in `managed-settings.json`, for example `{"claudeMd": "Always run \`make lint\` before committing.\nNever push directly to main."}`. This key is honored only in managed or policy settings.
- **Loading:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - Files in the cwd and every ancestor directory load at launch.
  - "All discovered files are concatenated into context rather than overriding each other," ordered from the filesystem root down to the cwd. `CLAUDE.local.md` is appended after `CLAUDE.md` at each level.
  - Subdirectory CLAUDE.md files load on demand, once Claude reads, writes or edits a file in that subdirectory.
  - Block-level HTML comments `<!-- ... -->` are stripped before injection.
  - Files over 4 MiB are skipped.
  - `claudeMdExcludes` skips ancestor files in monorepos.
- **Imports:** `@path/to/import` syntax. Relative paths resolve from the importing file. "Imported files can recursively import other files, with a maximum depth of four hops." — [Memory docs](https://code.claude.com/docs/en/memory)
  - Imports inside code spans or fences are ignored.
  - External imports (outside the working directory) trigger a one-time approval dialog in project files.
  - Imports help organize a file but "don't reduce its context cost, because imported files also load at launch."
- **`.claude/rules/` and path-scoped rules:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - All `.md` files are discovered recursively.
  - A rule without `paths` loads at launch with the same priority as `.claude/CLAUDE.md`.
  - `paths` is the only frontmatter field read. A rule with `paths` loads when Claude Reads, Writes or Edits a matching file, or `cat`s it. Example:
    ```markdown
    ---
    paths:
      - "src/api/**/*.ts"
    ---
    # API Development Rules
    - All API endpoints must include input validation
    - Use the standard error response format
    - Include OpenAPI documentation comments
    ```
  - User-level rules live in `~/.claude/rules/`.
- **Writing guidance:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - "Write instructions that are concrete enough to verify":
    - "Use 2-space indentation" rather than "Format code properly"
    - "Run `npm test` before committing" rather than "Test your changes"
  - "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."
  - "If two instructions contradict each other, Claude may pick one arbitrarily."
  - `/doctor prompt-audit` (v2.1.283+) audits instruction files for stale or conflicting content.
- **Best-practices guidance:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions!"
  - Include:
    - Bash commands Claude can't guess
    - Style rules that differ from defaults
    - Testing instructions and preferred test runners
    - Repo etiquette
    - Architectural decisions
    - Environment quirks
    - Gotchas
  - Exclude:
    - Anything Claude can derive from the code
    - Standard conventions
    - Detailed API docs
    - Info that changes frequently
    - Tutorials
    - File-by-file descriptions
    - "Self-evident practices like 'write clean code'"
- **Emphasis:** "If Claude keeps skipping one instruction, add emphasis such as 'IMPORTANT' to that line alone. If you emphasize many lines, none of them stands out." — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Escalation path:** "If Claude already does something correctly without the instruction, delete it or convert it to a hook." Also: "Unlike CLAUDE.md instructions which are advisory, hooks are deterministic and guarantee the action happens." — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Compaction:** "Project-root CLAUDE.md survives compaction: after `/compact`, Claude re-reads it from disk and re-injects it into the session. Nested CLAUDE.md files in subdirectories and rules with `paths:` frontmatter load again on demand." Instructions given only in conversation can be lost. — [Memory docs](https://code.claude.com/docs/en/memory)
  - Best practices adds: customize compaction via CLAUDE.md, e.g. "When compacting, always preserve the full list of modified files and any test commands." — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Org split, from the memory docs table:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - Managed settings: "Block specific tools, commands, or file paths → `permissions.deny`" and "Enforce sandbox isolation → `sandbox.enabled`".
  - Managed CLAUDE.md: code style, quality guidelines and behavioral instructions.
  - "Settings rules are enforced by the client regardless of what Claude decides to do. CLAUDE.md instructions shape Claude's behavior but are not a hard enforcement layer."
- **Debugging:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - `/context` lists loaded "Memory files".
  - `/memory` opens and edits them.
  - The `InstructionsLoaded` hook logs which files load and why.
  - `includeGitInstructions` turns off built-in commit/PR guidance that may compete with your own rules.
- **Bootstrapping:** `/init` generates a starter CLAUDE.md. `CLAUDE_CODE_NEW_INIT=1` gives an interactive flow that can also propose skills and hooks. — [Memory docs](https://code.claude.com/docs/en/memory)

### Inferences
- A "quality guardian" CLAUDE.md should hold:
  - The exact commands (`make lint`, `npm test -- <file>`)
  - The definition of done
  - Protected areas, stated only as rationale
  - One or two IMPORTANT lines
- The actual protection belongs in permission deny rules and PreToolUse hooks. The "run tests before finishing" step belongs in a Stop hook.
- Put critical, path-specific conventions in `.claude/rules/*.md` with `paths`, so the top-level file stays short.

### Gaps
- No official quantitative adherence data (e.g. compliance rate versus file length) was found. The 200-line figure is guidance, not a measured threshold.

---

## 2. Subagents: files, frontmatter, delegation, read-only reviewers

### Takeaway
Subagents are Markdown files with YAML frontmatter in `.claude/agents/` (project) or `~/.claude/agents/` (user). Each runs in its own context window with a restricted tool list. A read-only reviewer or verifier (`tools: Read, Grep, Glob`) gives an independent second opinion that never sees the implementer's reasoning.

### Cited Findings
- **Locations and priority** (highest first): — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  1. Managed settings
  2. `--agents` CLI JSON
  3. `.claude/agents/`
  4. `~/.claude/agents/`
  5. A plugin's `agents/`
  - Directories are scanned recursively. Identity comes from `name`, not the path.
- **Frontmatter:** only `name` and `description` are required. Field names are case-sensitive, and unknown fields are silently ignored. — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)

  | Field | Notes |
  | :- | :- |
  | `name` | At most 256 characters; no `:` |
  | `description` | When Claude should delegate to this subagent |
  | `tools` | Comma string or YAML list; inherits all tools if omitted |
  | `disallowedTools` | Removed from the inherited or specified list |
  | `model` | `sonnet`, `opus`, `haiku`, `fable`, a full model ID, or `inherit` |
  | `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`, or `manual` |
  | `maxTurns` | Maximum agentic turns |
  | `skills` | Full content preloaded at startup |
  | `mcpServers` | By name reference or inline definition |
  | `hooks` | Scoped to this subagent |
  | `memory` | `user`, `project`, or `local` |
  | `background` | `true` keeps it in the background |
  | `omitClaudeMd` | `true` skips user, project and local CLAUDE.md |
  | `effort` | Effort level |
  | `isolation` | `worktree` runs it in a temporary git worktree |
  | `color` | Display color |
  | `initialPrompt` | First turn when run as the main session agent |
  | `experimental.cacheTtl` | `5m` or `1h` |

- **Official example** (`.claude/agents/code-reviewer.md`): — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  ```markdown
  ---
  name: code-reviewer
  description: Reviews code for quality and best practices
  tools: Read, Glob, Grep
  model: sonnet
  ---

  You are a code reviewer. When invoked, analyze the code and provide
  specific, actionable feedback on quality, security, and best practices.
  ```
  - The body becomes the system prompt. "Subagents receive only that prompt plus basic environment details, not the Claude Code system prompt."
- **Security reviewer example:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  ```markdown
  ---
  name: security-reviewer
  description: Reviews code for security vulnerabilities
  tools: Read, Grep, Glob, Bash
  model: opus
  ---
  You are a senior security engineer. Review code for:
  - Injection vulnerabilities (SQL, XSS, command injection)
  - Authentication and authorization flaws
  - Secrets or credentials in code
  - Insecure data handling

  Provide specific line references and suggested fixes.
  ```
- **CLI-defined (session-only) example:** — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  ```bash
  claude --agents '{"code-reviewer":{"description":"Expert code reviewer. Use proactively after code changes.","prompt":"You are a senior code reviewer. Focus on code quality, security, and best practices.","tools":["Read","Grep","Glob","Bash"],"model":"sonnet"}}'
  ```
- **Delegation:** — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  - Claude delegates based on the task, the `description` field and current context.
  - "To encourage proactive delegation, include phrases like 'use proactively' in your subagent's description field."
  - Explicit invocation works too ("Use the test-runner subagent…"), as does an @-mention or `claude --agent code-reviewer` for a whole session.
  - A startup warning appears when combined custom descriptions exceed 15,000 tokens.
- **Context isolation:** — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  - "Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions."
  - Its initial context is: its system prompt, the delegation message, CLAUDE.md files, a git status snapshot and preloaded skills.
  - "Only the summary returns to your main conversation."
- **Built-in subagents:** — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  - Explore: read-only; Write and Edit denied.
  - Plan: read-only.
  - general-purpose: all tools.
  - Explore and Plan skip CLAUDE.md.
- **Nesting:** subagents can spawn subagents up to 3 levels deep by default (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `1` disables nesting). To stop a subagent spawning others, omit `Agent` from its `tools`. — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
- **Hooks in frontmatter:** — [Sub-agents docs](https://code.claude.com/docs/en/sub-agents)
  - They run only while the subagent is active.
  - `Stop` in frontmatter becomes `SubagentStop` at runtime.
  - In settings.json, `SubagentStart` and `SubagentStop` matchers name the agent type.
  - Project-agent frontmatter hooks run only after the folder is trusted.
  - Plugin subagents ignore `hooks`, `mcpServers` and `permissionMode`.
- **Adversarial review step:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - "Before treating a task as done, have a subagent review the diff in a fresh context and report gaps."
  - "A reviewer running in a fresh subagent context sees only the diff and the criteria you give it, not the reasoning that produced the change."
  - Caveat: "A reviewer prompted to find gaps will usually report some, even when the work is sound… Tell the reviewer to flag only gaps that affect correctness or the stated requirements."
  - Example prompt: "Use a subagent to review the rate limiter diff against PLAN.md. Check that every requirement is implemented, the listed edge cases have tests, and nothing outside the task's scope changed. Report gaps, not style preferences."
- **Bundled `/code-review`:** reviews the current diff for bugs in a background subagent with its own context. Flags: `--fix`, `--comment`, `--max-findings`. It follows CLAUDE.md but not REVIEW.md. — [Code Review docs](https://code.claude.com/docs/en/code-review)

### Inferences
- For a verifier, give `tools: Read, Grep, Glob, Bash` and add `disallowedTools: Edit, Write`, or use `permissionMode: plan`. It can then run tests but not "fix" by weakening them.
- Use `model: opus` or a high `effort` for the reviewer, and require a structured verdict such as `PASS` / `FAIL` with file:line evidence.
- `disallowedTools` is a documented field. Combining it with Bash, though, still lets shell commands write files. Bash deny rules or a PreToolUse hook scoped in the agent's `hooks` close that gap. This is my synthesis, not a quoted recommendation.

### Gaps
- The docs don't publish a canonical "verifier" agent file beyond code-reviewer and security-reviewer.
- The page was truncated at 100k characters, so the last ~8k characters (persistent memory details, worktree isolation specifics) weren't read.

---

## 3. Hooks: events, config format, I/O, exit codes, quality-gate patterns

### Takeaway
Hooks are the deterministic enforcement layer.
- PreToolUse can deny edits to protected files or block dangerous commands, even in bypassPermissions mode.
- PostToolUse runs formatters and linters and feeds results back.
- A Stop hook (`decision: "block"` or exit 2) forces Claude to keep working until tests and lint pass. Guard it with `stop_hook_active`; there is a built-in cap of 8 consecutive blocks.
- Use `exit 2`, not `exit 1`, to enforce policy.

### Cited Findings
- **Events, and which can block:** — [Hooks reference](https://code.claude.com/docs/en/hooks)

  | Event | Can block? |
  | :- | :- |
  | `SessionStart` | No |
  | `Setup` | No |
  | `UserPromptSubmit` | Yes |
  | `UserPromptExpansion` | Yes |
  | `PreToolUse` | Yes |
  | `PermissionRequest` | Via `decision` object |
  | `PermissionDenied` | No |
  | `PostToolUse` | No; the tool already ran, but `decision: block` feeds back a reason |
  | `PostToolUseFailure` | No |
  | `PostToolBatch` | Yes |
  | `Notification` | No |
  | `MessageDisplay` | No |
  | `SubagentStart` / `SubagentStop` | Stop can block |
  | `TaskCreated` / `TaskCompleted` | Yes |
  | `Stop` | Yes; keeps Claude working |
  | `StopFailure` | No |
  | `TeammateIdle` | Yes |
  | `InstructionsLoaded` | No |
  | `ConfigChange` | Yes, except `policy_settings` |
  | `CwdChanged` | No |
  | `DirectoryAdded` | No |
  | `FileChanged` | No |
  | `WorktreeCreate` / `WorktreeRemove` | Any non-zero exit fails the operation |
  | `PreCompact` / `PostCompact` | Pre can block |
  | `PreModelSwitch` / `PostModelSwitch` | Pre can block |
  | `Elicitation` / `ElicitationResult` | Yes |
  | `SessionEnd` | No |

- **Config format:** three levels (event → matcher group → handlers). Verbatim example: — [Hooks reference](https://code.claude.com/docs/en/hooks)
  ```json
  {
    "hooks": {
      "PreToolUse": [
        {
          "matcher": "Bash",
          "hooks": [
            {
              "type": "command",
              "if": "Bash(rm *)",
              "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh",
              "args": []
            }
          ]
        }
      ]
    }
  }
  ```
  - `args` selects exec form, with no shell interpretation. It is recommended for path placeholders.
  - `if` uses permission-rule syntax and is "best-effort". Use the permission system for hard allow/deny.
- **Matchers:** — [Hooks reference](https://code.claude.com/docs/en/hooks); [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  - `"*"`, `""` or omitted matches all.
  - Strings of only letters, digits, `_ - , |` and spaces are exact names or lists (`Edit|Write`).
  - Anything else is an unanchored JS regex (`mcp__memory__.*`).
  - Matchers are case-sensitive.
  - What the matcher filters, by event:
    - Tool events: tool name
    - `SessionStart`: `startup`, `resume`, `clear`, `compact`, `fork`
    - `PreCompact` / `PostCompact`: `manual`, `auto`
    - `SubagentStart` / `SubagentStop`: agent type
    - `ConfigChange`: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`
    - `Notification`: e.g. `permission_prompt`, `idle_prompt`
- **Handler types:** — [Hooks reference](https://code.claude.com/docs/en/hooks); [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  - `command`
  - `http`: POSTs the JSON
  - `mcp_tool`
  - `prompt`: single LLM call; default timeout 30s
  - `agent`: subagent with tools; experimental; default 60s, up to 50 tool-use turns
  - Default timeout for command, http and mcp_tool is 600s (10 min). It drops to 30s for `UserPromptSubmit` and model-switch events.
  - Override per hook with `timeout` (seconds).
  - `async: true` runs in the background; results are delivered on the next turn.
- **Hook locations** (they merge rather than replace each other): — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - `~/.claude/settings.json`
  - `.claude/settings.json` (shareable)
  - `.claude/settings.local.json`
  - Managed policy settings
  - Plugin `hooks/hooks.json`
  - Skill frontmatter (active after the skill is invoked)
  - Subagent frontmatter (active while it runs)
- **Common stdin fields:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - `session_id`, `prompt_id`, `transcript_path`, `cwd`, `scratchpad_dir`, `permission_mode`, `effort`, `hook_event_name`
  - `agent_id` and `agent_type` when relevant
  - Tool events add `tool_name`, `tool_input` and `tool_use_id`. Example:
    ```json
    {"session_id":"abc123","cwd":"/home/user/my-project","permission_mode":"default","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"npm test","description":"Run test suite","timeout":120000,"run_in_background":false},"tool_use_id":"toolu_01ABC123..."}
    ```
- **Stop input and loop guard:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - Stop hooks receive `stop_hook_active`, `last_assistant_message`, `background_tasks` and `session_crons`.
  - "The `stop_hook_active` field is `true` when Claude Code is already continuing as a result of a stop hook. Check this value or process the transcript to avoid blocking on a condition that will never resolve."
  - "Claude Code applies an 8-consecutive-continuation cap… The count of consecutive continuations resets each time Claude calls a tool. To raise the cap, set `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`."
  - Guard snippet: — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
    ```bash
    #!/bin/bash
    INPUT=$(cat)
    if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
      exit 0  # Allow Claude to stop
    fi
    # ... rest of your hook logic
    ```
- **Exit codes:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - **0**: success. Stdout is parsed as JSON if it is a single JSON object. Plain stdout is added to context only for `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart` and `PostModelSwitch`.
  - **2**: blocking error. Stderr is the reason fed to Claude, and JSON cannot override the block. On PostToolUse, stderr is shown to Claude because the tool already ran.
  - **Other codes**: non-blocking. The action proceeds. "If your hook is meant to enforce a policy, use `exit 2`."
- **JSON output fields:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - Universal:
    - `continue` (false stops Claude entirely)
    - `stopReason`
    - `suppressOutput` (documented as having no effect)
    - `systemMessage`
    - `terminalSequence`
  - Top-level `decision: "block"` plus `reason`, for UserPromptSubmit, PostToolUse, Stop, SubagentStop and ConfigChange.
  - `hookSpecificOutput` (requires `hookEventName`):
    - PreToolUse: `permissionDecision` (`allow`, `deny`, `ask`, `defer`), `permissionDecisionReason`, `updatedInput`, `additionalContext`
    - PermissionRequest: `decision.behavior`
    - PostToolUse: `updatedToolOutput`
  - `additionalContext` is capped at 10,000 characters and injected as a system reminder.
  - Precedence among multiple PreToolUse hooks: `deny > defer > ask > allow`. Exit 2 is routed like deny.
- **PreToolUse JSON example:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"My reason here","updatedInput":{"field_to_modify":"new value"},"additionalContext":"Current environment: production. Proceed with caution."}}
  ```
- **Stop block example:** `{"decision": "block", "reason": "Must be provided when Claude is blocked from stopping"}`. A softer alternative: `{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"Please run the test suite before finishing"}}`. — [Hooks reference](https://code.claude.com/docs/en/hooks)
- **Permission-mode interaction:** — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  - "`PreToolUse` hooks fire before any permission-mode check, in every permission mode… A hook that returns `permissionDecision: "deny"` blocks the tool even in `bypassPermissions` mode or with `--dangerously-skip-permissions`."
  - Conversely, a hook `"allow"` doesn't bypass settings deny rules. Hooks "can tighten restrictions but not loosen them past what permission rules allow."
  - Exception: an installed "mod" handling `tool.check` can override a non-managed PreToolUse block.
- **Protect files** (verbatim `.claude/hooks/protect-files.sh`): — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  ```bash
  #!/bin/bash
  INPUT=$(cat)
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  FILE_PATH="${FILE_PATH//\\//}"
  PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")
  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$FILE_PATH" == *"$pattern"* ]]; then
      echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
      exit 2
    fi
  done
  exit 0
  ```
  Registered with:
  ```json
  {"hooks":{"PreToolUse":[{"matcher":"Edit|Write","hooks":[{"type":"command","command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"}]}]}}
  ```
  The script must be `chmod +x`.
- **Auto-format after edits:** — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  ```json
  {"hooks":{"PostToolUse":[{"matcher":"Edit|Write","hooks":[{"type":"command","command":"jq -r '.tool_input.file_path' | xargs npx prettier --write"}]}]}}
  ```
  The guide also notes: "Claude can also create or modify files by running shell commands. If your hook must see every file change… add a `Stop` hook that scans the working tree once per turn," or match `Bash|PowerShell` and use `git status --porcelain`.
- **Async test runner on edits:** the script runs `npm test` and returns `jq -nc --arg msg "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'`, configured with `"async": true`. — [Hooks reference](https://code.claude.com/docs/en/hooks)
- **Re-inject context after compaction:** a `SessionStart` hook with matcher `"compact"` whose stdout (e.g. `echo 'Reminder: use Bun, not npm. Run bun test before committing…'`) is added to context. — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
- **PreCompact:** matchers `manual` and `auto`. Exit 2 or `decision: block` blocks compaction. Input includes `trigger` and `custom_instructions`. — [Hooks reference](https://code.claude.com/docs/en/hooks)
- **Prompt and agent Stop hooks:** — [Hooks reference](https://code.claude.com/docs/en/hooks); [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  - The model returns `{"ok": true|false, "reason": "...", "impossible": true|false}`.
  - On Stop with `ok: false`, the reason becomes Claude's next instruction, unless `impossible: true`.
  - Prompt hook fields: `type`, `prompt` (with `$ARGUMENTS`), `model`, `timeout`, `continueOnBlock`.
  - Agent hook verbatim example:
    ```json
    {"hooks":{"Stop":[{"hooks":[{"type":"agent","prompt":"Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS","timeout":120}]}]}}
    ```
    Agent hooks are labeled "experimental… For production workflows, prefer command hooks."
- **Limits:** — [Hooks guide](https://code.claude.com/docs/en/hooks-guide); [Hooks reference](https://code.claude.com/docs/en/hooks)
  - "`Stop` hooks fire whenever Claude finishes responding, not only at task completion. They don't fire on user interrupts."
  - PostToolUse can't undo actions.
  - Multiple `updatedInput` writers are non-deterministic.
  - A timed-out command or http hook doesn't block unless `onFailure: "block"` is set. "Hooks are not a hard gate" in that sense.
- **Security:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - "Command hooks execute shell commands with your full user permissions."
  - Interactive sessions hold back settings-file hooks until workspace trust is accepted. However, "`-p` or SDK session: Claude Code never shows the dialog and treats the folder as trusted, so hooks committed in a repository's `.claude/settings.json` run in a folder you've never trusted."
  - Mitigations: `--bare` or `--settings '{"disableAllHooks": true}'`.
  - Best practices: validate inputs, quote `"$VAR"`, block `..` traversal, use absolute paths or `${CLAUDE_PROJECT_DIR}`, skip `.env` and `.git/`.
- **Managed controls:** — [Hooks reference](https://code.claude.com/docs/en/hooks)
  - `allowManagedHooksOnly` (managed settings) blocks user, project, local and plugin hooks.
  - `disableAllHooks` can't disable managed hooks from outside managed settings.
  - `allowedHttpHookUrls` and `httpHookAllowedEnvVars` restrict HTTP hooks.
- **Debugging:** — [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
  - `/hooks` lists configured hooks.
  - Test a script by hand: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh; echo $?`.
  - Shell-profile `echo` output before the JSON breaks parsing.
  - `permissionDecision` must sit inside `hookSpecificOutput`.

### Inferences
**Recommended "quality gate" Stop hook.** This is my composition from the documented primitives, not a quoted doc example:
- Read stdin.
- If `stop_hook_active` is true, exit 0 (or allow a bounded number of retries by inspecting the transcript).
- Run `make lint test` with output captured.
- On failure, print a trimmed tail of the output to stderr and `exit 2`, or emit `{"decision":"block","reason":"<failures>"}`.
- Pair it with `"timeout"` sized to the test suite.
- Because Stop fires on every turn end, skip the check when `git diff --quiet` shows no changes.

**PreToolUse guard for "don't weaken the quality bar".** Again my synthesis:
- Match `Edit|Write`.
- Deny edits to:
  - `.github/workflows/**`, `.claude/settings.json`, `.claude/hooks/**`
  - Lockfiles
  - Lint configs (`.eslintrc*`, `pyproject.toml [tool.ruff]`)
  - Existing test files, optionally
- Return `permissionDecision: "deny"` with a reason telling Claude to ask the human.
- Match `Bash` to deny:
  - `git push --force`
  - `git commit --no-verify`
  - `rm -rf`
  - `--no-verify` and skip flags such as `pytest -k 'not ...'`
- Because Bash rules and hooks match command text, also back these with CI and branch protection.

Put these hooks in `.claude/settings.json` (committed). Put them in managed settings, with `allowManagedHooksOnly`, if developers mustn't be able to disable them.

### Gaps
- The full `onFailure` field definition and the PostToolBatch/TaskCompleted schemas were only partially read; the hooks page is 268k characters.
- No official numbers on hook reliability or overhead were found.

---

## 4. Skills, slash commands, plugins, permissions and managed settings

### Takeaway
- Skills (`.claude/skills/<name>/SKILL.md`) package on-demand procedures, such as a `/verify` or `/pre-commit-check` workflow. Custom slash commands (`.claude/commands/*.md`) are now merged into skills.
- Permission rules (`allow`/`ask`/`deny` in settings.json) are client-enforced. Evaluation order is deny → ask → allow, and a deny at any level wins.
- Managed settings sit at the top of precedence and can lock out bypass mode, non-managed hooks and non-managed permission rules.

### Cited Findings
- **Skill locations:** — [Skills docs](https://code.claude.com/docs/en/skills)
  - Enterprise (managed settings dir)
  - Personal: `~/.claude/skills/<name>/SKILL.md`
  - Project: `.claude/skills/<name>/SKILL.md`
  - Nested: `<subdir>/.claude/skills/`
  - Plugin: `<plugin>/skills/`, namespaced `/plugin:skill`
  - Precedence: "Enterprise over personal, and personal over project."
- **Commands merged into skills:** "A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way." A skill beats a command file of the same name. — [Skills docs](https://code.claude.com/docs/en/skills)
- **SKILL.md frontmatter** (all optional; `description` recommended): — [Skills docs](https://code.claude.com/docs/en/skills)
  - `name`, `description`, `when_to_use`, `argument-hint`, `arguments`
  - `disable-model-invocation` (true means manual-only)
  - `user-invocable` (false hides it from the `/` menu)
  - `allowed-tools` (pre-approved during the invoking turn), `disallowed-tools`
  - `model`, `effort`
  - `context: fork` (run in a subagent) and `agent`, `background`
  - `hooks`, `paths`, `shell`
  - Description plus `when_to_use` is truncated at 1,536 characters in the listing.
- **Loading:** — [Skills docs](https://code.claude.com/docs/en/skills)
  - "skill descriptions are loaded into context… but full skill content only loads when invoked."
  - After compaction, invoked skills are re-attached, keeping "the first 5,000 tokens of each" within a 25,000-token budget.
  - Keep SKILL.md under 500 lines.
- **Dynamic context:** — [Skills docs](https://code.claude.com/docs/en/skills)
  - `` !`git diff HEAD` `` runs before Claude sees the content.
  - Placeholders: `$ARGUMENTS`, `$0`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`.
- **Workflow skill example:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  ```markdown
  ---
  name: fix-issue
  description: Fix a GitHub issue
  disable-model-invocation: true
  ---
  Analyze and fix the GitHub issue: $ARGUMENTS.
  1. Use `gh issue view` to get the issue details
  ...
  5. Write and run tests to verify the fix
  6. Ensure code passes linting and type checking
  7. Create a descriptive commit message
  8. Push and create a PR
  ```
  "Use `disable-model-invocation: true` for workflows with side effects that you want to trigger manually."
- **Bundled skills:** — [Skills docs](https://code.claude.com/docs/en/skills)
  - Includes `/doctor`, `/code-review`, `/batch`, `/debug`, `/loop`, `/claude-api` and `/verify`, plus `/simplify`.
  - "a project skill named `verify` or `simplify` makes Claude run it before each commit (Claude Code v2.1.286 or later)". This is a direct hook for team quality steps. It was paraphrased by the fetch tool, so verify the exact wording.
  - `skillOverrides` (e.g. `{"code-review": "user-invocable-only"}`) controls model invocation. — [Code Review docs](https://code.claude.com/docs/en/code-review)
- **Plugins:** — [Best practices](https://code.claude.com/docs/en/best-practices); [Hooks reference](https://code.claude.com/docs/en/hooks)
  - "Plugins bundle skills, hooks, subagents, and MCP servers into a single installable unit."
  - Hooks live in `hooks/hooks.json` and can use `${CLAUDE_PLUGIN_ROOT}`.
  - Managed `enabledPlugins` can force-enable a plugin.
- **Permission semantics:** — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - "Rules are evaluated in order: deny, then ask, then allow. The first match in that order determines the outcome, and rule specificity doesn't change the order."
  - "An allow rule can't carve an exception out of a deny rule."
  - A bare tool name in deny (e.g. `Bash`) removes the tool from context entirely.
  - "Permission rules are enforced by Claude Code, not by the model."
- **Settings example:** — [Settings docs](https://code.claude.com/docs/en/settings)
  ```json
  {
    "$schema": "https://json.schemastore.org/claude-code-settings.json",
    "permissions": {
      "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
      "deny": ["Read(./.env)", "Read(./.env.*)"]
    }
  }
  ```
  Settings files are strict JSON: no comments, no trailing commas.
- **Path patterns** (gitignore syntax): — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - `//abs/path`: filesystem root
  - `~/path`: home directory
  - `/path`: relative to the settings source; in project settings that is the project root
  - `path` or `./path`: cwd
  - `Edit(...)` rules cover all built-in edit tools. Rules written for `Write(...)` are never consulted; use `Edit(...)`.
  - A `Read` deny also blocks Edit and Write on the same path.
  - Deny rules also apply to recognized Bash file commands (`cat`, `sed`, `tee`, redirections). They don't apply to arbitrary scripts that open files.
- **Bash rule caveats:** — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - Compound commands are split on `&& || ; | |& &` and newlines. Each subcommand must match an allow rule. Deny and ask rules apply if any subcommand matches, including inside subshells.
  - A Bash rule "isn't a security boundary around the program". For example, `Bash(git push *)` doesn't stop `git -C . push origin main`, and `Bash(rm *)` doesn't stop `/bin/rm`.
  - "Bash permission patterns that try to constrain command arguments are fragile."
  - Use sandboxing or PreToolUse hooks for robust enforcement.
  - Hook interplay: "A hook that exits with code 2 stops the tool call before permission rules are evaluated."
- **Permission modes:** — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - `default`, labeled Manual (alias `manual`)
  - `acceptEdits`
  - `plan`
  - `auto`: classifier-reviewed
  - `dontAsk`: auto-denies anything not pre-approved; good for CI
  - `bypassPermissions`: "Only use this mode in isolated environments"
  - `permissions.disableBypassPermissionsMode` and `permissions.disableAutoMode` set to `"disable"` are "most useful in managed settings where they can't be overridden."
- **Precedence**, highest first: — [Settings docs](https://code.claude.com/docs/en/settings)
  1. Managed: `managed-settings.json`, MDM, or server-managed from the claude.ai console
  2. Command line `--settings`
  3. `.claude/settings.local.json`
  4. `.claude/settings.json`
  5. `~/.claude/settings.json`
  - "If a tool is denied at any level, no other level can allow it… a managed settings deny can't be overridden by `--allowedTools`." — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - `allowManagedPermissionRulesOnly` makes managed settings the only source of permission rules. — [Permissions docs](https://code.claude.com/docs/en/permissions)
  - A few security keys honor a stricter lower-level value over managed, e.g. `permissions.blockReadsOutsideWorkingDirectories: true`. — [Settings docs](https://code.claude.com/docs/en/settings)
- **Sandboxing:** `sandbox.enabled` gives OS-level filesystem and network isolation, which doesn't depend on command text. — [Memory docs](https://code.claude.com/docs/en/memory); [Permissions docs](https://code.claude.com/docs/en/permissions)

### Inferences
**Suggested team `.claude/settings.json`.** This is a synthesis; validate against the schema.
- `permissions.allow`:
  - Test, lint and typecheck commands
  - Read-only git (`Bash(git diff *)`, `Bash(git status *)`, `Bash(git log *)`)
- `permissions.ask`:
  - `Bash(git push *)`
  - `Edit(/.github/workflows/**)`
- `permissions.deny`:
  - `Read(./.env)`
  - `Bash(git push --force *)`
  - `Edit(/.claude/settings.json)`
  - `Edit(/.claude/hooks/**)`
  - Lockfiles
- `hooks`: PreToolUse guard, PostToolUse formatter, Stop gate, SessionStart(compact) re-injection.

For org-wide non-bypassability, mirror the deny list and hooks in managed settings and add:
- `allowManagedHooksOnly`
- `allowManagedPermissionRulesOnly`
- `permissions.disableBypassPermissionsMode: "disable"`

### Gaps
- I did not fetch the managed-settings page itself, so the exact managed file paths per OS (e.g. `/etc/claude-code/managed-settings.json`, `managed-settings.d/`) were not verified this session.
- The settings-reference entries for `allowManagedHooksOnly` and `allowManagedPermissionRulesOnly` (full lists of what each ignores) were not read.

---

## 5. CI: claude-code-action, Claude Code Review, headless mode, GitHub branch protection

### Takeaway
- **`anthropics/claude-code-action@v1`** runs Claude in your own GitHub workflows. It has two modes: interactive `@claude` mentions, and automation via `prompt`. It respects CLAUDE.md and repo skills.
- **Claude Code Review** (managed; Team/Enterprise; research preview) posts severity-tagged inline findings. Its check run is always neutral and never blocks a merge.
- **`claude -p`** (preferably with `--bare`, `--permission-mode dontAsk` and `--json-schema`) turns Claude into a scriptable CI check whose exit status or JSON you gate on.
- The non-bypassable layer is GitHub required status checks, rulesets and CODEOWNERS review, all running deterministic tests and linters.

### Cited Findings
- **Setup:** — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
  - `/install-github-app`, run from Claude Code, installs the GitHub App, stores the `ANTHROPIC_API_KEY` or `CLAUDE_CODE_OAUTH_TOKEN` secret, and opens a PR with the workflow files.
  - Manual setup: install https://github.com/apps/claude, add the secret, and copy `examples/claude.yml`.
  - Org-level options: an org secret, a reusable workflow, or OIDC workload identity federation (`anthropic_federation_rule_id`, `anthropic_organization_id`; needs `id-token: write`).
- **@claude workflow (verbatim):** — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
  ```yaml
  name: Claude Code
  on:
    issue_comment:
      types: [created]
    pull_request_review_comment:
      types: [created]
  jobs:
    claude:
      if: contains(github.event.comment.body, '@claude')
      runs-on: ubuntu-latest
      permissions:
        contents: write
        pull-requests: write
        issues: write
        id-token: write
        actions: read
      steps:
        - uses: actions/checkout@v6
          with:
            fetch-depth: 1
        - uses: anthropics/claude-code-action@v1
          with:
            anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
  ```
- **Automated PR review workflow (verbatim):** — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
  ```yaml
  name: Code Review
  on:
    pull_request:
      types: [opened, synchronize, ready_for_review, reopened]
  jobs:
    review:
      runs-on: ubuntu-latest
      permissions:
        contents: read
        pull-requests: read
        issues: read
        id-token: write
      steps:
        - uses: actions/checkout@v6
          with:
            fetch-depth: 1
        - uses: anthropics/claude-code-action@v1
          with:
            anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
            plugin_marketplaces: "https://github.com/anthropics/claude-code.git"
            plugins: "code-review@claude-code-plugins"
            prompt: "/code-review:code-review --comment ${{ github.repository }}/pull/${{ github.event.pull_request.number }}"
            claude_args: '--allowedTools "mcp__github_inline_comment__create_inline_comment"'
  ```
  - `--comment` posts findings inline. The `claude_args` line is required because the action starts the inline-comment MCP server only when `--allowedTools` names it.
  - Fork PRs on public repos get no secrets.
  - Repo skills can be run with `prompt: "/skill-name"` after `actions/checkout`.
- **Action inputs:** — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
  - `prompt`, `claude_args`
  - `anthropic_api_key`, `claude_code_oauth_token`, `github_token`
  - `plugin_marketplaces`, `plugins`
  - `settings` (JSON string or path; can carry `permissions.allow` rules)
  - `trigger_phrase` (default `@claude`)
  - `use_bedrock`, `use_vertex`, `use_foundry`
  - `allowed_bots`, `allowed_non_write_users`
  - `claude_args` examples: `--max-turns 5 --model claude-sonnet-5 --mcp-config …`, `--allowedTools`, `--debug`.
  - Migrating from beta: `@beta` → `@v1`, `direct_prompt` → `prompt`, `custom_instructions` → `--append-system-prompt`.
- **Trigger safety:** the triggering user must have write access, and bot actors are rejected unless they appear in `allowed_bots`. — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
- **Best practices:** — [GitHub Actions docs](https://code.claude.com/docs/en/github-actions)
  - "Create a `CLAUDE.md` file in your repository root to define code style guidelines, review criteria, project-specific rules."
  - "Never commit API keys."
  - "Grant the workflow only the permissions it needs, and review Claude's changes before merging."
  - Cap cost with `--max-turns`, workflow timeouts and concurrency.
  - "GitHub doesn't trigger workflows on commits made with the default `GITHUB_TOKEN`." Let the action authenticate as the app so CI runs on Claude's commits.
- **Claude Code Review (managed):** — [Code Review docs](https://code.claude.com/docs/en/code-review)
  - "research preview, available for Team and Enterprise." Not available with ZDR or HIPAA.
  - "multiple agents analyze the diff… a verification step checks candidates against actual code behavior to filter out false positives."
  - Severities: 🔴 Important, 🟡 Nit, 🟣 Pre-existing.
  - Triggers: once after PR creation, after every push, or manual (`@claude review`, `@claude review always`, `@claude review once`).
  - Averages $15–25 per review and about 20 minutes.
  - Enabled by an Owner at claude.ai/admin-settings/claude-code.
- **Code Review does not gate merges:** — [Code Review docs](https://code.claude.com/docs/en/code-review)
  - "The check run always completes with a neutral conclusion so it never blocks merging through branch protection rules. If you want to gate merges on Code Review findings, read the severity breakdown from the check run output in your own CI."
  - Parse it with:
    ```bash
    gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
      --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
    ```
    This returns e.g. `{"normal": 2, "nit": 1, "pre_existing": 0}`, where `normal` is the count of Important findings.
- **Customizing Code Review:** — [Code Review docs](https://code.claude.com/docs/en/code-review)
  - `CLAUDE.md` violations are flagged as nits.
  - `REVIEW.md` at the repo root holds review-only rules: severity calibration, nit caps, skip paths, "Always check" items such as "New API routes have an integration test".
  - "these land more reliably than the same rules in a long `CLAUDE.md`."
- **Headless (`claude -p`):** — [Headless docs](https://code.claude.com/docs/en/headless)
  - "Claude Code exits with code 0 on success and a non-zero code when the run fails."
  - `--output-format text|json|stream-json`. JSON has a `result` field.
  - `--json-schema '<schema>'` returns `structured_output`.
  - `--bare` skips hooks, skills, plugins, MCP, auto memory and CLAUDE.md: "recommended mode for scripted and SDK calls, and will become the default for `-p`."
  - `--permission-mode dontAsk` is "useful for locked-down CI runs".
  - `--permission-prompts none` (v2.1.259+).
  - `--append-system-prompt`.
  - Example:
    ```bash
    gh pr diff "$1" | claude -p --append-system-prompt "You are a security engineer. Review for vulnerabilities." --output-format json
    ```
  - Example linter script: `"lint:claude": "git diff main | claude -p \"you are a typo linter…\""`.
- **CI security caveat:** without `--bare`, `-p` runs hooks from a repo's `.claude/settings.json` "even in a folder you've never trusted." — [Headless docs](https://code.claude.com/docs/en/headless)
- **GitHub CODEOWNERS** (search-result summary of docs.github.com; direct fetch was blocked): — [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
  - The file maps path patterns to users or teams.
  - It must be on the PR's base branch.
  - Files over 3 MB aren't loaded.
  - Owner approval becomes mandatory only when "Require review from Code Owners" is enabled in branch protection or a ruleset.
  - Approval from any one listed owner suffices.
- **Rulesets and required checks** (search-result summary): — [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets); [Managing a branch protection rule](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
  - "Require a pull request before merging" offers required approvals and code-owner review.
  - "Require status checks to pass" ensures "all required CI tests are passing". It supports a strict mode (branch up to date) and pinning a check to an expected source GitHub App.
  - Classic protection treats successful, skipped or neutral as passing.
  - A "required reviewer" ruleset rule (team approvals per file pattern) went GA in February 2026 and "augments CODEOWNERS". — [GitHub Changelog](https://github.blog/changelog/2026-02-17-required-reviewer-rule-is-now-generally-available/)
- **Bypass caveat:** GitHub's Repository Rules GA announcement says bypass actors (including GitHub Apps on the bypass list) can skip rules such as status checks. — [GitHub blog](https://github.blog/news-insights/product-news/github-repository-rules-are-now-generally-available/), via search summary; not directly verified.

### Inferences
- Because Code Review's check is always neutral, and "skipped/neutral" counts as passing for required checks, a Claude-based gate needs its own workflow job that fails, i.e. exits non-zero, on Important findings or on a failing `claude -p --json-schema` verdict. That job is then marked as a required status check.
- Keep deterministic checks (tests, lint, typecheck, coverage threshold) as the primary required checks. Treat LLM review as advisory or second-tier, given false-positive risk.
- Do not put the Claude GitHub App on ruleset bypass lists.
- Add CODEOWNERS entries for `.github/workflows/`, `.claude/`, `CLAUDE.md`, `REVIEW.md` and lint configs, and require code-owner review. That way agent edits to the guardrails themselves need human sign-off.

### Gaps
- docs.github.com pages could not be fetched; the exact UI names and options for rulesets and bypass behavior come from search summaries only.
- I didn't verify whether claude-code-action exposes a native "fail the job on findings" option. The docs show only comment and log output.

---

## 6. Anthropic best practices for agentic coding and context engineering

### Takeaway
- Anthropic's core advice is: give Claude a pass/fail check it can run, and decide how hard that check gates the stop: in the prompt, via `/goal`, via a Stop hook, or via an independent verifier subagent.
- Explore → plan → implement → commit.
- Keep context lean (`/clear`, subagents, concise CLAUDE.md), because performance degrades as context fills.

### Cited Findings
- **Verification ladder:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - "Give Claude a check it can run: tests, a build, a screenshot to compare. It's the difference between a session you watch and one you walk away from."
  - "Claude stops when the work looks done. Without a check it can run, 'looks done' is the only signal available."
  - Gate options:
    - In one prompt
    - Across a session with `/goal`
    - "As a deterministic gate: a Stop hook runs your check as a script and blocks the turn from ending until it passes"
    - "By a second opinion: a verification subagent… so the agent doing the work isn't the one grading it"
  - "Have Claude show evidence rather than asserting success."
- **Root causes:** "address the root cause, don't suppress the error." — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Workflow:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - The four phases are Explore (plan mode), Plan (`Ctrl+G` edits the plan), Implement ("write tests… run the test suite and fix any failures") and Commit.
  - "If you could describe the diff in one sentence, skip the plan."
- **TDD and parallel sessions:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - "write a failing test that reproduces the issue, then fix it."
  - Writer/Reviewer: "A fresh context improves code review since Claude won't be biased toward code it just wrote."
  - "have one Claude write tests, then another write code to pass them."
- **Context as the key constraint:** — [Best practices](https://code.claude.com/docs/en/best-practices)
  - "Claude's context window fills up fast, and performance degrades as it fills… Claude may start 'forgetting' earlier instructions."
  - "After two failed corrections, `/clear` and write a better initial prompt."
- **Failure patterns:** the kitchen-sink session, correcting over and over, over-specified CLAUDE.md, the trust-then-verify gap ("If you can't verify it, don't ship it"), and infinite exploration. — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Unattended runs:** `--permission-mode auto` (classifier) or `dontAsk` with `--allowedTools`. Fan out with `claude -p` loops or `/batch`. — [Best practices](https://code.claude.com/docs/en/best-practices)
- **Context engineering:** "Effective context engineering for AI agents" (Anthropic, Sep 29, 2025). — [Anthropic Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
  - "finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."
  - "context rot": recall degrades as context grows. Models have an "attention budget".
  - System prompts at the "right altitude", between brittle if-else logic and vague guidance.
  - Claude Code's hybrid approach: CLAUDE.md up front, with glob and grep "just-in-time".
  - Compaction, structured note-taking (NOTES.md), and sub-agents returning condensed summaries of "1,000–2,000 tokens".

### Inferences
- The best-practices page itself points to the "quality guardian" architecture:
  - A concise CLAUDE.md
  - A Stop hook as the deterministic gate
  - A read-only verifier subagent as the second opinion
  - CI as the final arbiter
- Each layer covers the previous layer's failure mode: advisory context that gets ignored, a self-grading bias, and local config the developer can bypass.

### Gaps
- The original April 2025 "Claude Code: Best practices for agentic coding" blog post (anthropic.com/engineering/claude-code-best-practices) was not fetched. The current docs page appears to be its maintained successor, but I didn't confirm that.

---

## 7. Portability: AGENTS.md, Cursor rules, Copilot instructions

### Takeaway
- AGENTS.md is the cross-tool, schema-less Markdown standard, now under the Linux Foundation's Agentic AI Foundation.
- Claude Code (v2.1.277+) reads AGENTS.md natively when no CLAUDE.md exists, or alongside it via a setting. The portable pattern is a CLAUDE.md that contains `@AGENTS.md`.
- Cursor (`.cursor/rules/*.mdc`) and Copilot (`.github/copilot-instructions.md`, `.github/instructions/*.instructions.md` with `applyTo`) have analogous advisory files.
- None of these is enforcement. Hooks are Claude Code–specific, so CI is the portable enforcement layer.

### Cited Findings
- **How Claude Code reads AGENTS.md:** — [Memory docs](https://code.claude.com/docs/en/memory)
  - By default it reads `AGENTS.md` "only when you have no `CLAUDE.md` in your working directory or above it". A `CLAUDE.local.md` also counts and suppresses it.
  - The setting **Project instructions** takes `claude-md-or-agents-md` (default), `claude-md-and-agents-md`, `claude-md` or `managed-only`.
  - Settings key: `pluginConfigs["cc-plugin-agents-md@builtin"].options.instructionFiles`.
  - Requires v2.1.277+.
  - Alternatives: a CLAUDE.md containing `@AGENTS.md` (then Claude-specific lines below it), or `ln -s AGENTS.md CLAUDE.md`.
- **AGENTS.md governance:** stewarded by the Agentic AI Foundation (Linux Foundation), announced Dec 9, 2025, co-founded by OpenAI, Anthropic and Block. — [InfoQ](https://infoq.com/news/2025/08/agents-md/); [AAIF blog](https://aaif.io/blog/measuring-agents-md-what-five-runs-show-that-one-doesn-t), via search summary
- **AGENTS.md format:** "No schema, no required fields, just Markdown." Nested files are allowed; the closest file wins, and explicit user prompts override it. — [codex.danielvaughan.com](https://codex.danielvaughan.com/2026/04/07/agents-md-open-standard-cross-tool-portability), secondary source; agents.md itself was blocked
  - Supporting-tool counts ("20+" / "25+", "60,000 projects") come from secondary sites and are approximate.
- **Cursor:** — [Cursor forum](https://forum.cursor.com/t/a-deep-dive-into-cursor-rules-0-45/60721); [StackHawk](https://www.stackhawk.com/blog/cursor-rules/)
  - `.cursor/rules/*.mdc` files with frontmatter `description`, `globs`, `alwaysApply`.
  - Modes: always, glob-attached, agent-requested (description only), or manual @-mention.
  - Legacy `.cursorrules` is deprecated.
  - Forum reports describe glob rules not always being applied ([forum](https://forum.cursor.com/t/glob-pattern-rules-are-never-respected-by-agent/160133)), which shows advisory rules are unreliable there too. These are community sources.
- **GitHub Copilot:** — [GitHub Docs: custom instructions support](https://docs.github.com/en/copilot/reference/custom-instructions-support); [Changelog: Copilot coding agent supports AGENTS.md](https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/), via search summary
  - `.github/copilot-instructions.md` applies repo-wide.
  - `.github/instructions/**/*.instructions.md` files carry an `applyTo` glob in frontmatter.
  - The coding agent supports AGENTS.md (August 2025).
  - The `excludeAgent` property can hide a file from code review or the coding agent.

### Inferences
- Portable setup:
  - Put shared, tool-agnostic standards in `AGENTS.md`: commands, definition of done, conventions.
  - Add a thin `CLAUDE.md` with `@AGENTS.md` plus Claude-only notes.
  - Optionally add `.github/copilot-instructions.md` and Cursor rules that point to the same content.
- Enforcement (hooks, permissions) doesn't port. Implement the same checks as git pre-commit hooks and required CI checks, so every agent and every human hits them.

### Gaps
- agents.md, docs.github.com and Cursor's official docs could not be fetched directly. Copilot and Cursor field names come from search summaries of official and community pages and should be spot-checked.
