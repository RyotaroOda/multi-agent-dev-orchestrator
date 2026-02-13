#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/audit_fixture.sh [--mode pass|blocked] [--output <path>]
EOF
}

mode="pass"
output="var/state/collector-output.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      mode="${2:-}"
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
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

mkdir -p "$(dirname "${output}")"

if [[ "${mode}" == "pass" ]]; then
  cat > "${output}" <<'JSON'
{
  "status": "collected",
  "repo": "RyotaroOda/multi-agent-dev-orchestrator",
  "branch": "main",
  "repository": {
    "delete_branch_on_merge": true,
    "allow_squash_merge": true
  },
  "branch_protection": {
    "required_pull_request_reviews": true,
    "required_status_checks": true,
    "strict_status_checks": true,
    "required_conversation_resolution": true,
    "required_linear_history": true,
    "required_status_check_contexts": ["lint/format", "unit test", "typecheck", "build"]
  },
  "collected_at": "2026-02-13T00:00:00Z"
}
JSON
elif [[ "${mode}" == "blocked" ]]; then
  cat > "${output}" <<'JSON'
{
  "status": "collected",
  "repo": "RyotaroOda/multi-agent-dev-orchestrator",
  "branch": "main",
  "repository": {
    "delete_branch_on_merge": false,
    "allow_squash_merge": true
  },
  "branch_protection": {
    "required_pull_request_reviews": true,
    "required_status_checks": true,
    "strict_status_checks": false,
    "required_conversation_resolution": true,
    "required_linear_history": true,
    "required_status_check_contexts": ["lint/format"]
  },
  "collected_at": "2026-02-13T00:00:00Z"
}
JSON
else
  echo "invalid mode: ${mode}" >&2
  exit 2
fi

echo "{\"status\":\"fixture_created\",\"mode\":\"${mode}\",\"output\":\"${output}\"}"
