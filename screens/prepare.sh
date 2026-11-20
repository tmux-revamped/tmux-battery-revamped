#!/bin/sh
set -eu

: "${SCREENS_REPO:?}"
demo=/Users/Shared/demo
rm -rf "${demo}"
mkdir -p "${demo}/home" "${demo}/bin" "${demo}/tmux-battery-revamped"
cp -Rpf "${SCREENS_REPO}/bin" "${SCREENS_REPO}/lib" "${SCREENS_REPO}/battery-revamped.tmux" "${demo}/tmux-battery-revamped/"
for tool in tmux gum; do
  tool_path=$(command -v "${tool}")
  ln -s "${tool_path}" "${demo}/bin/${tool}"
done

cat >"${demo}/bin/pmset" <<'PMSET'
#!/bin/sh
IFS='|' read -r percent state remain </Users/Shared/demo/battery 2>/dev/null || :
printf "Now drawing from 'Battery Power'\n"
printf ' -InternalBattery-0 (id=4653155)\t%s%%; %s; %s remaining present: true\n' "${percent:-76}" "${state:-discharging}" "${remain:-3:10}"
PMSET

cat >"${demo}/bin/system_profiler" <<'PROFILER'
#!/bin/sh
printf 'Power:\n\n      AC Charger Information:\n          Connected: Yes\n          Wattage (W): 61\n'
PROFILER

cat >"${demo}/bin/ioreg" <<'IOREG'
#!/bin/sh
printf '+-o AppleSmartBattery  <class AppleSmartBattery, id 0x1000>\n    {\n'
printf '      "DesignCapacity" = 8579\n      "CycleCount" = 214\n      "MaxCapacity" = 100\n      "AppleRawMaxCapacity" = 8140\n    }\n'
IOREG

cat >"${demo}/bin/osascript" <<'NOTIFIER'
#!/bin/sh
shift 6
printf '%s: %s\n' "$1" "$2" >>/Users/Shared/demo/notices
NOTIFIER

cat >"${demo}/bin/state" <<'STATE'
#!/bin/sh
printf '%s|%s|%s\n' "$1" "$2" "${3:-0:00}" >/Users/Shared/demo/battery
STATE

chmod +x "${demo}/bin/pmset" "${demo}/bin/system_profiler" "${demo}/bin/ioreg" "${demo}/bin/osascript" "${demo}/bin/state"
