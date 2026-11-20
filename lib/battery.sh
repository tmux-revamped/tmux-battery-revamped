#!/bin/sh

[ -n "${BATTERY_REVAMPED_BATTERY_LOADED:-}" ] && return 0
BATTERY_REVAMPED_BATTERY_LOADED=1

# shellcheck source=SCRIPTDIR/state.sh
. "${REVAMPED_LIB:?}/state.sh"
# shellcheck source=SCRIPTDIR/platform.sh
. "${REVAMPED_LIB}/platform.sh"
# shellcheck source=SCRIPTDIR/command.sh
. "${REVAMPED_LIB}/command.sh"
# shellcheck source=SCRIPTDIR/cache.sh
. "${REVAMPED_LIB}/cache.sh"
# shellcheck source=SCRIPTDIR/publish.sh
. "${REVAMPED_LIB}/publish.sh"
# shellcheck source=SCRIPTDIR/ticker.sh
. "${REVAMPED_LIB}/ticker.sh"
# shellcheck source=SCRIPTDIR/notify.sh
. "${REVAMPED_LIB}/notify.sh"

battery_revamped_format() {
  printf '%s\n' "${BATTERY_REVAMPED_SETTINGS}" | awk -F '\t' -v live="${BATTERY_REVAMPED_LIVE}" '{ printf "%s#{@battery_revamped_%s}", (NR > 1 ? "\t" : ""), $1 } END { count = split(live, name, " "); for (i = 1; i <= count; i++) { printf "\t#{@battery_revamped_%s}", name[i] } }'
}

battery_revamped_resolve() {
  env | BATTERY_REVAMPED_ROWS="${BATTERY_REVAMPED_SETTINGS}" BATTERY_REVAMPED_VALUES="$1" awk -v live="${BATTERY_REVAMPED_LIVE}" '
    BEGIN {
      count = split(ENVIRON["BATTERY_REVAMPED_ROWS"], rows, "\n")
      split(ENVIRON["BATTERY_REVAMPED_VALUES"], given, "\t")
      for (i = 1; i <= count; i++) {
        at = index(rows[i], "\t")
        if (at == 0) { at = length(rows[i]) + 1 }
        name[i] = substr(rows[i], 1, at - 1)
        value[i] = (given[i] != "") ? given[i] : substr(rows[i], at + 1)
        want["BATTERY_REVAMPED_" toupper(name[i])] = i
      }
    }
    {
      at = index($0, "=")
      key = substr($0, 1, at - 1)
      if (key in want) {
        value[want[key]] = substr($0, at + 1)
      }
    }
    END {
      for (i = 1; i <= count; i++) { print name[i] "\t" value[i] }
      extra = split(live, state, " ")
      for (i = 1; i <= extra; i++) { print state[i] "\t" given[count + i] }
    }
  '
}

battery_revamped_setting_rows() {
  battery_revamped_setting_rows_format=$(battery_revamped_format)
  battery_revamped_setting_rows_live=$(tmux display-message -p "${battery_revamped_setting_rows_format}" 2>/dev/null) || battery_revamped_setting_rows_live=""
  battery_revamped_resolve "${battery_revamped_setting_rows_live}"
}

battery_revamped_load() {
  battery_revamped_load_values=$(battery_revamped_setting_rows)
  while IFS='	' read -r battery_revamped_load_name battery_revamped_load_value; do
    IFS= read -r "BATTERY_REVAMPED_S_${battery_revamped_load_name}" <<EOF
${battery_revamped_load_value}
EOF
  done <<EOF
${battery_revamped_load_values}
EOF
}

battery_revamped_parse_version() {
  printf '%s\n' "$1" | sed -En 's/^tmux[ -]([a-z]+-)?([0-9]+\.[0-9]+).*/\2/p'
}

battery_revamped_version_ge() {
  case "$1:$2" in
  *[!0-9.:]* | :* | *:) return 1 ;;
  *) ;;
  esac
  battery_revamped_version_ge_have="${1%%.*}"
  battery_revamped_version_ge_want="${2%%.*}"
  [ "${battery_revamped_version_ge_have}" -gt "${battery_revamped_version_ge_want}" ] && return 0
  [ "${battery_revamped_version_ge_have}" -eq "${battery_revamped_version_ge_want}" ] || return 1
  battery_revamped_version_ge_have="${1#*.}"
  battery_revamped_version_ge_want="${2#*.}"
  [ "${battery_revamped_version_ge_have%%.*}" -ge "${battery_revamped_version_ge_want%%.*}" ]
}

battery_revamped_emit() {
  for battery_revamped_emit_arg in "$@"; do
    case "${battery_revamped_emit_arg}" in
    *\;) battery_revamped_emit_arg="${battery_revamped_emit_arg%;}\\;" ;;
    *) ;;
    esac
    BATTERY_REVAMPED_PLAN="${BATTERY_REVAMPED_PLAN}${battery_revamped_emit_arg:-${BATTERY_REVAMPED_EMPTY}}
"
  done
  BATTERY_REVAMPED_PLAN="${BATTERY_REVAMPED_PLAN}
"
}

battery_revamped_literal() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e "s/#/'\"\$(printf '%b' '\\\\0043')\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

battery_revamped_send() {
  set --
  battery_revamped_send_sep=""
  while IFS= read -r battery_revamped_send_line; do
    if [ -z "${battery_revamped_send_line}" ]; then
      [ "$#" -eq 0 ] || battery_revamped_send_sep=";"
      continue
    fi
    [ -z "${battery_revamped_send_sep}" ] || set -- "$@" "${battery_revamped_send_sep}"
    battery_revamped_send_sep=""
    [ "${battery_revamped_send_line}" != "${BATTERY_REVAMPED_EMPTY}" ] || battery_revamped_send_line=""
    set -- "$@" "${battery_revamped_send_line}"
  done <<PLAN
${BATTERY_REVAMPED_PLAN}
PLAN
  [ "$#" -gt 0 ] || return 0
  tmux "$@" 2>/dev/null
}

battery_revamped_send_each() {
  battery_revamped_send_each_status=0
  set --
  while IFS= read -r battery_revamped_send_each_line; do
    if [ -n "${battery_revamped_send_each_line}" ]; then
      [ "${battery_revamped_send_each_line}" != "${BATTERY_REVAMPED_EMPTY}" ] || battery_revamped_send_each_line=""
      set -- "$@" "${battery_revamped_send_each_line}"
      continue
    fi
    [ "$#" -gt 0 ] || continue
    tmux "$@" || battery_revamped_send_each_status=1
    set --
  done <<PLAN
${BATTERY_REVAMPED_PLAN}
PLAN
  return "${battery_revamped_send_each_status}"
}

battery_revamped_deliver() {
  ! battery_revamped_send || return 0
  battery_revamped_send_each
}

battery_revamped_lines() {
  printf '%s' "${BATTERY_REVAMPED_PLAN}" | awk -v empty="${BATTERY_REVAMPED_EMPTY}" '$0 == empty { $0 = "\"\"" } $0 == "" && line != "" { print line; line = ""; next } $0 == "" { next } { line = (line == "" ? $0 : line " " $0) } END { if (line != "") { print line } }'
}

battery_revamped_json() {
  printf '%s' "${BATTERY_REVAMPED_PLAN}" | awk -v empty="${BATTERY_REVAMPED_EMPTY}" '
    function quote(s,    out, i, c) {
      out = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\\") { out = out "\\\\" } else if (c == "\"") { out = out "\\\"" } else { out = out c }
      }
      return "\"" out "\""
    }
    /^$/ { if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" } args = ""; next }
    $0 == empty { $0 = "" }
    { args = args (args == "" ? "" : ",") quote($0) }
    END {
      if (args != "") { rows = rows (rows == "" ? "" : ",") "[" args "]" }
      print "{\"bindings\":[" rows "]}"
    }
  '
}

battery_revamped_bindings() {
  printf '%s' "${BATTERY_REVAMPED_PLAN}" | awk 'previous == "" && $0 == "bind-key" { count++ } { previous = $0 } END { print count + 0 }'
}

battery_revamped_setting_name() {
  battery_revamped_setting_name_raw=$(printf '%s\n' "${1#--}" | tr '-' '_')
  case " ${BATTERY_REVAMPED_NAMES} " in
  *" ${battery_revamped_setting_name_raw} "*) printf '%s\n' "${battery_revamped_setting_name_raw}" ;;
  *) printf '\n' ;;
  esac
}

battery_revamped_bind() {
  case "$1" in
  "" | off) return 0 ;;
  *) ;;
  esac
  battery_revamped_bind_key="$1" battery_revamped_bind_note="$2"
  shift 2
  set -- "${battery_revamped_bind_key}" "$@"
  [ "${BATTERY_REVAMPED_NOTES}" != 1 ] || set -- -N "${battery_revamped_bind_note}" "$@"
  battery_revamped_emit bind-key "$@"
}

battery_revamped_job_quote() {
  printf '%s\n' "$1" | sed -e "s/'/'\\\\''/g" -e 's/#/##/g' -e 's/%/%%/g' -e "1s/^/'/" -e "\$s/\$/'/"
}

battery_revamped_carried() {
  battery_revamped_carried_set=$(env | sed -n 's/^BATTERY_REVAMPED_\([A-Z_]*\)=\(.*\)$/\1 \2/p')
  [ -n "${battery_revamped_carried_set}" ] || return 0
  printf '%s\n' "${battery_revamped_carried_set}" | BATTERY_REVAMPED_WANTED="${BATTERY_REVAMPED_CARRIED}" awk '
    BEGIN { count = split(ENVIRON["BATTERY_REVAMPED_WANTED"], name, " "); for (i = 1; i <= count; i++) { wanted[toupper(name[i])] = i } }
    {
      key = $1
      if (!(key in wanted)) { next }
      given[wanted[key]] = 1
      value[wanted[key]] = substr($0, length(key) + 2)
    }
    END {
      for (i = 1; i <= count; i++) {
        if (!given[i]) { continue }
        flag = name[i]
        gsub(/_/, "-", flag)
        print flag "\t" value[i]
      }
    }
  '
}

battery_revamped_tools() {
  battery_revamped_tools_path="${REVAMPED_LIB%/lib}/bin/battery-revamped"
  BATTERY_REVAMPED_TOOL=$(battery_revamped_literal "${battery_revamped_tools_path}")
  BATTERY_REVAMPED_JOB=$(battery_revamped_job_quote "${battery_revamped_tools_path}")
  battery_revamped_tools_rows=$(battery_revamped_carried)
  while IFS='	' read -r battery_revamped_tools_flag battery_revamped_tools_value; do
    [ -n "${battery_revamped_tools_flag}" ] || continue
    BATTERY_REVAMPED_TOOL="${BATTERY_REVAMPED_TOOL} --${battery_revamped_tools_flag} $(battery_revamped_literal "${battery_revamped_tools_value}")"
    BATTERY_REVAMPED_JOB="${BATTERY_REVAMPED_JOB} --${battery_revamped_tools_flag} $(battery_revamped_job_quote "${battery_revamped_tools_value}")"
  done <<EOF
${battery_revamped_tools_rows}
EOF
}

battery_revamped_held() {
  tmux list-keys -T prefix 2>/dev/null | awk '
    {
      at = 2
      if ($at == "-r") { at++ }
      if ($at == "-T") { at += 2 }
      key = $at
      if (key ~ /^\\./) { key = substr(key, 2) }
      rest = ""
      for (i = at + 1; i <= NF; i++) { rest = rest " " $i }
      if (index(rest, "battery-revamped") == 0) { printf "%s ", key }
    }
  '
}

battery_revamped_doubled() {
  battery_revamped_doubled_rest="$1" battery_revamped_doubled_hash='#' BATTERY_REVAMPED_DOUBLED=""
  while [ "${battery_revamped_doubled_rest}" != "${battery_revamped_doubled_rest#*"${battery_revamped_doubled_hash}"}" ]; do
    BATTERY_REVAMPED_DOUBLED="${BATTERY_REVAMPED_DOUBLED}${battery_revamped_doubled_rest%%"${battery_revamped_doubled_hash}"*}${battery_revamped_doubled_hash}${battery_revamped_doubled_hash}"
    battery_revamped_doubled_rest="${battery_revamped_doubled_rest#*"${battery_revamped_doubled_hash}"}"
  done
  BATTERY_REVAMPED_DOUBLED="${BATTERY_REVAMPED_DOUBLED}${battery_revamped_doubled_rest}"
}

battery_revamped_now() {
  BATTERY_REVAMPED_NOW=$(date +%s 2>/dev/null) || BATTERY_REVAMPED_NOW=0
}

battery_revamped_version() {
  battery_revamped_version_raw=$(tmux -V 2>/dev/null) || battery_revamped_version_raw=""
  BATTERY_REVAMPED_TMUX=$(battery_revamped_parse_version "${battery_revamped_version_raw}")
}

battery_revamped_number() {
  BATTERY_REVAMPED_NUMBER="$1"
  revamped_cache_is_number "$1" || BATTERY_REVAMPED_NUMBER="$2"
}

battery_revamped_store() {
  battery_revamped_emit set-option -gq "@battery_revamped_$1" "$2"
  IFS= read -r "BATTERY_REVAMPED_S_$1" <<EOF
$2
EOF
}

battery_revamped_slurp() {
  BATTERY_REVAMPED_LINE=""
  [ -r "$1" ] || return 1
  read -r BATTERY_REVAMPED_LINE 2>/dev/null <"$1" || :
}

battery_revamped_dir() {
  BATTERY_REVAMPED_DIR=""
  for battery_revamped_dir_each in "${BATTERY_REVAMPED_SYS}"/class/power_supply/BAT*; do
    [ -r "${battery_revamped_dir_each}/capacity" ] || continue
    BATTERY_REVAMPED_DIR="${battery_revamped_dir_each}"
    return 0
  done
}

battery_revamped_sys() {
  battery_revamped_slurp "${BATTERY_REVAMPED_DIR}/$1" || :
}

battery_revamped_assign() {
  while IFS='	' read -r battery_revamped_assign_name battery_revamped_assign_value; do
    [ -n "${battery_revamped_assign_name}" ] || continue
    IFS= read -r "BATTERY_REVAMPED_R_${battery_revamped_assign_name}" <<EOF
${battery_revamped_assign_value}
EOF
  done <<EOF
$1
EOF
}

battery_revamped_scan() {
  printf '%s\n' "$2" | LC_ALL=C awk -v mode="$1" '
    mode == "acpi" && NR > 1 { next }
    mode == "acpi" && NR == 1 { raw = $0 }
    percent == "" && match($0, /[0-9]+%/) { percent = substr($0, RSTART, RLENGTH - 1) }
    mode == "pmset" && !taken && /[0-9]+%/ { taken = 1; split($0, part, ";"); raw = part[2] }
    remain == "" && match($0, /[0-9]+:[0-9]+/) { remain = substr($0, RSTART, RLENGTH) }
    END { printf "percent\t%s\nraw\t%s\nremain\t%s\n", percent, raw, remain }
  '
}

battery_revamped_norm() {
  battery_revamped_norm_text=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "${battery_revamped_norm_text}" in
  *"not charging"* | *"pending-charge"* | *"pending charge"* | *"pending-discharge"* | *"pending discharge"*) BATTERY_REVAMPED_F_status=attached ;;
  *discharging*) BATTERY_REVAMPED_F_status=discharging ;;
  *charging*) BATTERY_REVAMPED_F_status=charging ;;
  *charged* | *full*) BATTERY_REVAMPED_F_status=charged ;;
  *) BATTERY_REVAMPED_F_status=unknown ;;
  esac
}

battery_revamped_acpi_read() {
  [ -z "${BATTERY_REVAMPED_ACPI_DONE}" ] || return 0
  BATTERY_REVAMPED_ACPI_DONE=1
  battery_revamped_acpi_read_text=$(acpi -b 2>/dev/null) || battery_revamped_acpi_read_text=""
  battery_revamped_acpi_read_rows=$(battery_revamped_scan acpi "${battery_revamped_acpi_read_text}")
  battery_revamped_assign "${battery_revamped_acpi_read_rows}"
}

battery_revamped_primary_pmset() {
  battery_revamped_primary_pmset_text=$(pmset -g batt 2>/dev/null) || battery_revamped_primary_pmset_text=""
  battery_revamped_primary_pmset_rows=$(battery_revamped_scan pmset "${battery_revamped_primary_pmset_text}")
  battery_revamped_assign "${battery_revamped_primary_pmset_rows}"
  BATTERY_REVAMPED_F_percent="${BATTERY_REVAMPED_R_percent}"
  battery_revamped_norm "${BATTERY_REVAMPED_R_raw}"
}

battery_revamped_primary_sysfs() {
  battery_revamped_sys capacity
  case "${BATTERY_REVAMPED_LINE}" in
  '' | *[!0-9]*) BATTERY_REVAMPED_F_percent="" ;;
  *) BATTERY_REVAMPED_F_percent="${BATTERY_REVAMPED_LINE}" ;;
  esac
  battery_revamped_sys status
  battery_revamped_norm "${BATTERY_REVAMPED_LINE}"
}

battery_revamped_primary_acpi() {
  battery_revamped_acpi_read
  BATTERY_REVAMPED_F_percent="${BATTERY_REVAMPED_R_percent}"
  battery_revamped_norm "${BATTERY_REVAMPED_R_raw}"
}

battery_revamped_primary() {
  BATTERY_REVAMPED_F_percent="" BATTERY_REVAMPED_F_status=unknown
  battery_revamped_dir
  if revamped_is_macos; then
    battery_revamped_primary_pmset
  elif [ -n "${BATTERY_REVAMPED_DIR}" ]; then
    battery_revamped_primary_sysfs
  elif revamped_has_command acpi; then
    battery_revamped_primary_acpi
  fi
}

battery_revamped_clock() {
  LC_ALL=C awk -v p="$1" -v r="$2" 'BEGIN { h = p / r; H = int(h); M = int((h - H) * 60 + 0.5); if (M == 60) { H++; M = 0 } printf "%d:%02d", H, M }'
}

battery_revamped_counter() {
  battery_revamped_sys "$1"
  [ -n "${BATTERY_REVAMPED_LINE}" ] || battery_revamped_sys "$2"
}

battery_revamped_remain_sysfs() {
  battery_revamped_counter energy_now charge_now
  battery_revamped_remain_sysfs_now="${BATTERY_REVAMPED_LINE}"
  battery_revamped_counter energy_full charge_full
  battery_revamped_remain_sysfs_full="${BATTERY_REVAMPED_LINE}"
  battery_revamped_counter power_now current_now
  battery_revamped_remain_sysfs_rate="${BATTERY_REVAMPED_LINE}"
  revamped_cache_is_number "${battery_revamped_remain_sysfs_now}" || return 0
  revamped_cache_is_number "${battery_revamped_remain_sysfs_rate}" || return 0
  [ "${battery_revamped_remain_sysfs_rate}" -gt 0 ] || return 0
  case "${BATTERY_REVAMPED_F_status}" in
  discharging) battery_revamped_remain_sysfs_left="${battery_revamped_remain_sysfs_now}" ;;
  charging) battery_revamped_remain_sysfs_left=$(battery_revamped_remain_sysfs_gap "${battery_revamped_remain_sysfs_now}" "${battery_revamped_remain_sysfs_full}") ;;
  *) return 0 ;;
  esac
  [ -n "${battery_revamped_remain_sysfs_left}" ] || return 0
  BATTERY_REVAMPED_F_remain=$(battery_revamped_clock "${battery_revamped_remain_sysfs_left}" "${battery_revamped_remain_sysfs_rate}")
}

battery_revamped_remain_sysfs_gap() {
  revamped_cache_is_number "$2" || return 0
  [ "$2" -gt "$1" ] || return 0
  printf '%s' "$(($2 - $1))"
}

battery_revamped_remain_linux() {
  BATTERY_REVAMPED_F_remain=""
  if revamped_has_command acpi; then
    battery_revamped_acpi_read
    BATTERY_REVAMPED_F_remain="${BATTERY_REVAMPED_R_remain}"
  fi
  [ -z "${BATTERY_REVAMPED_F_remain}" ] || return 0
  battery_revamped_dir
  [ -z "${BATTERY_REVAMPED_DIR}" ] || battery_revamped_remain_sysfs
}

battery_revamped_percent_of() {
  case "$1:$2" in
  *[!0-9:]* | :* | *: | *:0) return 0 ;;
  *) ;;
  esac
  battery_revamped_percent_of_value=$(($1 * 100 / $2))
  [ "${battery_revamped_percent_of_value}" -le 100 ] || battery_revamped_percent_of_value=100
  printf '%s' "${battery_revamped_percent_of_value}"
}

battery_revamped_details_linux() {
  BATTERY_REVAMPED_F_watts="" BATTERY_REVAMPED_F_cycles="" BATTERY_REVAMPED_F_health=""
  battery_revamped_dir
  [ -n "${BATTERY_REVAMPED_DIR}" ] || return 0
  battery_revamped_sys power_now
  ! revamped_cache_is_number "${BATTERY_REVAMPED_LINE}" || BATTERY_REVAMPED_F_watts=$((BATTERY_REVAMPED_LINE / 1000000))
  battery_revamped_sys cycle_count
  ! revamped_cache_is_number "${BATTERY_REVAMPED_LINE}" || BATTERY_REVAMPED_F_cycles="${BATTERY_REVAMPED_LINE}"
  battery_revamped_sys energy_full
  battery_revamped_details_linux_full="${BATTERY_REVAMPED_LINE}"
  battery_revamped_sys energy_full_design
  battery_revamped_details_linux_design="${BATTERY_REVAMPED_LINE}"
  if [ -z "${battery_revamped_details_linux_full}" ] || [ -z "${battery_revamped_details_linux_design}" ]; then
    battery_revamped_sys charge_full
    battery_revamped_details_linux_full="${BATTERY_REVAMPED_LINE}"
    battery_revamped_sys charge_full_design
    battery_revamped_details_linux_design="${BATTERY_REVAMPED_LINE}"
  fi
  BATTERY_REVAMPED_F_health=$(battery_revamped_percent_of "${battery_revamped_details_linux_full}" "${battery_revamped_details_linux_design}")
}

battery_revamped_ioreg_rows() {
  printf '%s\n' "$1" | LC_ALL=C awk '
    BEGIN {
      count = split("CycleCount AppleRawMaxCapacity MaxCapacity DesignCapacity", name, " ")
      split("cycles rawmax max design", field, " ")
    }
    {
      line = $0
      sub(/^[ \t]*/, "", line)
      for (i = 1; i <= count; i++) {
        key = "\"" name[i] "\" = "
        if (!(i in value) && index(line, key) == 1) {
          text = substr(line, length(key) + 1)
          gsub(/[^0-9]/, "", text)
          value[i] = text
        }
      }
    }
    END { for (i = 1; i <= count; i++) { printf "%s\t%s\n", field[i], value[i] } }
  '
}

battery_revamped_wattage() {
  printf '%s\n' "$1" | LC_ALL=C awk 'tolower($0) ~ /wattage/ && match($0, /[0-9]+/) { print substr($0, RSTART, RLENGTH); exit }'
}

battery_revamped_details_macos() {
  battery_revamped_details_macos_text=$(system_profiler SPPowerDataType 2>/dev/null) || battery_revamped_details_macos_text=""
  BATTERY_REVAMPED_F_watts=$(battery_revamped_wattage "${battery_revamped_details_macos_text}")
  battery_revamped_details_macos_text=$(ioreg -r -c AppleSmartBattery 2>/dev/null) || battery_revamped_details_macos_text=""
  battery_revamped_details_macos_rows=$(battery_revamped_ioreg_rows "${battery_revamped_details_macos_text}")
  battery_revamped_assign "${battery_revamped_details_macos_rows}"
  BATTERY_REVAMPED_F_cycles="${BATTERY_REVAMPED_R_cycles}"
  BATTERY_REVAMPED_F_remain="${BATTERY_REVAMPED_R_remain}"
  battery_revamped_details_macos_max="${BATTERY_REVAMPED_R_rawmax:-${BATTERY_REVAMPED_R_max}}"
  BATTERY_REVAMPED_F_health=$(battery_revamped_percent_of "${battery_revamped_details_macos_max}" "${BATTERY_REVAMPED_R_design}")
}

battery_revamped_details() {
  BATTERY_REVAMPED_F_remain="" BATTERY_REVAMPED_F_watts="" BATTERY_REVAMPED_F_cycles="" BATTERY_REVAMPED_F_health=""
  if revamped_is_macos; then
    battery_revamped_details_macos
    return 0
  fi
  battery_revamped_remain_linux
  ! revamped_is_linux || battery_revamped_details_linux
}

battery_revamped_ring() {
  battery_revamped_ring_text="${1:+$1,}$2"
  battery_revamped_ring_rest="${battery_revamped_ring_text}"
  battery_revamped_ring_count=1
  while [ "${battery_revamped_ring_rest}" != "${battery_revamped_ring_rest#*,}" ]; do
    battery_revamped_ring_rest="${battery_revamped_ring_rest#*,}"
    battery_revamped_ring_count=$((battery_revamped_ring_count + 1))
  done
  while [ "${battery_revamped_ring_count}" -gt "$3" ]; do
    battery_revamped_ring_text="${battery_revamped_ring_text#*,}"
    battery_revamped_ring_count=$((battery_revamped_ring_count - 1))
  done
  BATTERY_REVAMPED_RING="${battery_revamped_ring_text}"
}

battery_revamped_rate() {
  revamped_cache_is_number "$1" && revamped_cache_is_number "$2" && revamped_cache_is_number "$3" && revamped_cache_is_number "$4" || return 0
  battery_revamped_rate_span=$(($4 - $2))
  [ "${battery_revamped_rate_span}" -gt 0 ] || return 0
  LC_ALL=C awk -v a="$1" -v b="$3" -v d="${battery_revamped_rate_span}" 'BEGIN { printf "%.1f", (a - b) * 3600 / d }'
}

battery_revamped_drain_due() {
  revamped_cache_is_number "${BATTERY_REVAMPED_S_snap_ts}" || return 0
  [ "$((BATTERY_REVAMPED_NOW - BATTERY_REVAMPED_S_snap_ts))" -ge "${BATTERY_REVAMPED_DRAIN_WINDOW}" ] && return 0
  [ "${BATTERY_REVAMPED_NOW}" -lt "${BATTERY_REVAMPED_S_snap_ts}" ]
}

battery_revamped_drain() {
  battery_revamped_drain_due || return 0
  battery_revamped_drain_rate=$(battery_revamped_rate "${BATTERY_REVAMPED_S_snap_pct}" "${BATTERY_REVAMPED_S_snap_ts}" "${BATTERY_REVAMPED_F_percent}" "${BATTERY_REVAMPED_NOW}")
  [ -z "${battery_revamped_drain_rate}" ] || battery_revamped_store drain_rate "${battery_revamped_drain_rate}"
  battery_revamped_store snap_pct "${BATTERY_REVAMPED_F_percent}"
  battery_revamped_store snap_ts "${BATTERY_REVAMPED_NOW}"
}

battery_revamped_history() {
  battery_revamped_number "${BATTERY_REVAMPED_S_history_size}" "${BATTERY_REVAMPED_DEFAULT_HISTORY}"
  [ "${BATTERY_REVAMPED_NUMBER}" -gt 0 ] || BATTERY_REVAMPED_NUMBER="${BATTERY_REVAMPED_DEFAULT_HISTORY}"
  BATTERY_REVAMPED_RING="${BATTERY_REVAMPED_S_history}"
  ! revamped_cache_is_number "${BATTERY_REVAMPED_F_percent}" || battery_revamped_ring "${BATTERY_REVAMPED_S_history}" "${BATTERY_REVAMPED_F_percent}" "${BATTERY_REVAMPED_NUMBER}"
  battery_revamped_store history "${BATTERY_REVAMPED_RING}"
}

battery_revamped_level() {
  battery_revamped_number "${BATTERY_REVAMPED_S_low_threshold}" "${BATTERY_REVAMPED_DEFAULT_LOW}"
  battery_revamped_level_low="${BATTERY_REVAMPED_NUMBER}"
  battery_revamped_number "${BATTERY_REVAMPED_S_critical_threshold}" "${BATTERY_REVAMPED_DEFAULT_CRITICAL}"
  BATTERY_REVAMPED_LEVEL=unknown
  revamped_cache_is_number "$1" || return 0
  BATTERY_REVAMPED_LEVEL=ok
  case "$2" in
  charged) BATTERY_REVAMPED_LEVEL=full ;;
  charging) [ "$1" -lt 100 ] || BATTERY_REVAMPED_LEVEL=full ;;
  discharging) battery_revamped_level_pick "$1" "${battery_revamped_level_low}" "${BATTERY_REVAMPED_NUMBER}" ;;
  *) ;;
  esac
}

battery_revamped_level_pick() {
  if [ "$1" -le "$3" ]; then
    BATTERY_REVAMPED_LEVEL=critical
  elif [ "$1" -le "$2" ]; then
    BATTERY_REVAMPED_LEVEL=low
  fi
}

battery_revamped_alert() {
  battery_revamped_alert_prev="${BATTERY_REVAMPED_S_alert_level}"
  battery_revamped_level "${BATTERY_REVAMPED_F_percent}" "${BATTERY_REVAMPED_F_status}"
  battery_revamped_store alert_level "${BATTERY_REVAMPED_LEVEL}"
  [ "${BATTERY_REVAMPED_S_notify}" = 1 ] || return 0
  [ "${BATTERY_REVAMPED_LEVEL}" != "${battery_revamped_alert_prev}" ] || return 0
  case "${BATTERY_REVAMPED_LEVEL}" in
  critical) battery_revamped_alert_send "Critically low: ${BATTERY_REVAMPED_F_percent}%" ;;
  low) battery_revamped_alert_send "Low battery: ${BATTERY_REVAMPED_F_percent}%" ;;
  full) battery_revamped_alert_send "Fully charged: ${BATTERY_REVAMPED_F_percent}%" ;;
  *) return 0 ;;
  esac
}

battery_revamped_alert_send() {
  revamped_notify_send "Battery ${BATTERY_REVAMPED_LEVEL}" "$1"
}

battery_revamped_due() {
  revamped_cache_is_number "${BATTERY_REVAMPED_S_detail_ts}" || return 0
  [ "$((BATTERY_REVAMPED_NOW - BATTERY_REVAMPED_S_detail_ts))" -gt "${BATTERY_REVAMPED_DETAIL}" ]
}

battery_revamped_keep() {
  battery_revamped_store percent "${BATTERY_REVAMPED_F_percent}"
  battery_revamped_store status "${BATTERY_REVAMPED_F_status}"
  battery_revamped_store percent_ts "${BATTERY_REVAMPED_NOW}"
  if [ -n "${BATTERY_REVAMPED_DUE}" ]; then
    battery_revamped_store remain "${BATTERY_REVAMPED_F_remain}"
    battery_revamped_store watts "${BATTERY_REVAMPED_F_watts}"
    battery_revamped_store cycles "${BATTERY_REVAMPED_F_cycles}"
    battery_revamped_store health "${BATTERY_REVAMPED_F_health}"
    battery_revamped_store detail_ts "${BATTERY_REVAMPED_NOW}"
  fi
  battery_revamped_drain
  battery_revamped_history
  battery_revamped_alert
}

battery_revamped_sample() {
  battery_revamped_number "${BATTERY_REVAMPED_S_detail_interval}" "${BATTERY_REVAMPED_DEFAULT_DETAIL}"
  BATTERY_REVAMPED_DETAIL="${BATTERY_REVAMPED_NUMBER}"
  BATTERY_REVAMPED_DUE="" BATTERY_REVAMPED_ACPI_DONE="" BATTERY_REVAMPED_R_percent="" BATTERY_REVAMPED_R_raw="" BATTERY_REVAMPED_R_remain=""
  battery_revamped_primary
  ! battery_revamped_due || BATTERY_REVAMPED_DUE=1
  [ -z "${BATTERY_REVAMPED_DUE}" ] || battery_revamped_details
  battery_revamped_keep
}

battery_revamped_refresh() {
  BATTERY_REVAMPED_PLAN=""
  battery_revamped_now
  battery_revamped_sample
  BATTERY_REVAMPED_STORED=1
  battery_revamped_send || BATTERY_REVAMPED_STORED=0
}

battery_revamped_limit() {
  battery_revamped_number "${BATTERY_REVAMPED_S_interval}" "${BATTERY_REVAMPED_DEFAULT_INTERVAL}"
  BATTERY_REVAMPED_LIMIT="${BATTERY_REVAMPED_NUMBER}"
  [ "${BATTERY_REVAMPED_S_interval}" != minute ] || BATTERY_REVAMPED_LIMIT="${BATTERY_REVAMPED_MINUTE}"
}

battery_revamped_stale() {
  revamped_cache_is_number "${BATTERY_REVAMPED_S_percent_ts}" || return 0
  [ "$((BATTERY_REVAMPED_NOW - BATTERY_REVAMPED_S_percent_ts))" -gt "${BATTERY_REVAMPED_LIMIT}" ]
}

battery_revamped_locked() {
  [ "${BATTERY_REVAMPED_S_percent_lock}" = 1 ] || return 1
  revamped_cache_is_number "${BATTERY_REVAMPED_S_percent_lock_ts}" || return 1
  [ "$((BATTERY_REVAMPED_NOW - BATTERY_REVAMPED_S_percent_lock_ts))" -lt "${REVAMPED_CACHE_MAX_RUN_DEFAULT}" ]
}

battery_revamped_text() {
  BATTERY_REVAMPED_TEXT="$1"
  [ "$1" != off ] || BATTERY_REVAMPED_TEXT=""
}

battery_revamped_off() {
  [ "${BATTERY_REVAMPED_OUT}" = off ] || return 1
  BATTERY_REVAMPED_OUT=""
}

battery_revamped_pick() {
  case "$1:${BATTERY_REVAMPED_TIER}" in
  icon:1) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier1_icon}" ;;
  icon:2) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier2_icon}" ;;
  icon:3) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier3_icon}" ;;
  icon:4) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier4_icon}" ;;
  icon:5) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier5_icon}" ;;
  icon:6) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier6_icon}" ;;
  icon:7) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier7_icon}" ;;
  icon:8) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier8_icon}" ;;
  fg:1) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier1_fg_color}" ;;
  fg:2) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier2_fg_color}" ;;
  fg:3) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier3_fg_color}" ;;
  fg:4) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier4_fg_color}" ;;
  fg:5) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier5_fg_color}" ;;
  fg:6) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier6_fg_color}" ;;
  fg:7) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier7_fg_color}" ;;
  fg:8) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier8_fg_color}" ;;
  bg:1) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier1_bg_color}" ;;
  bg:2) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier2_bg_color}" ;;
  bg:3) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier3_bg_color}" ;;
  bg:4) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier4_bg_color}" ;;
  bg:5) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier5_bg_color}" ;;
  bg:6) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier6_bg_color}" ;;
  bg:7) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier7_bg_color}" ;;
  *) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_charge_tier8_bg_color}" ;;
  esac
}

battery_revamped_tier() {
  battery_revamped_number "${BATTERY_REVAMPED_S_percent}" 0
  BATTERY_REVAMPED_TIER=$(((BATTERY_REVAMPED_NUMBER * 8 + 99) / 100))
  [ "${BATTERY_REVAMPED_TIER}" -ge 1 ] || BATTERY_REVAMPED_TIER=1
  [ "${BATTERY_REVAMPED_TIER}" -le 8 ] || BATTERY_REVAMPED_TIER=8
}

battery_revamped_glyph() {
  if [ "${BATTERY_REVAMPED_S_icons}" != nerd ]; then
    set -- ▁ ▂ ▃ ▄ ▅ ▆ ▇ █
  elif [ "${BATTERY_REVAMPED_S_status}" = charging ]; then
    set -- '\0363\0260\0242\0234' '\0363\0260\0202\0206' '\0363\0260\0202\0207' '\0363\0260\0202\0210' '\0363\0260\0202\0211' '\0363\0260\0242\0236' '\0363\0260\0202\0212' '\0363\0260\0202\0205'
  else
    set -- '\0363\0260\0201\0272' '\0363\0260\0201\0273' '\0363\0260\0201\0274' '\0363\0260\0201\0275' '\0363\0260\0201\0277' '\0363\0260\0202\0200' '\0363\0260\0202\0201' '\0363\0260\0201\0271'
  fi
  shift "$((BATTERY_REVAMPED_TIER - 1))"
  BATTERY_REVAMPED_GLYPH="$1"
}

battery_revamped_charge_icon() {
  BATTERY_REVAMPED_OUT=""
  [ -n "${BATTERY_REVAMPED_S_percent}" ] || return 0
  battery_revamped_tier
  battery_revamped_pick icon
  battery_revamped_off && return 0
  [ -z "${BATTERY_REVAMPED_OUT}" ] || return 0
  battery_revamped_glyph
  BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_GLYPH}"
  [ "${BATTERY_REVAMPED_S_icons}" != nerd ] || BATTERY_REVAMPED_OUT=$(printf '%b' "${BATTERY_REVAMPED_GLYPH}")
}

battery_revamped_charge_color() {
  BATTERY_REVAMPED_OUT=""
  [ -n "${BATTERY_REVAMPED_S_percent}" ] || return 0
  battery_revamped_tier
  battery_revamped_pick "$1"
}

battery_revamped_status_name() {
  case "${BATTERY_REVAMPED_S_status}" in
  charged | charging | discharging | attached) BATTERY_REVAMPED_NAME="${BATTERY_REVAMPED_S_status}" ;;
  *) BATTERY_REVAMPED_NAME=unknown ;;
  esac
}

battery_revamped_status_icon() {
  battery_revamped_status_name
  case "${BATTERY_REVAMPED_NAME}" in
  charged) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charged_icon:-=}" ;;
  charging) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charging_icon:-+}" ;;
  discharging) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_discharging_icon:--}" ;;
  attached) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_attached_icon:-!}" ;;
  *) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_unknown_icon:-?}" ;;
  esac
  battery_revamped_off || :
}

battery_revamped_status_color() {
  battery_revamped_status_name
  case "${BATTERY_REVAMPED_NAME}:$1" in
  charged:fg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charged_fg_color}" ;;
  charged:bg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charged_bg_color}" ;;
  charging:fg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charging_fg_color}" ;;
  charging:bg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_charging_bg_color}" ;;
  discharging:fg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_discharging_fg_color}" ;;
  discharging:bg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_discharging_bg_color}" ;;
  attached:fg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_attached_fg_color}" ;;
  attached:bg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_attached_bg_color}" ;;
  unknown:fg) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_unknown_fg_color}" ;;
  *) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_status_unknown_bg_color}" ;;
  esac
}

battery_revamped_value_shaped() {
  BATTERY_REVAMPED_OUT=""
  [ -n "$2" ] || return 0
  # shellcheck disable=SC2059
  BATTERY_REVAMPED_OUT=$(printf "$1" "$2")
}

battery_revamped_value_graph() {
  BATTERY_REVAMPED_OUT=""
  revamped_cache_is_number "${BATTERY_REVAMPED_S_percent}" || return 0
  battery_revamped_number "${BATTERY_REVAMPED_S_graph_width}" "${BATTERY_REVAMPED_DEFAULT_GRAPH}"
  battery_revamped_value_graph_width="${BATTERY_REVAMPED_NUMBER}"
  battery_revamped_value_graph_filled=$(((BATTERY_REVAMPED_S_percent * battery_revamped_value_graph_width + 50) / 100))
  [ "${battery_revamped_value_graph_filled}" -le "${battery_revamped_value_graph_width}" ] || battery_revamped_value_graph_filled="${battery_revamped_value_graph_width}"
  battery_revamped_text "${BATTERY_REVAMPED_S_graph_full}"
  battery_revamped_value_graph_full="${BATTERY_REVAMPED_TEXT}"
  battery_revamped_text "${BATTERY_REVAMPED_S_graph_empty}"
  battery_revamped_value_graph_empty="${BATTERY_REVAMPED_TEXT}"
  battery_revamped_value_graph_cell=0
  while [ "${battery_revamped_value_graph_cell}" -lt "${battery_revamped_value_graph_width}" ]; do
    if [ "${battery_revamped_value_graph_cell}" -lt "${battery_revamped_value_graph_filled}" ]; then
      BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_OUT}${battery_revamped_value_graph_full}"
    else
      BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_OUT}${battery_revamped_value_graph_empty}"
    fi
    battery_revamped_value_graph_cell=$((battery_revamped_value_graph_cell + 1))
  done
}

battery_revamped_value_estimate() {
  BATTERY_REVAMPED_OUT=""
  revamped_cache_is_number "${BATTERY_REVAMPED_S_percent}" || return 0
  case "${BATTERY_REVAMPED_S_drain_rate}" in
  '' | *[!0-9.-]*) return 0 ;;
  *) ;;
  esac
  battery_revamped_value_estimate_time=$(LC_ALL=C awk -v p="${BATTERY_REVAMPED_S_percent}" -v r="${BATTERY_REVAMPED_S_drain_rate}" -v s="${BATTERY_REVAMPED_S_status}" 'BEGIN { if (s == "discharging" && r > 0) { h = p / r } else if (s == "charging" && r < 0) { h = (100 - p) / (-r) } else { exit } H = int(h); M = int((h - H) * 60 + 0.5); if (M == 60) { H++; M = 0 } printf "%d:%02d", H, M }')
  battery_revamped_value_shaped "${BATTERY_REVAMPED_S_remain_format}" "${battery_revamped_value_estimate_time}"
}

battery_revamped_value_sparkline() {
  BATTERY_REVAMPED_OUT=""
  battery_revamped_value_sparkline_rest="${BATTERY_REVAMPED_S_history}" battery_revamped_value_sparkline_bytes=""
  while [ -n "${battery_revamped_value_sparkline_rest}" ]; do
    battery_revamped_value_sparkline_item="${battery_revamped_value_sparkline_rest%%,*}"
    battery_revamped_value_sparkline_rest="${battery_revamped_value_sparkline_rest#"${battery_revamped_value_sparkline_item}"}"
    battery_revamped_value_sparkline_rest="${battery_revamped_value_sparkline_rest#,}"
    revamped_cache_is_number "${battery_revamped_value_sparkline_item}" || continue
    battery_revamped_value_sparkline_step=$((battery_revamped_value_sparkline_item * 7 / 100))
    [ "${battery_revamped_value_sparkline_step}" -le 7 ] || battery_revamped_value_sparkline_step=7
    set -- 201 202 203 204 205 206 207 210
    shift "${battery_revamped_value_sparkline_step}"
    battery_revamped_value_sparkline_bytes="${battery_revamped_value_sparkline_bytes}\\0342\\0226\\0$1"
  done
  [ -n "${battery_revamped_value_sparkline_bytes}" ] || return 0
  BATTERY_REVAMPED_OUT=$(printf '%b' "${battery_revamped_value_sparkline_bytes}")
}

battery_revamped_value_alert() {
  BATTERY_REVAMPED_OUT=""
  battery_revamped_level "${BATTERY_REVAMPED_S_percent}" "${BATTERY_REVAMPED_S_status}"
  case "${BATTERY_REVAMPED_LEVEL}" in
  critical) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_critical_icon}" ;;
  low) BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_low_icon}" ;;
  *) ;;
  esac
  battery_revamped_off || :
}

battery_revamped_value_source() {
  if [ "${BATTERY_REVAMPED_S_status}" = discharging ]; then
    BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_source_battery_label}"
  else
    BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_S_source_ac_label}"
  fi
  battery_revamped_off || :
}

battery_revamped_value() {
  case "$1" in
  percentage) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_percentage_format}" "${BATTERY_REVAMPED_S_percent}" ;;
  icon | icon_charge) battery_revamped_charge_icon ;;
  icon_status) battery_revamped_status_icon ;;
  color_fg | color_status_fg) battery_revamped_status_color fg ;;
  color_bg | color_status_bg) battery_revamped_status_color bg ;;
  color_charge_fg) battery_revamped_charge_color fg ;;
  color_charge_bg) battery_revamped_charge_color bg ;;
  graph) battery_revamped_value_graph ;;
  remain) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_remain_format}" "${BATTERY_REVAMPED_S_remain}" ;;
  charging_watts) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_watts_format}" "${BATTERY_REVAMPED_S_watts}" ;;
  cycles) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_cycles_format}" "${BATTERY_REVAMPED_S_cycles}" ;;
  health) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_health_format}" "${BATTERY_REVAMPED_S_health}" ;;
  drain_rate) battery_revamped_value_shaped "${BATTERY_REVAMPED_S_drain_rate_format}" "${BATTERY_REVAMPED_S_drain_rate}" ;;
  estimate) battery_revamped_value_estimate ;;
  sparkline) battery_revamped_value_sparkline ;;
  power_source) battery_revamped_value_source ;;
  *) battery_revamped_value_alert ;;
  esac
}

battery_revamped_style_value() {
  case "$1" in
  '#[fg='*']')
    battery_revamped_style_value_inner="${1#'#[fg='}"
    BATTERY_REVAMPED_OUT="${battery_revamped_style_value_inner%']'}"
    ;;
  *) BATTERY_REVAMPED_OUT="$1" ;;
  esac
}

battery_revamped_wrap() {
  [ -n "${BATTERY_REVAMPED_OUT}" ] || return 0
  battery_revamped_wrap_value="${BATTERY_REVAMPED_OUT}"
  battery_revamped_charge_icon
  battery_revamped_wrap_icon="${BATTERY_REVAMPED_OUT}"
  battery_revamped_charge_color fg
  battery_revamped_style_value "${BATTERY_REVAMPED_OUT}"
  battery_revamped_wrap_color="${BATTERY_REVAMPED_OUT}"
  battery_revamped_text "${BATTERY_REVAMPED_S_before}"
  revamped_publish_replace '{icon}' "${battery_revamped_wrap_icon}" "${BATTERY_REVAMPED_TEXT}"
  revamped_publish_replace '{color}' "${battery_revamped_wrap_color}" "${revamped_publish_replace_out}"
  battery_revamped_wrap_before="${revamped_publish_replace_out}"
  battery_revamped_text "${BATTERY_REVAMPED_S_after}"
  revamped_publish_replace '{icon}' "${battery_revamped_wrap_icon}" "${BATTERY_REVAMPED_TEXT}"
  revamped_publish_replace '{color}' "${battery_revamped_wrap_color}" "${revamped_publish_replace_out}"
  BATTERY_REVAMPED_OUT="${battery_revamped_wrap_before}${battery_revamped_wrap_value}${revamped_publish_replace_out}"
}

battery_revamped_own() {
  BATTERY_REVAMPED_NATURAL=0
  case "$1" in
  percentage) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_percentage_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_percentage_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0201\0271' BATTERY_REVAMPED_NATURAL=4 ;;
  graph) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_graph_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_graph_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0236\0261' ;;
  remain) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_remain_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_remain_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0224\0237' ;;
  charging_watts) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_charging_watts_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_charging_watts_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0211\0201' ;;
  cycles) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_cycles_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_cycles_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0223\0246' ;;
  health) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_health_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_health_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0227\0266' ;;
  drain_rate) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_drain_rate_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_drain_rate_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0224\0263' ;;
  estimate) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_estimate_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_estimate_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0224\0237' ;;
  sparkline) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_sparkline_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_sparkline_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0236\0261' ;;
  *) BATTERY_REVAMPED_LABEL="${BATTERY_REVAMPED_S_power_source_label}" BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_S_power_source_width}" BATTERY_REVAMPED_GLYPH='\0363\0260\0232\0245' ;;
  esac
}

battery_revamped_pad() {
  if ! revamped_cache_is_number "${BATTERY_REVAMPED_WIDTH}"; then
    BATTERY_REVAMPED_WIDTH=0
    [ "${BATTERY_REVAMPED_S_fixed_width}" != on ] || BATTERY_REVAMPED_WIDTH="${BATTERY_REVAMPED_NATURAL}"
  fi
  [ "${BATTERY_REVAMPED_WIDTH}" -gt 0 ] || return 0
  revamped_publish_count "${BATTERY_REVAMPED_OUT}"
  [ "${revamped_publish_count_out}" -lt "${BATTERY_REVAMPED_WIDTH}" ] || return 0
  battery_revamped_pad_gap=$(printf "%$((BATTERY_REVAMPED_WIDTH - revamped_publish_count_out))s" '')
  BATTERY_REVAMPED_OUT="${battery_revamped_pad_gap}${BATTERY_REVAMPED_OUT}"
}

battery_revamped_label() {
  [ "${BATTERY_REVAMPED_LABEL}" != off ] || BATTERY_REVAMPED_LABEL="" BATTERY_REVAMPED_GLYPH=""
  [ -z "${BATTERY_REVAMPED_LABEL}" ] || return 0
  [ -n "${BATTERY_REVAMPED_GLYPH}" ] || return 0
  [ "${BATTERY_REVAMPED_S_icons}" = nerd ] || return 0
  BATTERY_REVAMPED_LABEL=$(printf '%b' "${BATTERY_REVAMPED_GLYPH}")
}

battery_revamped_hidden() {
  [ "${BATTERY_REVAMPED_S_hide_on_ac}" = 1 ] || return 1
  [ "${BATTERY_REVAMPED_S_status}" != discharging ]
}

battery_revamped_output() {
  BATTERY_REVAMPED_OUT=""
  ! battery_revamped_hidden || return 0
  battery_revamped_value "$1"
  [ "$1" != percentage ] || battery_revamped_wrap
  case " ${BATTERY_REVAMPED_LABELLED} " in
  *" $1 "*) : ;;
  *) return 0 ;;
  esac
  [ -n "${BATTERY_REVAMPED_OUT}" ] || return 0
  battery_revamped_own "$1"
  battery_revamped_pad
  battery_revamped_label
  [ -z "${BATTERY_REVAMPED_LABEL}" ] || BATTERY_REVAMPED_OUT="${BATTERY_REVAMPED_LABEL} ${BATTERY_REVAMPED_OUT}"
}

battery_revamped_show() {
  battery_revamped_output "$1"
  [ -z "${BATTERY_REVAMPED_OUT}" ] || printf '%s\n' "${BATTERY_REVAMPED_OUT}"
}

battery_revamped_status() {
  battery_revamped_load
  battery_revamped_now
  battery_revamped_limit
  if battery_revamped_stale && ! battery_revamped_locked; then
    revamped_cache_refresh_if_stale percent "${BATTERY_REVAMPED_LIMIT}" battery_revamped_refresh || :
  fi
  battery_revamped_show "$1"
}

battery_revamped_publish() {
  battery_revamped_refresh
  [ "${BATTERY_REVAMPED_STORED}" = 1 ] || return 0
  battery_revamped_publish_rest="${BATTERY_REVAMPED_S_published}"
  while [ -n "${battery_revamped_publish_rest}" ]; do
    battery_revamped_publish_metric="${battery_revamped_publish_rest%% *}"
    battery_revamped_publish_rest="${battery_revamped_publish_rest#"${battery_revamped_publish_metric}"}"
    battery_revamped_publish_rest="${battery_revamped_publish_rest# }"
    [ -n "${battery_revamped_publish_metric}" ] || continue
    battery_revamped_output "${battery_revamped_publish_metric}"
    revamped_publish_add "@battery_revamped_out_${battery_revamped_publish_metric}" "${BATTERY_REVAMPED_OUT}"
  done
  revamped_publish_commit || :
}

battery_revamped_tick() {
  battery_revamped_load
  battery_revamped_publish
}

battery_revamped_daemon() {
  revamped_ticker_run battery_revamped battery_revamped_tick "$$" "${BATTERY_REVAMPED_DEFAULT_INTERVAL}"
}

battery_revamped_popup_check() {
  BATTERY_REVAMPED_POPUP_OK=0
  ! battery_revamped_version_ge "${BATTERY_REVAMPED_TMUX}" "${BATTERY_REVAMPED_POPUP_SINCE}" || BATTERY_REVAMPED_POPUP_OK=1
}

battery_revamped_popup() {
  battery_revamped_load
  battery_revamped_version
  battery_revamped_popup_check
  if [ "${BATTERY_REVAMPED_POPUP_OK}" != 1 ]; then
    tmux display-message "battery-revamped: tmux 3.2+ is required for the battery detail popup" 2>/dev/null || :
    return 0
  fi
  battery_revamped_tools
  tmux display-popup -E -w "${BATTERY_REVAMPED_S_popup_width}" -h "${BATTERY_REVAMPED_S_popup_height}" "${BATTERY_REVAMPED_TOOL} popup-card" 2>/dev/null || :
}

battery_revamped_plan_keys() {
  case "${BATTERY_REVAMPED_S_popup_key}: ${BATTERY_REVAMPED_KEYS} " in
  "${BATTERY_REVAMPED_DEFAULT_POPUP_KEY}:"*" ${BATTERY_REVAMPED_DEFAULT_POPUP_KEY} "*) BATTERY_REVAMPED_SKIPPED="${BATTERY_REVAMPED_SKIPPED}${BATTERY_REVAMPED_SKIPPED:+ }${BATTERY_REVAMPED_DEFAULT_POPUP_KEY}" ;;
  *) battery_revamped_bind "${BATTERY_REVAMPED_S_popup_key}" "Battery details" run-shell "${BATTERY_REVAMPED_TOOL} popup" ;;
  esac
}

battery_revamped_replaced() {
  printf '%s\n' "$1" | BATTERY_REVAMPED_PUT="${BATTERY_REVAMPED_JOB}" awk -v mode="${BATTERY_REVAMPED_S_render}" -v kinds="${BATTERY_REVAMPED_METRICS}" '
    BEGIN {
      command = ENVIRON["BATTERY_REVAMPED_PUT"]
      count = split(kinds, kind, " ")
    }
    {
      line = $0
      for (i = 1; i <= count; i++) {
        holder = "#{battery_" kind[i] "}"
        target = (mode == "options") ? "#{E:@battery_revamped_out_" kind[i] "}" : "#(" command " status " kind[i] ")"
        done = ""
        while ((at = index(line, holder)) > 0) {
          done = done substr(line, 1, at - 1) target
          line = substr(line, at + length(holder))
        }
        line = done line
      }
      print line
    }
  '
}

battery_revamped_used() {
  printf '%s\n' "$1" | awk -v kinds="${BATTERY_REVAMPED_METRICS}" '
    BEGIN { count = split(kinds, kind, " ") }
    { text = text $0 " " }
    END {
      out = ""
      for (i = 1; i <= count; i++) {
        if (index(text, "#{battery_" kind[i] "}") > 0 || index(text, "@battery_revamped_out_" kind[i] "}") > 0 || index(text, " status " kind[i] ")") > 0) { out = out (out == "" ? "" : " ") kind[i] }
      }
      print out
    }
  '
}

battery_revamped_plan_status() {
  battery_revamped_plan_status_all=""
  for battery_revamped_plan_status_option in status-left status-right; do
    battery_revamped_plan_status_now=$(tmux show-option -gqv "${battery_revamped_plan_status_option}" 2>/dev/null) || battery_revamped_plan_status_now=""
    battery_revamped_plan_status_all="${battery_revamped_plan_status_all} ${battery_revamped_plan_status_now}"
    case "${battery_revamped_plan_status_now}" in
    *"#{battery_"*"}"*) battery_revamped_plan_status_new=$(battery_revamped_replaced "${battery_revamped_plan_status_now}") ;;
    *) continue ;;
    esac
    [ "${battery_revamped_plan_status_new}" != "${battery_revamped_plan_status_now}" ] || continue
    battery_revamped_emit set-option -gq "${battery_revamped_plan_status_option}" "${battery_revamped_plan_status_new}"
  done
  battery_revamped_plan_status_used=$(battery_revamped_used "${battery_revamped_plan_status_all}")
  [ "${battery_revamped_plan_status_used}" = "${BATTERY_REVAMPED_S_published}" ] || battery_revamped_emit set-option -gq @battery_revamped_published "${battery_revamped_plan_status_used}"
  BATTERY_REVAMPED_S_published="${battery_revamped_plan_status_used}"
}

battery_revamped_plan() {
  battery_revamped_load
  battery_revamped_version
  BATTERY_REVAMPED_NOTES=0
  ! battery_revamped_version_ge "${BATTERY_REVAMPED_TMUX}" "${BATTERY_REVAMPED_NOTES_SINCE}" || BATTERY_REVAMPED_NOTES=1
  battery_revamped_tools
  BATTERY_REVAMPED_KEYS=$(battery_revamped_held)
  BATTERY_REVAMPED_PLAN="" BATTERY_REVAMPED_SKIPPED=""
  battery_revamped_plan_keys
  battery_revamped_plan_status
}

battery_revamped_apply() {
  battery_revamped_plan
  battery_revamped_apply_status=0
  battery_revamped_deliver || battery_revamped_apply_status=1
  if [ "${BATTERY_REVAMPED_S_render}" = options ]; then
    revamped_ticker_start "${REVAMPED_LIB%/lib}/bin/battery-revamped"
  else
    tmux set-option -gqu @battery_revamped_ticker_pid 2>/dev/null || :
  fi
  return "${battery_revamped_apply_status}"
}
