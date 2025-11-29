#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MOD_CODE="vintagesticks"
MOD_NAME="VintageSticks"

MODINFO="$ROOT_DIR/modinfo.json"

# Try retrieving the modinfo.json version using jq. If jq isn't available, use "dev".
if command -v jq >/dev/null 2>&1 && [[ -f "$MODINFO" ]]; then
  MOD_VERSION="$(jq -r '.version // "dev"' "$MODINFO")"
else
  MOD_VERSION="dev"
fi

BUILD_ROOT="$ROOT_DIR/build"
STAGE_DIR="$BUILD_ROOT/$MOD_CODE"

echo "[pack] Cleaning up previous directories..."
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$ROOT_DIR"

echo "[pack] Copying mod files..."

# Main files
cp "$ROOT_DIR/modinfo.json" "$STAGE_DIR/"

if [[ -f "$ROOT_DIR/modicon.png" ]]; then
  cp "$ROOT_DIR/modicon.png" "$STAGE_DIR/"
fi

if [[ -f "$ROOT_DIR/LICENSE" ]]; then
  cp "$ROOT_DIR/LICENSE" "$STAGE_DIR/"
fi

if [[ -f "$ROOT_DIR/README.md" ]]; then
  cp "$ROOT_DIR/README.md" "$STAGE_DIR/"
fi

# Assets
if [[ -d "$ROOT_DIR/assets" ]]; then
  cp -r "$ROOT_DIR/assets" "$STAGE_DIR/"
else
  echo "[pack] ERROR: assets/ folder not found." >&2
  exit 1
fi

ZIP_NAME="${MOD_CODE}_v${MOD_VERSION}.zip"
ZIP_PATH="$ROOT_DIR/$ZIP_NAME"

echo "[pack] Generating .zip in: $ZIP_PATH"

(
  cd "$BUILD_ROOT"
  rm -f "$ZIP_PATH"
  zip -r "$ZIP_PATH" "$MOD_CODE" >/dev/null
)

echo "[pack] Success! -> $ZIP_PATH"
