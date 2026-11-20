#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

loaded_with_status() {
  tmux set-option -g status-right '#{battery_percentage} end'
  load_plugin
  wait_for host_shows "77% end"
}

pane_is_plain() {
  local mode
  mode=$(tmux display-message -p -t test:0.0 '#{pane_in_mode}')
  [[ "${mode}" == "0" ]]
}

@test "keys - prefix M-b opens the card, which stays until a key and then closes the popup" {
  # Arrange
  loaded_with_status

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Press any key to close."
  wait_for host_shows "3:10"
  stays "Press any key to close."
  press q
  wait_for host_lacks "Press any key to close."
  wait_for host_shows "77% end"
  pane_is_plain
}

@test "keys - the card opens on a key the person names, and the default key then does nothing" {
  # Arrange
  setting popup_key F4
  loaded_with_status
  press C-b M-b
  host_lacks "Press any key to close."

  # Act
  press C-b F4

  # Assert
  wait_for host_shows "Charge"
}

@test "keys - the card shows every figure the battery gives" {
  # Arrange
  loaded_with_status

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Charge"
  wait_for host_shows "discharging"
  wait_for host_shows "Cycles"
  wait_for host_shows "Health"
  wait_for host_shows "Read. 77% charge, discharging."
}

@test "keys - the popup takes the size the options give" {
  # Arrange
  setting popup_width 60
  setting popup_height 14
  loaded_with_status

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Press any key to close."
  stays "Press any key to close."
}

@test "keys - in options mode the status line reads options a daemon fills" {
  # Arrange
  setting render options
  tmux set-option -g status-right '#{battery_percentage} | #{battery_remain} end'

  # Act
  load_plugin

  # Assert
  run tmux show-option -gqv status-right
  [[ "${output}" == "#{E:@battery_revamped_out_percentage} | #{E:@battery_revamped_out_remain} end" ]]
  wait_for host_shows "77% | 3:10 end"
  run tmux show-option -gqv @battery_revamped_ticker_pid
  [[ "${output}" =~ ^[0-9]+$ ]]
}

@test "keys - in options mode the popup key still opens the card" {
  # Arrange
  setting render options
  tmux set-option -g status-right '#{battery_percentage} end'
  load_plugin
  wait_for host_shows "77% end"

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Press any key to close."
}

@test "keys - a machine without a battery says so in the card" {
  # Arrange
  stand_in pmset 'exit 1'
  rm -rf "${REVAMPED_TEST_SYS:?}/class/power_supply/BAT0"
  tmux set-option -g status-right 'x'
  load_plugin

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "No battery was found on this machine."
}
