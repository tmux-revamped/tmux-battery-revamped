#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/battery_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/battery_helpers.bash"

@test "battery - percentage prints the stored charge through its format, and nothing without a reading" {
  # Arrange
  shown percentage
  [[ "${output}" == "[]" ]]
  sampled 83
  option percentage_format "%s percent"
  var @battery_revamped_x ignored

  # Act
  shown percentage

  # Assert
  [[ "${output}" == "[83 percent]" ]]
}

@test "battery - the icon follows the eight charge tiers" {
  # Arrange
  local script='for pct in 0 13 26 38 51 63 76 88 100; do BATTERY_REVAMPED_S_percent=${pct}; battery_revamped_output icon; printf "%s" "${BATTERY_REVAMPED_OUT}"; done; BATTERY_REVAMPED_S_percent=""; battery_revamped_output icon_charge; printf "[%s]" "${BATTERY_REVAMPED_OUT}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "▁▂▃▄▅▆▇██[]" ]]
}

@test "battery - a junk charge is tier one, and a tier icon the person sets wins, a tier left empty keeps the default" {
  # Arrange
  option charge_tier2_icon "two"
  option charge_tier8_icon ""
  local script='BATTERY_REVAMPED_S_percent=abc; battery_revamped_output icon; printf "[%s]" "${BATTERY_REVAMPED_OUT}"; BATTERY_REVAMPED_S_percent=20; battery_revamped_output icon; printf "[%s]" "${BATTERY_REVAMPED_OUT}"; BATTERY_REVAMPED_S_percent=100; battery_revamped_output icon; printf "[%s]" "${BATTERY_REVAMPED_OUT}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[▁][two][█]" ]]
}

@test "battery - the nerd set draws a glyph per tier, and another one while charging" {
  # Arrange
  option icons nerd
  local script='for state in discharging charging; do BATTERY_REVAMPED_S_status=${state}; for pct in 5 20 30 45 55 65 80 95; do BATTERY_REVAMPED_S_percent=${pct}; battery_revamped_output icon; printf "%s" "${BATTERY_REVAMPED_OUT}"; done; printf "|"; done'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == $'\xf3\xb0\x81\xba\xf3\xb0\x81\xbb\xf3\xb0\x81\xbc\xf3\xb0\x81\xbd\xf3\xb0\x81\xbf\xf3\xb0\x82\x80\xf3\xb0\x82\x81\xf3\xb0\x81\xb9|\xf3\xb0\xa2\x9c\xf3\xb0\x82\x86\xf3\xb0\x82\x87\xf3\xb0\x82\x88\xf3\xb0\x82\x89\xf3\xb0\xa2\x9e\xf3\xb0\x82\x8a\xf3\xb0\x82\x85|' ]]
}

@test "battery - every tier has its own icon and its own colours" {
  # Arrange
  local script='for n in 1 2 3 4 5 6 7 8; do eval "BATTERY_REVAMPED_S_charge_tier${n}_icon=i${n} BATTERY_REVAMPED_S_charge_tier${n}_fg_color=f${n} BATTERY_REVAMPED_S_charge_tier${n}_bg_color=b${n}"; done; for pct in 10 20 30 40 55 65 80 90; do BATTERY_REVAMPED_S_percent=${pct}; for name in icon color_charge_fg color_charge_bg; do battery_revamped_output "${name}"; printf "%s," "${BATTERY_REVAMPED_OUT}"; done; done; BATTERY_REVAMPED_S_percent=""; battery_revamped_output color_charge_fg; printf "[%s]" "${BATTERY_REVAMPED_OUT}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "i1,f1,b1,i2,f2,b2,i3,f3,b3,i4,f4,b4,i5,f5,b5,i6,f6,b6,i7,f7,b7,i8,f8,b8,[]" ]]
}

@test "battery - the status icon and colours follow the state, with a default icon per state" {
  # Arrange
  option status_charging_icon "C"
  option status_attached_fg_color "A"
  local script='for state in charged charging discharging attached unknown weird; do BATTERY_REVAMPED_S_status=${state}; for name in icon_status color_fg color_bg color_status_fg color_status_bg; do battery_revamped_output "${name}"; printf "%s," "${BATTERY_REVAMPED_OUT}"; done; printf "|"; done'
  option status_charged_fg_color cf
  option status_charged_bg_color cb
  option status_charging_fg_color gf
  option status_charging_bg_color gb
  option status_discharging_fg_color df
  option status_discharging_bg_color db
  option status_attached_bg_color ab
  option status_unknown_fg_color uf
  option status_unknown_bg_color ub

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "=,cf,cb,cf,cb,|C,gf,gb,gf,gb,|-,df,db,df,db,|!,A,ab,A,ab,|?,uf,ub,uf,ub,|?,uf,ub,uf,ub,|" ]]
}

@test "battery - the graph fills a bar of the width the option gives" {
  # Arrange
  sampled 50
  option graph_width 6
  option graph_full "#"
  option graph_empty "-"
  shown graph
  [[ "${output}" == "[###---]" ]]
  option graph_width junk
  option graph_full ""
  option graph_empty ""

  # Act
  shown graph

  # Assert
  [[ "${output}" == "[█████░░░░░]" ]]
}

@test "battery - the graph is empty with no charge, with a zero width, and full at 100" {
  # Arrange
  sampled 100
  shown graph
  [[ "${output}" == "[██████████]" ]]
  option graph_width 0
  shown graph
  [[ "${output}" == "[]" ]]
  option percent ""

  # Act
  shown graph

  # Assert
  [[ "${output}" == "[]" ]]
}

@test "battery - the remaining time, the watts, the cycles, the health and the drain rate take their formats" {
  # Arrange
  sampled 50
  option remain 2:30
  option watts 45
  option cycles 88
  option health 96
  option drain_rate 12.5

  # Act
  shown remain charging_watts cycles health drain_rate

  # Assert
  [[ "${output}" == "[2:30][45W][88][96%][12.5%/h]" ]]
}

@test "battery - a format the person sets is used, and a value the host lacks prints nothing" {
  # Arrange
  sampled 50
  option remain_format "%s left"
  option remain 1:05
  option watts_format "%s watts"
  option cycles_format "n%s"
  option health_format "%s of new"
  option drain_rate_format "%s per hour"
  option watts 9
  option cycles 3
  option health 80
  option drain_rate 1.0

  # Act
  shown remain charging_watts cycles health drain_rate estimate

  # Assert
  [[ "${output}" == "[1:05 left][9 watts][n3][80 of new][1.0 per hour][50:00 left]" ]]
}

@test "battery - the estimate divides the charge left by the drain rate, and the time to full by the charge rate" {
  # Arrange
  sampled 50 1000000 discharging
  option drain_rate 25.0
  shown estimate
  [[ "${output}" == "[2:00]" ]]
  option status charging
  option drain_rate -20.0
  shown estimate
  [[ "${output}" == "[2:30]" ]]
  option percent 99
  option drain_rate -2.1

  # Act
  shown estimate

  # Assert
  [[ "${output}" == "[0:29]" ]]
}

@test "battery - the estimate rounds sixty minutes up to the next hour, and is empty when it cannot be known" {
  # Arrange
  sampled 50 1000000 discharging
  option drain_rate 33.0
  shown estimate
  [[ "${output}" == "[1:31]" ]]
  option percent 100
  option drain_rate 100.5
  shown estimate
  [[ "${output}" == "[1:00]" ]]
  option drain_rate -5.0
  shown estimate
  [[ "${output}" == "[]" ]]
  option status charged
  option drain_rate 5.0
  shown estimate
  [[ "${output}" == "[]" ]]
  option drain_rate junk
  shown estimate
  [[ "${output}" == "[]" ]]
  option drain_rate ""
  shown estimate
  [[ "${output}" == "[]" ]]
  option percent abc
  option drain_rate 5.0

  # Act
  shown estimate

  # Assert
  [[ "${output}" == "[]" ]]
}

@test "battery - the sparkline draws one block per reading and skips a junk one" {
  # Arrange
  sampled 50
  option history "0,50,100,junk,14"
  shown sparkline
  [[ "${output}" == $'[\xe2\x96\x81\xe2\x96\x84\xe2\x96\x88\xe2\x96\x81]' ]]
  option history "junk"

  # Act
  shown sparkline

  # Assert
  [[ "${output}" == "[]" ]]
}

@test "battery - the power source is the battery label while discharging and the AC label otherwise" {
  # Arrange
  sampled 50 1000000 discharging
  shown power_source
  [[ "${output}" == "[Bat]" ]]
  option status charging
  option source_ac_label "Wall"
  shown power_source
  [[ "${output}" == "[Wall]" ]]
  option status discharging
  option source_battery_label "Cell"

  # Act
  shown power_source

  # Assert
  [[ "${output}" == "[Cell]" ]]
}

@test "battery - the alert icon shows while discharging at a low or critical charge" {
  # Arrange
  option low_icon "L"
  option critical_icon "C"
  local script='for pair in "50 discharging" "20 discharging" "10 discharging" "10 charging" "100 charged" "5 attached" "abc discharging"; do set -- ${pair}; BATTERY_REVAMPED_S_percent=$1 BATTERY_REVAMPED_S_status=$2; battery_revamped_output alert_icon; printf "[%s]" "${BATTERY_REVAMPED_OUT}"; done'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[][L][C][][][][]" ]]
}

@test "battery - the levels follow the thresholds, which fall back to 20 and 10 when they are junk" {
  # Arrange
  local script='for pair in "20 discharging" "21 discharging" "10 discharging" "11 discharging" "99 charging" "100 charging" "40 charged" "40 attached" "40 unknown" "x discharging" "" ; do set -- ${pair}; battery_revamped_level "$1" "$2"; printf "%s " "${BATTERY_REVAMPED_LEVEL}"; done; BATTERY_REVAMPED_S_low_threshold=junk BATTERY_REVAMPED_S_critical_threshold=junk; battery_revamped_level 15 discharging; printf "%s " "${BATTERY_REVAMPED_LEVEL}"; BATTERY_REVAMPED_S_low_threshold=50 BATTERY_REVAMPED_S_critical_threshold=30; battery_revamped_level 40 discharging; printf "%s" "${BATTERY_REVAMPED_LEVEL}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "low ok critical low ok full full ok ok unknown unknown low low" ]]
}

@test "battery - before and after wrap the charge when it prints, with the icon and the tier colour filled in" {
  # Arrange
  sampled 90
  option before "#[fg={color}]{icon} "
  option after " {icon}#[default]"
  option charge_tier8_fg_color "#[fg=#a6e3a1]"
  shown percentage

  [[ "${output}" == "[#[fg=#a6e3a1]█ 90% █#[default]]" ]]
  option charge_tier8_fg_color "plain"

  # Act
  shown percentage

  # Assert
  [[ "${output}" == "[#[fg=plain]█ 90% █#[default]]" ]]
}

@test "battery - before and after print nothing around an empty charge, and not around another metric" {
  # Arrange
  option before "<"
  option after ">"
  option remain 1:00

  # Act
  shown percentage remain

  # Assert
  [[ "${output}" == "[][1:00]" ]]
}

@test "battery - a label goes before the value, and nerd gives each labelled metric its glyph unless a label is set" {
  # Arrange
  sampled 50 1000000 discharging
  option percentage_label "Charge"
  option icons nerd
  option remain 1:00
  option watts 7
  option cycles 9
  option health 90
  option drain_rate 1.5
  option history "10"

  local expected
  expected=$'[Charge 50%][\xf3\xb0\x9e\xb1 █████░░░░░][\xf3\xb0\x94\x9f 1:00][\xf3\xb0\x89\x81 7W][\xf3\xb0\x93\xa6 9][\xf3\xb0\x97\xb6 90%][\xf3\xb0\x94\xb3 1.5%/h][\xf3\xb0\x94\x9f 33:20][\xf3\xb0\x9e\xb1 ▁][\xf3\xb0\x9a\xa5 Bat][\xf3\xb0\x81\xbd]'

  # Act
  shown percentage graph remain charging_watts cycles health drain_rate estimate sparkline power_source icon

  # Assert
  [[ "${output}" == "${expected}" ]]
}

@test "battery - an icon, a label or a text set to off prints nothing, and nerd gives no glyph for a label set to off" {
  # Arrange
  sampled 15 1000000 discharging
  option icons nerd
  option percentage_label off
  option graph_label off
  option graph_full off
  option charge_tier2_icon off
  option status_discharging_icon off
  option low_icon off
  option source_battery_label off
  option before off
  option after off

  # Act
  shown percentage graph icon icon_status alert_icon power_source

  # Assert
  [[ "${output}" == "[15%][  ░░░░░░░░][][][][]" ]]
}

@test "battery - every labelled metric takes the label the person sets, and an ascii set has none by default" {
  # Arrange
  sampled 50
  option graph_label g
  option remain_label r
  option charging_watts_label w
  option cycles_label c
  option health_label h
  option drain_rate_label d
  option estimate_label e
  option sparkline_label s
  option power_source_label p
  option remain 1:00
  option watts 7
  option cycles 9
  option health 90
  option drain_rate 1.5
  option history 10

  # Act
  shown graph remain charging_watts cycles health drain_rate estimate sparkline power_source

  # Assert
  [[ "${output}" == "[g █████░░░░░][r 1:00][w 7W][c 9][h 90%][d 1.5%/h][e 33:20][s ▁][p Bat]" ]]
}

@test "battery - a value is padded to its own width, or to its natural width when the width is fixed, and a longer one is never cut" {
  # Arrange
  sampled 5
  shown percentage
  [[ "${output}" == "[5%]" ]]
  option fixed_width on
  shown percentage remain
  [[ "${output}" == "[  5%][]" ]]
  option percentage_width 6
  shown percentage
  [[ "${output}" == "[    5%]" ]]
  option percentage_width 1
  option percent 100

  # Act
  shown percentage

  # Assert
  [[ "${output}" == "[100%]" ]]
}

@test "battery - the graph pads to its width in characters, and a junk width is no width" {
  # Arrange
  sampled 50
  option graph_width 3
  option graph_full "é"
  option graph_empty "ü"
  shown graph
  [[ "${output}" == "[ééü]" ]]
  option power_source_width 6

  # Act
  shown power_source

  # Assert
  [[ "${output}" == "[   Bat]" ]]
}

@test "battery - hide on AC prints every placeholder empty unless the battery is discharging" {
  # Arrange
  sampled 50 1000000 charging
  option hide_on_ac 1
  option remain 1:00
  shown percentage remain icon_status
  [[ "${output}" == "[][][]" ]]
  option status discharging

  # Act
  shown percentage remain icon_status

  # Assert
  [[ "${output}" == "[50%][1:00][-]" ]]
}

@test "battery - a reading takes the drain rate from the one at least five minutes older, and keeps the old rate before that" {
  # Arrange
  macos
  pmset_battery 80
  reading
  holds snap_pct 80
  holds drain_rate ""
  later 100
  pmset_battery 70
  reading
  holds snap_pct 80
  holds drain_rate ""
  later 500
  pmset_battery 70

  # Act
  reading

  # Assert
  holds drain_rate 60.0
  holds snap_pct 70
  later 400
  pmset_battery 71
  reading
  holds drain_rate -9.0
}

@test "battery - a clock that moved back or readings with no number keep the old rate and take a new snapshot" {
  # Arrange
  macos
  pmset_battery 60
  option snap_pct 80
  option snap_ts 2000000
  option drain_rate 5.0

  # Act
  reading

  # Assert
  holds drain_rate 5.0
  holds snap_pct 60
  holds snap_ts 1000000
}

@test "battery - the rate helper needs four numbers and a later time, so two readings in one second keep the old rate" {
  # Arrange
  local script='for args in "80 100 70 700" "80 100 70 100" "80 100 70 50" "80 100 x 700" "" "80 x 70 700" "x 100 70 700" "80 100 70 x"; do set -- ${args}; printf "[%s]" "$(battery_revamped_rate "$@")"; done'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[60.0][][][][][][][]" ]]
}

@test "battery - the history keeps the newest readings the size allows, and ignores a junk size or reading" {
  # Arrange
  macos
  option history_size 3
  pmset_battery 50
  reading
  pmset_battery 51
  reading
  pmset_battery 52
  reading
  pmset_battery 53

  # Act
  reading

  # Assert
  holds history "51,52,53"
  option history_size junk
  pmset_battery 54
  reading
  holds history "51,52,53,54"
  option history_size 0
  quiet pmset 'exit 1'
  reading
  holds history "51,52,53,54"
}

@test "battery - a reading with a notification setting on sends one message per crossing" {
  # Arrange
  macos
  option notify 1
  quiet notify-send 'printf "%s|%s\n" "$2" "$3" >>"'"${FAKE}"'/notices"'
  pmset_battery 15 discharging
  reading
  pmset_battery 14 discharging
  reading
  pmset_battery 9 discharging
  reading
  pmset_battery 100 charged "0:00 remaining"
  reading
  pmset_battery 100 charged "0:00 remaining"
  reading
  pmset_battery 50 charging
  reading

  # Act
  run cat "${FAKE}/notices"

  # Assert
  [[ "${output}" == $'Battery low|Low battery: 15%\nBattery critical|Critically low: 9%\nBattery full|Fully charged: 100%' ]]
}

@test "battery - notifications stay off by default, and an ok level sends nothing" {
  # Arrange
  macos
  quiet notify-send 'printf "sent\n" >>"'"${FAKE}"'/notices"'
  pmset_battery 5 discharging
  reading
  option notify 1
  option alert_level critical
  pmset_battery 60 discharging
  reading

  # Act
  run cat "${FAKE}/notices"

  # Assert
  [[ "${status}" -ne 0 ]]
  holds alert_level ok
}

@test "battery - the notification goes through the notifier of the system, with the text as arguments" {
  # Arrange
  macos
  option notify 1
  quiet osascript 'printf "%s\n" "$@" >>"'"${FAKE}"'/notices"'
  pmset_battery 5 discharging

  # Act
  reading

  # Assert
  run cat "${FAKE}/notices"
  [[ "${output}" == *"Battery critical"* ]]
  [[ "${output}" == *"Critically low: 5%"* ]]
}

@test "battery - the status of a stale reading starts one background reading, and a fresh or locked one starts none" {
  # Arrange
  macos
  pmset_battery 61
  sampled 42 999900
  option percent_ts 999900
  lib_run battery 'REVAMPED_CACHE_SYNC=1; battery_revamped_status percentage'
  [[ "${output}" == "61%" ]] || [[ "${output}" == "42%" ]]
  holds percent 61
  option percent 10
  option percent_ts 1000000

  # Act
  lib_run battery 'REVAMPED_CACHE_SYNC=1; battery_revamped_status percentage'

  # Assert
  [[ "${output}" == "10%" ]]
  holds percent 10
  option percent_ts 1
  option percent_lock 1
  option percent_lock_ts 999999
  lib_run battery 'REVAMPED_CACHE_SYNC=1; battery_revamped_status percentage'
  holds percent 10
}

@test "battery - a lock with no time of its own does not hold a refresh back" {
  # Arrange
  macos
  pmset_battery 61
  sampled 42 1
  option percent_lock 1

  # Act
  lib_run battery 'REVAMPED_CACHE_SYNC=1; battery_revamped_status percentage'

  # Assert
  holds percent 61
}

@test "battery - a junk interval means 15 seconds, and a number the person sets is used" {
  # Arrange
  sampled 42 999990
  option interval junk

  # Act
  lib_run battery 'battery_revamped_load; battery_revamped_now; battery_revamped_limit; printf "%s," "${BATTERY_REVAMPED_LIMIT}"; BATTERY_REVAMPED_S_interval=3; battery_revamped_limit; printf "%s" "${BATTERY_REVAMPED_LIMIT}"'

  # Assert
  [[ "${output}" == "15,3" ]]
}

@test "battery - an interval of minute keeps a reading fresh for sixty seconds" {
  # Arrange
  sampled 42 999990
  option interval minute

  # Act
  lib_run battery 'battery_revamped_load; battery_revamped_now; battery_revamped_limit; printf "%s" "${BATTERY_REVAMPED_LIMIT}"'

  # Assert
  [[ "${output}" == "60" ]]
}

@test "battery - a tmux version is read out of its banner and compared part by part" {
  # Arrange
  local script='for banner in "tmux 3.6a" "tmux next-3.7" "nonsense"; do printf "[%s]" "$(battery_revamped_parse_version "${banner}")"; done; for pair in "3.6 3.2" "3.2 3.2" "3.1 3.2" "4.0 3.2" "2.9 3.2" " 3.2" "x 3.2"; do if battery_revamped_version_ge ${pair}; then printf y; else printf n; fi; done'

  # Act
  lib_run battery "${script}"

  # Assert
  [[ "${output}" == "[3.6][3.7][]yynynnn" ]]
}

@test "battery - the health and the clock helpers refuse junk and zero" {
  # Arrange
  local script='for pair in "4800 5000" "6000 5000" "1 0" "x 5" "5 x" " 5" "5 "; do set -- ${pair}; printf "[%s]" "$(battery_revamped_percent_of "$@")"; done; printf "[%s]" "$(battery_revamped_clock 3 2)" "$(battery_revamped_clock 59.5 60)"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[96][100][][][][][][1:30][1:00]" ]]
}

@test "battery - the ring helper keeps a window of the newest readings" {
  # Arrange
  local script='battery_revamped_ring "" 5 3; printf "[%s]" "${BATTERY_REVAMPED_RING}"; battery_revamped_ring "1,2,3" 4 3; printf "[%s]" "${BATTERY_REVAMPED_RING}"; battery_revamped_ring "1,2" 3 5; printf "[%s]" "${BATTERY_REVAMPED_RING}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[5][2,3,4][1,2,3]" ]]
}

@test "battery - a number in the stored state falls back to the default when it is junk" {
  # Arrange
  local script='battery_revamped_number 5 9; printf "[%s]" "${BATTERY_REVAMPED_NUMBER}"; battery_revamped_number x 9; printf "[%s]" "${BATTERY_REVAMPED_NUMBER}"; battery_revamped_doubled "a#b#c"; printf "[%s]" "${BATTERY_REVAMPED_DOUBLED}"'

  # Act
  evaluated "${script}"

  # Assert
  [[ "${output}" == "[5][9][a##b##c]" ]]
}

@test "battery - a number in a locale with a decimal comma is still printed with a point" {
  # Arrange
  macos
  option snap_pct 80
  option snap_ts 1000000
  later 600
  pmset_battery 75

  # Act
  run env LC_ALL=pt_BR.UTF-8 REVAMPED_TEST_UNAME_S=Darwin PATH="${PATH}" sh "${REVAMPED_TESTS_DIR}/../bin/battery-revamped" refresh

  # Assert
  [[ "${status}" -eq 0 ]]
  holds drain_rate 30.0
}
