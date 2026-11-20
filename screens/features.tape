Source common.tape
Output scratch.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 3500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_drain_rate 25.0"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_drain_rate '25.0'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot drain.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_percentage} #{battery_drain_rate} #{battery_estimate} #{battery_remain}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_percentage} #{battery_drain_rate} #{battery_estimate} #{battery_remain}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_drain_rate 25.0"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_drain_rate '25.0'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot estimate.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_estimate_label left"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_estimate_label 'left'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot estimate-label.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_drain_rate_format %s per hour"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_drain_rate_format '%s per hour'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_drain_rate 25.0"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_drain_rate '25.0'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot drain-format.png
Sleep 1s
Hide
Type "state 40 charging 1:05"
Enter
Sleep 2500ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_drain_rate -20.0"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_drain_rate '-20.0'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot charging.png
Sleep 1s
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 2500ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Type "state 18 discharging 0:41"
Enter
Sleep 3500ms
Show
Screenshot low.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_low_threshold 50"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_low_threshold '50'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot thresholds.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_low_threshold 20"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_low_threshold '20'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Type "state 8 discharging 0:17"
Enter
Sleep 3500ms
Show
Screenshot critical.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_critical_threshold 30"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_critical_threshold '30'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot critical-threshold.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_critical_threshold 10"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_critical_threshold '10'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_low_icon LOW!"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_low_icon 'LOW!'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_critical_icon CRIT!"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_critical_icon 'CRIT!'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot alert-icons.png
Sleep 1s
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 2500ms
Show
Hide
Type "state 100 charged 0:00"
Enter
Sleep 3500ms
Show
Screenshot state-charged.png
Sleep 1s
Hide
Type "state 80 attached 0:00"
Enter
Sleep 3500ms
Show
Screenshot state-attached.png
Sleep 1s
Hide
Type "state 50 unknown 0:00"
Enter
Sleep 3500ms
Show
Screenshot state-unknown.png
Sleep 1s
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 2500ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_status_discharging_icon DIS"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_status_discharging_icon 'DIS'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_status_discharging_fg_color pink"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_status_discharging_fg_color '#[fg=#ff00aa]'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot status-icons.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_status_discharging_bg_color navy"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_status_discharging_bg_color '#[bg=#003366]'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_color_status_bg}#{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_percentage}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_color_status_bg}#{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_percentage}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Screenshot status-colors.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_charge_tier7_icon SEVEN"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_charge_tier7_icon 'SEVEN'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_charge_tier7_fg_color orange"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_charge_tier7_fg_color '#[fg=#ff8800]'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_charge_tier7_bg_color navy"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_charge_tier7_bg_color '#[bg=#003366]'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_color_charge_bg}#{battery_color_charge_fg}#{battery_icon_charge}#[default] #{battery_percentage}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_color_charge_bg}#{battery_color_charge_fg}#{battery_icon_charge}#[default] #{battery_percentage}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Screenshot tiers.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_color_status_fg}#{battery_icon_status}#[default] #{battery_color_charge_fg}#{battery_icon} #{battery_percentage}#[default] #{battery_remain} #{battery_power_source} #{battery_alert_icon}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_percentage_format charge %s"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_percentage_format 'charge %s'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot format.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_remain_format %s left"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_remain_format '%s left'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot remain-format.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_percentage_format %s%%"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_percentage_format '%s%%'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_remain_format %s"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_remain_format '%s'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_percentage} #{battery_charging_watts} #{battery_cycles} #{battery_health}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_percentage} #{battery_charging_watts} #{battery_cycles} #{battery_health}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Screenshot details.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_watts_format %s watts"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_watts_format '%s watts'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_cycles_format %s cycles"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_cycles_format '%s cycles'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_health_format %s of new"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_health_format '%s of new'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot detail-formats.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_detail_interval 2"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_detail_interval '2'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot detail-interval.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_fixed_width on"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_fixed_width 'on'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot fixed.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_percentage_width 8"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_percentage_width '8'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot width.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_percentage_label charge"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_percentage_label 'charge'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot labels.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_health_label health"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_health_label 'health'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot label-health.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_percentage} #{battery_graph}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_percentage} #{battery_graph}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_graph_width 5"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_graph_width '5'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_graph_full #"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_graph_full '#'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_graph_empty -"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_graph_empty '-'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot graph-width.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_percentage} #{battery_power_source}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_percentage} #{battery_power_source}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_source_battery_label on battery"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_source_battery_label 'on battery'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_source_ac_label plugged in"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_source_ac_label 'plugged in'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot power-source.png
Sleep 1s
Hide
Type "state 60 charging 1:10"
Enter
Sleep 3500ms
Show
Screenshot power-source-ac.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_hide_on_ac 1"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_hide_on_ac '1'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot hide-on-ac.png
Sleep 1s
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 3500ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_hide_on_ac 0"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_hide_on_ac '0'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g status-right #{battery_percentage}"
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_percentage}'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_before [{icon} "
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_before '[{icon} '"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_after  {color}]"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_after ' {color}]'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot before-after.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_notify 1"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_notify '1'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1000ms
Hide
Type "state 15 discharging 0:30"
Enter
Sleep 3000ms
Show
Hide
Type "state 7 discharging 0:12"
Enter
Sleep 3000ms
Show
Hide
Type "state 100 charged 0:00"
Enter
Sleep 3000ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "cat /Users/Shared/demo/notices"
Enter
Show
Sleep 800ms
Type "cat /Users/Shared/demo/notices"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot notify.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 2000ms
Type "tmux set -g @battery_revamped_snap_pct 80 && tmux set -g @battery_revamped_snap_ts $(($(date +%s) - 3600))"
Enter
Sleep 2000ms
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_popup_width 60"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_popup_width '60'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 800ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_popup_height 20"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_popup_height '20'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 800ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix M-b, q"
Enter
Show
Ctrl+B
Escape
Type@1ms "b"
Sleep 3500ms
Screenshot popup-size.png
Sleep 1s
Type "q"
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_popup_key B"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_popup_key 'B'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 800ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "battery-revamped apply"
Enter
Show
Sleep 800ms
Type "battery-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix B, q"
Enter
Show
Ctrl+B
Type@1ms "B"
Sleep 3500ms
Screenshot popup-key.png
Sleep 1s
Type "q"
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_interval 3"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_interval '3'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot interval.png
Sleep 1s
Sleep 1500ms
