#!/usr/bin/env bash

[[ -n "${_BATTERY_REVAMPED_ALERTS_LOADED:-}" ]] && return 0
_BATTERY_REVAMPED_ALERTS_LOADED=1

_BATTERY_ALERTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_BATTERY_ALERTS_DIR}/../utils/notify.sh"
# shellcheck source=/dev/null
source "${_BATTERY_ALERTS_DIR}/../tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${_BATTERY_ALERTS_DIR}/trends.sh"

battery_alert_message() {
  case "${1}" in
    critical) printf 'Critically low: %s%%' "${2}" ;;
    low)      printf 'Low battery: %s%%' "${2}" ;;
    full)     printf 'Fully charged: %s%%' "${2}" ;;
    *)        printf '%s%%' "${2}" ;;
  esac
}

battery_should_notify() {
  local prev="${1}" cur="${2}"
  case "${cur}" in
    low|critical|full) ;;
    *) return 1 ;;
  esac
  [[ "${cur}" != "${prev}" ]]
}

battery_alert_check() {
  local pct="${1}" status="${2}"
  local low crit cur prev
  low=$(get_tmux_option "@battery_revamped_low_threshold" "20")
  crit=$(get_tmux_option "@battery_revamped_critical_threshold" "10")
  cur=$(battery_level "${pct}" "${status}" "${low}" "${crit}")
  prev=$(get_tmux_option "@battery_revamped_alert_level" "")
  set_tmux_option "@battery_revamped_alert_level" "${cur}"
  notify_enabled "@battery_revamped_notify" || return 0
  battery_should_notify "${prev}" "${cur}" || return 0
  notify_send "Battery ${cur}" "$(battery_alert_message "${cur}" "${pct}")"
}

export -f battery_alert_message
export -f battery_should_notify
export -f battery_alert_check
