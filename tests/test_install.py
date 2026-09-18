"""Check the install guide's copyable contracts without external tools or services."""

from pathlib import Path
import re
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
GUIDE = (ROOT / "INSTALL.md").read_text()
README = (ROOT / "README.md").read_text()


class InstallationContractTests(unittest.TestCase):
    def test_documented_imports_resolve_to_the_same_core(self) -> None:
        rows = re.findall(r"\| `(CLAUDE\.md|\.claude/CLAUDE\.md)` \| `(@[^`]+)` \|", GUIDE)
        self.assertEqual({path for path, _ in rows}, {"CLAUDE.md", ".claude/CLAUDE.md"})
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            core = root / "AGENTS.md"
            core.write_text("shared rules")
            for location, imported in rows:
                bridge = root / location
                bridge.parent.mkdir(parents=True, exist_ok=True)
                bridge.write_text(imported + "\n")
                self.assertEqual((bridge.parent / imported[1:]).resolve(), core.resolve())
                self.assertEqual((bridge.parent / imported[1:]).read_text(), "shared rules")

    def test_manual_recipe_cannot_mix_versions_or_overwrite_provenance(self) -> None:
        self.assertNotRegex(README, r"cp -[Rn]+|rev-parse HEAD\s*>")
        self.assertIn("INSTALL.md", README)
        self.assertIn("same guide for upgrades", README)

    def test_upgrades_replace_only_reviewed_kit_owned_hooks(self) -> None:
        self.assertIn("three-way comparison", GUIDE)
        self.assertIn("previous kit", GUIDE)
        self.assertIn("replace", GUIDE)
        self.assertIn("unrelated project hooks", GUIDE)
        self.assertNotIn("Append each kit matcher group", GUIDE)
        self.assertNotIn("added lines only", GUIDE)

    def test_provenance_is_written_after_verification(self) -> None:
        verify = GUIDE.index("## 5. Verify")
        record = GUIDE.index("## 6. Record and report")
        self.assertLess(verify, record)
        self.assertIn("INSTALLED_FROM", GUIDE[record:])
        self.assertIn("Do not update provenance", GUIDE[verify:record])

    def test_core_only_adoption_does_not_require_hook_dependencies(self) -> None:
        self.assertIn("optional", GUIDE)
        self.assertIn("Only check jq", GUIDE)
        self.assertIn("when installing hooks", GUIDE)

    def test_no_install_commit_or_package_install_is_implicit(self) -> None:
        self.assertIn("Do not commit, push, or install packages", GUIDE)
        self.assertIn("before writing", GUIDE)
        self.assertIn("pre-existing", GUIDE)


if __name__ == "__main__":
    unittest.main()
