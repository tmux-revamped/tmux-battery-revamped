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
    *"not charging"*)      echo "attached" ;;
    *"pending-charge"*|*"pending charge"*)       echo "attached" ;;
    *"pending-discharge"*|*"pending discharge"*) echo "attached" ;;
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

# battery_remain_from_sysfs NOW FULL RATE STATUS -> "H:MM" remaining computed
# from the power-supply energy/charge counters. Empty when the rate is zero or
# the status is neither charging nor discharging. NOW and RATE must share units
# (energy_now with power_now, or charge_now with current_now).
battery_remain_from_sysfs() {
  local now="${1}" full="${2}" rate="${3}" status="${4}"
  [[ "${now}" =~ ^[0-9]+$ && "${rate}" =~ ^[0-9]+$ ]] || { echo ""; return 0; }
  (( rate > 0 )) || { echo ""; return 0; }
  local num
  case "${status}" in
    discharging) num="${now}" ;;
    charging)
      [[ "${full}" =~ ^[0-9]+$ ]] && (( full > now )) || { echo ""; return 0; }
      num=$(( full - now )) ;;
    *) echo ""; return 0 ;;
  esac
  awk -v n="${num}" -v r="${rate}" \
    'BEGIN { h = n / r; H = int(h); M = int((h - H) * 60 + 0.5); \
      if (M == 60) { H++; M = 0 } printf "%d:%02d", H, M }'
}

# battery_watts_from_profiler TEXT -> charging watts integer, empty when absent.
battery_watts_from_profiler() {
  printf '%s\n' "${1}" | grep -i "Wattage" | grep -oE '[0-9]+' | head -1
}

# bat_ioreg_field TEXT KEY -> the integer value for an ioreg AppleSmartBattery key.
bat_ioreg_field() {
  printf '%s\n' "${1}" | awk -v k="\"${2}\" = " '
    { line = $0; sub(/^[ \t]*/, "", line) }
    index(line, k) == 1 { v = substr(line, length(k) + 1); gsub(/[^0-9]/, "", v); print v; exit }'
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
_read_acpi() { acpi -b 2>/dev/null | head -1; }
_read_profiler() { system_profiler SPPowerDataType 2>/dev/null; }
_read_ioreg_battery() { ioreg -r -c AppleSmartBattery 2>/dev/null; }
_bat_sys_root() { printf '%s' /sys/class/power_supply; }

_bat_sys_dir() {
  local dir
  for dir in "$(_bat_sys_root)"/BAT*; do
    if [[ -r "${dir}/capacity" ]]; then
      printf '%s' "${dir}"
      return 0
    fi
  done
  return 1
}

_sys_battery_present() { _bat_sys_dir >/dev/null; }

_read_bat_sys() {
  local dir
  dir=$(_bat_sys_dir) || return 0
  [[ -r "${dir}/${1}" ]] || return 0
  cat "${dir}/${1}" 2>/dev/null
}
_read_sys_capacity() { _read_bat_sys capacity; }
_read_sys_status() { _read_bat_sys status; }
_read_bat_cycle_count() { _read_bat_sys cycle_count; }
_read_bat_charge_full() { _read_bat_sys charge_full; }
_read_bat_charge_full_design() { _read_bat_sys charge_full_design; }
_read_bat_power_now() { _read_bat_sys power_now; }

# Energy and charge counters share a unit family: energy_* pairs with power_now,
# charge_* pairs with current_now. Each reader prefers energy, then charge, so
# the remaining-time numerator and rate stay in matching units.
_read_bat_energy_now() {
  local v; v=$(_read_bat_sys energy_now); [[ -n "${v}" ]] || v=$(_read_bat_sys charge_now); echo "${v}"
}
_read_bat_energy_full() {
  local v; v=$(_read_bat_sys energy_full); [[ -n "${v}" ]] || v=$(_read_bat_sys charge_full); echo "${v}"
}
_read_bat_rate() {
  local v; v=$(_read_bat_sys power_now); [[ -n "${v}" ]] || v=$(_read_bat_sys current_now); echo "${v}"
}

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
    return 0
  fi
  if has_command acpi; then
    local t
    t=$(printf '%s\n' "$(_read_acpi)" | grep -oE '[0-9]+:[0-9]+' | head -1)
    [[ -n "${t}" ]] && { echo "${t}"; return 0; }
  fi
  if _sys_battery_present; then
    battery_remain_from_sysfs "$(_read_bat_energy_now)" "$(_read_bat_energy_full)" \
      "$(_read_bat_rate)" "$(read_battery_status)"
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
    local d max
    d=$(_read_ioreg_battery)
    max=$(bat_ioreg_field "${d}" AppleRawMaxCapacity)
    [[ -n "${max}" ]] || max=$(bat_ioreg_field "${d}" MaxCapacity)
    bat_health_pct "${max}" "$(bat_ioreg_field "${d}" DesignCapacity)"
  elif is_linux; then
    local full design
    full=$(_read_bat_sys energy_full)
    design=$(_read_bat_sys energy_full_design)
    if [[ -z "${full}" || -z "${design}" ]]; then
      full=$(_read_bat_charge_full)
      design=$(_read_bat_charge_full_design)
    fi
    bat_health_pct "${full}" "${design}"
  fi
}

export -f bat_ioreg_field
export -f bat_health_pct
export -f battery_norm_status
export -f battery_pct_from_pmset
export -f battery_status_from_pmset
export -f battery_remain_from_pmset
export -f battery_remain_from_sysfs
export -f battery_watts_from_profiler
export -f _read_pmset
export -f _read_sys_capacity
export -f _read_sys_status
export -f _read_acpi
export -f _read_profiler
export -f _read_ioreg_battery
export -f _bat_sys_root
export -f _bat_sys_dir
export -f _sys_battery_present
export -f _read_bat_sys
export -f _read_bat_cycle_count
export -f _read_bat_charge_full
export -f _read_bat_charge_full_design
export -f _read_bat_power_now
export -f _read_bat_energy_now
export -f _read_bat_energy_full
export -f _read_bat_rate
export -f read_battery_percentage
export -f read_battery_status
export -f read_battery_remain
export -f read_battery_watts
export -f read_battery_cycles
export -f read_battery_health
