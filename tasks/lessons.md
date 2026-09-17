# Lessons

Corrections and gotchas for this repository. Prune when it grows past a screen.

## Tooling

- A bare `npx <name>` runs whatever package owns that name on npm. `npx biome` fetched an unrelated `biome@0.3.3`, and the hook's `|| true` hid it. Use the scoped name, `@biomejs/biome`, and check the npx cache after changing a hook.
- Claude Code normally picks up hook edits through its file watcher, with no restart. An earlier version of this lesson said hooks load once at session start. That was out of date. Check the current docs before stating how the harness behaves.
- Exit code 2 blocks only where the event can block. On `PostToolUse` the tool already ran, so exit 2 shows stderr to the model and blocks nothing.
- In shell, `a && b || true` swallows a failure of `b`. The shipped `Stop` hook has that shape around `tsc`, so a type error never blocks. Use `! a || b`.
- The `PreToolUse` hook matches the raw command string. A Bash command that only mentions a blocked phrase, even inside quotes, gets blocked.
- macOS `/usr/bin/tidy` dates from 2006 and rejects HTML5 elements. Validate HTML with a parser check, not with `tidy`.
- Pipe command output. Do not write temp files to `/tmp` and delete them. Use the session scratchpad when a file is needed.

## Hooks

- A hook should act only on tools and inputs that are already present. Call `node_modules/.bin/<tool>`, never `npx <tool>`. Check that a lockfile or a config exists before running the tool that needs it.
- Pick the tool from the file that changed, not from which manifests exist. The old audit hook ran `npm audit` when a Python requirements file changed.
- Test a hook with stub tools on `PATH` that log every call. Then a test can assert that something never ran, which an exit code cannot show.
- Read a tool's security model before wiring it into a hook. `pip-audit -r <file>` is "functionally equivalent to `pip install -r`", so it downloads and builds what it audits. A fix that made the audit correct also made it execute code on every manifest edit.
- A stub that logs `$*` flattens its arguments, so a test passes with the quotes removed. Log each argument in its own brackets, then mutate the hook and watch a test fail.
- `cd ""` succeeds. Test that a variable is set before using it as a directory.
- `jq -e` exits non-zero for a missing key and for invalid JSON alike. A guard built on it treats a broken file as an absent setting. Read the value with `jq -r '... // empty'` and handle a jq failure on its own.
- A prefix match such as `"$p"/*` is text. A path with a `..` step passes it and leaves the folder. Reject `..` steps as well.
- After fixing a hook, mutate it on a copy and run the tests with `SETTINGS=<copy>`. A guard that no mutation can break has no test.
- Match a file by its base name, `${f##*/}`. `*package.json` also matches `my-package.json` and everything under `node_modules/`.
- Biome finds its config from the working directory, and Claude's working directory follows its last `cd`. A format hook has to `cd` to the project root and skip files outside it.
- `bash tests/test_hooks.sh` before and after any change to `.claude/settings.json`. `HOOK_SH=dash` runs the hooks under another shell, and `SETTINGS=<file>` tests another settings file.
- A live format hook rewrites the file you just edited. After editing `settings.json`, check `git diff --numstat`. `jq --indent 2 .` restores the layout.

## Editing the kit

- `docs/explainer.html` hard-codes line counts from `AGENTS.md` and the reference: two hero facts, two sentences, and every segment of the to-scale figure. Any edit to those files makes the page wrong. Recompute from the headings and update the page in the same change.
- The page's Definition of Done list quotes Part 5 word for word. A new checkbox in Part 5 needs the same item on the page.
- `AGENTS.md` cites its own length on the page (84 lines). Edit its lines in place to hold the count, or update the page.
- Give a reviewer the owner's words and the spec, never your own summary. A reviewer handed the author's framing reviews the framing.
- A pointer such as "(1.2)" is a claim about what that section says. Before citing a closed list, check the list carries the item. A heading that exists is not enough.
- `AGENTS.md` tells agents to open the reference only when a line points there. A rule in the core file with no "Playbook N.N" pointer hides its own detail.
- When a spec excludes an edit, check the exclusion against the approved design, not against the edit count quoted at approval. A count is an estimate. The design is the contract.
- Presence tests pass under contradiction. For prose rules, add a structural test for each cross-section claim, and let the independent review hunt for the rest.
- Appending a clause to a long existing sentence makes it longer. Add a new short sentence.

## Writing instructions for other people's agents

- Test an install guide by having a fresh agent follow it in a fixture repository. The first dry run found 18 problems that 9 passing checks missed.
- An approval gate covers only what comes after it. Check everything an agent can do before the gate: running commands, not only writing files. A stranger's manifest can hold a deploy or a publish.
- A URL handed to an agent can arrive as a summary, because fetch tools often pass the page through a small model. Tell the agent to clone and read the file.
- Plan first, ask once, write once. A gate placed between two edits approves a file that never lands.
- Rewriting a guide after its dry run voids the dry run. Run it again on the final text.
- Build traps into fixtures: a declared tool that is not installed, a `deploy` script that leaves a marker, a symlinked `CLAUDE.md`, a settings file that needs a JSON comma.
- A subagent runs under this project's hooks, even when it works in another folder. The Biome hook reformatted a fixture's JSON to tabs.
- A word-match test needs word boundaries. "overwrite" matched a search for the "Write" step.

## Front end

- Never put bare text beside an element inside a grid container. Each becomes its own grid item, and the text lands in the narrow column. Position the marker, or wrap the content.
- Besley's tabular zero ignores the weight axis. Drop `tabular-nums` where a "0" appears in Besley.
- Native `scroll-target-group` maps the end of a page proportionally, so short final sections light up early. Use an `IntersectionObserver` on the viewport's middle band.
- A scroll-scrubbed animation can rest half finished. For a mark or reveal, trigger a timed animation once on entry.
- Anything drawn with `background` vanishes under `forced-colors: active`. Check figures and selected states, not only text.
- Automated Chrome windows throttle frames. A mid-animation screenshot is not proof of a stuck animation. Capture again without scrolling.
