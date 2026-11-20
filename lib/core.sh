#!/bin/sh
# shellcheck disable=SC2034

[ -n "${BATTERY_REVAMPED_CORE_LOADED:-}" ] && return 0
BATTERY_REVAMPED_CORE_LOADED=1

readonly BATTERY_REVAMPED_VERSION="2.0.0"
