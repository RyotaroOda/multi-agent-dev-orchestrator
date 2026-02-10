# plan ディレクトリ運用

## 読む順番

1. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/企画書.md`
2. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/エージェント.md`
3. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/マイルストーン.md`
4. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/バックログ.md`
5. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/リスク登録簿.md`
6. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/意思決定ログ.md`
7. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/README.md`
8. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/GitHub App導入実行手順.md`
9. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/templates/Issueテンプレート_v0.2.md`
10. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/M4_Go-No-Goチェックリスト.md`
11. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/12_M4本判定と開発着手条件仕様.md`
12. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/13_機能別開発者実装準備仕様.md`
13. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/14_GitHub App認証と鍵管理仕様.md`
14. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/15_機能別イベント契約と判定語彙仕様.md`
15. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/16_初回開発Issue候補とDoR詳細.md`
16. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/templates/M4本判定会_記録テンプレート.md`
17. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/M4本判定会_記録_2026-02-21.md`

## 更新ルール

- 新しい論点は、まずIssue化し、受け入れ条件を記述する
- 結論が出たら `意思決定ログ` を更新する
- 影響する作業は `バックログ` の優先度を見直す
- 新しい懸念は `リスク登録簿` に追加し、回避策を明記する
- 機能別の詳細化は `plan/specs/` に記載し、未決事項を必ず明示する

## ステータス定義

- `todo`: 未着手
- `ready`: 受け入れ条件が定義済みで着手可能
- `doing`: 検討中
- `blocked`: 外部判断待ち
- `done`: 企画として合意済み
