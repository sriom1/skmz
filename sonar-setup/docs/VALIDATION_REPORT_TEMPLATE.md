# SonarQube Integration — Validation Report

**Repository:** <CHANGE_ME>
**SonarCloud Project:** <CHANGE_ME — link to project dashboard>
**Date:** <CHANGE_ME>
**Prepared by:** <CHANGE_ME>

---

## 1. GitHub Actions Workflow Execution

- Workflow file: `.github/workflows/sonarqube.yml`
- Trigger events confirmed: `push` ✅ / ❌  |  `pull_request` ✅ / ❌
- Run link: <CHANGE_ME — paste Actions run URL>
- Result: Success ✅ / Failed ❌

**Screenshot:** `docs/sonarqube-validation/01-github-actions-run.png`

---

## 2. SonarQube Dashboard Overview

| Metric | Value |
|---|---|
| Quality Gate | Passed ✅ / Failed ❌ |
| Bugs | <CHANGE_ME> |
| Vulnerabilities | <CHANGE_ME> |
| Code Smells | <CHANGE_ME> |
| Security Hotspots (reviewed / total) | <CHANGE_ME> |
| Duplications (%) | <CHANGE_ME> |

**Screenshot:** `docs/sonarqube-validation/02-sonarcloud-dashboard.png`

---

## 3. Quality Gate Results (Threshold: 80% Coverage)

| Condition | Threshold | Actual | Status |
|---|---|---|---|
| Coverage | ≥ 80% | <CHANGE_ME> | Pass / Fail |
| Duplicated Lines (%) | ≤ 3% | <CHANGE_ME> | Pass / Fail |
| Maintainability Rating | A | <CHANGE_ME> | Pass / Fail |
| Reliability Rating | A | <CHANGE_ME> | Pass / Fail |
| Security Rating | A | <CHANGE_ME> | Pass / Fail |
| Security Hotspots Reviewed | 100% | <CHANGE_ME> | Pass / Fail |

**Screenshot:** `docs/sonarqube-validation/03-quality-gate.png`

---

## 4. Code Coverage Report

- Coverage source: `server/coverage.out` (Go), `webapp/coverage/lcov.info` (JS/React)
- Overall coverage: <CHANGE_ME>%
- Notable low-coverage files: <CHANGE_ME>

**Screenshot:** `docs/sonarqube-validation/04-coverage-report.png`

---

## 5. Test Commit Summary

| Commit / PR | Purpose | Expected Gate Result | Actual Result |
|---|---|---|---|
| `good_example.py` + tests | Clean, fully-tested code | Pass | <CHANGE_ME> |
| `poor_example.py` (no tests) | Deliberately poor quality | Fail | <CHANGE_ME> |

---

## 6. Notes / Follow-ups

- <CHANGE_ME: any issues found, false positives dismissed, hotspots marked safe, etc.>
