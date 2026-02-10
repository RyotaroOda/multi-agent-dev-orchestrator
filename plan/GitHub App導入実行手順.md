# GitHub App導入実行手順（PLN-031/032）

## 1. 対象

- Issue: `#2`（PLN-031）
- Issue: `#3`（PLN-032）
- リポジトリ: `RyotaroOda/multi-agent-dev-orchestrator`

## 2. 実施順

1. GitHub Appを作成し、対象リポジトリへインストールする。
2. App ID / Installation ID / app slug を控える。
3. `plan/templates/GitHub App作成チェックリスト.md` を埋める。
4. installation token で bot author のテストPRを1件作成する。
5. 結果を Issue #3 コメントに記録する。

## 3. 記録先

- 方針/決定: `plan/意思決定ログ.md`
- タスク状態: `plan/バックログ.md`
- リスク監視: `plan/リスク登録簿.md`

## 4. 完了条件

- `PLN-031` が done
- `PLN-032` が done
- テストPRで `run_id` と `app_slug` を確認済み
