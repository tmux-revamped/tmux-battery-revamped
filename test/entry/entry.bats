#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../helpers.bash"

ENTRY="${BATS_TEST_DIRNAME}/../../battery-revamped.tmux"

setup() {
  setup_test_environment
  export SPAWN_LOG="${TEST_TMPDIR}/spawn.log"
  nohup() { printf '%s\n' "$*" >> "${SPAWN_LOG}"; }
  export -f nohup
}

teardown() {
  cleanup_test_environment
}

@test "entry - jobs mode turns a placeholder into a dispatcher call" {
  tmux set-option -gq "status-right" "[#{battery_percentage}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file status-right)")" == "[#($(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/src/battery.sh percentage)]" ]]
}

@test "entry - options mode turns a placeholder into an option read" {
  tmux set-option -gq "@battery_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{battery_percentage}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file status-right)")" == "[#{E:@battery_revamped_out_percentage}]" ]]
}

@test "entry - options mode starts the ticker" {
  tmux set-option -gq "@battery_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{battery_percentage}]"

  bash "${ENTRY}"

  [[ "$(cat "${SPAWN_LOG}")" == *"/src/battery.sh daemon" ]]
}

@test "entry - jobs mode starts no ticker" {
  tmux set-option -gq "status-right" "[#{battery_percentage}]"

  bash "${ENTRY}"

  [ ! -f "${SPAWN_LOG}" ]
}

@test "entry - only metrics on the status line are published" {
  tmux set-option -gq "status-right" "#{battery_percentage}"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file @battery_revamped_published)")" == "percentage" ]]
}

@test "entry - a second run keeps metrics already turned into option reads" {
  tmux set-option -gq "@battery_revamped_render" "options"
  tmux set-option -gq "status-right" "[#{E:@battery_revamped_out_percentage}]"

  bash "${ENTRY}"

  [[ "$(cat "$(_mock_opt_file @battery_revamped_published)")" == "percentage" ]]
}

@test "entry - jobs mode releases a running ticker so the daemon exits" {
  # Arrange
  tmux set-option -gq "@battery_revamped_ticker_pid" "4242"
  tmux set-option -gq "status-right" "[#{battery_percentage}]"

  # Act
  bash "${ENTRY}"

  # Assert
  [ ! -f "$(_mock_opt_file @battery_revamped_ticker_pid)" ]
}

make_quoted_plugin() {
  local dir="${TEST_TMPDIR}/it's a plugin"
  mkdir -p "${dir}/src"
  cp -f "${ENTRY}" "${dir}/battery-revamped.tmux"
  printf '#!/usr/bin/env bash\nprintf "%%s" "$1" > "%s/ran"\n' "${TEST_TMPDIR}" > "${dir}/src/battery.sh"
  chmod +x "${dir}/src/battery.sh"
  printf '%s' "${dir}"
}

@test "entry - a plugin path with a space and a quote still runs the dispatcher" {
  # Arrange
  local dir command
  dir="$(make_quoted_plugin)"
  tmux set-option -gq "status-right" "#{battery_percentage}"
  bash "${dir}/battery-revamped.tmux"
  command="$(cat "$(_mock_opt_file status-right)")"
  command="${command#\#(}"
  command="${command%)}"

  # Act
  bash -c "${command}"

  # Assert
  [[ "$(cat "${TEST_TMPDIR}/ran")" == "percentage" ]]
}

@test "entry - the popup key quotes a plugin path with a space and a quote" {
  # Arrange
  local dir
  dir="$(make_quoted_plugin)"
  eval "_entry_mock_tmux() $(declare -f tmux | sed 1d)"
  tmux() {
    if [[ "${1}" == "bind-key" ]]; then
      printf '%s' "${!#}" > "${TEST_TMPDIR}/bound"
      return 0
    fi
    _entry_mock_tmux "$@"
  }
  export -f tmux _entry_mock_tmux
  bash "${dir}/battery-revamped.tmux"

  # Act
  bash -c "$(cat "${TEST_TMPDIR}/bound")"

  # Assert
  [[ "$(cat "${TEST_TMPDIR}/ran")" == "popup" ]]
}
