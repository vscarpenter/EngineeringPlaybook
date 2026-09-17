# Lessons

Corrections and gotchas for this repository. Prune when it grows past a screen.

## Tooling

- A bare `npx <name>` runs whatever package owns that name on npm. `npx biome` fetched an unrelated `biome@0.3.3`, and the hook's `|| true` hid it. Use the scoped name, `@biomejs/biome`, and check the npx cache after changing a hook.
- Claude Code reads hooks at session start. After editing `.claude/settings.json`, approve the change in `/hooks` or restart before trusting it.
- The `PreToolUse` hook matches the raw command string. A Bash command that only mentions a blocked phrase, even inside quotes, gets blocked.
- macOS `/usr/bin/tidy` dates from 2006 and rejects HTML5 elements. Validate HTML with a parser check, not with `tidy`.
- Pipe command output. Do not write temp files to `/tmp` and delete them. Use the session scratchpad when a file is needed.

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

## Front end

- Never put bare text beside an element inside a grid container. Each becomes its own grid item, and the text lands in the narrow column. Position the marker, or wrap the content.
- Besley's tabular zero ignores the weight axis. Drop `tabular-nums` where a "0" appears in Besley.
- Native `scroll-target-group` maps the end of a page proportionally, so short final sections light up early. Use an `IntersectionObserver` on the viewport's middle band.
- A scroll-scrubbed animation can rest half finished. For a mark or reveal, trigger a timed animation once on entry.
- Anything drawn with `background` vanishes under `forced-colors: active`. Check figures and selected states, not only text.
- Automated Chrome windows throttle frames. A mid-animation screenshot is not proof of a stuck animation. Capture again without scrolling.
