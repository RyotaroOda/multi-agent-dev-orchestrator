# GitHub前提 コミット-PR-マージ-完了 運用仕様書 v0.2-draft

## 1. 目的

個人 x 複数AIエージェント開発で、`Commit -> Pull Request -> Merge -> Done` を安全に高速化するため、GitHub前提の標準運用フローを固定する。

## 2. 前提

- 作業は並列、統合は直列で運用する。
- 最終責任は人間（Integrator）が持つ。
- AIエージェントは作業者であり、最終マージ判断者ではない。
- SoTは Issue / PR / CIログとする。
- 企画フェーズでは本仕様の文書整備のみを行い、実装コード作成やテスト実行は次フェーズで適用する。

## 3. 役割

| 役割 | 主責務 |
| --- | --- |
| Integrator（ユーザー） | 仕様確定、優先順位、マージ判断、リスク受容判断 |
| Planner Agent | タスク分割、依存関係、影響範囲、リスク整理 |
| Implementer Agent | 実装と最小コミットの作成 |
| Tester Agent | テスト追加、回帰検証、再現手順の明文化 |
| Reviewer Agent | 差分監査（逸脱/設計整合/不要変更/リスク） |

## 4. 標準フロー

### 4.1 Plan（Issue作成）

- `Task Brief` をIssueへ記載する:
  - Goal
  - Non-goals
  - Acceptance Criteria
  - Constraints（変更可能範囲/禁止事項）
  - How to Test
- Planner Agentにタスク分割（3〜7件）を作成させ、Integratorが確定する。

### 4.2 Start（ブランチ + Draft PR）

- 1変更につき `1 Issue = 1 branch = 1 PR` を原則とする。
- PRは先に Draft で作成し、着地点を固定する。
- PR本文に関連Issueを明記する（例: `Fixes #123`）。

### 4.3 Commit（実装）

- コミットは意味単位で小さく分割する。
- 実装変更と機械整形変更を混在させない。
- 同一ファイルを複数エージェントが同時変更しない。

### 4.4 Verify（CIゲート）

- `CI赤のPRはレビューしない` を原則とする。
- 最低限の必須チェック:
  - lint/format
  - typecheck（該当時）
  - unit test
  - build（該当時）
- 並列PR運用時は `concurrency` を設定し、古い実行をキャンセルする。

### 4.5 Review（二段レビュー）

- 1次: Reviewer Agent が仕様逸脱/不要変更/リスクを指摘
- 2次: Integrator が受け入れ条件と影響範囲で最終判断
- 未解決コメントが残るPRはマージしない。

### 4.6 Merge（直列統合）

- マージ順序は `土台 -> 機能 -> テスト/ドキュメント` を基本とする。
- マージ方式は `Squash` を推奨する。
- `Require branches to be up to date` を有効化し、最新main追従を必須化する。
- `Merge Queue` を使う場合は `merge_group` トリガーをCIに追加する。

### 4.7 Done（変更完了判定）

- 次の全条件を満たした時のみ `Done` とする:
  - mainがgreen
  - IssueがCloseされている
  - 監査項目（run_id/app_slug/例外ラベル）に欠落がない
  - Follow-upが必要なら次Issueが起票済み

## 5. GitHub設定チェックリスト（最小）

- Branch protection:
  - `Require pull request before merging`
  - `Require status checks to pass before merging`
  - `Require branches to be up to date before merging`
  - `Require conversation resolution before merging`
  - `Require linear history`（推奨）
- Repository settings:
  - `Automatically delete head branches` を有効化
- Actions:
  - 必須チェックのjob名を一意にする
  - 並列時は `concurrency` を設定する

## 6. 参照テンプレート

- `plan/templates/個人xマルチエージェント_TaskBriefテンプレート.md`
- `plan/templates/個人xマルチエージェント_PRチェックリスト.md`
- `plan/templates/個人xマルチエージェント_日次レビュー.md`
- `plan/templates/GitHubブランチ保護監査チェックリスト.md`

## 7. 未決事項

- なし（v0.2運用スコープとして確定）。

## 8. 定期監査運用（R-026対応）

- 監査周期:
  - 定期監査は週1回（毎週金曜）に実施する。
  - Branch protection / required checks を変更した場合は同日中に臨時監査を実施する。
- 監査記録:
  - テンプレートは `plan/templates/GitHubブランチ保護監査チェックリスト.md` を使用する。
  - 実施版は `plan/GitHubブランチ保護監査_YYYY-MM-DD.md` 形式で保存する。
- 台帳反映:
  - 差分なし: `plan/リスク登録簿.md` の監視指標のみ更新する。
  - 差分あり: `plan/バックログ.md` に是正タスク追加、必要時 `plan/意思決定ログ.md` にADR追記する。
