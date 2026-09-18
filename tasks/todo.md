# Todo: close six gaps in the operating rules

Tier: Non-trivial. It changes rules every adopter's agents load on every session. Vinny approved the scope in chat on 2026-09-17: batch review findings 1, 2, 3, 4, 9, and 10 into one PR. Spec: `tasks/spec.md`. Branch: `fix/rule-gaps`.

The previous task (hook defects) merged as PR 2. Its spec and review live in git history at commit `70719be` and before.

## Verification (defined first)

- Document checks: a shell script with 55 assertions. It checks required and removed phrases in the core, the reference, and the explainer, every line count and Part heading position, and em and en dashes. Red first (33 of 55 failing), then green.
- `bash tests/test_hooks.sh` under `sh`, `bash`, and `dash`, as a regression guard. No hook changed.
- An independent review of the diff against Vinny's request and the spec (1.4). Not run yet. See Not verified.

## Plan

- [x] Baseline: hook tests green on `main` (41 of 41, three shells)
- [x] Write the document checks, confirm red for the right reasons (33 of 55 failing)
- [x] Spec written and committed
- [x] Core and reference edits, in place. `AGENTS.md` still 84 lines, the reference still 640, every Part heading on its line.
- [x] Explainer: two sentences that restated changed rules
- [x] Checks green (55 of 55). Hook tests green (41 of 41, three shells).
- [x] Self-review: re-read every changed line
- [ ] Independent review in a fresh context
- [ ] Open the PR

## Assumptions

- The elegance check's "two or more lines per dependency" was a garbled copy of principle 2.1. Both files now use the 2.1 threshold: the standard library would take more than twice the code.
- The reference moved to "five commits" to match the core and the `SessionStart` hook, which prints five.
- The mode line lives in the launcher's prompt only. An environment variable would be a second interface to document and test.
- The new lines fit on existing lines by merging two pairs of reference bullets: the two test-naming bullets in 3.2, and two scope red flags in Part 8. No rule was dropped.

## Review

### Self-review findings, fixed

- The first draft of the red-suite exit ran past 25 words and hung on a colon. Split into two sentences.
- The red-suite exit allows one commit with a failing suite, which 1.5 and Part 8 otherwise forbid. Reference 1.6 now says that commit is the only exception.

### Behavior changes an adopter will notice

- A pipeline or routine whose prompt lacks `Mode: unattended` now runs attended. Its agent asks a question and the run ends. Add the line to AgentMachinist's prompts and to the nightly routine before this merges.
- The core grew from 1,147 to 1,290 words. Finding 12 (trim "Done means" to a pointer) would pay that back.

### Not verified

- No independent review has run. The session that wrote this had no way to start a fresh-context reviewer. Criterion 9 is open, and the PR should not merge without it.
- The document checks are not committed. Committing them is still Vinny's open decision, and this change adds a second script to that decision.
- The explainer was checked by text only. Nobody opened it in a browser after the edit.
- No agent has run under the new rules. In particular, nobody has watched an unattended agent take the red-suite exit.

## Resuming From Here

- Done: all edits are committed on `fix/rule-gaps`. Nothing is pushed. The work arrives as a patch series, because the session had no GitHub credentials.
- Next: apply the series, run the independent review (6.2 prompt, with the request, the spec, and the diff), fix or decline findings, then open the PR.
- After merge: republish the explainer Artifact (https://claude.ai/artifact/2457aNRNQn52x6CQ4zvFyh). Two of its sentences change.
- Blockers: none.
- Needs decision, all Vinny's:
  1. Finding 5, a definition of "trivial." Recommendation given in chat on 2026-09-17.
  2. Finding 6, declining a BLOCKING finding alone, and a bound on review rounds. Recommendation given in chat on 2026-09-17.
  3. Findings 7, 8, 11, and 12 from the same review: the deny list and a `permissions` block, a harness-neutral CI template, the `SessionStart` budget, and trimming "Done means."
  4. Block `--no-verify` in the `PreToolUse` hook. The rule now exists in prose only.
  5. Carried from the hook task: move the hooks into script files, audit `npm install` run through Bash, and a Python audit that does not install what it audits.
  6. Carried from earlier tasks: a version bump, 4.2, a release tag, publishing the explainer, and committing the document checks.
