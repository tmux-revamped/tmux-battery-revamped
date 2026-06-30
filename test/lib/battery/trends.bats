#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _BATTERY_REVAMPED_TRENDS_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/battery/trends.sh"
}

teardown() {
  cleanup_test_environment
}

@test "trends.sh - battery_drain_rate computes signed percent per hour" {
  [[ "$(battery_drain_rate 90 0 80 3600)" == "10.0" ]]
  [[ "$(battery_drain_rate 80 0 90 3600)" == "-10.0" ]]
}

@test "trends.sh - battery_drain_rate is empty without a previous reading" {
  [[ -z "$(battery_drain_rate '' 0 80 3600)" ]]
}

@test "trends.sh - battery_drain_rate is empty when time did not advance" {
  [[ -z "$(battery_drain_rate 90 3600 80 3600)" ]]
}

@test "trends.sh - battery_render_drain_rate formats the value" {
  [[ -z "$(battery_render_drain_rate "")" ]]
  [[ "$(battery_render_drain_rate 12.5)" == "12.5%/h" ]]
}

@test "trends.sh - battery_render_drain_rate honors a custom format" {
  set_tmux_option "@battery_revamped_drain_rate_format" "%s pph"
  [[ "$(battery_render_drain_rate 5.0)" == "5.0 pph" ]]
}

@test "trends.sh - battery_estimate_remain time to empty while discharging" {
  [[ "$(battery_estimate_remain 50 25.0 discharging)" == "2:00" ]]
}

@test "trends.sh - battery_estimate_remain time to full while charging" {
  [[ "$(battery_estimate_remain 50 -25.0 charging)" == "2:00" ]]
}

@test "trends.sh - battery_estimate_remain is empty for the wrong sign" {
  [[ -z "$(battery_estimate_remain 50 -25.0 discharging)" ]]
  [[ -z "$(battery_estimate_remain 50 25.0 charging)" ]]
}

@test "trends.sh - battery_estimate_remain is empty on junk input" {
  [[ -z "$(battery_estimate_remain xx 25.0 discharging)" ]]
  [[ -z "$(battery_estimate_remain 50 abc discharging)" ]]
}

@test "trends.sh - battery_history_size defaults and honors the option" {
  [[ "$(battery_history_size)" == "16" ]]
  set_tmux_option "@battery_revamped_history_size" "8"
  [[ "$(battery_history_size)" == "8" ]]
}

@test "trends.sh - battery_spark_push appends to an empty ring" {
  [[ "$(battery_spark_push "" 42 16)" == "42" ]]
}

@test "trends.sh - battery_spark_push appends to an existing ring" {
  [[ "$(battery_spark_push "10,20" 30 16)" == "10,20,30" ]]
}

@test "trends.sh - battery_spark_push trims to the max length" {
  [[ "$(battery_spark_push "10,20,30" 40 3)" == "20,30,40" ]]
}

@test "trends.sh - battery_spark_push defaults max on junk" {
  [[ "$(battery_spark_push "10" 20 xx)" == "10,20" ]]
}

@test "trends.sh - battery_spark_push ignores a junk value" {
  [[ "$(battery_spark_push "10,20" abc 16)" == "10,20" ]]
}

@test "trends.sh - battery_sparkline is empty for an empty ring" {
  [[ -z "$(battery_sparkline "")" ]]
}

@test "trends.sh - battery_sparkline maps values to block glyphs" {
  local low high
  low=$'\xe2\x96\x81'
  high=$'\xe2\x96\x88'
  [[ "$(battery_sparkline "0,100")" == "${low}${high}" ]]
}

@test "trends.sh - battery_sparkline clamps and skips junk" {
  local high
  high=$'\xe2\x96\x88'
  [[ "$(battery_sparkline "150,bad,100")" == "${high}${high}" ]]
}

@test "trends.sh - battery_level classifies discharging thresholds" {
  [[ "$(battery_level 5 discharging 20 10)" == "critical" ]]
  [[ "$(battery_level 15 discharging 20 10)" == "low" ]]
  [[ "$(battery_level 80 discharging 20 10)" == "ok" ]]
}

@test "trends.sh - battery_level classifies charging and charged" {
  [[ "$(battery_level 100 charging 20 10)" == "full" ]]
  [[ "$(battery_level 50 charging 20 10)" == "ok" ]]
  [[ "$(battery_level 100 charged 20 10)" == "full" ]]
}

@test "trends.sh - battery_level handles unknown status and junk" {
  [[ "$(battery_level 50 unknown 20 10)" == "ok" ]]
  [[ "$(battery_level xx discharging 20 10)" == "unknown" ]]
}

@test "trends.sh - battery_level falls back to default thresholds" {
  [[ "$(battery_level 5 discharging aa bb)" == "critical" ]]
}

@test "trends.sh - battery_alert_icon returns configured glyphs" {
  [[ -z "$(battery_alert_icon ok)" ]]
  set_tmux_option "@battery_revamped_critical_icon" "!!"
  set_tmux_option "@battery_revamped_low_icon" "!"
  [[ "$(battery_alert_icon critical)" == "!!" ]]
  [[ "$(battery_alert_icon low)" == "!" ]]
}

@test "trends.sh - battery_power_source labels AC and battery" {
  [[ "$(battery_power_source discharging)" == "Bat" ]]
  [[ "$(battery_power_source charging)" == "AC" ]]
  set_tmux_option "@battery_revamped_source_battery_label" "DC"
  [[ "$(battery_power_source discharging)" == "DC" ]]
}
