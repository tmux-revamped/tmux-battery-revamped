<div align="center">

# tmux-battery-revamped

<strong>在 tmux 状态栏显示电池状态，从不阻塞状态栏渲染。</strong>

[English](README.md) | [日本語](README.ja.md) | 简体中文 | [繁體中文（香港）](README.zh-HK.md)

[![family](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/family.yml?branch=main&style=flat-square&label=family)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/family.yml)
[![tests](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/tests.yml?branch=main&style=flat-square&label=tests)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#what-it-does">功能</a> |
  <a href="#requirements">环境要求</a> |
  <a href="#installation">安装</a> |
  <a href="#usage">用法</a> |
  <a href="#configuration">配置</a> |
  <a href="#key-bindings">快捷键</a> |
  <a href="#how-it-works">工作原理</a>
</p>

</div>

**20** 个占位符。**2** 种渲染模式。**5** 个系统数据源：`pmset`、`system_profiler`、`ioreg`、`/sys/class/power_supply` 和 `acpi`。CI 在 **10** 种 Linux 和 macOS 工具链组合上运行测试。

---

<a id="what-it-does"></a>

## 功能

插件把 `status-left` 和 `status-right` 中的 `#{battery_*}` 占位符替换为笔记本电池的电量、状态、剩余时间、功率、循环次数、健康度、耗电速度和电量历史。每个占位符读取缓存在 tmux 选项中的值。电池工具在后台运行，所以缓慢的 `pmset` 或 `system_profiler` 调用不会拖慢状态栏。不向磁盘写入任何内容。

它还可以在电量低、电量极低和充满时发送桌面通知，并通过 `prefix + M-b` 打开详情弹窗。

<a id="requirements"></a>

## 环境要求

| 工具 | 版本 | 用途 |
|:-----|:--------|:-----------|
| tmux | 3.2 或更高 | 详情弹窗所用的 `display-popup` |
| bash | 3.2 或更高 | 所有脚本，包括 macOS 的 `/bin/bash` |
| `acpi` | 任意 | Linux 上可选，电量和剩余时间的后备来源 |
| `osascript` 或 `notify-send` | 任意 | 可选，桌面通知 |

| 数值 | Linux，x86_64 和 arm64 | macOS，Intel 和 Apple Silicon |
|:------|:------------------------|:-------------------------------|
| 电量和状态 | 第一个 `/sys/class/power_supply/BAT*`，其次 `acpi` | `pmset` |
| 剩余时间 | `acpi`，其次根据 `/sys` 的能量或电荷计数器计算 | `pmset` |
| 功率 | `power_now`，当前功耗 | `system_profiler`，充电器的额定功率 |
| 循环次数 | `cycle_count` | `ioreg` |
| 健康度 | `energy_full` 与 `energy_full_design` 之比，其次 `charge_*` 这一对 | `ioreg`，`AppleRawMaxCapacity` 与 `DesignCapacity` 之比 |

主机没有数据源的数值显示为空。运行 `src/battery.sh doctor` 可以查看本机有哪些数据源。

<a id="installation"></a>

## 安装

### 使用 TPM

把插件和占位符加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
set -g status-right '#{battery_icon_status} #{battery_percentage} #{battery_remain}'
```

### 手动安装

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

然后把这一行加到 `~/.tmux.conf` 中设置 `status-left` 和 `status-right` 的行之后，并重新加载 tmux：

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

<a id="usage"></a>

## 用法

在 `status-left` 或 `status-right` 中写入占位符，插件加载时会替换它们。完整示例见 [`examples/status-right.tmux.conf`](examples/status-right.tmux.conf)。

```tmux
set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

| 占位符 | 输出 |
|:------------|:-------|
| `#{battery_percentage}` | 电量，例如 `83%` |
| `#{battery_icon}`、`#{battery_icon_charge}` | 当前电量档位的图标 |
| `#{battery_icon_status}` | 当前状态的图标 |
| `#{battery_color_fg}`、`#{battery_color_bg}` | 当前状态的颜色 |
| `#{battery_color_status_fg}`、`#{battery_color_status_bg}` | 当前状态的颜色 |
| `#{battery_color_charge_fg}`、`#{battery_color_charge_bg}` | 当前电量档位的颜色 |
| `#{battery_graph}` | 电量条，例如 `████████░░` |
| `#{battery_remain}` | 系统报告的剩余时间，例如 `4:32` |
| `#{battery_estimate}` | 根据耗电速度计算的剩余时间，例如 `2:00` |
| `#{battery_charging_watts}` | 功率，例如 `45W` |
| `#{battery_cycles}` | 循环次数 |
| `#{battery_health}` | 满充容量与设计容量之比，例如 `96%` |
| `#{battery_drain_rate}` | 至少间隔五分钟测得的每小时耗电百分比，例如 `12.5%/h` |
| `#{battery_sparkline}` | 最近的电量读数，例如 `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC` 或 `Bat` |
| `#{battery_alert_icon}` | 放电时电量低或极低时显示的符号 |

状态为 `charged`、`charging`、`discharging`、`attached` 或 `unknown` 之一。`attached` 表示接着交流电源但没有充电。

<a id="configuration"></a>

## 配置

| 选项 | 默认值 | 含义 |
|:-------|:--------|:--------|
| `@battery_revamped_interval` | `15` | 电量和状态读数保持有效的秒数 |
| `@battery_revamped_detail_interval` | `60` | 剩余时间、功率、循环次数和健康度保持有效的秒数 |
| `@battery_revamped_render` | 空 | `options` 开启选项渲染模式，见[工作原理](#how-it-works) |
| `@battery_revamped_percentage_format` | `%s%%` | 电量的 printf 格式 |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` 到 `█` | 每个电量档位的图标，第 1 档最低 |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 每个电量档位的颜色 |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`、`+`、`-`、`!`、`?` | 每种状态的图标 |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 每种状态的颜色 |
| `@battery_revamped_icons` | `ascii` | `nerd` 为八个档位使用 Nerd Font 电池字形，充电时使用充电字形，并为每个指标加标签；档位图标选项仍然优先 |
| `@battery_revamped_graph_width` | `10` | 电量条的格数 |
| `@battery_revamped_graph_full` | `█` | 已填充的格 |
| `@battery_revamped_graph_empty` | `░` | 空格 |
| `@battery_revamped_remain_format` | `%s` | 两个剩余时间占位符的格式 |
| `@battery_revamped_watts_format` | `%sW` | 功率的格式 |
| `@battery_revamped_cycles_format` | `%s` | 循环次数的格式 |
| `@battery_revamped_health_format` | `%s%%` | 健康度的格式 |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 耗电速度的格式 |
| `@battery_revamped_history_size` | `16` | 走势图保留的读数个数 |
| `@battery_revamped_low_threshold` | `20` | 放电时视为电量低的百分比 |
| `@battery_revamped_critical_threshold` | `10` | 放电时视为电量极低的百分比 |
| `@battery_revamped_low_icon`、`@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}` 的符号 |
| `@battery_revamped_source_ac_label`、`@battery_revamped_source_battery_label` | `AC`、`Bat` | `#{battery_power_source}` 的文字 |
| `@battery_revamped_hide_on_ac` | `0` | `1` 在电池不处于放电状态时让所有占位符显示为空 |
| `@battery_revamped_before`、`@battery_revamped_after` | 空 | 仅在 `#{battery_percentage}` 显示时放在其前后的文字；`{icon}` 替换为电量图标，`{color}` 替换为电量档位颜色 |
| `@battery_revamped_<metric>_label` | 空 | 值不为空时显示在某个指标前的文字；`''` 去掉 `nerd` 标签 |
| `@battery_revamped_fixed_width` | `off` | `on` 在左侧填充每个值到其最大宽度 |
| `@battery_revamped_<metric>_width` | 空 | 某个指标的填充宽度，优先于固定宽度 |
| `@battery_revamped_notify` | `0` | `1` 在电量进入低、极低或充满时发送桌面通知 |
| `@battery_revamped_popup_key` | `M-b` | 详情弹窗的 prefix 按键；`off` 不绑定 |
| `@battery_revamped_popup_width`、`@battery_revamped_popup_height` | `44`、`12` | 弹窗大小 |

标签适用于 `percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline` 和 `power_source`。宽度设置不会截断较长的值。

### 主题配色

颜色选项默认为空，因此在设置之前插件不添加颜色。下面每个配色把第 1 到 3 档设为红色，第 4 到 6 档设为黄色，第 7 到 8 档设为绿色，并为每种状态设置颜色：

<details>
<summary>Catppuccin Mocha</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#f38ba8]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#a6e3a1]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#f9e2af]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#89b4fa]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#a6adc8]"
```

</details>

<details>
<summary>Dracula</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#ff5555]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#50fa7b]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#f1fa8c]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#bd93f9]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#6272a4]"
```

</details>

<details>
<summary>Nord</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#bf616a]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#a3be8c]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#ebcb8b]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#81a1c1]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#d8dee9]"
```

</details>

<details>
<summary>Gruvbox Dark</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#fb4934]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#b8bb26]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#fabd2f]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#83a598]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#a89984]"
```

</details>

<details>
<summary>Tokyo Night</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#f7768e]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#9ece6a]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#e0af68]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#7aa2f7]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#565f89]"
```

</details>

<details>
<summary>Solarized Dark</summary>

```tmux
set -g @battery_revamped_charge_tier1_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier2_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier3_fg_color "#[fg=#dc322f]"
set -g @battery_revamped_charge_tier4_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier5_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier6_fg_color "#[fg=#b58900]"
set -g @battery_revamped_charge_tier7_fg_color "#[fg=#859900]"
set -g @battery_revamped_charge_tier8_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_charged_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_charging_fg_color "#[fg=#859900]"
set -g @battery_revamped_status_discharging_fg_color "#[fg=#b58900]"
set -g @battery_revamped_status_attached_fg_color "#[fg=#268bd2]"
set -g @battery_revamped_status_unknown_fg_color "#[fg=#586e75]"
```

</details>

### 内部状态

以下选项由插件自己写入，请不要设置。

| 选项 | 内容 |
|:-------|:------|
| `@battery_revamped_published` | 加载时在 `status-left` 和 `status-right` 中找到的指标，即选项模式要发布的指标 |
| `@battery_revamped_out_<metric>` | 选项模式中每个指标发布的值 |
| `@battery_revamped_ticker_pid` | 选项模式后台进程的 pid |
| `@battery_revamped_option_names` | 后台进程每个周期用一次调用读取的选项 |
| `@battery_revamped_alert_level` | 最近一次的档位，为 `ok`、`low`、`critical`、`full` 或 `unknown`，使每次跨越只通知一次 |
| `@battery_revamped_history` | 走势图所用的最近电量读数 |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 计算耗电速度的基准读数 |
| `@battery_revamped_{percent,status,remain,watts,cycles,health,drain_rate}` | 缓存的读数，各带一个 `_ts` 时间戳，`percent` 另有 `_lock` |

<a id="key-bindings"></a>

## 快捷键

| 按键 | 操作 | 选项 |
|:----|:-------|:-------|
| `prefix + M-b` | 打开详情弹窗 | `@battery_revamped_popup_key` |

弹窗显示缓存的电量、状态、剩余时间、功率、耗电速度、循环次数和健康度，不会再次查询电池。按任意键关闭。`@battery_revamped_popup_key` 为空时回退到 `M-b`，为 `off` 时不绑定任何按键。

<a id="how-it-works"></a>

## 工作原理

在默认的作业模式中，每个占位符都会变成调用 [`src/battery.sh`](src/battery.sh) 的 `#()`。调用会立即输出缓存的值。当缓存的电量比 `@battery_revamped_interval` 旧时，它还会启动一次后台刷新；刷新受锁保护，并行的调用不会再启动第二次。

tmux 每次重绘状态栏都会运行所有 `#()`。一条状态栏上有多个插件时，大约每秒一次。选项模式去掉了这些调用：

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

此时每个占位符变成类似 `#{E:@battery_revamped_out_percentage}` 的选项读取。每个服务器有一个后台进程，每 `@battery_revamped_interval` 秒读取一次电池，用一次 tmux 调用写入状态栏用到的所有值，然后只重绘一次。服务器停止，或重新加载配置启动了接替的进程时，它就会退出。切回作业模式也会释放它。

耗电速度把当前电量与至少五分钟前的读数比较。`#{battery_estimate}` 用剩余电量除以这个速度。每次进入低、极低或充满时只通知一次，macOS 上通过 `osascript`，Linux 上通过 `notify-send`。

<a id="development"></a>

## 开发

| 命令 | 运行内容 |
|:--------|:-------------|
| `make test` | [`test/`](test) 下的 bats 测试 |
| `make lint` | 对所有 shell 文件运行 shellcheck |
| `make coverage` | 在 Linux 上用 kcov 统计行覆盖率，低于 95% 时失败 |

<a id="license"></a>

## 许可证

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中的同一份约定、`family/` 下的同一套工具和同一个共享库，并由校验和清单保证逐字节一致。这些成员可以一起安装：任何成员都不会占用其他成员使用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在全部成员中排查之后才算修复完成。这项义务写在约定里，而不是靠记忆，`family/bin/sweep` 负责执行它。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和终端区分的合理默认设置，不改动你自己设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺窗口管理：八种布局，包括 BSP dwindle 和 spiral，并支持撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 状态栏中的本地时钟和世界时钟，按一天中的时段着色，并提供倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在后台从 wttr.in 获取天气并显示在状态栏，状态栏无需等待 |

### 检查安装

所有成员都在磁盘上时，一条命令即可报告它们之间的任何冲突：

```sh
family/bin/doctor --live
```

它读取每个成员和正在运行的 tmux 服务器，报告重复的按键、重复的状态占位符、不符合命名规则的选项，以及约定版本落后的成员。

<!-- family:end -->
