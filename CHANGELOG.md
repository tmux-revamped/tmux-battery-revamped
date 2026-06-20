# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
