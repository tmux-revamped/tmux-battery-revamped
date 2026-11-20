# shellcheck shell=bash
# shellcheck disable=SC2207

_battery_revamped() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case "${prev}" in
  --theme)
    COMPREPLY=($(compgen -W "kodougu catppuccin-mocha catppuccin-latte dracula nord gruvbox tokyo-night mono" -- "${cur}"))
    return
    ;;
  status)
    COMPREPLY=($(compgen -W "percentage icon icon_charge icon_status color_fg color_bg color_charge_fg color_charge_bg color_status_fg color_status_bg graph remain charging_watts cycles health drain_rate estimate sparkline power_source alert_icon" -- "${cur}"))
    return
    ;;
  --render)
    COMPREPLY=($(compgen -W "jobs options" -- "${cur}"))
    return
    ;;
  --icons)
    COMPREPLY=($(compgen -W "ascii nerd" -- "${cur}"))
    return
    ;;
  --hide-on-ac)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --fixed-width)
    COMPREPLY=($(compgen -W "on off" -- "${cur}"))
    return
    ;;
  --notify)
    COMPREPLY=($(compgen -W "0 1" -- "${cur}"))
    return
    ;;
  --popup-key | --popup-width | --popup-height | --interval | --detail-interval | --percentage-format | --graph-width | --graph-full | --graph-empty | --remain-format | --watts-format | --cycles-format | --health-format | --drain-rate-format | --history-size | --low-threshold | --critical-threshold | --low-icon | --critical-icon | --source-ac-label | --source-battery-label | --before | --after | --charge-tier1-icon | --charge-tier2-icon | --charge-tier3-icon | --charge-tier4-icon | --charge-tier5-icon | --charge-tier6-icon | --charge-tier7-icon | --charge-tier8-icon | --charge-tier1-fg-color | --charge-tier1-bg-color | --charge-tier2-fg-color | --charge-tier2-bg-color | --charge-tier3-fg-color | --charge-tier3-bg-color | --charge-tier4-fg-color | --charge-tier4-bg-color | --charge-tier5-fg-color | --charge-tier5-bg-color | --charge-tier6-fg-color | --charge-tier6-bg-color | --charge-tier7-fg-color | --charge-tier7-bg-color | --charge-tier8-fg-color | --charge-tier8-bg-color | --status-charged-icon | --status-charging-icon | --status-discharging-icon | --status-attached-icon | --status-unknown-icon | --status-charged-fg-color | --status-charged-bg-color | --status-charging-fg-color | --status-charging-bg-color | --status-discharging-fg-color | --status-discharging-bg-color | --status-attached-fg-color | --status-attached-bg-color | --status-unknown-fg-color | --status-unknown-bg-color | --percentage-label | --graph-label | --remain-label | --charging-watts-label | --cycles-label | --health-label | --drain-rate-label | --estimate-label | --sparkline-label | --power-source-label | --percentage-width | --remain-width | --charging-watts-width | --cycles-width | --health-width | --drain-rate-width | --estimate-width | --sparkline-width | --power-source-width)
    return
    ;;
  *) ;;
  esac

  COMPREPLY=($(compgen -W "apply list status refresh card popup popup-card daemon doctor version help --json --theme --popup-key --popup-width --popup-height --interval --detail-interval --render --percentage-format --icons --graph-width --graph-full --graph-empty --remain-format --watts-format --cycles-format --health-format --drain-rate-format --history-size --low-threshold --critical-threshold --low-icon --critical-icon --source-ac-label --source-battery-label --hide-on-ac --before --after --fixed-width --notify --charge-tier1-icon --charge-tier2-icon --charge-tier3-icon --charge-tier4-icon --charge-tier5-icon --charge-tier6-icon --charge-tier7-icon --charge-tier8-icon --charge-tier1-fg-color --charge-tier1-bg-color --charge-tier2-fg-color --charge-tier2-bg-color --charge-tier3-fg-color --charge-tier3-bg-color --charge-tier4-fg-color --charge-tier4-bg-color --charge-tier5-fg-color --charge-tier5-bg-color --charge-tier6-fg-color --charge-tier6-bg-color --charge-tier7-fg-color --charge-tier7-bg-color --charge-tier8-fg-color --charge-tier8-bg-color --status-charged-icon --status-charging-icon --status-discharging-icon --status-attached-icon --status-unknown-icon --status-charged-fg-color --status-charged-bg-color --status-charging-fg-color --status-charging-bg-color --status-discharging-fg-color --status-discharging-bg-color --status-attached-fg-color --status-attached-bg-color --status-unknown-fg-color --status-unknown-bg-color --percentage-label --graph-label --remain-label --charging-watts-label --cycles-label --health-label --drain-rate-label --estimate-label --sparkline-label --power-source-label --percentage-width --remain-width --charging-watts-width --cycles-width --health-width --drain-rate-width --estimate-width --sparkline-width --power-source-width" -- "${cur}"))
}

complete -F _battery_revamped battery-revamped
