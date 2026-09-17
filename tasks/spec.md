# Spec: hooks that act only on what is present

## Goal

Fix five defects in the shipped hooks and three wrong statements in the reference, so an adopter's hooks never fetch a tool, never audit the wrong thing, and block when they claim to.

## Inputs / Outputs

- Inputs: Vinny's request on 2026-09-17 ("let's fix the four hook defects and the reference wording"), and his three answers the same day: fix the format hook too, reword reference 1.9 to a conditional, and commit the tests as `tests/test_hooks.sh`.
- Outputs: `.claude/settings.json`, `tests/test_hooks.sh`, four reference lines (1.9 and 7.5), and the documents that describe the hooks: `README.md`, `INSTALL.md`, and `docs/explainer.html`. Branch `fix/hook-defects`.

## The rule behind every fix

A hook acts only when the tool and the input it needs are already present. It never fetches a tool. It audits the project, never the machine.

## Constraints

- No `npx` anywhere in `.claude/settings.json`.
- Every hook stays a POSIX `sh` one-liner that reads its input with `jq`.
- The `stop_hook_active` check stays first in the `Stop` hook.
- The `PreToolUse` and `SessionStart` hooks do not change.
- Reference edits stay on their existing lines, so the line counts on the explainer do not drift.
- Each corrected statement about Claude Code or `pip-audit` is checked against its docs.
- The tests use stub executables on `PATH`. They run no real `npm`, `tsc`, or `pip-audit`, and need no network.
- vinny-voice rules on all prose.

## Edge Cases

- `tsconfig.json` exists but TypeScript is not installed: no type check, and nothing fetched.
- `package.json` changes in a project with no `package-lock.json`: no audit, no failure.
- `requirements.txt` changes in a repository that also has a `package.json`: `pip-audit` runs, `npm audit` does not.
- `pip-audit` is not installed: the hook does nothing.
- The formatter fails: the write still stands and nothing blocks.
- A file that is not a manifest changes: the audit hook does nothing.
- `CLAUDE_PROJECT_DIR` has spaces in its path.

## Out of Scope

- A secret-scanning hook. Vinny chose to reword 1.9 instead.
- Audit support for pnpm, yarn, and uv. The hook drops the two triggers it cannot serve.
- Monorepo lockfile discovery. `npm audit` still runs at the project root.
- Any change to `AGENTS.md` or `CLAUDE.md`.
- The decisions still open from earlier tasks: a version bump, a definition of "trivial", declining a BLOCKING finding alone, 4.2, a release tag, and publishing the explainer.

## Acceptance Criteria

1. The `Stop` hook exits 2 when the type check fails, and names the type check in its message.
2. The `Stop` hook runs the type check only through `node_modules/.bin/tsc`, and only when `tsconfig.json` exists. It never calls `npx`.
3. The `Stop` hook still exits 0 when `stop_hook_active` is true, exits 0 with no `package.json`, and exits 2 when the tests fail.
4. The audit hook runs `npm audit --audit-level=high` only when the changed file is `package.json` or `package-lock.json` and a `package-lock.json` exists.
5. The audit hook runs `pip-audit -r <file>` for a changed requirements file, and `pip-audit <folder>` for a changed `pyproject.toml`. It never runs bare `pip-audit`.
6. The audit hook picks its tool from the changed file, not from which manifests exist.
7. The audit hook exits 2 when an audit fails, and sends the audit output to stderr so the agent can read it.
8. The format hook runs only `node_modules/.bin/biome`, never `npx`, and never blocks.
9. Reference 7.5 says what exit code 2 does for each event, and states the limit of 8 consecutive blocks. Reference 1.9 promises no hook the kit lacks. The 7.5 example matches the shipped hooks. The reference keeps its line count.
10. `README.md` and `INSTALL.md` describe the hooks as they now behave, drop the defect disclosures, and say how to run the tests. The explainer's hook table matches.
11. An independent review of the diff against the request and this spec has run, with every finding fixed or declined with a reason.

## Test Stubs

- `should_exit_2_when_the_type_check_fails` (1)
- `should_name_the_type_check_in_its_message` (1)
- `should_never_call_npx_when_typescript_is_absent` (2)
- `should_skip_the_type_check_when_there_is_no_tsconfig` (2)
- `should_exit_0_when_stop_hook_active_is_true` (3)
- `should_exit_0_when_there_is_no_package_json` (3)
- `should_exit_2_when_the_tests_fail` (3)
- `should_exit_0_when_tests_and_types_pass` (3)
- `should_skip_npm_audit_when_there_is_no_lockfile` (4)
- `should_run_npm_audit_high_when_a_lockfile_exists` (4)
- `should_audit_the_changed_requirements_file` (5)
- `should_audit_the_folder_of_a_changed_pyproject` (5)
- `should_run_pip_audit_not_npm_in_a_mixed_repository` (6)
- `should_do_nothing_when_pip_audit_is_missing` (5)
- `should_ignore_a_file_that_is_not_a_manifest` (4)
- `should_exit_2_and_show_findings_when_an_audit_fails` (7)
- `should_never_call_npx_when_biome_is_absent` (8)
- `should_run_the_local_biome_on_the_written_file` (8)
- `should_exit_0_when_the_formatter_fails` (8)
- `should_work_when_the_project_path_has_spaces` (edge case)
- `should_hold_no_npx_in_settings` (constraint)
- Regression guards for the two unchanged hooks: `PreToolUse` blocks and allows, `SessionStart` prints task files.
- Criteria 9 and 10 are checked by the session's document checks. Criterion 11 by an agent.
