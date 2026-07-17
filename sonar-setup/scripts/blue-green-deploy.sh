#!/usr/bin/env bash
# Blue-Green deployment to Kubernetes production namespace.
#
# Strategy:
#   - Two deployments exist at all times: app-prod-blue and app-prod-green.
#   - The `app-prod` Service's selector points to whichever is "live".
#   - This script deploys the new image to the IDLE color, waits for it to
#     become healthy, then flips the Service selector to point at it.
#   - The previously-live color is left running (not scaled down) so you can
#     instantly roll back by flipping the selector back.
#
# Requires: kubectl configured against the prod cluster, IMAGE_TAG env var set.

set -euo pipefail

NAMESPACE="prod"
SERVICE_NAME="app-prod"
IMAGE_NAME="${IMAGE_NAME:?IMAGE_NAME env var must be set}"
IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG env var must be set}"

current_color=$(kubectl get service "${SERVICE_NAME}" -n "${NAMESPACE}" \
  -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")

if [[ "${current_color}" == "blue" ]]; then
  idle_color="green"
else
  idle_color="blue"
fi

echo "Current live color: ${current_color} | Deploying to idle color: ${idle_color}"

kubectl set image "deployment/app-prod-${idle_color}" \
  app="${IMAGE_NAME}:${IMAGE_TAG}" \
  -n "${NAMESPACE}"

echo "Waiting for ${idle_color} deployment rollout..."
kubectl rollout status "deployment/app-prod-${idle_color}" -n "${NAMESPACE}" --timeout=300s

echo "Running health check against ${idle_color} pods before flipping traffic..."
kubectl run "healthcheck-${idle_color}-$(date +%s)" \
  --rm -i --restart=Never \
  --image=curlimages/curl:latest \
  -n "${NAMESPACE}" \
  -- curl -sf "http://app-prod-${idle_color}.${NAMESPACE}.svc.cluster.local/"

echo "Health check passed. Flipping ${SERVICE_NAME} selector to ${idle_color}..."
kubectl patch service "${SERVICE_NAME}" -n "${NAMESPACE}" \
  -p "{\"spec\":{\"selector\":{\"color\":\"${idle_color}\"}}}"

echo "Blue-Green switch complete. Live color is now: ${idle_color}"
echo "Previous color (${current_color}) is still running for instant rollback if needed."
