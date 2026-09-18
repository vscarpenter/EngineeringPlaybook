# Contributing

This repository contains Markdown operating rules, Claude Code hook settings, and a standalone HTML explainer. Read `AGENTS.md` before changing the kit.

Run the local checks with a POSIX shell, Bash, jq, and Python 3:

```bash
bash tests/test_hooks.sh
python3 -m unittest discover -s tests -p 'test_*.py'
git diff --check
```

For a hook change, also run `HOOK_SH=bash bash tests/test_hooks.sh` and `HOOK_SH=dash bash tests/test_hooks.sh`. The tests use disposable fixtures and stub tools; they do not install packages or call live services. CI runs these checks on macOS and Linux.

The document tests check shared contracts, routing, and examples. They supplement independent review; they cannot establish that an agent will interpret every sentence correctly. Installation changes also need fresh-agent dry runs against clean and previously configured fixture repositories.

Open `docs/explainer.html` in a browser after changing it. Check its links, keyboard-operated tabs, narrow layout, and agreement with the reference. There is no application build, package install, or separate compiler/linter for this kit.

Keep executable hooks in `.claude/settings.json`, and link there from examples. Keep the core, reference, installation guide, and explainer consistent. Publish changes through a focused pull request with verification evidence.
