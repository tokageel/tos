# tkgnotifier

## Descriptions

メールボックスに期限が近い未開封メールがあった場合、ログイン直後に通知してくれるかもしれないアドオンです。

![tkgnotifierimage](./tkgnotifier_image.jpg "イメージ")

## Usage

アドオンマネージャには登録していませんので、手動でのインストールが必要です。
ただし、アドオンの動作にはacutilが必要です。

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

|キー名|型|内容|デフォルト値|
-|-|-|-
|mail_notify_threshold_day|number|未開封メールの期限が近いと判断する閾値（単位:日）|7|

期限が3日以内に迫った未開封メールがある場合に通知する場合は以下のような設定になります。
```json
{"mail_notify_threshold_day":"3"}
```
