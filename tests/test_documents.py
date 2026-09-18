"""Regression contracts for the playbook's executable examples and operating rules."""

from pathlib import Path
from html import unescape
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "AGENTS.md"
REFERENCE = ROOT / ".claude/skills/engineering-playbook/references/engineering-playbook.md"
ROUTER = ROOT / ".claude/skills/engineering-playbook/SKILL.md"
BRIDGE = ROOT / "CLAUDE.md"
EXPLAINER = ROOT / "docs/explainer.html"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def section(document: str, heading: str) -> str:
    """Read one Markdown section, including its subordinate headings."""
    start = re.search(rf"^(#+) {re.escape(heading)}$", document, re.MULTILINE)
    if start is None:
        raise AssertionError(f"Missing section: {heading}")
    end = re.search(
        rf"^#{{1,{len(start.group(1))}}} ", document[start.end():], re.MULTILINE
    )
    return document[start.end():start.end() + end.start()] if end else document[start.end():]


class DocumentContracts(unittest.TestCase):
    def test_explainer_checklist_matches_reference(self) -> None:
        reference = section(read(REFERENCE), "Part 5: Definition of Done")
        expected = [item.replace("`", "") for item in
                    re.findall(r"^- \[ \] (.+)$", reference, re.MULTILINE)]
        done = re.search(r'<section\b[^>]*id="done"[^>]*>(.*?)</section>',
                         read(EXPLAINER), re.DOTALL)
        self.assertIsNotNone(done)
        items = re.findall(r"<li\b[^>]*>(.*?)</li>", done.group(1), re.DOTALL)
        actual = [" ".join(unescape(re.sub(r"<[^>]+>", "", item)).split())
                  for item in items]
        self.assertTrue(expected)
        self.assertEqual(actual, expected)

    def test_explainer_ids_are_unique_and_fragments_resolve(self) -> None:
        page = read(EXPLAINER)
        ids = re.findall(r'''<[A-Za-z][^>]*\bid=["']([^"']+)["']''', page)
        fragments = re.findall(r'''<a\b[^>]*\bhref=["']#([^"']+)["']''', page)
        self.assertTrue(ids)
        self.assertTrue(fragments)
        self.assertEqual(len(ids), len(set(ids)), "Duplicate HTML IDs")
        self.assertEqual(set(map(unescape, fragments)) - set(map(unescape, ids)), set())

    def test_hook_implementation_has_one_canonical_source(self) -> None:
        hooks = section(read(REFERENCE), "7.5 Hooks (`.claude/settings.json`)")
        self.assertIn(".claude/settings.json", hooks)
        self.assertIn("tests/test_hooks.sh", hooks)
        self.assertRegex(hooks, r"canonical|single source")
        self.assertNotRegex(hooks, r'"command"\s*:')
        self.assertNotIn("```json", hooks)

    def test_reviewer_template_has_only_read_only_tools(self) -> None:
        reviewers = section(read(REFERENCE), "7.4 Subagents (`.claude/agents/*.md`)")
        tools = re.search(r"^tools: (.+)$", reviewers, re.MULTILINE)
        self.assertIsNotNone(tools)
        self.assertEqual({tool.strip() for tool in tools.group(1).split(",")},
                         {"Read", "Grep", "Glob"})
        self.assertRegex(reviewers, r"enforced read-only (?:filesystem|environment)")
        self.assertRegex(reviewers, r"(?:provide|supply|give).*diff")

    def test_orientation_records_staged_and_unstaged_baseline(self) -> None:
        for path, heading in (
            (CORE, "Before you write"),
            (REFERENCE, "1.1 Orientation (required before the first write)"),
        ):
            with self.subTest(path=path):
                orientation = section(read(path), heading)
                self.assertIn("git status", orientation)
                self.assertRegex(orientation, r"\bstaged\b")
                self.assertRegex(orientation, r"\bunstaged\b")
                self.assertRegex(orientation, r"(?:pre-existing|existing).*changes")

    def test_scoped_staging_covers_shared_files_and_recovery(self) -> None:
        for path, heading in (
            (CORE, "Commits, tasks, and handoff"),
            (REFERENCE, "1.6 Context, commits, and handoff"),
        ):
            with self.subTest(path=path):
                commits = section(read(path), heading)
                self.assertRegex(commits, r"[Ss]tage only task-owned (?:changes|hunks)")
                self.assertIn("same file", commits)
                self.assertRegex(commits, r"(?:ask|confirmation|permission).*unrelated")
                self.assertRegex(commits, r"recovery[^.]*ownership|ownership[^.]*recovery")
                self.assertNotIn("Commit all working code", commits)

    def test_handoff_is_written_then_verified_then_committed(self) -> None:
        handoff = section(read(REFERENCE), "1.6 Context, commits, and handoff")
        handoff = handoff.split("**Handoff protocol (required before ending).**", 1)[1]
        steps = re.findall(r"^\d+\. (.+)$", handoff, re.MULTILINE)
        self.assertGreaterEqual(len(steps), 4)
        self.assertRegex(steps[0], r"(?:Write|Update).*Resuming From Here")
        self.assertRegex(steps[1], r"(?:Run|Verify).*verification|Run.*suite")
        self.assertRegex(steps[2], r"Commit.*task-owned.*(?:handoff|state|todo)")
        self.assertRegex(steps[3], r"(?:Confirm|Check).*status")
        core = section(read(CORE), "Commits, tasks, and handoff")
        lifecycle = re.search(r"Before ending:(.+)", core)
        self.assertIsNotNone(lifecycle)
        self.assertLess(lifecycle.group(1).index("Resuming From Here"),
                        lifecycle.group(1).index("verification"))
        self.assertLess(lifecycle.group(1).index("verification"),
                        lifecycle.group(1).index("commit"))

    def test_blocked_handoff_is_recorded_before_recovery_commit(self) -> None:
        handoff = section(read(REFERENCE), "1.6 Context, commits, and handoff")
        recovery = handoff.split("**Blocked handoff.**", 1)[1]
        self.assertLess(recovery.index("tasks/todo.md"), recovery.index("Commit"))
        self.assertIn("failure evidence", recovery)
        self.assertIn("report blocked rather than complete", recovery)

    def test_verification_covers_behavior_refactors_and_documents(self) -> None:
        for path, heading in (
            (CORE, "Build in increments"),
            (REFERENCE, "3.1 Red/green/refactor (changed behavior)"),
        ):
            with self.subTest(path=path):
                testing = section(read(path), heading)
                self.assertRegex(testing, r"changed (?:executable )?behavior")
                self.assertRegex(testing, r"[Rr]efactors?.*before and after")
                self.assertRegex(testing, r"[Dd]ocumentation.*(?:links|examples)")
                self.assertNotIn("you do not yet understand the requirement", testing)
                self.assertNotIn("Run the full suite", testing)

    def test_specs_allow_planned_checks_for_nonbehavioral_work(self) -> None:
        for path, heading in (
            (CORE, "Spec first (non-trivial work)"),
            (REFERENCE, "1.3 Spec-driven development (required for non-trivial work)"),
        ):
            with self.subTest(path=path):
                spec = section(read(path), heading)
                self.assertIn("Test Stubs", spec)
                self.assertIn("verification steps", spec)
                self.assertRegex(spec, r"refactors (?:or|and) documentation")

    def test_done_criteria_allow_justified_inapplicability(self) -> None:
        for path, heading in ((CORE, "Done means"), (REFERENCE, "Part 5: Definition of Done")):
            with self.subTest(path=path):
                done = section(read(path), heading)
                self.assertRegex(done, r"evidence.*justified.*N/A")
                self.assertIn("changed behavior", done)
                self.assertIn("verification", done)
                self.assertNotIn("Each acceptance criterion has at least one passing test", done)

    def test_tdd_evidence_uses_observed_runs_not_commit_order(self) -> None:
        reference = read(REFERENCE)
        testing = section(reference, "3.1 Red/green/refactor (changed behavior)")
        self.assertRegex(testing, r"red command.*failure.*green (?:command|result)")
        self.assertIn("tasks/todo.md", testing)
        review = section(reference, "4.2 Pull requests")
        self.assertIn("red/green evidence", review)
        self.assertNotIn("check commit order", reference)

    def test_second_broken_plan_is_an_unconditional_stop(self) -> None:
        for path, heading in (
            (CORE, "Operating mode"), (REFERENCE, "1.2 Operating modes")
        ):
            with self.subTest(path=path):
                mode = section(read(path), heading)
                self.assertIn("plan has broken twice", mode)
                self.assertNotIn("fix is not obvious", mode)

    def test_routing_permits_explicitly_referenced_prompt_templates(self) -> None:
        routing = section(read(ROUTER), "Gotchas")
        self.assertRegex(routing, r"explicitly referenced.*(?:prompt|section)")
        reference = section(read(REFERENCE), "Part 6: Human Playbook: Prompting")
        self.assertRegex(reference, r"explicitly referenced.*(?:prompt|section)")

    def test_stop_is_a_bounded_reminder_not_a_success_guarantee(self) -> None:
        for path, content in (
            (BRIDGE, read(BRIDGE)),
            (REFERENCE, section(read(REFERENCE), "7.5 Hooks (`.claude/settings.json`)")),
        ):
            with self.subTest(path=path):
                self.assertIn("bounded verification reminder", content)
                self.assertIn("stop_hook_active", content)
                self.assertRegex(content, r"blocked handoff.*successful completion")
                self.assertNotIn("refuse to stop with a failing suite", content)
        self.assertNotIn("Hooks enforce the second half", read(REFERENCE))

    def test_hook_context_claim_includes_output(self) -> None:
        hooks = section(read(REFERENCE), "7.5 Hooks (`.claude/settings.json`)")
        self.assertRegex(hooks, r"output.*(?:uses|consumes).*context")
        self.assertRegex(hooks, r"(?:permissions|sandbox).*(?:boundary|boundaries)")
        self.assertIn("best effort", hooks)

    def test_red_flags_allow_authorized_launching_issues(self) -> None:
        reference = read(REFERENCE)
        flags = section(reference, "Part 8: Red Flags (quick reference)")
        self.assertIn("authorized launching issue", flags)
        self.assertIn("other issues", flags)
        self.assertIn("issue comments", flags)
        for path, heading in (
            (CORE, "Security"), (REFERENCE, "1.9 Agent security")
        ):
            with self.subTest(path=path):
                security = section(read(path), heading)
                self.assertIn("maintainer wrote or labeled", security)
                self.assertIn("issue comments", security)
                self.assertIn("other issues", security)


if __name__ == "__main__":
    unittest.main()
