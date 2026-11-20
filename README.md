<div align="center">

# tmux-battery-revamped

<strong>Battery status for your tmux status bar, without ever blocking the status render.</strong>

English &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#Quick start"><strong>Quick start</strong></a> &nbsp;|&nbsp;
  <a href="#Usage">Usage</a> &nbsp;|&nbsp;
  <a href="#How it works">How it works</a> &nbsp;|&nbsp;
  <a href="#Screens">Screens</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="battery-revamped showing the charge coloured by tier with its state and remaining time, falling to a low and a critical charge, opening the card popup, switching to Nerd Font labels, the sparkline and the options render mode" width="800">
</p>

```console
$ battery-revamped refresh
Refreshed. 100% charge, charged.
$ battery-revamped status percentage
100%
```

**20** placeholders, **2** render modes, macOS and Linux, tmux **3.2** or later.

---

## Quick start

### Prerequisites

| Tool | Version | Used for |
|:-----|:-----|:-----|
| tmux | 3.2 or later | the family floor, and the popup |
| gum | optional | the menu, tables and colours of `battery-revamped`; without it every command prints plain text |
| `osascript`, `notify-send` | optional | desktop notifications, when `@battery_revamped_notify` is `1` |

It runs on Linux and macOS with BSD, GNU, uutils or BusyBox tools. Each figure comes from something the OS ships:

| Figure | Linux | macOS |
|:-----|:-----|:-----|
| Charge and state | the first `/sys/class/power_supply/BAT*` with a `capacity`, then `acpi` | `pmset` |
| Remaining time | `acpi`, then computed from the `energy_now` or `charge_now` counters | `pmset` |
| Watts | `power_now`, the current draw | `system_profiler`, the charger's rated wattage |
| Cycle count | `cycle_count` | `ioreg` |
| Health | `energy_full` over `energy_full_design`, then the `charge_*` pair | `ioreg`, `AppleRawMaxCapacity` over `DesignCapacity` |

A missing source leaves its placeholder empty, and `battery-revamped doctor` names it. A machine without a battery shows nothing.

### Install

With [TPM](https://github.com/tmux-plugins/tpm), add the plugin to `~/.tmux.conf` and press `prefix + I`:

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
```

To install by hand, clone the repository and run the entrypoint from `~/.tmux.conf`:

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

Set `status-left` or `status-right` before the plugin loads. The plugin replaces the placeholders it finds there once, at load time.

`make install` in the clone also puts `battery-revamped` in `~/.local/bin`, with its man page and completions under `~/.local/share`.

### Verify

```bash
~/.tmux/plugins/tmux-battery-revamped/bin/battery-revamped doctor
```

## Usage

The plugin shows the charge of the laptop battery with its state, remaining time, watts, cycle count, health, drain rate, an estimate and a sparkline of the recent charge. The status line prints a value tmux already holds, and a background reading refreshes it.

| Placeholder | Output |
|:-----|:-----|
| `#{battery_percentage}` | The charge, for example `83%` |
| `#{battery_icon}` | The icon of the current charge tier |
| `#{battery_icon_charge}` | The same icon as `#{battery_icon}` |
| `#{battery_icon_status}` | The icon of the current state |
| `#{battery_color_fg}` | The foreground style of the current state |
| `#{battery_color_bg}` | The background style of the current state |
| `#{battery_color_charge_fg}` | The foreground style of the current charge tier |
| `#{battery_color_charge_bg}` | The background style of the current charge tier |
| `#{battery_color_status_fg}` | The same style as `#{battery_color_fg}` |
| `#{battery_color_status_bg}` | The same style as `#{battery_color_bg}` |
| `#{battery_graph}` | A charge bar, for example `█████░░░░░` |
| `#{battery_remain}` | The time remaining the system reports, for example `4:32` |
| `#{battery_charging_watts}` | The watts, for example `45W` |
| `#{battery_cycles}` | The charge cycle count |
| `#{battery_health}` | Full capacity over design capacity, for example `96%` |
| `#{battery_drain_rate}` | Percent per hour over at least five minutes, for example `12.5%/h` |
| `#{battery_estimate}` | The time remaining computed from the drain rate, for example `2:00` |
| `#{battery_sparkline}` | Recent charge readings, for example `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC`, or `Bat` while discharging |
| `#{battery_alert_icon}` | A glyph while discharging at a low or critical charge, empty otherwise |

The state is one of `charged`, `charging`, `discharging`, `attached` or `unknown`. `attached` means on AC power and not charging.

Put placeholders in the status line:

```tmux
set -g @battery_revamped_status_discharging_fg_color '#[fg=yellow]'
set -g @battery_revamped_status_charging_fg_color '#[fg=green]'

set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

The same example, with a few more options, is in [examples/status-right.tmux.conf](examples/status-right.tmux.conf).

### Labels and widths

`@battery_revamped_<metric>_label` prints an icon or word before one metric, only when its value is not empty. `@battery_revamped_icons` set to `nerd` labels every metric below with a Nerd Font glyph. A metric's own label wins over the set, and a label set to nothing in tmux means the default, so the glyph stays; set a label to `off` to show neither a label nor the glyph. `off` also hides any icon or text option, such as `@battery_revamped_low_icon` or `@battery_revamped_graph_full`. The default, `ascii`, adds no labels.

| Metric | `nerd` glyph |
|:-----|:-----|
| `percentage` | U+F0079 |
| `graph` | U+F07B1 |
| `remain` | U+F051F |
| `charging_watts` | U+F0241 |
| `cycles` | U+F04E6 |
| `health` | U+F05F6 |
| `drain_rate` | U+F0533 |
| `estimate` | U+F051F |
| `sparkline` | U+F07B1 |
| `power_source` | U+F06A5 |

`@battery_revamped_fixed_width` set to `on` pads the charge on the left to its natural width, four characters, so a change from `9%` to `42%` does not shift the rest of the line. `@battery_revamped_<metric>_width` sets one metric's width and wins over the fixed width. A longer value is never cut.

### Around the charge

`@battery_revamped_before` and `@battery_revamped_after` put text around `#{battery_percentage}`, only when it prints. In them `{icon}` becomes the charge icon and `{color}` the colour of the charge tier, with the `#[fg=` wrapper taken off, so `#[fg={color}]{icon} ` colours the icon.

### Render mode

By default each placeholder becomes a `#()` call, which tmux reruns on status redraws. With `@battery_revamped_render` set to `options`, each placeholder becomes an option read such as `#{E:@battery_revamped_out_percentage}`. One background process per server then reads the battery every `@battery_revamped_interval` seconds and writes all values in one tmux call, so they change together.

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

### Notifications

With `@battery_revamped_notify` set to `1`, one desktop notification goes out when the charge enters low, critical or full: `osascript` on macOS and `notify-send` on Linux. Each crossing notifies once. The default is `0`, and the state always shows in the status line and the card.

### Tier colors

The colour options are empty by default, so the colour placeholders print nothing until you set them. These palettes map tiers 1 to 3 to red, 4 to 6 to yellow and 7 and 8 to green:

| Theme | Low | Medium | High |
|:-----|:-----|:-----|:-----|
| Catppuccin Mocha | `#f38ba8` | `#f9e2af` | `#a6e3a1` |
| Dracula | `#ff5555` | `#f1fa8c` | `#50fa7b` |
| Nord | `#bf616a` | `#ebcb8b` | `#a3be8c` |
| Gruvbox Dark | `#fb4934` | `#fabd2f` | `#b8bb26` |
| Tokyo Night | `#f7768e` | `#e0af68` | `#9ece6a` |
| Solarized Dark | `#dc322f` | `#b58900` | `#859900` |

Each value goes in a style, such as `set -g @battery_revamped_charge_tier1_fg_color '#[fg=#f38ba8]'`, for each tier. The states take the same styles under `@battery_revamped_status_<state>_fg_color`.

| Command | What it does |
|:-----|:-----|
| `battery-revamped apply` | Binds the popup key and fills the placeholders now; the entry point runs it when tmux loads the plugin |
| `battery-revamped list` | Prints every command `apply` would send and changes nothing; `--json` prints one object |
| `battery-revamped status NAME` | Prints one placeholder, such as `percentage`, `remain` or `graph`; the status line runs it; a name that is no placeholder prints nothing |
| `battery-revamped refresh` | Reads the battery now and says where it stands |
| `battery-revamped card` | Prints the stored reading, or reads the battery first when nothing is stored, one row per figure |
| `battery-revamped popup` | Opens the card in a tmux popup; the popup key runs it |
| `battery-revamped popup-card` | Prints the card and waits for a key, which is what the popup runs |
| `battery-revamped daemon` | Publishes the placeholders on every tick, for the `options` render mode; `apply` starts it |
| `battery-revamped doctor` | One row per dependency: each tool or file a figure comes from, the popup, the settings, the notifier and any key left alone |
| `battery-revamped version` | The version, then the tmux version |
| `battery-revamped help` | The help page; `man battery-revamped` documents the same commands and settings |
| `battery-revamped` | On a terminal, a menu |

## Configuration

Every option is also a command option with dashes, such as `--interval 2`, and an environment variable, such as `BATTERY_REVAMPED_INTERVAL`; the command line wins over the environment, and the environment over the tmux option. An empty tmux option means its default; a value given as nothing on the command line or in the environment is used as given. `doctor` names any setting that holds a value the plugin does not know. One given to `apply` rides on the popup key and on every status call.

### Reading and alerts

| Option | Default | Meaning |
|:-----|:-----|:-----|
| `@battery_revamped_interval` | `15` | Seconds a charge and state reading stays fresh, or `minute` for the ticker of the options render mode |
| `@battery_revamped_detail_interval` | `60` | Seconds the remaining time, watts, cycles and health stay fresh |
| `@battery_revamped_render` | `jobs` | `options` reads published options instead of running `#()` calls; any other value means `jobs` |
| `@battery_revamped_history_size` | `16` | Readings kept for `#{battery_sparkline}` |
| `@battery_revamped_low_threshold` | `20` | Charge percent treated as low while discharging |
| `@battery_revamped_critical_threshold` | `10` | Charge percent treated as critical while discharging |
| `@battery_revamped_low_icon`, `@battery_revamped_critical_icon` | empty | What `#{battery_alert_icon}` prints at a low and at a critical charge |
| `@battery_revamped_hide_on_ac` | `0` | `1` renders every placeholder empty unless the battery is discharging |
| `@battery_revamped_notify` | `0` | `1` sends a desktop notification when the charge enters low, critical or full |

### Icons and colours

| Option | Default | Meaning |
|:-----|:-----|:-----|
| `@battery_revamped_icons` | `ascii` | `nerd` uses Nerd Font battery glyphs for the eight tiers, with charging variants, and labels every metric; a tier icon option still wins |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` to `█` | Icon of each charge tier, tier 1 is the lowest |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | empty | Colours of each charge tier, such as `#[fg=green]` |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | Icon of each state; `attached` means on AC power and not charging |
| `@battery_revamped_status_{state}_{fg,bg}_color` | empty | Colours of each state |
| `@battery_revamped_source_ac_label`, `@battery_revamped_source_battery_label` | `AC`, `Bat` | Text of `#{battery_power_source}` off and on the battery |
| `@battery_revamped_before`, `@battery_revamped_after` | empty | Text placed around `#{battery_percentage}` only when it prints; `{icon}` becomes the charge icon and `{color}` the colour of the charge tier |

### Formats and labels

| Option | Default | Meaning |
|:-----|:-----|:-----|
| `@battery_revamped_percentage_format` | `%s%%` | printf format for the charge |
| `@battery_revamped_remain_format` | `%s` | printf format for both remaining-time placeholders |
| `@battery_revamped_watts_format` | `%sW` | printf format for the watts |
| `@battery_revamped_cycles_format` | `%s` | printf format for the cycle count |
| `@battery_revamped_health_format` | `%s%%` | printf format for the health |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | printf format for the drain rate |
| `@battery_revamped_graph_width` | `10` | Cells in the charge bar, and the width it is padded to |
| `@battery_revamped_graph_full` | `█` | Filled cell |
| `@battery_revamped_graph_empty` | `░` | Empty cell |
| `@battery_revamped_<metric>_label` | empty | Text printed before one metric's value, only when the value is not empty |
| `@battery_revamped_fixed_width` | `off` | `on` pads the charge on the left to its natural width, four characters |
| `@battery_revamped_<metric>_width` | empty | Pad one metric to this many characters; a longer value is never cut |

A metric that takes a label and a width is `percentage`, `graph`, `remain`, `charging_watts`, `cycles`, `health`, `drain_rate`, `estimate`, `sparkline` or `power_source`.

### Popup

| Option | Default | Meaning |
|:-----|:-----|:-----|
| `@battery_revamped_popup_key` | `M-b` | Prefix key that opens the card popup. `off` binds nothing |
| `@battery_revamped_popup_width` | `44` | Popup width |
| `@battery_revamped_popup_height` | `16` | Popup height |

### Internal state

The plugin writes these options itself. Do not set them.

| Option | Holds |
|:-----|:-----|
| `@battery_revamped_published` | The metrics the status line uses, recorded at load so options mode writes only those |
| `@battery_revamped_out_<metric>` | The rendered value of each metric in options mode |
| `@battery_revamped_ticker_pid` | The process id of the options-mode background process |
| `@battery_revamped_history` | The recent charge readings behind `#{battery_sparkline}` |
| `@battery_revamped_alert_level` | The last level seen, `ok`, `low`, `critical`, `full` or `unknown`, so each notification goes out once per crossing |
| `@battery_revamped_snap_pct`, `@battery_revamped_snap_ts` | The reading the drain rate is measured from |
| `@battery_revamped_percent` and the other figures, `_ts`, `_lock` | The stored reading, the time of each reading and the refresh lock |

## Key bindings

| Key | Action | Default |
|:-----|:-----|:-----|
| `prefix + M-b` | Opens the card of the stored reading in a popup, and any key closes it | Bound |

`@battery_revamped_popup_key` names another key, and `off` binds none. The default key is left alone when something else already holds it, and `battery-revamped doctor` says so.

<a id="How it works"></a>

## How it works

[`battery-revamped.tmux`](battery-revamped.tmux) runs once when tmux loads the plugin. It records which metrics `status-left` and `status-right` use in `@battery_revamped_published`, then replaces each placeholder with a call to [`bin/battery-revamped`](bin/battery-revamped) or, in `options` mode, with an option read and starts the background process.

In the default mode, each `#()` call returns the stored reading at once. When the reading is older than its interval, the call starts a refresh in the background and takes a lock, so only one refresh runs at a time. The remaining time, the watts, the cycle count and the health cost more reads, so they refresh every `@battery_revamped_detail_interval` seconds. One tmux call stores every figure. The drain rate compares the charge with a reading at least five minutes old, and `#{battery_estimate}` divides the charge left by that rate.

Notifications go out once per crossing into low, critical or full, through the shared notifier. The readers, the figures and the formatting live in [`lib/battery.sh`](lib/battery.sh), and the settings table in [`lib/state.sh`](lib/state.sh).

<a id="Screens"></a>

## Screens

<details>
<summary>Every screen, recorded inside a real tmux with <code>make screens</code>, with each key on the status line</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="battery-revamped: The charge with its tier icon and colour, the state, the remaining time and the power source"><br><sub>The charge with its tier icon and colour, the state, the remaining time and the power source, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="battery-revamped: prefix M-b opens the card in a popup"><br><sub><code>prefix M-b</code> opens the card in a popup, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="battery-revamped: @battery_revamped_icons set to nerd draws a glyph per tier and labels every metric"><br><sub><code>@battery_revamped_icons</code> set to <code>nerd</code> draws a glyph per tier and labels every metric, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="battery-revamped: The charge bar, the charge and the sparkline"><br><sub>The charge bar, the charge and the sparkline, from <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="battery-revamped: In the options render mode each placeholder reads a tmux option"><br><sub>In the <code>options</code> render mode each placeholder reads a tmux option, from <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/drain.png" alt="battery-revamped: The drain rate in percent per hour"><br><sub>The drain rate in percent per hour, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/estimate.png" alt="battery-revamped: The estimate, the drain rate and the remaining time"><br><sub>The estimate, the drain rate and the remaining time, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/estimate-label.png" alt="battery-revamped: @battery_revamped_estimate_label puts a word before the estimate"><br><sub><code>@battery_revamped_estimate_label</code> puts a word before the estimate, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/drain-format.png" alt="battery-revamped: @battery_revamped_drain_rate_format shapes the drain rate"><br><sub><code>@battery_revamped_drain_rate_format</code> shapes the drain rate, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/charging.png" alt="battery-revamped: While charging the estimate counts the time to full"><br><sub>While charging the estimate counts the time to full, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/low.png" alt="battery-revamped: The alert icon at a low charge"><br><sub>The alert icon at a low charge, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/thresholds.png" alt="battery-revamped: @battery_revamped_low_threshold moves the low level"><br><sub><code>@battery_revamped_low_threshold</code> moves the low level, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/critical.png" alt="battery-revamped: The alert icon at a critical charge"><br><sub>The alert icon at a critical charge, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/critical-threshold.png" alt="battery-revamped: @battery_revamped_critical_threshold moves the critical level"><br><sub><code>@battery_revamped_critical_threshold</code> moves the critical level, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/alert-icons.png" alt="battery-revamped: @battery_revamped_low_icon and @battery_revamped_critical_icon name the alert glyphs"><br><sub><code>@battery_revamped_low_icon</code> and <code>@battery_revamped_critical_icon</code> name the alert glyphs, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-charged.png" alt="battery-revamped: The charged state"><br><sub>The charged state, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/state-attached.png" alt="battery-revamped: The attached state, on AC power and not charging"><br><sub>The attached state, on AC power and not charging, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-unknown.png" alt="battery-revamped: The unknown state"><br><sub>The unknown state, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status-icons.png" alt="battery-revamped: @battery_revamped_status_<state>_icon and its colour"><br><sub><code>@battery_revamped_status_<state>_icon</code> and its colour, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-colors.png" alt="battery-revamped: #{battery_color_status_fg} and #{battery_color_status_bg}"><br><sub><code>#{battery_color_status_fg}</code> and <code>#{battery_color_status_bg}</code>, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="battery-revamped: @battery_revamped_charge_tier7_icon and its colours"><br><sub><code>@battery_revamped_charge_tier7_icon</code> and its colours, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/format.png" alt="battery-revamped: @battery_revamped_percentage_format shapes the charge"><br><sub><code>@battery_revamped_percentage_format</code> shapes the charge, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/remain-format.png" alt="battery-revamped: @battery_revamped_remain_format shapes the remaining time"><br><sub><code>@battery_revamped_remain_format</code> shapes the remaining time, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/details.png" alt="battery-revamped: The watts, the cycle count and the health"><br><sub>The watts, the cycle count and the health, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/detail-formats.png" alt="battery-revamped: @battery_revamped_watts_format, _cycles_format and _health_format"><br><sub><code>@battery_revamped_watts_format</code>, <code>_cycles_format</code> and <code>_health_format</code>, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/detail-interval.png" alt="battery-revamped: @battery_revamped_detail_interval sets how often the details are read"><br><sub><code>@battery_revamped_detail_interval</code> sets how often the details are read, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="battery-revamped: @battery_revamped_fixed_width pads the charge to its natural width"><br><sub><code>@battery_revamped_fixed_width</code> pads the charge to its natural width, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/width.png" alt="battery-revamped: @battery_revamped_percentage_width pads one metric to its own width"><br><sub><code>@battery_revamped_percentage_width</code> pads one metric to its own width, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="battery-revamped: A label of its own before the charge"><br><sub>A label of its own before the charge, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/label-health.png" alt="battery-revamped: A label of its own before the health"><br><sub>A label of its own before the health, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/graph-width.png" alt="battery-revamped: @battery_revamped_graph_width, _graph_full and _graph_empty shape the bar"><br><sub><code>@battery_revamped_graph_width</code>, <code>_graph_full</code> and <code>_graph_empty</code> shape the bar, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/power-source.png" alt="battery-revamped: @battery_revamped_source_battery_label and _source_ac_label"><br><sub><code>@battery_revamped_source_battery_label</code> and <code>_source_ac_label</code>, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/power-source-ac.png" alt="battery-revamped: The power source label while charging"><br><sub>The power source label while charging, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/hide-on-ac.png" alt="battery-revamped: @battery_revamped_hide_on_ac empties every placeholder off the battery"><br><sub><code>@battery_revamped_hide_on_ac</code> empties every placeholder off the battery, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/before-after.png" alt="battery-revamped: @battery_revamped_before and _after with {icon} and {color}"><br><sub><code>@battery_revamped_before</code> and <code>_after</code> with <code>{icon}</code> and <code>{color}</code>, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/notify.png" alt="battery-revamped: @battery_revamped_notify sends one notification per crossing, shown here from the stand-in notifier"><br><sub><code>@battery_revamped_notify</code> sends one notification per crossing, shown here from the stand-in notifier, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-size.png" alt="battery-revamped: @battery_revamped_popup_width and _popup_height size the popup"><br><sub><code>@battery_revamped_popup_width</code> and <code>_popup_height</code> size the popup, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="battery-revamped: @battery_revamped_popup_key names another key for the popup"><br><sub><code>@battery_revamped_popup_key</code> names another key for the popup, from <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/interval.png" alt="battery-revamped: @battery_revamped_interval sets how long a reading stays fresh"><br><sub><code>@battery_revamped_interval</code> sets how long a reading stays fresh, from <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="battery-revamped: The version"><br><sub>The version, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="battery-revamped: An unknown command"><br><sub>An unknown command, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="battery-revamped: status percentage and status graph print one placeholder each"><br><sub><code>status percentage</code> and <code>status graph</code> print one placeholder each, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="battery-revamped: refresh reads the battery now"><br><sub><code>refresh</code> reads the battery now, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="battery-revamped: card prints every figure"><br><sub><code>card</code> prints every figure, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="battery-revamped: list prints every binding"><br><sub><code>list</code> prints every binding, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="battery-revamped: list --json prints the same plan as one object"><br><sub><code>list --json</code> prints the same plan as one object, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="battery-revamped: doctor"><br><sub><code>doctor</code>, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="battery-revamped: The menu"><br><sub>The menu, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="battery-revamped: The card from the menu"><br><sub>The card from the menu, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="battery-revamped: An accent from BATTERY_REVAMPED_ACCENT"><br><sub>An accent from <code>BATTERY_REVAMPED_ACCENT</code>, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="battery-revamped: The menu without gum"><br><sub>The menu without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="battery-revamped: doctor from the menu, without gum"><br><sub><code>doctor</code> from the menu, without gum, from <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="battery-revamped: card without gum"><br><sub><code>card</code> without gum, from <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="battery-revamped: The header in six themes"><br><sub>The header in six themes, from <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="battery-revamped: The help page"><br><sub>The help page, from <code>help.tape</code></sub></td>
</tr>
</table>

The recordings run the real plugin and tmux. Small scripts stand in for `pmset`, `system_profiler`, `ioreg` and `osascript`, so the figures on screen are theirs, and the battery holds one state unless a recording changes it.

</details>

## Portability

The plugin is POSIX `sh`. CI runs every suite on each row below.

| Shell | Status |
|:-----|:-----|
| `dash`, `/bin/sh` on macOS | Supported |
| `bash` 3.2 and 5.x, the system's `zsh` and Homebrew's | Supported |

| System | Status |
|:-----|:-----|
| macOS | Tahoe on Apple Silicon and Intel, with the tools it ships, Homebrew's GNU tools and Homebrew's uutils |
| Linux | Ubuntu 26.04 on x86_64 and arm64, with GNU coreutils, uutils and BusyBox |

## Development

| Command | What it runs |
|:-----|:-----|
| `make fmt` | shfmt `-i 2` on every script |
| `make lint` | shfmt, ShellCheck, mandoc, yamllint and actionlint, at zero findings |
| `make test` | The bats suites under the system `sh` |
| `make test-all` | The suites under every installed shell, both builds of bash and zsh on macOS |
| `make test-linux` | The suites in an Ubuntu container |
| `make coverage` | bashcov on this Mac and in the Ubuntu container, merged and gated at 100 percent |
| `make screens` | The screens above, recorded from the real plugin inside tmux with VHS, on macOS |
| `make install` | The command, its man page and completions under `PREFIX` |

On macOS, `brew bundle` installs every tool these targets call, from the [`Brewfile`](Brewfile).

Commits follow the conventional commit format and go straight to `main`. After a green `ci` run on `main`, `release.yml` runs semantic-release: every `feat` or `fix` since the last tag publishes a release, stamps the version constant and adds the notes to [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE), copyright Gustavo Franco.

<!-- family:begin -->

## The tmux-revamped family

This plugin is one member of the tmux-revamped family. Every member carries the same contract in [`FAMILY.md`](FAMILY.md) and the same shared library, and they are built to be installed together: no member claims a key or a tmux option that another member claims.

A defect found in one member is hunted across all of them before the fix is called done.

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
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | Open any terminal app in a tmux popup, window or split from one menu, starting at the project root |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | Capture any pane to a file: live logging, full scrollback, or a one-shot screenshot |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | Now playing in your tmux status bar, without ever blocking the status render |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | Network throughput in your tmux status bar, without ever blocking the render |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | Pane and window management bindings for tmux, version aware, vim friendly, every prefix key can be disabled |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | Save every tmux session, window and pane, auto-save on a timer, and restore it all after a reboot |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | The starting point for a tmux-revamped plugin: shared library, bats harness and CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | A Pomodoro timer in the tmux status bar that keeps all of its state in tmux options, with no temp files |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM, swap and memory pressure in the tmux status bar, sampled in the background so the render never waits |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | Drag a window tab along the tmux status bar with the mouse to move that window |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | Send the mouse wheel to apps that scroll themselves and into tmux copy-mode everywhere else |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | Sensible tmux defaults, gated by tmux version and terminal, that leave the options you set alone |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | Tiling window management for tmux: eight layouts including BSP dwindle and spiral, with layout undo |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | Local and world clocks for the tmux status bar, colored by time of day, with countdowns and a DST warning |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | Weather for the tmux status bar from wttr.in, fetched in the background so the status line never waits |

<!-- family:end -->

