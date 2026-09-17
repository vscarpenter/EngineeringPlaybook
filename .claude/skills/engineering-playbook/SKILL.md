---
name: engineering-playbook
description: Full Engineering Playbook reference (spec workflow, verification, TDD, code standards, git and PR rules, ADRs, Definition of Done, unattended-mode stop conditions, Claude Code primitives). Use when AGENTS.md points to a playbook section, when planning non-trivial work, when writing a spec or ADR, when checking a PR against the Definition of Done, or when unsure how a core rule applies to an edge case.
---

# Engineering Playbook

The always-on rules are already in context from `AGENTS.md`. Do not re-read them. Open `references/engineering-playbook.md` and read only the section you need:

| Need | Section |
|---|---|
| Deciding attended vs unattended, stop conditions | 1.2 Operating modes |
| Writing or updating a spec | 1.3 Spec-driven development |
| Choosing a verification method, elegance check, independent review | 1.4 Verification first |
| `tasks/` file lifecycle, handoff block, context budget | 1.6 Context, commits, and handoff |
| Untrusted content, secrets, destructive operations | 1.9 Agent security |
| Naming, types, structure, dependencies, error handling | Part 2 Code Standards |
| Red/green/refactor details, test quality, flaky tests | Part 3 Testing |
| Commit format, PR checklist, ADR template | Part 4 Git, Reviews, and Decisions |
| Final checklist before calling work done | Part 5 Definition of Done |
| Prompt templates (spec, implementation, review, debug, architecture) | Part 6 (human-facing) |
| Skills, rules, subagents, hooks, `AGENTS.md` import | Part 7 (human-facing) |
| Fast scan for smells | Part 8 Red Flags |

## Gotchas

- Parts 6 and 7 are written for the human running the harness. Read them only when asked to build a skill, hook, or prompt.
- The Project section of `AGENTS.md`, not this playbook, lists the verification tools available in this repository.
- When the playbook and the existing codebase disagree on style, the codebase wins (1.1).
