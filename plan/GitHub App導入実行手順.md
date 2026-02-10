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

## 2.1 GitHub UI操作（PLN-031）

1. GitHub 右上プロフィール -> `Settings` -> `Developer settings` -> `GitHub Apps` -> `New GitHub App`。
2. App名、Homepage URL、Description を入力。
3. Repository permissions を次に設定。
   - `Contents: Read and write`
   - `Pull requests: Read and write`
   - `Issues: Read and write`
   - `Metadata: Read-only`
4. App を作成後、`Generate a private key` を実行。
5. `Install App` から `RyotaroOda/multi-agent-dev-orchestrator` を選択してインストール。
6. Appページで `App ID` と `Slug` を控える。InstallationページURLから `Installation ID` を控える。
7. `plan/templates/GitHub App設定値記録テンプレート.md` に記入。

## 2.2 スモークテスト（PLN-032）

1. installation token を発行して、bot主体でブランチ作成・push・PR作成を行う。
2. テストPR本文に `run_id` と `app_slug` を記載する。
3. Issue #3 に PR URL、結果、失敗時理由をコメントする。

## 3. 記録先

- 方針/決定: `plan/意思決定ログ.md`
- タスク状態: `plan/バックログ.md`
- リスク監視: `plan/リスク登録簿.md`
- 設定値記録: `plan/templates/GitHub App設定値記録テンプレート.md`

## 4. 完了条件

- `PLN-031` が done
- `PLN-032` が done
- テストPRで `run_id` と `app_slug` を確認済み
