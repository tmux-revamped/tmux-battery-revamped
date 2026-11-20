<div align="center">

# tmux-battery-revamped

<strong>tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#仕組み">仕組み</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="段階ごとの色で電池残量と状態、残り時間を表示し、低い残量と危険な残量に下がり、カードのポップアップを開き、Nerd Font のラベル、スパークライン、options 描画モードに切り替える battery-revamped" width="800">
</p>

```console
$ battery-revamped refresh
Refreshed. 100% charge, charged.
$ battery-revamped status percentage
100%
```

プレースホルダー **20** 個、描画モード **2** つ、macOS と Linux、tmux **3.2** 以降。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:-----|:-----|
| tmux | 3.2 以降 | ファミリー共通の最低バージョン。ポップアップにも必要です |
| gum | 任意 | `battery-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |
| `osascript`、`notify-send` | 任意 | `@battery_revamped_notify` が `1` のときのデスクトップ通知 |

Linux と macOS で、BSD、GNU、uutils、BusyBox のいずれのツールでも動作します。各値は OS に付属するものから取得します。

| 値 | Linux | macOS |
|:-----|:-----|:-----|
| 残量と状態 | `capacity` を読める最初の `/sys/class/power_supply/BAT*`、次に `acpi` | `pmset` |
| 残り時間 | `acpi`、次に `energy_now` か `charge_now` のカウンターからの計算 | `pmset` |
| ワット数 | 現在の消費電力 `power_now` | `system_profiler`、充電器の定格ワット数 |
| サイクル数 | `cycle_count` | `ioreg` |
| 健全性 | `energy_full` を `energy_full_design` で割った値、次に `charge_*` の組 | `ioreg`、`AppleRawMaxCapacity` を `DesignCapacity` で割った値 |

取得元がない値のプレースホルダーは空になり、`battery-revamped doctor` が名前を挙げます。電池のないマシンでは何も表示しません。

### インストール

[TPM](https://github.com/tmux-plugins/tpm) を使う場合は、プラグインを `~/.tmux.conf` に追加して `prefix + I` を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
```

手動でインストールする場合は、リポジトリをクローンして `~/.tmux.conf` からエントリポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

プラグインを読み込む前に `status-left` か `status-right` を設定してください。プラグインは、そこにあるプレースホルダーを読み込み時に 1 回だけ置き換えます。

クローンで `make install` を実行すると、`battery-revamped` が `~/.local/bin` に、man ページと補完が `~/.local/share` に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-battery-revamped/bin/battery-revamped doctor
```

## 使い方

このプラグインは、ノート PC の電池残量を、状態、残り時間、ワット数、サイクル数、健全性、減少率、見積もり、最近の残量のスパークラインとともに表示します。ステータスラインは tmux がすでに持っている値を表示し、バックグラウンドの読み取りがそれを更新します。

| プレースホルダー | 出力 |
|:-----|:-----|
| `#{battery_percentage}` | 電池残量で、たとえば`83%`です |
| `#{battery_icon}` | 現在の残量段階のアイコンです |
| `#{battery_icon_charge}` | `#{battery_icon}` と同じアイコンです |
| `#{battery_icon_status}` | 現在の状態のアイコンです |
| `#{battery_color_fg}` | 現在の状態の前景のスタイルです |
| `#{battery_color_bg}` | 現在の状態の背景のスタイルです |
| `#{battery_color_charge_fg}` | 現在の残量段階の前景のスタイルです |
| `#{battery_color_charge_bg}` | 現在の残量段階の背景のスタイルです |
| `#{battery_color_status_fg}` | `#{battery_color_fg}` と同じスタイルです |
| `#{battery_color_status_bg}` | `#{battery_color_bg}` と同じスタイルです |
| `#{battery_graph}` | 残量バーで、たとえば`█████░░░░░`です |
| `#{battery_remain}` | システムが報告する残り時間で、たとえば`4:32`です |
| `#{battery_charging_watts}` | ワット数で、たとえば`45W`です |
| `#{battery_cycles}` | 充放電サイクル数です |
| `#{battery_health}` | 満充電容量を設計容量で割った値で、たとえば`96%`です |
| `#{battery_drain_rate}` | 5 分以上の間隔で測った 1 時間あたりの減少率で、たとえば`12.5%/h`です |
| `#{battery_estimate}` | 減少率から計算した残り時間で、たとえば`2:00`です |
| `#{battery_sparkline}` | 最近の残量のスパークラインで、たとえば`▇▇▆▆▅`です |
| `#{battery_power_source}` | `AC`、放電中は`Bat`です |
| `#{battery_alert_icon}` | 放電中に残量が低いか危険な間表示する記号で、それ以外は空です |

状態は `charged`、`charging`、`discharging`、`attached`、`unknown` のいずれかです。`attached` は AC 電源につながっていて充電していない状態です。

ステータスラインにプレースホルダーを置きます。

```tmux
set -g @battery_revamped_status_discharging_fg_color '#[fg=yellow]'
set -g @battery_revamped_status_charging_fg_color '#[fg=green]'

set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

オプションをいくつか足した同じ例が [examples/status-right.tmux.conf](examples/status-right.tmux.conf) にあります。

### ラベルと幅

`@battery_revamped_<metric>_label` は、値が空でないときだけ、1 つの指標の前にアイコンや語を表示します。`@battery_revamped_icons` を `nerd` にすると、下の各指標に Nerd Font の記号のラベルが付きます。指標ごとのラベルはこのセットより優先されます。tmux で空にしたラベルは既定値を意味するので記号は残ります。ラベルも記号も出さないには、ラベルを `off` にします。`off` は `@battery_revamped_low_icon` や `@battery_revamped_graph_full` など、どのアイコンやテキストのオプションも隠します。既定の `ascii` はラベルを付けません。

| 指標 | `nerd` の記号 |
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

`@battery_revamped_fixed_width` を `on` にすると、残量を自然な幅の 4 文字まで左側で埋めるので、`9%` から `42%` に変わっても行の残りがずれません。`@battery_revamped_<metric>_width` は 1 つの指標の幅を決め、固定幅より優先されます。これより長い値は切りません。

### 残量の前後

`@battery_revamped_before` と `@battery_revamped_after` は、`#{battery_percentage}` が表示されるときだけ、その前後に文字を置きます。中の `{icon}` は残量アイコン、`{color}` は `#[fg=` の包みを外した残量段階の色になるので、`#[fg={color}]{icon} ` でアイコンに色が付きます。

### 描画モード

既定では各プレースホルダーが `#()` 呼び出しになり、tmux がステータスの再描画のたびに再実行します。`@battery_revamped_render` を `options` にすると、各プレースホルダーが `#{E:@battery_revamped_out_percentage}` のようなオプションの読み取りになります。サーバーごとに 1 つのバックグラウンドプロセスが `@battery_revamped_interval` 秒ごとに電池を読み取り、すべての値を 1 回の tmux 呼び出しで書き込むので、値は一緒に変わります。

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

### 通知

`@battery_revamped_notify` を `1` にすると、残量が低、危険、満充電になったときにデスクトップ通知を 1 回送ります。macOS では `osascript`、Linux では `notify-send` を使います。境目を越えるたびに 1 回だけ通知します。既定は `0` で、状態は常にステータスラインとカードに表示されます。

### 段階ごとの色

色のオプションは既定で空なので、設定するまで色のプレースホルダーは何も表示しません。次のパレットは、段階 1 から 3 を赤、4 から 6 を黄、7 と 8 を緑に割り当てます。

| テーマ | 低 | 中 | 高 |
|:-----|:-----|:-----|:-----|
| Catppuccin Mocha | `#f38ba8` | `#f9e2af` | `#a6e3a1` |
| Dracula | `#ff5555` | `#f1fa8c` | `#50fa7b` |
| Nord | `#bf616a` | `#ebcb8b` | `#a3be8c` |
| Gruvbox Dark | `#fb4934` | `#fabd2f` | `#b8bb26` |
| Tokyo Night | `#f7768e` | `#e0af68` | `#9ece6a` |
| Solarized Dark | `#dc322f` | `#b58900` | `#859900` |

各値は段階ごとにスタイルに入れます。たとえば `set -g @battery_revamped_charge_tier1_fg_color '#[fg=#f38ba8]'` です。状態にも `@battery_revamped_status_<state>_fg_color` で同じスタイルを使えます。

| コマンド | 動作 |
|:-----|:-----|
| `battery-revamped apply` | ポップアップのキーをバインドしてプレースホルダーを今すぐ埋めます。tmux がプラグインを読み込むときにエントリポイントが実行します |
| `battery-revamped list` | `apply` が送るコマンドをすべて表示し、何も変更しません。`--json` は 1 つのオブジェクトを出力します |
| `battery-revamped status NAME` | `percentage`、`remain`、`graph` などのプレースホルダーを 1 つ表示します。ステータスラインが実行します。プレースホルダーでない名前は何も表示しません |
| `battery-revamped refresh` | 電池を今すぐ読み取り、現在の状態を伝えます |
| `battery-revamped card` | 保存済みの読み取りを 1 つの値につき 1 行で表示します。何も保存されていなければ先に電池を読み取ります |
| `battery-revamped popup` | tmux のポップアップでカードを開きます。ポップアップのキーが実行します |
| `battery-revamped popup-card` | カードを表示してキー入力を待ちます。ポップアップが実行するのはこれです |
| `battery-revamped daemon` | options 描画モードのために、ティックごとにプレースホルダーを公開します。`apply` が起動します |
| `battery-revamped doctor` | 依存関係ごとに 1 行を表示します。各値の取得元のツールやファイル、ポップアップ、設定、通知手段、使わずに残したキーです |
| `battery-revamped version` | バージョンと tmux のバージョンを表示します |
| `battery-revamped help` | ヘルプページです。`man battery-revamped` も同じコマンドと設定を説明します |
| `battery-revamped` | ターミナルではメニューを表示します |

## 設定

すべてのオプションは、`--interval 2` のようなダッシュ付きのコマンドオプションと、`BATTERY_REVAMPED_INTERVAL` のような環境変数でも指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。tmux オプションを空にすると既定値を意味します。コマンドラインや環境変数で空の値を渡した場合は、そのまま使います。`doctor` は、プラグインが知らない値を持つ設定を挙げます。`apply` に渡した設定は、ポップアップのキーとすべてのステータス呼び出しに引き継がれます。

### 読み取りと警告

| オプション | 既定値 | 意味 |
|:-----|:-----|:-----|
| `@battery_revamped_interval` | `15` | 電池残量と状態の読み取りが新しいとみなす秒数です。options 描画モードのティッカーでは `minute` も使えます |
| `@battery_revamped_detail_interval` | `60` | 残り時間、ワット数、サイクル数、健全性が新しいとみなす秒数です |
| `@battery_revamped_render` | `jobs` | `options` は `#()` を実行する代わりに公開されたオプションを読みます。それ以外の値は `jobs` を意味します |
| `@battery_revamped_history_size` | `16` | `#{battery_sparkline}` のために保持する読み取りの数です |
| `@battery_revamped_low_threshold` | `20` | 放電中に低いとみなす残量のパーセントです |
| `@battery_revamped_critical_threshold` | `10` | 放電中に危険とみなす残量のパーセントです |
| `@battery_revamped_low_icon`, `@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}` が低い残量と危険な残量で表示するものです |
| `@battery_revamped_hide_on_ac` | `0` | `1` にすると、放電中でない限りすべてのプレースホルダーが空になります |
| `@battery_revamped_notify` | `0` | `1` にすると、残量が低、危険、満充電になったときにデスクトップ通知を送ります |

### アイコンと色

| オプション | 既定値 | 意味 |
|:-----|:-----|:-----|
| `@battery_revamped_icons` | `ascii` | `nerd` は 8 段階に充電中の変種を含む Nerd Font の電池記号を使い、すべての指標にラベルを付けます。段階ごとのアイコンのオプションが優先されます |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁` to `█` | 各残量段階のアイコンです。段階 1 が最も低い段階です |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 各残量段階の色で、たとえば`#[fg=green]`です |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`, `+`, `-`, `!`, `?` | 各状態のアイコンです。`attached` は AC 電源につながっていて充電していない状態です |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 各状態の色です |
| `@battery_revamped_source_ac_label`, `@battery_revamped_source_battery_label` | `AC`, `Bat` | 電池を使っていないときと使っているときの `#{battery_power_source}` の文字です |
| `@battery_revamped_before`, `@battery_revamped_after` | 空 | `#{battery_percentage}` が表示されるときだけその前後に置く文字です。`{icon}` は残量アイコン、`{color}` は残量段階の色になります |

### 書式とラベル

| オプション | 既定値 | 意味 |
|:-----|:-----|:-----|
| `@battery_revamped_percentage_format` | `%s%%` | 残量の printf 書式です |
| `@battery_revamped_remain_format` | `%s` | 2 つの残り時間プレースホルダーの printf 書式です |
| `@battery_revamped_watts_format` | `%sW` | ワット数の printf 書式です |
| `@battery_revamped_cycles_format` | `%s` | サイクル数の printf 書式です |
| `@battery_revamped_health_format` | `%s%%` | 健全性の printf 書式です |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 減少率の printf 書式です |
| `@battery_revamped_graph_width` | `10` | 残量バーのセル数で、バーを埋める幅でもあります |
| `@battery_revamped_graph_full` | `█` | 埋まったセルです |
| `@battery_revamped_graph_empty` | `░` | 空のセルです |
| `@battery_revamped_<metric>_label` | 空 | 値が空でないときだけ、1 つの指標の値の前に表示する文字です |
| `@battery_revamped_fixed_width` | `off` | `on` にすると、残量を自然な幅の 4 文字まで左側で埋めます |
| `@battery_revamped_<metric>_width` | 空 | 1 つの指標をこの文字数まで埋めます。これより長い値は切りません |

ラベルと幅を持てる指標は、`percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline`、`power_source` です。

### ポップアップ

| オプション | 既定値 | 意味 |
|:-----|:-----|:-----|
| `@battery_revamped_popup_key` | `M-b` | カードのポップアップを開くプレフィックスキーです。`off` は何もバインドしません |
| `@battery_revamped_popup_width` | `44` | ポップアップの幅です |
| `@battery_revamped_popup_height` | `16` | ポップアップの高さです |

### 内部状態

プラグインがこれらのオプションを自分で書き込みます。設定しないでください。

| オプション | 保持する内容 |
|:-----|:-----|
| `@battery_revamped_published` | ステータスラインが使う指標です。読み込み時に記録するので、options モードはそれだけを書き込みます |
| `@battery_revamped_out_<metric>` | options モードでの各指標の描画結果です |
| `@battery_revamped_ticker_pid` | options モードのバックグラウンドプロセスのプロセス ID です |
| `@battery_revamped_history` | `#{battery_sparkline}` の元になる最近の残量の読み取りです |
| `@battery_revamped_alert_level` | 最後に見た段階で、`ok`、`low`、`critical`、`full`、`unknown` のいずれかです。通知が境目ごとに 1 回になるために使います |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 減少率の測定の起点となる読み取りです |
| `@battery_revamped_percent` などの値、`_ts`、`_lock` | 保存された読み取り、各読み取りの時刻、更新のロックです |

## キーバインド

| キー | 動作 | 既定 |
|:-----|:-----|:-----|
| `prefix + M-b` | 保存済みの読み取りのカードをポップアップに開きます。どのキーでも閉じます | バインド済み |

`@battery_revamped_popup_key` で別のキーを指定でき、`off` はバインドしません。既定のキーはすでにほかのバインドが使っている場合は使わずに残され、`battery-revamped doctor` が知らせます。

<a id="仕組み"></a>

## 仕組み

tmux がプラグインを読み込むとき、[`battery-revamped.tmux`](battery-revamped.tmux) が 1 回実行されます。`status-left` と `status-right` が使う指標を `@battery_revamped_published` に記録し、各プレースホルダーを [`bin/battery-revamped`](bin/battery-revamped) の呼び出しに置き換えます。`options` モードではオプションの読み取りに置き換え、バックグラウンドプロセスを起動します。

既定のモードでは、各 `#()` 呼び出しが保存済みの読み取りをすぐに返します。読み取りが間隔より古いと、呼び出しはバックグラウンドで更新を始めてロックを取るので、同時に動く更新は 1 つだけです。残り時間、ワット数、サイクル数、健全性は読み取りの負担が大きいので、`@battery_revamped_detail_interval` 秒ごとに更新します。すべての値は 1 回の tmux 呼び出しで保存します。減少率は残量を 5 分以上前の読み取りと比べて求め、`#{battery_estimate}` は残りの残量をその率で割ります。

通知は、低、危険、満充電に入るたびに 1 回、共有の通知ツールを通して送ります。読み取り、値、書式は [`lib/battery.sh`](lib/battery.sh) に、設定の表は [`lib/state.sh`](lib/state.sh) にあります。

<a id="画面"></a>

## 画面

<details>
<summary>実際の tmux の中で <code>make screens</code> により録画した全画面。押したキーはステータスラインに表示されます</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="battery-revamped: 段階のアイコンと色、状態、残り時間、電源を含む電池残量"><br><sub>段階のアイコンと色、状態、残り時間、電源を含む電池残量、<code>hero.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="battery-revamped: prefix M-b でカードをポップアップに開きます"><br><sub><code>prefix M-b</code> でカードをポップアップに開きます、<code>hero.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/icons.png" alt="battery-revamped: @battery_revamped_icons を nerd にすると段階ごとの記号とラベルが付きます"><br><sub><code>@battery_revamped_icons</code> を <code>nerd</code> にすると段階ごとの記号とラベルが付きます、<code>hero.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/graph.png" alt="battery-revamped: 残量バー、残量、スパークライン"><br><sub>残量バー、残量、スパークライン、<code>hero.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/options.png" alt="battery-revamped: options 描画モードでは各プレースホルダーが tmux オプションを読みます"><br><sub><code>options</code> 描画モードでは各プレースホルダーが tmux オプションを読みます、<code>hero.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/drain.png" alt="battery-revamped: 1 時間あたりの減少率"><br><sub>1 時間あたりの減少率、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/estimate.png" alt="battery-revamped: 見積もり、減少率、残り時間"><br><sub>見積もり、減少率、残り時間、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/estimate-label.png" alt="battery-revamped: @battery_revamped_estimate_label で見積もりの前に語を置きます"><br><sub><code>@battery_revamped_estimate_label</code> で見積もりの前に語を置きます、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/drain-format.png" alt="battery-revamped: @battery_revamped_drain_rate_format で減少率の書式を変えます"><br><sub><code>@battery_revamped_drain_rate_format</code> で減少率の書式を変えます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/charging.png" alt="battery-revamped: 充電中の見積もりは満充電までの時間です"><br><sub>充電中の見積もりは満充電までの時間です、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/low.png" alt="battery-revamped: 残量が低いときの警告アイコン"><br><sub>残量が低いときの警告アイコン、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/thresholds.png" alt="battery-revamped: @battery_revamped_low_threshold で低い残量の境目を動かします"><br><sub><code>@battery_revamped_low_threshold</code> で低い残量の境目を動かします、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/critical.png" alt="battery-revamped: 残量が危険なときの警告アイコン"><br><sub>残量が危険なときの警告アイコン、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/critical-threshold.png" alt="battery-revamped: @battery_revamped_critical_threshold で危険な残量の境目を動かします"><br><sub><code>@battery_revamped_critical_threshold</code> で危険な残量の境目を動かします、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/alert-icons.png" alt="battery-revamped: @battery_revamped_low_icon と @battery_revamped_critical_icon で警告の記号を決めます"><br><sub><code>@battery_revamped_low_icon</code> と <code>@battery_revamped_critical_icon</code> で警告の記号を決めます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/state-charged.png" alt="battery-revamped: 満充電の状態"><br><sub>満充電の状態、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/state-attached.png" alt="battery-revamped: AC 電源につながっていて充電していない状態"><br><sub>AC 電源につながっていて充電していない状態、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/state-unknown.png" alt="battery-revamped: 不明な状態"><br><sub>不明な状態、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status-icons.png" alt="battery-revamped: @battery_revamped_status_<state>_icon とその色"><br><sub><code>@battery_revamped_status_<state>_icon</code> とその色、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/status-colors.png" alt="battery-revamped: #{battery_color_status_fg} と #{battery_color_status_bg}"><br><sub><code>#{battery_color_status_fg}</code> と <code>#{battery_color_status_bg}</code>、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/tiers.png" alt="battery-revamped: @battery_revamped_charge_tier7_icon とその色"><br><sub><code>@battery_revamped_charge_tier7_icon</code> とその色、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/format.png" alt="battery-revamped: @battery_revamped_percentage_format で残量の書式を変えます"><br><sub><code>@battery_revamped_percentage_format</code> で残量の書式を変えます、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/remain-format.png" alt="battery-revamped: @battery_revamped_remain_format で残り時間の書式を変えます"><br><sub><code>@battery_revamped_remain_format</code> で残り時間の書式を変えます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/details.png" alt="battery-revamped: ワット数、サイクル数、健全性"><br><sub>ワット数、サイクル数、健全性、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/detail-formats.png" alt="battery-revamped: @battery_revamped_watts_format、_cycles_format、_health_format"><br><sub><code>@battery_revamped_watts_format</code>、<code>_cycles_format</code>、<code>_health_format</code>、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/detail-interval.png" alt="battery-revamped: @battery_revamped_detail_interval で詳細を読む間隔を決めます"><br><sub><code>@battery_revamped_detail_interval</code> で詳細を読む間隔を決めます、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/fixed.png" alt="battery-revamped: @battery_revamped_fixed_width で残量を自然な幅に揃えます"><br><sub><code>@battery_revamped_fixed_width</code> で残量を自然な幅に揃えます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/width.png" alt="battery-revamped: @battery_revamped_percentage_width で 1 つの指標を独自の幅に揃えます"><br><sub><code>@battery_revamped_percentage_width</code> で 1 つの指標を独自の幅に揃えます、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/labels.png" alt="battery-revamped: 残量の前の独自のラベル"><br><sub>残量の前の独自のラベル、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/label-health.png" alt="battery-revamped: 健全性の前の独自のラベル"><br><sub>健全性の前の独自のラベル、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/graph-width.png" alt="battery-revamped: @battery_revamped_graph_width、_graph_full、_graph_empty でバーの形を決めます"><br><sub><code>@battery_revamped_graph_width</code>、<code>_graph_full</code>、<code>_graph_empty</code> でバーの形を決めます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/power-source.png" alt="battery-revamped: @battery_revamped_source_battery_label と _source_ac_label"><br><sub><code>@battery_revamped_source_battery_label</code> と <code>_source_ac_label</code>、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/power-source-ac.png" alt="battery-revamped: 充電中の電源ラベル"><br><sub>充電中の電源ラベル、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/hide-on-ac.png" alt="battery-revamped: @battery_revamped_hide_on_ac で電池を使っていないときはすべて空になります"><br><sub><code>@battery_revamped_hide_on_ac</code> で電池を使っていないときはすべて空になります、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/before-after.png" alt="battery-revamped: @battery_revamped_before と _after に {icon} と {color} を使います"><br><sub><code>@battery_revamped_before</code> と <code>_after</code> に <code>{icon}</code> と <code>{color}</code> を使います、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/notify.png" alt="battery-revamped: @battery_revamped_notify は境目を越えるたびに通知を 1 回送ります。ここでは代用の通知ツールの記録です"><br><sub><code>@battery_revamped_notify</code> は境目を越えるたびに通知を 1 回送ります。ここでは代用の通知ツールの記録です、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/popup-size.png" alt="battery-revamped: @battery_revamped_popup_width と _popup_height でポップアップの大きさを決めます"><br><sub><code>@battery_revamped_popup_width</code> と <code>_popup_height</code> でポップアップの大きさを決めます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/popup-key.png" alt="battery-revamped: @battery_revamped_popup_key でポップアップに別のキーを割り当てます"><br><sub><code>@battery_revamped_popup_key</code> でポップアップに別のキーを割り当てます、<code>features.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/interval.png" alt="battery-revamped: @battery_revamped_interval で読み取りが新しい期間を決めます"><br><sub><code>@battery_revamped_interval</code> で読み取りが新しい期間を決めます、<code>features.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/version.png" alt="battery-revamped: バージョン"><br><sub>バージョン、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/error.png" alt="battery-revamped: 不明なコマンド"><br><sub>不明なコマンド、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/status-command.png" alt="battery-revamped: status percentage と status graph は 1 つずつプレースホルダーを表示します"><br><sub><code>status percentage</code> と <code>status graph</code> は 1 つずつプレースホルダーを表示します、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/refresh.png" alt="battery-revamped: refresh は電池を今すぐ読み取ります"><br><sub><code>refresh</code> は電池を今すぐ読み取ります、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/card.png" alt="battery-revamped: card はすべての値を表示します"><br><sub><code>card</code> はすべての値を表示します、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/list.png" alt="battery-revamped: list はすべてのバインドを表示します"><br><sub><code>list</code> はすべてのバインドを表示します、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/json.png" alt="battery-revamped: list --json は同じ計画を 1 つのオブジェクトで表示します"><br><sub><code>list --json</code> は同じ計画を 1 つのオブジェクトで表示します、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="battery-revamped: doctor"><br><sub><code>doctor</code>、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/menu.png" alt="battery-revamped: メニュー"><br><sub>メニュー、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/menu-card.png" alt="battery-revamped: メニューからのカード"><br><sub>メニューからのカード、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/accent.png" alt="battery-revamped: BATTERY_REVAMPED_ACCENT によるアクセント"><br><sub><code>BATTERY_REVAMPED_ACCENT</code> によるアクセント、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="battery-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="battery-revamped: gum なしでメニューから実行した doctor"><br><sub>gum なしでメニューから実行した <code>doctor</code>、<code>stills.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-card.png" alt="battery-revamped: gum なしの card"><br><sub>gum なしの <code>card</code>、<code>stills.tape</code> から</sub></td>
<td width="50%" valign="top"><img src="screens/themes.png" alt="battery-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー、<code>themes.tape</code> から</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help.png" alt="battery-revamped: ヘルプページ"><br><sub>ヘルプページ、<code>help.tape</code> から</sub></td>
</tr>
</table>

録画は本物のプラグインと tmux を動かします。`pmset`、`system_profiler`、`ioreg`、`osascript` は小さなスクリプトで代用しているので、画面の値はそれらのものです。電池は、録画が変えない限り 1 つの状態を保ちます。

</details>

## 移植性

プラグインは POSIX `sh` です。CI は次の各行ですべてのスイートを実行します。

| シェル | 状態 |
|:-----|:-----|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-----|:-----|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で動作します |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で動作します |

## 開発

| コマンド | 実行内容 |
|:-----|:-----|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` を実行します |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を警告ゼロで実行します |
| `make test` | システムの `sh` で bats のスイートを実行します |
| `make test-all` | インストール済みのすべてのシェルでスイートを実行します。macOS では bash と zsh の両方のビルドを使います |
| `make test-linux` | Ubuntu コンテナでスイートを実行します |
| `make coverage` | この Mac と Ubuntu コンテナで bashcov を実行し、結果を統合して 100 パーセントを条件にします |
| `make screens` | 上の画面を、macOS で VHS を使い tmux 内の本物のプラグインから録画します |
| `make install` | コマンド、man ページ、補完を `PREFIX` の下に入れます |

macOS では、`brew bundle` が [`Brewfile`](Brewfile) からこれらのターゲットが呼ぶすべてのツールをインストールします。

コミットは Conventional Commits 形式で、`main` に直接入ります。`main` の `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降の `feat` または `fix` ごとにリリースが公開され、バージョン定数が更新され、ノートが [`CHANGELOG.md`](CHANGELOG.md) に追加されます。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | **このプラグイン**、tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->

