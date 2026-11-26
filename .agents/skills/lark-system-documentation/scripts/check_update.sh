#!/usr/bin/env bash
set -euo pipefail

REPO="wqlce/casharbour-lark-system-documentation"
BRANCH="main"
SKILL_SUBPATH=".agents/skills/lark-system-documentation"
INTERVAL="${LARK_DOC_SKILL_CHECK_INTERVAL:-86400}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/lark-system-documentation"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FORCE=0
CHECK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --check-only) CHECK_ONLY=1 ;;
    -h|--help)
      echo "Usage: $0 [--force] [--check-only]"
      exit 0
      ;;
  esac
done

if [ "${LARK_DOC_SKILL_AUTO_UPDATE:-1}" = "0" ]; then
  echo "skip: auto-update disabled (LARK_DOC_SKILL_AUTO_UPDATE=0)"
  exit 0
fi

# Per-install-path cache key so multiple installed copies do not collide
if command -v shasum >/dev/null 2>&1; then
  DIR_KEY="$(printf '%s' "$SKILL_DIR" | shasum -a 256 | awk '{print substr($1,1,12)}')"
elif command -v md5 >/dev/null 2>&1; then
  DIR_KEY="$(printf '%s' "$SKILL_DIR" | md5 -q | awk '{print substr($1,1,12)}')"
else
  DIR_KEY="default"
fi

STATE_FILE="$CACHE_DIR/last_check_${DIR_KEY}.ts"
NOW_TS="$(date +%s)"

if [ "$FORCE" -ne 1 ] && [ -f "$STATE_FILE" ]; then
  LAST_TS="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"
  if [[ "$LAST_TS" =~ ^[0-9]+$ ]] && [ $((NOW_TS - LAST_TS)) -lt "$INTERVAL" ]; then
    echo "skip: recently checked"
    exit 0
  fi
fi

mkdir -p "$CACHE_DIR"

write_ts() {
  printf '%s\n' "$NOW_TS" > "$STATE_FILE"
}

run_with_timeout() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import subprocess, sys
t = int(sys.argv[1])
try:
    p = subprocess.run(sys.argv[2:], timeout=t)
    sys.exit(p.returncode)
except subprocess.TimeoutExpired:
    sys.exit(124)
' "$secs" "$@"
  else
    "$@"
  fi
}

# Mode A: running inside a git checkout of casharbour-lark-system-documentation
if command -v git >/dev/null 2>&1 && git -C "$SKILL_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE_URL="$(git -C "$SKILL_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ "$REMOTE_URL" == *"casharbour-lark-system-documentation"* ]]; then
    REMOTE_LINE="$(GIT_TERMINAL_PROMPT=0 run_with_timeout 6 git -C "$SKILL_DIR" ls-remote --heads origin "$BRANCH" 2>/dev/null | head -n 1 || true)"
    REMOTE_SHA="$(printf '%s' "$REMOTE_LINE" | awk '{print $1}')"
    if [ -z "$REMOTE_SHA" ]; then
      echo "warn: update check skipped (offline/timeout)"
      exit 0
    fi
    write_ts
    LOCAL_SHA="$(git -C "$SKILL_DIR" rev-parse HEAD 2>/dev/null || true)"
    if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
      echo "up-to-date (${LOCAL_SHA:0:7})"
      exit 0
    fi
    if [ "$CHECK_ONLY" -eq 1 ]; then
      echo "update-available: ${LOCAL_SHA:0:7} -> ${REMOTE_SHA:0:7}"
      exit 0
    fi
    if [ -n "$(git -C "$SKILL_DIR" status --porcelain 2>/dev/null)" ]; then
      echo "warn: local uncommitted changes, skip auto-update"
      exit 0
    fi
    if GIT_TERMINAL_PROMPT=0 run_with_timeout 15 git -C "$SKILL_DIR" pull --ff-only origin "$BRANCH" >/dev/null 2>&1; then
      NEW_SHA="$(git -C "$SKILL_DIR" rev-parse HEAD 2>/dev/null || echo "$REMOTE_SHA")"
      echo "updated: ${LOCAL_SHA:0:7} -> ${NEW_SHA:0:7} (please re-read SKILL.md)"
    else
      echo "warn: git pull --ff-only failed, skip auto-update"
    fi
    exit 0
  fi
fi

# Mode B: standalone copied directory (e.g. ~/.codex/skills/... or ~/.gemini/.../skills/...)
REMOTE_SHA=""
if command -v git >/dev/null 2>&1; then
  REMOTE_LINE="$(GIT_TERMINAL_PROMPT=0 run_with_timeout 6 git ls-remote "https://github.com/$REPO.git" "refs/heads/$BRANCH" 2>/dev/null | head -n 1 || true)"
  REMOTE_SHA="$(printf '%s' "$REMOTE_LINE" | awk '{print $1}')"
fi

if [ -z "$REMOTE_SHA" ] && command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  API_JSON="$(curl -fsSL --connect-timeout 3 --max-time 6 -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null || true)"
  if [ -n "$API_JSON" ]; then
    REMOTE_SHA="$(printf '%s' "$API_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("sha",""))' 2>/dev/null || true)"
  fi
fi

if [ -z "$REMOTE_SHA" ]; then
  echo "warn: update check skipped (offline/timeout)"
  exit 0
fi

write_ts

VERSION_FILE="$SKILL_DIR/.skill-version"
LOCAL_SHA=""
if [ -f "$VERSION_FILE" ]; then
  LOCAL_SHA="$(tr -d '[:space:]' < "$VERSION_FILE" 2>/dev/null || true)"
fi

if [ -n "$LOCAL_SHA" ] && [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo "up-to-date (${LOCAL_SHA:0:7})"
  exit 0
fi

OLD_SHORT="${LOCAL_SHA:0:7}"
[ -z "$OLD_SHORT" ] && OLD_SHORT="unknown"

if [ "$CHECK_ONLY" -eq 1 ]; then
  echo "update-available: ${OLD_SHORT} -> ${REMOTE_SHA:0:7}"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1 || ! command -v rsync >/dev/null 2>&1; then
  echo "warn: missing curl/tar/rsync, skip auto-update"
  exit 0
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

TARBALL="$TMP_DIR/repo.tar.gz"
if ! curl -fsSL --connect-timeout 5 --max-time 20 "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TARBALL" 2>/dev/null; then
  echo "warn: download failed, skip auto-update"
  exit 0
fi

if ! tar -xzf "$TARBALL" -C "$TMP_DIR" 2>/dev/null; then
  echo "warn: extract failed, skip auto-update"
  exit 0
fi

SRC_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1 || true)"
SRC_SKILL="$SRC_ROOT/$SKILL_SUBPATH"

if [ -z "$SRC_ROOT" ] || [ ! -f "$SRC_SKILL/SKILL.md" ] || [ ! -f "$SRC_SKILL/references/knowledge-base.md" ]; then
  echo "warn: invalid archive structure, skip auto-update"
  exit 0
fi

rsync -a --delete --exclude='.skill-version' --exclude='.DS_Store' "$SRC_SKILL/" "$SKILL_DIR/"
chmod +x "$SKILL_DIR/scripts/check_update.sh" 2>/dev/null || true
printf '%s\n' "$REMOTE_SHA" > "$VERSION_FILE"

echo "updated: ${OLD_SHORT} -> ${REMOTE_SHA:0:7} (please re-read SKILL.md)"
