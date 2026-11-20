#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/battery_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/battery_helpers.bash"

logged() {
  grep -qxF -- "$1" "${FAKE}/log"
}

other_owner() {
  quiet sleep 'kept=$(grep -v "^@battery_revamped_ticker_pid	" "'"${FAKE}"'/vars" || :)
printf "%s\n@battery_revamped_ticker_pid\tsomeone-else\n" "${kept}" | grep -v "^$" >"'"${FAKE}"'/vars.next"
mv -f "'"${FAKE}"'/vars.next" "'"${FAKE}"'/vars"'
}

settled() {
  local tries=0
  until "$@"; do
    tries=$((tries + 1))
    [[ "${tries}" -lt 200 ]] || return 1
    /bin/sleep 0.05
  done
}

@test "plan - a fresh install binds the detail popup to M-b" {
  # Arrange
  local tool
  tool=$(tool_path)

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Battery details M-b run-shell ${tool} popup" ]]
}

@test "plan - a key set to off binds nothing, and a key the person names is bound whoever holds it" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  planned
  [[ -z "${output}" ]]
  printf 'bind-key    -T prefix F8     display-message mine\n' >"${FAKE}/keys"
  option popup_key F8

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Battery details F8 run-shell ${tool} popup" ]]
}

@test "plan - a tmux older than 3.1 gets its key without a note" {
  # Arrange
  tmux_is 3.0

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key M-b run-shell "*" popup" ]]
}

@test "plan - the default key is left alone when something else holds it, and bound again when the binding is the plugin's own" {
  # Arrange
  printf 'bind-key    -T prefix M-b     display-message mine\n' >"${FAKE}/keys"
  planned 'battery_revamped_plan; printf "[%s]\n" "${BATTERY_REVAMPED_SKIPPED}"; '
  [[ "${output}" == "[M-b]" ]]
  printf 'bind-key -r -T prefix M-b     run-shell "/old/bin/battery-revamped popup"\n' >"${FAKE}/keys"

  # Act
  planned

  # Assert
  [[ "${output}" == "bind-key -N Battery details M-b run-shell "*" popup" ]]
}

@test "plan - each placeholder becomes a job that prints it, and the metrics in use are recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{battery_color_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_alert_icon}'
  var status-left '#{battery_graph} #S'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-left #(${tool} status graph) #S" ]]
  [[ "${lines[1]}" == "set-option -gq status-right #(${tool} status color_fg)#(${tool} status icon) #(${tool} status percentage)#[default] #(${tool} status remain) #(${tool} status alert_icon)" ]]
  [[ "${lines[2]}" == "set-option -gq @battery_revamped_published percentage icon color_fg graph remain alert_icon" ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "plan - every placeholder has its job" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{battery_percentage}#{battery_icon}#{battery_icon_charge}#{battery_icon_status}#{battery_color_fg}#{battery_color_bg}#{battery_color_charge_fg}#{battery_color_charge_bg}#{battery_color_status_fg}#{battery_color_status_bg}#{battery_graph}#{battery_remain}#{battery_charging_watts}#{battery_cycles}#{battery_health}#{battery_drain_rate}#{battery_estimate}#{battery_sparkline}#{battery_power_source}#{battery_alert_icon}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status percentage)#(${tool} status icon)#(${tool} status icon_charge)#(${tool} status icon_status)#(${tool} status color_fg)#(${tool} status color_bg)#(${tool} status color_charge_fg)#(${tool} status color_charge_bg)#(${tool} status color_status_fg)#(${tool} status color_status_bg)#(${tool} status graph)#(${tool} status remain)#(${tool} status charging_watts)#(${tool} status cycles)#(${tool} status health)#(${tool} status drain_rate)#(${tool} status estimate)#(${tool} status sparkline)#(${tool} status power_source)#(${tool} status alert_icon)" ]]
  [[ "${lines[1]}" == "set-option -gq @battery_revamped_published percentage icon icon_charge icon_status color_fg color_bg color_charge_fg color_charge_bg color_status_fg color_status_bg graph remain charging_watts cycles health drain_rate estimate sparkline power_source alert_icon" ]]
}

@test "plan - a status line that ends in a semicolon keeps it, escaped, so tmux does not read it as a separator" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  var status-right '#{battery_percentage};'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status percentage)\\;" ]]
}

@test "plan - in options mode each placeholder becomes a read of the option the daemon fills" {
  # Arrange
  option popup_key off
  option render options
  var status-right '#{battery_color_fg}#{battery_percentage} | #{battery_remain}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #{E:@battery_revamped_out_color_fg}#{E:@battery_revamped_out_percentage} | #{E:@battery_revamped_out_remain}" ]]
  [[ "${lines[1]}" == "set-option -gq @battery_revamped_published percentage color_fg remain" ]]
}

@test "plan - a render mode the plugin does not know means jobs" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  option render both
  var status-right '#{battery_percentage}'

  # Act
  planned

  # Assert
  [[ "${lines[0]}" == "set-option -gq status-right #(${tool} status percentage)" ]]
}

@test "plan - a status line already rewritten is left as it is, and its metrics stay recorded" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key off
  option render options
  option published "percentage remain"
  var status-right '#{E:@battery_revamped_out_percentage} | #{E:@battery_revamped_out_remain}'
  planned
  [[ -z "${output}" ]]
  option render jobs
  option published "icon remain"
  var status-right "#(${tool} status icon) #(${tool} status remain)"

  # Act
  planned

  # Assert
  [[ -z "${output}" ]]
}

@test "plan - a status line with no placeholder is not written, and an old list of metrics is emptied" {
  # Arrange
  option popup_key off
  option published "percentage"
  var status-right '%H:%M #{session_name}'

  # Act
  planned

  # Assert
  [[ "${output}" == 'set-option -gq @battery_revamped_published ""' ]]
}

@test "plan - a setting given in the environment rides on the key and on every job" {
  # Arrange
  var status-right '#{battery_percentage}'

  # Act
  planned 'export BATTERY_REVAMPED_INTERVAL=2; '

  # Assert
  [[ "${lines[0]}" == *"battery-revamped' --interval '2' popup" ]]
  [[ "${lines[1]}" == *"battery-revamped' --interval '2' status percentage)" ]]
}

@test "plan - settings given in the environment ride in the order of the settings table, and an empty one rides too" {
  # Arrange
  var status-right '#{battery_percentage}'

  # Act
  planned 'export BATTERY_REVAMPED_LOW_THRESHOLD=15 BATTERY_REVAMPED_PERCENTAGE_LABEL= BATTERY_REVAMPED_INTERVAL=3 BATTERY_REVAMPED_POPUP_KEY=F8 BATTERY_REVAMPED_POPUP_WIDTH=40; '

  # Assert
  [[ "${lines[0]}" == "bind-key -N Battery details F8 run-shell "*"battery-revamped' --popup-width '40' --interval '3' --low-threshold '15' --percentage-label '' popup" ]]
}

@test "plan - apply sends everything in one tmux call and clears a daemon's claim in jobs mode" {
  # Arrange
  var status-right '#{battery_percentage}'

  # Act
  lib_run battery 'battery_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  run sends
  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" == "bind-key -N Battery details M-b run-shell "*" popup ; set-option -gq status-right #("*" status percentage) ; set-option -gq @battery_revamped_published percentage" ]]
  [[ "${lines[1]}" == "set-option -gqu @battery_revamped_ticker_pid" ]]
}

@test "plan - when tmux refuses the batch each command is sent alone, and the bad one fails the run" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_key F99
  var status-right '#{battery_percentage}'
  printf '%s\n' "bind-key -N Battery details F99 run-shell ${tool} popup" >"${FAKE}/refused"

  # Act
  lib_run battery 'battery_revamped_apply'

  # Assert
  [[ "${status}" -eq 1 ]]
  run sent '^set-option -gq status-right #(.* status percentage)$'
  [[ "${output}" == "1" ]]
  holds published percentage
}

@test "plan - in options mode apply starts the daemon, which claims the ticker and publishes until another takes over" {
  # Arrange
  acpi_battery 64
  option popup_key off
  option render options
  option interval 1
  var status-right '#{battery_percentage}'
  other_owner

  # Act
  lib_run battery 'battery_revamped_apply'

  # Assert
  [[ "${status}" -eq 0 ]]
  settled holds out_percentage "64%%"
  settled holds ticker_pid someone-else
  run sent '^set-option -gq @battery_revamped_ticker_pid [0-9][0-9]*$'
  [[ "${output}" == "1" ]]
}

@test "plan - the daemon ends when another process owns the ticker" {
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

@test "plan - the popup opens the card at the size the options give" {
  # Arrange
  local tool
  tool=$(tool_path)
  option popup_width 50
  option popup_height 20

  # Act
  lib_run battery 'battery_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-popup -E -w 50 -h 20 ${tool} popup-card"
}

@test "plan - the popup takes the default size, and a setting given in the environment rides on its command" {
  # Arrange
  local tool
  tool=$(tool_path)
  lib_run battery 'battery_revamped_popup'
  logged "display-popup -E -w 44 -h 16 ${tool} popup-card"

  # Act
  lib_run battery 'export BATTERY_REVAMPED_ICONS=nerd; battery_revamped_popup'

  # Assert
  logged "display-popup -E -w 44 -h 16 ${tool} --icons 'nerd' popup-card"
}

@test "plan - a tmux older than 3.2 says so and opens nothing" {
  # Arrange
  tmux_is 3.1

  # Act
  lib_run battery 'battery_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  logged "display-message battery-revamped: tmux 3.2+ is required for the battery detail popup"
  run sent '^display-popup'
  [[ "${output}" == "0" ]]
}

@test "plan - a popup or a message tmux refuses to open leaves the key quiet" {
  # Arrange
  printf '%s\n' "display-message battery-revamped: tmux 3.2+ is required for the battery detail popup" >"${FAKE}/refused"
  tmux_is 3.1
  lib_run battery 'battery_revamped_popup'
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
  local tool
  tool=$(tool_path)
  printf '%s\n' "display-popup -E -w 44 -h 16 ${tool} popup-card" >"${FAKE}/refused"
  tmux_is 3.6

  # Act
  lib_run battery 'battery_revamped_popup'

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "plan - a path is quoted for a job with each hash and each percent sign doubled, and for a key with no hash left" {
  # Arrange
  local script='battery_revamped_job_quote "/a b/it'"'"'s#1 50%"; battery_revamped_literal "/a b/it'"'"'s#1 50%"'

  # Act
  lib_run battery "${script}"

  # Assert
  [[ "${lines[0]}" == "'/a b/it'\\''s##1 50%%'" ]]
  [[ "${lines[1]}" == "'/a b/it'\\''s'\"\$(printf '%b' '\\0043')\"'1 50%'" ]]
}

@test "plan - a format given in the environment rides on the job with its percent signs doubled, since tmux reads the status line as a time format" {
  # Arrange
  option popup_key off
  var status-right '#{battery_percentage}'

  # Act
  planned 'export BATTERY_REVAMPED_PERCENTAGE_FORMAT="%s%% used"; '

  # Assert
  [[ "${lines[0]}" == *"battery-revamped' --percentage-format '%%s%%%% used' status percentage)" ]]
}
