#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/battery_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/battery_helpers.bash"

other_owner() {
  quiet sleep 'kept=$(grep -v "^@battery_revamped_ticker_pid	" "'"${FAKE}"'/vars" || :)
printf "%s\n@battery_revamped_ticker_pid\tsomeone-else\n" "${kept}" | grep -v "^$" >"'"${FAKE}"'/vars.next"
mv -f "'"${FAKE}"'/vars.next" "'"${FAKE}"'/vars"'
}

full_card() {
  macos
  pmset_battery 77 discharging "3:10 remaining"
  mac_details 60 92 8579 8331
  option drain_rate 12.5
  option history "70,80"
}

@test "commands - status prints one placeholder from the stored reading" {
  # Arrange
  sampled 42 1000000

  # Act
  tool status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "42%" ]]
}

@test "commands - status without a name is a usage error, and a name that is no placeholder prints nothing" {
  # Arrange
  sampled 42 1000000
  tool status
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: no placeholder given. run 'battery-revamped help' for usage." ]]

  # Act
  tool status free

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "commands - refresh reads the battery now and says where it stands" {
  # Arrange
  acpi_battery 64 Discharging

  # Act
  tool refresh

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "Refreshed. 64% charge, discharging." ]]
  holds percent 64
}

@test "commands - refresh on a machine without a battery says so and stores an empty reading" {
  # Arrange
  macos

  # Act
  tool refresh

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "Refreshed. No battery was found on this machine." ]]
  holds percent ""
}

@test "commands - refresh fails when no tmux server takes the reading" {
  # Arrange
  acpi_battery 64
  printf 'refused\n' >"${FAKE}/refused"

  # Act
  tool refresh

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: no tmux server is running, so the reading has nowhere to go" ]]
}

@test "commands - card prints one row per figure from the stored reading" {
  # Arrange
  full_card
  option percent 77
  option percent_ts 1000000
  option status discharging
  option remain 3:10
  option watts 60
  option cycles 92
  option health 97
  option drain_rate 12.5
  option history "70,80"

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == "Charge             77%" ]]
  [[ "${lines[1]}" == "State              discharging" ]]
  [[ "${lines[2]}" == "Remaining          3:10" ]]
  [[ "${lines[3]}" == "Watts              60W" ]]
  [[ "${lines[4]}" == "Drain rate         12.5%/h" ]]
  [[ "${lines[5]}" == "Cycles             92" ]]
  [[ "${lines[6]}" == "Health             97%" ]]
  [[ "${lines[7]}" == "Read. 77% charge, discharging." ]]
  [[ "${#lines[@]}" -eq 8 ]]
}

@test "commands - card reads the battery first when nothing is stored, and shows a dash for a figure the host lacks" {
  # Arrange
  macos
  pmset_battery 77 discharging "3:10 remaining"

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${lines[0]}" == "Charge             77%" ]]
  [[ "${lines[3]}" == "Watts              -" ]]
  holds percent 77
}

@test "commands - card on a machine without a battery says so in one sentence" {
  # Arrange
  macos

  # Act
  tool card

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "No battery was found on this machine." ]]
}

@test "commands - where gum draws the card is a table and a closing sentence, and the absence is a sentence" {
  # Arrange
  full_card
  export REVAMPED_TEST_GUM=1
  tool card
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Figure"*"Value"* ]]
  [[ "${output}" == *"Remaining"*"3:10"* ]]
  [[ "${output}" == *"Read. 77% charge, discharging."* ]]
  unstub pmset
  quiet pmset 'exit 1'
  option percent_ts ""
  option percent ""
  option percent_ts 1000000

  # Act
  tool card

  # Assert
  [[ "${output}" == *"No battery was found on this machine."* ]]
}

@test "commands - popup-card prints the card, then waits for a key and leaves when one comes" {
  # Arrange
  full_card
  option percent 77
  option percent_ts 1000000
  local shell_words
  read -r -a shell_words <<<"${REVAMPED_TEST_SHELL:-sh}"

  # Act
  run python3 "${REVAMPED_TESTS_DIR}/on_tty.py" "${shell_words[@]}" "${REVAMPED_TESTS_DIR}/../bin/battery-revamped" popup-card <<<"q"

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Charge"*"77%"* ]]
  [[ "${output}" == *"Press any key to close."* ]]
}

@test "commands - popup-card without a terminal prints the card and does not wait" {
  # Arrange
  full_card
  option percent 77
  option percent_ts 1000000

  # Act
  tool popup-card </dev/null

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Press any key to close." ]]
}

@test "commands - apply binds the popup key and prints nothing" {
  # Arrange
  local bound='^bind-key -N Battery details M-b run-shell'

  # Act
  tool apply

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run sent "${bound}"
  [[ "${output}" == "1" ]]
}

@test "commands - popup opens the card in a tmux popup and prints nothing" {
  # Arrange
  local opened='^display-popup -E -w 44 -h 16 .*bin/battery-revamped. popup-card$'

  # Act
  tool popup

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  run sent "${opened}"
  [[ "${output}" == "1" ]]
}

@test "commands - list prints what apply would send, and --json the same plan as one object" {
  # Arrange
  local path
  path=$(bin_path)
  option popup_key 'C-"'
  tool list
  [[ "${output}" == "bind-key -N Battery details C-\" run-shell ${path} popup" ]]

  # Act
  tool list --json

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == '{"bindings":[["bind-key","-N","Battery details","C-\"","run-shell","'*' popup"]]}' ]]
  run sends
  [[ -z "${output}" ]]
}

@test "commands - --json with any command but list is a usage error" {
  # Arrange
  sampled

  # Act
  tool --json card

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: option '--json' works only with list. run 'battery-revamped help' for usage." ]]
}

@test "commands - the command line wins over the environment, and the environment over the tmux option" {
  # Arrange
  sampled 42 1000000
  option percentage_format 'option %s'
  tool status percentage
  [[ "${output}" == "option 42" ]]
  export BATTERY_REVAMPED_PERCENTAGE_FORMAT='environment %s'
  tool status percentage
  [[ "${output}" == "environment 42" ]]

  # Act
  tool --percentage-format 'line %s' status percentage

  # Assert
  [[ "${output}" == "line 42" ]]
}

@test "commands - an option takes its value after a space or an equals sign, and an empty value given by the person is used as given" {
  # Arrange
  sampled 42 1000000
  option icons nerd
  option percentage_label "tmux"
  tool --percentage-label=C: status percentage
  [[ "${output}" == "C: 42%" ]]
  tool status percentage
  [[ "${output}" == "tmux 42%" ]]

  # Act
  tool --percentage-label '' --icons ascii status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "42%" ]]
}

@test "commands - an empty tmux option means its default, and an empty one in the environment is kept" {
  # Arrange
  sampled 42 1000000
  option icons nerd
  option percentage_label ""
  tool status percentage
  [[ "${output}" == $'\xf3\xb0\x81\xb9 42%' ]]

  # Act
  export BATTERY_REVAMPED_PERCENTAGE_LABEL=''
  tool status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == $'\xf3\xb0\x81\xb9 42%' ]]
}

@test "commands - an unknown option, one without its value and a word after a double dash are usage errors" {
  # Arrange
  tool --colour red status graph
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: unknown option '--colour'. run 'battery-revamped help' for usage." ]]
  tool --colour=red status graph
  [[ "${output}" == "battery-revamped: unknown option '--colour'. run 'battery-revamped help' for usage." ]]
  tool -x
  [[ "${output}" == "battery-revamped: unknown option '-x'. run 'battery-revamped help' for usage." ]]
  tool status --interval
  [[ "${output}" == "battery-revamped: option '--interval' needs a value. run 'battery-revamped help' for usage." ]]

  # Act
  tool -- --interval

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: unknown command '--interval'. run 'battery-revamped help' for usage." ]]
}

@test "commands - a bad number is reported alone, since the reader of the environment reads it to the end" {
  # Arrange
  mkdir -p "${BATS_TEST_TMPDIR}/stubs"
  cat >"${BATS_TEST_TMPDIR}/stubs/env" <<'STUB'
#!/bin/sh
{ set +x; } 2>/dev/null
trap '' PIPE
printf 'BATTERY_REVAMPED_DETAIL_INTERVAL=soon\n'
count=0
while [ "${count}" -lt 4000 ]; do
  printf 'FILLER_%s=%0100d\n' "${count}" 0 || exit 1
  count=$((count + 1))
done
STUB
  chmod +x "${BATS_TEST_TMPDIR}/stubs/env"

  # Act
  tool status graph

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: --detail-interval must be a whole number, got: soon" ]]
}

@test "commands - a number is checked before anything runs, whichever setting carries it" {
  # Arrange
  tool --detail-interval often status graph
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: --detail-interval must be a whole number, got: often" ]]
  tool --graph-width long status graph
  [[ "${output}" == "battery-revamped: --graph-width must be a whole number, got: long" ]]
  tool --history-size many status graph
  [[ "${output}" == "battery-revamped: --history-size must be a whole number, got: many" ]]
  tool --critical-threshold low status graph
  [[ "${output}" == "battery-revamped: --critical-threshold must be a whole number, got: low" ]]
  tool --power-source-width wide status graph
  [[ "${output}" == "battery-revamped: --power-source-width must be a whole number, got: wide" ]]

  # Act
  tool --low-threshold most status graph

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: --low-threshold must be a whole number, got: most" ]]
}

@test "commands - the interval is a whole number or minute" {
  # Arrange
  sampled 42 1000000
  tool --interval soon status graph
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: --interval must be a whole number or minute, got: soon" ]]
  tool --interval 30 status percentage
  [[ "${output}" == "42%" ]]

  # Act
  tool --interval minute status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "42%" ]]
}

@test "commands - a width given as nothing is no width, and the fixed and the popup widths are not numbers" {
  # Arrange
  sampled 9 1000000

  # Act
  tool --percentage-width '' --fixed-width on --popup-width 90% status percentage

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "  9%" ]]
}

@test "commands - each choice is checked before anything runs" {
  # Arrange
  tool --icons emoji status graph
  [[ "${output}" == "battery-revamped: --icons must be ascii or nerd, got: emoji" ]]
  tool --fixed-width yes status graph
  [[ "${output}" == "battery-revamped: --fixed-width must be on or off, got: yes" ]]
  tool --notify on status graph
  [[ "${output}" == "battery-revamped: --notify must be 0 or 1, got: on" ]]
  tool --hide-on-ac yes status graph
  [[ "${output}" == "battery-revamped: --hide-on-ac must be 0 or 1, got: yes" ]]

  # Act
  tool --render both status graph

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: --render must be jobs or options, got: both" ]]
}

@test "commands - on Linux doctor names the power supply and acpi, and a default key someone else holds" {
  # Arrange
  local supply='power_supply +ok +.*/BAT0, holds the charge' acpi='acpi +ok +.*/acpi, reads the charge and the remaining time' popup='popup +ok +tmux 3\.6 opens the detail popup' taken='keys +warn +already bound and left alone: M-b'
  supply BAT0 capacity 50
  acpi_battery 50
  printf 'bind-key    -T prefix M-b     display-message mine\n' >"${FAKE}/keys"

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${supply} ]]
  [[ "${output}" =~ ${acpi} ]]
  [[ "${output}" =~ ${popup} ]]
  [[ "${output}" =~ ${taken} ]]
}

@test "commands - on Linux doctor warns about each source that is missing and exits 0" {
  # Arrange
  local supply='power_supply +warn +no battery under .*/class/power_supply, so the charge falls back to acpi' acpi='acpi +warn +without a power supply or acpi the charge stays empty'

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${supply} ]]
  [[ "${output}" =~ ${acpi} ]]
}

@test "commands - on macOS doctor names pmset, the system profiler and ioreg" {
  # Arrange
  local pmset='pmset +ok +.*/pmset, reads the charge' profiler='system_profiler +ok +.*/system_profiler, reads the charger watts' ioreg='ioreg +ok +.*/ioreg, reads the cycle count and the health'
  macos
  says pmset ""
  says system_profiler ""
  says ioreg ""

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${pmset} ]]
  [[ "${output}" =~ ${profiler} ]]
  [[ "${output}" =~ ${ioreg} ]]
}

@test "commands - on macOS doctor warns about each tool that is missing" {
  # Arrange
  local pmset='pmset +warn +without it the charge stays empty' profiler='system_profiler +warn +without it the watts stay empty' ioreg='ioreg +warn +without it the cycles and the health stay empty'
  macos

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${pmset} ]]
  [[ "${output}" =~ ${profiler} ]]
  [[ "${output}" =~ ${ioreg} ]]
}

@test "commands - doctor names the notifier it would use, and warns when there is none" {
  # Arrange
  local none='notifier +warn +no osascript or notify-send' found='notifier +ok +notify-send'
  tool doctor
  [[ "${output}" =~ ${none} ]]
  quiet notify-send ':'

  # Act
  tool doctor

  # Assert
  [[ "${output}" =~ ${found} ]]
}

@test "commands - doctor warns when the tmux is too old for the popup" {
  # Arrange
  local old='popup +warn +the detail popup needs tmux 3\.2 or later'
  tmux_is 3.1

  # Act
  tool doctor

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" =~ ${old} ]]
}

@test "commands - doctor names a tmux option whose value it does not know" {
  # Arrange
  option render both
  option graph_width lots
  option notify yes

  # Act
  tool doctor

  # Assert
  run grep '^settings' <<<"${output}"
  [[ "${output}" == "settings           warn     unknown values: render=both graph_width=lots notify=yes" ]]
}

@test "commands - the daemon publishes the placeholders once and ends when another process owns the ticker" {
  # Arrange
  acpi_battery 64
  option published "percentage"
  other_owner

  # Act
  tool daemon

  # Assert
  [[ "${status}" -eq 0 ]]
  holds out_percentage "64%%"
  holds ticker_pid someone-else
}

@test "commands - a bare run without a terminal is a usage error" {
  # Arrange
  cd "${BATS_TEST_TMPDIR}"

  # Act
  tool

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "battery-revamped: no command given. run 'battery-revamped help' for usage." ]]
}

@test "commands - the menu runs each choice" {
  # Arrange
  full_card
  export REVAMPED_TEST_GUM=1
  option percent 77
  option percent_ts 1000000
  option status discharging
  answers "Show the battery now" "List the bindings" "Apply them now" "Check this machine" "Help"
  tool
  [[ "${output}" == *"Read. 77% charge, discharging."* ]]
  tool
  [[ "${output}" == *"bind-key"* ]]
  tool
  [[ "${output}" == *"Applied. 1 key is bound."* ]]
  tool
  [[ "${output}" == *"pmset"* ]]

  # Act
  tool

  # Assert
  [[ "${output}" == *"battery-revamped apply"* ]]
}

@test "commands - apply from the menu counts the keys it binds" {
  # Arrange
  export REVAMPED_TEST_GUM=1
  answers "Apply them now"

  # Act
  tool --popup-key off

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Applied. 0 keys are bound."* ]]
}
