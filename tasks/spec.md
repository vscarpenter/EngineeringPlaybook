# Spec: independent review as a completion gate

## Goal

Make independent review a gate on completing work, with defined reviewer inputs and a triage step, so work without a PR still gets reviewed and every finding is either fixed or declined with a recorded reason.

## Inputs / Outputs

- Inputs: the guidance Vinny pasted on 2026-09-17, the design he approved in chat the same day, and the current text of reference sections 1.4, 6.2, and Part 5, plus `AGENTS.md` lines 31 and 74.
- Outputs: edits to `engineering-playbook.md` and `AGENTS.md`, an updated `docs/explainer.html`, and a republished Artifact at the same URL.

## Constraints

- Parts 1 to 5 stay harness-neutral. The reviewer stays read-only (7.4).
- "Report ALL findings" and the 6.3 self-censorship rule stay. The new text adds no severity filter.
- `AGENTS.md` stays 84 lines. Edit lines 31 and 74 in place.
- Every section number cited in `AGENTS.md`, `SKILL.md`, and the new text resolves to a heading.
- New prose follows the vinny-voice rules.
- No change to hooks, `SKILL.md`, or `CLAUDE.md`.

## Edge Cases

- Work with no PR and no git: the rule triggers on completion, not on the PR.
- A trivial change: no reviewer, and self-review still applies.
- Unattended, with a BLOCKING finding the agent cannot resolve: the session ends with a Needs decision note.
- The reviewer is wrong: the agent declines the finding and records why.
- No spec exists, only a ticket: the reviewer gets the ticket.

## Out of Scope

- A version bump and an Appendix A entry. Vinny has not decided.
- CI or hook enforcement that a review happened.
- A new Part 8 red flag, a definition of "trivial", or an edit to 4.2.
- Corrected after review on 2026-09-17: this list first excluded a new stop condition in 1.2. That was wrong. The approved design calls the unattended case a stop condition, so 1.2 and the `AGENTS.md` stop list must name it.
- A committed check script for this repository.
- The `CLAUDE.md` rewrite still pending from earlier on 2026-09-17.

## Acceptance Criteria

1. Section 1.4 gates the review on marking work complete, for non-trivial changes and before any PR. The PR-only sentence is gone.
2. Section 1.4 tells the agent to give the reviewer the original request or ticket and the spec, plus the final diff and repository context, and not the agent's own summary. The author writes the spec, so the spec alone cannot catch a misread request.
3. Section 1.4 defines triage: evaluate each finding, fix the valid ones, rerun affected tests, and record each declined finding with its reason. The PR description is named only "when there is one".
4. Section 1.4 exempts only a trivial change with no PR, so it never contradicts "before any PR". It names the unattended case as a stop condition, and the 1.2 list and the `AGENTS.md` stop list both carry that condition.
5. The 6.2 review prompt reviews against the request and the spec, flags where they differ, asks for a concrete form per finding without suppressing findings that have no failure scenario, covers correctness, spec match, regressions, edge cases, and maintainability, and still says to report all findings.
6. Part 5 lists independent review as a checkbox under Correctness and quality, with its condition stated.
7. `AGENTS.md` mirrors the rule on line 31, points to Playbook 1.4, names the review on the Done means line, and stays 84 lines.
8. The explainer matches the new text: line counts, the to-scale figure, the verbatim Definition of Done list, the Review step, and the unattended stop list. Every quotation still matches the reference.

## Test Stubs

- `should_gate_review_on_completion_not_only_pr` (1)
- `should_give_reviewer_original_requirements_not_a_summary` (2)
- `should_define_triage_and_record_declined_findings` (3)
- `should_exempt_trivial_changes_and_cover_unattended` (4)
- `should_review_against_spec_and_still_report_all_findings` (5)
- `should_list_independent_review_in_definition_of_done` (6)
- `should_mirror_rule_in_agents_md_at_84_lines` (7)
- `should_keep_every_cross_reference_valid` (constraint)
- `should_stay_harness_neutral_and_read_only` (constraint)
- `should_keep_explainer_numbers_and_quotations_true` (8)
- `should_pass_voice_rules_on_new_prose` (constraint)
