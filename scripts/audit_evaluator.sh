#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/audit_evaluator.sh --input <collector-json-path> [--audit-id <id>] [--run-id <id>] [--app-slug <slug>] [--require-check <name> ...]

Options:
  --input          Required. Collector output JSON path.
  --audit-id       Optional. Audit ID.
  --run-id         Optional. run_id for metadata validation.
  --app-slug       Optional. app_slug for metadata validation.
  --require-check  Optional. Required status check context (repeatable).
                   If omitted, defaults to "lint/format" and "unit test".
EOF
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "{\"status\":\"blocked\",\"run_control\":\"blocked\",\"failed_stage\":\"preflight\",\"reason\":\"missing_command:${cmd}\"}"
    exit 1
  fi
}

json_escape() {
  printf '%s' "$1" | sed 's/"/\\"/g'
}

input=""
audit_id=""
run_id=""
app_slug=""
required_checks=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      input="${2:-}"
      shift 2
      ;;
    --audit-id)
      audit_id="${2:-}"
      shift 2
      ;;
    --run-id)
      run_id="${2:-}"
      shift 2
      ;;
    --app-slug)
      app_slug="${2:-}"
      shift 2
      ;;
    --require-check)
      required_checks+=("${2:-}")
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${input}" ]]; then
  usage >&2
  exit 2
fi

require_cmd "jq"

if [[ ! -f "${input}" ]]; then
  echo "{\"status\":\"blocked\",\"run_control\":\"blocked\",\"failed_stage\":\"input\",\"reason\":\"input_not_found:${input}\"}"
  exit 1
fi

if [[ ${#required_checks[@]} -eq 0 ]]; then
  required_checks=("lint/format" "unit test")
fi

collector_status="$(jq -r '.status // ""' "${input}")"
if [[ "${collector_status}" != "collected" ]]; then
  reason="$(jq -r '.reason // "collector_not_collected"' "${input}")"
  echo "{\"status\":\"blocked\",\"run_control\":\"blocked\",\"failed_stage\":\"collector\",\"reason\":\"${reason}\"}"
  exit 1
fi

declare -a diffs

check_bool_field() {
  local field="$1"
  local expected="$2"
  local actual
  actual="$(jq -r "${field}" "${input}")"
  if [[ "${actual}" != "${expected}" ]]; then
    diffs+=("{\"field\":\"$(json_escape "${field}")\",\"expected\":\"${expected}\",\"actual\":\"$(json_escape "${actual}")\",\"reason\":\"mismatch\"}")
  fi
}

# Metadata presence checks
if [[ -z "${run_id}" ]]; then
  diffs+=("{\"field\":\"run_id\",\"expected\":\"non_empty\",\"actual\":\"empty\",\"reason\":\"metadata_missing\"}")
fi
if [[ -z "${app_slug}" ]]; then
  diffs+=("{\"field\":\"app_slug\",\"expected\":\"non_empty\",\"actual\":\"empty\",\"reason\":\"metadata_missing\"}")
fi

# Branch protection / repository checks
bp_endpoint_available="$(
  jq -r '
    if (.branch_protection | type) == "object" and (.branch_protection | has("endpoint_available"))
    then (.branch_protection.endpoint_available | tostring)
    else "true"
    end
  ' "${input}"
)"
if [[ "${bp_endpoint_available}" == "true" ]]; then
  check_bool_field '.branch_protection.required_pull_request_reviews' 'true'
  check_bool_field '.branch_protection.required_status_checks' 'true'
  check_bool_field '.branch_protection.strict_status_checks' 'true'
  check_bool_field '.branch_protection.required_conversation_resolution' 'true'
  check_bool_field '.branch_protection.required_linear_history' 'true'
fi
check_bool_field '.repository.delete_branch_on_merge' 'true'
check_bool_field '.repository.allow_squash_merge' 'true'

# Required status check contexts
for check_name in "${required_checks[@]}"; do
  if ! jq -e --arg c "${check_name}" '.branch_protection.required_status_check_contexts[]? | select(. == $c)' "${input}" >/dev/null; then
    diffs+=("{\"field\":\"required_status_check_contexts\",\"expected\":\"contains:$(json_escape "${check_name}")\",\"actual\":\"missing\",\"reason\":\"missing_required_check\"}")
  fi
done

status="pass"
run_control="continue"
if [[ "${#diffs[@]}" -gt 0 ]]; then
  status="blocked"
  run_control="blocked"
fi

diffs_json="[]"
if [[ "${#diffs[@]}" -gt 0 ]]; then
  diffs_json="["
  for i in "${!diffs[@]}"; do
    if [[ "${i}" -gt 0 ]]; then
      diffs_json+=","
    fi
    diffs_json+="${diffs[$i]}"
  done
  diffs_json+="]"
fi

jq -n \
  --arg audit_id "${audit_id}" \
  --arg status "${status}" \
  --arg run_control "${run_control}" \
  --arg run_id "${run_id}" \
  --arg app_slug "${app_slug}" \
  --argjson diffs "${diffs_json}" '
  {
    audit_id: (if $audit_id == "" then null else $audit_id end),
    result: $status,
    run_control: $run_control,
    metadata: {
      run_id: $run_id,
      app_slug: $app_slug
    },
    diffs: $diffs
  }'
