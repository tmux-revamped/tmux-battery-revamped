<div align="center">

# tmux-battery-revamped

<strong>在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速开始"><strong>快速开始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#运作原理">运作原理</a> &nbsp;|&nbsp;
  <a href="#界面">界面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="battery-revamped 按档位着色显示电量、状态和剩余时间，电量降到偏低和危急，打开卡片弹窗，切换到 Nerd Font 标签、迷你图和 options 渲染模式" width="800">
</p>

```console
$ battery-revamped refresh
Refreshed. 100% charge, charged.
$ battery-revamped status percentage
100%
```

**20** 个占位符，**2** 种渲染模式，支持 macOS 和 Linux，需要 tmux **3.2** 或更高版本。

---

## 快速开始

### 前提条件

| 工具 | 版本 | 用途 |
|:-----|:-----|:-----|
| tmux | 3.2 或更高 | 家族共同的最低版本，也用于弹窗 |
| gum | 可选 | `battery-revamped` 的菜单、表格和颜色；没有它时每个命令都输出纯文本 |
| `osascript`、`notify-send` | 可选 | `@battery_revamped_notify` 为 `1` 时的桌面通知 |

它在 Linux 和 macOS 上运行，可使用 BSD、GNU、uutils 或 BusyBox 工具。每个数值都来自系统自带的东西：

| 数值 | Linux | macOS |
|:-----|:-----|:-----|
| 电量和状态 | 第一个有可读 `capacity` 的 `/sys/class/power_supply/BAT*`，然后是 `acpi` | `pmset` |
| 剩余时间 | `acpi`，然后由 `energy_now` 或 `charge_now` 计数器计算 | `pmset` |
| 瓦数 | 当前功耗 `power_now` | `system_profiler`，充电器的额定瓦数 |
| 循环次数 | `cycle_count` | `ioreg` |
| 健康度 | `energy_full` 除以 `energy_full_design`，然后是 `charge_*` 这一对 | `ioreg`，`AppleRawMaxCapacity` 除以 `DesignCapacity` |

缺少来源的数值，其占位符为空，`battery-revamped doctor` 会指出它。没有电池的机器不显示任何内容。

### 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件加入 `~/.tmux.conf` 并按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
```

手动安装时，克隆仓库，并在 `~/.tmux.conf` 中运行入口脚本：

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

请在插件加载之前设置 `status-left` 或 `status-right`。插件只在加载时替换一次其中的占位符。

在克隆目录中运行 `make install`，还会把 `battery-revamped` 放进 `~/.local/bin`，把 man 手册和补全放进 `~/.local/share`。

### 验证

```bash
~/.tmux/plugins/tmux-battery-revamped/bin/battery-revamped doctor
```

## 用法

本插件显示笔记本电池的电量，以及状态、剩余时间、瓦数、循环次数、健康度、下降速度、估算和最近电量的迷你图。状态栏显示 tmux 已经保存的值，后台读取负责更新它。

| 占位符 | 输出 |
|:-----|:-----|
| `#{battery_percentage}` | 电量，例如 `83%` |
| `#{battery_icon}` | 当前电量档位的图标 |
| `#{battery_icon_charge}` | 与 `#{battery_icon}` 相同的图标 |
| `#{battery_icon_status}` | 当前状态的图标 |
| `#{battery_color_fg}` | 当前状态的前景样式 |
| `#{battery_color_bg}` | 当前状态的背景样式 |
| `#{battery_color_charge_fg}` | 当前电量档位的前景样式 |
| `#{battery_color_charge_bg}` | 当前电量档位的背景样式 |
| `#{battery_color_status_fg}` | 与 `#{battery_color_fg}` 相同的样式 |
| `#{battery_color_status_bg}` | 与 `#{battery_color_bg}` 相同的样式 |
| `#{battery_graph}` | 电量条，例如 `█████░░░░░` |
| `#{battery_remain}` | 系统报告的剩余时间，例如 `4:32` |
| `#{battery_charging_watts}` | 瓦数，例如 `45W` |
| `#{battery_cycles}` | 充放电循环次数 |
| `#{battery_health}` | 满充容量除以设计容量，例如 `96%` |
| `#{battery_drain_rate}` | 至少间隔五分钟测得的每小时下降百分比，例如 `12.5%/h` |
| `#{battery_estimate}` | 按下降速度计算的剩余时间，例如 `2:00` |
| `#{battery_sparkline}` | 最近电量读数的迷你图，例如 `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC`，放电时为 `Bat` |
| `#{battery_alert_icon}` | 放电时电量偏低或危急期间显示的符号，否则为空 |

状态是 `charged`、`charging`、`discharging`、`attached` 或 `unknown` 之一。`attached` 表示接通交流电但没有充电。

把占位符放进状态栏：

```tmux
set -g @battery_revamped_status_discharging_fg_color '#[fg=yellow]'
set -g @battery_revamped_status_charging_fg_color '#[fg=green]'

set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

同一个示例加上几个选项，见 [examples/status-right.tmux.conf](examples/status-right.tmux.conf)。

### 标签和宽度

`@battery_revamped_<metric>_label` 在某个指标的值非空时，在它前面打印一个图标或词。`@battery_revamped_icons` 设为 `nerd` 时，下面每个指标前都有 Nerd Font 字形标签。指标自己的标签优先于这组字形；在 tmux 中设为空的标签表示默认值，所以字形保留。把标签设为 `off`，就既不显示标签也不显示字形。`off` 也能隐藏任何图标或文字选项，例如 `@battery_revamped_low_icon` 或 `@battery_revamped_graph_full`。默认的 `ascii` 不加标签。

| 指标 | `nerd` 字形 |
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

`@battery_revamped_fixed_width` 设为 `on` 时，电量在左侧补齐到自然宽度，即四个字符，所以从 `9%` 变成 `42%` 不会让这一行的其余部分移位。`@battery_revamped_<metric>_width` 设置某个指标的宽度，并优先于固定宽度。过长的值不会被截断。

### 电量前后的文字

`@battery_revamped_before` 和 `@battery_revamped_after` 仅在 `#{battery_percentage}` 有输出时，把文字放在它前后。其中 `{icon}` 变为电量图标，`{color}` 变为去掉 `#[fg=` 包装的电量档位颜色，所以 `#[fg={color}]{icon} ` 会给图标着色。

### 渲染模式

默认情况下，每个占位符变成一个 `#()` 调用，tmux 在状态栏重绘时重新运行它。把 `@battery_revamped_render` 设为 `options` 后，每个占位符变成对选项的读取，例如 `#{E:@battery_revamped_out_percentage}`。每个服务器随后有一个后台进程每隔 `@battery_revamped_interval` 秒读取一次电池，并用一次 tmux 调用写入所有数值，所以它们一起变化。

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

### 通知

`@battery_revamped_notify` 设为 `1` 时，电量进入偏低、危急或充满时发送一次桌面通知：macOS 上用 `osascript`，Linux 上用 `notify-send`。每次跨过界线只通知一次。默认是 `0`，状态始终显示在状态栏和卡片中。

### 档位颜色

颜色选项默认为空，所以设置之前颜色占位符不输出任何内容。下面的配色把档位 1 到 3 映射为红色，4 到 6 为黄色，7 和 8 为绿色：

| 主题 | 低 | 中 | 高 |
|:-----|:-----|:-----|:-----|
| Catppuccin Mocha | `#f38ba8` | `#f9e2af` | `#a6e3a1` |
| Dracula | `#ff5555` | `#f1fa8c` | `#50fa7b` |
| Nord | `#bf616a` | `#ebcb8b` | `#a3be8c` |
| Gruvbox Dark | `#fb4934` | `#fabd2f` | `#b8bb26` |
| Tokyo Night | `#f7768e` | `#e0af68` | `#9ece6a` |
| Solarized Dark | `#dc322f` | `#b58900` | `#859900` |

每个值按档位放进样式，例如 `set -g @battery_revamped_charge_tier1_fg_color '#[fg=#f38ba8]'`。各状态也用 `@battery_revamped_status_<state>_fg_color` 采用相同的样式。

| 命令 | 作用 |
|:-----|:-----|
| `battery-revamped apply` | 立即绑定弹窗按键并填充占位符；tmux 加载插件时由入口脚本运行 |
| `battery-revamped list` | 输出 `apply` 会发送的每条命令，不做任何更改；`--json` 输出一个对象 |
| `battery-revamped status NAME` | 输出一个占位符，例如 `percentage`、`remain` 或 `graph`；状态栏运行它；不是占位符的名称不输出任何内容 |
| `battery-revamped refresh` | 立即读取电池并说明当前情况 |
| `battery-revamped card` | 输出已保存的读数，每个数值一行；没有保存任何读数时先读取电池 |
| `battery-revamped popup` | 在 tmux 弹窗中打开卡片；弹窗按键运行它 |
| `battery-revamped popup-card` | 输出卡片并等待按键，弹窗运行的就是它 |
| `battery-revamped daemon` | 为 `options` 渲染模式在每个节拍发布占位符；由 `apply` 启动 |
| `battery-revamped doctor` | 每个依赖一行：每个数值的来源工具或文件、弹窗、设置、通知方式，以及被放过的按键 |
| `battery-revamped version` | 版本，然后是 tmux 版本 |
| `battery-revamped help` | 帮助页面；`man battery-revamped` 记录相同的命令和设置 |
| `battery-revamped` | 在终端中显示菜单 |

## 配置

每个选项也是带短横线的命令选项，例如 `--interval 2`，也是环境变量，例如 `BATTERY_REVAMPED_INTERVAL`；命令行优先于环境变量，环境变量优先于 tmux 选项。为空的 tmux 选项表示默认值；在命令行或环境变量中给出的空值按原样使用。`doctor` 会指出持有插件不认识的值的设置。传给 `apply` 的设置会随弹窗按键和每次状态调用一起传递。

### 读取和警报

| 选项 | 默认 | 含义 |
|:-----|:-----|:-----|
| `@battery_revamped_interval` | `15` | 电量和状态读数保持新鲜的秒数，选项渲染模式的计时器也接受 `minute` |
| `@battery_revamped_detail_interval` | `60` | 剩余时间、瓦数、循环次数和健康度保持新鲜的秒数 |
| `@battery_revamped_render` | `jobs` | `options` 读取已发布的选项，而不是运行 `#()` 调用；其他任何值都表示 `jobs` |
| `@battery_revamped_history_size` | `16` | 为 `#{battery_sparkline}` 保留的读数个数 |
| `@battery_revamped_low_threshold` | `20` | 放电时视为偏低的电量百分比 |
| `@battery_revamped_critical_threshold` | `10` | 放电时视为危急的电量百分比 |
| `@battery_revamped_low_icon`, `@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}` 在电量偏低和危急时输出的内容 |
| `@battery_revamped_hide_on_ac` | `0` | 设为 `1` 时，除非正在放电，否则每个占位符都为空 |
| `@battery_revamped_notify` | `0` | 设为 `1` 时，电量进入偏低、危急或充满时发送桌面通知 |

### 图标和颜色

| 选项 | 默认 | 含义 |
|:-----|:-----|:-----|
| `@battery_revamped_icons` | `ascii` | `nerd` 为八个档位使用 Nerd Font 电池字形，并带有充电变体，同时给每个指标加标签；档位图标选项仍然优先 |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` to `█` | 每个电量档位的图标，档位 1 最低 |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 每个电量档位的颜色，例如 `#[fg=green]` |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | 每个状态的图标；`attached` 表示接通交流电但没有充电 |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 每个状态的颜色 |
| `@battery_revamped_source_ac_label`, `@battery_revamped_source_battery_label` | `AC`, `Bat` | 未使用电池和使用电池时 `#{battery_power_source}` 的文字 |
| `@battery_revamped_before`, `@battery_revamped_after` | 空 | 仅在 `#{battery_percentage}` 有输出时放在它前后的文字；`{icon}` 变为电量图标，`{color}` 变为电量档位的颜色 |

### 格式和标签

| 选项 | 默认 | 含义 |
|:-----|:-----|:-----|
| `@battery_revamped_percentage_format` | `%s%%` | 电量的 printf 格式 |
| `@battery_revamped_remain_format` | `%s` | 两个剩余时间占位符共用的 printf 格式 |
| `@battery_revamped_watts_format` | `%sW` | 瓦数的 printf 格式 |
| `@battery_revamped_cycles_format` | `%s` | 循环次数的 printf 格式 |
| `@battery_revamped_health_format` | `%s%%` | 健康度的 printf 格式 |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 下降速度的 printf 格式 |
| `@battery_revamped_graph_width` | `10` | 电量条的格数，也是它补齐到的宽度 |
| `@battery_revamped_graph_full` | `█` | 已填充的格子 |
| `@battery_revamped_graph_empty` | `░` | 空格子 |
| `@battery_revamped_<metric>_label` | 空 | 仅在值非空时，打印在某个指标的值之前的文字 |
| `@battery_revamped_fixed_width` | `off` | 设为 `on` 时，电量在左侧补齐到自然宽度，即四个字符 |
| `@battery_revamped_<metric>_width` | 空 | 把某个指标补齐到这么多字符；过长的值不会被截断 |

可带标签和宽度的指标是 `percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline` 或 `power_source`。

### 弹窗

| 选项 | 默认 | 含义 |
|:-----|:-----|:-----|
| `@battery_revamped_popup_key` | `M-b` | 打开卡片弹窗的前缀按键。`off` 表示不绑定 |
| `@battery_revamped_popup_width` | `44` | 弹窗宽度 |
| `@battery_revamped_popup_height` | `16` | 弹窗高度 |

### 内部状态

插件自己写入这些选项，请勿设置它们。

| 选项 | 保存的内容 |
|:-----|:-----|
| `@battery_revamped_published` | 状态栏使用的指标，在加载时记录，使 options 模式只写入这些 |
| `@battery_revamped_out_<metric>` | options 模式下每个指标的渲染结果 |
| `@battery_revamped_ticker_pid` | options 模式后台进程的进程号 |
| `@battery_revamped_history` | `#{battery_sparkline}` 背后的最近电量读数 |
| `@battery_revamped_alert_level` | 最后一次看到的级别，`ok`、`low`、`critical`、`full` 或 `unknown`，使每次跨过界线只通知一次 |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 下降速度的测量起点读数 |
| `@battery_revamped_percent` 和其他数值、`_ts`、`_lock` | 保存的读数、每次读取的时间和刷新锁 |

## 按键绑定

| 按键 | 动作 | 默认 |
|:-----|:-----|:-----|
| `prefix + M-b` | 在弹窗中打开已保存读数的卡片，按任意键关闭 | 已绑定 |

`@battery_revamped_popup_key` 可指定另一个按键，`off` 表示不绑定。默认按键已被其他绑定占用时会被放过，`battery-revamped doctor` 会说明。

<a id="运作原理"></a>

## 运作原理

tmux 加载插件时，[`battery-revamped.tmux`](battery-revamped.tmux) 运行一次。它把 `status-left` 和 `status-right` 用到的指标记录在 `@battery_revamped_published` 中，然后把每个占位符替换为对 [`bin/battery-revamped`](bin/battery-revamped) 的调用；在 `options` 模式下则替换为选项读取，并启动后台进程。

在默认模式下，每个 `#()` 调用立即返回已保存的读数。读数比间隔旧时，调用会在后台启动刷新并加锁，所以同一时间只有一个刷新在运行。剩余时间、瓦数、循环次数和健康度的读取代价更高，所以每隔 `@battery_revamped_detail_interval` 秒刷新一次。一次 tmux 调用保存所有数值。下降速度用当前电量与至少五分钟前的读数比较得出，`#{battery_estimate}` 用剩余电量除以这个速度。

每次进入偏低、危急或充满，都通过共享的通知程序发送一次通知。读取、数值和格式化位于 [`lib/battery.sh`](lib/battery.sh)，设置表位于 [`lib/state.sh`](lib/state.sh)。

<a id="界面"></a>

## 界面

<details>
<summary>每个界面都用 <code>make screens</code> 在真实的 tmux 中录制，每个按键都显示在状态栏上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="battery-revamped: 带档位图标和颜色的电量、状态、剩余时间和电源"><br><sub>带档位图标和颜色的电量、状态、剩余时间和电源，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="battery-revamped: prefix M-b 在弹窗中打开卡片"><br><sub><code>prefix M-b</code> 在弹窗中打开卡片，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="battery-revamped: @battery_revamped_icons 设为 nerd 时每个档位有字形并带标签"><br><sub><code>@battery_revamped_icons</code> 设为 <code>nerd</code> 时每个档位有字形并带标签，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="battery-revamped: 电量条、电量和迷你图"><br><sub>电量条、电量和迷你图，来自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="battery-revamped: 在 options 渲染模式下每个占位符读取一个 tmux 选项"><br><sub>在 <code>options</code> 渲染模式下每个占位符读取一个 tmux 选项，来自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/drain.png" alt="battery-revamped: 每小时的下降百分比"><br><sub>每小时的下降百分比，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/estimate.png" alt="battery-revamped: 估算、下降速度和剩余时间"><br><sub>估算、下降速度和剩余时间，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/estimate-label.png" alt="battery-revamped: @battery_revamped_estimate_label 在估算前放一个词"><br><sub><code>@battery_revamped_estimate_label</code> 在估算前放一个词，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/drain-format.png" alt="battery-revamped: @battery_revamped_drain_rate_format 决定下降速度的格式"><br><sub><code>@battery_revamped_drain_rate_format</code> 决定下降速度的格式，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/charging.png" alt="battery-revamped: 充电时估算给出充满所需的时间"><br><sub>充电时估算给出充满所需的时间，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/low.png" alt="battery-revamped: 电量偏低时的警报图标"><br><sub>电量偏低时的警报图标，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/thresholds.png" alt="battery-revamped: @battery_revamped_low_threshold 移动偏低的界线"><br><sub><code>@battery_revamped_low_threshold</code> 移动偏低的界线，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/critical.png" alt="battery-revamped: 电量危急时的警报图标"><br><sub>电量危急时的警报图标，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/critical-threshold.png" alt="battery-revamped: @battery_revamped_critical_threshold 移动危急的界线"><br><sub><code>@battery_revamped_critical_threshold</code> 移动危急的界线，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/alert-icons.png" alt="battery-revamped: @battery_revamped_low_icon 和 @battery_revamped_critical_icon 指定警报符号"><br><sub><code>@battery_revamped_low_icon</code> 和 <code>@battery_revamped_critical_icon</code> 指定警报符号，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-charged.png" alt="battery-revamped: 充满状态"><br><sub>充满状态，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/state-attached.png" alt="battery-revamped: 接通交流电但未充电的状态"><br><sub>接通交流电但未充电的状态，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-unknown.png" alt="battery-revamped: 未知状态"><br><sub>未知状态，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status-icons.png" alt="battery-revamped: @battery_revamped_status_<state>_icon 及其颜色"><br><sub><code>@battery_revamped_status_<state>_icon</code> 及其颜色，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-colors.png" alt="battery-revamped: #{battery_color_status_fg} 和 #{battery_color_status_bg}"><br><sub><code>#{battery_color_status_fg}</code> 和 <code>#{battery_color_status_bg}</code>，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="battery-revamped: @battery_revamped_charge_tier7_icon 及其颜色"><br><sub><code>@battery_revamped_charge_tier7_icon</code> 及其颜色，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/format.png" alt="battery-revamped: @battery_revamped_percentage_format 决定电量的格式"><br><sub><code>@battery_revamped_percentage_format</code> 决定电量的格式，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/remain-format.png" alt="battery-revamped: @battery_revamped_remain_format 决定剩余时间的格式"><br><sub><code>@battery_revamped_remain_format</code> 决定剩余时间的格式，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/details.png" alt="battery-revamped: 瓦数、循环次数和健康度"><br><sub>瓦数、循环次数和健康度，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/detail-formats.png" alt="battery-revamped: @battery_revamped_watts_format、_cycles_format 和 _health_format"><br><sub><code>@battery_revamped_watts_format</code>、<code>_cycles_format</code> 和 <code>_health_format</code>，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/detail-interval.png" alt="battery-revamped: @battery_revamped_detail_interval 决定读取详细数据的频率"><br><sub><code>@battery_revamped_detail_interval</code> 决定读取详细数据的频率，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="battery-revamped: @battery_revamped_fixed_width 把电量补齐到自然宽度"><br><sub><code>@battery_revamped_fixed_width</code> 把电量补齐到自然宽度，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/width.png" alt="battery-revamped: @battery_revamped_percentage_width 把某个指标补齐到自己的宽度"><br><sub><code>@battery_revamped_percentage_width</code> 把某个指标补齐到自己的宽度，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="battery-revamped: 电量前的专属标签"><br><sub>电量前的专属标签，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/label-health.png" alt="battery-revamped: 健康度前的专属标签"><br><sub>健康度前的专属标签，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/graph-width.png" alt="battery-revamped: @battery_revamped_graph_width、_graph_full 和 _graph_empty 决定电量条的样子"><br><sub><code>@battery_revamped_graph_width</code>、<code>_graph_full</code> 和 <code>_graph_empty</code> 决定电量条的样子，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/power-source.png" alt="battery-revamped: @battery_revamped_source_battery_label 和 _source_ac_label"><br><sub><code>@battery_revamped_source_battery_label</code> 和 <code>_source_ac_label</code>，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/power-source-ac.png" alt="battery-revamped: 充电时的电源标签"><br><sub>充电时的电源标签，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/hide-on-ac.png" alt="battery-revamped: @battery_revamped_hide_on_ac 让不使用电池时的每个占位符都为空"><br><sub><code>@battery_revamped_hide_on_ac</code> 让不使用电池时的每个占位符都为空，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/before-after.png" alt="battery-revamped: @battery_revamped_before 和 _after 搭配 {icon} 和 {color}"><br><sub><code>@battery_revamped_before</code> 和 <code>_after</code> 搭配 <code>{icon}</code> 和 <code>{color}</code>，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/notify.png" alt="battery-revamped: @battery_revamped_notify 每跨过一个界线发送一次通知，这里显示的是替身通知程序的记录"><br><sub><code>@battery_revamped_notify</code> 每跨过一个界线发送一次通知，这里显示的是替身通知程序的记录，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-size.png" alt="battery-revamped: @battery_revamped_popup_width 和 _popup_height 决定弹窗大小"><br><sub><code>@battery_revamped_popup_width</code> 和 <code>_popup_height</code> 决定弹窗大小，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="battery-revamped: @battery_revamped_popup_key 为弹窗指定另一个按键"><br><sub><code>@battery_revamped_popup_key</code> 为弹窗指定另一个按键，来自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/interval.png" alt="battery-revamped: @battery_revamped_interval 决定读数保持新鲜的时长"><br><sub><code>@battery_revamped_interval</code> 决定读数保持新鲜的时长，来自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="battery-revamped: 版本"><br><sub>版本，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="battery-revamped: 未知命令"><br><sub>未知命令，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="battery-revamped: status percentage 和 status graph 各输出一个占位符"><br><sub><code>status percentage</code> 和 <code>status graph</code> 各输出一个占位符，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="battery-revamped: refresh 立即读取电池"><br><sub><code>refresh</code> 立即读取电池，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="battery-revamped: card 输出每个数值"><br><sub><code>card</code> 输出每个数值，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="battery-revamped: list 输出每个绑定"><br><sub><code>list</code> 输出每个绑定，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="battery-revamped: list --json 把同一份计划输出为一个对象"><br><sub><code>list --json</code> 把同一份计划输出为一个对象，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="battery-revamped: doctor"><br><sub><code>doctor</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="battery-revamped: 菜单"><br><sub>菜单，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="battery-revamped: 从菜单打开的卡片"><br><sub>从菜单打开的卡片，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="battery-revamped: 来自 BATTERY_REVAMPED_ACCENT 的强调色"><br><sub>来自 <code>BATTERY_REVAMPED_ACCENT</code> 的强调色，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="battery-revamped: 没有 gum 的菜单"><br><sub>没有 gum 的菜单，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="battery-revamped: 没有 gum 时从菜单运行的 doctor"><br><sub>没有 gum 时从菜单运行的 <code>doctor</code>，来自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="battery-revamped: 没有 gum 的 card"><br><sub>没有 gum 的 <code>card</code>，来自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="battery-revamped: 六个主题下的标题"><br><sub>六个主题下的标题，来自 <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="battery-revamped: 帮助页面"><br><sub>帮助页面，来自 <code>help.tape</code></sub></td>
</tr>
</table>

录制运行真实的插件和 tmux。`pmset`、`system_profiler`、`ioreg` 和 `osascript` 由小脚本代替，所以画面上的数值来自它们；除非录制改变它，电池保持同一个状态。

</details>

## 可移植性

插件是 POSIX `sh`。CI 在下面每一行上运行全部测试。

| Shell | 状态 |
|:-----|:-----|
| `dash`、macOS 上的 `/bin/sh` | 支持 |
| `bash` 3.2 和 5.x、系统自带的 `zsh` 和 Homebrew 的 `zsh` | 支持 |

| 系统 | 状态 |
|:-----|:-----|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系统自带的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 开发

| 命令 | 运行内容 |
|:-----|:-----|
| `make fmt` | 对每个脚本运行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零告警 |
| `make test` | 在系统 `sh` 下运行 bats 测试 |
| `make test-all` | 在每个已安装的 shell 下运行测试，macOS 上包括 bash 和 zsh 的两种构建 |
| `make test-linux` | 在 Ubuntu 容器中运行测试 |
| `make coverage` | 在这台 Mac 和 Ubuntu 容器中运行 bashcov，合并后以 100% 为门槛 |
| `make screens` | 用 VHS 在 tmux 中从真实插件录制上面的界面，在 macOS 上运行 |
| `make install` | 把命令、man 手册和补全安装到 `PREFIX` 下 |

在 macOS 上，运行 `brew bundle` 会根据 [`Brewfile`](Brewfile) 安装这些目标用到的所有工具。

提交遵循 Conventional Commits 格式，直接进入 `main`。`main` 上的 `ci` 通过后，`release.yml` 运行 semantic-release：自上一个标签以来的每个 `feat` 或 `fix` 都会发布新版本，更新版本常量，并把说明写进 [`CHANGELOG.md`](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

这个插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中相同的约定和相同的共享库，并且设计为一起安装：没有成员占用另一个成员占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后，它会自动重新加载，无需按键，也无需命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | **本插件**，在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示每个已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，从不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘用量，从不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上挑选 URL、路径、哈希或任意其他词元，并输入到光标处，全部用纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口中的 fzf 选择器里切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏中显示活动窗格的 git 分支、改动和托管平台计数，且不阻塞渲染 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏中显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏中显示当前的 Kubernetes 上下文和命名空间，不依赖 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在弹出窗口或新窗口中启动任意 TUI 应用，从当前窗格的目录开始，每个应用可配置一个按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚缓冲区或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，从不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，从不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和窗口管理按键，适配 tmux 版本，兼容 vim，每个 prefix 按键都可禁用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

<!-- family:end -->

