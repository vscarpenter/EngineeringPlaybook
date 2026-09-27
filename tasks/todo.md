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
  - Green: the full suite runs 25 tests OK and 57 of 57 hook tests.
- [ ] R2 review fix: pasted text after the maintainer rule, later messages covered, instructions followed only on the user's words, and a tagged Debug template.
- [ ] Re-review of the fix diff.
- [ ] Write the Review and Resuming From Here sections, then commit the handoff.
- [ ] Blocked on the user: push the branch and open a pull request.

## Assumptions

- The approval covers the proposed rule text from the review, including the 6.3 item, with matching Part 8 and explainer edits so the documents agree.
- The review fixes change the approved wording. Each is its own commit, so the user can drop either in review.
- The approval does not cover a push or a pull request.
