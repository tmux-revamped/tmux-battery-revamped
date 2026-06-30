#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _BATTERY_REVAMPED_POPUP_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/battery/popup.sh"
}

teardown() {
  cleanup_test_environment
}

@test "popup.sh - _tmux seam routes through tmux" {
  _tmux set-option -gq "@probe_opt" "routed"
  [[ "$(get_tmux_option "@probe_opt")" == "routed" ]]
}

@test "popup.sh - battery_popup_card prints cached values" {
  cache_set percent "83"
  cache_set status "discharging"
  cache_set health "96"
  run battery_popup_card
  [[ "${lines[0]}" == "Battery" ]]
  [[ "${output}" == *"Charge    : 83%"* ]]
  [[ "${output}" == *"Status    : discharging"* ]]
  [[ "${output}" == *"Health    : 96%"* ]]
}

@test "popup.sh - battery_popup_command references the dispatcher" {
  BATTERY_REVAMPED_CMD="/x/battery.sh"
  run battery_popup_command
  [[ "${output}" == "/x/battery.sh popup-card"* ]]
  [[ "${output}" == *"read -r -n1 _" ]]
}

@test "popup.sh - battery_show_popup opens through the _tmux seam" {
  _tmux() { echo "$*" > "${TEST_TMPDIR}/popup_call"; }
  battery_show_popup
  grep -q "display-popup" "${TEST_TMPDIR}/popup_call"
  grep -q -- "-E" "${TEST_TMPDIR}/popup_call"
}

@test "popup.sh - battery_show_popup honors custom geometry" {
  set_tmux_option "@battery_revamped_popup_width" "60"
  set_tmux_option "@battery_revamped_popup_height" "20"
  _tmux() { echo "$*" > "${TEST_TMPDIR}/popup_call"; }
  battery_show_popup
  grep -q -- "-w 60" "${TEST_TMPDIR}/popup_call"
  grep -q -- "-h 20" "${TEST_TMPDIR}/popup_call"
}

@test "popup.sh - _doctor_have reports found and missing" {
  has_command() { [[ "$1" == "present_tool" ]]; }
  [[ "$(_doctor_have present_tool)" == "found" ]]
  [[ "$(_doctor_have absent_tool)" == "missing" ]]
}

@test "popup.sh - _battery_sysfs_present runs safely" {
  run _battery_sysfs_present
  [[ "${status}" -eq 0 || "${status}" -eq 1 ]]
}

@test "popup.sh - _doctor_sysfs reports present and absent" {
  _battery_sysfs_present() { return 0; }
  [[ "$(_doctor_sysfs)" == "present" ]]
  _battery_sysfs_present() { return 1; }
  [[ "$(_doctor_sysfs)" == "absent" ]]
}

@test "popup.sh - _doctor_notify_backend picks osascript on macOS" {
  _PLATFORM_OS_CACHE="Darwin"
  [[ "$(_doctor_notify_backend)" == "osascript" ]]
}

@test "popup.sh - _doctor_notify_backend picks notify-send on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { [[ "$1" == "notify-send" ]]; }
  [[ "$(_doctor_notify_backend)" == "notify-send" ]]
}

@test "popup.sh - _doctor_notify_backend reports none without a backend" {
  _PLATFORM_OS_CACHE="Linux"
  has_command() { return 1; }
  [[ "$(_doctor_notify_backend)" == "none" ]]
}

@test "popup.sh - battery_doctor prints a capability report" {
  _PLATFORM_OS_CACHE="Linux"
  run battery_doctor
  [[ "${lines[0]}" == "tmux-battery-revamped doctor" ]]
  [[ "${output}" == *"os             : Linux"* ]]
  [[ "${output}" == *"sysfs battery  :"* ]]
  [[ "${output}" == *"notify backend :"* ]]
}
