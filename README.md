readme-english
==============
READMEに使われる頻出英単語を集計するプログラム

### 仕様
GitHubのスター数ランキング上位N件のリポジトリを対象に、READMEの英単語出現数を集計します。

### インストール
```bash
$ git clone git@github.com:hogesuke/readme-english.git
$ cd readme-english
$ bundle install --path vendor/bundle
```

### 使い方
```bash
$ bundle ex ./bin/run 20
```
コマンド引数で上位何件のリポジトリを対象とするか指定します。  

集計結果は `out/result.yaml` に出力されます。

### リンク
http://hogesuke.hateblo.jp/entry/readme-english