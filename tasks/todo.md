Tier: Non-trivial. Fifteen approved fixes change the rules, hooks, and installation contract used by adopters.

# Plan: release-readiness fixes

Branch: `fix/release-readiness`. Baseline: clean `dabdc2a`. The user approved all 15 findings and asked for simple adoption and use. Contract: `tasks/spec.md`.

## Verification defined first

- Baseline: 41/41 hook checks pass under sh; the preceding review verified bash/dash and exact-commit CI.
- Add failing regressions before changing behavior and document contracts.
- Run all committed checks before each commit; inspect changed files and the final diff.
- Fresh agents dry-run installation and independently review the final remediation.

## Plan

- [x] Inspect source, review, and clean baseline; define the contract.
- [x] Commit the spec and plan (`3592caf`).
- [x] R1/R2: guard and physical path checks fixed; 57 regressions pass under sh, bash, and dash.
- [x] R3/R4/R5: simplify installation, upgrades, imports, and provenance; six contract checks pass. Fresh-agent dry runs remain below.
- [x] R6-R15: core/reference/bridge/routing updated; 17 document checks pass. Explainer checklist, quotations, links, and hook descriptions are synchronized.
- [x] Add document/install checks and CI integration; 23 checks pass. Integrated into CI.
- [x] Browser verification: desktop and 390px layout, keyboard Home/End tabs, one selected/visible panel, no horizontal page overflow.
- [x] Fresh install/upgrade dry runs against complete kit `cf04cc0`; no actionable guide failures.
- [x] Fresh adversarial review; no actionable findings or required fix loop.
- [x] Scoped implementation commits pushed and stacked PRs opened: #4, then #5.
- Final handoff is below. Confirm the current-head CI checks from both PRs before reporting completion.

## Assumptions

- Approval covers all 15 fixes and matching tests/docs; no separate approval gate is needed.
- Prefer the existing agent-assisted install path over an installer framework. Retire the unsafe manual recipe instead of duplicating merge logic.
- Keep five hooks and current prerequisites; the filter prevents common accidents and permissions/sandboxing supply the actual boundary.
- Use the conservative second-plan-break stop condition everywhere.
- Use two stacked PRs to keep non-generated-code diffs under 400 lines: safe adoption R1-R5, then rules/explainer R6-R15. No merge or release publication is authorized here.

## Review

- Pre-patch independent security-boundary investigation: confirmed original command variants and physical-path escapes; narrowed fixes to the existing canonical settings without a new runtime dependency.
- Final independent adversarial review: no actionable findings. Fresh reviewer independently ran all 57 hook checks on three shells, all 23 Python checks, and 54 supplemental destructive/safe command probes. No review findings were declined.
- Red evidence: `bash tests/test_hooks.sh` on original settings produced 38 passed/17 failed (Git/rm variants, invalid payloads, missing jq, external symlink tool calls). Missing/erroring grep then produced 55 passed/2 failed with exit 0 instead of 2. `python3 -m unittest discover -s tests -p test_documents.py` initially ran 13 tests with 19 failing subcases. Installation contracts initially had five failures and one missing-contract error across six tests. These failures matched the reviewed defects.
- Green: `python3 -m unittest discover -s tests -p 'test_*.py'` passes 17 document and six install contracts. `HOOK_SH=<sh|bash|dash> bash tests/test_hooks.sh` passes 57 checks per shell, including missing/erroring-matcher regressions. `bash -n tests/test_hooks.sh` and `git diff --check` pass.

- Clean-install evidence: eight fixtures cover no-jq core-only adoption, root/nested/both/symlink Claude layouts, unrelated staged/unstaged/untracked work, unresolved collisions, and interrupted installation. Plans preceded writes; successful source stamps followed verification. Local report: `/private/tmp/engineering-playbook-install-review.kzdqh2/REPORT.md`.
- Upgrade evidence: ordinary and customized migrations from `38c3a77` remove obsolete handlers and preserve project rules/hooks/settings/permissions. Reinstalls are unchanged with unique handlers. Missing/invalid provenance and intentional failed verification keep the prior record. Synthetic guard exits 0/2/2; adapted Stop exits 0/2/0. Local report: `/private/tmp/playbook-upgrade-cf04cc0.grKuMA/REPORT.md`.
- Applicable completion checks: shell syntax, diff hygiene, regression suites, document contracts, fresh review, and browser checks pass. No new runtime dependencies, environment variables, feature flags, or hard-to-reverse architecture were added. Application builds/compiler checks and a new ADR are N/A. Temporary fixture reports remain local; no destructive sample, old hook, dependency install, or live-service action was executed.

## Resuming From Here

- Done: all 15 findings resolved; local suites, fresh install/upgrade rehearsals, browser verification, and fresh adversarial review passed.
- Pull requests: [#4 safe adoption](https://github.com/vscarpenter/EngineeringPlaybook/pull/4), then [#5 rule consistency](https://github.com/vscarpenter/EngineeringPlaybook/pull/5). #5 targets `fix/safe-adoption`; retarget it to `main` after #4 merges. Non-Markdown diffs are 314 and 391 lines.
- Next: maintainer review and merge in that order; no merge, tag, deployment, or release publication performed. Current-head CI results are available on each PR.
- Assumptions: single reviewed installer path, optional hooks, existing runtime only; the shell filter and physical-path checks have the limits documented in README/INSTALL.
- Blockers: none.
- Needs decision: none.
