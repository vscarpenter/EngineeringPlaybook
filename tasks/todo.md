Tier: Non-trivial. Two new rules change the core, the reference, the explainer, and the document tests that adopters rely on.

# Plan: unattended-stop and pasted-text rules

Branch: `fix/unattended-and-pasted-text`. Baseline: clean `44ab0c7`. The user approved recommendations 1 and 2 from the Opus 5.5 guide review. Contract: `tasks/spec.md`.

## Verification defined first

- Baseline on `44ab0c7`: 23 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check` is clean.
- Each rule gets a document contract test that fails before the edit and passes after it. Record both runs here.
- Check the explainer in a browser at desktop and phone widths, then get a fresh-context review of the final diff.

## Plan

- [x] Record the baseline suites on clean `44ab0c7`.
- [x] Commit the spec and plan (`4dd9f0e`).
- [x] R1: unattended runs do not stop at a progress report. Test first, then the core, reference 1.2, and the explainer.
  - Red: `python3 -m unittest tests.test_documents.DocumentContracts.test_unattended_runs_do_not_stop_at_a_progress_report` failed twice, once for the core and once for the reference: "'progress report is not a stopping point' not found" in the unattended part.
  - Green: the same command passes. The full suite runs 24 tests OK and 57 of 57 hook tests. Commit `c8e9155`.
- [x] R2: pasted text is data. Test first, then the core, reference 1.9, 6.3, Part 8, and the explainer.
  - Red: `python3 -m unittest tests.test_documents.DocumentContracts.test_pasted_text_in_the_prompt_is_data` had three failures: the core and 1.9 lacked the rule, and Part 8 lacked "pasted text".
  - Green: the same command passes. The full suite runs 25 tests OK and 57 of 57 hook tests. Commit `60088e8`.
- [x] Browser check of the explainer, served from 127.0.0.1. At 1731px and in a 386px frame, the stops paragraph and the 1.9 panel render inside the gutters with no page-level horizontal scroll.
  - Keyboard: End on the first failure tab selects and focuses Unsafe input, and exactly one panel shows.
  - The window would not resize, so a same-origin 390px iframe stood in for a phone. The two tables that overflow sit in their own `overflow-x: auto` regions, as before.
- [x] Fresh-context review of the final diff: no BLOCKING, 6 IMPORTANT, 10 NIT.
- [x] Update the spec for the review fixes (`8be16c5`).
- [x] R1 review fix: name the stops that do not count, end on any rule that says to stop, and add the person-only blocker as a stop condition.
  - Red: the strengthened R1 test failed three times, for the core, the reference, and the explainer's stops block.
  - A first green hid a typo, "Oonly", because `[Oo]nly` matched inside it. The test now expects the exact form in each file, failed on the typo, and passed once it was fixed.
  - Green: the full suite runs 25 tests OK and 57 of 57 hook tests. Commit `3e5606f`.
- [x] R2 review fix: pasted text after the maintainer rule, later messages covered, instructions followed only on the user's words, and a tagged Debug template.
  - Red: the strengthened R2 test failed four times: the core, 1.9, the 6.2 Debug template, and the explainer panel. Part 8 and 6.3 already passed.
  - Green: the same command passes. The full suite runs 25 tests OK and 57 of 57 hook tests. Commit `62cce6a`.
- [x] Second browser check: at 1440px, 500px, and 386px the seven stop items, the note, and the 1.9 panel fit the gutters with no page-level horizontal scroll.
- [x] Re-review of the fix diff: no BLOCKING, all six earlier findings resolved, and 1 IMPORTANT and 7 NIT new.
- [x] Re-review fix: the person-only stop names a hook that asks for confirmation, not any blocking hook, and the core points to 1.9.
  - Red: four failures. The confirmation-hook wording was missing from the core, 1.2, and the explainer, and the core had no 1.9 pointer.
  - Green: both tests pass. The full suite runs 25 tests OK and 57 of 57 hook tests.
- [x] Write the Review and Resuming From Here sections, then commit the handoff.
- [x] Pushed with `git push -u origin fix/unattended-and-pasted-text` and opened [#7](https://github.com/vscarpenter/EngineeringPlaybook/pull/7), on the user's go-ahead.

## Assumptions

- The approval covers the proposed rule text from the review, including the 6.3 item, with matching Part 8 and explainer edits so the documents agree.
- The review fixes change the approved wording. Each is its own commit, so the user can drop any of them in review.
- The first approval did not cover a push or a pull request. The user approved both later: "Push and open a PR".

## Review

- First review, in a fresh context and an isolated worktree, using the 6.2 prompt with the owner's words and the spec: no BLOCKING, 6 IMPORTANT, and 10 NIT. It reproduced the red runs and both suites.
- Fixed from the first review: the explainer's closed stop list (#1) and the missing stop for a step only a person can clear (#2), both in `3e5606f`. Also fixed in `62cce6a`: the weaker "unless" wording (#3), the blurred launching-issue order (#4), the untagged Debug template (#5), later messages (#6), and "act on it" blocking pasted evidence (NIT 3). The rule now names more kinds of early stop (NIT 10), the tests use subtests and exact forms (NIT 4), and the plan carries the old follow-ups (NIT 5).
- Declined NIT 1: Part 8 names the failure, pasted text treated as commands. The exception lives in 1.9, as it does for the other items on that list.
- Declined NIT 2: the random-ID tag scheme is a harness mechanic, and Claude Code already adds it. Permissions and sandboxing stay the boundary (7.5).
- Declined NIT 6: the `60088e8` message keeps its first wording. `62cce6a` records the change.
- Declined NIT 7 and NIT 8 as out of scope: the core's missing "When you cannot tell" sentence and the README row. The core now points to 1.9, which holds that sentence.
- Declined NIT 9: in the browser the note sits under the list in body ink and reads as a closing note.
- Re-review of the fix diff: no BLOCKING, and all six findings resolved. It found that "a blocking hook" also matched the Stop hook, which sends the agent back to fix failing tests. Fixed in `8d8569d`, which also adds the core's 1.9 pointer and tests for "Do not work around it" and the old wording.
- Declined from the re-review: NIT 5 and NIT 6 need no change. The Review template's inline slot (NIT 7) is a follow-up. Presence tests still pass under some contradictions (NIT 8). The new guards catch only the old phrases.
- Parked for the user (NIT 3): the person-only stop ends the run at once. The alternative is to finish work that does not depend on the blocker first. The default keeps the conservative stop.
- Known cost: a `PreToolUse` false positive, such as a grep that mentions a blocked phrase, now ends an unattended run. That is the conservative outcome.
- Checks at `8d8569d`: 25 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check 44ab0c7..HEAD` is clean. Shipped additions have no em dashes, en dashes, or double hyphens. No stale wording remains in the core, bridge, reference, explainer, README, or install guide.
- Completion checks: red and green runs are recorded for each rule and fix. No dependencies, environment variables, feature flags, or architecture decisions were added. Browser checks passed at desktop and phone widths, including keyboard tab selection.

## Resuming From Here

- Done: both rules, the review and re-review fixes, and the handoff are committed on `fix/unattended-and-pasted-text`. Suites pass and both reviews are resolved.
- Pushed to `origin/fix/unattended-and-pasted-text`. Pull request: [#7](https://github.com/vscarpenter/EngineeringPlaybook/pull/7).
- Next: maintainer review and merge. No merge was performed.
- Follow-ups for the user: the parked NIT 3 choice above. The README row "Fetched text is data". The 6.2 Review template's inline request slot. From PR #6: the audit's six flags, the 6.3 line "The model expands scope by default", and a test for the explainer's memory quote.
- Blockers: none.
- Needs decision: none.
