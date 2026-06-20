# tmux-battery-revamped

[![Tests](https://github.com/gufranco/tmux-battery-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-battery-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Battery status for your tmux status bar, without ever blocking the status render.

Battery probes like `pmset` and `upower` are slow enough to stutter a status bar
that queries them inline, and the classic approach fans out a dozen of them per
refresh. This plugin queries once in a detached background worker, caches the
result in tmux server user-options, and serves every placeholder from that cache.
No temp files are used.

Inspired by [tmux-battery](https://github.com/tmux-plugins/tmux-battery). Built
from [tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template).

## Placeholders

| Placeholder | Output |
|-------------|--------|
| `#{battery_percentage}` | charge, for example `83%` |
| `#{battery_icon}` | charge tier icon |
| `#{battery_icon_charge}` | charge tier icon |
| `#{battery_icon_status}` | status icon |
| `#{battery_color_fg}` / `#{battery_color_bg}` | status colors |
| `#{battery_color_charge_fg}` / `#{battery_color_charge_bg}` | charge tier colors |
| `#{battery_color_status_fg}` / `#{battery_color_status_bg}` | status colors |
| `#{battery_graph}` | a proportional charge bar |
| `#{battery_remain}` | time remaining, for example `4:32` |
| `#{battery_charging_watts}` | charging or discharging watts |
| `#{battery_cycles}` | charge cycle count |
| `#{battery_health}` | battery health, for example `96%` |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'gufranco/tmux-battery-revamped'
set -g status-right '#{battery_icon_status} #{battery_percentage} #{battery_remain}'
```

Press `prefix + I` to install.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@battery_revamped_interval` | `15` | seconds a reading stays fresh |
| `@battery_revamped_percentage_format` | `%s%%` | format for the percentage |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁`..`█` | charge tier icons, tier 1 is lowest |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | empty | charge tier colors |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | status icons |
| `@battery_revamped_status_{state}_{fg,bg}_color` | empty | status colors |
| `@battery_revamped_graph_width` | `10` | cells in the charge bar |
| `@battery_revamped_graph_full` | `█` | filled cell character |
| `@battery_revamped_graph_empty` | `░` | empty cell character |
| `@battery_revamped_remain_format` | `%s` | format for the remaining time |
| `@battery_revamped_watts_format` | `%sW` | format for charging watts |
| `@battery_revamped_cycles_format` | `%s` | format for the cycle count |
| `@battery_revamped_health_format` | `%s%%` | format for battery health |
| `@battery_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/battery-revamped-logs` |

## Support by platform and architecture

The macOS path uses built-in tools and works the same on Intel and Apple Silicon.

| Field | Linux (x86_64 and arm64) | macOS (Intel and Apple Silicon) |
|-------|--------------------------|----------------------------------|
| Percentage and status | yes, `/sys/class/power_supply` then `acpi` | yes, `pmset` |
| Remaining time | yes, with `acpi` installed | yes, `pmset` |
| Charging or discharging watts | yes, `power_now` | yes, `system_profiler` |
| Cycle count and health | yes, `/sys` | yes, `ioreg` (works on Apple Silicon) |

On Linux, percentage and status work through `/sys` with no extra package;
remaining time needs `acpi` installed. Cycle count and health read from `ioreg`
on macOS, which works on Apple Silicon, and from `/sys` on Linux.

## License

[MIT](LICENSE), copyright Gustavo Franco.
