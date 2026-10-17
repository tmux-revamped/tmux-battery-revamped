#!/usr/bin/env bash

[[ -n "${_BATTERY_REVAMPED_TRENDS_LOADED:-}" ]] && return 0
_BATTERY_REVAMPED_TRENDS_LOADED=1

_BATTERY_TRENDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_BATTERY_TRENDS_DIR}/../tmux/tmux-ops.sh"

_BATTERY_SPARK_GLYPHS=(
  $'\xe2\x96\x81' $'\xe2\x96\x82' $'\xe2\x96\x83' $'\xe2\x96\x84'
  $'\xe2\x96\x85' $'\xe2\x96\x86' $'\xe2\x96\x87' $'\xe2\x96\x88'
)

battery_drain_rate() {
  local pp="${1}" pt="${2}" cp="${3}" ct="${4}"
  [[ "${pp}" =~ ^[0-9]+$ && "${pt}" =~ ^[0-9]+$ && "${cp}" =~ ^[0-9]+$ && "${ct}" =~ ^[0-9]+$ ]] || { echo ""; return 0; }
  local dt=$(( ct - pt ))
  (( dt > 0 )) || { echo ""; return 0; }
  LC_ALL=C awk -v a="${pp}" -v b="${cp}" -v d="${dt}" 'BEGIN { printf "%.1f", (a - b) * 3600 / d }'
}

BATTERY_DRAIN_WINDOW=300

battery_drain_due() {
  local anchor="${1}" now="${2}"
  [[ "${anchor}" =~ ^[0-9]+$ && "${now}" =~ ^[0-9]+$ ]] || return 0
  (( now - anchor >= BATTERY_DRAIN_WINDOW || now < anchor ))
}

battery_render_drain_rate() {
  [[ -z "${1}" ]] && { echo ""; return 0; }
  local fmt
  fmt=$(get_tmux_option "@battery_revamped_drain_rate_format" "%s%%/h")
  # shellcheck disable=SC2059
  printf "${fmt}" "${1}"
}

battery_estimate_remain() {
  local pct="${1}" rate="${2}" status="${3}"
  [[ "${pct}" =~ ^[0-9]+$ ]] || { echo ""; return 0; }
  [[ "${rate}" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || { echo ""; return 0; }
  awk -v p="${pct}" -v r="${rate}" -v s="${status}" 'BEGIN { if (s == "discharging" && r > 0) h = p / r; else if (s == "charging" && r < 0) h = (100 - p) / (-r); else exit 0; H = int(h); M = int((h - H) * 60 + 0.5); if (M == 60) { H++; M = 0 } printf "%d:%02d", H, M }'
}

battery_history_size() {
  get_tmux_option "@battery_revamped_history_size" "16"
}

battery_spark_push() {
  local ring="${1}" val="${2}" max="${3}"
  [[ "${max}" =~ ^[0-9]+$ && "${max}" -gt 0 ]] || max=16
  [[ "${val}" =~ ^[0-9]+$ ]] || { echo "${ring}"; return 0; }
  local combined
  if [[ -n "${ring}" ]]; then combined="${ring},${val}"; else combined="${val}"; fi
  echo "${combined}" | awk -v m="${max}" -F, '{ s = (NF > m) ? NF - m + 1 : 1; out = $s; for (i = s + 1; i <= NF; i++) out = out","$i; print out }'
}

battery_sparkline() {
  local ring="${1}"
  [[ -z "${ring}" ]] && { echo ""; return 0; }
  local out="" v idx
  local IFS=,
  for v in ${ring}; do
    if [[ "${v}" =~ ^[0-9]+$ ]]; then
      idx=$(( v * 7 / 100 ))
      (( idx > 7 )) && idx=7
      out="${out}${_BATTERY_SPARK_GLYPHS[idx]}"
    fi
  done
  echo "${out}"
}

battery_level() {
  local pct="${1}" status="${2}" low="${3}" crit="${4}"
  [[ "${low}" =~ ^[0-9]+$ ]] || low=20
  [[ "${crit}" =~ ^[0-9]+$ ]] || crit=10
  [[ "${pct}" =~ ^[0-9]+$ ]] || { echo "unknown"; return 0; }
  case "${status}" in
    charged)
      echo "full"; return 0 ;;
    charging)
      if (( pct >= 100 )); then echo "full"; else echo "ok"; fi
      return 0 ;;
    discharging)
      if (( pct <= crit )); then echo "critical"; return 0; fi
      if (( pct <= low )); then echo "low"; return 0; fi
      echo "ok"; return 0 ;;
    *)
      echo "ok"; return 0 ;;
  esac
}

battery_alert_icon() {
  case "${1}" in
    critical) get_tmux_option "@battery_revamped_critical_icon" "" ;;
    low)      get_tmux_option "@battery_revamped_low_icon" "" ;;
    *)        echo "" ;;
  esac
}

battery_power_source() {
  if [[ "${1}" == "discharging" ]]; then
    get_tmux_option "@battery_revamped_source_battery_label" "Bat"
  else
    get_tmux_option "@battery_revamped_source_ac_label" "AC"
  fi
}

export -f battery_drain_rate
export -f battery_drain_due
export -f battery_render_drain_rate
export -f battery_estimate_remain
export -f battery_history_size
export -f battery_spark_push
export -f battery_sparkline
export -f battery_level
export -f battery_alert_icon
export -f battery_power_source
