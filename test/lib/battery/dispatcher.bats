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

@test "battery.sh dispatcher - a metric renders without a label by default" {
  run battery_labelled percentage "42"

  [[ "${output}" == "42" ]]
}

@test "battery.sh dispatcher - the nerd icon set labels a metric" {
  set_tmux_option "@battery_revamped_icons" "nerd"

  run battery_labelled percentage "42"

  [[ "${output}" == $'\xf3\xb0\x81\xb9'" 42" ]]
}

@test "battery.sh dispatcher - a set label beats the icon set" {
  set_tmux_option "@battery_revamped_icons" "nerd"
  set_tmux_option "@battery_revamped_percentage_label" "X"

  run battery_labelled percentage "42"

  [[ "${output}" == "X 42" ]]
}

@test "battery.sh dispatcher - an empty label removes the icon set's label" {
  set_tmux_option "@battery_revamped_icons" "nerd"
  battery_option_exists() { [[ "${1}" == "@battery_revamped_percentage_label" ]]; }

  run battery_labelled percentage "42"

  [[ "${output}" == "42" ]]
}

@test "battery.sh dispatcher - an empty value renders nothing even with a label" {
  set_tmux_option "@battery_revamped_icons" "nerd"

  run battery_labelled percentage ""

  [ -z "${output}" ]
}

@test "battery.sh dispatcher - only value metrics carry a label" {
  run battery_is_labelled fg_color

  [ "${status}" -eq 1 ]
}

@test "battery.sh dispatcher - main labels a rendered metric" {
  set_tmux_option "@battery_revamped_icons" "nerd"
  battery_render_metric() { echo "42"; }

  run main percentage

  [[ "${output}" == $'\xf3\xb0\x81\xb9'" 42" ]]
}

@test "battery.sh dispatcher - hide on AC renders nothing while plugged in" {
  set_tmux_option "@battery_revamped_hide_on_ac" "1"
  cache_get() { [[ "${1}" == "status" ]] && echo "charging"; }

  run battery_hidden_on_ac

  [ "${status}" -eq 0 ]
}

@test "battery.sh dispatcher - hide on AC still renders on battery power" {
  set_tmux_option "@battery_revamped_hide_on_ac" "1"
  cache_get() { [[ "${1}" == "status" ]] && echo "discharging"; }

  run battery_hidden_on_ac

  [ "${status}" -eq 1 ]
}

@test "battery.sh dispatcher - nothing is hidden by default" {
  cache_get() { [[ "${1}" == "status" ]] && echo "charging"; }

  run battery_hidden_on_ac

  [ "${status}" -eq 1 ]
}

@test "battery.sh dispatcher - main renders nothing on AC when hiding" {
  set_tmux_option "@battery_revamped_hide_on_ac" "1"
  battery_tick() { :; }
  cache_get() { [[ "${1}" == "status" ]] && echo "charged"; }
  battery_render_metric() { echo "80%"; }

  run main percentage

  [ -z "${output}" ]
}

@test "battery.sh dispatcher - the percentage is wrapped when set" {
  set_tmux_option "@battery_revamped_before" "<<"
  set_tmux_option "@battery_revamped_after" ">>"
  battery_tick() { :; }
  battery_render_metric() { echo "80%"; }

  run main percentage

  [[ "${output}" == "<<80%>>" ]]
}

@test "battery.sh dispatcher - an empty percentage is not wrapped" {
  set_tmux_option "@battery_revamped_before" "<<"

  run battery_wrap ""

  [ -z "${output}" ]
}

@test "battery.sh dispatcher - the nerd set picks the charge level glyph" {
  set_tmux_option "@battery_revamped_icons" "nerd"

  run battery_charge_icon 79 discharging

  [[ "${output}" == $'\xf3\xb0\x82\x81' ]]
}

@test "battery.sh dispatcher - the nerd set picks the charging glyph while charging" {
  set_tmux_option "@battery_revamped_icons" "nerd"

  run battery_charge_icon 79 charging

  [[ "${output}" == $'\xf3\xb0\x82\x8a' ]]
}

@test "battery.sh dispatcher - a tier icon option beats the nerd set" {
  set_tmux_option "@battery_revamped_icons" "nerd"
  set_tmux_option "@battery_revamped_charge_tier7_icon" "B7"

  run battery_charge_icon 79 discharging

  [[ "${output}" == "B7" ]]
}

@test "battery.sh dispatcher - the color value comes out of an fg style" {
  run battery_color_value "#[fg=#a6e3a1]"

  [[ "${output}" == "#a6e3a1" ]]
}

@test "battery.sh dispatcher - a bare color passes through" {
  run battery_color_value "green"

  [[ "${output}" == "green" ]]
}

@test "battery.sh dispatcher - the wrapper fills the icon and color tokens" {
  set_tmux_option "@battery_revamped_before" "[{color}|{icon}]"
  set_tmux_option "@battery_revamped_after" "<{color}>"
  set_tmux_option "@battery_revamped_charge_tier7_icon" "B7"
  set_tmux_option "@battery_revamped_charge_tier7_fg_color" "#[fg=#a6e3a1]"
  cache_get() { case "${1}" in percent) echo "79" ;; status) echo "discharging" ;; esac; }

  run battery_wrap "79%"

  [[ "${output}" == "[#a6e3a1|B7]79%<#a6e3a1>" ]]
}

@test "battery.sh dispatcher - every discharging tier has a nerd glyph" {
  local tier
  for tier in 1 2 3 4 5 6 7 8; do
    [[ -n "$(battery_nerd_tier_icon "${tier}" discharging)" ]] || { echo "no glyph for tier ${tier}"; return 1; }
  done
}

@test "battery.sh dispatcher - every charging tier has a charging glyph" {
  local tier
  for tier in 1 2 3 4 5 6 7 8; do
    [[ -n "$(battery_nerd_tier_icon "${tier}" charging)" ]] || { echo "no glyph for tier ${tier}"; return 1; }
    [[ "$(battery_nerd_tier_icon "${tier}" charging)" != "$(battery_nerd_tier_icon "${tier}" discharging)" ]] || { echo "tier ${tier} charging glyph equals its level glyph"; return 1; }
  done
}

@test "battery.sh dispatcher - an empty percentage has no charge icon" {
  run battery_charge_icon "" discharging

  [ -z "${output}" ]
}

@test "battery dispatcher - fixed width pads a value to its widest form" {
  set_tmux_option "@battery_revamped_fixed_width" "on"

  run battery_labelled percentage "9%"

  [[ "${output}" == "  9%" ]]
}

@test "battery dispatcher - natural widths cover the padded metrics" {
  run bash -c 'source "$1"; for m in percentage graph; do printf "%s=%s " "$m" "$(battery_natural_width "$m")"; done' _ "${BATS_TEST_DIRNAME}/../../../src/battery.sh"

  [[ "${output}" == "percentage=4 graph=0 " ]]
}

@test "battery dispatcher - publish writes every published metric in one batch" {
  export PUBLISH_LOG="${TEST_TMPDIR}/publish.log"
  _publish_tmux() { [[ "${1}" == "list-clients" ]] && return 0; printf '%s\n' "$@" > "${PUBLISH_LOG}"; }
  battery_refresh() { return 0; }
  battery_output() { printf 'v-%s' "${1}"; }
  set_tmux_option "@battery_revamped_published" "alpha beta"

  battery_publish

  [[ "$(paste -sd'|' "${PUBLISH_LOG}")" == "set-option|-gq|@battery_revamped_out_alpha|v-alpha|;|set-option|-gq|@battery_revamped_out_beta|v-beta" ]]
}

@test "battery dispatcher - the daemon re-executes after the tick limit" {
  ticker_run() { return 0; }
  _battery_reexec() { echo "reexec" > "${TEST_TMPDIR}/reexec"; }

  battery_daemon

  [[ "$(cat "${TEST_TMPDIR}/reexec")" == "reexec" ]]
}

@test "battery dispatcher - the daemon stops when it loses ownership" {
  ticker_run() { return 1; }
  _battery_reexec() { echo "reexec" > "${TEST_TMPDIR}/reexec"; }

  battery_daemon

  [ ! -f "${TEST_TMPDIR}/reexec" ]
}

@test "battery dispatcher - main daemon runs the ticker" {
  battery_daemon() { echo "daemon" > "${TEST_TMPDIR}/daemon"; }

  main daemon

  [[ "$(cat "${TEST_TMPDIR}/daemon")" == "daemon" ]]
}

@test "battery dispatcher - main start spawns the daemon" {
  _ticker_spawn() { printf '%s' "${1}" > "${TEST_TMPDIR}/spawn"; }

  main start

  [[ "$(cat "${TEST_TMPDIR}/spawn")" == *"/src/battery.sh" ]]
}

@test "battery dispatcher - the metric renderer does not start the daemon" {
  battery_daemon() { echo "daemon" > "${TEST_TMPDIR}/daemon"; }

  battery_render_metric daemon >/dev/null

  [ ! -f "${TEST_TMPDIR}/daemon" ]
}
