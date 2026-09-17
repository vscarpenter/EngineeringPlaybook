# Todo: hooks that act only on what is present

Tier: Non-trivial. It changes the hooks every adopter installs. Vinny approved the design in chat on 2026-09-17: fix the four defects and the format hook, reword 1.9, commit the tests. Spec: `tasks/spec.md`. Branch: `fix/hook-defects`.

The previous task (public release files) merged as PR 1. Its spec and review live in git history at commit `fcd08f4` and before.

## Verification (defined first)

- `bash tests/test_hooks.sh`. Each hook command runs in a throwaway folder against stub `npm`, `npx`, `tsc`, `biome`, and `pip-audit` that record how they were called. Red against today's hooks, then green.
- The session's document checks for the reference, `README.md`, `INSTALL.md`, and the explainer.
- An independent review of the diff against Vinny's request and the spec, by a read-only agent in a fresh context (1.4).

## Plan

- [ ] Write `tests/test_hooks.sh`, confirm red for the right reasons
- [ ] Fix the `Stop` hook
- [ ] Fix the audit hook
- [ ] Fix the format hook
- [ ] Green
- [ ] Reference: 7.5 (two sentences and the example) and 1.9, edited in place
- [ ] `README.md`, `INSTALL.md`, and the explainer
- [ ] Document checks green, line counts unchanged
- [ ] Independent review, then triage
- [ ] Handoff

## Assumptions

- Claude Code runs a hook command through a POSIX shell. The tests use `sh -c`.
- `npm audit` keeps running at the project root, as it did before.
