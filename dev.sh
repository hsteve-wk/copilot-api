#!/usr/bin/env zsh
set -euo pipefail

echo "[INFO] Changing directory to script location: $(dirname "$0")"
cd "$(dirname "$0")"

# Install dependencies if not already installed
if [[ ! -d "node_modules" ]]; then
    echo "[INFO] node_modules not found, running bun install..."
    bun install
fi

echo "[INFO] Running: bun run dev start"
bun run dev start
