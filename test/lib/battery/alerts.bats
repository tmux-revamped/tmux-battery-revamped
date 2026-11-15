#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _BATTERY_REVAMPED_ALERTS_LOADED _BATTERY_REVAMPED_TRENDS_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/battery/alerts.sh"
  _PLATFORM_OS_CACHE="Linux"
  NOTIFY_CALLS="${TEST_TMPDIR}/calls"
  mkdir -p "${TEST_TMPDIR}/bin"
  printf '#!/bin/sh\nprintf "%%s|" "$@" >>"%s"\nprintf "\\n" >>"%s"\n' "${NOTIFY_CALLS}" "${NOTIFY_CALLS}" >"${TEST_TMPDIR}/bin/notify-send"
  chmod +x "${TEST_TMPDIR}/bin/notify-send"
  PATH="${TEST_TMPDIR}/bin:${PATH}"
}

teardown() {
  cleanup_test_environment
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
  # Arrange
  set_tmux_option "@battery_revamped_low_threshold" "20"

  # Act
  battery_alert_check 5 discharging

  # Assert
  [ "$(get_tmux_option "@battery_revamped_alert_level")" = "critical" ]
  [ ! -e "${NOTIFY_CALLS}" ]
}

@test "alerts.sh - battery_alert_check notifies once on a crossing through the shared notifier" {
  # Arrange
  set_tmux_option "@battery_revamped_notify" "1"

  # Act
  battery_alert_check 5 discharging
  battery_alert_check 5 discharging

  # Assert
  [ "$(cat "${NOTIFY_CALLS}")" = "--|Battery critical|Critically low: 5%|" ]
}

@test "alerts.sh - battery_alert_check stays quiet at a safe level when enabled" {
  # Arrange
  set_tmux_option "@battery_revamped_notify" "1"

  # Act
  battery_alert_check 80 discharging

  # Assert
  [ ! -e "${NOTIFY_CALLS}" ]
  [ "$(get_tmux_option "@battery_revamped_alert_level")" = "ok" ]
}
