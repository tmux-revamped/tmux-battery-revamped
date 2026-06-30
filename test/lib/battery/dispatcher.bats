#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _BATTERY_REVAMPED_BATTERY_LOADED _BATTERY_REVAMPED_RENDER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/battery.sh"
  read_battery_percentage() { echo "83"; }
  read_battery_status() { echo "discharging"; }
  read_battery_remain() { echo "4:32"; }
  read_battery_watts() { echo "60"; }
  read_battery_cycles() { echo "142"; }
  read_battery_health() { echo "96"; }
}

teardown() {
  cleanup_test_environment
}

@test "battery.sh dispatcher - functions are defined" {
  function_exists main
  function_exists battery_refresh
  function_exists battery_tick
  function_exists battery_max_age
}

@test "battery.sh dispatcher - battery_max_age default is 15" {
  [[ "$(battery_max_age)" == "15" ]]
}

@test "battery.sh dispatcher - battery_max_age honors the interval option" {
  set_tmux_option "@battery_revamped_interval" "30"
  [[ "$(battery_max_age)" == "30" ]]
}

@test "battery.sh dispatcher - battery_refresh caches every field" {
  battery_refresh
  [[ "$(cache_get percent)" == "83" ]]
  [[ "$(cache_get status)" == "discharging" ]]
  [[ "$(cache_get remain)" == "4:32" ]]
  [[ "$(cache_get watts)" == "60" ]]
  [[ "$(cache_get cycles)" == "142" ]]
  [[ "$(cache_get health)" == "96" ]]
}

@test "battery.sh dispatcher - cycles and health render the cache" {
  run main cycles
  [[ "${output}" == "142" ]]
  run main health
  [[ "${output}" == "96%" ]]
}

@test "battery.sh dispatcher - refresh subcommand caches values" {
  main refresh
  [[ "$(cache_get percent)" == "83" ]]
}

@test "battery.sh dispatcher - percentage renders the cached value" {
  run main percentage
  [[ "${output}" == "83%" ]]
}

@test "battery.sh dispatcher - icon_status maps the cached status" {
  run main icon_status
  [[ "${output}" == "-" ]]
}

@test "battery.sh dispatcher - graph draws from the cached percentage" {
  run main graph
  [[ "${output}" == "████████░░" ]]
}

@test "battery.sh dispatcher - remain renders the cached value" {
  run main remain
  [[ "${output}" == "4:32" ]]
}

@test "battery.sh dispatcher - charging_watts renders the cached value" {
  run main charging_watts
  [[ "${output}" == "60W" ]]
}

@test "battery.sh dispatcher - unknown subcommand produces no output" {
  run main bogus
  [[ -z "${output}" ]]
}

@test "battery.sh dispatcher - new functions are defined" {
  function_exists battery_estimate
  function_exists battery_alert_token
  function_exists battery_low_threshold
  function_exists battery_critical_threshold
}

@test "battery.sh dispatcher - low and critical thresholds default and honor options" {
  [[ "$(battery_low_threshold)" == "20" ]]
  [[ "$(battery_critical_threshold)" == "10" ]]
  set_tmux_option "@battery_revamped_low_threshold" "25"
  set_tmux_option "@battery_revamped_critical_threshold" "8"
  [[ "$(battery_low_threshold)" == "25" ]]
  [[ "$(battery_critical_threshold)" == "8" ]]
}

@test "battery.sh dispatcher - refresh computes drain rate across readings" {
  read_battery_percentage() { echo "90"; }
  battery_refresh
  [[ -z "$(cache_get drain_rate)" ]]
  export MOCK_EPOCH=1003600
  read_battery_percentage() { echo "80"; }
  battery_refresh
  [[ "$(cache_get drain_rate)" == "10.0" ]]
}

@test "battery.sh dispatcher - refresh pushes to the history ring" {
  read_battery_percentage() { echo "50"; }
  battery_refresh
  [[ "$(get_tmux_option "@battery_revamped_history")" == "50" ]]
}

@test "battery.sh dispatcher - refresh records the alert level" {
  read_battery_percentage() { echo "5"; }
  read_battery_status() { echo "discharging"; }
  battery_refresh
  [[ "$(get_tmux_option "@battery_revamped_alert_level")" == "critical" ]]
}

@test "battery.sh dispatcher - drain_rate renders the cached value" {
  cache_set drain_rate "12.0"
  run main drain_rate
  [[ "${output}" == "12.0%/h" ]]
}

@test "battery.sh dispatcher - estimate renders from the cached delta" {
  cache_set percent "50"
  cache_set status "discharging"
  cache_set drain_rate "25.0"
  run main estimate
  [[ "${output}" == "2:00" ]]
}

@test "battery.sh dispatcher - sparkline renders the cached history" {
  set_tmux_option "@battery_revamped_history" "50"
  cache_set percent "50"
  run main sparkline
  [[ -n "${output}" ]]
}

@test "battery.sh dispatcher - power_source maps the cached status" {
  cache_set status "discharging"
  cache_set percent "50"
  run main power_source
  [[ "${output}" == "Bat" ]]
}

@test "battery.sh dispatcher - alert_icon renders for the cached level" {
  cache_set percent "5"
  cache_set status "discharging"
  set_tmux_option "@battery_revamped_critical_icon" "CRIT"
  run main alert_icon
  [[ "${output}" == "CRIT" ]]
}

@test "battery.sh dispatcher - popup-card prints from the cache" {
  cache_set percent "77"
  run main popup-card
  [[ "${output}" == *"77%"* ]]
}

@test "battery.sh dispatcher - popup opens through the seam without launching" {
  run main popup
  [[ "${status}" -eq 0 ]]
}

@test "battery.sh dispatcher - doctor prints a report" {
  run main doctor
  [[ "${output}" == *"tmux-battery-revamped doctor"* ]]
}

@test "battery.sh dispatcher - icon and color arms render from the cache" {
  cache_set percent "83"
  cache_set status "discharging"
  set_tmux_option "@battery_revamped_charge_tier7_fg_color" "CFG"
  set_tmux_option "@battery_revamped_charge_tier7_bg_color" "CBG"
  set_tmux_option "@battery_revamped_status_discharging_fg_color" "SFG"
  set_tmux_option "@battery_revamped_status_discharging_bg_color" "SBG"
  run main icon
  [[ -n "${output}" ]]
  run main icon_charge
  [[ -n "${output}" ]]
  run main color_charge_fg
  [[ "${output}" == "CFG" ]]
  run main color_charge_bg
  [[ "${output}" == "CBG" ]]
  run main color_fg
  [[ "${output}" == "SFG" ]]
  run main color_bg
  [[ "${output}" == "SBG" ]]
  run main color_status_fg
  [[ "${output}" == "SFG" ]]
  run main color_status_bg
  [[ "${output}" == "SBG" ]]
}
