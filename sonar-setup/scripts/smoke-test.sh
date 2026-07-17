#!/usr/bin/env bash
# Simple smoke test for the skmz app.
# Usage: ./smoke-test.sh <base-url> [health-path]
# The skmz server has no dedicated /health endpoint; it serves the React app
# at "/" (HTTP 200), so "/" is used as the liveness signal by default.
# Pass a second argument to override (e.g. "/playground").

set -euo pipefail

BASE_URL="${1:?Usage: smoke-test.sh <base-url> [health-path]}"
HEALTH_PATH="${2:-/}"
HEALTH_URL="${BASE_URL%/}${HEALTH_PATH}"
MAX_ATTEMPTS=10
SLEEP_SECONDS=6

echo "Running smoke test against: ${HEALTH_URL}"

for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
  http_status=$(curl -s -o /dev/null -w "%{http_code}" "${HEALTH_URL}" || echo "000")

  if [[ "${http_status}" == "200" ]]; then
    echo "Health check passed (attempt ${attempt}/${MAX_ATTEMPTS}), HTTP ${http_status}"
    exit 0
  fi

  echo "Attempt ${attempt}/${MAX_ATTEMPTS}: HTTP ${http_status}, retrying in ${SLEEP_SECONDS}s..."
  sleep "${SLEEP_SECONDS}"
done

echo "Health check FAILED after ${MAX_ATTEMPTS} attempts against ${HEALTH_URL}"
exit 1
