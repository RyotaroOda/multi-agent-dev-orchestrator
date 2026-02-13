# GitHub保護設定_非常時運用手順

## 目的

- `main` の branch protection / required checks 更新が通常導線で失敗した際に、監査停止を最短で解除する。
- 非常時に人アカウントで実施した操作を、同日中に台帳へ確実に残す。

## 適用範囲

- 対象リポジトリ: `RyotaroOda/multi-agent-dev-orchestrator`
- 対象ブランチ: `main`
- 対象設定: branch protection, required status checks

## 権限境界（運用基準）

| 操作 | 標準主体 | 必要権限 | 非常時主体 |
| --- | --- | --- | --- |
| 監査収集（read） | GitHub App (`multi-agent-orchestrator-bot`) | Administration: read | なし |
| 監査判定/レポート/通知（local） | AI実行環境 | ローカル実行権限 | なし |
| 保護設定更新（write） | 原則なし（設定変更は手動管理） | Administration: write | 人アカウント（管理者） |

注記:
- `GH_TOKEN=$(./scripts/github_app_token.sh)` で `403 Resource not accessible by integration` が出る場合、Appトークンでは更新不可と判断する。
- branch protection系APIが `404 Branch not protected` の場合、保護ルール自体が未作成の可能性を優先確認する。

## 非常時の発火条件

次のいずれかで非常時運用へ移行する。

1. `make audit-collect` が `failed_stage=branch_protection` で失敗する。
2. UI上で `Require status checks to pass before merging` が有効でも、`No checks have been added` から追加できない。
3. `gh api /repos/{owner}/{repo}/branches/main/protection/required_status_checks` が `404` または `403` を返す。

## 非常時手順（人アカウント）

1. 現状確認
   - `gh auth status`
   - `gh api /repos/RyotaroOda/multi-agent-dev-orchestrator/commits/main/check-runs`
2. `main` の保護設定を更新（required checksを明示）
   - `lint/format`
   - `unit test`
3. 反映確認
   - `gh api /repos/RyotaroOda/multi-agent-dev-orchestrator/branches/main/protection/required_status_checks`
4. 監査再実行
   - `make audit-collect`
   - `make audit-evaluate`
   - `make audit-report`
   - `make audit-dispatch`
   - `jq '{result,run_control,diffs}' var/state/evaluator-output.json`
5. 台帳記録（同日中）
   - `plan/意思決定ログ.md` に非常時判断をADR追記
   - `plan/バックログ.md` に再発防止タスクを登録/更新
   - `plan/リスク登録簿.md` にリスク状態を記録

## 復旧後のbot運用復帰条件

以下を満たしたら通常運用へ戻す。

1. 監査結果が `result=pass` かつ `run_control=continue`。
2. required checks に `lint/format` と `unit test` が登録済み。
3. 非常時操作の理由と実施内容が台帳へ反映済み（`ADR-072` 参照）。

## 追跡情報

- 関連ADR: `ADR-072`
- 関連タスク: `PLN-077`
- 関連リスク: `R-032`
