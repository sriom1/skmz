#!/usr/bin/env bash
# Push a deployment annotation to Grafana so deploys show up as vertical
# markers on your Prometheus-backed dashboards.
#
# Usage: ./grafana-annotate.sh <grafana-url> <api-key> "<annotation text>"

set -euo pipefail

GRAFANA_URL="${1:?Usage: grafana-annotate.sh <grafana-url> <api-key> <text>}"
API_KEY="${2:?Missing Grafana API key}"
TEXT="${3:?Missing annotation text}"
NOW_MS=$(($(date +%s) * 1000))

curl -sf -X POST "${GRAFANA_URL%/}/api/annotations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
        \"time\": ${NOW_MS},
        \"tags\": [\"deployment\", \"ci-cd\"],
        \"text\": \"${TEXT}\"
      }"

echo ""
echo "Grafana annotation posted: ${TEXT}"

# Note: Prometheus itself has no "annotation" concept — annotations are a
# Grafana feature layered on top of whatever data source (Prometheus, etc.)
# backs your dashboard. If you're using Prometheus alerting rules, those
# should already be defined separately in your prometheus.yml / Alertmanager
# config; this script only marks the deploy event on the dashboard timeline.
