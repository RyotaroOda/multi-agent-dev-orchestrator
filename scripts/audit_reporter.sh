#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/audit_reporter.sh --collector <path> --evaluator <path> [--output <path>] [--mode <scheduled|manual|retry>] [--approver <name>]
EOF
}

require_cmd() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || {
    echo "missing command: ${cmd}" >&2
    exit 1
  }
}

collector=""
evaluator=""
output=""
mode="manual"
approver="Integrator"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --collector)
      collector="${2:-}"
      shift 2
      ;;
    --evaluator)
      evaluator="${2:-}"
      shift 2
      ;;
    --output)
      output="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --approver)
      approver="${2:-}"
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

if [[ -z "${collector}" || -z "${evaluator}" ]]; then
  usage >&2
  exit 2
fi

require_cmd "jq"

if [[ ! -f "${collector}" || ! -f "${evaluator}" ]]; then
  echo "collector or evaluator input not found" >&2
  exit 1
fi

today="$(date +%F)"
if [[ -z "${output}" ]]; then
  output="plan/GitHubブランチ保護監査_${today}.md"
fi

repo="$(jq -r '.repo // "unknown"' "${collector}")"
branch="$(jq -r '.branch // "main"' "${collector}")"
audit_id="$(jq -r '.audit_id // "AUDIT-unknown"' "${evaluator}")"
result="$(jq -r '.result // "blocked"' "${evaluator}")"
run_control="$(jq -r '.run_control // "blocked"' "${evaluator}")"
run_id="$(jq -r '.metadata.run_id // ""' "${evaluator}")"
app_slug="$(jq -r '.metadata.app_slug // ""' "${evaluator}")"
diff_count="$(jq -r '(.diffs // []) | length' "${evaluator}")"

required_pr_reviews="$(jq -r '.branch_protection.required_pull_request_reviews // false' "${collector}")"
required_status_checks="$(jq -r '.branch_protection.required_status_checks // false' "${collector}")"
strict_status_checks="$(jq -r '.branch_protection.strict_status_checks // false' "${collector}")"
required_conversation_resolution="$(jq -r '.branch_protection.required_conversation_resolution // false' "${collector}")"
required_linear_history="$(jq -r '.branch_protection.required_linear_history // false' "${collector}")"
delete_branch_on_merge="$(jq -r '.repository.delete_branch_on_merge // false' "${collector}")"
allow_squash_merge="$(jq -r '.repository.allow_squash_merge // false' "${collector}")"

checks_list="$(jq -r '.branch_protection.required_status_check_contexts // [] | .[]' "${collector}" | sed 's/^/- /')"
if [[ -z "${checks_list}" ]]; then
  checks_list="- (none)"
fi

diff_lines="$(jq -r '.diffs // [] | .[] | "- \(.field): expected=\(.expected), actual=\(.actual), reason=\(.reason)"' "${evaluator}")"
if [[ -z "${diff_lines}" ]]; then
  diff_lines="- なし"
fi

mkdir -p "$(dirname "${output}")"

cat > "${output}" <<EOF
# GitHubブランチ保護自動監査結果

## 1. 監査情報

- 監査ID: \`${audit_id}\`
- 実施日: ${today}
- 実行モード: ${mode}
- 実施者（Agent）: Audit Agent
- 承認者（Integrator）: ${approver}
- 対象リポジトリ: \`${repo}\`
- 対象ブランチ: \`${branch}\`
- \`run_id\`: \`${run_id}\`
- \`app_slug\`: \`${app_slug}\`

## 2. Branch protection監査（実測）

| 項目 | 実測 |
| --- | --- |
| Require pull request before merging | ${required_pr_reviews} |
| Require status checks to pass before merging | ${required_status_checks} |
| Require branches to be up to date before merging | ${strict_status_checks} |
| Require conversation resolution before merging | ${required_conversation_resolution} |
| Require linear history | ${required_linear_history} |

## 3. Required checks監査（実測）

${checks_list}

## 4. Repository設定監査（実測）

| 項目 | 実測 |
| --- | --- |
| Automatically delete head branches | ${delete_branch_on_merge} |
| Merge方式（Squash） | ${allow_squash_merge} |

## 5. 総合判定

- 監査判定: \`${result}\`
- \`run_control\`: \`${run_control}\`
- 差分件数: ${diff_count}

## 6. 差分一覧

${diff_lines}

## 7. 台帳反映

- \`plan/バックログ.md\`: $( [[ "${result}" == "blocked" ]] && echo "要更新" || echo "差分なし" )
- \`plan/リスク登録簿.md\`: $( [[ "${result}" == "blocked" ]] && echo "要更新" || echo "差分なし" )
- \`plan/意思決定ログ.md\`: $( [[ "${result}" == "blocked" ]] && echo "必要時更新" || echo "差分なし" )
EOF

echo "{\"status\":\"reported\",\"output\":\"${output}\"}"
