# Todo: public release files

Tier: Non-trivial. `INSTALL.md` is a public contract that other people's agents will execute. Vinny approved the design in chat on 2026-09-17: MIT, README plus INSTALL.md, trim `CLAUDE.md`. Spec: `tasks/spec.md`. Branch: `docs/public-release`.

## Verification (defined first)

- A check script with one test per stub in the spec. Red first, then green.
- A dry run: a fresh agent follows `INSTALL.md` in a fixture repository. An install guide for agents is proven by an agent installing from it.
- An independent review of the diff against Vinny's request and the spec, by a read-only agent in a fresh context (1.4).

## Plan

- [x] Check script, confirm red (6 of 9 failing, each on a missing file or a named companion)
- [x] `.gitignore` (all three Claude Code entries confirmed in the docs)
- [x] `LICENSE` (matches GitHub's MIT template)
- [x] Trim `CLAUDE.md` (three bullets removed, nothing else touched)
- [x] `INSTALL.md`
- [x] `README.md`
- [x] Correct the errors found while checking docs (a lesson, and two explainer sentences)
- [x] Green, then commit each unit
- [x] Dry run 1, Python fixture: correct install, 18 problems with the guide. Guide restructured.
- [x] Independent review: 3 blocking, 11 important, 4 nits. Spec corrected, tests red, fixes, green (11 of 11).
- [x] Dry run 2 on the restructured text, JavaScript fixture: correct install, no trap fired, 22 unclear points. 20 settled.
- [x] Handoff

## Assumptions

- The copyright line reads "Copyright (c) 2026 Vinny Carpenter", the name the reference already carries.
- Adopters satisfy the MIT notice by keeping a copy of `LICENSE` inside the copied skill folder.
- The quick start clones the default branch, so it works only after this branch merges to `main`.

## Review

### What the verification found

- Dry run 1 produced a correct install and showed the guide's approval gate sat before the hook changes. The person approved a settings file that never landed. The guide now plans in steps 1 to 5, asks once, then writes.
- The independent review found that "run each command once" let an agent run a deploy or a publish before any plan. It also found that a fetched URL can reach an agent as a summary. Both fixed. The quick start now clones first.
- Dry run 2 ran the restructured text end to end. The agent stopped at a symlinked `CLAUDE.md`, never ran `deploy`, `release`, `install`, or `audit`, and merged both files as pure insertions (83 and 9 added lines, 0 removed).
- Checking claims against the Claude Code docs caught three of my own errors: hooks are not snapshotted at session start, exit code 2 does not block on `PostToolUse`, and a `Stop` hook cannot loop forever.

### Review findings fixed

B1 pre-gate commands, B2 dry run on the final structure, B3 clone before reading, I1 artifacts from tests, I2 the JSON comma, I3 missing `jq` or shell, I4 stop-and-ask preconditions, I5 the manual install, I6 three facts against the docs, I8 pinning and `INSTALLED_FROM`, I9 other harnesses and scratch clones, N1 the hook index, N2 `.env` in `.gitignore`. I7 and I10 fixed by disclosure in `README.md` and `INSTALL.md`. I11 answered with two structural tests: the hooks table against `settings.json`, and `bash -n` on every published shell block.

### Declined, with reasons

- I7, fix the hooks: out of scope by the spec. Disclosed, and raised with Vinny below.
- I8, no tag exists: tags and releases are out of scope. Raised below.
- I10, reference 7.5 still says "Exit code 2 blocks": the reference is out of scope here. Raised below.
- I11, commit the check script: Vinny's open decision from the last task.
- I11, fetch the quick-start URL in a test: the branch is not pushed, so there is nothing to fetch.
- N3, no next-steps artifact: adoption advice goes to Vinny in chat. He decides what becomes a file.
- N4, a gmail address and session URLs in public history: both come from Vinny's own commit conventions.
- Dry run 2, items 16 and 19: npm rotating its own logs, and an empty `git diff` on a symlink. Neither misleads an agent.

### Not verified

- The clone from GitHub. Both dry runs cloned the local branch, because `main` on GitHub lacks these files.
- The final `INSTALL.md` differs from the text dry run 2 executed by about 22 lines. All are clarifications that run asked for. None changes the flow.
- The paths the fixtures did not reach: a repository that really has Biome installed, a pnpm or yarn project, an invalid `settings.json`, a non-git folder, Windows, and an upgrade over an earlier install.
- Both dry-run agents ran under this repository's hooks and had its `AGENTS.md` in context. An adopter's agent starts colder.

## Resuming From Here

- Done: 11 commits on `docs/public-release`, tree clean. Nothing is pushed. The explainer Artifact is at version 3: https://claude.ai/artifact/2457aNRNQn52x6CQ4zvFyh
- Next: Vinny decides whether to push and open a PR. The quick start works only once this is on `main`.
- The 11 release checks, the 11 review-rule checks, and both fixtures live in the session scratchpad. They do not survive the session.
- Needs decision, all Vinny's:
  1. Push `docs/public-release` and open a PR?
  2. Fix the shipped hooks. The `Stop` hook cannot block on a type error, and bare `npx tsc` fetches an unrelated package. `pip-audit` audits the active environment. `npm audit` needs a lockfile.
  3. Reference 7.5 says exit code 2 "blocks" and that a `Stop` hook can "loop the session forever". The docs say otherwise for `PostToolUse` and cap continuations at eight. Reference 1.9 promises a secret-scanning hook that does not ship.
  4. Tag a release, so adopters can pin to a name and not a hash.
  5. Publish the explainer, by GitHub Pages or another host, so the README can link to a rendered page.
  6. Still open from the last task: a version bump, a definition of "trivial", declining a BLOCKING finding alone, 4.2, and committing the structural checks.
