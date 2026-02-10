# DGX Spark対応方針（将来対応 / P2） v0.2-draft

## 1. 目的

v0.2の標準環境（Apple Mac Studio M3 Ultra / 512GB）を維持したまま、NVIDIA DGX Spark への移行準備を低コストで進める。

## 2. スコープ

- DGX Spark 向け差分要件の整理
- リソースプロファイル差分
- 監視指標セット
- 検証シナリオ
- 移行 Go/No-Go 条件とロールバック条件

## 3. 前提

- 優先度は P2（低）で、v0.2必須要件には含めない。
- 本方針は「設計・運用準備」までを対象とし、実装変更は行わない。
- セキュリティ優先順位（A > B > C）は維持する。

## 4. 差分要件（Mac基準 -> DGX）

| 項目 | Mac基準 | DGX方針 |
| --- | --- | --- |
| 並列制御の主指標 | queue詰まり + macOSメモリプレッシャ | queue詰まり + GPU利用率 + GPUメモリ使用率 |
| コンテナ制限値 | CPU/メモリ/PIDs/ディスク中心 | GPU割当上限を追加（GPUメモリ上限含む） |
| モデル運用 | JIT + TTL | JIT + TTLを維持しつつ、GPU常駐候補を最小数で定義 |
| 運用監視 | Run/KPI中心 | Run/KPI + GPU指標（温度除く）を追加 |
| 失敗判定 | `resource_exceeded` 中心 | `resource_exceeded` を CPU系/GPU系に分類 |

## 5. リソースプロファイル（確定版 / v0.2）

- `profile:mac-v02`（現行）
  - CPU: `--cpus=8`
  - メモリ: `--memory=64g`
  - PIDs: `--pids-limit=2048`
  - ディスク: 80GiB
- `profile:dgx-draft`（将来）
  - CPU/メモリ/PIDs/ディスクは `mac-v02` を踏襲
  - GPU割当上限: `1 GPU / Run`
  - GPUメモリ上限: `70% / Run`
  - 同時GPU Run上限: `2`
  - ホスト全体GPUメモリ上限: `85%`

## 6. 監視指標セット（DGX）

- 必須:
  - GPU利用率（run単位）
  - GPUメモリ使用率（run単位）
  - queue depth
  - blocked理由カテゴリ（CPU系/GPU系/その他）
- 補助:
  - モデルロード時間
  - Run時間 p50/p90
  - `resource_exceeded` blocked率（GPU系）

## 7. 検証シナリオ（5ケース）

### 正常系（3）

1. 単一Issue処理で `resource_exceeded` なし
2. 2並列Issue処理で queue遅延が閾値内
3. JIT/TTL運用でモデル再ロードが許容時間内

### 異常系（2）

1. GPUメモリ逼迫時に Level降格（2->1 or 1->0）が発火する
2. GPU関連失敗時に `blocked` と要因分類（GPU系）が正しく残る

## 8. Go/No-Go 条件（DGX移行判定）

- Go 条件（7日連続で満たす）:
  - throughput が Mac基準比で 1.2倍以上
  - `resource_exceeded` blocked率（GPU系含む）が 5% 以下
  - 平均Run時間 p50/p90 が Mac基準を悪化させない
- No-Go 条件:
  - `resource_exceeded` blocked率（GPU系）が 8% 超
  - 並列Levelの頻繁降格（1日3回超）が3日連続
  - 主要KPI（throughput/merge率）が Mac基準比で悪化
  - GPUメモリ使用率が `85%` 超で24時間継続

## 9. ロールバック条件

- No-Go 条件を満たした場合は `profile:mac-v02` に即時切り戻し
- 切り戻し後は DGXプロファイル変更を凍結し、原因分類を完了するまで再試行しない

## 10. 移行判定の承認体制（確定）

- 最終承認者: PM（責任者）
- 共同承認者:
  - 技術責任者
  - セキュリティ責任者
- 判定会議の成立条件:
  - 最終承認者 + 共同承認者2名の全員参加

## 11. GPU指標取得の運用前提（v0.2）

- 取得経路: NVML互換メトリクス経路（runner側集約）
- サンプリング間隔: 60秒
- 欠損時の扱い: fail-safe で Level 1 へ降格し、`blocked` ではなく監視強化

## 12. 未決事項

- なし（v0.2範囲で確定済み）。
