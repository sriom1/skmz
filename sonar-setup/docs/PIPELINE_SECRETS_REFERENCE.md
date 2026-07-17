# Required GitHub Secrets & Variables — Full CI/CD Pipeline

Add these under **Settings → Secrets and variables → Actions** in your repo.
Secrets tab for anything sensitive; Variables tab for non-sensitive config.

## Secrets

| Name | Used in stage | Purpose |
|---|---|---|
| `SONAR_TOKEN` | 3 | SonarCloud project analysis token (see SONARQUBE_SETUP_GUIDE.md) |
| `DOCKERHUB_USERNAME` | 6, 7 | Docker Hub login |
| `DOCKERHUB_TOKEN` | 6, 7 | Docker Hub access token (create at hub.docker.com → Account Settings → Security) |
| `KUBE_CONFIG_DEV` | 8 | Base64-encoded kubeconfig scoped to the Dev namespace |
| `KUBE_CONFIG_STAGING` | 11 | Base64-encoded kubeconfig scoped to the Staging namespace |
| `KUBE_CONFIG_PROD` | 12 | Base64-encoded kubeconfig scoped to the Prod namespace |
| `DEV_APP_URL` | 8 | Base URL used for the Dev smoke test, e.g. `https://dev.app.company.com` |
| `STAGING_APP_URL` | 11 | Base URL for Staging smoke test |
| `PROD_APP_URL` | 13 | Base URL for Prod post-deploy health check |
| `GRAFANA_URL` | 14 | Your Grafana instance base URL |
| `GRAFANA_API_KEY` | 14 | Grafana API key with Editor role (for posting annotations) |

To base64-encode a kubeconfig for the secrets above:
```bash
cat ~/.kube/config-dev | base64 -w 0
```

## Variables (non-sensitive)

| Name | Used in stage | Purpose |
|---|---|---|
| `PROD_DEPLOY_STRATEGY` | 12 | Set to `rolling` or `blue-green` to pick the production deployment path |

## GitHub Environments

Create three Environments under **Settings → Environments**: `development`,
`staging`, `production`. These let you (optionally, later) attach protection
rules — required reviewers, wait timers, deployment branch restrictions — even
though the current workflow has no approval gate baked in, per your request to
skip it. Each Environment can also hold environment-scoped secrets if you want
different credentials per environment instead of the flat list above.

## One-time manual step for Blue-Green

If `PROD_DEPLOY_STRATEGY=blue-green`, apply the bootstrap manifest once by hand
before the first pipeline run, so both colors exist:
```bash
export IMAGE_NAME=<your-dockerhub-username>/<repo-name>
envsubst < deploy/k8s/prod-deployment-bluegreen-bootstrap.yaml | kubectl apply -n prod -f -
```
After that, `scripts/blue-green-deploy.sh` handles every subsequent deploy by
updating the idle color and flipping the `app-prod` Service selector.
