#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _BATTERY_REVAMPED_ALERTS_LOADED _BATTERY_REVAMPED_TRENDS_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/battery/alerts.sh"
}

teardown() {
  cleanup_test_environment
}

@test "alerts.sh - _osascript body runs through a stubbed binary" {
  osascript() { echo "osa:$*" > "${TEST_TMPDIR}/osa"; }
  _osascript "display notification"
  [[ "$(cat "${TEST_TMPDIR}/osa")" == "osa:-e display notification" ]]
}

@test "alerts.sh - _notify_send body runs through a stubbed binary" {
  notify-send() { echo "ns:$*" > "${TEST_TMPDIR}/ns"; }
  _notify_send "Title" "Body"
  [[ "$(cat "${TEST_TMPDIR}/ns")" == "ns:Title Body" ]]
}

@test "alerts.sh - _notify uses osascript on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  _osascript() { echo "$1" > "${TEST_TMPDIR}/call"; }
  _notify "Battery low" "20%"
  grep -q "display notification" "${TEST_TMPDIR}/call"
}

@test "alerts.sh - _notify uses notify-send on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { [[ "$1" == "notify-send" ]]; }
  _notify_send() { echo "$1|$2" > "${TEST_TMPDIR}/call"; }
  _notify "Battery low" "20%"
  [[ "$(cat "${TEST_TMPDIR}/call")" == "Battery low|20%" ]]
}

@test "alerts.sh - _notify is a no-op without a backend" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 1; }
  run _notify "x" "y"
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "alerts.sh - battery_alert_message formats each level" {
  [[ "$(battery_alert_message critical 5)" == "Critically low: 5%" ]]
  [[ "$(battery_alert_message low 18)" == "Low battery: 18%" ]]
  [[ "$(battery_alert_message full 100)" == "Fully charged: 100%" ]]
  [[ "$(battery_alert_message ok 50)" == "50%" ]]
}

@test "alerts.sh - battery_should_notify fires on a crossing into a level" {
  run battery_should_notify ok low
  [[ "${status}" -eq 0 ]]
}

@test "alerts.sh - battery_should_notify is silent on a repeat level" {
  run battery_should_notify low low
  [[ "${status}" -ne 0 ]]
}

@test "alerts.sh - battery_should_notify ignores non-notifiable levels" {
  run battery_should_notify low ok
  [[ "${status}" -ne 0 ]]
}

@test "alerts.sh - battery_alert_check records the level without notifying when disabled" {
  _PLATFORM_OS_CACHE="Linux"
  _notify() { echo "fired" > "${TEST_TMPDIR}/fired"; }
  battery_alert_check 5 discharging
  [[ "$(get_tmux_option "@battery_revamped_alert_level")" == "critical" ]]
  [[ ! -f "${TEST_TMPDIR}/fired" ]]
}

@test "alerts.sh - battery_alert_check fires once on a crossing when enabled" {
  _PLATFORM_OS_CACHE="Linux"
  set_tmux_option "@battery_revamped_notify" "1"
  _notify() { echo "fired:$2" >> "${TEST_TMPDIR}/fired"; }
  battery_alert_check 5 discharging
  battery_alert_check 5 discharging
  [[ "$(wc -l < "${TEST_TMPDIR}/fired" | tr -d ' ')" == "1" ]]
}

@test "alerts.sh - battery_alert_check stays quiet at a safe level when enabled" {
  _PLATFORM_OS_CACHE="Linux"
  set_tmux_option "@battery_revamped_notify" "1"
  _notify() { echo "fired" > "${TEST_TMPDIR}/fired"; }
  battery_alert_check 80 discharging
  [[ ! -f "${TEST_TMPDIR}/fired" ]]
  [[ "$(get_tmux_option "@battery_revamped_alert_level")" == "ok" ]]
}
