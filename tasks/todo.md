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
- [ ] Commit the spec and plan.
- [ ] R1/R2: fix and test command guarding and physical formatter containment.
- [ ] R3/R4/R5: simplify installation, upgrades, imports, and provenance.
- [ ] R6-R15: align core, reference, bridge, routing, and explainer.
- [ ] Commit document/install checks and add them to CI.
- [ ] Fresh install/upgrade dry runs and browser verification.
- [ ] Fresh adversarial review; resolve findings and rerun affected checks.
- [ ] Final scoped commit, push, PR, exact-SHA CI, and handoff.

## Assumptions

- Approval covers all 15 fixes and matching tests/docs; no separate approval gate is needed.
- Prefer the existing agent-assisted install path over an installer framework. Retire the unsafe manual recipe instead of duplicating merge logic.
- Keep five hooks and current prerequisites; the filter prevents common accidents and permissions/sandboxing supply the actual boundary.
- Use the conservative second-plan-break stop condition everywhere.
- Use logical commits. No merge or release publication is authorized here.

## Review

- Pre-patch independent security-boundary investigation: running.
- Final independent adversarial review: pending.

## Resuming From Here

- Done: baseline, approved scope, spec, and verification defined.
- Next: regressions and implementation in bounded parallel workstreams.
- Blockers: none.
- Needs decision: none.
