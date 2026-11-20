#!/bin/sh

battery_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${battery_revamped_dir}/bin/battery-revamped" apply
