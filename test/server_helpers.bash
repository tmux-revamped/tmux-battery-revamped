#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/tmux_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/tmux_helpers.bash"

screens() {
  printf 'host screen:\n'
  command tmux -S "${HOST}" capture-pane -p -t host || :
  printf 'options:\n'
  tmux show-options -g | grep battery_revamped || :
  printf 'messages:\n'
  tmux show-messages | tail -n 5 || :
}

wait_for() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    sleep "${delay}"
  done
  "$@" && return 0
  screens
  return 1
}

attached() {
  local clients
  clients=$(tmux list-clients -F x 2>/dev/null)
  [[ -n "${clients}" ]]
}

holds() {
  local now
  now=$(tmux show-option -gqv "@battery_revamped_$1")
  [[ "${now}" == "$2" ]]
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

stand_in() {
  printf '#!/bin/sh\n{ set +x; } 2>/dev/null\n%s\n' "$2" >"${STUBS}/$1"
  chmod +x "${STUBS}/$1"
}

battery() {
  stand_in pmset 'printf "Now drawing from Battery Power\n -InternalBattery-0 (id=1)\t77%%; discharging; 3:10 remaining present: true\n"'
  stand_in system_profiler 'printf "      Wattage (W): 60\n"'
  stand_in ioreg 'printf "    \"DesignCapacity\" = 8579\n    \"CycleCount\" = 92\n    \"AppleRawMaxCapacity\" = 8331\n"'
  power_supply
}

power_supply() {
  local cell="${BATS_TEST_TMPDIR}/sys/class/power_supply/BAT0"
  mkdir -p "${cell}"
  printf '77\n' >"${cell}/capacity"
  printf 'Discharging\n' >"${cell}/status"
  printf '190000000\n' >"${cell}/energy_now"
  printf '60000000\n' >"${cell}/power_now"
  printf '97000000\n' >"${cell}/energy_full"
  printf '100000000\n' >"${cell}/energy_full_design"
  printf '92\n' >"${cell}/cycle_count"
  export REVAMPED_TEST_SYS="${BATS_TEST_TMPDIR}/sys"
}

without_tools() {
  local farm="${BATS_TEST_TMPDIR}/farm" folder name
  mkdir -p "${farm}"
  local IFS=:
  for folder in ${PATH}; do
    [[ -d "${folder}" ]] || continue
    ln -s "${folder}"/* "${farm}/" 2>/dev/null || :
  done
  unset IFS
  for name in pmset acpi system_profiler ioreg osascript notify-send gum; do
    rm -f "${farm:?}/${name}"
  done
  PATH="${STUBS}:${farm}"
}

setup() {
  unset BASH_ENV
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  STUBS="${BATS_TEST_TMPDIR}/stubs"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}" "${STUBS}"
  without_tools
  battery
  setup_tmux_server
  HOST="${TMUX_SOCKET}-host"
  tmux set-option -g default-command "env PS1='$ ' sh"
  tmux respawn-pane -k -t test:0.0 "env PS1='$ ' sh"
  tmux set-option -g status-interval 1
  tmux set-option -g status-left ''
  tmux set-option -g status-right-length 120
  tmux set-option -g @battery_revamped_interval 1
  command tmux -S "${HOST}" -f /dev/null new-session -d -s host -x 120 -y 30 \
    "env -u TMUX TERM=xterm-256color tmux -u -S '${TMUX_SOCKET}' attach-session -t test"
  wait_for attached
}

teardown() {
  local daemon
  daemon=$(tmux show-option -gqv @battery_revamped_ticker_pid 2>/dev/null) || daemon=""
  if [[ "${daemon}" =~ ^[0-9]+$ ]]; then
    pkill -P "${daemon}" 2>/dev/null || :
    kill "${daemon}" 2>/dev/null || :
  fi
  command tmux -S "${HOST}" kill-server 2>/dev/null || :
  rm -f "${HOST}"
  teardown_tmux_server
}

load_plugin() {
  local quoted
  quoted=$(printf '%s' "${1:-${ROOT}}" | sed "s/'/'\\\\''/g")
  tmux run-shell "'${quoted}/battery-revamped.tmux'"
}

setting() {
  set_option "@battery_revamped_$1" "$2"
}

press() {
  local key
  for key in "$@"; do
    command tmux -S "${HOST}" send-keys -t host "${key}"
  done
}

prefix_keys() {
  local table
  table=$(tmux list-keys -T prefix)
  awk '{ for (i = 1; i < NF; i++) { if ($i == "-T") { print $(i + 2); break } } }' <<<"${table}"
}
