<div align="center">

# tmux-battery-revamped

<strong>在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#運作原理">運作原理</a> &nbsp;|&nbsp;
  <a href="#畫面">畫面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="battery-revamped 按級別着色顯示電量、狀態和剩餘時間，電量降到偏低和危急，開啟卡片彈出視窗，切換到 Nerd Font 標籤、迷你圖和 options 繪製模式" width="800">
</p>

```console
$ battery-revamped refresh
Refreshed. 100% charge, charged.
$ battery-revamped status percentage
100%
```

**20** 個佔位符，**2** 種繪製模式，支援 macOS 和 Linux，需要 tmux **3.2** 或更高版本。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:-----|:-----|
| tmux | 3.2 或更高 | 家族共同的最低版本，也用於彈出視窗 |
| gum | 可選 | `battery-revamped` 的選單、表格和顏色；沒有它時每個指令都輸出純文字 |
| `osascript`、`notify-send` | 可選 | `@battery_revamped_notify` 為 `1` 時的桌面通知 |

它在 Linux 和 macOS 上執行，可使用 BSD、GNU、uutils 或 BusyBox 工具。每個數值都來自系統自帶的東西：

| 數值 | Linux | macOS |
|:-----|:-----|:-----|
| 電量和狀態 | 第一個有可讀 `capacity` 的 `/sys/class/power_supply/BAT*`，然後是 `acpi` | `pmset` |
| 剩餘時間 | `acpi`，然後由 `energy_now` 或 `charge_now` 計數器計算 | `pmset` |
| 瓦數 | 目前功耗 `power_now` | `system_profiler`，充電器的額定瓦數 |
| 循環次數 | `cycle_count` | `ioreg` |
| 健康度 | `energy_full` 除以 `energy_full_design`，然後是 `charge_*` 這一對 | `ioreg`，`AppleRawMaxCapacity` 除以 `DesignCapacity` |

缺少來源的數值，其佔位符為空，`battery-revamped doctor` 會指出它。沒有電池的機器不顯示任何內容。

### 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，把插件加入 `~/.tmux.conf` 並按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
```

手動安裝時，複製儲存庫，並在 `~/.tmux.conf` 中執行入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

請在插件載入之前設定 `status-left` 或 `status-right`。插件只在載入時替換一次其中的佔位符。

在複製的目錄中執行 `make install`，還會把 `battery-revamped` 放進 `~/.local/bin`，把 man 手冊和補全放進 `~/.local/share`。

### 驗證

```bash
~/.tmux/plugins/tmux-battery-revamped/bin/battery-revamped doctor
```

## 用法

本插件顯示手提電腦電池的電量，以及狀態、剩餘時間、瓦數、循環次數、健康度、下降速度、估算和最近電量的迷你圖。狀態列顯示 tmux 已經儲存的值，背景讀取負責更新它。

| 佔位符 | 輸出 |
|:-----|:-----|
| `#{battery_percentage}` | 電量，例如 `83%` |
| `#{battery_icon}` | 目前電量級別的圖示 |
| `#{battery_icon_charge}` | 與 `#{battery_icon}` 相同的圖示 |
| `#{battery_icon_status}` | 目前狀態的圖示 |
| `#{battery_color_fg}` | 目前狀態的前景樣式 |
| `#{battery_color_bg}` | 目前狀態的背景樣式 |
| `#{battery_color_charge_fg}` | 目前電量級別的前景樣式 |
| `#{battery_color_charge_bg}` | 目前電量級別的背景樣式 |
| `#{battery_color_status_fg}` | 與 `#{battery_color_fg}` 相同的樣式 |
| `#{battery_color_status_bg}` | 與 `#{battery_color_bg}` 相同的樣式 |
| `#{battery_graph}` | 電量條，例如 `█████░░░░░` |
| `#{battery_remain}` | 系統報告的剩餘時間，例如 `4:32` |
| `#{battery_charging_watts}` | 瓦數，例如 `45W` |
| `#{battery_cycles}` | 充放電循環次數 |
| `#{battery_health}` | 滿充容量除以設計容量，例如 `96%` |
| `#{battery_drain_rate}` | 至少相隔五分鐘量度的每小時下降百分比，例如 `12.5%/h` |
| `#{battery_estimate}` | 按下降速度計算的剩餘時間，例如 `2:00` |
| `#{battery_sparkline}` | 最近電量讀數的迷你圖，例如 `▇▇▆▆▅` |
| `#{battery_power_source}` | `AC`，放電時為 `Bat` |
| `#{battery_alert_icon}` | 放電時電量偏低或危急期間顯示的符號，否則為空 |

狀態是 `charged`、`charging`、`discharging`、`attached` 或 `unknown` 之一。`attached` 表示接上交流電但沒有充電。

把佔位符放進狀態列：

```tmux
set -g @battery_revamped_status_discharging_fg_color '#[fg=yellow]'
set -g @battery_revamped_status_charging_fg_color '#[fg=green]'

set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

同一個示例加上幾個選項，見 [examples/status-right.tmux.conf](examples/status-right.tmux.conf)。

### 標籤和闊度

`@battery_revamped_<metric>_label` 在某個指標的值非空時，在它前面列印一個圖示或詞。`@battery_revamped_icons` 設為 `nerd` 時，下面每個指標前都有 Nerd Font 字形標籤。指標自己的標籤優先於這組字形；在 tmux 中設為空的標籤表示預設值，所以字形保留。把標籤設為 `off`，就既不顯示標籤也不顯示字形。`off` 也能隱藏任何圖示或文字選項，例如 `@battery_revamped_low_icon` 或 `@battery_revamped_graph_full`。預設的 `ascii` 不加標籤。

| 指標 | `nerd` 字形 |
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

`@battery_revamped_fixed_width` 設為 `on` 時，電量在左側補齊到自然闊度，即四個字元，所以由 `9%` 變成 `42%` 不會令這一行的其餘部分移位。`@battery_revamped_<metric>_width` 設定某個指標的闊度，並優先於固定闊度。過長的值不會被截斷。

### 電量前後的文字

`@battery_revamped_before` 和 `@battery_revamped_after` 只在 `#{battery_percentage}` 有輸出時，把文字放在它前後。其中 `{icon}` 變為電量圖示，`{color}` 變為去掉 `#[fg=` 包裝的電量級別顏色，所以 `#[fg={color}]{icon} ` 會給圖示着色。

### 繪製模式

預設情況下，每個佔位符變成一個 `#()` 呼叫，tmux 在狀態列重繪時重新執行它。把 `@battery_revamped_render` 設為 `options` 後，每個佔位符變成對選項的讀取，例如 `#{E:@battery_revamped_out_percentage}`。每個伺服器隨後有一個背景進程每隔 `@battery_revamped_interval` 秒讀取一次電池，並用一次 tmux 呼叫寫入所有數值，所以它們一起變化。

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

### 通知

`@battery_revamped_notify` 設為 `1` 時，電量進入偏低、危急或充滿時發送一次桌面通知：macOS 上用 `osascript`，Linux 上用 `notify-send`。每次跨過界線只通知一次。預設是 `0`，狀態始終顯示在狀態列和卡片中。

### 級別顏色

顏色選項預設為空，所以設定之前顏色佔位符不輸出任何內容。下面的配色把級別 1 至 3 對應為紅色，4 至 6 為黃色，7 和 8 為綠色：

| 主題 | 低 | 中 | 高 |
|:-----|:-----|:-----|:-----|
| Catppuccin Mocha | `#f38ba8` | `#f9e2af` | `#a6e3a1` |
| Dracula | `#ff5555` | `#f1fa8c` | `#50fa7b` |
| Nord | `#bf616a` | `#ebcb8b` | `#a3be8c` |
| Gruvbox Dark | `#fb4934` | `#fabd2f` | `#b8bb26` |
| Tokyo Night | `#f7768e` | `#e0af68` | `#9ece6a` |
| Solarized Dark | `#dc322f` | `#b58900` | `#859900` |

每個值按級別放進樣式，例如 `set -g @battery_revamped_charge_tier1_fg_color '#[fg=#f38ba8]'`。各狀態也用 `@battery_revamped_status_<state>_fg_color` 採用相同的樣式。

| 指令 | 作用 |
|:-----|:-----|
| `battery-revamped apply` | 立即綁定彈出視窗按鍵並填充佔位符；tmux 載入插件時由入口腳本執行 |
| `battery-revamped list` | 列出 `apply` 會發送的每條指令，不做任何更改；`--json` 輸出一個物件 |
| `battery-revamped status NAME` | 輸出一個佔位符，例如 `percentage`、`remain` 或 `graph`；狀態列執行它；不是佔位符的名稱不輸出任何內容 |
| `battery-revamped refresh` | 立即讀取電池並說明目前情況 |
| `battery-revamped card` | 輸出已儲存的讀數，每個數值一行；沒有儲存任何讀數時先讀取電池 |
| `battery-revamped popup` | 在 tmux 彈出視窗中開啟卡片；彈出視窗按鍵執行它 |
| `battery-revamped popup-card` | 輸出卡片並等待按鍵，彈出視窗執行的就是它 |
| `battery-revamped daemon` | 為 `options` 繪製模式在每個節拍發布佔位符；由 `apply` 啟動 |
| `battery-revamped doctor` | 每個依賴一行：每個數值的來源工具或檔案、彈出視窗、設定、通知方式，以及被放過的按鍵 |
| `battery-revamped version` | 版本，然後是 tmux 版本 |
| `battery-revamped help` | 說明頁面；`man battery-revamped` 記載相同的指令和設定 |
| `battery-revamped` | 在終端機中顯示選單 |

## 設定

每個選項也是帶短橫線的指令選項，例如 `--interval 2`，也是環境變數，例如 `BATTERY_REVAMPED_INTERVAL`；指令列優先於環境變數，環境變數優先於 tmux 選項。為空的 tmux 選項表示預設值；在指令列或環境變數中給出的空值按原樣使用。`doctor` 會指出持有插件不認識的值的設定。傳給 `apply` 的設定會隨彈出視窗按鍵和每次狀態呼叫一併傳遞。

### 讀取和警報

| 選項 | 預設 | 含義 |
|:-----|:-----|:-----|
| `@battery_revamped_interval` | `15` | 電量和狀態讀數保持新鮮的秒數，選項繪製模式的計時器也接受 `minute` |
| `@battery_revamped_detail_interval` | `60` | 剩餘時間、瓦數、循環次數和健康度保持新鮮的秒數 |
| `@battery_revamped_render` | `jobs` | `options` 讀取已發布的選項，而不是執行 `#()` 呼叫；其他任何值都表示 `jobs` |
| `@battery_revamped_history_size` | `16` | 為 `#{battery_sparkline}` 保留的讀數個數 |
| `@battery_revamped_low_threshold` | `20` | 放電時視為偏低的電量百分比 |
| `@battery_revamped_critical_threshold` | `10` | 放電時視為危急的電量百分比 |
| `@battery_revamped_low_icon`, `@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}` 在電量偏低和危急時輸出的內容 |
| `@battery_revamped_hide_on_ac` | `0` | 設為 `1` 時，除非正在放電，否則每個佔位符都為空 |
| `@battery_revamped_notify` | `0` | 設為 `1` 時，電量進入偏低、危急或充滿時發送桌面通知 |

### 圖示和顏色

| 選項 | 預設 | 含義 |
|:-----|:-----|:-----|
| `@battery_revamped_icons` | `ascii` | `nerd` 為八個級別使用 Nerd Font 電池字形，並帶有充電變體，同時給每個指標加標籤；級別圖示選項仍然優先 |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` to `█` | 每個電量級別的圖示，級別 1 最低 |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 每個電量級別的顏色，例如 `#[fg=green]` |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | 每個狀態的圖示；`attached` 表示接上交流電但沒有充電 |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 每個狀態的顏色 |
| `@battery_revamped_source_ac_label`, `@battery_revamped_source_battery_label` | `AC`, `Bat` | 沒有使用電池和使用電池時 `#{battery_power_source}` 的文字 |
| `@battery_revamped_before`, `@battery_revamped_after` | 空 | 只在 `#{battery_percentage}` 有輸出時放在它前後的文字；`{icon}` 變為電量圖示，`{color}` 變為電量級別的顏色 |

### 格式和標籤

| 選項 | 預設 | 含義 |
|:-----|:-----|:-----|
| `@battery_revamped_percentage_format` | `%s%%` | 電量的 printf 格式 |
| `@battery_revamped_remain_format` | `%s` | 兩個剩餘時間佔位符共用的 printf 格式 |
| `@battery_revamped_watts_format` | `%sW` | 瓦數的 printf 格式 |
| `@battery_revamped_cycles_format` | `%s` | 循環次數的 printf 格式 |
| `@battery_revamped_health_format` | `%s%%` | 健康度的 printf 格式 |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 下降速度的 printf 格式 |
| `@battery_revamped_graph_width` | `10` | 電量條的格數，也是它補齊到的闊度 |
| `@battery_revamped_graph_full` | `█` | 已填充的格子 |
| `@battery_revamped_graph_empty` | `░` | 空格子 |
| `@battery_revamped_<metric>_label` | 空 | 只在值非空時，列印在某個指標的值之前的文字 |
| `@battery_revamped_fixed_width` | `off` | 設為 `on` 時，電量在左側補齊到自然闊度，即四個字元 |
| `@battery_revamped_<metric>_width` | 空 | 把某個指標補齊到這麼多字元；過長的值不會被截斷 |

可帶標籤和闊度的指標是 `percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline` 或 `power_source`。

### 彈出視窗

| 選項 | 預設 | 含義 |
|:-----|:-----|:-----|
| `@battery_revamped_popup_key` | `M-b` | 開啟卡片彈出視窗的前綴按鍵。`off` 表示不綁定 |
| `@battery_revamped_popup_width` | `44` | 彈出視窗闊度 |
| `@battery_revamped_popup_height` | `16` | 彈出視窗高度 |

### 內部狀態

插件自己寫入這些選項，請勿設定它們。

| 選項 | 儲存的內容 |
|:-----|:-----|
| `@battery_revamped_published` | 狀態列使用的指標，在載入時記錄，使 options 模式只寫入這些 |
| `@battery_revamped_out_<metric>` | options 模式下每個指標的繪製結果 |
| `@battery_revamped_ticker_pid` | options 模式背景進程的進程號 |
| `@battery_revamped_history` | `#{battery_sparkline}` 背後的最近電量讀數 |
| `@battery_revamped_alert_level` | 最後一次看到的級別，`ok`、`low`、`critical`、`full` 或 `unknown`，使每次跨過界線只通知一次 |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 下降速度的量度起點讀數 |
| `@battery_revamped_percent` 和其他數值、`_ts`、`_lock` | 儲存的讀數、每次讀取的時間和更新鎖 |

## 按鍵綁定

| 按鍵 | 動作 | 預設 |
|:-----|:-----|:-----|
| `prefix + M-b` | 在彈出視窗中開啟已儲存讀數的卡片，按任意鍵關閉 | 已綁定 |

`@battery_revamped_popup_key` 可指定另一個按鍵，`off` 表示不綁定。預設按鍵已被其他綁定佔用時會被放過，`battery-revamped doctor` 會說明。

<a id="運作原理"></a>

## 運作原理

tmux 載入插件時，[`battery-revamped.tmux`](battery-revamped.tmux) 執行一次。它把 `status-left` 和 `status-right` 用到的指標記錄在 `@battery_revamped_published` 中，然後把每個佔位符替換為對 [`bin/battery-revamped`](bin/battery-revamped) 的呼叫；在 `options` 模式下則替換為選項讀取，並啟動背景進程。

在預設模式下，每個 `#()` 呼叫立即返回已儲存的讀數。讀數比間隔舊時，呼叫會在背景啟動更新並加鎖，所以同一時間只有一個更新在執行。剩餘時間、瓦數、循環次數和健康度的讀取成本較高，所以每隔 `@battery_revamped_detail_interval` 秒更新一次。一次 tmux 呼叫儲存所有數值。下降速度用目前電量與至少五分鐘前的讀數比較得出，`#{battery_estimate}` 用剩餘電量除以這個速度。

每次進入偏低、危急或充滿，都透過共用的通知程式發送一次通知。讀取、數值和格式化位於 [`lib/battery.sh`](lib/battery.sh)，設定表位於 [`lib/state.sh`](lib/state.sh)。

<a id="畫面"></a>

## 畫面

<details>
<summary>每個畫面都用 <code>make screens</code> 在真實的 tmux 中錄製，每個按鍵都顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="battery-revamped: 帶級別圖示和顏色的電量、狀態、剩餘時間和電源"><br><sub>帶級別圖示和顏色的電量、狀態、剩餘時間和電源，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="battery-revamped: prefix M-b 在彈出視窗中開啟卡片"><br><sub><code>prefix M-b</code> 在彈出視窗中開啟卡片，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="battery-revamped: @battery_revamped_icons 設為 nerd 時每個級別有字形並帶標籤"><br><sub><code>@battery_revamped_icons</code> 設為 <code>nerd</code> 時每個級別有字形並帶標籤，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="battery-revamped: 電量條、電量和迷你圖"><br><sub>電量條、電量和迷你圖，來自 <code>hero.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="battery-revamped: 在 options 繪製模式下每個佔位符讀取一個 tmux 選項"><br><sub>在 <code>options</code> 繪製模式下每個佔位符讀取一個 tmux 選項，來自 <code>hero.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/drain.png" alt="battery-revamped: 每小時的下降百分比"><br><sub>每小時的下降百分比，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/estimate.png" alt="battery-revamped: 估算、下降速度和剩餘時間"><br><sub>估算、下降速度和剩餘時間，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/estimate-label.png" alt="battery-revamped: @battery_revamped_estimate_label 在估算前放一個詞"><br><sub><code>@battery_revamped_estimate_label</code> 在估算前放一個詞，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/drain-format.png" alt="battery-revamped: @battery_revamped_drain_rate_format 決定下降速度的格式"><br><sub><code>@battery_revamped_drain_rate_format</code> 決定下降速度的格式，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/charging.png" alt="battery-revamped: 充電時估算給出充滿所需的時間"><br><sub>充電時估算給出充滿所需的時間，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/low.png" alt="battery-revamped: 電量偏低時的警報圖示"><br><sub>電量偏低時的警報圖示，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/thresholds.png" alt="battery-revamped: @battery_revamped_low_threshold 移動偏低的界線"><br><sub><code>@battery_revamped_low_threshold</code> 移動偏低的界線，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/critical.png" alt="battery-revamped: 電量危急時的警報圖示"><br><sub>電量危急時的警報圖示，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/critical-threshold.png" alt="battery-revamped: @battery_revamped_critical_threshold 移動危急的界線"><br><sub><code>@battery_revamped_critical_threshold</code> 移動危急的界線，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/alert-icons.png" alt="battery-revamped: @battery_revamped_low_icon 和 @battery_revamped_critical_icon 指定警報符號"><br><sub><code>@battery_revamped_low_icon</code> 和 <code>@battery_revamped_critical_icon</code> 指定警報符號，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-charged.png" alt="battery-revamped: 充滿狀態"><br><sub>充滿狀態，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/state-attached.png" alt="battery-revamped: 接上交流電但未充電的狀態"><br><sub>接上交流電但未充電的狀態，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/state-unknown.png" alt="battery-revamped: 未知狀態"><br><sub>未知狀態，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status-icons.png" alt="battery-revamped: @battery_revamped_status_<state>_icon 及其顏色"><br><sub><code>@battery_revamped_status_<state>_icon</code> 及其顏色，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-colors.png" alt="battery-revamped: #{battery_color_status_fg} 和 #{battery_color_status_bg}"><br><sub><code>#{battery_color_status_fg}</code> 和 <code>#{battery_color_status_bg}</code>，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="battery-revamped: @battery_revamped_charge_tier7_icon 及其顏色"><br><sub><code>@battery_revamped_charge_tier7_icon</code> 及其顏色，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/format.png" alt="battery-revamped: @battery_revamped_percentage_format 決定電量的格式"><br><sub><code>@battery_revamped_percentage_format</code> 決定電量的格式，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/remain-format.png" alt="battery-revamped: @battery_revamped_remain_format 決定剩餘時間的格式"><br><sub><code>@battery_revamped_remain_format</code> 決定剩餘時間的格式，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/details.png" alt="battery-revamped: 瓦數、循環次數和健康度"><br><sub>瓦數、循環次數和健康度，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/detail-formats.png" alt="battery-revamped: @battery_revamped_watts_format、_cycles_format 和 _health_format"><br><sub><code>@battery_revamped_watts_format</code>、<code>_cycles_format</code> 和 <code>_health_format</code>，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/detail-interval.png" alt="battery-revamped: @battery_revamped_detail_interval 決定讀取詳細數據的頻率"><br><sub><code>@battery_revamped_detail_interval</code> 決定讀取詳細數據的頻率，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="battery-revamped: @battery_revamped_fixed_width 把電量補齊到自然闊度"><br><sub><code>@battery_revamped_fixed_width</code> 把電量補齊到自然闊度，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/width.png" alt="battery-revamped: @battery_revamped_percentage_width 把某個指標補齊到自己的闊度"><br><sub><code>@battery_revamped_percentage_width</code> 把某個指標補齊到自己的闊度，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="battery-revamped: 電量前的專屬標籤"><br><sub>電量前的專屬標籤，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/label-health.png" alt="battery-revamped: 健康度前的專屬標籤"><br><sub>健康度前的專屬標籤，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/graph-width.png" alt="battery-revamped: @battery_revamped_graph_width、_graph_full 和 _graph_empty 決定電量條的樣子"><br><sub><code>@battery_revamped_graph_width</code>、<code>_graph_full</code> 和 <code>_graph_empty</code> 決定電量條的樣子，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/power-source.png" alt="battery-revamped: @battery_revamped_source_battery_label 和 _source_ac_label"><br><sub><code>@battery_revamped_source_battery_label</code> 和 <code>_source_ac_label</code>，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/power-source-ac.png" alt="battery-revamped: 充電時的電源標籤"><br><sub>充電時的電源標籤，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/hide-on-ac.png" alt="battery-revamped: @battery_revamped_hide_on_ac 讓不使用電池時的每個佔位符都為空"><br><sub><code>@battery_revamped_hide_on_ac</code> 讓不使用電池時的每個佔位符都為空，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/before-after.png" alt="battery-revamped: @battery_revamped_before 和 _after 配合 {icon} 和 {color}"><br><sub><code>@battery_revamped_before</code> 和 <code>_after</code> 配合 <code>{icon}</code> 和 <code>{color}</code>，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/notify.png" alt="battery-revamped: @battery_revamped_notify 每跨過一個界線發送一次通知，這裏顯示的是替身通知程式的記錄"><br><sub><code>@battery_revamped_notify</code> 每跨過一個界線發送一次通知，這裏顯示的是替身通知程式的記錄，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-size.png" alt="battery-revamped: @battery_revamped_popup_width 和 _popup_height 決定彈出視窗大小"><br><sub><code>@battery_revamped_popup_width</code> 和 <code>_popup_height</code> 決定彈出視窗大小，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="battery-revamped: @battery_revamped_popup_key 為彈出視窗指定另一個按鍵"><br><sub><code>@battery_revamped_popup_key</code> 為彈出視窗指定另一個按鍵，來自 <code>features.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/interval.png" alt="battery-revamped: @battery_revamped_interval 決定讀數保持新鮮的時長"><br><sub><code>@battery_revamped_interval</code> 決定讀數保持新鮮的時長，來自 <code>features.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="battery-revamped: 版本"><br><sub>版本，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="battery-revamped: 未知指令"><br><sub>未知指令，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="battery-revamped: status percentage 和 status graph 各輸出一個佔位符"><br><sub><code>status percentage</code> 和 <code>status graph</code> 各輸出一個佔位符，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="battery-revamped: refresh 立即讀取電池"><br><sub><code>refresh</code> 立即讀取電池，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="battery-revamped: card 輸出每個數值"><br><sub><code>card</code> 輸出每個數值，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="battery-revamped: list 列出每個綁定"><br><sub><code>list</code> 列出每個綁定，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="battery-revamped: list --json 把同一份計劃輸出為一個物件"><br><sub><code>list --json</code> 把同一份計劃輸出為一個物件，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="battery-revamped: doctor"><br><sub><code>doctor</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="battery-revamped: 選單"><br><sub>選單，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="battery-revamped: 從選單開啟的卡片"><br><sub>從選單開啟的卡片，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="battery-revamped: 來自 BATTERY_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>BATTERY_REVAMPED_ACCENT</code> 的強調色，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="battery-revamped: 沒有 gum 的選單"><br><sub>沒有 gum 的選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="battery-revamped: 沒有 gum 時從選單執行的 doctor"><br><sub>沒有 gum 時從選單執行的 <code>doctor</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="battery-revamped: 沒有 gum 的 card"><br><sub>沒有 gum 的 <code>card</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="battery-revamped: 六個主題下的標題"><br><sub>六個主題下的標題，來自 <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="battery-revamped: 說明頁面"><br><sub>說明頁面，來自 <code>help.tape</code></sub></td>
</tr>
</table>

錄製執行真實的插件和 tmux。`pmset`、`system_profiler`、`ioreg` 和 `osascript` 由小腳本代替，所以畫面上的數值來自它們；除非錄製改變它，電池保持同一個狀態。

</details>

## 可攜性

插件是 POSIX `sh`。CI 在下面每一行上執行全部測試。

| Shell | 狀態 |
|:-----|:-----|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統自帶的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-----|:-----|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用系統自帶的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:-----|:-----|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零警告 |
| `make test` | 在系統 `sh` 下執行 bats 測試 |
| `make test-all` | 在每個已安裝的 shell 下執行測試，macOS 上包括 bash 和 zsh 的兩種建置 |
| `make test-linux` | 在 Ubuntu 容器中執行測試 |
| `make coverage` | 在這部 Mac 和 Ubuntu 容器中執行 bashcov，合併後以 100% 為門檻 |
| `make screens` | 用 VHS 在 tmux 中從真實插件錄製上面的畫面，在 macOS 上執行 |
| `make install` | 把指令、man 手冊和補全安裝到 `PREFIX` 下 |

在 macOS 上，執行 `brew bundle` 會根據 [`Brewfile`](Brewfile) 安裝這些目標用到的所有工具。

提交遵循 Conventional Commits 格式，直接進入 `main`。`main` 上的 `ci` 通過後，`release.yml` 執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發布新版本，更新版本常數，並把說明寫進 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | **本插件**，在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->

