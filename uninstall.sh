#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
echo "Removing claude-desktop-sandbox-for-macos..."
rm -f "$PREFIX/bin/cd-seatbelt"
rm -rf "$PREFIX/share/claude-desktop-sandbox-for-macos"
echo "Done."
echo ""
echo "Note: ~/Claude-Sandbox was not removed — it's your project folder. To delete it, navigate to ~/Claude-Sandbox and remove it manually after verifying you're no longer actively working in there."
