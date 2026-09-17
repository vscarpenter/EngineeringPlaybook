# Todo: hooks that act only on what is present

Tier: Non-trivial. It changes the hooks every adopter installs. Vinny approved the design in chat on 2026-09-17: fix the four defects and the format hook, reword 1.9, commit the tests. Spec: `tasks/spec.md`. Branch: `fix/hook-defects`.

The previous task (public release files) merged as PR 1. Its spec and review live in git history at commit `fcd08f4` and before.

## Verification (defined first)

- `bash tests/test_hooks.sh`. Each hook command runs in a throwaway folder against stub `npm`, `npx`, `tsc`, `biome`, and `pip-audit` that record how they were called. Red against today's hooks, then green.
- The session's document checks for the reference, `README.md`, `INSTALL.md`, and the explainer.
- An independent review of the diff against Vinny's request and the spec, by a read-only agent in a fresh context (1.4).

## Plan

- [x] Write `tests/test_hooks.sh`, confirm red for the right reasons (14 of 26 failing)
- [x] Fix the `Stop`, audit, and format hooks. Green.
- [x] Reference: 7.5 and 1.9, edited in place. Still 640 lines.
- [x] `README.md`, `INSTALL.md`, and the explainer
- [x] Independent review: 2 blocking, 8 important, 8 nits
- [x] Back to Vinny on the blocking finding. He chose to drop the Python audit and to edit `CLAUDE.md`.
- [x] Spec corrected, tests red (12 of 33), fixes, green under sh, dash, bash, and zsh
- [x] Second, narrow review of the three hook commands: no blocker, 3 important, 2 nits
- [x] Spec updated, tests red (4 of 41), fixes, green. Nine mutations, nine caught.
- [x] Handoff

## Assumptions

- Claude Code runs a hook command through a POSIX shell. The tests use `sh -c`, and pass under dash, bash, and zsh too.
- `npm audit` keeps running at the project root, as it did before.
- Claude Code passes `file_path` as an absolute path in the same form as `CLAUDE_PROJECT_DIR`. A symlinked alias of the project path makes the two `PostToolUse` hooks do nothing, which is the safe direction.

## Review

### What the reviews found

- My first fix for the Python audit was unsafe. `pip-audit -r <file>` is, in its own README's words, "functionally equivalent to `pip install -r`". The hook would have downloaded and built packages on every manifest edit. Vinny chose to drop the Python arm.
- My first tests logged `$*`, which flattens arguments. The reviewer removed the quotes around a path and all 26 tests still passed. The stubs now log each argument in its own brackets.
- My test-script guard used `jq -e`, which exits 5 on invalid JSON, so a `package.json` with a trailing comma ended the session ungated. That was a regression against `main`. Fixed, with a test.
- While editing `settings.json`, the old format hook re-indented all 49 lines with tabs. That is the defect the format fix removes, caught in this repository.

### Findings fixed

Review 1: B1 and B2 (Python audit dropped), I1 (argument logging), I2 (exact file names, `node_modules`), I3 (README on 1.9), I4 (`npm` and test-script guards), I5 (format from the project root, inside the project only), I6 (exit code 2 by event), I7 (`CLAUDE.md` bullet, with Vinny's approval), the wording part of I8, N1 (`SETTINGS` override), N2 (exact-line matching), N3 (`PATH` isolation, `mktemp` and `jq` guards, `HOOK_SH`), N4 (unset project variable), N6 (`npm-shrinkwrap.json`), N7 (the 7.5 example).

Review 2: a `..` step escaping the project, invalid JSON passing the `Stop` hook, the `npm init` placeholder script, a trailing slash on the project variable, the `node_modules` check on the whole path, three mutations that survived, a sibling-prefix test, `$RANDOM` collisions, and a non-POSIX `grep` pattern.

### Declined, with reasons

- Review 1, I8, sign-off for dropping the pnpm and uv triggers: the design Vinny approved said those triggers go away.
- Review 1, I8, criteria 9 and 10 rest on session checks: committing the document checks is Vinny's open decision. The hook behaviour is covered by committed tests.
- Review 1, N1, tests and fix share a commit: Part 8 of the reference calls a failing test committed without its implementation a red flag. `SETTINGS=<file>` now reproduces red, and `main` fails 30 of 41.
- Review 1, N5, show `npm test` output on failure: the agent can rerun the suite, and the one-liner stays readable. Yarn PnP, `tsc -b`, and worktrees are beyond this change. The README says to replace the commands with your own.
- Review 1, N6, the audit never fires for `npm install` run through Bash: the `Edit|Write` matcher predates this change. Raised below.
- Review 1, N8, one-liners are hard to review, and no CI runs the tests: both are larger changes. Raised below.
- Review 2, a symlinked alias of the project path: the hooks do nothing in that case, which is safe. Resolving paths on every write costs more than it buys.
- Review 2, document workspace roots: the README already tells people to replace the commands.

### Not verified

- The hooks under a real Claude Code session in a JavaScript project. The tests drive each command with a hand-built payload.
- Real `npm audit`, `tsc`, and `biome`. The tests use stubs by design.
- `INSTALL.md` was not dry-run again. Its flow did not change. Three rows of its hooks table did.
- No review ran after the second round of fixes. Nine mutations stand in for one.

## Resuming From Here

- Done: all work is committed on `fix/hook-defects`, and the tree is clean. Nothing is pushed. The explainer Artifact matches the repository: https://claude.ai/artifact/2457aNRNQn52x6CQ4zvFyh
- Run `bash tests/test_hooks.sh` before and after any hook change. The document checks still live in the session scratchpad and do not survive the session.
- Needs decision, all Vinny's:
  1. Push `fix/hook-defects` and open a PR?
  2. Move the hooks out of one-line JSON strings into script files. Each is now about 500 characters. Script files would be readable and lintable, but the kit would grow a fifth path.
  3. Run `bash tests/test_hooks.sh` in CI.
  4. The audit hook fires on `Edit|Write` only, so `npm install <package>` through Bash is never audited.
  5. A Python audit that does not install what it audits, for example a pinned-only static mode, tested against a real `pip-audit`.
  6. Still open from earlier tasks: a version bump, a definition of "trivial", declining a BLOCKING finding alone, 4.2, a release tag, publishing the explainer, and committing the document checks.
