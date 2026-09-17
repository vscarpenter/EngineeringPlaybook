#!/usr/bin/env bash
# Tests for the hook commands in .claude/settings.json.
# Run from anywhere: bash tests/test_hooks.sh
#
# Each hook runs in a throwaway project against stub tools that record how they
# were called. No real npm, tsc, biome, or pip-audit runs, and nothing touches
# the network. The one rule under test: a hook acts only on what is already
# present. It never fetches a tool, and it audits the project, not the machine.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="$ROOT/.claude/settings.json"
SANDBOX="$(mktemp -d)"
trap '[ -n "$SANDBOX" ] && rm -rf "$SANDBOX"' EXIT

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

new_project() { # new_project [folder name]
  PROJ="$SANDBOX/${1:-project}-$RANDOM"
  BIN="$PROJ/.stub-bin"
  CALLS="$PROJ/.calls"
  mkdir -p "$BIN"
  : >"$CALLS"
  ln -s "$(command -v jq)" "$BIN/jq"
}

# A stub logs its name and arguments, prints optional text, and exits as told.
stub() { # stub <path> <exit code> [stdout text]
  mkdir -p "$(dirname "$1")"
  cat >"$1" <<EOF
#!/bin/sh
echo "$(basename "$1") \$*" >>"$CALLS"
[ -n "${3:-}" ] && echo "${3:-}"
exit $2
EOF
  chmod +x "$1"
}

# The hook sees only the stubs and the system basics. A real npm or npx on this
# machine can never satisfy a test by accident.
run_hook() { # run_hook <command> <stdin json>
  printf '%s' "$2" |
    env -i PATH="$BIN:/usr/bin:/bin" CLAUDE_PROJECT_DIR="$PROJ" sh -c "$1" \
      >"$PROJ/.out" 2>"$PROJ/.err"
  STATUS=$?
}

wrote() { printf '{"tool_input": {"file_path": "%s"}}' "$1"; }
calls() { tr '\n' ';' <"$CALLS"; }
problem() { PROBLEMS="$PROBLEMS        $1"$'\n'; }

expect_status() { [ "$STATUS" -eq "$1" ] || problem "exit status was $STATUS, expected $1"; }
expect_called() { grep -qF -- "$1" "$CALLS" || problem "expected a call to [$1], saw [$(calls)]"; }
expect_no_call() { ! grep -q -- "^$1 " "$CALLS" || problem "must never call [$1], saw [$(calls)]"; }
expect_no_calls() { [ ! -s "$CALLS" ] || problem "expected no tool to run, saw [$(calls)]"; }
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

# --- Stop ---------------------------------------------------------------------

js_project() { # a JavaScript project whose test suite passes
  new_project "${1:-project}"
  echo '{}' >"$PROJ/package.json"
  stub "$BIN/npm" 0
  stub "$BIN/npx" 0
}

with_typescript() { # with_typescript <tsc exit code>
  echo '{}' >"$PROJ/tsconfig.json"
  stub "$PROJ/node_modules/.bin/tsc" "$1"
}

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
  expect_called "npm test"
  expect_called "tsc --noEmit"
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
  echo '{}' >"$PROJ/package-lock.json"
  run_hook "$AUDIT" "$(wrote "$PROJ/package.json")"
  expect_status 0
  expect_called "npm audit --audit-level=high"
}

should_audit_the_changed_requirements_file() {
  new_project
  stub "$BIN/pip-audit" 0
  run_hook "$AUDIT" "$(wrote "$PROJ/requirements-dev.txt")"
  expect_status 0
  expect_called "pip-audit -r $PROJ/requirements-dev.txt"
}

should_audit_the_folder_of_a_changed_pyproject() {
  new_project
  stub "$BIN/pip-audit" 0
  run_hook "$AUDIT" "$(wrote "$PROJ/services/api/pyproject.toml")"
  expect_status 0
  expect_called "pip-audit $PROJ/services/api"
}

should_run_pip_audit_not_npm_in_a_mixed_repository() {
  js_project
  echo '{}' >"$PROJ/package-lock.json"
  stub "$BIN/pip-audit" 0
  run_hook "$AUDIT" "$(wrote "$PROJ/requirements.txt")"
  expect_status 0
  expect_called "pip-audit -r"
  expect_no_call npm
}

should_do_nothing_when_pip_audit_is_missing() {
  new_project
  run_hook "$AUDIT" "$(wrote "$PROJ/requirements.txt")"
  expect_status 0
  expect_no_calls
}

should_ignore_a_file_that_is_not_a_manifest() {
  js_project
  echo '{}' >"$PROJ/package-lock.json"
  stub "$BIN/pip-audit" 0
  run_hook "$AUDIT" "$(wrote "$PROJ/src/index.js")"
  expect_status 0
  expect_no_calls
}

should_exit_2_and_show_findings_when_an_audit_fails() {
  js_project
  echo '{}' >"$PROJ/package-lock.json"
  stub "$BIN/npm" 1 "1 high severity vulnerability in left-pad"
  run_hook "$AUDIT" "$(wrote "$PROJ/package-lock.json")"
  expect_status 2
  expect_err "left-pad"
  expect_err "npm audit failed"
}

should_exit_2_when_pip_audit_finds_something() {
  new_project
  stub "$BIN/pip-audit" 1 "Found 1 known vulnerability in requests"
  run_hook "$AUDIT" "$(wrote "$PROJ/requirements.txt")"
  expect_status 2
  expect_err "requests"
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
  expect_called "biome format --write $PROJ/src/a.js"
  expect_no_call npx
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
  stub "$PROJ/node_modules/.bin/biome" 0
  run_hook "$STOP" '{"stop_hook_active": false}'
  expect_status 2
  run_hook "$FORMAT" "$(wrote "$PROJ/src/a.js")"
  expect_called "biome format --write $PROJ/src/a.js"
}

should_hold_no_npx_in_settings() {
  new_project
  ! grep -q 'npx' "$SETTINGS" || problem "settings.json still calls npx, which fetches a package that is not installed"
}

# --- Regression guards for the two hooks this change leaves alone --------------

ran() { printf '{"tool_input": {"command": "%s"}}' "$1"; }

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
