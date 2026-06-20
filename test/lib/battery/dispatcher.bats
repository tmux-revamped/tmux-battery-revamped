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
