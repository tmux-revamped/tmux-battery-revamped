Source common.tape
Output hero.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 5s
Screenshot status.png
Sleep 1s
Hide
Type "state 18 discharging 0:41"
Enter
Sleep 3500ms
Show
Hide
Type "state 8 discharging 0:17"
Enter
Sleep 3500ms
Show
Hide
Type "state 40 charging 1:05"
Enter
Sleep 3500ms
Show
Hide
Type "state 76 discharging 3:10"
Enter
Sleep 2500ms
Show
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
Screenshot popup.png
Sleep 1s
Type "q"
Sleep 1500ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_icons nerd"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_icons 'nerd'"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot icons.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_icons ascii"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_icons 'ascii'"
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
Type@5ms "tmux set -g status-right #{battery_graph} #{battery_percentage} #{battery_sparkline} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_graph} #{battery_percentage} #{battery_sparkline} '"
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
Type@5ms "tmux set -g @battery_revamped_history_size 6"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_history_size '6'"
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
Sleep 2000ms
Hide
Type "state 90 discharging 2:00"
Enter
Sleep 1800ms
Show
Hide
Type "state 70 discharging 2:00"
Enter
Sleep 1800ms
Show
Hide
Type "state 55 discharging 2:00"
Enter
Sleep 1800ms
Show
Hide
Type "state 35 discharging 2:00"
Enter
Sleep 1800ms
Show
Hide
Type "state 20 discharging 2:00"
Enter
Sleep 1800ms
Show
Hide
Type "state 45 discharging 2:00"
Enter
Sleep 1800ms
Show
Sleep 2s
Screenshot graph.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @battery_revamped_render options"
Enter
Show
Sleep 800ms
Type "tmux set -g @battery_revamped_render 'options'"
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
Type@5ms "tmux set -g status-right #{battery_graph} #{battery_percentage} #{battery_sparkline} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{battery_graph} #{battery_percentage} #{battery_sparkline} '"
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
Sleep 3s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux show -gv status-right | cut -c1-90"
Enter
Show
Sleep 800ms
Type "tmux show -gv status-right | cut -c1-90"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot options.png
Sleep 1s
Sleep 1500ms
