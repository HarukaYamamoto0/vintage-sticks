#!/usr/bin/env bash
set -euo pipefail

# Project root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MOD_CODE="vintagesticks"

# Folder where the "dev" mod will be located
DEV_MODS_ROOT="$ROOT_DIR/.dev-mods"
DEV_MOD_DIR="$DEV_MODS_ROOT/$MOD_CODE"

# Vintage Story path via environment variable
if [[ -z "${VINTAGE_STORY:-}" ]]; then
  echo "[run] ERRO: variável VINTAGE_STORY não definida."
  echo "      Exemplo:"
  echo "        export VINTAGE_STORY=\"\$HOME/Games/VintageStory\""
  exit 1
fi

# ================== SYNC MOD =====================

echo "[run] Preparing mod in: $DEV_MOD_DIR"

rm -rf "$DEV_MOD_DIR"
mkdir -p "$DEV_MOD_DIR"

# Main Files
cp "$ROOT_DIR/modinfo.json" "$DEV_MOD_DIR/"

if [[ -f "$ROOT_DIR/modicon.png" ]]; then
  cp "$ROOT_DIR/modicon.png" "$DEV_MOD_DIR/"
fi

if [[ -f "$ROOT_DIR/LICENSE" ]]; then
  cp "$ROOT_DIR/LICENSE" "$DEV_MOD_DIR/"
fi

if [[ -f "$ROOT_DIR/README.md" ]]; then
  cp "$ROOT_DIR/README.md" "$DEV_MOD_DIR/"
fi

# Assets
if [[ -d "$ROOT_DIR/assets" ]]; then
  cp -r "$ROOT_DIR/assets" "$DEV_MOD_DIR/"
else
  echo "[run] ERROR: assets/ folder not found in $ROOT_DIR." >&2
  exit 1
fi

# ================== CLIENT / SERVER =================

PROFILE="${1:-client}"

CLIENT_BIN="$VINTAGE_STORY/Vintagestory"
SERVER_BIN="$VINTAGE_STORY/VintagestoryServer"

case "$PROFILE" in
  client|Client)
    if [[ -x "$CLIENT_BIN" ]]; then
      TARGET_BIN="$CLIENT_BIN"
      LABEL="Client"
    else
      echo "[run] ERRO: I couldn't find the client executable."
      echo "      $CLIENT_BIN"
      exit 1
    fi
    ;;
  server|Server)
    if [[ -x "$SERVER_BIN" ]]; then
      TARGET_BIN="$SERVER_BIN"
      LABEL="Server"
    else
      echo "[run] ERRO: I couldn't find the server executable:"
      echo "      $SERVER_BIN"
      exit 1
    fi
    ;;
  *)
    echo "[run] Usage:"
    echo "  $0 client   # run the client"
    echo "  $0 server   # Run the server."
    exit 1
    ;;
esac

echo "[run] Starting Vintage Story ($LABEL)..."
echo "[run]   VINTAGE_STORY = $VINTAGE_STORY"
echo "[run]   --addModPath  = $DEV_MODS_ROOT"
echo "[run]   --addOrigin   = $DEV_MOD_DIR/assets"

cd "$VINTAGE_STORY"

"$TARGET_BIN" \
  --addModPath "$DEV_MODS_ROOT" \
  --playStyle "creativebuilding" \
  --openWorld "$MOD_CODE Test World (Flat)"
  --addOrigin "$DEV_MOD_DIR/assets" \
  --tracelog
