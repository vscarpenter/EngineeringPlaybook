Tier: Non-trivial. Four files change, including the core and reference rules that adopters copy.

# Plan: prompt-audit fixes

Branch: `fix/prompt-audit`. Baseline: clean `ec9f79b`. The user approved all four audit patches ("apply all patches"). Contract: `tasks/spec.md`.

## Verification defined first

- Baseline on `ec9f79b`: 23 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check` is clean.
- These edits are prose only, so there is no red test (playbook 3.1). Each commit runs the full suite, and the final diff gets a fresh-context review.

## Plan

- [x] Record the baseline suites on clean `ec9f79b`.
- [x] Commit the spec and plan (`de11251`).
- [x] H1: context budget in the core, reference 1.6, and the explainer. The explainer quote matches reference 1.6.
- [x] H2: implicit scope in reference 6.3 (`b9086bc` was H1).
- [x] M1: an exit for the staff-engineer check in reference 1.4. Part 5's staff-engineer bar still points at it.
- [ ] M2: drop the history from the hook-reload lesson.
- [ ] Fresh-context review of the final diff.
- [ ] Write the Review and Resuming From Here sections, then commit the handoff.

## Assumptions

- "Apply all patches" covers the branch, commits, and handoff. It does not cover a push or a pull request.
- The patch text reviewed in the audit is the approved wording.
- The audit's six flags stay open for the user.
