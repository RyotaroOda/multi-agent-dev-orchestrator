# DEV-001 実装フェーズ開始 Task Brief

## Goal（目的）

- Issue `#5`（DEV-001）着手時の目的/制約/終了条件を固定し、`blocked -> retry -> running` 契約の実装解釈差分を防ぐ。

## Non-goals（非目的）

- 企画フェーズ内での実装コード作成
- GitHub設定変更や運用監査タスク（PLN-082 以降）の先行実施
- DEV-002/DEV-003 の受け入れ条件確定

## Acceptance Criteria（受け入れ条件）

- `Goal/Non-goals/Acceptance/Constraints/How to Test` が本Task Briefに記入済みである。
- DEV-001 の一次参照順（`13 -> 15 -> 16 -> 17 -> 18`）が明記されている。
- `blocked_reason` 命名規約と復帰契約（`blocked -> retry -> running`）の確認観点が定義されている。
- Issue `#5` 参照リンクが記録されている。

## Constraints（制約・禁止事項）

- セキュリティ優先順位 `A:漏えい防止 > B:ホスト保護 > C:課金回避` を崩さない。
- `run_id` と `app_slug` の追跡可能性を維持する。
- 判定不能時は fail-closed（`run_control=blocked`）を前提にする。
- 企画フェーズでは実装コード作成・依存追加・ビルド/テスト実行を行わない。

## Scope（変更してよい範囲）

- 対象ディレクトリ: `plan/`, `plan/specs/`
- 対象ファイル:
  - `plan/DEV-001_実装フェーズ開始_TaskBrief.md`
  - `plan/バックログ.md`
  - `plan/意思決定ログ.md`
  - `plan/実装進捗ダッシュボード.md`
  - `plan/specs/18_DEV-001状態遷移と復帰契約仕様.md`（参照のみ）

## How to Test（検証手順）

- 文書整合確認:
  - 本Task Briefの受け入れ条件が `plan/バックログ.md` の `PLN-078` 受け入れ条件と矛盾しない。
  - 復帰契約（`blocked -> retry -> running`）の記述が `plan/specs/18_DEV-001状態遷移と復帰契約仕様.md` と一致する。
- 台帳整合確認:
  - `PLN-078` 状態変更が `plan/バックログ.md` と `plan/実装進捗ダッシュボード.md` で一致する。
  - 意思決定ログに本Task Brief確定の判断が記録される。

## Risks（主要リスク）

- Task Brief更新が台帳反映とずれると、進捗判定が再びセッション依存になる。
- DEV-001の契約記述が複数文書でずれると、`R-020`（遷移不整合）が再燃する。

## Rollback（戻し方）

- 本Task Brief追加前へ戻す場合は、`PLN-078` の状態とダッシュボード指標を同時に巻き戻す。

## 参照リンク

- Issue: [#5 DEV-001](https://github.com/RyotaroOda/multi-agent-dev-orchestrator/issues/5)
