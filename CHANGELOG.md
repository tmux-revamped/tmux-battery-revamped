# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
