#!/usr/bin/env bash
# Tests for the hook commands in .claude/settings.json.
#
#   bash tests/test_hooks.sh                      test the shipped hooks
#   HOOK_SH=dash bash tests/test_hooks.sh         run the hooks under another shell
#   SETTINGS=/path/to/settings.json bash tests/test_hooks.sh
#
# Each hook runs in a throwaway project against stub tools that record how they
# were called. No real npm, tsc, or biome runs, and nothing touches the network.
# The one rule under test: a hook acts only on what is already present. It never
# fetches a tool, and it never runs a tool that installs what it audits.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="${SETTINGS:-$ROOT/.claude/settings.json}"
HOOK_SH="$(command -v "${HOOK_SH:-sh}")" || { echo "no such shell: ${HOOK_SH:-sh}" >&2; exit 1; }
command -v jq >/dev/null || { echo "these tests need jq, as the hooks do" >&2; exit 1; }
SANDBOX="$(mktemp -d)" || exit 1
[ -d "$SANDBOX" ] || exit 1
trap 'rm -rf "$SANDBOX"' EXIT

PASSED=0
FAILED=0
PROBLEMS=""

# Find a hook command by a word that only that command contains. Indexes would
# break the day someone reorders the hooks.
hook() { # hook <event> <word>
  jq -r --arg e "$1" --arg w "$2" \
    '[.hooks[$e][].hooks[].command | select(contains($w))][0] // empty' "$SETTINGS"
}

FORMAT="$(hook PostToolUse biome)"
AUDIT="$(hook PostToolUse audit)"
STOP="$(hook Stop stop_hook_active)"
SESSION="$(hook SessionStart tasks/todo.md)"
PRE="$(hook PreToolUse Blocked)"

# The hook's PATH holds the stubs and links to the few real tools the hooks
# use. A real npm, npx, or pip-audit on this machine can never satisfy a test.
new_project() { # new_project [folder name]
  PROJ="$SANDBOX/${1:-project}-$RANDOM"
  BIN="$PROJ/.stub-bin"
  CALLS="$PROJ/.calls"
  RUN_DIR="$PROJ"
  PROJECT_DIR_VALUE="$PROJ"
  mkdir -p "$BIN"
  : >"$CALLS"
  for tool in jq grep cat git; do
    ln -s "$(command -v "$tool")" "$BIN/$tool"
  done
}

# A stub logs its name, each argument in its own brackets, and its working
# directory. Brackets matter: an unquoted path with a space shows up as two.
stub() { # stub <path> <exit code> [stdout text]
  mkdir -p "$(dirname "$1")"
  cat >"$1" <<EOF
#!/bin/sh
line="$(basename "$1")"
for arg in "\$@"; do line="\$line [\$arg]"; done
echo "\$line" >>"$CALLS"
echo "$(basename "$1") ran in \$(pwd -P)" >>"$CALLS.cwd"
[ -n "${3:-}" ] && echo "${3:-}"
exit $2
EOF
  chmod +x "$1"
}

run_hook() { # run_hook <command> <stdin json>
  (
    cd "$RUN_DIR" || exit 99
    printf '%s' "$2" |
      env -i PATH="$BIN" CLAUDE_PROJECT_DIR="$PROJECT_DIR_VALUE" "$HOOK_SH" -c "$1" \
        >"$PROJ/.out" 2>"$PROJ/.err"
  )
  STATUS=$?
}

wrote() { jq -cn --arg p "$1" '{tool_input: {file_path: $p}}'; }
ran() { jq -cn --arg c "$1" '{tool_input: {command: $c}}'; }
calls() { tr '\n' ';' <"$CALLS"; }
problem() { PROBLEMS="$PROBLEMS        $1"$'\n'; }

expect_status() { [ "$STATUS" -eq "$1" ] || problem "exit status was $STATUS, expected $1"; }
expect_called() { grep -qxF -- "$1" "$CALLS" || problem "expected exactly [$1], saw [$(calls)]"; }
expect_no_call() { ! grep -q -- "^$1\( \|\$\)" "$CALLS" || problem "must never call [$1], saw [$(calls)]"; }
expect_no_calls() { [ ! -s "$CALLS" ] || problem "expected no tool to run, saw [$(calls)]"; }
expect_ran_in() { grep -qxF -- "$1 ran in $(cd "$2" && pwd -P)" "$CALLS.cwd" 2>/dev/null || problem "$1 did not run in $2"; }
expect_err() { grep -qF -- "$1" "$PROJ/.err" || problem "stderr lacks [$1]"; }
expect_out() { grep -qF -- "$1" "$PROJ/.out" || problem "stdout lacks [$1]"; }

t() { # t <test function>
  PROBLEMS=""
  "$1"
  if [ -z "$PROBLEMS" ]; then
    PASSED=$((PASSED + 1))
    echo "pass  $1"
  else
    FAILED=$((FAILED + 1))
    echo "FAIL  $1"
    printf '%s' "$PROBLEMS"
  fi
}

js_project() { # a JavaScript project with a test script, and a suite that passes
  new_project "${1:-project}"
  echo '{"scripts": {"test": "node --test"}}' >"$PROJ/package.json"
  stub "$BIN/npm" 0
  stub "$BIN/npx" 0
}

with_lockfile() { echo '{}' >"$PROJ/${1:-package-lock.json}"; }

with_typescript() { # with_typescript <tsc exit code>
  echo '{}' >"$PROJ/tsconfig.json"
  stub "$PROJ/node_modules/.bin/tsc" "$1"
}

# --- Stop ---------------------------------------------------------------------

should_exit_2_when_the_type_check_fails() {
  js_project
  with_typescript 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 2
}

should_name_the_type_check_in_its_message() {
  js_project
  with_typescript 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_err "type check"
}

should_never_call_npx_when_typescript_is_absent() {
  js_project
  echo '{}' >"$PROJ/tsconfig.json"
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  expect_no_call npx
}

should_skip_the_type_check_when_there_is_no_tsconfig() {
  js_project
  stub "$PROJ/node_modules/.bin/tsc" 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  expect_no_call tsc
}

should_exit_0_when_stop_hook_active_is_true() {
  js_project
  stub "$BIN/npm" 1
  run_hook "$STOP" '{"stop_hook_active": true}'
  expect_status 0
  expect_no_calls
}

should_exit_0_when_there_is_no_package_json() {
  new_project
  stub "$BIN/npm" 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  expect_no_calls
}

should_do_nothing_when_npm_is_missing() {
  new_project
  echo '{"scripts": {"test": "node --test"}}' >"$PROJ/package.json"
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
}

should_do_nothing_when_there_is_no_test_script() {
  js_project
  echo '{"scripts": {"build": "tsc"}}' >"$PROJ/package.json"
  stub "$BIN/npm" 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  expect_no_calls
}

should_exit_2_when_the_tests_fail() {
  js_project
  stub "$BIN/npm" 1
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 2
  expect_err "test suite"
}

should_exit_0_when_tests_and_types_pass() {
  js_project
  with_typescript 0
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  expect_called "npm [test]"
  expect_called "tsc [--noEmit]"
  expect_ran_in npm "$PROJ"
}

# --- Audit --------------------------------------------------------------------

should_skip_npm_audit_when_there_is_no_lockfile() {
  js_project
  run_hook "$AUDIT" "$(wrote "$PROJ/package.json")"
  expect_status 0
  expect_no_calls
}

should_run_npm_audit_high_when_a_lockfile_exists() {
  js_project
  with_lockfile
  run_hook "$AUDIT" "$(wrote "$PROJ/package.json")"
  expect_status 0
  expect_called "npm [audit] [--audit-level=high]"
  expect_ran_in npm "$PROJ"
}

should_accept_a_shrinkwrap_as_the_lockfile() {
  js_project
  with_lockfile npm-shrinkwrap.json
  run_hook "$AUDIT" "$(wrote "$PROJ/npm-shrinkwrap.json")"
  expect_status 0
  expect_called "npm [audit] [--audit-level=high]"
}

# pip-audit resolves a requirements file by installing it, so the hook must
# never run it, even when it is installed and a Python manifest changes.
should_never_run_pip_audit() {
  js_project
  with_lockfile
  stub "$BIN/pip-audit" 0
  for manifest in requirements.txt requirements-dev.txt pyproject.toml uv.lock; do
    run_hook "$AUDIT" "$(wrote "$PROJ/$manifest")"
    expect_status 0
  done
  expect_no_calls
}

should_ignore_a_near_miss_file_name() {
  js_project
  with_lockfile
  for name in my-package.json tsconfig.package.json package.json.bak docs/package.json.md; do
    run_hook "$AUDIT" "$(wrote "$PROJ/$name")"
    expect_status 0
  done
  expect_no_calls
}

should_ignore_a_manifest_under_node_modules() {
  js_project
  with_lockfile
  run_hook "$AUDIT" "$(wrote "$PROJ/node_modules/left-pad/package.json")"
  expect_status 0
  expect_no_calls
}

should_ignore_a_manifest_outside_the_project() {
  js_project
  with_lockfile
  run_hook "$AUDIT" "$(wrote "$SANDBOX/elsewhere/package.json")"
  expect_status 0
  expect_no_calls
}

should_ignore_a_file_that_is_not_a_manifest() {
  js_project
  with_lockfile
  run_hook "$AUDIT" "$(wrote "$PROJ/src/index.js")"
  expect_status 0
  expect_no_calls
}

should_exit_2_and_show_findings_when_an_audit_fails() {
  js_project
  with_lockfile
  stub "$BIN/npm" 1 "1 high severity vulnerability in left-pad"
  run_hook "$AUDIT" "$(wrote "$PROJ/package-lock.json")"
  expect_status 2
  expect_err "left-pad"
  expect_err "npm audit failed or found issues"
}

# --- Format -------------------------------------------------------------------

should_never_call_npx_when_biome_is_absent() {
  js_project
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_status 0
  expect_no_calls
}

should_run_the_local_biome_on_the_written_file() {
  js_project
  stub "$PROJ/node_modules/.bin/biome" 0
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_status 0
  expect_called "biome [format] [--write] [$PROJ/src/a.js]"
  expect_no_call npx
}

# Biome finds its config from the working directory, and Claude's working
# directory follows its last cd. From anywhere else Biome would use defaults.
should_run_biome_from_the_project_root() {
  js_project
  stub "$PROJ/node_modules/.bin/biome" 0
  RUN_DIR="$SANDBOX"
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_status 0
  expect_ran_in biome "$PROJ"
}

should_ignore_a_file_outside_the_project() {
  js_project
  stub "$PROJ/node_modules/.bin/biome" 0
  run_hook "$FORMAT" "$(wrote "$SANDBOX/elsewhere/settings.json")"
  expect_status 0
  expect_no_calls
}

should_exit_0_when_the_formatter_fails() {
  js_project
  stub "$PROJ/node_modules/.bin/biome" 1
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_status 0
}

# --- Every hook ---------------------------------------------------------------

should_work_when_the_project_path_has_spaces() {
  js_project "my project"
  with_typescript 1
  with_lockfile
  stub "$PROJ/node_modules/.bin/biome" 0
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 2
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_called "biome [format] [--write] [$PROJ/src/a.js]"
  run_hook "$AUDIT" "$(wrote "$PROJ/package.json")"
  expect_called "npm [audit] [--audit-level=high]"
  expect_ran_in npm "$PROJ"
}

should_pass_a_path_with_a_quote_as_one_argument() {
  js_project
  stub "$PROJ/node_modules/.bin/biome" 0
  run_hook "$FORMAT" "$(wrote "$PROJ/src/it's \"odd\".js")"
  expect_status 0
  expect_called "biome [format] [--write] [$PROJ/src/it's \"odd\".js]"
}

# With the variable unset, a bare cd "" succeeds and the hook would act on
# whatever folder it happens to be in.
should_exit_0_when_the_project_dir_is_unset() {
  js_project
  with_typescript 1
  with_lockfile
  stub "$BIN/npm" 1
  stub "$PROJ/node_modules/.bin/biome" 0
  PROJECT_DIR_VALUE=""
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 0
  run_hook "$AUDIT" "$(wrote "$PROJ/package.json")"
  expect_status 0
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_status 0
  expect_no_calls
}

should_hold_no_npx_in_settings() {
  new_project
  ! grep -q 'npx' "$SETTINGS" || problem "settings.json calls npx, which fetches a package that is not installed"
}

should_hold_no_pip_audit_in_settings() {
  new_project
  ! grep -q 'pip-audit' "$SETTINGS" || problem "settings.json calls pip-audit, which installs what it audits"
}

# --- Regression guards for the two hooks this change leaves alone --------------

should_block_a_forced_push_and_a_hard_reset() {
  new_project
  run_hook "$PRE" "$(ran 'git push --force origin main')"
  expect_status 2
  expect_err "Blocked"
  run_hook "$PRE" "$(ran 'git push -f origin main')"
  expect_status 2
  run_hook "$PRE" "$(ran 'git reset --hard HEAD~1')"
  expect_status 2
}

should_allow_an_ordinary_push_and_a_test_run() {
  new_project
  run_hook "$PRE" "$(ran 'git push origin main')"
  expect_status 0
  run_hook "$PRE" "$(ran 'npm test')"
  expect_status 0
}

should_print_the_task_files_at_session_start() {
  new_project
  mkdir -p "$PROJ/tasks"
  echo "PLAN-MARKER" >"$PROJ/tasks/todo.md"
  echo "LESSON-MARKER" >"$PROJ/tasks/lessons.md"
  run_hook "$SESSION" '{}'
  expect_status 0
  expect_out "PLAN-MARKER"
  expect_out "LESSON-MARKER"
}

should_start_a_session_cleanly_in_an_empty_project() {
  new_project
  run_hook "$SESSION" '{}'
  expect_status 0
}

for name in FORMAT AUDIT STOP SESSION PRE; do
  [ -n "${!name}" ] || { echo "could not find the $name hook in $SETTINGS" >&2; exit 1; }
done

for test_function in $(declare -F | awk '{print $3}' | grep '^should_'); do
  t "$test_function"
done

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
