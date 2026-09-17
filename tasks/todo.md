# Todo: public release files

Tier: Non-trivial. `INSTALL.md` is a public contract that other people's agents will execute. Vinny approved the design in chat on 2026-09-17: MIT, README plus INSTALL.md, trim `CLAUDE.md`. Spec: `tasks/spec.md`. Branch: `docs/public-release`.

## Verification (defined first)

- A check script with one test per stub in the spec. Red first, then green.
- A dry run: a fresh agent follows `INSTALL.md` in a fixture repository that already has a `CLAUDE.md` and a `.claude/settings.json`, on a Python stack. An install guide for agents is proven by an agent installing from it.
- An independent review of the diff against Vinny's request and the spec, by a read-only agent in a fresh context (1.4).

## Plan

- [ ] Check script, confirm red
- [ ] `.gitignore`
- [ ] `LICENSE`
- [ ] Trim `CLAUDE.md`
- [ ] `INSTALL.md`
- [ ] `README.md`
- [ ] Correct the two errors found while checking docs (a lesson, and one explainer sentence)
- [ ] Green, then commit each unit
- [ ] Dry run in a fixture repository, then fix what it shows
- [ ] Independent review, then triage
- [ ] Handoff

## Assumptions

- The copyright line reads "Copyright (c) 2026 Vinny Carpenter", the name the reference already carries.
- Adopters satisfy the MIT notice by keeping a copy of `LICENSE` inside the copied skill folder.
- The quick-start URL points at `main`, so it works only after this branch merges.
