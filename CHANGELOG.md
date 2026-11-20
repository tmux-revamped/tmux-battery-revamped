# Changelog

# [3.0.0](https://github.com/tmux-revamped/tmux-battery-revamped/compare/v2.0.0...v3.0.0) (2026-11-20)


* feat!: rewrite the plugin in POSIX sh ([77a09e7](https://github.com/tmux-revamped/tmux-battery-revamped/commit/77a09e7037c8409934efe8caa25679d6f35ac057))


### BREAKING CHANGES

* the script moved from src/battery.sh to
bin/battery-revamped. A placeholder is printed by "battery-revamped
status NAME", where it was "battery.sh NAME", and "battery.sh start"
is now "battery-revamped apply". bash is no longer required. A tmux
option set to nothing now means its default, where an empty label,
format, icon or graph cell used to print nothing; set it to off
instead. The environment variables CACHE_SYNC, CACHE_MAX_RUN and
TICKER_MAX_TICKS are gone.

# [2.0.0](https://github.com/tmux-revamped/tmux-battery-revamped/compare/v1.4.3...v2.0.0) (2026-11-18)


### Documentation

* add the settings and value rules ([b1ffe10](https://github.com/tmux-revamped/tmux-battery-revamped/commit/b1ffe103fdd474be1486ee44d8eec1dbc57430cc))


### BREAKING CHANGES

* decided on its own, apart from the alias rule, which
is about names.

## [1.4.3] - 2026-11-17

### Fixed

- `prefix + M-b` opened a card with empty values when nothing had filled the
  cache yet, as on a status line without a battery placeholder. The card now
  reads the battery first in that case, and says so on a machine without one.

## [1.4.2] - 2026-11-16

### Fixed

- A popup opened from a checkout path holding a `#` ran the wrong path,
  because the popup command doubled the `#` and tmux 3.6 and later expand no
  format there. The command now writes each `#` through `printf '%b'`, so
  it reads the same on every tmux version.

## [1.4.1] - 2026-11-15

### Fixed

- A desktop notification whose title or message held a double quote or a
  backslash broke the AppleScript that showed it, and text after the quote ran
  as AppleScript. Notifications now go through the family's shared notifier,
  which hands the title and message to `osascript` and `notify-send` as
  arguments.

## [1.4.0] - 2026-10-27

### Added

- `@battery_revamped_render 'options'` replaces the `#()` calls with tmux option
  reads, written by one background process per server every
  `@battery_revamped_interval` seconds, 15 by default. tmux reruns a `#()` call on every redraw, so a
  shared bar ran each one about once a second and painted values one by one.
- `@battery_revamped_fixed_width 'on'` pads each value to its widest form, and
  `@battery_revamped_<metric>_width` sets one metric's width, so a value changing
  length no longer shifts the rest of the status line.
- `{icon}` and `{color}` tokens in `@battery_revamped_before` and
  `@battery_revamped_after`, filled with the current charge icon and tier
  color, so a pill drawn around the percentage follows the charge.
- Nerd Font battery-level glyphs for the eight charge tiers under
  `@battery_revamped_icons nerd`, with charging variants while charging.
- `@battery_revamped_hide_on_ac`. Set to `1`, every placeholder renders
  nothing while the machine is on AC power.
- `@battery_revamped_before` and `@battery_revamped_after`, placed around the
  percentage only when it renders, so a theme pill disappears with it.
- Metric labels. `@battery_revamped_<metric>_label` prints an icon or word before a value
  only when the value is not empty, and `@battery_revamped_icons` set to `nerd` labels
  every metric from a Nerd Font set. The default adds no labels.

### Changed

- The options-mode background process reads every option it needs in one tmux
  call per tick, sends its cache writes and published values in a second, and
  keeps its functions out of the environment of the commands it runs.
  Remaining time, wattage, cycles and health refresh every
  `@battery_revamped_detail_interval` seconds, 60 by default, and options mode
  ticks every `@battery_revamped_interval` seconds, 15 by default.

### Fixed

- On bash 5.2 and later, an `&` or a backslash in the charge icon or tier color
  came out altered in `@battery_revamped_before` and `@battery_revamped_after`,
  because an unquoted `&` in a replacement stands for the matched text. Both are
  now inserted verbatim.
- In options mode, running the entry point a second time, as two overlapping
  config reloads do, found no placeholders left in the status line and
  published nothing, which froze every value. A metric whose option read is
  already on the status line now counts as used.
- A comma-decimal locale such as pt_BR printed the drain rate as `1,0`. The
  arithmetic now runs under the C locale.
- The 1.3.0 entry below named the popup key as `prefix + B`. The popup has
  always been bound to `prefix + M-b`, as the README states.
- On Apple Silicon, cycles showed a huge number and health was wrong, because
  the ioreg key match hit the nested `BatteryData` dictionary first. Keys now
  match only at the start of a line, and health uses `AppleRawMaxCapacity`.
- On a Linux host with two batteries, percent came from one battery and
  cycles, health and time remaining from the other. Every value now comes
  from the same battery.
- Linux health stayed empty on batteries that expose only `energy_full` and
  `energy_full_design`. Those counters are now read first.
- The drain rate compared consecutive 15 second readings, so it swung between
  0 and 240%/h. It is now measured over at least five minutes.
- The detail popup closed at once when the default shell was dash or zsh. It
  now runs under bash.
- A plugin directory containing a space or a quote broke every placeholder and
  the popup key. The path is now quoted.
- Switching from options mode back to jobs mode left the background process
  running. Jobs mode now releases it, and it exits on its next tick.
- The background process no longer keeps the caller's stdin open.
- `@battery_revamped_enable_logging` was documented but did nothing, and is no
  longer listed.
- On bash 5.2 and later, a plugin directory whose path held `&` still broke
  every `#()` status call, because the placeholder replacement treated `&` in
  the quoted path as the matched text. Placeholders are now replaced by plain
  string splicing.
- Setting `@battery_revamped_popup_key` to `off` leaves the detail popup
  unbound; before, no value could turn the key off. The default stays `M-b`.

## [1.3.0] - 2026-06-30

### Added

- Drain-rate token `#{battery_drain_rate}` in percent per hour, computed from the
  delta between the previous and current reading kept in a tmux user-option.
- acpi-free remaining-time estimate `#{battery_estimate}` derived from the drain
  rate, so a time estimate shows even when no native source reports one.
- Charge-history sparkline `#{battery_sparkline}` backed by a bounded ring buffer
  in a tmux user-option, with no temp file.
- Opt-in, one-shot threshold desktop notifications for low, critical, and full,
  off by default behind `@battery_revamped_notify`. Each crossing fires once.
- Battery detail popup bound to `prefix + B` by default, built from cached values
  with zero re-probing.
- Power-source token `#{battery_power_source}` and a low/critical alert glyph
  `#{battery_alert_icon}`.
- A `doctor` subcommand reporting which battery sources this host exposes.

## [1.2.0] - 2026-06-23

### Added

- Remaining battery time on Linux now also computes from the power-supply
  energy or charge counters when `acpi` is not installed, so `#{battery_remain}`
  keeps working on minimal systems (upstream tmux-battery #124).

### Changed

- The UPower `pending-charge` and `pending-discharge` states now map to the
  attached status instead of showing as unknown (upstream tmux-battery #117).
- Reviewed upstream tmux-battery PR #123. The false-positive WSL detection it
  fixes never applied here; this plugin reads battery state directly from
  `pmset`, `/sys`, and `acpi` and has no kernel-string heuristic.

## [1.1.0] - 2026-06-20

### Added

- Charge cycle count `#{battery_cycles}` and battery health `#{battery_health}`,
  from ioreg on macOS (works on Apple Silicon) and /sys on Linux.
- Discharging/charging watts on Linux via power_now.

## [1.0.0] - 2026-06-19

### Added

- Thirteen battery placeholders: percentage, charge and status icons, charge and
  status colors, a proportional graph, remaining time, and charging watts.
- Non-blocking design: one query per refresh runs in a background worker and all
  placeholders read cached tmux user-options, replacing the classic per-render
  subprocess fan-out. No temp files.
- macOS via `pmset` and `system_profiler`, Linux via `/sys/class/power_supply`
  with an `acpi` fallback.
- Eight configurable charge tiers and five status states with custom icons and
  colors.
