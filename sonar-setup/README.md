# Full CI/CD Pipeline — SonarQube, Trivy, Docker, Kubernetes, Monitoring

A complete GitHub Actions pipeline for the **skmz** app — a **Go** GraphQL API
(`server/`, gqlgen + MongoDB) served alongside a **React** front end
(`webapp/`), packaged as a single Docker image — covering all 14 stages from
checkout to production monitoring.

## Pipeline stages (`.github/workflows/ci-cd-pipeline.yml`)

1. **Source Checkout** — triggers on push, PR, and manual `workflow_dispatch`
2. **Build** — compile the Go server (`go build ./...`) and build the React app (`npm run build`)
3. **Code Quality** — SonarQube Cloud scan + quality gate check (Go + JS coverage)
4. **Unit Testing** — `go test ./...` + `react-scripts test`, with coverage reports
5. **Security Scanning** — Trivy filesystem/dependency scan
6. **Package** — build Docker image, Trivy image scan
7. **Push Artifact** — publish image to Docker Hub
8. **Deploy to Dev** — Kubernetes Dev namespace + smoke test
9. **Integration Testing** — Postman/Newman (web app `/`, `/playground`, GraphQL `/query`)
10. **Approval Gate** — *skipped, per requirements*
11. **Deploy to Staging/UAT** — Kubernetes Staging namespace + validation
12. **Production Deployment** — Rolling update or Blue-Green (toggle via `vars.PROD_DEPLOY_STRATEGY`)
13. **Post-Deployment Validation** — production health check
14. **Monitoring & Alerting** — pushes a deploy marker annotation to Grafana

## Contents

| Path | Purpose |
|---|---|
| `.github/workflows/ci-cd-pipeline.yml` | The full 14-stage pipeline |
| `SONARQUBE_SETUP_GUIDE.md` | Manual SonarCloud account/org/token/quality-gate setup |
| `docs/PIPELINE_SECRETS_REFERENCE.md` | Every secret/variable the pipeline needs, and why |
| `docs/VALIDATION_REPORT_TEMPLATE.md` | Fill-in report for Sonar quality gate validation |
| `sonar-project.properties` | SonarQube scanner config (pre-set to `sriom1_skmz` / `sriom1`) |
| `tests/quality_samples/` | Good and poor-quality sample files illustrating what the quality gate catches |
| `deploy/k8s/dev-deployment.yaml` | Dev namespace manifest |
| `deploy/k8s/staging-deployment.yaml` | Staging namespace manifest |
| `deploy/k8s/prod-deployment-rolling.yaml` | Prod manifest — rolling update strategy |
| `deploy/k8s/prod-deployment-bluegreen-bootstrap.yaml` | Prod manifest — blue/green bootstrap (apply once manually) |
| `scripts/smoke-test.sh` | Polls `/` (the app has no `/health`) until HTTP 200; used in stages 8/11/13 |
| `scripts/blue-green-deploy.sh` | Flips traffic between blue/green deployments in stage 12 |
| `scripts/grafana-annotate.sh` | Posts a deployment marker to Grafana in stage 14 |
| `postman/health-check-collection.json` | Newman collection for stage 9 |
| `postman/dev-environment.json` | Newman environment (base URL) for stage 9 |

## Quick start

1. Read `SONARQUBE_SETUP_GUIDE.md` and set up SonarCloud (account, org, project, token, quality gate at 80% coverage). The project key/org (`sriom1_skmz` / `sriom1`) are already set in `sonar-project.properties`.
2. Read `docs/PIPELINE_SECRETS_REFERENCE.md` and add every secret/variable listed to your repo.
3. Health checks target `/` (the skmz server exposes `/`, `/playground`, and `/query` — there is no dedicated `/health`). If you add a real health endpoint later, update `scripts/smoke-test.sh`, `postman/health-check-collection.json`, and the k8s probe paths in `deploy/k8s/`.
4. Pick a production strategy: set the `PROD_DEPLOY_STRATEGY` repo variable to `rolling` or `blue-green`. If `blue-green`, apply the bootstrap manifest once manually (see the secrets reference doc).
5. Push. Watch the Actions tab — each stage runs as a separate job with clear names (`1.` through `14.`, `10.` skipped as noted).

## Pushing this to a new GitHub repo

```bash
cd sonar-setup
git init
git add .
git commit -m "Add full CI/CD pipeline: Sonar, Trivy, Docker, K8s, monitoring"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo-name>.git
git push -u origin main
```

Or merge these files/folders into your existing repository instead of creating a new one — nothing here assumes a fresh repo except the workflow triggers on `main`/`master`/`develop`.
