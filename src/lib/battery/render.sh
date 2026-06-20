#!/usr/bin/env bash
#
# render.sh: map cached battery values to icons, colors, a graph, and text.

[[ -n "${_BATTERY_REVAMPED_RENDER_LOADED:-}" ]] && return 0
_BATTERY_REVAMPED_RENDER_LOADED=1

_BATTERY_RENDER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_BATTERY_RENDER_DIR}/../tmux/tmux-ops.sh"

_DEFAULT_TIER_ICONS=("_" "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# battery_tier PCT -> charge tier 1..8.
battery_tier() {
  local pct="${1%%.*}"
  [[ "${pct}" =~ ^[0-9]+$ ]] || pct=0
  local t=$(( (pct * 8 + 99) / 100 ))
  (( t < 1 )) && t=1
  (( t > 8 )) && t=8
  echo "${t}"
}

battery_charge_icon() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local tier
  tier=$(battery_tier "${1}")
  get_tmux_option "@battery_revamped_charge_tier${tier}_icon" "${_DEFAULT_TIER_ICONS[tier]}"
}

battery_charge_color() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  get_tmux_option "@battery_revamped_charge_tier$(battery_tier "${1}")_${2}_color" ""
}

battery_status_icon() {
  local status="${1:-unknown}"
  local default
  case "${status}" in
    charged)     default="=" ;;
    charging)    default="+" ;;
    discharging) default="-" ;;
    attached)    default="!" ;;
    *)           default="?" ;;
  esac
  get_tmux_option "@battery_revamped_status_${status}_icon" "${default}"
}

battery_status_color() {
  local status="${1:-unknown}"
  get_tmux_option "@battery_revamped_status_${status}_${2}_color" ""
}

battery_render_percentage() {
  local raw="${1}"
  [[ -z "${raw}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_percentage_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${raw}"
}

battery_render_graph() {
  local pct="${1%%.*}"
  [[ "${pct}" =~ ^[0-9]+$ ]] || { echo ""; return 0; }
  local width full empty
  width=$(get_tmux_option "@battery_revamped_graph_width" "10")
  full=$(get_tmux_option "@battery_revamped_graph_full" "█")
  empty=$(get_tmux_option "@battery_revamped_graph_empty" "░")
  [[ "${width}" =~ ^[0-9]+$ ]] || width=10
  local filled=$(( (pct * width + 50) / 100 ))
  (( filled < 0 )) && filled=0
  (( filled > width )) && filled=width
  local out="" i
  for (( i = 0; i < filled; i++ )); do out+="${full}"; done
  for (( i = filled; i < width; i++ )); do out+="${empty}"; done
  echo "${out}"
}

battery_render_remain() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_remain_format" "%s")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

battery_render_watts() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_watts_format" "%sW")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

battery_render_cycles() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_cycles_format" "%s")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

battery_render_health() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_health_format" "%s%%")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

export -f battery_render_cycles
export -f battery_render_health
export -f battery_tier
export -f battery_charge_icon
export -f battery_charge_color
export -f battery_status_icon
export -f battery_status_color
export -f battery_render_percentage
export -f battery_render_graph
export -f battery_render_remain
export -f battery_render_watts
