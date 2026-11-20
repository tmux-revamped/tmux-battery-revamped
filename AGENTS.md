# tmux-battery-revamped

Guidance for anyone, human or agent, changing tmux-battery-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-battery-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`battery-revamped.tmux`](battery-revamped.tmux) | The entry point TPM runs: it runs `bin/battery-revamped apply` |
| [`bin/battery-revamped`](bin/battery-revamped) | The command: `apply`, `list`, `status`, `refresh`, `card`, `popup`, `popup-card`, `daemon`, `doctor`, `version`, `help` and the menu. `apply`, `status`, `popup` and `daemon` run without loading the interface modules |
| [`lib/battery.sh`](lib/battery.sh) | Reading the settings and the stored reading, the readers for both systems, the drain rate, the history, the alerts, the placeholders with their labels and widths, the publisher's tick, the popup and the binding |
| [`lib/state.sh`](lib/state.sh) | Every global, including `BATTERY_REVAMPED_SETTINGS`, the table of setting names and defaults, `BATTERY_REVAMPED_LIVE`, the names of the options that hold the reading, and `BATTERY_REVAMPED_KINDS` |
| [`lib/core.sh`](lib/core.sh) | The version |
| [`lib/`](lib) | Every other file is the shared library, identical in every member |
| [`test/readers.bats`](test/readers.bats), [`test/battery.bats`](test/battery.bats), [`test/plan.bats`](test/plan.bats), [`test/commands.bats`](test/commands.bats) | The readers on both systems with stand-ins for `pmset`, `system_profiler`, `ioreg`, `acpi`, `osascript` and `notify-send` and fixture folders for `/sys/class/power_supply`, every placeholder with its labels and widths, the drain rate, the history, the alerts and notifications, the binding with both render modes, the daemon and the popup, and every command, against a stand-in tmux from [`test/battery_helpers.bash`](test/battery_helpers.bash) that keeps options in a file |
| [`test/entrypoint.bats`](test/entrypoint.bats), [`test/keys.bats`](test/keys.bats) | The plugin on a private tmux server, with the popup key pressed through a second tmux attached to it, in both render modes; both share [`test/server_helpers.bash`](test/server_helpers.bash), whose stand-ins give the same figures on macOS and Linux |
| [`test/cli.bats`](test/cli.bats), [`test/golden.bats`](test/golden.bats), [`test/install.bats`](test/install.bats), [`test/core.bats`](test/core.bats), [`test/set-version.bats`](test/set-version.bats) | The interface, the golden transcripts in [`test/golden/`](test/golden), the install target with the completions, the version constant and the version script |
| [`screens/`](screens) | The tapes and the recording's tmux config. `prepare.sh` copies the plugin to a neutral folder and writes stand-ins for `pmset`, `system_profiler`, `ioreg` and `osascript`, plus a `state` command that sets the one state the stand-in `pmset` reports |
| [`examples/`](examples) | A status line to copy |

## Names

- Settings are the tmux options `@battery_revamped_<setting>` listed in `BATTERY_REVAMPED_SETTINGS`, the long options with dashes, such as `--drain-rate-format`, and the environment variables `BATTERY_REVAMPED_<SETTING>`. `@battery_revamped_graph_width` is both the number of cells of the bar and the width the graph is padded to.
- The stored reading is `@battery_revamped_percent`, `_status`, `_remain`, `_watts`, `_cycles`, `_health`, `_drain_rate`, `_history`, `_alert_level`, `_snap_pct` and `_snap_ts`, with `_percent_ts`, `_detail_ts`, `_percent_lock` and `_percent_lock_ts`. `apply` writes `@battery_revamped_published`, the daemon `@battery_revamped_out_<name>` and `@battery_revamped_ticker_pid`. None of them is a setting.
- The placeholders are `#{battery_percentage}`, `#{battery_icon}`, `#{battery_icon_charge}`, `#{battery_icon_status}`, `#{battery_color_fg}`, `#{battery_color_bg}`, `#{battery_color_charge_fg}`, `#{battery_color_charge_bg}`, `#{battery_color_status_fg}`, `#{battery_color_status_bg}`, `#{battery_graph}`, `#{battery_remain}`, `#{battery_charging_watts}`, `#{battery_cycles}`, `#{battery_health}`, `#{battery_drain_rate}`, `#{battery_estimate}`, `#{battery_sparkline}`, `#{battery_power_source}` and `#{battery_alert_icon}`; `status` names each one without the `battery_`.
- The version constant is `BATTERY_REVAMPED_VERSION`.
- The command's own functions and the library's never share a name, because the command is sourced after the library and would replace it.
- `REVAMPED_TEST_SYS` is a test switch that moves the folder the sysfs reader globs from `/sys`.

## Behaviour

- `apply` reads every setting and the stored reading with one `tmux display-message` call and one `env` read, reads the prefix table once, and sends the binding and the replaced status strings in one tmux call. When that call fails, it sends each command alone and `apply` exits 1.
- In `jobs` mode each placeholder in `status-left` or `status-right` becomes `#(<tool> status <name>)`, with the tool's path and every carried value quoted for a shell and every `#` and `%` doubled, since tmux reads the status line as a format and as a time format. In `options` mode it becomes `#{E:@battery_revamped_out_<name>}`, `apply` starts the daemon, and a status refresh starts no process. A render mode other than `options` means `jobs`. A string already rewritten is not written again, and the names it uses stay in `@battery_revamped_published`, so loading twice changes nothing.
- `status` makes one tmux read and one `date` call, and prints the stored reading at once. Only when the reading is older than `@battery_revamped_interval` and no reading is under way does it start one in the background through the shared cache module. A name that is no placeholder prints nothing and exits 0, as the bash dispatcher did; a missing name is a usage error.
- A reading stores the charge and the state every time, and the remaining time, the watts, the cycles and the health only when `@battery_revamped_detail_interval` seconds have passed since they were last read. It then updates the drain rate, the sparkline history and the alert level, and everything is written in one tmux call.
- The daemon is the shared ticker: it claims `@battery_revamped_ticker_pid`, reads and publishes every name in `@battery_revamped_published` in one tmux call per tick, sleeps for the interval, and ends when another process holds the claim or the server is gone. At the ticker's tick cap it starts itself again.
- `M-b` opens the popup of `@battery_revamped_popup_width` by `@battery_revamped_popup_height`, running `popup-card`, which prints the card of the stored reading, reading the battery first when nothing is stored, then waits for one key. A tmux older than 3.2 gets a message that says so. `popup` returns 0 whatever the popup returns.
- A key set to `off` binds nothing. Only the default key is skipped when someone else holds it, and `doctor` names it; a key the person names is bound whoever holds it.
- A setting `apply` got from the command line or the environment rides, as an option, on the popup key, on the popup's command and on every status call; `BATTERY_REVAMPED_CARRIED` lists the ones that ride. The daemon inherits the environment of the `apply` that started it.
- A tmux option set to nothing means its default, as FAMILY.md says. The bash version kept it empty when its default was not empty, so an empty `@battery_revamped_percentage_format`, label, icon or graph cell used to print nothing; give that empty value on the command line or in the environment now, where it is used as given.

## Domain rules

- Linux reads the first `/sys/class/power_supply/BAT*` that has a readable `capacity`, then `acpi`; macOS reads `pmset`, `system_profiler` and `ioreg`; any other system takes the Linux way for the charge, the state and the remaining time, and reads no watts, cycles or health. The README's source table names each value's source per platform, and a new source goes into that table and into `doctor` in the same change.
- The charge is the first percent of `pmset -g batt`, the `capacity` file, or the first percent of the first `acpi -b` line; a `capacity` that is not a whole number reads no battery and does not fall back to `acpi`. The state is the lower-cased second field of the `pmset` line with the percent, the `status` file, or the first `acpi` line: `not charging` and the `pending` states are `attached`, then `discharging`, `charging`, `charged` or `full`, and anything else is `unknown`.
- The remaining time is the first `H:MM` of `pmset`, then of the first `acpi` line, then computed on Linux from `energy_now` or `charge_now` over `power_now` or `current_now` while discharging, or from the gap to `energy_full` or `charge_full` while charging; a zero rate, a missing counter or another state leaves it empty. The watts are `power_now` over a million on Linux and the first number of the `Wattage` line of `system_profiler` on macOS. The cycle count is `cycle_count` or `CycleCount`. The health is `energy_full` over `energy_full_design`, else the `charge_*` pair, or `AppleRawMaxCapacity`, else `MaxCapacity`, over `DesignCapacity`, as a whole percent capped at 100.
- The drain rate compares the charge with the one stored at least five minutes ago, or at a later clock time, and is the drop in percent per hour with one decimal; two readings in one second keep the previous rate. `#{battery_estimate}` is the charge over a positive rate while discharging and the charge missing over a negative rate while charging, as `H:MM` rounded to the minute.
- The tier is the charge times eight over a hundred rounded up, from 1 to 8, and a charge that is no number is tier 1. The alert level is `critical` at or under `@battery_revamped_critical_threshold` and `low` at or under `@battery_revamped_low_threshold` while discharging, `full` when charged or at 100 while charging, `ok` otherwise and `unknown` without a charge; a threshold that is no number means 10 or 20.
- The history keeps the newest `@battery_revamped_history_size` charges, comma separated, with 16 for zero or junk; the sparkline draws one of eight blocks per charge at the charge times seven over a hundred.
- Notifications fire once per crossing into low, critical or full, through the shared notifier behind `@battery_revamped_notify`, off by default. The level is stored on every reading, so a notification fires again only after the level changed.
- The label, the width and the padding follow the bash rules: a value is wrapped by `before` and `after` first, then padded to its own width or, with `@battery_revamped_fixed_width` at `on`, to four characters for the charge, then labelled; the graph pads to `@battery_revamped_graph_width`; width counts characters and a longer value is never cut. `@battery_revamped_hide_on_ac` at `1` empties every placeholder unless the state is `discharging`.
- A value the host has no source for renders empty.
- An icon, a label or a text set to `off` prints nothing, and a label set to `off` also drops the `nerd` glyph.

## Release

- `BATTERY_REVAMPED_VERSION` in [`lib/core.sh`](lib/core.sh) holds the version. Nobody edits it by hand.
- After a green `ci` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release: a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-20:

- The screens are written and not recorded: `screens/hero.gif` and every still the README names do not exist until `make screens` runs on macOS.
- Coverage has not been measured: bashcov was not run for this rewrite, so the 100 percent gate on macOS and Linux is unverified.
- Only `make test` under the system `sh` and `make lint` ran for this rewrite. The shell matrix, `make test-linux` and the six toolsets have not run.
- The Linux readers are tested against fixture folders and stand-ins, not against Linux hardware, and the macOS readers against one Mac.
- The popup default height is 16, where the bash version used 12, because the card drawn with gum has a header and a border; the popup card shows the seven figures of the old card.
