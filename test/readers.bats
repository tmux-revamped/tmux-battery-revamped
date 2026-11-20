#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031,SC2034,SC2154

# shellcheck source=test/battery_helpers.bash
source "${BATS_TEST_DIRNAME:-.}/battery_helpers.bash"

@test "readers - macOS takes the charge, the state and the remaining time from pmset" {
  # Arrange
  macos
  pmset_battery 83 discharging "4:32 remaining"
  mac_details

  # Act
  reading

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "stored=1" ]]
  holds percent 83
  holds status discharging
  holds remain 4:32
  run asked
  [[ "${output}" == *"pmset -g batt"* ]]
}

@test "readers - every state word is read into one of the five states" {
  # Arrange
  local script='for text in Discharging Charging Charged Full "Not charging" pending-charge "pending discharge" Weird ""; do battery_revamped_norm "${text}"; printf "%s " "${BATTERY_REVAMPED_F_status}"; done'

  # Act
  lib_run battery "${script}"

  # Assert
  [[ "${output}" == "discharging charging charged charged attached attached attached unknown unknown " ]]
}

@test "readers - macOS reads the watts, the cycle count and the health from the system profiler and ioreg" {
  # Arrange
  macos
  pmset_battery
  mac_details 60 92 8579 8331

  # Act
  reading

  # Assert
  holds watts 60
  holds cycles 92
  holds health 97
}

@test "readers - macOS falls back to MaxCapacity and caps the health at 100" {
  # Arrange
  macos
  pmset_battery
  says ioreg '    "DesignCapacity" = 50
    "MaxCapacity" = 80
    "CycleCount" = 3'
  says system_profiler 'Power: nothing'

  # Act
  reading

  # Assert
  holds health 100
  holds cycles 3
  holds watts ""
}

@test "readers - macOS with no ioreg capacity leaves the health empty" {
  # Arrange
  macos
  pmset_battery
  says ioreg '    "CycleCount" = 3'

  # Act
  reading

  # Assert
  holds health ""
  holds cycles 3
}

@test "readers - macOS with a pmset that fails reads no battery and an unknown state" {
  # Arrange
  macos
  quiet pmset 'exit 1'

  # Act
  reading

  # Assert
  holds percent ""
  holds status unknown
  holds remain ""
}

@test "readers - macOS with no pmset at all reads no battery" {
  # Arrange
  macos

  # Act
  reading

  # Assert
  holds percent ""
  holds status unknown
}

@test "readers - macOS on AC reads the charged state and no remaining time" {
  # Arrange
  macos
  pmset_battery 100 charged "(no estimate) present: true"

  # Act
  reading

  # Assert
  holds percent 100
  holds status charged
  holds remain ""
}

@test "readers - Linux reads the first power supply with a readable capacity" {
  # Arrange
  supply BAT0 capacity 77 status Discharging
  supply BAT1 capacity 10 status Charging

  # Act
  reading

  # Assert
  holds percent 77
  holds status discharging
}

@test "readers - Linux skips a power supply that has no capacity file" {
  # Arrange
  supply BAT0 status Charging
  supply BAT1 capacity 55 status Full

  # Act
  reading

  # Assert
  holds percent 55
  holds status charged
}

@test "readers - Linux reads no battery when the capacity file cannot be read" {
  # Arrange
  mkdir -p "${SYS}/class/power_supply/BAT0/capacity" "${SYS}/class/power_supply/BAT0/status"

  # Act
  reading

  # Assert
  holds percent ""
  holds status unknown
}

@test "readers - Linux computes the time to empty from the energy and power counters" {
  # Arrange
  supply BAT0 capacity 50 status Discharging energy_now 30000000 energy_full 60000000 power_now 12000000

  # Act
  reading

  # Assert
  holds remain 2:30
  holds watts 12
}

@test "readers - Linux computes the time to full, and uses the charge counters when the energy ones are missing" {
  # Arrange
  supply BAT0 capacity 50 status Charging charge_now 1500000 charge_full 3000000 current_now 600000

  # Act
  reading

  # Assert
  holds remain 2:30
}

@test "readers - Linux has no remaining time when full, idle, at zero rate or with junk counters" {
  # Arrange
  supply BAT0 capacity 50 status Charging energy_now 60000000 energy_full 60000000 power_now 1000
  reading
  holds remain ""
  supply BAT0 status Discharging power_now 0
  later 100
  option detail_ts 0
  reading
  holds remain ""
  supply BAT0 status "Not charging" power_now 1000
  option detail_ts 0
  reading
  holds remain ""
  supply BAT0 status Charging energy_full junk
  option detail_ts 0

  # Act
  reading

  # Assert
  holds remain ""
  supply BAT0 energy_now abc status Discharging
  option detail_ts 0
  reading
  holds remain ""
}

@test "readers - Linux reads the cycle count, the watts and the health" {
  # Arrange
  supply BAT0 capacity 50 status Discharging cycle_count 88 power_now 45000000 energy_full 45000000 energy_full_design 50000000

  # Act
  reading

  # Assert
  holds cycles 88
  holds watts 45
  holds health 90
}

@test "readers - Linux reads the health from the charge counters when the energy ones are missing" {
  # Arrange
  supply BAT0 capacity 50 status Discharging cycle_count junk power_now junk charge_full 4500 charge_full_design 5000

  # Act
  reading

  # Assert
  holds health 90
  holds cycles ""
  holds watts ""
}

@test "readers - Linux leaves the health empty for a zero design capacity and caps it at 100" {
  # Arrange
  supply BAT0 capacity 50 status Discharging energy_full 10 energy_full_design 0
  reading
  holds health ""
  supply BAT0 energy_full 90 energy_full_design 50
  option detail_ts 0

  # Act
  reading

  # Assert
  holds health 100
}

@test "readers - Linux with a junk capacity reads no battery and does not fall back to acpi" {
  # Arrange
  supply BAT0 capacity junk status Charging
  acpi_battery 64

  # Act
  reading

  # Assert
  holds percent ""
  holds status charging
}

@test "readers - Linux without a power supply falls back to acpi for the charge, the state and the time" {
  # Arrange
  acpi_battery 64 Discharging ", 03:00:00 remaining"

  # Act
  reading

  # Assert
  holds percent 64
  holds status discharging
  holds remain 03:00
  run asked
  [[ "${output}" == "acpi -b" ]]
}

@test "readers - acpi with a state and no time leaves the remaining time empty, and a full battery is charged" {
  # Arrange
  acpi_battery 100 Full ""

  # Act
  reading

  # Assert
  holds percent 100
  holds status charged
  holds remain ""
}

@test "readers - the remaining time comes from acpi before the counters when both exist" {
  # Arrange
  supply BAT0 capacity 50 status Discharging energy_now 30000000 energy_full 60000000 power_now 12000000
  acpi_battery 50 Discharging ", 01:10:00 remaining"

  # Act
  reading

  # Assert
  holds remain 01:10
  holds percent 50
}

@test "readers - acpi with no time falls back to the counters" {
  # Arrange
  supply BAT0 capacity 50 status Discharging energy_now 30000000 energy_full 60000000 power_now 12000000
  acpi_battery 50 Discharging ""

  # Act
  reading

  # Assert
  holds remain 2:30
}

@test "readers - Linux with neither a power supply nor acpi reads no battery" {
  # Arrange
  supply NOTBAT capacity 50

  # Act
  reading

  # Assert
  holds percent ""
  holds status unknown
  holds remain ""
  holds watts ""
}

@test "readers - another system reads the battery the Linux way, and only Linux reads the watts" {
  # Arrange
  other_system
  supply BAT0 capacity 30 status Discharging energy_now 30000000 energy_full 60000000 power_now 12000000 cycle_count 5

  # Act
  reading

  # Assert
  holds percent 30
  holds remain 2:30
  holds watts ""
  holds cycles ""
}

@test "readers - the details are read again only when they are older than the detail interval" {
  # Arrange
  supply BAT0 capacity 50 status Discharging cycle_count 5
  reading
  supply BAT0 cycle_count 6
  later 30

  # Act
  reading

  # Assert
  holds cycles 5
  later 100
  reading
  holds cycles 6
}
