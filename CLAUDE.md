# line_f_growth — タロチャ グロース戦略

タロチャ（LINEの都度課金タロット占いボット）を「伸ばす前に、伸ばしても死なないか」検査するための作業リポ。
Claude.ai側の対話（プロジェクト「タロチャグロース戦略話し合い会場」）で決めたことをここに落とし、Claude CodeはDB集計・実装を担当する。

## 読む順番
1. `docs/growth_brief.md` — 進め方の骨組み（①健康診断 → ②プレモータム → ③成長条件 → ④打ち手）と①の診断結果
2. `docs/2026-09-28_mandalart_and_actions.md` — 2026-09-28時点のマンダラチャート、③の状態、打ち手10個、Now/Next/Later、決まったことのログ
3. `docs/2026-09-28_db_findings.md` — Nowの集計結果と、1・2の記述の訂正（決済はKOMOJU、A群47人の意味など）。1・2はClaude.aiのartifactの写しなので、訂正は正本側にも反映が要る

## 2026-09-28時点の前提（変わったらここを更新）
- 成長方針は脱依存。user59は顧客定義から外す。売上の判定は「user59以外」で行う
- 中心テーマ: user59抜きで月¥6,600（損益分岐）超が3ヶ月連続
- 戦略の軸: 追加1人の単価（約¥700）× 追加→279型率（約2%）× 一周の売上（¥7,680）を黒字にする
- やらないこと: 「カードをもっと深く見る」導線 / 月額パス / 恋愛執着ターゲティング / 姉妹プッシュ型プロダクト着手 / 「カードが覚えている」機構
- 決済は2025-12からKOMOJU（クレカ・メルペイ・PayPay・コンビニ等）。Stripeは使っていない
- 止める条件は運用しながら見直す（案は `docs/2026-09-28_db_findings.md` ④）

## 運用ルール: コードの変更はissue経由
- このリポは戦略と集計用。ボット本体（emomie/line_f）やタロヒキ（emomie/oneoracle）のコードは、ここから直接変更・デプロイしない
- 変更が必要とわかったら、根拠（数字、該当ファイル:行）と受け入れ条件を書いたissueを対象リポに起票する。起票前に内容をユーザーに見せる
- 実装は各コードベースのプロジェクト（`C:/xampp/htdocs/line_f`、`C:/xampp/htdocs/oneoracle`）でissueをもとに行う
- ここでやること: DBの読み取り集計（`node scripts/db.mjs`、SQLは `queries/`）、ログとコードの読み取り調査、docs と CLAUDE.md の更新、issueの起票

## Claude Codeへの依頼（Now）
- [x] B群32人の登録日を広告の配信期間と重ねる → 22人がGoogle広告期。Instagram期間（8/17〜）は要確定
- [x] ~~Stripe~~ KOMOJUで決済の途中離脱を出す → 手段選択まで進んだA群は2人。決済手段が理由の可能性はほぼ無い
- [x] A群の残高ゼロ時メッセージ → 本文はDBに無い（[line_f#64](https://github.com/emomie/line_f/issues/64)）。回数と日数は集計済み
- [x] 新規の1日10回超を週次で出すクエリ → `node scripts/weekly_watch.mjs`
- [x] タロヒキにイベント実装 → 2026-09-28本番反映（[oneoracle#2](https://github.com/emomie/oneoracle/issues/2)）。Meta側のカスタムコンバージョン作成が残り

## 起票済みのissue（実装は各リポで）
- [oneoracle#2](https://github.com/emomie/oneoracle/issues/2) Metaピクセル導入・友だち追加URLへの変更（反映済み、残りはチェックリスト）
- [oneoracle#3](https://github.com/emomie/oneoracle/issues/3) 最初の画面でカードをすぐ引けるようにする
- [line_f#64](https://github.com/emomie/line_f/issues/64) 残高0のときに届いたメッセージをDBに保存
- [line_f#65](https://github.com/emomie/line_f/issues/65) ブロック（unfollow）の日時をDBに記録
- [line_f#66](https://github.com/emomie/line_f/issues/66) 課金メニューのボタン押下を記録

## 用語
- user279型: 出来事の夜に¥1,280パックを買い、1日5回で止まる健全なリピーター
- user59型: 出来事なしでカードの意味を深掘りし続け、1日18回に達する依存的利用者
- A群: 無料3枚を使い切り、毎月1日の無料1枚で戻るが買わない57人（うち47人に課金メニューが届いた。メニューは残高0で自動送信）
- B群: 1回だけ占って無料2枚を残したまま離脱した32人（残り2回あるので月初の無料1枚は届かない）
- 数え方: 6/28以降に占った109人が母数。定義とSQLは `docs/2026-09-28_db_findings.md` と `queries/`
- タロヒキ: 広告のLPを兼ねる登録不要の1枚引きWebアプリ（one.tarocha.jp）
