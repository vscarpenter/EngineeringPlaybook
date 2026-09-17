# Engineering Playbook

Operating rules for AI coding agents and the people who run them.

Coding agents fail in predictable ways. They guess at unclear requirements, build more than anyone asked for, and report success without proof. They also start every session with no memory of the last one.

The playbook treats each failure as a process problem and answers it with a mechanism. That can be a spec, a test written first, an independent review, a committed handoff note, or a hook that blocks the action.

It works with any agent that reads `AGENTS.md`. Claude Code gets two extras: hooks that enforce the mechanical rules, and the full reference as a skill.

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

Attention is the budget. The core file stays short because every agent loads it on every session. The full reference sits behind a routing table, so an agent opens one section at a time. Hooks run outside the model and cost no context.

The reference states the principle directly:

> If a rule can run as a hook or a CI check, it does not belong in prose.

An illustrated explainer lives at [`docs/explainer.html`](docs/explainer.html). GitHub shows its source, so clone the repository and open the file in a browser.

## What is in the kit

| Path | What it is |
|---|---|
| `AGENTS.md` | The core rules for every agent, with a blank Project section for your repository |
| `CLAUDE.md` | One import line, `@AGENTS.md`, plus notes for Claude Code |
| `.claude/settings.json` | The hooks: block destructive commands, format, audit dependencies, restore task state, gate on tests |
| `.claude/skills/engineering-playbook/` | The full reference, and a routing table from a need to a section |

Everything else here belongs to this repository: this README, `INSTALL.md`, `docs/`, and `tasks/`. The `tasks/` folder is the playbook applied to its own development.

### Not included yet

The reference names companions that this repository does not include. Add your own per project.

- Helper skills: `/qspec`, `/qcheck`, and `/tdd`
- Reviewer and builder subagents: `build-validator`, `code-simplifier`, `security-reviewer`, `tdd-enforcer`, and `verify-app`
- Path-scoped rules in `.claude/rules/`

## Quick start

Read [`INSTALL.md`](INSTALL.md) first. It is short, and it is the text your agent will follow. Then paste this into your coding agent, from the root of your repository:

```text
Read https://raw.githubusercontent.com/vscarpenter/EngineeringPlaybook/main/INSTALL.md
and follow it to install the Engineering Playbook in this repository.
Show me your plan before you change anything.
```

Your agent fetches the kit, checks what your repository already has, and proposes a merge. It should never overwrite a file, commit, or push without your say. It adapts the hooks to your stack and fills in the Project section with commands it has run.

To pin what you install, replace `main` in the URL with a commit hash, and tell your agent to check out that commit.

## Manual install

Use this for a repository that has none of these files yet. These commands overwrite.

```bash
git clone --depth 1 https://github.com/vscarpenter/EngineeringPlaybook.git /tmp/engineering-playbook
cd /path/to/your/repository
cp /tmp/engineering-playbook/AGENTS.md /tmp/engineering-playbook/CLAUDE.md .
mkdir -p .claude/skills
cp /tmp/engineering-playbook/.claude/settings.json .claude/settings.json
cp -R /tmp/engineering-playbook/.claude/skills/engineering-playbook .claude/skills/
cp /tmp/engineering-playbook/LICENSE .claude/skills/engineering-playbook/LICENSE
```

Then do two things by hand:

1. Fill in the Project section at the end of `AGENTS.md`: stack, commands, verification tools, patterns, and gotchas. The playbook sends agents there for your project's commands.
2. Read `.claude/settings.json` and fix the hooks for your stack, as the next section describes.

## Before you turn on the hooks

Hooks run shell commands on your machine with your permissions. Read `.claude/settings.json` before you trust it.

- Every hook needs `jq`.
- The format hook runs Biome through `npx`. In a repository without Biome, replace it with your formatter or delete it. Left alone, `npx` downloads Biome on every write.
- The audit hook runs `npm audit` or `pip-audit` when a dependency manifest changes.
- The `Stop` hook runs `npm test` when a `package.json` exists. A failing suite sends the agent back to work before it can finish. Replace the command with your own test command. On a slow suite, consider leaving this gate to CI.
- The `PreToolUse` hook blocks force pushes, hard resets, branch deletion, recursive deletes of root or home, and dropped tables. It matches text, so it also blocks a harmless command that only mentions one of those phrases.
- Hooks are a Claude Code feature. Other harnesses ignore `.claude/settings.json`, so those rules rest on CI and on the agent.

## Day to day

- Agents load `AGENTS.md` on every session. They open the reference only when a rule points there. In Claude Code, `/engineering-playbook` loads the routing table.
- Non-trivial work starts with `tasks/spec.md` and a plan in `tasks/todo.md`. Both get committed.
- Every session ends with a Resuming From Here block, so the next session needs no briefing.
- After any correction, the agent adds a line to `tasks/lessons.md`.
- Parts 6 and 7 of the reference are written for you, not the agent. They cover prompt patterns and how to build skills, rules, subagents, and hooks.

## License

[MIT](LICENSE). Keep the notice with your copy. `INSTALL.md` and the manual steps both place it inside the copied skill folder.
