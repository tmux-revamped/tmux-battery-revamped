<div align="center">

# tmux-battery-revamped

<strong>tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません。</strong>

[English](README.md) | 日本語 | [简体中文](README.zh-Hans.md) | [繁體中文（香港）](README.zh-HK.md)

[![family](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/family.yml?branch=main&style=flat-square&label=family)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/family.yml)
[![tests](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-battery-revamped/tests.yml?branch=main&style=flat-square&label=tests)](https://github.com/tmux-revamped/tmux-battery-revamped/actions/workflows/tests.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-battery-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-battery-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-battery-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-battery-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-battery-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#what-it-does">機能</a> |
  <a href="#requirements">動作要件</a> |
  <a href="#installation">インストール</a> |
  <a href="#usage">使い方</a> |
  <a href="#configuration">設定</a> |
  <a href="#key-bindings">キーバインド</a> |
  <a href="#how-it-works">仕組み</a>
</p>

</div>

プレースホルダー**20**個。描画モード**2**種類。システムの情報源**5**種類：`pmset`、`system_profiler`、`ioreg`、`/sys/class/power_supply`、`acpi`。CIはLinuxとmacOSの**10**通りのツールチェーンの組み合わせでテストを実行します。

---

<a id="what-it-does"></a>

## 機能

`status-left`と`status-right`の`#{battery_*}`プレースホルダーを、ノートパソコンの電池の残量、状態、残り時間、ワット数、充放電回数、劣化度、消費速度、残量の履歴に置き換えます。どのプレースホルダーもtmuxのオプションにキャッシュされた値を読みます。電池のツールはバックグラウンドで動くため、遅い`pmset`や`system_profiler`の呼び出しでステータスラインが遅れることはありません。ディスクには何も書き込みません。

残量が少ないとき、非常に少ないとき、満充電のときにデスクトップ通知を送ることもでき、`prefix + M-b`で詳細ポップアップを開きます。

<a id="requirements"></a>

## 動作要件

| ツール | バージョン | 用途 |
|:-----|:--------|:-----------|
| tmux | 3.2以降 | 詳細ポップアップの`display-popup` |
| bash | 3.2以降 | macOSの`/bin/bash`を含むすべてのスクリプト |
| `acpi` | 任意 | Linuxで任意。残量と残り時間の代替手段 |
| `osascript`または`notify-send` | 任意 | 任意。デスクトップ通知 |

| 値 | Linux、x86_64とarm64 | macOS、IntelとApple Silicon |
|:------|:------------------------|:-------------------------------|
| 残量と状態 | 最初の`/sys/class/power_supply/BAT*`、次に`acpi` | `pmset` |
| 残り時間 | `acpi`、次に`/sys`のエネルギーまたは電荷のカウンターから計算 | `pmset` |
| ワット数 | `power_now`、現在の消費電力 | `system_profiler`、充電器の定格ワット数 |
| 充放電回数 | `cycle_count` | `ioreg` |
| 劣化度 | `energy_full`と`energy_full_design`の比、次に`charge_*`の組 | `ioreg`、`AppleRawMaxCapacity`と`DesignCapacity`の比 |

ホストに情報源がない値は空で表示されます。このホストで使える情報源は`src/battery.sh doctor`で確認できます。

<a id="installation"></a>

## インストール

### TPMでインストール

`~/.tmux.conf`にプラグインとプレースホルダーを追加し、`prefix + I`を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-battery-revamped'
set -g status-right '#{battery_icon_status} #{battery_percentage} #{battery_remain}'
```

### 手動インストール

```bash
git clone https://github.com/tmux-revamped/tmux-battery-revamped ~/.tmux/plugins/tmux-battery-revamped
```

次の行を`~/.tmux.conf`の`status-left`と`status-right`を設定する行より後に追加し、tmuxを再読み込みします。

```tmux
run-shell ~/.tmux/plugins/tmux-battery-revamped/battery-revamped.tmux
```

<a id="usage"></a>

## 使い方

`status-left`か`status-right`にプレースホルダーを書きます。プラグインは読み込み時にそれを置き換えます。完全な例は[`examples/status-right.tmux.conf`](examples/status-right.tmux.conf)にあります。

```tmux
set -g status-right '#{battery_color_status_fg}#{battery_icon_status} #{battery_percentage}#[default] #{battery_graph} #{battery_remain} '
```

| プレースホルダー | 出力 |
|:------------|:-------|
| `#{battery_percentage}` | 残量。例：`83%` |
| `#{battery_icon}`、`#{battery_icon_charge}` | 現在の残量段階のアイコン |
| `#{battery_icon_status}` | 現在の状態のアイコン |
| `#{battery_color_fg}`、`#{battery_color_bg}` | 現在の状態の色 |
| `#{battery_color_status_fg}`、`#{battery_color_status_bg}` | 現在の状態の色 |
| `#{battery_color_charge_fg}`、`#{battery_color_charge_bg}` | 現在の残量段階の色 |
| `#{battery_graph}` | 残量のバー。例：`████████░░` |
| `#{battery_remain}` | システムが報告する残り時間。例：`4:32` |
| `#{battery_estimate}` | 消費速度から計算した残り時間。例：`2:00` |
| `#{battery_charging_watts}` | ワット数。例：`45W` |
| `#{battery_cycles}` | 充放電回数 |
| `#{battery_health}` | 設計容量に対する満充電容量。例：`96%` |
| `#{battery_drain_rate}` | 5分以上の間隔で測った1時間あたりの減少率。例：`12.5%/h` |
| `#{battery_sparkline}` | 最近の残量の推移。例：`▇▇▆▆▅` |
| `#{battery_power_source}` | `AC`または`Bat` |
| `#{battery_alert_icon}` | 放電中に残量が少ないか非常に少ないときの記号 |

状態は`charged`、`charging`、`discharging`、`attached`、`unknown`のいずれかです。`attached`はAC電源につながっていて充電していない状態です。

<a id="configuration"></a>

## 設定

| オプション | 既定値 | 意味 |
|:-------|:--------|:--------|
| `@battery_revamped_interval` | `15` | 残量と状態の読み取りを新しいとみなす秒数 |
| `@battery_revamped_detail_interval` | `60` | 残り時間、ワット数、充放電回数、劣化度を新しいとみなす秒数 |
| `@battery_revamped_render` | 空 | `options`でオプション描画モードにする。[仕組み](#how-it-works)を参照 |
| `@battery_revamped_percentage_format` | `%s%%` | 残量のprintf書式 |
| `@battery_revamped_charge_tier{1..8}_icon` | `▁`から`█` | 残量段階ごとのアイコン。段階1が最も低い |
| `@battery_revamped_charge_tier{1..8}_{fg,bg}_color` | 空 | 残量段階ごとの色 |
| `@battery_revamped_status_{charged,charging,discharging,attached,unknown}_icon` | `=`、`+`、`-`、`!`、`?` | 状態ごとのアイコン |
| `@battery_revamped_status_{state}_{fg,bg}_color` | 空 | 状態ごとの色 |
| `@battery_revamped_icons` | `ascii` | `nerd`で8段階にNerd Fontの電池記号を使い、充電中は充電用の記号にし、すべての指標にラベルを付ける。段階ごとのアイコンの設定が優先 |
| `@battery_revamped_graph_width` | `10` | 残量バーのセル数 |
| `@battery_revamped_graph_full` | `█` | 埋まったセル |
| `@battery_revamped_graph_empty` | `░` | 空のセル |
| `@battery_revamped_remain_format` | `%s` | 2つの残り時間プレースホルダーの書式 |
| `@battery_revamped_watts_format` | `%sW` | ワット数の書式 |
| `@battery_revamped_cycles_format` | `%s` | 充放電回数の書式 |
| `@battery_revamped_health_format` | `%s%%` | 劣化度の書式 |
| `@battery_revamped_drain_rate_format` | `%s%%/h` | 消費速度の書式 |
| `@battery_revamped_history_size` | `16` | 推移グラフに残す読み取りの数 |
| `@battery_revamped_low_threshold` | `20` | 放電中に少ないとみなす残量のパーセント |
| `@battery_revamped_critical_threshold` | `10` | 放電中に非常に少ないとみなす残量のパーセント |
| `@battery_revamped_low_icon`、`@battery_revamped_critical_icon` | 空 | `#{battery_alert_icon}`の記号 |
| `@battery_revamped_source_ac_label`、`@battery_revamped_source_battery_label` | `AC`、`Bat` | `#{battery_power_source}`の文字列 |
| `@battery_revamped_hide_on_ac` | `0` | `1`で、電池が放電中でない間はすべてのプレースホルダーを空にする |
| `@battery_revamped_before`、`@battery_revamped_after` | 空 | `#{battery_percentage}`が表示されるときだけ前後に置く文字列。`{icon}`は残量のアイコン、`{color}`は残量段階の色になる |
| `@battery_revamped_<metric>_label` | 空 | 値が空でないときに1つの指標の値の前に出す文字列。`''`で`nerd`のラベルを消す |
| `@battery_revamped_fixed_width` | `off` | `on`で各値を最大幅まで左側に詰め物をする |
| `@battery_revamped_<metric>_width` | 空 | 1つの指標の幅。固定幅より優先 |
| `@battery_revamped_notify` | `0` | `1`で残量が少ない、非常に少ない、満充電になったときにデスクトップ通知を送る |
| `@battery_revamped_popup_key` | `M-b` | 詳細ポップアップのprefixキー。`off`で割り当てない |
| `@battery_revamped_popup_width`、`@battery_revamped_popup_height` | `44`、`12` | ポップアップの大きさ |

ラベルは`percentage`、`graph`、`remain`、`charging_watts`、`cycles`、`health`、`drain_rate`、`estimate`、`sparkline`、`power_source`に付きます。幅の設定で長い値が切り詰められることはありません。

### テーマの色

色のオプションは既定で空のため、設定するまで色は付きません。次の各ブロックは段階1から3を赤、4から6を黄、7から8を緑にし、状態ごとにも色を付けます。

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

### 内部状態

次のオプションはプラグインが自身で書き込みます。設定しないでください。

| オプション | 内容 |
|:-------|:------|
| `@battery_revamped_published` | 読み込み時に`status-left`と`status-right`で見つかった指標。オプションモードで公開するもの |
| `@battery_revamped_out_<metric>` | オプションモードで公開される各指標の値 |
| `@battery_revamped_ticker_pid` | オプションモードのバックグラウンドプロセスのpid |
| `@battery_revamped_option_names` | バックグラウンドプロセスが1周期に1回の呼び出しで読むオプション |
| `@battery_revamped_alert_level` | 最後に見た段階。`ok`、`low`、`critical`、`full`、`unknown`のいずれかで、通知を境界を越えるたびに1回だけにする |
| `@battery_revamped_history` | 推移グラフ用の最近の残量 |
| `@battery_revamped_snap_pct`、`@battery_revamped_snap_ts` | 消費速度を測る基準の読み取り |
| `@battery_revamped_{percent,status,remain,watts,cycles,health,drain_rate}` | キャッシュされた読み取り。それぞれに`_ts`のタイムスタンプ、`percent`には`_lock`もある |

<a id="key-bindings"></a>

## キーバインド

| キー | 操作 | オプション |
|:----|:-------|:-------|
| `prefix + M-b` | 詳細ポップアップを開く | `@battery_revamped_popup_key` |

ポップアップはキャッシュされた残量、状態、残り時間、ワット数、消費速度、充放電回数、劣化度を、電池を再度調べずに表示します。どのキーでも閉じます。`@battery_revamped_popup_key`が空のときは`M-b`を使い、`off`のときは何も割り当てません。

<a id="how-it-works"></a>

## 仕組み

既定のジョブモードでは、各プレースホルダーが[`src/battery.sh`](src/battery.sh)を呼ぶ`#()`になります。呼び出しはキャッシュされた値をすぐに出力します。キャッシュされた残量が`@battery_revamped_interval`より古ければ、バックグラウンドでの更新を1つ開始します。更新はロックで守られ、並行した呼び出しが2つ目を開始することはありません。

tmuxはステータスを描き直すたびにすべての`#()`を実行します。1つのバーに複数のプラグインがあると、およそ1秒に1回になります。オプションモードはこの呼び出しをなくします。

```tmux
set -g @battery_revamped_render 'options'
set -g @battery_revamped_fixed_width 'on'
```

各プレースホルダーは`#{E:@battery_revamped_out_percentage}`のようなオプションの読み取りになります。サーバーごとに1つのバックグラウンドプロセスが`@battery_revamped_interval`秒ごとに電池を読み、ステータスラインが使うすべての値を1回のtmux呼び出しで書き込み、1回だけ再描画します。このプロセスはサーバーが止まるか、設定の再読み込みで後継が起動すると終了します。ジョブモードに戻すと解放されます。

消費速度は現在の残量を5分以上前の読み取りと比べます。`#{battery_estimate}`は残りの残量をその速度で割ります。通知は少ない、非常に少ない、満充電の各段階に入るたびに1回だけ、macOSでは`osascript`、Linuxでは`notify-send`で送ります。

<a id="development"></a>

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make test` | [`test/`](test)以下のbatsテスト |
| `make lint` | すべてのシェルファイルへのshellcheck |
| `make coverage` | Linuxでのkcovによる行カバレッジ。95%未満で失敗します |

<a id="license"></a>

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約、`family/` 配下の同じツール、同じ共有ライブラリを持ち、チェックサムの一覧によってバイト単位で同一に保たれています。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。この義務は記憶に頼らず規約に書かれており、`family/bin/sweep` がその作業を行います。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CI、ファミリーのツールを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

### インストールの確認

全メンバーがディスク上にあれば、1 つのコマンドでメンバー間の衝突を報告できます。

```sh
family/bin/doctor --live
```

各メンバーと実行中の tmux サーバーを読み取り、重複したキー、重複したステータスのプレースホルダー、命名規則に合わないオプション、規約のバージョンが古いメンバーを報告します。

<!-- family:end -->
