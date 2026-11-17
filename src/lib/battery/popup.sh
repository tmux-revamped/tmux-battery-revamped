#!/usr/bin/env bash

[[ -n "${_BATTERY_REVAMPED_POPUP_LOADED:-}" ]] && return 0
_BATTERY_REVAMPED_POPUP_LOADED=1

_BATTERY_POPUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_BATTERY_POPUP_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_BATTERY_POPUP_DIR}/../utils/has-command.sh"
# shellcheck source=/dev/null
source "${_BATTERY_POPUP_DIR}/../tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${_BATTERY_POPUP_DIR}/../utils/cache.sh"
# shellcheck source=/dev/null
source "${_BATTERY_POPUP_DIR}/../utils/notify.sh"

_tmux() { tmux "$@"; }

battery_popup_card() {
  local percent
  percent="$(cache_get percent)"
  printf 'Battery\n'
  if [[ -z "${percent}" ]]; then
    printf 'no battery found on this machine\n'
    return 0
  fi
  printf 'Charge    : %s%%\n' "${percent}"
  printf 'Status    : %s\n' "$(cache_get status)"
  printf 'Remaining : %s\n' "$(cache_get remain)"
  printf 'Watts     : %s\n' "$(cache_get watts)"
  printf 'Drain     : %s\n' "$(cache_get drain_rate)"
  printf 'Cycles    : %s\n' "$(cache_get cycles)"
  printf 'Health    : %s%%\n' "$(cache_get health)"
}

_battery_hash_free() {
  local rest="${1}" out="" piece hash="#"
  while [[ "${rest}" == *"${hash}"* ]]; do
    printf -v piece '%q' "${rest%%"${hash}"*}"
    out+="${piece}\"\$(printf '%b' '\\0043')\""
    rest="${rest#*"${hash}"}"
  done
  printf -v piece '%q' "${rest}"
  printf '%s%s' "${out}" "${piece}"
}

battery_popup_command() {
  local self command
  self="$(printf '%q' "${BATTERY_REVAMPED_CMD:-battery.sh}")"
  command="$(printf '%s popup-card; printf "\\n[q] close"; read -r -n1 _' "${self}")"
  printf 'bash -c %s' "$(_battery_hash_free "${command}")"
}

battery_show_popup() {
  local w h
  w=$(get_tmux_option "@battery_revamped_popup_width" "44")
  h=$(get_tmux_option "@battery_revamped_popup_height" "12")
  _tmux display-popup -w "${w}" -h "${h}" -E "$(battery_popup_command)"
}

_doctor_have() {
  if has_command "${1}"; then echo "found"; else echo "missing"; fi
}

_battery_sysfs_present() {
  compgen -G "/sys/class/power_supply/BAT*/capacity" >/dev/null 2>&1
}

_doctor_sysfs() {
  if _battery_sysfs_present; then echo "present"; else echo "absent"; fi
}

battery_doctor() {
  printf 'tmux-battery-revamped doctor\n'
  printf 'os             : %s\n' "$(platform_os)"
  printf 'pmset          : %s\n' "$(_doctor_have pmset)"
  printf 'system_profiler: %s\n' "$(_doctor_have system_profiler)"
  printf 'ioreg          : %s\n' "$(_doctor_have ioreg)"
  printf 'acpi           : %s\n' "$(_doctor_have acpi)"
  printf 'sysfs battery  : %s\n' "$(_doctor_sysfs)"
  printf 'notify backend : %s\n' "$(notify_backend)"
}

export -f _tmux
export -f battery_popup_card
export -f battery_popup_command
export -f battery_show_popup
export -f _doctor_have
export -f _battery_sysfs_present
export -f _doctor_sysfs
export -f battery_doctor
