#!/bin/bash
set -e

# Detect project root (works both in devcontainer and locally)
ROOT="${WORKSPACE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo /workspace)}"
cd "$ROOT"

# Log to file so VS Code tasks can tail it
SETUP_LOG="/tmp/reify-setup.log"
exec > >(tee -a "$SETUP_LOG") 2>&1

echo "==> Setting up Reify development environment..."

# Ensure we own the mounted volumes
# Only chown volumes that actually exist, so missing dirs don't cause errors
VOLUMES=("$ROOT/deps" "$ROOT/_build" "$ROOT/assets/node_modules")
EXISTING_VOLUMES=()
for dir in "${VOLUMES[@]}"; do
  if [ -e "$dir" ]; then
    EXISTING_VOLUMES+=("$dir")
  fi
done

if [ "${#EXISTING_VOLUMES[@]}" -gt 0 ]; then
  if ! sudo chown -R elixir:elixir "${EXISTING_VOLUMES[@]}"; then
    echo "WARNING: Failed to adjust ownership for volumes: ${EXISTING_VOLUMES[*]}"
    echo "         You may not have sufficient permissions; continuing anyway."
  fi
else
  echo "    Note: No volumes found yet to adjust ownership (this is expected on first run)"
fi

# Install Elixir dependencies
echo "==> Installing Elixir dependencies..."
if ! mix deps.get; then
  echo "ERROR: Failed to install Elixir dependencies"
  echo "       Check your network connection and try again"
  exit 1
fi

# Install Node.js dependencies
echo "==> Installing Node.js dependencies..."
cd "$ROOT/assets"
if ! npm install; then
  echo "ERROR: Failed to install Node.js dependencies"
  echo "       Check your network connection and try again"
  exit 1
fi
cd "$ROOT"

# Setup database
echo "==> Setting up database..."
if ! mix ash.setup; then
  echo ""
  echo "WARNING: Database setup failed or incomplete"
  echo "         You may need to run manually:"
  echo "           mix ash.setup"
  echo "         Or if database exists:"
  echo "           mix ecto.migrate"
  echo ""
  # Don't exit - database might already exist or need manual intervention
fi

# Run seeds
echo "==> Running seeds..."
if ! mix run priv/repo/seeds.exs; then
  echo "WARNING: Seeds failed (this is okay if database already has data)"
fi

# Compile both environments in parallel
echo "==> Compiling project (dev + test in parallel)..."
mix compile &
DEV_PID=$!
MIX_ENV=test mix compile &
TEST_PID=$!

# Wait for both and check results
DEV_EXIT=0
TEST_EXIT=0
wait $DEV_PID || DEV_EXIT=$?
wait $TEST_PID || TEST_EXIT=$?

if [ $DEV_EXIT -ne 0 ]; then
  echo "WARNING: Dev compilation had issues (exit code: $DEV_EXIT)"
fi
if [ $TEST_EXIT -ne 0 ]; then
  echo "WARNING: Test compilation had issues (exit code: $TEST_EXIT)"
fi

# Mark setup as complete (used by VS Code tasks to know when ready)
touch "$ROOT/deps/.setup-complete"

echo ""
echo "============================================"
echo "  Reify development environment ready!"
echo "============================================"
echo ""
