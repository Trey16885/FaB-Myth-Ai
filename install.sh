#!/usr/bin/env bash
#
# FaB-Myth-Ai installer — puts the `fabmyth` command on your PATH.
#
# Local (from a clone):   ./install.sh
# Remote (one-liner):     curl -fsSL https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main/install.sh | bash
#
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/Trey16885/FaB-Myth-Ai/main"

# Pick an install dir that's writable without root and usually on PATH.
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
  BIN_DIR="$PREFIX/bin"          # Termux
elif [ -w "/usr/local/bin" ] 2>/dev/null; then
  BIN_DIR="/usr/local/bin"
else
  BIN_DIR="$HOME/.local/bin"
fi
mkdir -p "$BIN_DIR"
DEST="$BIN_DIR/fabmyth"

echo "==> Installing fabmyth to $DEST"

# Prefer the copy sitting next to this installer (clone); else fetch it.
SRC=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
if [ -f "$SCRIPT_DIR/bin/fabmyth" ]; then
  SRC="$SCRIPT_DIR/bin/fabmyth"
fi

if [ -n "$SRC" ]; then
  install -m 0755 "$SRC" "$DEST"
else
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to fetch fabmyth. Install curl and retry." >&2
    exit 1
  fi
  curl -fsSL "$REPO_RAW/bin/fabmyth" -o "$DEST"
  chmod 0755 "$DEST"
fi

echo "✔ Installed."

# PATH hint
case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *)
    echo
    echo "! $BIN_DIR isn't on your PATH. Add this to your shell profile:"
    echo "    export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

echo
echo "Next steps:"
echo "    fabmyth setup     # install Ollama"
echo "    fabmyth start     # launch the server"
echo "    fabmyth search    # find a model"
echo "    fabmyth chat      # start chatting"
