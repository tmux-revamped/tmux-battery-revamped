#!/usr/bin/env bash
#
# battery.sh: command dispatcher for tmux-battery-revamped.
#
# Usage: battery.sh <placeholder> | refresh
#   percentage icon icon_charge icon_status
#   color_fg color_bg color_charge_fg color_charge_bg color_status_fg color_status_bg
#   graph remain charging_watts

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="battery_revamped"
export PLUGIN_LOG_NS="battery-revamped"

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

battery_max_age() {
  get_tmux_option "@battery_revamped_interval" "15"
}

battery_refresh() {
  cache_set percent "$(read_battery_percentage)"
  cache_set status "$(read_battery_status)"
  cache_set remain "$(read_battery_remain)"
  cache_set watts "$(read_battery_watts)"
  cache_set cycles "$(read_battery_cycles)"
  cache_set health "$(read_battery_health)"
}

battery_tick() {
  cache_refresh_if_stale percent "$(battery_max_age)" battery_refresh
}

main() {
  local cmd="${1:-}"

  if [[ "${cmd}" == "refresh" ]]; then
    battery_refresh
    return 0
  fi

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
    *)               return 0 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
