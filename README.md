<div align="center">

# tmux-battery-revamped

<strong>Battery status for your tmux status bar, without ever blocking the status render.</strong>

English | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">What it does</a> |
  <a href="#requirements">Requirements</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#configuration">Configuration</a> |
  <a href="#key-bindings">Key bindings</a> |
  <a href="#how-it-works">How it works</a>
</p>

</div>

**20** placeholders. **2** render modes. **5** system sources: `pmset`, `system_profiler`, `ioreg`, `/sys/class/power_supply` and `acpi`. CI runs the suite on **10** Linux and macOS toolchain combinations.

---

## What it does

The plugin replaces `#{battery_*}` placeholders in `status-left` and `status-right` with the charge, status, remaining time, wattage, cycle count, health, drain rate and charge history of the laptop battery. Every placeholder reads a value cached in a tmux option. The battery tools run in the background, so a slow `pmset` or `system_profiler` call never delays the status line. Nothing is written to disk.

It also sends optional desktop notifications at low, critical and full charge, and opens a detail popup on `prefix + M-b`.

## Requirements

| Tool | Version | Needed for |
|:-----|:--------|:-----------|
| tmux | 3.2 or later | `display-popup` for the detail popup |
| bash | 3.2 or later | every script, including macOS `/bin/bash` |
| `acpi` | any | optional on Linux, a fallback for charge and remaining time |
| `osascript` or `notify-send` | any | optional, desktop notifications |

| Value | Linux, x86_64 and arm64 | macOS, Intel and Apple Silicon |
|:------|:------------------------|:-------------------------------|
| Charge and status | the first `/sys/class/power_supply/BAT*`, then `acpi` | `pmset` |
| Remaining time | `acpi`, then computed from the `/sys` energy or charge counters | `pmset` |
| Watts | `power_now`, the current draw | `system_profiler`, the charger's rated wattage |
| Cycle count | `cycle_count` | `ioreg` |
| Health | `energy_full` over `energy_full_design`, then the `charge_*` pair | `ioreg`, `AppleRawMaxCapacity` over `DesignCapacity` |

A value the host has no source for renders empty. Run `src/battery.sh doctor` to see which sources this host has.

## Installation

### With TPM

Add the plugin and a placeholder to `~/.tmux.conf`, then press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
set -g status-right '#{battery_icon_status} #{battery_percentage} #{battery_remain}'
```

### Manual

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

Then add this line to `~/.tmux.conf`, after the lines that set `status-left` and `status-right`, and reload tmux:

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

## Usage

Put placeholders in `status-left` or `status-right`. The plugin replaces them when it loads. [`examples/status-right.tmux.conf`](examples/status-right.tmux.conf) has a complete example.

```tmux
set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

| Placeholder | Output |
|:------------|:-------|
| `#{battery_percentage}` | charge, for example `83%` |
| `#{battery_icon}`, `#{battery_icon_charge}` | the icon of the current charge tier |
| `#{battery_icon_status}` | the icon of the current status |
| `#{battery_color_fg}`, `#{battery_color_bg}` | the colors of the current status |
| `#{battery_color_status_fg}`, `#{battery_color_status_bg}` | the colors of the current status |
| `#{battery_color_charge_fg}`, `#{battery_color_charge_bg}` | the colors of the current charge tier |
| `#{battery_graph}` | a charge bar, for example `████████░░` |
| `#{battery_remain}` | time remaining reported by the system, for example `4:32` |
| `#{battery_estimate}` | time remaining computed from the drain rate, for example `2:00` |
| `#{battery_charging_watts}` | watts, for example `45W` |
| `#{battery_cycles}` | charge cycle count |
| `#{battery_health}` | full capacity over design capacity, for example `96%` |
| `#{battery_drain_rate}` | percent per hour over at least five minutes, for example `12.5%/h` |
| `#{battery_sparkline}` | recent charge readings, for example `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC` or `Bat` |
| `#{battery_alert_icon}` | a glyph while discharging at a low or critical charge |

The status is one of `charged`, `charging`, `discharging`, `attached` or `unknown`. `attached` means on AC power and not charging.

## Configuration

| Option | Default | Meaning |
|:-------|:--------|:--------|
| `@battery_revamped_interval` | `15` | seconds a charge and status reading stays fresh |
| `@battery_revamped_detail_interval` | `60` | seconds the remaining time, watts, cycles and health stay fresh |
| `@battery_revamped_render` | empty | `options` turns on options render mode, see [How it works](#how-it-works) |
| `@battery_revamped_percentage_format` | `%s%%` | printf format for the charge |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` to `█` | icon per charge tier, tier 1 is the lowest |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | empty | colors per charge tier |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | icon per status |
| `@battery_revamped_status_{state}_{fg,bg}_color` | empty | colors per status |
| `@battery_revamped_icons` | `ascii` | `nerd` uses Nerd Font battery glyphs for the eight tiers, with charging variants, and labels every metric; a tier icon option still wins |
| `@battery_revamped_graph_width` | `10` | cells in the charge bar |
| `@battery_revamped_graph_full` | `█` | filled cell |
| `@battery_revamped_graph_empty` | `░` | empty cell |
| `@battery_revamped_remain_format` | `%s` | format for both remaining-time placeholders |
| `@battery_revamped_watts_format` | `%sW` | format for the watts |
| `@battery_revamped_cycles_format` | `%s` | format for the cycle count |
| `@battery_revamped_health_format` | `%s%%` | format for the health |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | format for the drain rate |
| `@battery_revamped_history_size` | `16` | readings kept for the sparkline |
| `@battery_revamped_low_threshold` | `20` | charge percent treated as low while discharging |
| `@battery_revamped_critical_threshold` | `10` | charge percent treated as critical while discharging |
| `@battery_revamped_low_icon`, `@battery_revamped_critical_icon` | empty | glyphs for `#{battery_alert_icon}` |
| `@battery_revamped_source_ac_label`, `@battery_revamped_source_battery_label` | `AC`, `Bat` | text for `#{battery_power_source}` |
| `@battery_revamped_hide_on_ac` | `0` | `1` renders every placeholder empty unless the battery is discharging |
| `@battery_revamped_before`, `@battery_revamped_after` | empty | text placed around `#{battery_percentage}` only when it renders; `{icon}` becomes the charge icon and `{color}` the charge tier color |
| `@battery_revamped_<metric>_label` | empty | text printed before one metric's value when the value is not empty; `''` removes the `nerd` label |
| `@battery_revamped_fixed_width` | `off` | `on` pads each value on the left to its widest form |
| `@battery_revamped_<metric>_width` | empty | pad width for one metric, which wins over the fixed width |
| `@battery_revamped_notify` | `0` | `1` sends a desktop notification when the charge enters low, critical or full |
| `@battery_revamped_popup_key` | `M-b` | prefix key for the detail popup; `off` binds nothing |
| `@battery_revamped_popup_width`, `@battery_revamped_popup_height` | `44`, `12` | popup size |

Labels apply to `percentage`, `graph`, `remain`, `charging_watts`, `cycles`, `health`, `drain_rate`, `estimate`, `sparkline` and `power_source`. A longer value is never cut by a width.

### Theme colors

The color options are empty by default, so the plugin adds no color until you set one. Each block below colors tiers 1 to 3 red, 4 to 6 yellow and 7 to 8 green, and gives each status its own color:

<details>
<summary>Catppuccin Mocha</summary>

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

</details>

<details>
<summary>Dracula</summary>

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

</details>

<details>
<summary>Nord</summary>

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

</details>

<details>
<summary>Gruvbox Dark</summary>

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

</details>

<details>
<summary>Tokyo Night</summary>

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

</details>

<details>
<summary>Solarized Dark</summary>

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

</details>

### Internal state

The plugin writes these options itself. Do not set them.

| Option | Holds |
|:-------|:------|
| `@battery_revamped_published` | the metrics found in `status-left` and `status-right` at load, which options mode publishes |
| `@battery_revamped_out_<metric>` | the published value of each metric in options mode |
| `@battery_revamped_ticker_pid` | pid of the options-mode background process |
| `@battery_revamped_option_names` | the options the background process reads in one call per tick |
| `@battery_revamped_alert_level` | the last level seen, `ok`, `low`, `critical`, `full` or `unknown`, so each notification fires once per crossing |
| `@battery_revamped_history` | recent charge readings for the sparkline |
| `@battery_revamped_snap_pct`, `@battery_revamped_snap_ts` | the reading the drain rate is measured from |
| `@battery_revamped_{percent,status,remain,watts,cycles,health,drain_rate}` | cached readings, each with a `_ts` timestamp, and `_lock` on `percent` |

## Key bindings

| Key | Action | Option |
|:----|:-------|:-------|
| `prefix + M-b` | open the detail popup | `@battery_revamped_popup_key` |

The popup shows the cached charge, status, remaining time, watts, drain rate, cycles and health, without probing the battery again. Any key closes it. An empty `@battery_revamped_popup_key` falls back to `M-b`, and `off` binds nothing.

## How it works

In the default jobs mode, each placeholder becomes a `#()` call to [`src/battery.sh`](src/battery.sh). The call prints the cached value at once. When the cached charge is older than `@battery_revamped_interval`, it also starts one background refresh, guarded by a lock so parallel calls do not start a second one.

tmux runs every `#()` call on every status redraw. With several plugins on one bar that can be about once a second. Options mode removes those calls:

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

Each placeholder then becomes an option read such as `#{E:@battery_revamped_out_percentage}`. One background process per server reads the battery every `@battery_revamped_interval` seconds and writes every value the status line uses in a single tmux call, followed by one redraw. The process exits when the server stops or a config reload starts its replacement. Switching back to jobs mode releases it.

The drain rate compares the current charge with a reading at least five minutes old. `#{battery_estimate}` divides the charge left by that rate. Notifications fire once per crossing into low, critical or full, through `osascript` on macOS and `notify-send` on Linux.

## Development

| Command | What it runs |
|:--------|:-------------|
| `make test` | the bats suite under [`test/`](test) |
| `make lint` | shellcheck on every shell file |
| `make coverage` | kcov line coverage on Linux, failing below 95% |

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
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | Pick a URL, path, hash or any other token off the screen with fzf and type it at the cursor, in pure shell |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | Switch to, kill, rename or create tmux sessions, windows and panes from fzf pickers in a popup |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | Show the active pane's git branch, changes and provider counts in the tmux status bar without blocking it |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | GPU load, temperature, clock, power and memory in the tmux status bar, from NVIDIA, AMD, Intel and Apple GPUs |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | Current Kubernetes context and namespace in the tmux status bar, parsed from kubeconfig without kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Launch any TUI app in a popup or a window, scoped to the current pane's directory, with one configurable bindi |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness, CI and family tooling |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

### Checking an installation

With every member on disk, one command reports any conflict between them:

```sh
family/bin/doctor --live
```

It reads each member and the running tmux server, and reports duplicate keys,
duplicate status placeholders, options outside the naming grammar, and any
member whose contract version has fallen behind.

<!-- family:end -->
