# Todo: independent review as a completion gate

Tier: Non-trivial. It changes the contract of a kit that ships, across `AGENTS.md` and the reference. Vinny approved the design in chat on 2026-09-17 and asked for one pass. Spec: `tasks/spec.md`.

## Verification (defined first)

- A check script with one test per stub in the spec. It must fail first, for the right reason, then pass.
- Every quotation on the explainer still matches the reference word for word.
- A read-only reviewer in a fresh context reviews the diff against `tasks/spec.md`. This is the new rule applied to itself.
- The explainer's structural checks from the last task still pass.

## Plan

- [x] Write the check script and confirm red (8 of 11 failing, each on missing new text)
- [x] Edit reference 1.4
- [x] Edit reference 6.2 review prompt
- [x] Edit reference Part 5
- [x] Edit `AGENTS.md` lines 31 and 74
- [x] Confirm green on the playbook tests (10 of 10; `AGENTS.md` held at 84 lines)
- [x] Update the explainer: counts, figure, Definition of Done, Review step
- [x] Confirm green on the explainer tests
- [x] Independent review of the diff, then triage (2 blocking, 13 important, 8 nits)
- [x] Correct the spec, take the tests red again, fix, confirm green (11 of 11)
- [x] Republish the Artifact at the same URL (version 2)
- [x] Handoff: Review, Resuming From Here, lessons, memory

## Assumptions

- No version bump and no Appendix A entry. Vinny called that his decision and has not made it.
- The explainer's line counts get recomputed from the files after every edit to the reference.
- One review round, as approved. The fixes made after the review were not re-reviewed.

## Review

The change landed in eight edits, not the five quoted at approval. The three extra edits all come from one finding, I4, explained below.

### Fixed after review

- B1: `AGENTS.md:31` now ends with "Playbook 1.4." Without the pointer, an agent obeying "do not load it otherwise" never reads the five steps.
- B2: the reviewer now gets the original request or ticket and the spec, and the prompt says to flag where they differ. The author writes the spec, so a spec-only review passes a faithfully built misreading.
- I1: only a trivial change with no PR skips the reviewer. The first wording contradicted "before any PR".
- I2: the Part 5 checkbox states its condition, like its neighbours do.
- I4: the approved design calls the unattended case a stop condition, but the 1.2 list is closed and did not carry it. My spec wrongly put the 1.2 edit out of scope. Corrected the spec, then added the condition to 1.2, to the `AGENTS.md` stop list, and to the explainer's stop list.
- I5, in part: "cannot resolve" is now "can neither fix nor show to be wrong".
- I7, in part: "in the PR description when there is one", and the spec Goal no longer claims every finding gets a recorded outcome.
- I9: step 2 cites 6.2, not all of Part 6.
- I10: "correctness" and "maintainability" are back in the Cover list. Both were in Vinny's original words.
- N2: the explainer said a reviewer is read-only and fresh. The rule says "or". The page now matches. The "Unproven done" panel also mentions triage.
- N4: the 25-word sentence on `AGENTS.md:31` is now 22 words, and it regained its "by".
- N5: "a concrete failure scenario where one exists", so the form cannot suppress a readability nit.
- I13 and N8, in part: two structural tests added. One fails if 1.4 cites a stop condition that 1.2 lacks. One fails if the page's stop list and the 1.2 list differ in length.

### Declined, with reasons

- I3, define "trivial": the gap predates this change. Section 1.3 and the elegance check already gate on "non-trivial" with no definition. A definition is a new edit to 1.3 and needs Vinny's approval.
- I5, the rest: whether an author may ever decline a BLOCKING finding alone is a policy choice beyond the approved design.
- I6, a bounded re-review: Vinny approved a single review round.
- I7, the rest: recording an outcome for every fixed finding adds ceremony with no reader. The diff shows the fixes. `todo.md` resetting per task is existing 1.6 design, and git keeps the history.
- I8: adding declined findings to the 4.2 PR description list is an edit to 4.2, outside the approved scope. Performance and observability were not in Vinny's list.
- I9, the rest: amending the `SKILL.md` gotcha is outside the approved scope.
- I11: the playbook assumes git throughout (1.6, Part 4), so a no-git fallback is speculative for the repositories it targets. When no fresh context is available, the Part 5 box stays unticked, which already means not done.
- I12: the version and Appendix A are Vinny's decision. Appendix A describes what changed from v14 to v1.0, and "independent review before PR" was true of v1.0.
- I13, the rest: committing the structural tests adds a file to a kit that gets copied elsewhere. Recommended, but not approved.
- N1, "review gate" has two meanings: the phrase in 1.2 predates this change, and context separates the two.
- N2, the rest: `CLAUDE.md:10` and the 7.4 example say "before opening a PR", which is still a valid trigger. `CLAUDE.md` is out of scope.
- N3, one name for the reviewer: "subagent" already appears in the old line 122 and in 1.8.
- N6: the 7.4 advice on cheap models and concise summaries predates this change.
- N7: a Part 8 red flag is outside the approved scope.
- N8, the rest: no baseline snapshot exists for the untouched files, so a test cannot prove they are unchanged. The reviewer checked their modification times.

### Deviations

- The explainer's second round of edits ran through a script, so the format hook did not fire on them. Biome left this file unchanged on every earlier write.
- Red-first cannot be proven from history, because this directory has no git. Both red runs are in the session transcript.

## Resuming From Here

- Done: the rule is in 1.2, 1.4, 6.2, and Part 5 of the reference, and on `AGENTS.md` lines 17, 31, and 74. The reference is 640 lines and `AGENTS.md` is 84. The explainer matches and is live as version 2 at https://claude.ai/artifact/2457aNRNQn52x6CQ4zvFyh.
- To republish after an edit: `perl -ne 'print unless /^\s*(<!doctype|<\/?html|<\/?head>|<\/?body>|<meta\s)/i' docs/explainer.html`, then publish the result with that URL.
- Snapshots of the three files before this change sit in the session scratchpad under `before/`. They do not survive the session.
- Blockers: no git repository, so nothing is committed. No test suite lives in the repository. The 11 checks live in the session scratchpad.
- Needs decision, all Vinny's:
  1. Bump to v1.1 and add an Appendix A entry?
  2. Define "trivial" in 1.3? His global tiers already have a definition to borrow.
  3. May an author decline a BLOCKING finding alone, or must it go to a human?
  4. Add declined findings to the 4.2 PR description list, and amend the `SKILL.md` gotcha about Part 6?
  5. Commit the structural checks, so the explainer cannot drift silently?
  6. Do `tasks/` and `docs/` belong in a kit that gets copied into other repositories?
  7. The `CLAUDE.md` rewrite from earlier on 2026-09-17 is still unapplied.
