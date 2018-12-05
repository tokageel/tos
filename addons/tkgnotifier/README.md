# tkgnotifier

## Descriptions

無駄になってしまいそうなものが手元にあったときに通知してくれるかもしれないアドオンです。

![tkgnotifierimage](./tkgnotifier_image.jpg "イメージ")

* ログイン時、メールボックスに期限が7日以内かつアイテム付きの未開封メールがあった場合に通知
* ログイン時、無料TPが5ポイント溜まっていた場合に通知
* CC時、インベントリに使用期限が1日以内の未使用アイテムがあった場合に通知

## Usage

アドオンマネージャには登録していませんので、手動でのインストールが必要です。
アドオンの動作にはacutilが必要です。

通常のアドオンと同様、下記のようなファイル構成とします。

```bash
<ToSインストール先>
├addons/
│  └tkgnotifier/: 手動でフォルダを作成する
│    └settings.json: 任意
└data/
  └_tkgnotifier-🦎-vX.X.X.ipf: ダウンロードしたファイルを格納
```

## Configuration

settings.jsonファイルを手動で作成することで設定を変更できます。
デフォルト設定は下記の通りです。

```json
{
  "mail": {
    "trigger": 1,
    "threshold_day":7
  },
  "item": {
    "trigger": 2,
    "threshold_day":1
  },
  "medal": {
    "trigger": 1,
    "threshold": 5
  },
  "locale": "JP" 
}
```

|キー1|キー2|型|内容|デフォルト値|
-|-|-|-|-
|mail||table|期限付きメール通知機能の設定|-|
||trigger|number|期限付きメール通知を行うトリガー|1（ログイン時）|
||threshold_day|number|期限付きメールの期限が近いと判断する閾値（単位:日）|7|
|item||table|期限付きアイテム通知機能の設定|-|
||trigger|number|期限付きアイテム通知を行うトリガー|2（CC時）|
||threshold_day|number|未使用アイテムの期限が近いと判断する閾値（単位:日）|1|
|medal||table|無料TP蓄積通知機能の設定|-|
||trigger|number|無料TP蓄積通知を行うトリガー|1（ログイン時）|
||threshold|number|無料TPが蓄積したと判断する閾値（単位:ポイント）|5|
|locale||string|言語設定（"EN"または"JP"）|JP|

通知トリガーの内容は下記の通りです。

|設定値|通知タイミング|
-|-
|0|通知なし|
|1|ログイン時|
|2|ログイン時、キャラクター切替時|
|3|ログイン時、キャラクター切替時、マップ移動時|
|4|ログイン時、キャラクター切替時、マップ移動時、チャンネル切り替え時|

通知してほしくない機能に対しては、"trigger"に0を設定してください。
