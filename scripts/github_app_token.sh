#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/github_app_token.sh [--env-file <path>]

Description:
  Generate a GitHub App installation token from:
  - GITHUB_APP_ID
  - GITHUB_APP_INSTALLATION_ID
  - GITHUB_APP_PRIVATE_KEY_PATH
EOF
}

env_file=".env.github-app"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      env_file="${2:-}"
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

if [[ -f "${env_file}" ]]; then
  # shellcheck disable=SC1090
  source "${env_file}"
fi

: "${GITHUB_APP_ID:?GITHUB_APP_ID is required}"
: "${GITHUB_APP_INSTALLATION_ID:?GITHUB_APP_INSTALLATION_ID is required}"
: "${GITHUB_APP_PRIVATE_KEY_PATH:?GITHUB_APP_PRIVATE_KEY_PATH is required}"

if [[ "${GITHUB_APP_PRIVATE_KEY_PATH}" = /* ]]; then
  key_path="${GITHUB_APP_PRIVATE_KEY_PATH}"
else
  key_path="$(pwd)/${GITHUB_APP_PRIVATE_KEY_PATH}"
fi

if [[ ! -f "${key_path}" ]]; then
  echo "private key not found: ${key_path}" >&2
  exit 1
fi

b64url() {
  openssl base64 -A | tr '+/' '-_' | tr -d '='
}

now="$(date +%s)"
iat=$((now - 60))
exp=$((now + 540))

header='{"alg":"RS256","typ":"JWT"}'
payload="$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "${iat}" "${exp}" "${GITHUB_APP_ID}")"

header_b64="$(printf '%s' "${header}" | b64url)"
payload_b64="$(printf '%s' "${payload}" | b64url)"
unsigned_token="${header_b64}.${payload_b64}"

signature_b64="$(
  printf '%s' "${unsigned_token}" \
    | openssl dgst -sha256 -sign "${key_path}" \
    | b64url
)"

jwt="${unsigned_token}.${signature_b64}"

token_response="$(
  curl -fsSL -X POST \
    -H "Authorization: Bearer ${jwt}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/app/installations/${GITHUB_APP_INSTALLATION_ID}/access_tokens"
)"

installation_token="$(printf '%s' "${token_response}" | jq -r '.token // empty')"
if [[ -z "${installation_token}" ]]; then
  echo "failed to generate installation token" >&2
  exit 1
fi

printf '%s\n' "${installation_token}"
