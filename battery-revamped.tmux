#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAT_CMD="${PLUGIN_DIR}/src/battery.sh"
BAT_CMD_ARG="$(printf '%q' "${BAT_CMD}")"
hash="#"
BAT_CMD_ARG="${BAT_CMD_ARG//"${hash}"/${hash}${hash}}"

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
  "#(${BAT_CMD_ARG} percentage)"
  "#(${BAT_CMD_ARG} icon)"
  "#(${BAT_CMD_ARG} icon_charge)"
  "#(${BAT_CMD_ARG} icon_status)"
  "#(${BAT_CMD_ARG} color_fg)"
  "#(${BAT_CMD_ARG} color_bg)"
  "#(${BAT_CMD_ARG} color_charge_fg)"
  "#(${BAT_CMD_ARG} color_charge_bg)"
  "#(${BAT_CMD_ARG} color_status_fg)"
  "#(${BAT_CMD_ARG} color_status_bg)"
  "#(${BAT_CMD_ARG} graph)"
  "#(${BAT_CMD_ARG} remain)"
  "#(${BAT_CMD_ARG} charging_watts)"
  "#(${BAT_CMD_ARG} cycles)"
  "#(${BAT_CMD_ARG} health)"
  "#(${BAT_CMD_ARG} drain_rate)"
  "#(${BAT_CMD_ARG} estimate)"
  "#(${BAT_CMD_ARG} sparkline)"
  "#(${BAT_CMD_ARG} power_source)"
  "#(${BAT_CMD_ARG} alert_icon)"
)

render_mode="$(tmux show-option -gqv "@battery_revamped_render")"

target_for() {
  local command="${1}" metric
  metric="${command##* }"
  metric="${metric%)}"
  if [[ "${render_mode}" == "options" ]]; then
    printf '#{E:@battery_revamped_out_%s}' "${metric}"
  else
    printf '%s' "${command}"
  fi
}

interpolate() {
  local value="${1}" i placeholder out rest
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    placeholder="${placeholders[i]#\\}"
    out=""
    rest="${value}"
    while [[ "${rest}" == *"${placeholder}"* ]]; do
      out="${out}${rest%%"${placeholder}"*}$(target_for "${commands[i]}")"
      rest="${rest#*"${placeholder}"}"
    done
    value="${out}${rest}"
  done
  echo "${value}"
}

used_metrics() {
  local text="${1}" used="" i metric
  for (( i = 0; i < ${#placeholders[@]}; i++ )); do
    metric="${commands[i]##* }"
    metric="${metric%)}"
    if [[ "${text}" == *${placeholders[i]}* || "${text}" == *"@battery_revamped_out_${metric}}"* ]]; then
      used="${used:+${used} }${metric}"
    fi
  done
  echo "${used}"
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
  [[ -z "${key}" ]] && key="M-b"
  [[ "${key}" == "off" ]] && return 0
  tmux bind-key "${key}" run-shell "${BAT_CMD_ARG} popup"
}

chmod +x "${BAT_CMD}" 2>/dev/null || true

status_text="$(tmux show-option -gqv status-left) $(tmux show-option -gqv status-right)"
tmux set-option -gq "@battery_revamped_published" "$(used_metrics "${status_text}")"

update_option "status-left"
update_option "status-right"

if [[ "${render_mode}" == "options" ]]; then
  "${BAT_CMD}" start 2>/dev/null || true
else
  tmux set-option -gqu "@battery_revamped_ticker_pid"
fi
bind_popup
