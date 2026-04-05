#!/usr/bin/env zsh
set -euo pipefail

echo "[INFO] Changing directory to script location: $(dirname "$0")"
cd "$(dirname "$0")"

# ── Guard: exit early if server is already running ────────────────────────────
PORT=${COPILOT_API_PORT:-4141}
if lsof -iTCP:"$PORT" -sTCP:LISTEN -t &>/dev/null; then
    echo "[INFO] copilot-api is already listening on port $PORT — nothing to do."
    exit 0
fi

# ── Sync upstream/master into current branch ─────────────────────────────────
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "[INFO] Current branch: $CURRENT_BRANCH"

echo "[INFO] Fetching upstream..."
git fetch upstream

echo "[INFO] Merging upstream/master into $CURRENT_BRANCH..."
git merge upstream/master --no-edit

echo "[INFO] Pushing updated branch to origin..."
git push origin "$CURRENT_BRANCH" || echo "[WARN] Push failed (non-fatal, continuing)"

# ── Install / update dependencies ─────────────────────────────────────────────
if [[ ! -d "node_modules" ]]; then
    echo "[INFO] node_modules not found, running bun install..."
    bun install
fi

# ── Start server ──────────────────────────────────────────────────────────────
echo "[INFO] Running: bun run dev start --port $PORT"
bun run dev start --port "$PORT"
