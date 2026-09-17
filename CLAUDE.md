@AGENTS.md

# Claude Code notes

Everything above comes from `AGENTS.md`, which Codex and other agents read too. Keep shared rules there; this file holds only what is Claude Code specific.

- Full reference: `/engineering-playbook`. Load only the section you need.
- Hooks in `.claude/settings.json` block destructive shell commands, re-inject `tasks/` after compaction, and refuse to stop with a failing suite. When the project has the tools installed, they also format on write and audit a changed manifest. Do not edit hook configuration unless the task is about hooks.
- After compaction or on resume, the hooks print `tasks/todo.md` and `tasks/lessons.md`. Read them before acting.
