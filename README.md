# マルチエージェント開発ツール

このリポジトリは現在、**企画フェーズ専用**です。  
実装・検証はまだ開始せず、要件、制約、運用ルール、意思決定を先に固めます。

## 現在の方針

- Source of Truth は GitHub Issue
- 企画で決まった内容は `plan/` に必ず反映
- 1つの論点を1つのIssueで扱い、同時に複数論点を混ぜない

## 開発環境構築（アプリ実装とは分離）

開発環境の初期化とチェックは `scripts/` で実行できます。

```bash
# 初期化のみ（.env テンプレート作成、ディレクトリ作成）
make dev-env-init

# 必須コマンド/環境変数チェック
make dev-env-check

# 初期化 + チェック
make dev-env-setup

# GitHub監査設定の収集
make audit-collect

# 収集結果の評価
make audit-evaluate

# レポート生成
make audit-report

# 通知・台帳更新案生成
make audit-dispatch
```

詳細: `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/scripts/README.md`

## ドキュメント導線

- 企画の全体像: `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/企画書.md`
- エージェント設計: `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/エージェント.md`
- 企画運用インデックス: `/Users/ryotarooda/Desktop/マルチエージェント開発ツール/plan/README.md`

## 企画フェーズの完了条件

- 目的/非目的が明文化されている
- 受け入れ条件がIssue単位で定義されている
- 優先度付きバックログがある
- 主要リスクに対して対応方針がある
- 未解決事項が明示され、次の意思決定日が決まっている
