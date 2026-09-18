# Spec: make the playbook safe and simple to adopt

## Goal

Resolve all 15 findings from the September 18 release review while keeping installation, daily use, and maintenance simple.

## Inputs / Outputs

- Input: review of `dabdc2a`, R1 through R15; the user's approval: "let's resolve all 15 actionable issues. The goal is to make this as simple as possible to adopt and use".
- Output: corrected hooks, one clear installation/upgrade guide, consistent core/reference/explainer, committed regression checks, and independently reviewed pull requests.

## Constraints

- Keep the existing four-path kit and POSIX shell/jq runtime requirements; add no runtime package.
- Keep one canonical executable hook implementation. Remove the weaker copied JSON example.
- The destructive-command filter is best effort. Harness permissions and sandboxing remain the security boundary; do not claim to parse arbitrary shell safely.
- Preserve legitimate hook behavior: optional tools, quoted paths, working-directory handling, and bounded Stop continuation.
- This approval covers remediation through spec, plan, implementation, and verification without another approval gate.
- Preserve unrelated project files, permissions, hooks, and user edits during installation and upgrades.
- Physical line counts are not a contract. Describe the explainer's structure without freezing document lengths.
- No release tag, merge, or deployment. After verification, push two focused stacked PRs: safe adoption (R1-R5), then rule consistency (R6-R15). Keep each under the repository's 400-line non-generated-code limit.

## Edge Cases

- Quoted home paths, reordered flags, Git global options and deletion/forced refspecs, lowercase SQL, malformed JSON, missing jq.
- File or parent symlinks leaving the repository, a symlinked project root, spaces and quotes in paths.
- Root/nested Claude files, both present, retained symlinks, older/customized hooks, partial installs, missing provenance.
- Staged/unstaged user edits including unrelated changes in a task-owned file, and red-suite recovery.
- Refactors/docs with no changed executable behavior; authorized launching issues versus other issue content.

## Out of Scope

A general shell parser, replacement sandbox, dependency installation, new harness integration, installer framework, broad visual redesign, unrelated engineering opinions, or optional companion skills.

## Acceptance Criteria and Test Stubs

| Finding | Acceptance criterion | Verification |
|---|---|---|
| R1 | Guard blocks supported ordinary destructive forms and fails closed on invalid input/missing parser. Limits are explicit. | Original bypasses, alternate flags/refspecs, malformed payloads, missing jq, normal push/test controls. |
| R2 | Formatter rejects external destinations reached through symlinks; legitimate paths work. | File/parent/root symlink fixtures, spaces/quotes, existing traversal checks. |
| R3 | Approved upgrades replace prior kit hooks and preserve unrelated/customized hooks through explicit resolution. | Clean/reinstall/upgrade dry runs and contract checks. |
| R4 | Claude imports resolve to root AGENTS.md in every supported layout. | Root/nested/both/symlink scenarios. |
| R5 | Colliding/partial installs cannot silently claim the new version. | One reviewed install path; provenance only after final verification. |
| R6 | No second executable hook implementation appears in the reference. | Canonical source pointer and document check. |
| R7 | Read-only reviewer template has no unrestricted shell. | Template tool check; enforced read-only environment documented for execution. |
| R8 | Orientation, staging, and recovery preserve pre-existing changes. | Ownership contract and dirty-checkout scenario review. |
| R9 | Final handoff precedes verification and its scoped commit. | Ordered lifecycle check and scenario review. |
| R10 | Red-first applies to changed behavior; refactors/docs use relevant verification and justified N/A criteria. | Work-type contract checks. |
| R11 | TDD proof records red/green commands and results, not inferred commit ordering. | Review/checklist checks. |
| R12 | All documents stop after the second broken plan. | Cross-document scenario check. |
| R13 | Agents may follow explicit references to required review prompts. | Routing/reference check. |
| R14 | Stop is described as a bounded reminder; blocked handoff differs from successful completion. | Continuation regression and documentation check. |
| R15 | Red flags preserve the authorized-launching-issue exception. | Cross-document authority check. |

## Verification

Extend focused tests and confirm red before implementation. Run hooks under sh/bash/dash, standard-library document/install tests, syntax/diff checks, a browser smoke test, fresh-agent install/upgrade dry runs, and a fresh adversarial final-diff review. CI runs committed checks on Linux and macOS.

Existing test fixtures may gain physical files/directories needed for path validation. Assertions may change only for intentionally narrowed unsafe behavior; none may be removed to get green.
