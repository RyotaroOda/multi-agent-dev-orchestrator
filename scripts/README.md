# scripts ディレクトリ

## 目的

開発環境構築の初期化とチェックを、アプリ本体実装と分離して実行する。

## スクリプト一覧

- `dev_env_setup.sh`
  - `var/log/audit` と `var/state` を作成
  - `.env.github-app` 未作成時に `.env.github-app.example` から生成
  - 必要に応じて `dev_env_check.sh` を実行
- `dev_env_check.sh`
  - 必須コマンド（`git`/`gh`/`jq`/`curl`）の存在確認
  - `.env.github-app` の必須キー確認
  - 秘密鍵パスの存在確認
- `audit_collector.sh`
  - GitHub APIから監査対象設定を収集
  - Branch protection / required checks / Repository設定をJSONで出力
  - API失敗時は `collector_failed` を返して終了
  - `GH_TOKEN` 設定が前提（`github_app_token.sh` で都度発行）
- `github_app_token.sh`
  - `.env.github-app` の App ID / Installation ID / 秘密鍵から installation token を都度発行
  - 標準出力で token を返す（保存しない）
- `audit_evaluator.sh`
  - Collector出力JSONを評価し、`pass/blocked` と `run_control` を返す
  - 差分一覧（`diffs[]`）をJSONで出力
  - Collector失敗結果を受けた場合は `blocked` を返す
- `audit_reporter.sh`
  - Collector/Evaluator出力JSONから監査レポートMarkdownを生成
  - 出力先は既定で `plan/GitHubブランチ保護監査_YYYY-MM-DD.md`
- `audit_dispatcher.sh`
  - Evaluator出力JSONから通知文案と台帳更新案を生成
  - `blocked` 時は `dispatcher-ledger-proposal.md` を出力
- `audit_fixture.sh`
  - オフライン検証用のCollector出力fixtureを生成
  - `pass` / `blocked` を切り替えて後段をテストできる

## 使い方

```bash
# 初期化のみ（チェックなし）
./scripts/dev_env_setup.sh --init-only

# チェックのみ
./scripts/dev_env_check.sh

# 初期化 + チェック
./scripts/dev_env_setup.sh

# 監査設定の収集（標準出力）
GH_TOKEN="$(./scripts/github_app_token.sh)" ./scripts/audit_collector.sh --repo RyotaroOda/multi-agent-dev-orchestrator --branch main

# 監査設定の収集（ファイル出力）
GH_TOKEN="$(./scripts/github_app_token.sh)" ./scripts/audit_collector.sh --repo RyotaroOda/multi-agent-dev-orchestrator --branch main --output var/state/collector-output.json

# 収集結果の評価
./scripts/audit_evaluator.sh --input var/state/collector-output.json --audit-id AUDIT-local-001 --run-id local-run-001 --app-slug multi-agent-orchestrator-bot > var/state/evaluator-output.json

# レポート生成
./scripts/audit_reporter.sh --collector var/state/collector-output.json --evaluator var/state/evaluator-output.json --mode manual --approver Integrator

# 通知・台帳更新案の生成
./scripts/audit_dispatcher.sh --evaluator var/state/evaluator-output.json --mode manual --output-dir var/state

# オフライン一括スモーク（blockedケース）
make audit-smoke-local
```

Makefile経由:

```bash
make dev-env-init
make dev-env-check
make dev-env-setup
make audit-collect
make audit-evaluate
make audit-report
make audit-dispatch
make audit-smoke-local
```
