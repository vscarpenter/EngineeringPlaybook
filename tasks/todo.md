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
- [x] Review fix (`eb48e45`): make the durable-state line an instruction. The explainer quote still matches reference 1.6.
- [x] Review fix (`6590350`): keep the staff-engineer exit inside the change.
- [x] Write the Review and Resuming From Here sections, then commit the handoff.
- [x] Pushed with `git push -u origin fix/prompt-audit` and opened [#6](https://github.com/vscarpenter/EngineeringPlaybook/pull/6).

## Assumptions

- The user approved the branch, commits, handoff, push, and a pull request.
- The patch text reviewed in the audit is the approved wording.
- Two review fixes change approved wording. Each is its own commit, so the user can drop either in the pull request.
- The audit's six flags stay open for the user.

## Review

- A fresh-context reviewer in an isolated worktree got the owner's words, `tasks/spec.md`, and the diff, and ran the 6.2 review prompt. It found no BLOCKING, 6 IMPORTANT, and 7 NIT findings. It ran both suites itself.
- Fixed: spec contradicted the push request (#1, `a80cc31`). The durable-state line lost its instruction (#2, `eb48e45`). The staff-engineer exit covered code outside the change (#4 and #9, `6590350`). Checks are recorded below (#5). Plan items carry their hashes (#10). The Goal sentence is shorter, and the H2 check names the Conventions rule (#11, `a80cc31`).
- Declined #3: "The model expands scope by default" in 6.3 predates this change and already disagreed with the old item. Editing it widens scope, so it is a follow-up.
- Declined #6: git history records the approved wording. Each finding commit matches its reviewed patch line for line, checked with a comparison that fails on empty input.
- Declined #7: two commit messages compress the guide. It says Opus 4.7 scopes to the request at `low` and `medium` effort. It says Claude Fable 5.1 "delivers what was asked and sometimes more" on open-ended features. Rewriting commits for message wording is not worth it.
- Declined #8: "Context budget" still names the question the paragraph answers. Renaming it would change the `SKILL.md` routing row for no change in behavior.
- Declined #12: the severity note matches the migration guide's advice to report every finding and filter later. The audit kept it on purpose.
- Declined #13: the spec rules out new contract tests. A test for the explainer's memory quote is a follow-up.
- Checks at `6590350`: 23 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check ec9f79b..HEAD` is clean. Added prose has no em or en dashes and no double hyphens. The old wording appears nowhere outside the spec's description of the search. The explainer quote matches reference 1.6 and the core.
- Completion checks: red/green is N/A for prose-only edits (3.1). No dependencies, environment variables, feature flags, or architecture decisions were added. Accessibility is N/A: one explainer sentence changed, with no change to structure.

## Resuming From Here

- Done: four audit findings and two review fixes, committed on `fix/prompt-audit`. Suites pass and the independent review is resolved.
- Pushed to `origin/fix/prompt-audit`. Pull request: [#6](https://github.com/vscarpenter/EngineeringPlaybook/pull/6).
- Next: maintainer review and merge. No merge was performed.
- Follow-ups for the user: the audit's six flags; the 6.3 line "The model expands scope by default"; and a possible test for the explainer's memory quote.
- Blockers: none.
- Needs decision: none.
