#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/claude-desktop-sandbox-for-macos"

mkdir -p "$BIN_DIR" "$SHARE_DIR"
cp profile.sb "$SHARE_DIR/profile.sb"

sed "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$SHARE_DIR\"|" claude-desktop-sandboxed > "$BIN_DIR/claude-desktop-sandboxed"
chmod +x "$BIN_DIR/claude-desktop-sandboxed"

echo "Installed to $BIN_DIR/claude-desktop-sandboxed"
echo "Profile at $SHARE_DIR/profile.sb"
echo ""
echo "Make sure $BIN_DIR is in your PATH, then run:"
echo "  claude-desktop-sandboxed"
