Tier: Non-trivial. Two new rules change the core, the reference, the explainer, and the document tests that adopters rely on.

# Plan: unattended-stop and pasted-text rules

Branch: `fix/unattended-and-pasted-text`. Baseline: clean `44ab0c7`. The user approved recommendations 1 and 2 from the Opus 5.5 guide review. Contract: `tasks/spec.md`.

## Verification defined first

- Baseline on `44ab0c7`: 23 document and install tests pass, 57 of 57 hook tests pass, and `git diff --check` is clean.
- Each rule gets a document contract test that fails before the edit and passes after it. Record both runs here.
- Check the explainer in a browser at desktop and phone widths, then get a fresh-context review of the final diff.

## Plan

- [x] Record the baseline suites on clean `44ab0c7`.
- [ ] Commit the spec and plan.
- [ ] R1: unattended runs do not stop at a progress report. Test first, then the core, reference 1.2, and the explainer.
- [ ] R2: pasted text is data. Test first, then the core, reference 1.9, 6.3, Part 8, and the explainer.
- [ ] Browser check of the explainer.
- [ ] Fresh-context review of the final diff.
- [ ] Write the Review and Resuming From Here sections, then commit the handoff.
- [ ] Blocked on the user: push the branch and open a pull request.

## Assumptions

- The approval covers the proposed rule text from the review, with matching Part 8 and explainer edits so the documents agree.
- The approval does not cover a push or a pull request.
