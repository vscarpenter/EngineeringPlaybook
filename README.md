# Engineering Playbook

Operating rules for AI coding agents and the people who run them.

Coding agents fail in predictable ways. They guess at unclear requirements, build more than anyone asked for, and report success without proof. They also start every session with no memory of the last one.

The playbook treats each failure as a process problem and answers it with a mechanism. That can be a spec, a test written first, an independent review, a committed handoff note, or a hook that blocks the action.

It works with any agent that reads `AGENTS.md`. Claude Code gets two extras: optional hooks for common checks, and the full reference as a skill.

## How it works

| How agents fail | The playbook's answer | Where it lives |
|---|---|---|
| Guesses at an unclear requirement | Attended and unattended modes, recorded assumptions, stop conditions | `AGENTS.md` |
| Builds the wrong thing, or too much | A spec first, with an out-of-scope list and draft test names | `tasks/spec.md` |
| Says done with no proof | Verification defined before the code, then a reviewer that did not write it | `AGENTS.md`, the `Stop` hook |
| Writes a lot and runs none of it | Red, green, refactor, one behavior at a time | `AGENTS.md` |
| Forgets everything between sessions | A committed `tasks/` folder and a Resuming From Here block | `tasks/`, the `SessionStart` hook |
| Repeats a corrected mistake | Lessons written down the moment they happen | `tasks/lessons.md` |
| Obeys text it found, or runs something destructive | Fetched text is data. Destructive commands need a person. | `AGENTS.md`, the `PreToolUse` hook |

Attention is the budget. The core file stays short because every agent loads it on every session. The full reference sits behind a routing table, so an agent opens one section at a time. Hook commands run outside the model; their task notes and diagnostics still use context.

The reference states the principle directly:

> If a rule can run as a hook or a CI check, it does not belong in prose.

An illustrated explainer lives at [`docs/explainer.html`](docs/explainer.html). GitHub shows its source, so clone the repository and open the file in a browser.

## What is in the kit

| Path | What it is |
|---|---|
| `AGENTS.md` | The core rules for every agent, with a blank Project section for your repository |
| `CLAUDE.md` | One import line, `@AGENTS.md`, plus notes for Claude Code |
| `.claude/settings.json` | The hooks: guard common destructive commands, format, audit dependencies, restore task state, remind about verification |
| `.claude/skills/engineering-playbook/` | The full reference, and a routing table from a need to a section |

Everything else here belongs to this repository: this README, `INSTALL.md`, `docs/`, `tests/`, `tasks/`, and `.github/`. The `tasks/` folder is the playbook applied to its own development.

### Not included yet

The reference names companions that this repository does not include. Add your own per project.

- Helper skills: `/qspec`, `/qcheck`, and `/tdd`
- Reviewer and builder subagents: `build-validator`, `code-simplifier`, `security-reviewer`, `tdd-enforcer`, and `verify-app`
- Path-scoped rules in `.claude/rules/`
- A secret-scanning hook. Section 1.9 of the reference tells agents to run a scanner before commit when the project has one.

## Quick start

Read [`INSTALL.md`](INSTALL.md) first. It is the text your agent will follow. Then paste this into your coding agent, from the root of your repository:

```text
Clone https://github.com/vscarpenter/EngineeringPlaybook.git into a temporary folder.
Read INSTALL.md from the clone, in full, and follow it to install the
Engineering Playbook in this repository.
Show me your plan before you change anything.
```

The prompt says to clone because an agent that fetches a URL often receives a summary of the page. Read from the clone, the rules arrive whole.

Your agent reads the project, prepares one complete merge plan, and waits for approval before writing. It preserves your rules and existing edits, selects only hooks that fit your tools, and verifies the result before recording the source commit. Use the same guide for upgrades: it replaces earlier kit hooks while preserving your own.

For the smallest setup, install the core and reference. Claude Code users can add the import bridge and optional hooks. Other harnesses need no Claude configuration. Tell your agent a commit or tag if you want a pinned version.

## Optional hooks

Read [`.claude/settings.json`](.claude/settings.json) before enabling it. Hooks run shell commands with your permissions. They need a POSIX shell and `jq`; a core-only install needs neither.

- **Command guard:** blocks common destructive Bash spellings and rejects invalid input or a missing parser. This is best-effort text matching. It can block harmless quoted text and miss aliases, scripts, computed paths, or other shell syntax. Use harness permissions and OS sandboxing as the security boundary.
- **Formatting:** uses the project's installed Biome after Edit/Write, checks physical project containment, and skips file symlinks and node_modules. Directory symlinks within the project are allowed. It is not protection against concurrent filesystem changes or a malicious formatter.
- **Dependency audit:** runs `npm audit` after Edit/Write changes to a manifest or npm lockfile, only when npm and its lockfile are present. It reports after the write. Adapt or omit it for other package managers.
- **Session state:** adds task notes and five commits to context. Keep the notes short.
- **Stop reminder:** runs local tests and available TypeScript checks, then requests another turn on failure. The continuation guard allows a blocked handoff; a successful Stop is not proof that tests passed. Keep CI as the final check.

The hooks never download a missing tool. Adapt them to tools already in your project, or omit them. The [installation guide](INSTALL.md) covers setup and upgrades; there is no separate copy recipe to keep in sync.

## Day to day

- Agents load `AGENTS.md` on every session. They open the reference only when a rule points there. In Claude Code, `/engineering-playbook` loads the routing table.
- Non-trivial work starts with `tasks/spec.md` and a plan in `tasks/todo.md`. Both get committed.
- Every session ends with a Resuming From Here block, so the next session needs no briefing.
- After any correction, the agent adds a line to `tasks/lessons.md`.
- Parts 6 and 7 of the reference are written for you, not the agent. They cover prompt patterns and how to build skills, rules, subagents, and hooks.

## Working on the kit

Run the hook regressions and document/install contracts before and after a change:

```bash
bash tests/test_hooks.sh
python3 -m unittest discover -s tests -p 'test_*.py'
```

The hook tests use stub tools that record how they were called. Nothing real runs, and nothing touches the network. CI runs the hooks under `sh`, `bash`, and `dash` on Ubuntu and macOS, plus the document/install checks with Python 3. These development checks add no runtime dependency for adopters.

## License

[MIT](LICENSE). Keep the notice with your copy. `INSTALL.md` places it inside the copied skill folder.
