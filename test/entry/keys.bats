#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME}/../tmux_helpers.bash"

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  command tmux -S "${HOST}" capture-pane -p -t host || :
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

host_shows() {
  local screen
  screen=$(command tmux -S "${HOST}" capture-pane -p -t host)
  [[ "${screen}" == *"$1"* ]]
}

host_lacks() {
  ! host_shows "$1"
}

stays() {
  local delay
  for delay in 0.1 0.2 0.3 0.4; do
    sleep "${delay}"
    host_shows "$1" || return 1
  done
}

reading() {
  printf '#!/bin/sh\nprintf "%%s\\n" "%s"\n' "$1" >"${STUBS}/pmset"
  printf '#!/bin/sh\nprintf "%%s\\n" "%s"\n' "$2" >"${STUBS}/acpi"
  chmod +x "${STUBS}/pmset" "${STUBS}/acpi"
}

setup() {
  unset BASH_ENV
  ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  STUBS="${BATS_TEST_TMPDIR}/stubs"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}" "${STUBS}"
  PATH="${STUBS}:${PATH}"
  HOST="${TMUX_SOCKET}-host"
}

serve() {
  setup_tmux_server
  tmux set-option -g default-command "env PS1='$ ' sh"
  [[ -z "${1:-}" ]] || tmux set-option -g @battery_revamped_popup_key "$1"
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 40 \
    "env -u TMUX TERM=xterm-256color tmux -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
  tmux run-shell "'${ROOT}/battery-revamped.tmux'"
}

teardown() {
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

@test "keys - prefix M-b shows the battery card with a fresh reading, and it stays until a key" {
  # Arrange
  reading " -InternalBattery-0 (id=1)	77%; discharging; 3:10 remaining present: true" "Battery 0: Discharging, 77%, 03:10:00 remaining"
  serve

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Charge    : 77%"
  wait_for host_shows "[q] close"
  stays "[q] close"
  press q
  wait_for host_lacks "[q] close"
}

@test "keys - the card opens on the key the person set" {
  # Arrange
  reading " -InternalBattery-0 (id=1)	41%; charging; 0:50 remaining present: true" "Battery 0: Charging, 41%, 00:50:00 until charged"
  serve F4

  # Act
  press C-b F4

  # Assert
  wait_for host_shows "Charge    : 41%"
}
