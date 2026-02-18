#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.1.0}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
SKILL_FILE="$DIST_DIR/tailwind-frontend-copilot.skill"
SHA_FILE="$DIST_DIR/tailwind-frontend-copilot.skill.sha256"
ARCHIVE_FILE="$DIST_DIR/tailwind-frontend-copilot-v${VERSION}.tar.gz"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "ERROR: missing skill artifact: $SKILL_FILE" >&2
  exit 1
fi

cd "$ROOT_DIR"
shasum -a 256 "$SKILL_FILE" > "$SHA_FILE"

tar -czf "$ARCHIVE_FILE" \
  -C "$ROOT_DIR" \
  dist/tailwind-frontend-copilot.skill \
  dist/tailwind-frontend-copilot.skill.sha256 \
  README.md \
  CHANGELOG.md \
  LICENSE

echo "Generated:"
echo "- $SHA_FILE"
echo "- $ARCHIVE_FILE"
