# Issueテンプレート v0.2（SoT用）

## 1. 概要

- タイトル:
- 背景:
- 目的:
- 優先度: `P0 / P1 / P2`

## 2. Spec Block

```yaml
spec_version: 0.2
title: ""
problem: ""
goals:
  - ""
non_goals:
  - ""
acceptance_criteria:
  - ""
constraints:
  - "CI設定変更は禁止（例外ラベルが必要）"
  - "秘密情報を外部送信しない"
tech_notes:
  frontend: ""
  backend: ""
api_notes:
  - ""
test_plan:
  - "unit: "
  - "integration: "
priority: "P1"
```

## 3. 受け入れ条件（観測可能）

- [ ] 条件1:
- [ ] 条件2:
- [ ] 条件3:

## 4. ポリシー例外（必要時のみ）

- `policy:allow-test-change`:
  - 理由:
  - 適用範囲:
  - 失効日:
  - 承認者:
- `policy:allow-ci-change`:
  - 理由:
  - 適用範囲:
  - 失効日:
  - 承認者:
- `policy:cloud-llm=allow`:
  - 理由:
  - 適用範囲:
  - 失効日:
  - 承認者:

## 5. 実行時メモ

- 想定ステージ:
- 依存Issue:
- ブロッカー:

## 6. Definition of Ready

- [ ] 目的が1文で定義されている
- [ ] 非目的が3件以上記載されている
- [ ] 受け入れ条件が観測可能な文で3件以上ある
- [ ] 例外ラベル利用時は理由/適用範囲/失効日/承認者が埋まっている
