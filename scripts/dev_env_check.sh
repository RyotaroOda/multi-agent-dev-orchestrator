#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env.github-app"

RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
GREEN="$(printf '\033[32m')"
RESET="$(printf '\033[0m')"

failures=0
warnings=0

ok() {
  printf "%s[OK]%s %s\n" "${GREEN}" "${RESET}" "$1"
}

warn() {
  warnings=$((warnings + 1))
  printf "%s[WARN]%s %s\n" "${YELLOW}" "${RESET}" "$1"
}

ng() {
  failures=$((failures + 1))
  printf "%s[NG]%s %s\n" "${RED}" "${RESET}" "$1"
}

check_command() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    ok "コマンド '${cmd}' が見つかりました"
  else
    ng "コマンド '${cmd}' が見つかりません"
  fi
}

read_env_value() {
  local key="$1"
  local value
  value="$(grep -E "^${key}=" "${ENV_FILE}" 2>/dev/null | head -n 1 | cut -d'=' -f2- || true)"
  printf "%s" "${value}"
}

check_env_key() {
  local key="$1"
  local value

  value="$(read_env_value "${key}")"
  if [[ -n "${value}" ]]; then
    ok "環境変数 '${key}' が設定されています"
  else
    ng "環境変数 '${key}' が未設定です（${ENV_FILE}）"
  fi
}

echo "== 開発環境チェック =="
echo "ワークスペース: ${ROOT_DIR}"
echo

echo "-- 必須コマンド --"
check_command "git"
check_command "gh"
check_command "jq"
check_command "curl"

echo
echo "-- 任意コマンド --"
if command -v "docker" >/dev/null 2>&1; then
  ok "コマンド 'docker' が見つかりました"
else
  warn "コマンド 'docker' が見つかりません（必要時のみ導入）"
fi

if command -v "make" >/dev/null 2>&1; then
  ok "コマンド 'make' が見つかりました"
else
  warn "コマンド 'make' が見つかりません（スクリプト直接実行は可能）"
fi

echo
echo "-- GitHub App 環境変数 --"
if [[ -f "${ENV_FILE}" ]]; then
  ok "${ENV_FILE} が存在します"
  check_env_key "GITHUB_APP_ID"
  check_env_key "GITHUB_APP_INSTALLATION_ID"
  check_env_key "GITHUB_APP_SLUG"
  check_env_key "GITHUB_APP_PRIVATE_KEY_PATH"

  key_path="$(read_env_value "GITHUB_APP_PRIVATE_KEY_PATH")"
  if [[ -n "${key_path}" ]]; then
    if [[ "${key_path}" = /* ]]; then
      full_key_path="${key_path}"
    else
      full_key_path="${ROOT_DIR}/${key_path}"
    fi

    if [[ -f "${full_key_path}" ]]; then
      ok "秘密鍵ファイルが存在します: ${full_key_path}"
      if command -v stat >/dev/null 2>&1; then
        perm="$(stat -f "%OLp" "${full_key_path}" 2>/dev/null || true)"
        if [[ -n "${perm}" && "${perm}" != "600" ]]; then
          warn "秘密鍵パーミッションが 600 ではありません（現在: ${perm}）"
        fi
      fi
    else
      ng "秘密鍵ファイルが見つかりません: ${full_key_path}"
    fi
  fi
else
  ng "${ENV_FILE} が存在しません（.env.github-app.example から作成してください）"
fi

echo
echo "-- 結果 --"
if [[ "${failures}" -eq 0 ]]; then
  ok "重大な不足はありません（warning: ${warnings}）"
  exit 0
fi

ng "不足項目が ${failures} 件あります（warning: ${warnings}）"
exit 1
