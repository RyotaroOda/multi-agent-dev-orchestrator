#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_SAMPLE="${ROOT_DIR}/.env.github-app.example"
ENV_FILE="${ROOT_DIR}/.env.github-app"
LOG_DIR="${ROOT_DIR}/var/log/audit"
STATE_DIR="${ROOT_DIR}/var/state"

INIT_ONLY=0

for arg in "$@"; do
  case "${arg}" in
    --init-only)
      INIT_ONLY=1
      ;;
    *)
      echo "未対応オプションです: ${arg}" >&2
      echo "使用方法: $0 [--init-only]" >&2
      exit 2
      ;;
  esac
done

echo "== 開発環境セットアップ =="
echo "ワークスペース: ${ROOT_DIR}"
echo

mkdir -p "${LOG_DIR}" "${STATE_DIR}"
echo "作成済みディレクトリ:"
echo "- ${LOG_DIR}"
echo "- ${STATE_DIR}"

if [[ ! -f "${ENV_FILE}" ]]; then
  if [[ -f "${ENV_SAMPLE}" ]]; then
    cp "${ENV_SAMPLE}" "${ENV_FILE}"
    echo
    echo "${ENV_FILE} をテンプレートから作成しました"
    echo "必要な値を設定してください"
  else
    echo
    echo "テンプレートが見つかりません: ${ENV_SAMPLE}" >&2
    exit 1
  fi
else
  echo
  echo "${ENV_FILE} は既に存在します"
fi

if [[ "${INIT_ONLY}" -eq 1 ]]; then
  echo
  echo "--init-only 指定のためチェックはスキップします"
  exit 0
fi

echo
echo "環境チェックを実行します..."
"${ROOT_DIR}/scripts/dev_env_check.sh"
