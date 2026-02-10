# GitHub App作成チェックリスト（v0.2）

## 1. App基本情報

- [ ] App名を決定（例: `multi-agent-orchestrator-bot`）
- [ ] Homepage URL を設定（リポジトリURL）
- [ ] Description に用途（自動PR作成主体）を記載

## 2. 権限設定（最小権限）

- [ ] Repository permissions: `Contents: Read and write`
- [ ] Repository permissions: `Pull requests: Read and write`
- [ ] Repository permissions: `Issues: Read and write`
- [ ] Repository permissions: `Metadata: Read-only`
- [ ] 上記以外の write 権限が無効であることを確認

## 3. インストール設定

- [ ] 対象: `RyotaroOda/multi-agent-dev-orchestrator`
- [ ] インストール範囲: Only selected repositories
- [ ] 対象リポジトリが1件であることを確認

## 4. 鍵管理

- [ ] Private key を新規発行
- [ ] 安全ストアへ保存（ローカル平文保存禁止）
- [ ] 鍵ID・発行日時を記録
- [ ] 旧鍵がある場合は無効化

## 5. 実行情報記録

- [ ] App ID を記録
- [ ] Installation ID を記録
- [ ] App slug を記録
- [ ] 記録先: `plan/意思決定ログ.md`

## 6. 接続確認（最小）

- [ ] installation token 取得が成功する
- [ ] bot author でテストPRを1件作成できる
- [ ] PR本文に `run_id` と `app_slug` を記録できる

## 7. 運用開始条件

- [ ] 鍵ローテーション期限（90日以内）を設定
- [ ] 失効時の暫定手順（手動PR作成）を共有
- [ ] `PLN-031` と `PLN-032` を `done` に更新
