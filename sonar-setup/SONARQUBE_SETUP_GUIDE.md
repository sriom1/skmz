# SonarQube Cloud + GitHub Actions Integration Guide

Stack detected: **Go (primary)** — `server/` GraphQL API on MongoDB — plus **JavaScript/React** (`webapp/`), Shell, and Dockerfile.
This guide covers every manual step (account creation, tokens, secrets — things only you
should do) plus points to the ready-made config files in this bundle.

---

## Part 1 — Create the SonarQube Cloud Account & Organization

1. Go to **https://sonarcloud.io** and click **Log in** → **With GitHub**.
   - This authorizes SonarCloud via GitHub OAuth — you'll approve the permission screen
     yourself in the browser.
2. Once logged in, click the **+** icon (top right) → **Create new organization**.
3. Choose **Import an organization from GitHub** (if this is tied to a GitHub org) or
   **Create a personal organization** (if it's under your personal account).
4. Pick the **Free plan** (fine for public repos; private repos need a paid plan after
   the trial) and confirm.
5. Click **+** → **Analyze new project**, select the GitHub repository from the list.
   - If it's not listed, click **Choose another repository** and grant SonarCloud access
     to it via the GitHub App installation screen (GitHub → Settings → Applications →
     SonarCloud → Configure → add repository).

## Part 2 — Configure Project Permissions

1. In the new project, go to **Project Settings → Permissions**.
2. Under **Execute Analysis**, make sure your CI service account / token owner has this
   permission (it does by default for the org owner).
3. Under **Administer**, add any teammates who should manage the quality gate.
4. Go to **Project Settings → General Settings → Languages/Analysis Scope** — no changes
   needed yet; the scanner auto-detects languages from `sonar-project.properties`.

## Part 3 — Generate the Token

1. In SonarCloud, click your avatar → **My Account → Security**.
2. Under **Generate Tokens**, name it e.g. `github-actions-<repo-name>`, type = **Project
   Analysis Token**, select the project, expiration = your choice (90 days recommended,
   with a calendar reminder to rotate it).
3. Click **Generate** and **copy the token immediately** — it's shown only once.

## Part 4 — Add the Token to GitHub Secrets

1. In your GitHub repo: **Settings → Secrets and variables → Actions → New repository
   secret**.
2. Name: `SONAR_TOKEN`
3. Value: paste the token from Part 3.
4. Also add `SONAR_ORGANIZATION` (your SonarCloud org key, found on the org's Overview
   page URL, e.g. `sonarcloud.io/organizations/<this-part>`) and `SONAR_PROJECT_KEY`
   (found on the project's Overview page) as either secrets or plain repo **Variables**
   (Settings → Secrets and variables → Actions → Variables tab) since they aren't
   sensitive.

⚠️ Never paste the token into code, commit messages, or hand it to anyone else —
including me. I can't enter this for you; only you should touch this screen.

## Part 5 — Drop in the Workflow & Config Files

Copy these from this bundle into your repo:

- `.github/workflows/ci-cd-pipeline.yml` → the full pipeline; stage 3 runs the SonarQube
  scan + quality-gate check on every push and PR
- `sonar-project.properties` → project + coverage config (already filled in for this repo:
  `sonar.projectKey=sriom1_skmz`, `sonar.organization=sriom1`)
- `tests/quality_samples/` → optional good/bad sample files for validation testing

`sonar-project.properties` is already set for this repo:
```properties
sonar.projectKey=sriom1_skmz
sonar.organization=sriom1
```
(Change these only if you fork the project into a different SonarCloud org.)

Commit and push these files.

## Part 6 — Configure the Quality Gate (80% threshold)

1. In SonarCloud: **Project → Quality Gates** (or Org-level **Quality Gates** to reuse
   across projects).
2. Click **Create** (or duplicate the built-in "Sonar way" gate) → name it e.g.
   `Project-80-Gate`.
3. Add/edit conditions on **New Code** (recommended, so legacy code doesn't block you)
   or **Overall Code** if you want the strict whole-repo view:

   | Metric | Operator | Value |
   |---|---|---|
   | Coverage | is less than | 80% |
   | Duplicated Lines (%) | is greater than | 3% |
   | Maintainability Rating | is worse than | A |
   | Reliability Rating | is worse than | A |
   | Security Rating | is worse than | A |
   | Security Hotspots Reviewed | is less than | 100% |

4. Go to **Project Settings → Quality Gate** and select this gate for the project.
5. Save.

## Part 7 — Validation Testing (you run this)

1. Create a branch, add a well-tested "good" module (see
   `tests/quality_samples/good_example.py`) with matching unit tests.
2. On another branch/PR, add the intentionally poor file
   (`tests/quality_samples/poor_example.py`) — it has an unused import, a bare
   `except:`, high cyclomatic complexity, a hardcoded secret-looking string (to trigger
   a Security Hotspot), and no test coverage.
3. Push both. Confirm in the **GitHub Actions** tab that the `SonarQube Analysis`
   workflow runs on each push/PR and finishes green (workflow success ≠ quality gate
   pass — they're reported separately).
4. Check the **Checks** tab on the PR — SonarCloud posts a Quality Gate status check
   automatically once the GitHub App is installed.

## Part 8 — Review Results

In the SonarCloud project dashboard, check:
- **Overview** tab → Quality Gate status (Passed/Failed), Bugs, Vulnerabilities, Code
  Smells, Security Hotspots, Coverage %, Duplications.
- **Issues** tab → filter by type (Bug/Vulnerability/Code Smell) and severity.
- **Security Hotspots** tab → review and mark each as "Reviewed: Safe" or "Fixed".
- **Measures → Coverage** → confirm the coverage report was actually ingested (it'll
  show 0% if the `sonar.go.coverage.reportPaths` (server/coverage.out) or
  `sonar.javascript.lcov.reportPaths` (webapp/coverage/lcov.info) path in
  `sonar-project.properties` is wrong — a common first-run issue).

Expect: the "good" commit should pass the gate; the "poor" commit should fail it on
Coverage and/or Maintainability/Reliability Rating — that's the point of the test.

## Part 9 — Documentation (screenshots checklist)

Capture these four, ideally right after Part 7–8:
1. **GitHub Actions run** — Actions tab, the workflow run page showing green check and
   the expanded "Run SonarCloud Scan" step log.
2. **SonarCloud dashboard** — Project Overview tab showing the Quality Gate badge, Bugs/
   Vulnerabilities/Code Smells/Hotspots counts.
3. **Quality Gate results** — the Quality Gate tab/panel showing each condition
   (Coverage, Duplications, Ratings) with pass/fail per condition.
4. **Code coverage report** — Measures → Coverage view, showing the percentage and the
   file-by-file breakdown.

Save them under e.g. `docs/sonarqube-validation/` in the repo with descriptive names:
`01-github-actions-run.png`, `02-sonarcloud-dashboard.png`, `03-quality-gate.png`,
`04-coverage-report.png`.
