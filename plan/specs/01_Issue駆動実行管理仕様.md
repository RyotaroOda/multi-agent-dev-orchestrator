# Issue駆動実行管理仕様書 v0.2-draft

## 1. 目的

GitHub Issue を Source of Truth とし、重複実行なく Run を開始・進行・停止・再開できる状態管理を定義する。

## 2. スコープ

- Issue ラベルによるトリガ管理
- `run_id` による排他制御
- `blocked` / `retry` の運用
- give-up 閾値超過時の停止

## 3. 前提

- 実行開始トリガは `agent:queued`。
- 状態ラベルは `agent:queued` / `agent:running` / `agent:blocked` / `agent:retry` を使用。
- Issue コメントに構造化ログを残せる権限がある。

## 4. 機能要件

### FR-101 Run開始

- 条件:
  - `agent:queued` が付与されている。
  - 同一 Issue に有効な `run_id` が存在しない。
- 処理:
  - `run_id` を採番。
  - Run Header を Issue コメントへ投稿。
  - ラベルを `agent:running` へ遷移。

### FR-102 排他

- 実行中の全更新は `run_id` 一致を必須とする。
- 不一致の更新要求は破棄し、監査ログへ `lock_mismatch` を記録する。

### FR-103 Blocked遷移

- 以下のいずれかで `agent:blocked` に遷移:
  - 品質ルール違反
  - リトライ上限超過
  - 実行環境異常
- 遷移時は「失敗要約」「直近失敗点」「人間に必要な判断」を Issue コメントへ出力する。

### FR-104 Retry遷移

- `agent:retry` ラベル付与または `/retry` コメントで再実行可能。
- v0.2 はクリーンスタートを既定とし、旧 Run の中間状態を引き継がない。

### FR-105 Give-up

- 1 Issue あたりの最大リトライ回数を設定値で管理（初期値 5）。
- 上限超過時は自動再試行せず `agent:blocked` へ遷移する。

## 5. 非機能要件

- 状態遷移の冪等性: 同一イベントの再処理でも状態破壊を起こさない。
- 追跡可能性: すべての状態遷移は `run_id` と時刻付きで追跡できる。

## 6. 入出力契約

### 入力

- Issue ラベルイベント
- Issue コメントイベント（`/retry`）

### 出力

- Run Header コメント（YAML/JSON）
- Task/Stage 終了ログコメント（構造化）
- ラベル更新

## 7. 状態遷移

`queued -> running -> blocked`

`blocked -> retry -> running`

`running -> completed` は PR/CI 完了後に運用側で閉じる（Issue close 方針は別仕様）。

## 8. 異常系

- `run_id` 採番失敗: Run 開始中止、`agent:blocked` へ遷移。
- ラベル更新失敗: 再試行 1 回後に `agent:blocked`。
- コメント投稿失敗: ラベル遷移を行わず失敗終了。

## 9. 受け入れ条件

- 同一 Issue への二重起動要求で同時 Run が成立しない。
- `retry` 操作で新 `run_id` が採番される。
- give-up 超過時に自動で `agent:blocked` へ遷移する。

## 10. 未決事項

- `completed` 状態をラベル化するか（例: `agent:done`）。
- `retry` 実行権限（誰の操作を受理するか）。
- `/retry` コメントの認可方式（GitHub ロール連携要否）。
