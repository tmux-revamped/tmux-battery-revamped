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
| [`src/lib/utils/`](src/lib/utils), [`src/lib/tmux/`](src/lib/tmux) | The shared library. Every file there except `constants.sh` is owned by the family |
| [`test/`](test) | The bats suite. `helpers.bash` and `tmux_helpers.bash` are owned; this member's own mocks go in the `_local` files |
| [`family/`](family) | The family tooling, owned |

## Names

- Settings are tmux options named `@battery_revamped_<setting>`.
- Placeholders include `#{battery_percentage}`.
- Public functions carry `battery_`; private ones start with `_`.
- The version constant is `BATTERY_REVAMPED_VERSION`.
- Its command-line tool, once it exists, is `battery-revamped`.

## Behaviour

- Shows battery charge, state, remaining time, watts, cycle count and health in the status line, without blocking the render.
- `M-b` opens the detail popup.
- By default each placeholder becomes a `#()` call that prints the cached value at once; a value older than `@battery_revamped_interval` also starts one background refresh, guarded by a lock so parallel calls start no second one. With `@battery_revamped_render` set to `options`, each placeholder becomes an option read such as `#{E:@battery_revamped_out_percentage}`, and one background process per server writes every value in a single tmux call, then exits when the server stops or a config reload starts a newer one.

## Domain rules

- Linux reads the first `/sys/class/power_supply/BAT*`, then `acpi`; macOS reads `pmset`, `system_profiler` and `ioreg`. The README's source table names each value's source per platform, and a new source goes into that table and into `doctor` in the same change.
- The drain rate compares the current charge with a reading at least five minutes old, and `#{battery_estimate}` divides the charge left by that rate.
- Notifications fire once per crossing into low, critical or full, through the shared notifier behind `@battery_revamped_notify`, off by default.
- A value the host has no source for renders empty.

## Release

- `BATTERY_REVAMPED_VERSION` in [`src/lib/utils/constants.sh`](src/lib/utils/constants.sh) holds the version. It must equal the newest versioned heading in [`CHANGELOG.md`](CHANGELOG.md) and the README's version badge, which the `version` job in `tests.yml` checks.
- A push to `main` whose version has no tag yet makes the `release` job in `tests.yml` tag `vX.Y.Z` and publish a GitHub release with that changelog section.
- Unreleased changes sit under `## [Unreleased]` in [`CHANGELOG.md`](CHANGELOG.md) until a release is cut.

## Gaps against FAMILY.md

As of 2026-11-15:

- Every script is bash, under `#!/usr/bin/env bash`, not POSIX `sh`, so it is untested under `dash`, `zsh` and BusyBox `sh`.
- The code lives in [`src/`](src) and [`src/lib/`](src/lib); there is no `bin/battery-revamped`, `lib/state.sh` or `lib/core.sh`.
- No `battery-revamped` command with `help`, `version` and `doctor` in the family's form, no man page, no completions and no `manifest.json`.
- No gum interface: no `lib/ui.sh`, `lib/table.awk`, themes or `test/bin/gum`.
- No `screens/` and no recordings in the README.
- The README sections are not the family's order of Quick start, Usage, topic sections, Portability, Development and License.
- Coverage is kcov with a 95 percent floor on Linux, not bashcov at 100 percent merged from macOS and Linux.
- CI tests GNU, BSD and uutils tools in `tests.yml`, but not the six toolsets through `.github/scripts/toolset.sh`, and no shell matrix under `sh`, `dash`, `bash` and `zsh`.
- No golden transcripts, `call.sh`, `run-matrix.sh` or `linux-container.sh`.
- The version is written by hand and released by `tests.yml`; there is no semantic-release, `package.json`, `release.yml` with `recover`, `bot-merge.yml` or Renovate.
- CI is `tests.yml`, `family.yml` and `security.yml`, not `ci.yml`, and no job starts with `step-security/harden-runner`.
- The pull request template, `labeler.yml`, `pr.yml` and `stale.yml` are still present.
- No `.editorconfig`, `.yamllint.yml`, `scripts/check-names.sh` or shfmt; the Makefile has `help`, `test`, `test-unit`, `coverage`, `lint` and `clean`, not the family's targets.
