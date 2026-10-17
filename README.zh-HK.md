<div align="center">

# tmux-battery-revamped

<strong>在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![Tests](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> &nbsp;|&nbsp;
  <a href="#requirements">系統要求</a> &nbsp;|&nbsp;
  <a href="#installation">安裝</a> &nbsp;|&nbsp;
  <a href="#usage">用法</a> &nbsp;|&nbsp;
  <a href="#configuration">設定</a> &nbsp;|&nbsp;
  <a href="#key-bindings">快捷鍵</a> &nbsp;|&nbsp;
  <a href="#how-it-works">運作原理</a>
</p>

</div>

**20** 個佔位符。**2** 種繪製模式。**5** 個系統資料來源：`pmset`、`system_profiler`、`ioreg`、`/sys/class/power_supply` 及 `acpi`。CI 在 **10** 種 Linux 及 macOS 工具鏈組合上執行測試。

---

<a id="what-it-does"></a>

## 功能

插件把 `status-left` 及 `status-right` 中的 `#{battery_*}` 佔位符替換為手提電腦電池的電量、狀態、剩餘時間、功率、充電週期、健康度、耗電速度及電量記錄。每個佔位符讀取快取在 tmux 選項中的值。電池工具在背景運行，所以緩慢的 `pmset` 或 `system_profiler` 呼叫不會拖慢狀態列。不會寫入任何內容到磁碟。

它亦可在電量低、電量極低及充滿時發出桌面通知，並以 `prefix + M-b` 開啟詳情彈出視窗。

<a id="requirements"></a>

## 系統要求

| 工具 | 版本 | 用途 |
|:-----|:--------|:-----------|
| tmux | 3.2 或以上 | 詳情彈出視窗所用的 `display-popup` |
| bash | 3.2 或以上 | 所有腳本，包括 macOS 的 `/bin/bash` |
| `acpi` | 任何 | Linux 上可選，電量及剩餘時間的後備來源 |
| `osascript` 或 `notify-send` | 任何 | 可選，桌面通知 |

| 數值 | Linux，x86_64 及 arm64 | macOS，Intel 及 Apple Silicon |
|:------|:------------------------|:-------------------------------|
| 電量及狀態 | 第一個 `/sys/class/power_supply/BAT*`，其次 `acpi` | `pmset` |
| 剩餘時間 | `acpi`，其次根據 `/sys` 的能量或電荷計數器計算 | `pmset` |
| 功率 | `power_now`，目前耗電 | `system_profiler`，充電器的額定功率 |
| 充電週期 | `cycle_count` | `ioreg` |
| 健康度 | `energy_full` 與 `energy_full_design` 之比，其次 `charge_*` 這一對 | `ioreg`，`AppleRawMaxCapacity` 與 `DesignCapacity` 之比 |

主機沒有資料來源的數值會顯示為空。執行 `src/battery.sh doctor` 可查看本機有哪些資料來源。

<a id="installation"></a>

## 安裝

### 使用 TPM

把插件及佔位符加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
set -g status-right '#{battery_icon_status} #{battery_percentage} #{battery_remain}'
```

### 手動安裝

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

然後把這一行加到 `~/.tmux.conf` 中設定 `status-left` 及 `status-right` 的行之後，並重新載入 tmux：

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

<a id="usage"></a>

## 用法

在 `status-left` 或 `status-right` 中寫入佔位符，插件載入時會替換它們。完整範例見 [`examples/status-right.tmux.conf`](examples/status-right.tmux.conf)。

```tmux
set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

| 佔位符 | 輸出 |
|:------------|:-------|
| `#{battery_percentage}` | 電量，例如 `83%` |
| `#{battery_icon}`、`#{battery_icon_charge}` | 目前電量級別的圖示 |
| `#{battery_icon_status}` | 目前狀態的圖示 |
| `#{battery_color_fg}`、`#{battery_color_bg}` | 目前狀態的顏色 |
| `#{battery_color_status_fg}`、`#{battery_color_status_bg}` | 目前狀態的顏色 |
| `#{battery_color_charge_fg}`、`#{battery_color_charge_bg}` | 目前電量級別的顏色 |
| `#{battery_graph}` | 電量條，例如 `████████░░` |
| `#{battery_remain}` | 系統報告的剩餘時間，例如 `4:32` |
| `#{battery_estimate}` | 根據耗電速度計算的剩餘時間，例如 `2:00` |
| `#{battery_charging_watts}` | 功率，例如 `45W` |
| `#{battery_cycles}` | 充電週期次數 |
| `#{battery_health}` | 滿電容量與設計容量之比，例如 `96%` |
| `#{battery_drain_rate}` | 最少相隔五分鐘量度的每小時耗電百分比，例如 `12.5%/h` |
| `#{battery_sparkline}` | 最近的電量讀數，例如 `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC` 或 `Bat` |
| `#{battery_alert_icon}` | 放電時電量低或極低時顯示的符號 |

狀態為 `charged`、`charging`、`discharging`、`attached` 或 `unknown` 其中之一。`attached` 表示接駁交流電源但沒有充電。

<a id="configuration"></a>

## 設定

| 選項 | 預設值 | 意思 |
|:-------|:--------|:--------|
| `@battery_revamped_interval` | `15` | 電量及狀態讀數保持有效的秒數 |
| `@battery_revamped_detail_interval` | `60` | 剩餘時間、功率、充電週期及健康度保持有效的秒數 |
| `@battery_revamped_render` | 空 | `options` 開啟選項繪製模式，見[運作原理](#how-it-works) |
| `@battery_revamped_percentage_format` | `%s%%` | 電量的 printf 格式 |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` 至 `█` | 每個電量級別的圖示，第 1 級最低 |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 每個電量級別的顏色 |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`、`+`、`-`、`!`、`?` | 每種狀態的圖示 |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 每種狀態的顏色 |
| `@battery_revamped_icons` | `ascii` | `nerd` 為八個級別使用 Nerd Font 電池字符，充電時使用充電字符，並為每個指標加上標籤；級別圖示選項仍然優先 |
| `@battery_revamped_graph_width` | `10` | 電量條的格數 |
| `@battery_revamped_graph_full` | `█` | 已填滿的格 |
| `@battery_revamped_graph_empty` | `░` | 空格 |
| `@battery_revamped_remain_format` | `%s` | 兩個剩餘時間佔位符的格式 |
| `@battery_revamped_watts_format` | `%sW` | 功率的格式 |
| `@battery_revamped_cycles_format` | `%s` | 充電週期的格式 |
| `@battery_revamped_health_format` | `%s%%` | 健康度的格式 |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 耗電速度的格式 |
| `@battery_revamped_history_size` | `16` | 走勢圖保留的讀數數目 |
| `@battery_revamped_low_threshold` | `20` | 放電時視為電量低的百分比 |
| `@battery_revamped_critical_threshold` | `10` | 放電時視為電量極低的百分比 |
| `@battery_revamped_low_icon`、`@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}` 的符號 |
| `@battery_revamped_source_ac_label`、`@battery_revamped_source_battery_label` | `AC`、`Bat` | `#{battery_power_source}` 的文字 |
| `@battery_revamped_hide_on_ac` | `0` | `1` 在電池不在放電時令所有佔位符顯示為空 |
| `@battery_revamped_before`、`@battery_revamped_after` | 空 | 只在 `#{battery_percentage}` 顯示時放在其前後的文字；`{icon}` 換成電量圖示，`{color}` 換成電量級別顏色 |
| `@battery_revamped_<metric>_label` | 空 | 值不為空時顯示在某個指標前的文字；`''` 移除 `nerd` 標籤 |
| `@battery_revamped_fixed_width` | `off` | `on` 在左邊填充每個值至其最大寬度 |
| `@battery_revamped_<metric>_width` | 空 | 某個指標的填充寬度，優先於固定寬度 |
| `@battery_revamped_notify` | `0` | `1` 在電量進入低、極低或充滿時發出桌面通知 |
| `@battery_revamped_popup_key` | `M-b` | 詳情彈出視窗的 prefix 按鍵；`off` 不綁定 |
| `@battery_revamped_popup_width`、`@battery_revamped_popup_height` | `44`、`12` | 彈出視窗大小 |

標籤適用於 `percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline` 及 `power_source`。寬度設定不會截短較長的值。

### 主題配色

顏色選項預設為空，因此設定之前插件不會加上顏色。以下每個配色把第 1 至 3 級設為紅色，第 4 至 6 級設為黃色，第 7 至 8 級設為綠色，並為每種狀態設定顏色：

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

### 內部狀態

以下選項由插件自行寫入，請勿設定。

| 選項 | 內容 |
|:-------|:------|
| `@battery_revamped_published` | 載入時在 `status-left` 及 `status-right` 中找到的指標，即選項模式要發佈的指標 |
| `@battery_revamped_out_<metric>` | 選項模式中每個指標發佈的值 |
| `@battery_revamped_ticker_pid` | 選項模式背景進程的 pid |
| `@battery_revamped_option_names` | 背景進程每個週期以一次呼叫讀取的選項 |
| `@battery_revamped_alert_level` | 最近一次的級別，為 `ok`、`low`、`critical`、`full` 或 `unknown`，令每次越過只通知一次 |
| `@battery_revamped_history` | 走勢圖所用的最近電量讀數 |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 計算耗電速度的基準讀數 |
| `@battery_revamped_{percent,status,remain,watts,cycles,health,drain_rate}` | 快取的讀數，各附一個 `_ts` 時間戳記，`percent` 另有 `_lock` |

<a id="key-bindings"></a>

## 快捷鍵

| 按鍵 | 操作 | 選項 |
|:----|:-------|:-------|
| `prefix + M-b` | 開啟詳情彈出視窗 | `@battery_revamped_popup_key` |

彈出視窗顯示快取的電量、狀態、剩餘時間、功率、耗電速度、充電週期及健康度，不會再次查詢電池。按任何鍵關閉。`@battery_revamped_popup_key` 為空時會改用 `M-b`，為 `off` 時不綁定任何按鍵。

<a id="how-it-works"></a>

## 運作原理

在預設的工作模式中，每個佔位符都會變成呼叫 [`src/battery.sh`](src/battery.sh) 的 `#()`。呼叫會立即輸出快取的值。當快取的電量比 `@battery_revamped_interval` 舊時，它亦會啟動一次背景更新；更新受鎖保護，並行的呼叫不會再啟動第二次。

tmux 每次重繪狀態列都會執行所有 `#()`。一條狀態列上有多個插件時，大約每秒一次。選項模式取消了這些呼叫：

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

此時每個佔位符會變成類似 `#{E:@battery_revamped_out_percentage}` 的選項讀取。每個伺服器有一個背景進程，每 `@battery_revamped_interval` 秒讀取一次電池，以一次 tmux 呼叫寫入狀態列用到的所有值，然後只重繪一次。伺服器停止，或重新載入設定啟動了接替的進程時，它便會結束。切回工作模式亦會釋放它。

耗電速度把目前電量與最少五分鐘前的讀數比較。`#{battery_estimate}` 以剩餘電量除以這個速度。每次進入低、極低或充滿時只通知一次，macOS 上透過 `osascript`，Linux 上透過 `notify-send`。

<a id="development"></a>

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make test` | [`test/`](test) 下的 bats 測試 |
| `make lint` | 對所有 shell 檔案執行 shellcheck |
| `make coverage` | 在 Linux 上以 kcov 計算行覆蓋率，低於 95% 時失敗 |

<a id="license"></a>

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定、`family/` 下相同的工具及相同的共用程式庫，並由校驗和清單保持逐位元組一致。它們以一同安裝為設計前提：任何成員都不會佔用其他成員已佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在所有成員中排查之後，修正才算完成。這項責任寫在約定之中，而不是靠記憶，並透過 `family/bin/sweep` 履行。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | **本插件**，在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 以 fzf 從螢幕上揀選 URL、路徑、雜湊或其他片段，並在游標處輸入，純 shell 實作 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或新增 tmux 工作階段、視窗及窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示目前窗格的 git 分支、改動及託管平台計數，不阻塞狀態列 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 不借助 kubectl，從 kubeconfig 解析目前的 Kubernetes 環境及命名空間，顯示在 tmux 狀態列 |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或視窗中啟動任何 TUI 應用程式，工作目錄為目前窗格的目錄，按鍵可設定 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 把任何窗格儲存到檔案：即時記錄、完整回捲記錄或單次截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的曲目，從不阻塞狀態列繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡吞吐量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的標準窗格及視窗管理快捷鍵，按版本調整，貼合 vim 習慣，全部可設定 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存所有 tmux 工作階段、視窗及窗格，定時自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架、CI 及家族工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | 顯示在 tmux 狀態列的番茄鐘，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 以滑鼠沿 tmux 狀態列拖動視窗標籤，以移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 把滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本及終端機啟用的合理預設設定，不改動你自行設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：8 種版面，包括 BSP 的 dwindle 及 spiral，並支援還原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 在 tmux 狀態列顯示本地時鐘及世界時鐘，按時段著色，附倒數及夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在 tmux 狀態列顯示來自 wttr.in 的天氣，在背景擷取，狀態列從不等待 |

### 檢查安裝

所有成員都在磁碟上時，一個指令即可報告它們之間的衝突：

```sh
family/bin/doctor --live
```

它讀取每個成員及正在運行的 tmux 伺服器，報告重複的按鍵、重複的狀態列佔位符、不符合命名規則的選項，以及約定版本落後的成員。

<!-- family:end -->
