# DCS_LaunchingFlare
対艦ミサイルなどの脅威が接近すると艦艇が自動でフレアを放出するDCS用のスクリプトです。<br>
残念ながらフレアに効果はなく、あくまで雰囲気を楽しむものとなります。<br>
![flareTest](https://user-images.githubusercontent.com/30495755/167240258-d220377a-00b0-4b25-b58d-378700e86c35.png)
# 使い方
・スクリプトを導入（トリガー設定画面でNEW ⇒ ONECE ⇒ DOSCRIPTFILE）<br>
・フレアを放出するさせたいユニット名にキーワードを含める（デフォルトは"flare"）<br>
以上<br>


# パラメータの設定
スクリプトを編集することで挙動を変化させることができます。<br>
luaファイルを開いて下の変数に設定されている値を変えると反映されます。<br>
<br>
・_OPARATIONALTARGETKEYWORD フレアを放出する対象のキーワード<br>
・_REPETATIONTIME -- 何秒おきにフレアを撒くか<br>
・_FLARELAUNCHDISTANCE -- ミサイルが何km近づいたらフレアを撒くか<br>
・_FLAREVOLUME -- フレアを撒く量<br>
