@AGENTS.md

# Claude Code notes

Everything above comes from `AGENTS.md`, which Codex and other agents read too. Keep shared rules there; this file holds only what is Claude Code specific.

- Full reference: `/engineering-playbook`. Load only the section you need.
- Helpers: `/qspec` writes `tasks/spec.md`, `/qcheck` runs the skeptical review, `/tdd` starts a red/green/refactor cycle.
- Hooks in `.claude/settings.json` format on every write, audit dependency manifests when they change, block destructive shell commands, re-inject `tasks/` after compaction, and refuse to stop with a failing suite. Do not edit hook configuration unless the task is about hooks.
- Reviewer subagents in `.claude/agents/` run read-only. Use `security-reviewer` and `code-simplifier` before opening a PR. Implementation agents use `isolation: worktree`.
- Path-scoped conventions live in `.claude/rules/` and load automatically when you read matching files.
- After compaction or on resume, the hooks print `tasks/todo.md` and `tasks/lessons.md`. Read them before acting.
