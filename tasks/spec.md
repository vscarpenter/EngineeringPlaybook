# Spec: apply the prompt-audit fixes

## Goal

Apply the four September 27 prompt-audit findings so the kit's rules stop steering Claude Fable 5.1 toward documented failures.

## Inputs / Outputs

- Input: the audit's four findings (H1, H2, M1, M2) with their reviewed patch text, and the user's requests: "apply all patches", "push when complete", and "open a PR after the push".
- Output: one commit per finding on `fix/prompt-audit`, with the explainer kept in step with the reference, pushed with a pull request.

## Constraints

- Use the reviewed patch text as written, plus fixes the independent review finds in that text. Each such fix is its own commit, listed in the Review section of `tasks/todo.md`.
- Keep the durable-state principle ("state lives in `tasks/` and git") and the staff-engineer bar.
- The explainer quotes the reference word for word, so both change together.
- The user authorized a push and a pull request after the review and the handoff commit.

## Edge Cases

- The explainer's Memory section quotes reference 1.6. Its quote must match the new sentence.
- Part 5 cites the "staff-engineer bar" from 1.4, so step 7 keeps the bar.
- Existing document contracts read the changed sections of the core and reference. None may be weakened.

## Out of Scope

The audit's six flags, which need the user's decision. Also out: new document contract tests, Appendix A, hook settings, and the user-level `~/.claude/CLAUDE.md`.

## Acceptance Criteria and Test Stubs

These are prose-only edits. Verification is rule consistency plus the existing suites (playbook 3.1), not a new failing test.

| Finding | Acceptance criterion | Verification |
|---|---|---|
| H1 | The core and reference no longer tell the agent to stop at a context threshold or prefer a fresh session. The explainer quotes the new reference sentence. | A search for the 80% context wording and "fresh session over compaction" finds nothing. The explainer quote matches reference 1.6. |
| H2 | The 6.3 scope item makes no claim about how current models behave. | Read the item against the Conventions rule on model-specific notes. |
| M1 | Step 7 of the 1.4 checklist keeps the staff-engineer bar and has an exit. | Read the checklist. Part 5's "staff-engineer bar" still points at it. |
| M2 | The lesson keeps the current fact and the check-the-docs rule, without its history. | Read the lesson. |
| All | Suites pass and the diff is clean. | 23 document and install tests, 57 hook tests, `git diff --check`, a dash scan of added lines, and a fresh-context review of the final diff. |
