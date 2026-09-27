Tier: Non-trivial. Four files change, including the core and reference rules that adopters copy.

# Plan: prompt-audit fixes

Branch: `fix/prompt-audit`. Baseline: clean `ec9f79b`. The user approved all four audit patches ("apply all patches"). Contract: `tasks/spec.md`.

## Verification defined first

- Baseline on `ec9f79b`: 23 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check` is clean.
- These edits are prose only, so there is no red test (playbook 3.1). Each commit runs the full suite, and the final diff gets a fresh-context review.

## Plan

- [x] Record the baseline suites on clean `ec9f79b`.
- [x] Commit the spec and plan (`de11251`).
- [x] H1 (`b9086bc`): context budget in the core, reference 1.6, and the explainer. The explainer quote matches reference 1.6.
- [x] H2 (`d1a9bab`): implicit scope in reference 6.3.
- [x] M1 (`6b04f18`): an exit for the staff-engineer check in reference 1.4. Part 5's staff-engineer bar still points at it.
- [x] M2 (`e499f86`): drop the history from the hook-reload lesson.
- [x] Fresh-context review of the final diff: no BLOCKING, 6 IMPORTANT, 7 NIT.
- [x] Update the spec for the push, the pull request, and the review fixes (`a80cc31`).
- [x] Review fix: make the durable-state line an instruction. The explainer quote still matches reference 1.6.
- [ ] Review fix: keep the staff-engineer exit inside the change.
- [ ] Write the Review and Resuming From Here sections, then commit the handoff.
- [ ] Push with `git push -u origin fix/prompt-audit`, then open the pull request.

## Assumptions

- The user approved the branch, commits, handoff, push, and a pull request.
- The patch text reviewed in the audit is the approved wording.
- Two review fixes change approved wording. Each is its own commit, so the user can drop either in the pull request.
- The audit's six flags stay open for the user.
