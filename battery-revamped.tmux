#!/usr/bin/env bash
#
# battery-revamped.tmux: TPM entry point.
#
# Replaces the #{battery_*} placeholders in status-left and status-right with
# calls to the dispatcher, which reads cached values and never blocks the render.
# Also binds a key to the detail popup.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAT_CMD="${PLUGIN_DIR}/src/battery.sh"

placeholders=(
  "\#{battery_percentage}"
  "\#{battery_icon}"
  "\#{battery_icon_charge}"
  "\#{battery_icon_status}"
  "\#{battery_color_fg}"
  "\#{battery_color_bg}"
  "\#{battery_color_charge_fg}"
  "\#{battery_color_charge_bg}"
  "\#{battery_color_status_fg}"
  "\#{battery_color_status_bg}"
  "\#{battery_graph}"
  "\#{battery_remain}"
  "\#{battery_charging_watts}"
  "\#{battery_cycles}"
  "\#{battery_health}"
  "\#{battery_drain_rate}"
  "\#{battery_estimate}"
  "\#{battery_sparkline}"
  "\#{battery_power_source}"
  "\#{battery_alert_icon}"
)

commands=(
  "#(${BAT_CMD} percentage)"
  "#(${BAT_CMD} icon)"
  "#(${BAT_CMD} icon_charge)"
  "#(${BAT_CMD} icon_status)"
  "#(${BAT_CMD} color_fg)"
  "#(${BAT_CMD} color_bg)"
  "#(${BAT_CMD} color_charge_fg)"
  "#(${BAT_CMD} color_charge_bg)"
  "#(${BAT_CMD} color_status_fg)"
  "#(${BAT_CMD} color_status_bg)"
  "#(${BAT_CMD} graph)"
  "#(${BAT_CMD} remain)"
  "#(${BAT_CMD} charging_watts)"
  "#(${BAT_CMD} cycles)"
  "#(${BAT_CMD} health)"
  "#(${BAT_CMD} drain_rate)"
  "#(${BAT_CMD} estimate)"
  "#(${BAT_CMD} sparkline)"
  "#(${BAT_CMD} power_source)"
  "#(${BAT_CMD} alert_icon)"
)

interpolate() {
  local value="${1}"
  local i
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    value="${value//${placeholders[i]}/${commands[i]}}"
  done
  echo "${value}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

bind_popup() {
  local key
  key=$(tmux show-option -gqv "@battery_revamped_popup_key")
  [[ -z "${key}" ]] && key="B"
  tmux bind-key "${key}" run-shell "${BAT_CMD} popup"
}

chmod +x "${BAT_CMD}" 2>/dev/null || true

update_option "status-left"
update_option "status-right"
bind_popup
