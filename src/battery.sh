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

battery_refresh() {
  local now prev_pct prev_ts new_pct new_status
  now=$(_cache_now)
  prev_pct=$(cache_get percent)
  prev_ts=$(get_tmux_option "@${CACHE_PREFIX}_snap_ts" "")
  new_pct=$(read_battery_percentage)
  new_status=$(read_battery_status)
  cache_set percent "${new_pct}"
  cache_set status "${new_status}"
  cache_set remain "$(read_battery_remain)"
  cache_set watts "$(read_battery_watts)"
  cache_set cycles "$(read_battery_cycles)"
  cache_set health "$(read_battery_health)"
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

main() {
  local cmd="${1:-}"

  case "${cmd}" in
    refresh)    battery_refresh; return 0 ;;
    popup)      battery_show_popup; return 0 ;;
    popup-card) battery_popup_card; return 0 ;;
    doctor)     battery_doctor; return 0 ;;
  esac

  battery_tick

  case "${cmd}" in
    percentage)      battery_render_percentage "$(cache_get percent)" ;;
    icon)            battery_charge_icon "$(cache_get percent)" ;;
    icon_charge)     battery_charge_icon "$(cache_get percent)" ;;
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
