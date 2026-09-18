@AGENTS.md

# Claude Code notes

Everything above comes from `AGENTS.md`, which Codex and other agents read too. Keep shared rules there; this file holds only what is Claude Code specific.

- Full reference: `/engineering-playbook`. Load only the section you need.
- Hooks in `.claude/settings.json` provide best effort destructive-command checks, restore task state, and run installed format/audit tools. Harness permissions and sandboxing remain the security boundary. Do not edit hook configuration unless the task is about hooks.
- The `Stop` hook is a bounded verification reminder: it skips another check when `stop_hook_active` is true to prevent loops. A blocked handoff is not successful completion; the agent must report unresolved failures under Needs decision.
- After compaction or on resume, the hooks print `tasks/todo.md` and `tasks/lessons.md`. Read them before acting.
