#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/audit_dispatcher.sh --evaluator <path> [--mode <scheduled|manual|retry>] [--output-dir <path>]
EOF
}

require_cmd() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || {
    echo "missing command: ${cmd}" >&2
    exit 1
  }
}

evaluator=""
mode="manual"
output_dir="var/state"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --evaluator)
      evaluator="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --output-dir)
      output_dir="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${evaluator}" ]]; then
  usage >&2
  exit 2
fi

require_cmd "jq"

if [[ ! -f "${evaluator}" ]]; then
  echo "evaluator input not found: ${evaluator}" >&2
  exit 1
fi

result="$(jq -r '.result // "blocked"' "${evaluator}")"
run_control="$(jq -r '.run_control // "blocked"' "${evaluator}")"
audit_id="$(jq -r '.audit_id // "AUDIT-unknown"' "${evaluator}")"
run_id="$(jq -r '.metadata.run_id // ""' "${evaluator}")"
app_slug="$(jq -r '.metadata.app_slug // ""' "${evaluator}")"
diff_count="$(jq -r '(.diffs // []) | length' "${evaluator}")"

mkdir -p "${output_dir}"
notice_file="${output_dir}/dispatcher-notice.md"
proposal_file="${output_dir}/dispatcher-ledger-proposal.md"

if [[ "${result}" == "blocked" || "${run_control}" == "blocked" ]]; then
  cat > "${notice_file}" <<EOF
# 監査結果通知（要対応）

- 監査ID: \`${audit_id}\`
- 実行モード: \`${mode}\`
- 判定: \`${result}\`
- run_control: \`${run_control}\`
- run_id: \`${run_id}\`
- app_slug: \`${app_slug}\`
- 差分件数: ${diff_count}

次アクション:
1. 差分内容を確認し、同日中に是正方針を確定する
2. 再実行条件を満たした後、監査ジョブを再実行する
3. 必要に応じてバックログ/リスク/意思決定ログを更新する
EOF

  cat > "${proposal_file}" <<EOF
# 台帳更新案（blocked）

## plan/バックログ.md

- 是正タスクを1件追加（タイトル例: 「監査差分是正: ${audit_id}」）
- 受け入れ条件に差分解消と再監査成功を含める

## plan/リスク登録簿.md

- 監査差分に対応するリスク状態を \`watching\` で更新
- 監視指標に「同日再実行未実施件数」を追記

## plan/意思決定ログ.md

- 閾値変更や運用変更が必要な場合のみADRを追記
EOF

  jq -n \
    --arg status "dispatched" \
    --arg action_required "true" \
    --arg notice "${notice_file}" \
    --arg proposal "${proposal_file}" '
    {
      status: $status,
      action_required: ($action_required == "true"),
      notice_file: $notice,
      ledger_proposal_file: $proposal
    }'
else
  cat > "${notice_file}" <<EOF
# 監査結果通知（差分なし）

- 監査ID: \`${audit_id}\`
- 実行モード: \`${mode}\`
- 判定: \`${result}\`
- run_control: \`${run_control}\`
- 差分件数: ${diff_count}

次アクション:
- 台帳更新は不要（定期記録のみ）
EOF

  jq -n \
    --arg status "dispatched" \
    --arg action_required "false" \
    --arg notice "${notice_file}" '
    {
      status: $status,
      action_required: ($action_required == "true"),
      notice_file: $notice
    }'
fi
