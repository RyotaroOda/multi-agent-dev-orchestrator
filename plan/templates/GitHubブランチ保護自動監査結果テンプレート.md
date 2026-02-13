# GitHubブランチ保護自動監査結果テンプレート

## 1. 監査情報

- 監査ID: `AUDIT-YYYYMMDD-01`
- 実施日:
- 実行モード（定期/臨時/再実行）:
- 実施者（Agent）:
- 承認者（Integrator）:
- 対象リポジトリ:
- 対象ブランチ:
- `run_id`:
- `app_slug`:

## 2. Branch protection監査

| 項目 | 期待値 | 実測 | 判定（OK/NG） | 備考 |
| --- | --- | --- | --- | --- |
| Require pull request before merging | ON |  |  |  |
| Require status checks to pass before merging | ON |  |  |  |
| Require branches to be up to date before merging | ON |  |  |  |
| Require conversation resolution before merging | ON |  |  |  |
| Require linear history | ON（推奨） |  |  |  |

## 3. Required checks監査

- 期待一覧:
  - lint/format
  - typecheck（該当時）
  - unit test
  - build（該当時）
- 実測一覧:
  - 
- 判定:
  - `pass/blocked`
- 差分:
  - 

## 4. Repository設定監査

| 項目 | 期待値 | 実測 | 判定（OK/NG） | 備考 |
| --- | --- | --- | --- | --- |
| Automatically delete head branches | ON |  |  |  |
| Merge方式（Squash） | 有効 |  |  |  |

## 5. 監査メタデータ整合

| 項目 | 判定（OK/NG） | 備考 |
| --- | --- | --- |
| `run_id` 追跡可能 |  |  |
| `app_slug` が bot 主体と一致 |  |  |
| 例外ラベル4項目（理由/適用範囲/失効日/承認者）充足 |  |  |
| 判定語彙（allow/deny/blocked）整合 |  |  |

## 6. 総合判定

- 監査判定（`pass/blocked`）:
- `run_control`（`continue/blocked`）:
- 判定理由:

## 7. 是正計画（差分あり時のみ）

- 是正対象:
- 是正タスクID:
- 担当:
- 期限:

## 8. 台帳反映

- `plan/バックログ.md` 更新: 有/無
- `plan/リスク登録簿.md` 更新: 有/無
- `plan/意思決定ログ.md` 更新: 有/無

## 9. 企画タスク出力

- 結論:
- 根拠:
- 未決事項:
- 次アクション:
