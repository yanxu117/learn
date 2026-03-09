#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: bash scripts/learn_to_repo.sh \"<url-or-file>\""
  exit 1
fi

INPUT="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/reports"
LEARN_SCRIPT="/root/.ductor/workspace/skills/learn/scripts/learn_from_link_ptc.py"

if [[ ! -f "$LEARN_SCRIPT" ]]; then
  echo "ERROR: learn script not found: $LEARN_SCRIPT"
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Running learn skill..."
OUTPUT="$(
  python3 "$LEARN_SCRIPT" \
    --url "$INPUT" \
    --save-file \
    --output-dir "$OUT_DIR" \
    --flow-name "learn"
)"
echo "$OUTPUT"

REPORT_PATH="$(echo "$OUTPUT" | awk -F': ' '/^REPORT_PATH:/{print $2; exit}')"
if [[ -z "$REPORT_PATH" || ! -f "$REPORT_PATH" ]]; then
  echo "ERROR: no REPORT_PATH detected from learn output"
  exit 1
fi

cd "$REPO_ROOT"

if ! git config user.email >/dev/null 2>&1; then
  git config user.email "bot@local"
fi
if ! git config user.name >/dev/null 2>&1; then
  git config user.name "learn-bot"
fi

git add "$REPORT_PATH"
if git diff --cached --quiet; then
  echo "No content changes to commit."
  exit 0
fi

UTC_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
git commit -m "learn: ${UTC_TS} ${INPUT:0:90}"
git push origin HEAD

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
REL_PATH="${REPORT_PATH#$REPO_ROOT/}"
REMOTE_URL="$(git remote get-url origin)"
REMOTE_CLEAN="${REMOTE_URL%.git}"
if [[ "$REMOTE_CLEAN" == git@github.com:* ]]; then
  REMOTE_CLEAN="https://github.com/${REMOTE_CLEAN#git@github.com:}"
fi

echo "DONE"
echo "REPORT_FILE: $REPORT_PATH"
echo "REPORT_URL: ${REMOTE_CLEAN}/blob/${BRANCH}/${REL_PATH}"
