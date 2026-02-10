# plan ディレクトリ運用

## 読む順番

1. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/企画書.md`
2. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/エージェント.md`
3. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/マイルストーン.md`
4. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/バックログ.md`
5. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/リスク登録簿.md`
6. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/意思決定ログ.md`
7. `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/specs/README.md`

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
