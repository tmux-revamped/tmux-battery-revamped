#!/usr/bin/env bash
#
# battery.sh: battery percentage, status, remaining time, and charging watts.
#
# Pure parsers turn probe output into values. Reader functions wrap the host
# probes behind seams that tests override. One worker calls every reader once.

[[ -n "${_BATTERY_REVAMPED_BATTERY_LOADED:-}" ]] && return 0
_BATTERY_REVAMPED_BATTERY_LOADED=1

_BATTERY_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_BATTERY_LIB_DIR}/../utils/platform.sh"
# shellcheck source=/dev/null
source "${_BATTERY_LIB_DIR}/../utils/has-command.sh"

# battery_norm_status RAW -> charging|discharging|charged|attached|unknown.
battery_norm_status() {
  local s
  s=$(printf '%s' "${1}" | tr '[:upper:]' '[:lower:]')
  case "${s}" in
    *"not charging"*) echo "attached" ;;
    *discharging*)    echo "discharging" ;;
    *charging*)       echo "charging" ;;
    *charged*|*full*) echo "charged" ;;
    *)                echo "unknown" ;;
  esac
}

# battery_pct_from_pmset TEXT -> integer percent from `pmset -g batt`.
battery_pct_from_pmset() {
  printf '%s\n' "${1}" | grep -oE '[0-9]+%' | head -1 | tr -d '%'
}

# battery_status_from_pmset TEXT -> normalized status from `pmset -g batt`.
battery_status_from_pmset() {
  local line raw
  line=$(printf '%s\n' "${1}" | grep -E '[0-9]+%' | head -1)
  raw=$(printf '%s' "${line}" | awk -F';' '{ print $2 }')
  battery_norm_status "${raw}"
}

# battery_remain_from_pmset TEXT -> "H:MM" remaining, empty when not estimated.
battery_remain_from_pmset() {
  printf '%s\n' "${1}" | grep -oE '[0-9]+:[0-9]+' | head -1
}

# battery_watts_from_profiler TEXT -> charging watts integer, empty when absent.
battery_watts_from_profiler() {
  printf '%s\n' "${1}" | grep -i "Wattage" | grep -oE '[0-9]+' | head -1
}

# bat_ioreg_field TEXT KEY -> the integer value for an ioreg AppleSmartBattery key.
bat_ioreg_field() {
  printf '%s\n' "${1}" | awk -F' = ' -v k="\"${2}\"" '$0 ~ k { gsub(/[^0-9]/, "", $2); print $2; exit }'
}

# bat_health_pct MAX DESIGN -> battery health percent, clamped to 100.
bat_health_pct() {
  [[ "${1}" =~ ^[0-9]+$ && "${2}" =~ ^[0-9]+$ && "${2}" -gt 0 ]] || { echo ""; return 0; }
  local h=$(( ${1} * 100 / ${2} ))
  (( h > 100 )) && h=100
  echo "${h}"
}

# Host-probe seams.
_read_pmset() { pmset -g batt 2>/dev/null; }
_read_sys_capacity() { cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; }
_read_sys_status() { cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1; }
_read_acpi() { acpi -b 2>/dev/null | head -1; }
_read_profiler() { system_profiler SPPowerDataType 2>/dev/null; }
_read_ioreg_battery() { ioreg -r -c AppleSmartBattery 2>/dev/null; }
_sys_battery_present() { compgen -G "/sys/class/power_supply/BAT*/capacity" >/dev/null 2>&1; }

_read_bat_sys() {
  local name="${1}" base
  for base in /sys/class/power_supply/BAT1 /sys/class/power_supply/BAT0; do
    [[ -r "${base}/${name}" ]] && { cat "${base}/${name}" 2>/dev/null; return 0; }
  done
}
_read_bat_cycle_count() { _read_bat_sys cycle_count; }
_read_bat_charge_full() { _read_bat_sys charge_full; }
_read_bat_charge_full_design() { _read_bat_sys charge_full_design; }
_read_bat_power_now() { _read_bat_sys power_now; }

read_battery_percentage() {
  if is_macos; then
    battery_pct_from_pmset "$(_read_pmset)"
  elif _sys_battery_present; then
    local cap
    cap=$(_read_sys_capacity)
    [[ "${cap}" =~ ^[0-9]+$ ]] && echo "${cap}"
  elif has_command acpi; then
    printf '%s\n' "$(_read_acpi)" | grep -oE '[0-9]+%' | head -1 | tr -d '%'
  fi
}

read_battery_status() {
  if is_macos; then
    battery_status_from_pmset "$(_read_pmset)"
  elif _sys_battery_present; then
    battery_norm_status "$(_read_sys_status)"
  elif has_command acpi; then
    battery_norm_status "$(_read_acpi)"
  else
    echo "unknown"
  fi
}

read_battery_remain() {
  if is_macos; then
    battery_remain_from_pmset "$(_read_pmset)"
  elif has_command acpi; then
    printf '%s\n' "$(_read_acpi)" | grep -oE '[0-9]+:[0-9]+' | head -1
  fi
}

read_battery_watts() {
  if is_macos; then
    battery_watts_from_profiler "$(_read_profiler)"
  elif is_linux; then
    local p
    p=$(_read_bat_power_now)
    [[ "${p}" =~ ^[0-9]+$ ]] && echo $(( p / 1000000 ))
  fi
}

# read_battery_cycles -> charge cycle count, empty when unavailable.
read_battery_cycles() {
  if is_macos; then
    bat_ioreg_field "$(_read_ioreg_battery)" CycleCount
  elif is_linux; then
    local c
    c=$(_read_bat_cycle_count)
    [[ "${c}" =~ ^[0-9]+$ ]] && echo "${c}"
  fi
}

# read_battery_health -> battery health percent, empty when unavailable.
read_battery_health() {
  if is_macos; then
    local d
    d=$(_read_ioreg_battery)
    bat_health_pct "$(bat_ioreg_field "${d}" MaxCapacity)" "$(bat_ioreg_field "${d}" DesignCapacity)"
  elif is_linux; then
    bat_health_pct "$(_read_bat_charge_full)" "$(_read_bat_charge_full_design)"
  fi
}

export -f bat_ioreg_field
export -f bat_health_pct
export -f battery_norm_status
export -f battery_pct_from_pmset
export -f battery_status_from_pmset
export -f battery_remain_from_pmset
export -f battery_watts_from_profiler
export -f _read_pmset
export -f _read_sys_capacity
export -f _read_sys_status
export -f _read_acpi
export -f _read_profiler
export -f _read_ioreg_battery
export -f _sys_battery_present
export -f _read_bat_sys
export -f _read_bat_cycle_count
export -f _read_bat_charge_full
export -f _read_bat_charge_full_design
export -f _read_bat_power_now
export -f read_battery_percentage
export -f read_battery_status
export -f read_battery_remain
export -f read_battery_watts
export -f read_battery_cycles
export -f read_battery_health
