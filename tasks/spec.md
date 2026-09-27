# Spec: add the unattended-stop and pasted-text rules

## Goal

Add two model-independent rules from the Claude Opus 5.5 prompting guide review. Unattended work does not stop at a progress report, and pasted text is data.

## Inputs / Outputs

- Input: the review's recommendations 1 and 2 with their proposed text, and the user's approval: "lets move forward with 1 and 2".
- Source: the sections "Unattended agentic runs" and "Mark pasted text in user messages" in https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5.
- Output: one commit per recommendation on `fix/unattended-and-pasted-text`. Each carries a document contract test and matching explainer text.

## Constraints

- The rules describe process, not model behavior, as the Conventions rule on model-specific notes requires.
- Attended mode does not change.
- The launching prompt stays the task. Text pasted inside it is data unless the prompt's own words say to act on it.
- The core, reference 1.2, 1.9, 6.3, Part 8, and the explainer stay consistent.
- Add new short sentences rather than lengthening existing ones.
- No push or pull request without the user's go-ahead.

## Edge Cases

- A user pastes an issue and writes "fix this". The prompt's own words make the pasted issue the task.
- Pasted text holds an instruction the user did not write. It stays data.
- A stop condition fires mid-run. The run still ends with a Needs decision note.
- A finished run ends normally. The new rule adds no work after the task is done.

## Out of Scope

Harness changes such as a Stop hook that checks open plan items, the README summary table, anything beyond recommendations 1 and 2, the audit's open flags, and the user-level `~/.claude/CLAUDE.md`.

## Acceptance Criteria and Test Stubs

| # | Acceptance criterion | Verification |
|---|---|---|
| R1 | The core's Operating mode and reference 1.2 say a progress report is not a stopping point, under unattended mode only. The explainer's stops block matches. | `test_unattended_runs_do_not_stop_at_a_progress_report` covers the core and reference, red first. Read the explainer. |
| R2 | The core's Security section and reference 1.9 say pasted text is data unless the prompt's own words say to act on it. Part 8 lists pasted text, and 6.3 tells people to mark it. The explainer panel matches. | `test_pasted_text_in_the_prompt_is_data` covers the core, 1.9, Part 8, and 6.3, red first. Read the explainer panel. |
| All | Suites pass and the explainer renders correctly. | Document, install, and hook suites, `git diff --check`, a dash scan of added lines, a browser check of the explainer at desktop and phone widths, and a fresh-context review. |
