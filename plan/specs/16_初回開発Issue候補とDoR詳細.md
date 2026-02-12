# 初回開発Issue候補とDoR詳細 v0.2-draft

## 1. 目的

`13_機能別開発者実装準備仕様.md` と `15_機能別イベント契約と判定語彙仕様.md` を起点に、Go判定後に着手する初回開発Issue候補を具体化する。

## 2. スコープ

- 初回着手候補3件（P0）
- 候補ごとの DoR（目的/受け入れ条件/影響範囲/テスト観点/関連リスク）
- 着手順の推奨

## 3. 前提

- M4判定は `Go` とする。
- 初回着手対象は `P0/P1`、外部依存ブロッカーなし、受け入れ条件が観測可能、例外ラベル新規付与不要を満たす。
- セキュリティ優先順位 `A > B > C` を維持する。

## 4. 候補Issue一覧

| 候補ID | GitHub Issue | 対応機能 | 優先度 | 目的 | 担当 | 目標期限 |
| --- | --- | --- | --- | --- | --- | --- |
| DEV-001 | [#5](https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/5) | F-1301 / F-1303 | P0 | Run状態遷移と復帰手順を先に固定し、以降機能の実行基盤を確定する | PM（ユーザー） | 2026-02-12 |
| DEV-002 | [#6](https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/6) | F-1305 / F-1306 | P0 | 例外4項目と品質ゲート判定を連動させ、危険な実行を先に止められる状態を作る | PM（ユーザー） | 2026-02-13 |
| DEV-003 | [#7](https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/7) | F-1307 / F-1311 | P0 | `run_id` 完全性検証と GitHub App(bot) PR作成を接続し、成果物の出口を確立する | PM（ユーザー） | 2026-02-14 |

## 5. DoR詳細

### DEV-001 Run状態遷移と復帰手順の固定

- 目的:
  - `queued/running/blocked/completed` の遷移と `retry` の再現性を確立する。
- 受け入れ条件:
  - `run_id` の採番・排他・再採番（retry時）が仕様どおり説明できる。
  - `blocked_reason` と人間判断コメントの必須項目が定義されている。
  - give-up上限超過時の停止条件が明示されている（`01_Issue駆動実行管理仕様.md` の `FR-105` / 初期値5）。
- 影響範囲:
  - 実行状態管理
  - タスクDAG起動トリガ
  - 監査ログの基本キー
- テスト観点:
  - 正常系: `queued -> running -> completed` が1回で完了する。
  - 異常系: `run_id` 不一致更新が破棄され `lock_mismatch` 記録される。
  - 異常系: `blocked -> retry -> running` で新 `run_id` に切り替わる。
- 関連リスク:
  - `R-002`, `R-012`, `R-015`
- DoRレビュー結果（2026-02-10）:
  - 充足（不足追記なし）
  - 記録: https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/5#issuecomment-3878245474

### DEV-002 例外ラベル検証と品質ゲート判定の連動

- 目的:
  - 例外運用と品質判定の解釈差分を排除し、A（漏えい防止）を先に担保する。
- 受け入れ条件:
  - 例外4項目（理由/適用範囲/失効日/承認者）欠落時は `deny` 扱いになる。
  - `skip` 記法やテスト削減閾値違反時は `blocked` になる。
  - 例外適用時にも監査項目（承認者・失効日）が追跡できる。
- 影響範囲:
  - policy評価
  - 品質ゲート判定
  - 例外ラベル運用規程
- テスト観点:
  - 正常系: 4項目充足の例外申請で許可判定に進む。
  - 異常系: 4項目のいずれか欠落で `deny` となる。
  - 異常系: ルールエンジン失敗時に fail-closed で `blocked` になる。
- 関連リスク:
  - `R-003`, `R-005`, `R-015`
- DoRレビュー結果（2026-02-10）:
  - 充足（不足追記なし）
  - 記録: https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/6#issuecomment-3878261847

### DEV-003 成果物完全性検証とGitHub App PR作成の接続

- 目的:
  - 成果物の取り込みからPR作成までを bot 主体で一貫させ、監査追跡を成立させる。
- 受け入れ条件:
  - 取り込み前に `run_id` 一致と `SHA-256` 検証が必須化されている。
  - PR本文に `run_id` と `app_slug` が記録される。
  - token発行失敗/期限切れ時は1回再試行後に `blocked` 記録される。
- 影響範囲:
  - 成果物検証
  - PR作成フロー
  - GitHub App鍵管理と監査ログ
- テスト観点:
  - 正常系: ハッシュ一致時にPR作成まで進む。
  - 異常系: ハッシュ不一致で取り込み中止し `blocked`。
  - 異常系: token発行失敗継続で `blocked` と手動対応要求を出力。
- 関連リスク:
  - `R-006`, `R-014`, `R-015`
- DoRレビュー結果（2026-02-10）:
  - 充足（不足追記なし）
  - 記録: https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/7#issuecomment-3878271138

## 6. 推奨着手順

1. DEV-001（Issue #5 / 状態遷移の土台）
2. DEV-002（Issue #6 / ポリシー・品質ガード）
3. DEV-003（Issue #7 / 成果物出口と監査）

## 7. 未決事項

- なし（初回着手候補3件のIssue化・担当・期限・開始順を確定済み）。
