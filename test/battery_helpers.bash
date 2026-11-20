#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/helpers.bash
source "${BATS_TEST_DIRNAME:-.}/helpers.bash"

setup() {
  harness_setup
  for name in $(compgen -v BATTERY_REVAMPED_); do
    unset "${name}"
  done
  FAKE="${BATS_TEST_TMPDIR}/fake"
  SYS="${BATS_TEST_TMPDIR}/sys"
  REVAMPED_TEST_SYS="${SYS}"
  export HOME="${BATS_TEST_TMPDIR}/home" FAKE SYS REVAMPED_TEST_SYS
  mkdir -p "${HOME}" "${FAKE}" "${SYS}" "${BATS_TEST_TMPDIR}/stubs"
  UNTRACED='{ set +x; } 2>/dev/null'
  printf '3.6\n' >"${FAKE}/version"
  : >"${FAKE}/vars"
  : >"${FAKE}/log"
  : >"${FAKE}/asked"
  now 1000000
  fake_tmux
  fake_date
  linux
  harness_hide pmset acpi system_profiler ioreg osascript notify-send
}

quiet() {
  printf '#!/bin/sh\n%s\n%s\n' "${UNTRACED}" "$2" >"${BATS_TEST_TMPDIR}/stubs/$1"
  chmod +x "${BATS_TEST_TMPDIR}/stubs/$1"
}

var() {
  local kept
  kept=$(grep -v "^$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "${kept}" "$1" "$2" | grep -v '^$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}

value() {
  awk -F '\t' -v want="$1" '$1 == want { print $2 }' "${FAKE}/vars"
}

option() {
  var "@battery_revamped_$1" "$2"
}

held() {
  value "@battery_revamped_$1"
}

now() {
  printf '%s\n' "$1" >"${FAKE}/now"
}

later() {
  local current
  current=$(cat "${FAKE}/now")
  now $((current + ${1:-100}))
}

unstub() {
  rm -f "${BATS_TEST_TMPDIR}/stubs/$1"
}

fake_date() {
  quiet date 'cat "'"${FAKE}"'/now"'
}

macos() {
  export REVAMPED_TEST_UNAME_S=Darwin
}

linux() {
  export REVAMPED_TEST_UNAME_S=Linux
}

other_system() {
  export REVAMPED_TEST_UNAME_S=Plan9
}

says() {
  printf '%s\n' "$2" >"${FAKE}/$1.out"
  quiet "$1" 'printf "%s %s\n" "'"$1"'" "$*" >>"'"${FAKE}"'/asked"; cat "'"${FAKE}/$1"'.out"'
}

pmset_says() {
  says pmset "$1"
}

pmset_battery() {
  pmset_says "Now drawing from 'Battery Power'
 -InternalBattery-0 (id=123)	${1:-83}%; ${2:-discharging}; ${3:-4:32 remaining} present: true"
}

acpi_battery() {
  says acpi "Battery 0: ${2:-Discharging}, ${1:-64}%${3-, 03:00:00 remaining}"
}

mac_details() {
  says system_profiler "Power:

      AC Charger Information:
          Connected: Yes
          Wattage (W): ${1:-60}"
  says ioreg "+-o AppleSmartBattery  <class AppleSmartBattery>
    {
      \"DesignCapacity\" = ${3:-8579}
      \"BatteryData\" = {\"MaxCapacity\"=100,\"DesignCapacity\"=1,\"CycleCount\"=7}
      \"MaxCapacity\" = 100
      \"CycleCount\" = ${2:-92}
      \"AppleRawMaxCapacity\" = ${4:-8331}
    }"
}

supply() {
  local dir="${SYS}/class/power_supply/$1" file
  mkdir -p "${dir}"
  shift
  while [[ "$#" -ge 2 ]]; do
    file="$1"
    printf '%s\n' "$2" >"${dir}/${file}"
    shift 2
  done
}

sampled() {
  option percent "${1:-42}"
  option percent_ts "${2:-1000000}"
  option status "${3:-discharging}"
}

asked() {
  cat "${FAKE}/asked"
}

fake_tmux() {
  cat >"${BATS_TEST_TMPDIR}/stubs/tmux" <<EOF
#!/bin/sh
${UNTRACED}
printf '%s\n' "\$*" >>"${FAKE}/log"
expanded() {
  printf '%s\n' "\$1" | awk -v vars="${FAKE}/vars" '
    BEGIN { while ((getline row < vars) > 0) { at = index(row, "\t"); value[substr(row, 1, at - 1)] = substr(row, at + 1) } }
    {
      line = \$0
      out = ""
      while ((at = index(line, "#{")) > 0) {
        stop = index(substr(line, at), "}")
        name = substr(line, at + 2, stop - 3)
        out = out substr(line, 1, at - 1) value[name]
        line = substr(line, at + stop)
      }
      print out line
    }
  '
}
looked() {
  awk -F '\t' -v want="\$1" '\$1 == want { print \$2 }' "${FAKE}/vars"
}
put() {
  kept=\$(grep -v "^\$1	" "${FAKE}/vars" || :)
  printf '%s\n%s\t%s\n' "\${kept}" "\$1" "\$2" | grep -v '^\$' >"${FAKE}/vars.tmp"
  mv -f "${FAKE}/vars.tmp" "${FAKE}/vars"
}
written() {
  while [ "\$#" -gt 0 ]; do
    if [ "\$1" = set-option ] && [ "\${2:-}" = -gq ] && [ "\$#" -ge 4 ]; then
      put "\$3" "\$4"
      shift 4
      continue
    fi
    shift
  done
}
case "\$1" in
-V)
  IFS= read -r version <"${FAKE}/version"
  printf 'tmux %s\n' "\${version}"
  ;;
display-message)
  [ "\$2" != -p ] || expanded "\$3"
  ;;
show-option)
  looked "\$3"
  ;;
list-keys)
  [ ! -f "${FAKE}/keys" ] || cat "${FAKE}/keys"
  ;;
list-clients)
  [ ! -f "${FAKE}/clients" ] || cat "${FAKE}/clients"
  ;;
*)
  case "\$*" in
  *" ; "*) [ ! -f "${FAKE}/refused" ] || exit 1 ;;
  *) [ ! -f "${FAKE}/refused" ] || ! grep -qF -- "\$*" "${FAKE}/refused" || exit 1 ;;
  esac
  written "\$@"
  ;;
esac
exit 0
EOF
  chmod +x "${BATS_TEST_TMPDIR}/stubs/tmux"
}

tmux_is() {
  printf '%s\n' "$1" >"${FAKE}/version"
}

planned() {
  lib_run battery "${1:-}"'battery_revamped_plan; battery_revamped_lines'
}

sends() {
  grep -v -e '^display-message -p' -e '^-V' -e '^list-' -e '^show-option' "${FAKE}/log" || :
}

sent() {
  grep -c -- "$1" "${FAKE}/log" || :
}

tool() {
  # shellcheck disable=SC2086
  run ${REVAMPED_TEST_SHELL:-sh} "${REVAMPED_TESTS_DIR}/../bin/battery-revamped" "$@"
}

tool_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR}/../bin/battery-revamped"
}

bin_path() {
  printf "'%s'" "${REVAMPED_TESTS_DIR%/test}/bin/battery-revamped"
}

has_line() {
  local line
  for line in "${lines[@]}"; do
    [[ "${line}" == "$1" ]] && return 0
  done
  return 1
}

answers() {
  export REVAMPED_TEST_GUM_ANSWERS="${BATS_TEST_TMPDIR}/answers"
  printf '%s\n' "$@" >"${REVAMPED_TEST_GUM_ANSWERS}"
}

eventually() {
  local delay
  for delay in 0.01 0.02 0.05 0.1 0.1 0.2 0.2 0.5 0.5 1 1 1 2 2; do
    "$@" && return 0
    /bin/sleep "${delay}"
  done
  "$@"
}

holds() {
  local now
  now=$(held "$1")
  [[ "${now}" == "$2" ]]
}

reading() {
  lib_run battery 'BATTERY_REVAMPED_SYS="'"${SYS}"'"; battery_revamped_load; '"${1:-}"'battery_revamped_refresh; printf "stored=%s\n" "${BATTERY_REVAMPED_STORED}"'
}

shown() {
  lib_run battery 'battery_revamped_load; for name in '"$*"'; do battery_revamped_output "${name}"; printf "[%s]" "${BATTERY_REVAMPED_OUT}"; done'
}

evaluated() {
  lib_run battery 'battery_revamped_load; '"$1"
}
