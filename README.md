<div align="center">

<h1>tmux-battery-revamped</h1>

**Battery status for your tmux status bar, without ever blocking the status render.**

[![Tests](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

</div>

**20** placeholders · **2** platforms · **177** tests · **95%+** coverage

Battery probes like `pmset` and `upower` are slow enough to stutter a status bar that queries them inline, and the classic approach fans out a dozen of them per refresh. This plugin queries once in a detached background worker, caches the result in tmux server user-options, and serves every placeholder from that cache. No temp files are used.

Inspired by [tmux-battery](https://github.com/tmux-plugins/tmux-battery). Built from [tmux-plugin-template](https://github.com/tmux-revamped/tmux-plugin-template).

<table>
<tr>
<td><b>Non-blocking</b><br/>One detached background worker does the probing, so the status render never waits on slow battery tools.</td>
<td><b>No temp files</b><br/>Readings live in tmux server user-options, with nothing written to disk.</td>
</tr>
<tr>
<td><b>Cross-platform</b><br/>Works on Linux and macOS, across Intel and Apple Silicon.</td>
<td><b>Tested</b><br/>177 tests hold the behavior at 95%+ coverage.</td>
</tr>
</table>

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
| `#{battery_drain_rate}` | drain rate in percent per hour, for example `12.5%/h` |
| `#{battery_estimate}` | acpi-free remaining-time estimate, for example `2:00` |
| `#{battery_sparkline}` | charge-history sparkline from a bounded ring buffer |
| `#{battery_power_source}` | `AC` or `Bat` |
| `#{battery_alert_icon}` | a glyph when discharging at a low or critical level |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
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
| `@battery_revamped_low_threshold` | `20` | discharging percent treated as low |
| `@battery_revamped_critical_threshold` | `10` | discharging percent treated as critical |
| `@battery_revamped_low_icon` / `@battery_revamped_critical_icon` | empty | alert glyphs for `#{battery_alert_icon}` |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | format for the drain rate |
| `@battery_revamped_history_size` | `16` | readings kept in the sparkline ring |
| `@battery_revamped_source_ac_label` / `@battery_revamped_source_battery_label` | `AC` / `Bat` | power-source labels |
| `@battery_revamped_notify` | `0` | set to `1` for one-shot low/critical/full desktop notifications |
| `@battery_revamped_popup_key` | `B` | prefix key that opens the detail popup |
| `@battery_revamped_popup_width` / `@battery_revamped_popup_height` | `44` / `12` | detail popup size |

## Notifications, popup, and doctor

Desktop notifications are off by default. Set `@battery_revamped_notify` to `1` to get one alert each time the charge crosses into low, critical, or full while discharging or charging. Each crossing fires once: the alert will not repeat until the level changes and crosses again. macOS uses `osascript`, Linux uses `notify-send`.

```tmux
set -g @battery_revamped_notify '1'
```

Press `prefix + B` to open a detail popup built from the cached values, with no re-probing. Rebind it with `@battery_revamped_popup_key`.

Run the dispatcher with `doctor` to see which sources this host exposes:

```sh
./src/battery.sh doctor
```

## Theme color suggestions

The defaults use 16 ANSI color names that the active terminal theme remaps, so the plugin matches any theme out of the box. For exact hex values, copy one block below into your `.tmux.conf`. Each block colors the low charge tiers red, the middle tiers yellow, and the high tiers green, then colors the status states to match.

### Catppuccin Mocha

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#89b4fa]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#a6adc8]"
```

### Dracula

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#bd93f9]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#6272a4]"
```

### Nord

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#81a1c1]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#d8dee9]"
```

### Gruvbox Dark

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#83a598]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#a89984]"
```

### Tokyo Night

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#7aa2f7]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#565f89]"
```

### Solarized Dark

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#859900]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#b58900]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#268bd2]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#586e75]"
```

## Support by platform and architecture

The macOS path uses built-in tools and works the same on Intel and Apple Silicon.

| Field | Linux (x86_64 and arm64) | macOS (Intel and Apple Silicon) |
|-------|--------------------------|----------------------------------|
| Percentage and status | yes, `/sys/class/power_supply` then `acpi` | yes, `pmset` |
| Remaining time | yes, with `acpi` installed | yes, `pmset` |
| Charging or discharging watts | yes, `power_now` | yes, `system_profiler` |
| Cycle count and health | yes, `/sys` | yes, `ioreg` (works on Apple Silicon) |

On Linux, percentage and status work through `/sys` with no extra package; remaining time needs `acpi` installed. Cycle count and health read from `ioreg` on macOS, which works on Apple Silicon, and from `/sys` on Linux.

## Development

```sh
make test
make lint
make coverage
```

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the
same contract in [`FAMILY.md`](FAMILY.md), the same tooling under `family/`, and
the same shared library, all held byte-identical by a checksum manifest. They are
built to be installed together: no member claims a key or a tmux option that
another member claims.

A defect found in one member is hunted across all of them before the fix is
called done. That obligation is written into the contract rather than left to
memory, and `family/bin/sweep` is how it is discharged.

| Member | What it does |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | Edit your tmux config, save, and watch it reload itself, no key, no command |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | **this plugin**, Battery status for your tmux status bar, without ever blocking the status render |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | Every connected Bluetooth device and its battery in your tmux status bar, without blocking the render |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU load, temperature, and frequency in your tmux status bar, without ever blocking the render |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | Disk usage for your tmux status bar, without ever blocking the status render |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Fuzzy-grab any URL, path, or word off the screen and paste it, pure shell, no Python |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Jump to any session, window, or pane, or kill it, from one fzf popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Git repository status in your tmux status bar, without ever blocking the render |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, frequency, and memory for your tmux status bar |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in your tmux status bar, async, kubectl-free, never blocking |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Standard pane and window management bindings for tmux, version aware, vim friendly, and fully configurable |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | One plugin that captures every session, window, pane, layout, and working |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | A template for building non-blocking tmux status plugins |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in your tmux status bar, with zero temp files: all state lives in tmux options |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM usage for your tmux status bar, without ever blocking the status render |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Mouse wheel that does the right thing: scroll the app directly, copy-mode everywhere else. No app names to con |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults that normalize behavior across every tmux version, OS, and terminal, without clobbering |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | --- |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local clock and world clocks in your tmux status bar, without ever blocking the render |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather in your tmux status bar, fetched in the background so the render never waits on the network |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
