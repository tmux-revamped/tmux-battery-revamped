#!/usr/bin/env bash
#
# popup.sh: the battery detail popup and the doctor capability report.
#
# The popup is a card built from already-cached values, with zero re-probing. It
# opens through the _tmux seam, which tests replace, so display-popup is never
# launched during the suite. The doctor report explains which sources this host
# exposes and why a token may be empty.

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

# Single tmux seam for the popup. Tests override it so nothing is launched.
_tmux() { tmux "$@"; }

# battery_popup_card -> the multi-line detail card, read entirely from the cache.
battery_popup_card() {
  printf 'Battery\n'
  printf 'Charge    : %s%%\n' "$(cache_get percent)"
  printf 'Status    : %s\n' "$(cache_get status)"
  printf 'Remaining : %s\n' "$(cache_get remain)"
  printf 'Watts     : %s\n' "$(cache_get watts)"
  printf 'Drain     : %s\n' "$(cache_get drain_rate)"
  printf 'Cycles    : %s\n' "$(cache_get cycles)"
  printf 'Health    : %s%%\n' "$(cache_get health)"
}

# battery_popup_command -> the shell command the popup runs: print the card,
# then wait for a keypress. References the dispatcher so the card stays fresh.
battery_popup_command() {
  local self="${BATTERY_REVAMPED_CMD:-battery.sh}"
  printf '%s popup-card; printf "\\n[q] close"; read -r -n1 _' "${self}"
}

# battery_show_popup -> open the detail popup through the _tmux seam.
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

_doctor_notify_backend() {
  if is_macos; then
    echo "osascript"
  elif has_command notify-send; then
    echo "notify-send"
  else
    echo "none"
  fi
}

# battery_doctor -> a capability report naming detected sources per host.
battery_doctor() {
  printf 'tmux-battery-revamped doctor\n'
  printf 'os             : %s\n' "$(platform_os)"
  printf 'pmset          : %s\n' "$(_doctor_have pmset)"
  printf 'system_profiler: %s\n' "$(_doctor_have system_profiler)"
  printf 'ioreg          : %s\n' "$(_doctor_have ioreg)"
  printf 'acpi           : %s\n' "$(_doctor_have acpi)"
  printf 'sysfs battery  : %s\n' "$(_doctor_sysfs)"
  printf 'notify backend : %s\n' "$(_doctor_notify_backend)"
}

export -f _tmux
export -f battery_popup_card
export -f battery_popup_command
export -f battery_show_popup
export -f _doctor_have
export -f _battery_sysfs_present
export -f _doctor_sysfs
export -f _doctor_notify_backend
export -f battery_doctor
