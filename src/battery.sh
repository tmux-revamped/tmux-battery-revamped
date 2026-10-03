#!/usr/bin/env bash
#
# battery.sh: command dispatcher for tmux-battery-revamped.
#
# Usage: battery.sh <placeholder> | refresh | popup | popup-card | doctor
#   percentage icon icon_charge icon_status
#   color_fg color_bg color_charge_fg color_charge_bg color_status_fg color_status_bg
#   graph remain charging_watts cycles health
#   drain_rate estimate sparkline power_source alert_icon

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="battery_revamped"
export PLUGIN_LOG_NS="battery-revamped"
export BATTERY_REVAMPED_CMD="${PLUGIN_DIR}/src/battery.sh"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/platform.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/cache.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/publish.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/ticker.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/battery/battery.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/battery/render.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/battery/trends.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/battery/alerts.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/battery/popup.sh"

battery_max_age() {
  get_tmux_option "@battery_revamped_interval" "15"
}

battery_low_threshold() {
  get_tmux_option "@battery_revamped_low_threshold" "20"
}

battery_critical_threshold() {
  get_tmux_option "@battery_revamped_critical_threshold" "10"
}

battery_detail_age() {
  get_tmux_option "@battery_revamped_detail_interval" "60"
}

battery_refresh() {
  local now prev_pct prev_ts new_pct new_status
  now=$(_cache_now)
  prev_pct=$(cache_get percent)
  prev_ts=$(get_tmux_option "@${CACHE_PREFIX}_snap_ts" "")
  new_pct=$(read_battery_percentage)
  new_status=$(read_battery_status)
  cache_set percent "${new_pct}"
  cache_set status "${new_status}"
  cache_set_if_stale remain "$(battery_detail_age)" read_battery_remain
  cache_set_if_stale watts "$(battery_detail_age)" read_battery_watts
  cache_set_if_stale cycles "$(battery_detail_age)" read_battery_cycles
  cache_set_if_stale health "$(battery_detail_age)" read_battery_health
  set_tmux_option "@${CACHE_PREFIX}_snap_ts" "${now}"

  local rate
  rate=$(battery_drain_rate "${prev_pct}" "${prev_ts}" "${new_pct}" "${now}")
  [[ -n "${rate}" ]] && cache_set drain_rate "${rate}"

  local ring
  ring=$(get_tmux_option "@battery_revamped_history" "")
  set_tmux_option "@battery_revamped_history" \
    "$(battery_spark_push "${ring}" "${new_pct}" "$(battery_history_size)")"

  battery_alert_check "${new_pct}" "${new_status}"
}

battery_tick() {
  cache_refresh_if_stale percent "$(battery_max_age)" battery_refresh
}

battery_estimate() {
  battery_render_remain \
    "$(battery_estimate_remain "$(cache_get percent)" "$(cache_get drain_rate)" "$(cache_get status)")"
}

battery_alert_token() {
  battery_alert_icon \
    "$(battery_level "$(cache_get percent)" "$(cache_get status)" \
      "$(battery_low_threshold)" "$(battery_critical_threshold)")"
}

battery_hidden_on_ac() {
  [[ "$(get_tmux_option "@battery_revamped_hide_on_ac" "0")" == "1" ]] || return 1
  [[ "$(cache_get status)" != "discharging" ]]
}

battery_wrap() {
  local out="${1}" percent status icon color before after
  [[ -n "${out}" ]] || return 0
  percent="$(cache_get percent)"
  status="$(cache_get status)"
  icon="$(battery_charge_icon "${percent}" "${status}")"
  color="$(battery_color_value "$(battery_charge_color "${percent}" fg)")"
  before="$(get_tmux_option "@battery_revamped_before" "")"
  after="$(get_tmux_option "@battery_revamped_after" "")"
  before="${before//\{icon\}/${icon}}"
  before="${before//\{color\}/${color}}"
  after="${after//\{icon\}/${icon}}"
  after="${after//\{color\}/${color}}"
  printf '%s%s%s' "${before}" "${out}" "${after}"
}

battery_render_metric() {
  local cmd="${1}"
  case "${cmd}" in
    percentage)      battery_render_percentage "$(cache_get percent)" ;;
    icon)            battery_charge_icon "$(cache_get percent)" "$(cache_get status)" ;;
    icon_charge)     battery_charge_icon "$(cache_get percent)" "$(cache_get status)" ;;
    icon_status)     battery_status_icon "$(cache_get status)" ;;
    color_fg)        battery_status_color "$(cache_get status)" fg ;;
    color_bg)        battery_status_color "$(cache_get status)" bg ;;
    color_charge_fg) battery_charge_color "$(cache_get percent)" fg ;;
    color_charge_bg) battery_charge_color "$(cache_get percent)" bg ;;
    color_status_fg) battery_status_color "$(cache_get status)" fg ;;
    color_status_bg) battery_status_color "$(cache_get status)" bg ;;
    graph)           battery_render_graph "$(cache_get percent)" ;;
    remain)          battery_render_remain "$(cache_get remain)" ;;
    charging_watts)  battery_render_watts "$(cache_get watts)" ;;
    cycles)          battery_render_cycles "$(cache_get cycles)" ;;
    health)          battery_render_health "$(cache_get health)" ;;
    drain_rate)      battery_render_drain_rate "$(cache_get drain_rate)" ;;
    estimate)        battery_estimate ;;
    sparkline)       battery_sparkline "$(get_tmux_option "@battery_revamped_history" "")" ;;
    power_source)    battery_power_source "$(cache_get status)" ;;
    alert_icon)      battery_alert_token ;;
    *)               return 0 ;;
  esac
}

battery_is_labelled() {
  case "${1}" in
    percentage | graph | remain | charging_watts | cycles | health | drain_rate | estimate | sparkline | power_source) return 0 ;;
    *) return 1 ;;
  esac
}

battery_nerd_label() {
  case "${1}" in
    percentage) printf '\xf3\xb0\x81\xb9' ;;
    graph) printf '\xf3\xb0\x9e\xb1' ;;
    remain) printf '\xf3\xb0\x94\x9f' ;;
    charging_watts) printf '\xf3\xb0\x89\x81' ;;
    cycles) printf '\xf3\xb0\x93\xa6' ;;
    health) printf '\xf3\xb0\x97\xb6' ;;
    drain_rate) printf '\xf3\xb0\x94\xb3' ;;
    estimate) printf '\xf3\xb0\x94\x9f' ;;
    sparkline) printf '\xf3\xb0\x9e\xb1' ;;
    power_source) printf '\xf3\xb0\x9a\xa5' ;;
    *) printf '' ;;
  esac
}

battery_option_exists() {
  [[ -n "$(tmux show-option -gq "${1}" 2>/dev/null)" ]]
}

battery_label() {
  local option="@battery_revamped_${1}_label"
  if battery_option_exists "${option}"; then
    tmux show-option -gqv "${option}" 2>/dev/null
  elif [[ "$(get_tmux_option "@battery_revamped_icons" "ascii")" == "nerd" ]]; then
    battery_nerd_label "${1}"
  fi
}

battery_natural_width() {
  case "${1}" in
    percentage) printf '4' ;;
    *) printf '0' ;;
  esac
}

battery_padded() {
  publish_pad "${2}" "$(publish_width battery_revamped "${1}" "$(battery_natural_width "${1}")")"
}

battery_labelled() {
  local metric="${1}" value="${2}" label
  [[ -n "${value}" ]] || return 0
  value="$(battery_padded "${metric}" "${value}")"
  label="$(battery_label "${metric}")"
  if [[ -n "${label}" ]]; then
    printf '%s %s\n' "${label}" "${value}"
  else
    printf '%s\n' "${value}"
  fi
}

battery_output() {
  local metric="${1}" out
  battery_hidden_on_ac && return 0
  out="$(battery_render_metric "${metric}")"
  [[ "${metric}" == "percentage" ]] && out="$(battery_wrap "${out}")"
  if battery_is_labelled "${metric}"; then
    battery_labelled "${metric}" "${out}"
  elif [[ -n "${out}" ]]; then
    printf '%s\n' "${out}"
  fi
}

battery_publish() {
  local metric
  battery_refresh
  for metric in $(get_tmux_option "@battery_revamped_published" ""); do
    publish_add "@battery_revamped_out_${metric}" "$(battery_output "${metric}")"
  done
  publish_commit
}

_battery_reexec() { exec "${PLUGIN_DIR}/src/battery.sh" daemon; }

battery_daemon() {
  if ticker_run battery_revamped battery_publish "$$" 15; then
    _battery_reexec
  fi
}

main() {
  local cmd="${1:-}"

  case "${cmd}" in
    start) ticker_start "${PLUGIN_DIR}/src/battery.sh"; return 0 ;;
    daemon) battery_daemon; return 0 ;;
    refresh)    battery_refresh; return 0 ;;
    popup)      battery_show_popup; return 0 ;;
    popup-card) battery_popup_card; return 0 ;;
    doctor)     battery_doctor; return 0 ;;
  esac

  battery_tick
  battery_output "${cmd}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
