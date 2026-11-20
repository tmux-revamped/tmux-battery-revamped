#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/server_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/server_helpers.bash"

bats_require_minimum_version 1.5.0

everything() {
  local options
  options=$(tmux show-options -g)
  grep -vE '@battery_revamped_(percent|status|remain|watts|cycles|health|drain_rate|history|alert_level|snap_pct|snap_ts|detail_ts|[a-z_]+_ts|percent_lock) ' <<<"${options}"
  tmux list-keys
}

@test "entrypoint - git tracks the entry point and the tool as executable" {
  # Arrange
  local modes

  # Act
  modes=$(git -C "${ROOT}" ls-files --stage -- battery-revamped.tmux bin/battery-revamped)

  # Assert
  run awk '$1 != "100755" { bad++ } END { print NR ":" bad + 0 }' <<<"${modes}"
  [[ "${output}" == "2:0" ]]
}

@test "entrypoint - loading binds the popup on M-b and turns the placeholder into its job, which shows the charge" {
  # Arrange
  local keys
  tmux set-option -g status-right '#{battery_percentage} #{battery_remain} #{battery_power_source} end'

  # Act
  load_plugin

  # Assert
  keys=$(prefix_keys)
  run grep -c -x 'M-b' <<<"${keys}"
  [[ "${output}" == "1" ]]
  run tmux show-option -gqv status-right
  [[ "${output}" == "#('${ROOT}/bin/battery-revamped' status percentage) #('${ROOT}/bin/battery-revamped' status remain) #('${ROOT}/bin/battery-revamped' status power_source) end" ]]
  wait_for host_shows "77% 3:10 Bat end"
}

@test "entrypoint - loading twice changes nothing" {
  # Arrange
  local before after
  tmux set-option -g status-right '#{battery_percentage} end'
  load_plugin
  before=$(everything)

  # Act
  load_plugin

  # Assert
  after=$(everything)
  [[ "${before}" == "${after}" ]]
}

@test "entrypoint - the state icon, the graph, the watts, the cycles and the health reach the status line" {
  # Arrange
  tmux set-option -g status-right '#{battery_icon_status}#{battery_graph} #{battery_cycles} #{battery_health} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows $'-\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x91\xe2\x96\x91 92'
  wait_for host_shows " 97% end"
}

@test "entrypoint - in the nerd set a label set to nothing on a real server means the default, so every metric keeps its glyph" {
  # Arrange
  tmux set-option -g @battery_revamped_icons nerd
  tmux set-option -g @battery_revamped_percentage_label ''
  tmux set-option -g status-right '#{battery_percentage} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows $'\xf3\xb0\x81\xb9 77% end'
}

@test "entrypoint - a format given in the environment reaches the status job with its percent signs whole" {
  # Arrange
  tmux set-environment -g BATTERY_REVAMPED_PERCENTAGE_FORMAT 'charge %s%%'
  tmux set-option -g status-right '#{battery_percentage} end'

  # Act
  load_plugin

  # Assert
  wait_for host_shows "charge 77% end"
}

@test "entrypoint - a checkout whose path holds a space, a quote, a hash and a percent sign loads, shows the charge and takes its key" {
  # Arrange
  local copy="${BATS_TEST_TMPDIR}/it's #1 50% plug in"
  mkdir -p "${copy}"
  cp -R "${ROOT}/bin" "${ROOT}/lib" "${ROOT}/battery-revamped.tmux" "${copy}/"
  tmux set-option -g status-right '#{battery_percentage} end'
  load_plugin "${copy}"
  wait_for host_shows "77% end"

  # Act
  press C-b M-b

  # Assert
  wait_for host_shows "Press any key to close."
}

@test "entrypoint - a default key someone else holds is left alone, and one the person names is bound" {
  # Arrange
  local table
  tmux bind-key -T prefix M-b display-message taken
  load_plugin
  table=$(tmux list-keys -T prefix)
  run grep -c 'M-b  *display-message taken' <<<"${table}"
  [[ "${output}" == "1" ]]
  run grep -c 'battery-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
  tmux bind-key -T prefix x display-message taken-too
  setting popup_key x

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'battery-revamped. popup' <<<"${table}"
  [[ "${output}" == "1" ]]
}

@test "entrypoint - a key set to off binds nothing" {
  # Arrange
  local table
  setting popup_key off

  # Act
  load_plugin

  # Assert
  table=$(tmux list-keys -T prefix)
  run grep -c 'battery-revamped' <<<"${table}"
  [[ "${output}" == "0" ]]
}
