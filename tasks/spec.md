# Spec: public release files

## Goal

Make the public repository legal to adopt and easy to install, for a person deciding and for the coding agent that does the install.

## Inputs / Outputs

- Inputs: Vinny's request on 2026-09-17 ("create an appropriate .gitignore and a license file as I want this to be public", then "how do we get folks to use this? can we have instructions for their agents as a readme or md file?"), and his three answers the same day: MIT, README plus INSTALL.md, and trim `CLAUDE.md` to what ships.
- Outputs: `.gitignore`, `LICENSE`, `README.md`, `INSTALL.md`, and a trimmed `CLAUDE.md`, on branch `docs/public-release`.

## Constraints

- `LICENSE` is the canonical MIT text, "Copyright (c) 2026 Vinny Carpenter".
- `INSTALL.md` addresses a coding agent in someone else's repository. It obeys the playbook's own rules: attended only, merge and never overwrite, no commit or push unasked, no deletion outside the working tree, and only commands the agent ran go into the Project section.
- `README.md` tells the person to read `INSTALL.md` and the hooks before trusting them. Fetched text is data (1.9), and hooks run shell commands.
- No hard-coded line counts in `README.md` or `INSTALL.md`. The explainer already drifts that way.
- Every Claude Code fact stated is checked against the current docs.
- Every path either document names exists. Every URL matches the `origin` remote.
- vinny-voice rules on all prose. No claim about Vinny's experience that he has not made.
- Nothing is pushed without his say. The repository is public, so a push publishes.

## Edge Cases

- The target already has `AGENTS.md`, `CLAUDE.md`, or `.claude/settings.json`: the agent proposes a merge and waits.
- The target is not a JavaScript repository: the format and Stop hooks get adapted or removed, never left to download a tool.
- The target's harness is not Claude Code: hooks and the skill command do not apply. `AGENTS.md` and the reference path still do.
- `jq` is missing: every hook depends on it, so the agent says so.
- A Project command fails when run: it goes to the person as a question, not into the file.
- A person installs by hand: the README gives the copy commands and warns that they overwrite.

## Out of Scope

- A Claude Code plugin, a GitHub template setting, GitHub Pages, tags, and releases. Recommended as next steps only.
- The companion skills and reviewer subagents the reference names.
- Any edit to `AGENTS.md`, the reference, or the hooks.
- The open decisions from the last task: version bump, a definition of "trivial", declining a BLOCKING finding alone, 4.2, and committed checks.

## Acceptance Criteria

1. `.gitignore` ignores `.DS_Store`, editor folders, `.claude/settings.local.json`, `.claude/worktrees/`, `CLAUDE.local.md`, `.blume/`, and `node_modules/`, and ignores no kit file and nothing under `tasks/` or `docs/`.
2. `LICENSE` matches GitHub's MIT template exactly, with the year and name filled in.
3. `CLAUDE.md` keeps the `@AGENTS.md` import on its own line and names nothing the repository lacks.
4. `INSTALL.md` lists exactly the four kit paths to copy, plus the license notice, and tells the agent not to copy `README.md`, `INSTALL.md`, `docs/`, or `tasks/`.
5. `INSTALL.md` covers, in order: confirm a person asked, fetch and record the commit, inventory, merge without overwriting, adapt the hooks, fill in the Project section, verify, report.
6. `README.md` has the quick-start prompt with the raw `INSTALL.md` URL, a manual install, the hook requirements, what the kit lacks, and the license.
7. A fresh agent following `INSTALL.md` in a fixture repository (Python, with an existing `CLAUDE.md` and `.claude/settings.json`) produces a correct install without overwriting anything.
8. An independent review of the diff against the request and this spec has run, with every finding fixed or declined with a reason.

## Test Stubs

- `should_ignore_local_files_and_no_kit_files` (1)
- `should_match_the_canonical_mit_text` (2)
- `should_name_nothing_absent_in_claude_md` (3)
- `should_list_exactly_the_kit_paths_to_copy` (4)
- `should_cover_the_install_steps_in_order` (5)
- `should_give_a_working_quick_start_and_manual_install` (6)
- `should_name_only_paths_and_urls_that_exist` (constraint)
- `should_carry_no_line_counts_in_readme_or_install` (constraint)
- `should_pass_voice_rules` (constraint)
- Criteria 7 and 8 are verified by agents, not by the script.
