# tmux-battery-revamped

Guidance for anyone, human or agent, changing tmux-battery-revamped. What it is and how to use it lives in [README.md](README.md).

[FAMILY.md](FAMILY.md) holds everything this plugin shares with the rest of the tmux-revamped family, and it is the same in every member. This file holds only what is exclusive to tmux-battery-revamped, under the same headings as the agent guide of every member. Read both before changing anything; a rule that would serve the other members goes into [`FAMILY.md`](FAMILY.md) instead of here.

## Layout

| Path | Holds |
|:-----|:------|
| [`battery-revamped.tmux`](battery-revamped.tmux) | The entry point TPM runs |
| [`src/battery.sh`](src/battery.sh) | The script the placeholders, keys and popups call |
| [`src/lib/battery/`](src/lib/battery) | This member's modules |
| [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) | This member's constants, including its version |
| [`src/lib/utils/`](src/lib/utils), [`src/lib/tmux/`](src/lib/tmux) | The shared library. Every file there except `constants.sh` is identical in every member |
| [`test/`](test) | The bats suite. `helpers.bash` and `tmux_helpers.bash` are identical in every member; this member's own mocks go in the `_local` files. [`test/entry/keys.bats`](test/entry/keys.bats) presses the popup key through a second tmux attached to a private server, with stand-ins for `pmset` and `acpi` |

## Names

- Settings are tmux options named `@battery_revamped_<setting>`.
- Placeholders include `#{battery_percentage}`.
- Public functions carry `battery_`; private ones start with `_`.
- The version constant is `BATTERY_REVAMPED_VERSION`.
- Its command-line tool, once it exists, is `battery-revamped`.

## Behaviour

- Shows battery charge, state, remaining time, watts, cycle count and health in the status line, without blocking the render.
- `M-b` opens the detail popup, a card of the cached reading; with nothing cached yet the card reads the battery first, and on a machine without a battery it says so.
- By default each placeholder becomes a `#()` call that prints the cached value at once; a value older than `@battery_revamped_interval` also starts one background refresh, guarded by a lock so parallel calls start no second one. With `@battery_revamped_render` set to `options`, each placeholder becomes an option read such as `#{E:@battery_revamped_out_percentage}`, and one background process per server writes every value in a single tmux call, then exits when the server stops or a config reload starts a newer one.

## Domain rules

- Linux reads the first `/sys/class/power_supply/BAT*`, then `acpi`; macOS reads `pmset`, `system_profiler` and `ioreg`. The README's source table names each value's source per platform, and a new source goes into that table and into `doctor` in the same change.
- The drain rate compares the current charge with a reading at least five minutes old, and `#{battery_estimate}` divides the charge left by that rate.
- Notifications fire once per crossing into low, critical or full, through the shared notifier behind `@battery_revamped_notify`, off by default.
- A value the host has no source for renders empty.

## Release

- `BATTERY_REVAMPED_VERSION` in [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) holds the version. Nobody edits it by hand.
- After a green `Tests` run on `main`, [`release.yml`](.github/workflows/release.yml) runs semantic-release from [`.releaserc.json`](.releaserc.json): a `feat` or `fix` since the last tag publishes a release, [`set-version.sh`](.github/scripts/set-version.sh) stamps the constant, and the notes go into [`CHANGELOG.md`](CHANGELOG.md).

## Gaps against FAMILY.md

As of 2026-11-17:

- Every script is bash, under `#!/usr/bin/env bash`, not POSIX `sh`, so it is untested under `dash`, `zsh` and BusyBox `sh`.
- The code lives in [`src/`](src) and [`src/lib/`](src/lib); there is no `bin/battery-revamped`, `lib/state.sh` or `lib/core.sh`.
- No `battery-revamped` command with `help`, `version` and `doctor` in the family's form, no man page, no completions and no `manifest.json`.
- No gum interface: no `lib/ui.sh`, `lib/table.awk`, themes or `test/bin/gum`.
- No `screens/`: no VHS recording of each feature, no on-screen caption of the keys each recording presses, and no recordings in the README.
- The README sections are not the family's order of Quick start, Usage, topic sections, Portability, Development and License.
- Coverage is kcov with a 95 percent floor on Linux, not bashcov at 100 percent merged from macOS and Linux.
- CI tests GNU, BSD and uutils tools in `tests.yml`, but not the six toolsets through `.github/scripts/toolset.sh`, and no shell matrix under `sh`, `dash`, `bash` and `zsh`.
- No golden transcripts, `call.sh`, `run-matrix.sh` or `linux-container.sh`.
- [`release.yml`](.github/workflows/release.yml) follows `Tests` and has no `recover` job, and [`.releaserc.json`](.releaserc.json) and `set-version.sh` name `src/lib/utils/constants.sh`, so the three differ from the family's copies; there is no `ci-state.sh`, `recover.sh`, `bot-merge.yml` or Renovate.
- CI is `tests.yml` and `security.yml`, not `ci.yml`, and no job starts with `step-security/harden-runner`.
- No `.editorconfig`, `.yamllint.yml` or shfmt; the Makefile has `help`, `test`, `test-unit`, `coverage`, `lint` and `clean`, not the family's targets.
- `get_tmux_option` keeps a tmux option set to nothing as an empty value, where FAMILY.md has it mean the default; the ticker's own reader already takes the default.
