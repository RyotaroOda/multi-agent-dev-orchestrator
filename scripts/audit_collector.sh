#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/audit_collector.sh --repo <owner/repo> [--branch <name>] [--output <path>]

Options:
  --repo    Required. Target repository (example: RyotaroOda/multi-agent-dev-orchestrator)
  --branch  Optional. Target branch (default: main)
  --output  Optional. Output file path. If omitted, JSON is printed to stdout.
EOF
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "{\"status\":\"collector_failed\",\"failed_stage\":\"preflight\",\"reason\":\"missing_command:${cmd}\"}"
    exit 1
  fi
}

repo=""
branch="main"
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --branch)
      branch="${2:-}"
      shift 2
      ;;
    --output)
      output="${2:-}"
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

if [[ -z "${repo}" ]]; then
  usage >&2
  exit 2
fi

require_cmd "gh"
require_cmd "jq"

gh_get_with_retry() {
  local endpoint="$1"
  local attempt=1
  local max_attempt=2
  local result=""

  while [[ "${attempt}" -le "${max_attempt}" ]]; do
    if result="$(gh api \
      -H "Accept: application/vnd.github+json" \
      "${endpoint}" 2>/dev/null)"; then
      printf '%s' "${result}"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done

  return 1
}

extract_http_body() {
  awk 'BEGIN{body=0} body{print} /^[[:space:]]*$/{if(body==0){body=1}}'
}

gh_get_allow_404() {
  local endpoint="$1"
  local raw=""

  if raw="$(gh api -i \
    -H "Accept: application/vnd.github+json" \
    "${endpoint}" 2>&1)"; then
    printf '%s' "${raw}" | extract_http_body
    return 0
  fi

  if printf '%s' "${raw}" | grep -Eq 'HTTP/[0-9.]+ 404'; then
    return 4
  fi

  return 1
}

repo_json="$(gh_get_with_retry "/repos/${repo}")" || {
  echo "{\"status\":\"collector_failed\",\"failed_stage\":\"repository\",\"reason\":\"api_request_failed:/repos/${repo}\"}"
  exit 1
}

protection_endpoint_available=true
if protection_json="$(gh_get_with_retry "/repos/${repo}/branches/${branch}/protection")"; then
  :
else
  if protection_body="$(gh_get_allow_404 "/repos/${repo}/branches/${branch}/protection")"; then
    protection_json="${protection_body}"
  else
    status=$?
    if [[ "${status}" -eq 4 ]]; then
      protection_json="{}"
      protection_endpoint_available=false
    else
      echo "{\"status\":\"collector_failed\",\"failed_stage\":\"branch_protection\",\"reason\":\"api_request_failed:/repos/${repo}/branches/${branch}/protection\"}"
      exit 1
    fi
  fi
fi

# Rulesets API is optional. If unavailable, continue with empty list.
rulesets_json="[]"
if fetched_rulesets="$(gh_get_with_retry "/repos/${repo}/rulesets?includes_parents=true")"; then
  rulesets_json="${fetched_rulesets}"
fi

collected_json="$(
  jq -n \
    --arg repo "${repo}" \
    --arg branch "${branch}" \
    --arg protection_endpoint_available "${protection_endpoint_available}" \
    --argjson repository "${repo_json}" \
    --argjson protection "${protection_json}" \
    --argjson rulesets "${rulesets_json}" '
    def ruleset_check_contexts($branch):
      [
        $rulesets[]?
        | select((.target // "") == "branch")
        | select((.enforcement // "active") != "disabled")
        | select(
            (
              .conditions.ref_name.include // []
            ) as $inc
            | ($inc | length == 0)
              or ($inc | index("~DEFAULT_BRANCH") != null)
              or ($inc | index(("refs/heads/" + $branch)) != null)
              or ($inc | index($branch) != null)
          )
        | .rules[]?
        | select(.type == "required_status_checks")
        | .parameters.required_status_checks[]?.context
      ] | unique;

    {
      status: "collected",
      repo: $repo,
      branch: $branch,
      repository: {
        delete_branch_on_merge: $repository.delete_branch_on_merge,
        allow_squash_merge: $repository.allow_squash_merge
      },
      branch_protection: {
        endpoint_available: ($protection_endpoint_available == "true"),
        required_pull_request_reviews: ($protection.required_pull_request_reviews != null),
        required_status_checks: ($protection.required_status_checks != null),
        strict_status_checks: ($protection.required_status_checks.strict // false),
        required_conversation_resolution: ($protection.required_conversation_resolution.enabled // false),
        required_linear_history: ($protection.required_linear_history.enabled // false),
        required_status_check_contexts: (
          (
            ($protection.required_status_checks.contexts // [])
            +
            (($protection.required_status_checks.checks // []) | map(.context))
            +
            ruleset_check_contexts($branch)
          ) | unique
        )
      },
      collected_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
    }'
)"

if [[ -n "${output}" ]]; then
  mkdir -p "$(dirname "${output}")"
  printf '%s\n' "${collected_json}" > "${output}"
  echo "{\"status\":\"collected\",\"output\":\"${output}\"}"
else
  printf '%s\n' "${collected_json}"
fi
