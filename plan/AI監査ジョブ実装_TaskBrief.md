# AI監査ジョブ実装 Task Brief

## Goal（目的）

- `specs/22` と `specs/23` に基づき、GitHub保護設定のAI自動監査ジョブを次フェーズで実装可能な単位に分割し、着手順を固定する。

## Non-goals（非目的）

- 企画フェーズ内での実装コード作成
- GitHub実環境への設定変更
- 例外許可/リスク受容の自動承認化

## Acceptance Criteria（受け入れ条件）

- 実装タスクが `Collector/Evaluator/Reporter/Dispatcher` の4単位で定義されている。
- 各タスクに入力/出力/失敗時挙動が記述されている。
- `run_control=blocked` 条件が `specs/22` の判定表と一致している。
- 監査レポートの出力先とテンプレート参照が一意に決まっている。

## Constraints（制約・禁止事項）

- セキュリティ優先順位 `A > B > C` を崩さない。
- 認証主体は GitHub App（bot）を維持する。
- 判定不能時は fail-closed（`run_control=blocked`）を適用する。
- 企画フェーズではコード変更・テスト実行を行わない。

## Scope（変更してよい範囲）

- 対象ディレクトリ: `plan/`, `plan/specs/`, `plan/templates/`
- 対象ファイル:
  - `plan/specs/22_AI監査自動化運用仕様.md`
  - `plan/specs/23_AI監査ジョブ実装詳細仕様.md`
  - `plan/templates/GitHubブランチ保護自動監査結果テンプレート.md`
  - `plan/バックログ.md`
  - `plan/意思決定ログ.md`
  - `plan/リスク登録簿.md`

## How to Test（検証手順）

- 文書間整合確認:
  - `specs/20` / `specs/22` / `specs/23` の判定語彙が一致する。
  - `plan/README.md` と `specs/README.md` の参照導線が一致する。
- 台帳整合確認:
  - 新規タスクID、ADR ID、リスクIDに重複がない。
  - `PLN-069` の受け入れ条件と `specs/23` の受け入れ条件が矛盾しない。

## Risks（主要リスク）

- API取得失敗時に監査空白が生じる。
- 自動判定と人間最終判断の不一致増加で運用コストが上がる。

## Rollback（戻し方）

- `specs/23` と Task Brief 追加前の状態へ戻す場合は、関連台帳（バックログ/意思決定ログ/リスク登録簿）も同時に巻き戻す。
