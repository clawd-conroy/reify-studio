#!/bin/bash
# Start server with setup waiting and helpful output
set -e

# Detect project root (works both in devcontainer and locally)
ROOT="${WORKSPACE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo /workspace)}"
cd "$ROOT"

# Check if running in a container (devcontainer or codespace)
in_container() {
  [ "$CODESPACES" = "true" ] || [ "$REMOTE_CONTAINERS" = "true" ] || [ -f /.dockerenv ]
}

SETUP_LOG="/tmp/reify-setup.log"

# Cleanup background processes on exit
cleanup() {
  [ -n "$TAIL_PID" ] && kill "$TAIL_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Wait for initial setup if needed (only in container environments)
if [ ! -f "$ROOT/deps/.setup-complete" ] && in_container; then
  echo '⏳ Waiting for initial setup to complete...'
  echo '   Streaming setup logs below:'
  echo ''
  echo '────────────────────────────────────────────────────────────'

  # Start tailing the log file (wait for it to exist first)
  while [ ! -f "$SETUP_LOG" ]; do sleep 0.5; done
  tail -f "$SETUP_LOG" &
  TAIL_PID=$!

  # Wait for setup to complete
  while [ ! -f "$ROOT/deps/.setup-complete" ]; do
    sleep 1
  done

  # Stop tailing
  kill "$TAIL_PID" 2>/dev/null || true
  unset TAIL_PID

  echo '────────────────────────────────────────────────────────────'
  echo ''
  echo '✓ Setup complete!'
  echo ''
fi

# Build assets
mix dev.build

# Show welcome banner
echo ''
echo '🚀 STARTING SERVER'
echo ''
echo '   App URL: http://localhost:4000'
echo ''
echo '   Tips:'
echo '   • Changes to .ex files auto-reload'
echo '   • Changes to .tsx files hot-reload via Vite'
echo '   • Run tests: Ctrl+Shift+P → "Tasks: Run Task" → "tests"'
echo ''

# Start Phoenix
exec mix phx.server
