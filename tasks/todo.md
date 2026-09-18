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
- [x] R6-R15: core/reference/bridge/routing updated; 17 document checks pass. Explainer synchronization is being verified.
- [x] Add document/install checks and CI integration; 23 checks pass. Commit after integration verification.
- [ ] Fresh install/upgrade dry runs and browser verification.
- [ ] Fresh adversarial review; resolve findings and rerun affected checks.
- [ ] Final scoped commit, push, PR, exact-SHA CI, and handoff.

## Assumptions

- Approval covers all 15 fixes and matching tests/docs; no separate approval gate is needed.
- Prefer the existing agent-assisted install path over an installer framework. Retire the unsafe manual recipe instead of duplicating merge logic.
- Keep five hooks and current prerequisites; the filter prevents common accidents and permissions/sandboxing supply the actual boundary.
- Use the conservative second-plan-break stop condition everywhere.
- Use two stacked PRs to keep non-generated-code diffs under 400 lines: safe adoption R1-R5, then rules/explainer R6-R15. No merge or release publication is authorized here.

## Review

- Pre-patch independent security-boundary investigation: confirmed original command variants and physical-path escapes; narrowed fixes to the existing canonical settings without a new runtime dependency.
- Final independent adversarial review: pending.
- Red evidence: hook regressions on original settings produced 38 passed/17 failed; document contracts initially failed 19 subcases across 13 tests; installation contracts initially had five failures and one missing-contract error across six tests. These failures matched the reviewed defects.
- Green: 17 document and six install contracts; 57 hook checks under sh, bash, and dash, including missing/erroring-matcher regressions. Shell syntax and diff checks pass.

## Resuming From Here

- Done: all 15 fixes implemented; local hook and document/install suites pass.
- Next: commit the adoption unit, dry-run installation/upgrades, finish browser checks, and independently review the final diff.
- Blockers: none.
- Needs decision: none.
