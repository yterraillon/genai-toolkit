# Signatures d'outils — Harness Audit

Listes indicatives, non exhaustives : si un outil inconnu remplit le même rôle, le compter et le nommer dans le rapport.

---

## 1. Marqueurs de composants

| Type | Marqueurs |
|---|---|
| **web** | `package.json` avec `react`, `next`, `vue`, `nuxt`, `@angular/core`, `svelte`, `@sveltejs/kit`, `astro`, `remix`, `vite` ; `index.html` + bundler |
| **api** | `express`, `fastify`, `@nestjs/core`, `koa`, `hono` ; `fastapi`, `django`, `flask` ; `spring-boot` (`pom.xml`/`build.gradle`) ; `go.mod` + `net/http`/`gin`/`echo`/`fiber` ; `*.csproj` ASP.NET ; `Cargo.toml` + `axum`/`actix-web` ; `Gemfile` + `rails` ; specs `openapi.yaml`, `schema.graphql` |
| **backoffice** | web interne : dossiers `admin/`, `backoffice/`, `bo/`, `back-office/`, `dashboard/` ; `react-admin`, `refine`, Django admin, AdminJS, Retool/Appsmith exportés |
| **ios** | `*.xcodeproj`, `*.xcworkspace`, `Package.swift`, `Podfile`, `Cartfile`, `project.yml` (XcodeGen), `Tuist/` |
| **android** | `build.gradle(.kts)` avec `com.android.application`, `AndroidManifest.xml` |
| **mobile cross-platform** | `pubspec.yaml` (Flutter), `react-native` / `expo` dans `package.json` |
| **infra** | `*.tf`, `*.tfvars`, `terragrunt.hcl`, `cdk.json`, `Pulumi.yaml`, `serverless.yml`, `template.yaml` (SAM), `*.bicep`, `Chart.yaml`, `kustomization.yaml`, manifests K8s, `Dockerfile`, `docker-compose*.yml`, `ansible/`, `playbook*.yml` |
| **jobs/data** | `airflow/`, `dags/`, `dbt_project.yml`, `prefect`, `dagster`, workers (`celery`, `bullmq`, `sidekiq`), Lambdas, scripts cron |
| **lib partagée** | `packages/*`, `libs/*` sans point d'entrée applicatif ; workspaces (`pnpm-workspace.yaml`, `nx.json`, `turbo.json`, `lerna.json`, Gradle multi-module, Cargo workspace) |

---

## 2. Signatures par sensor

### Lint / formatage (C1)
| Stack | Fichiers / outils |
|---|---|
| JS/TS | `.eslintrc*`, `eslint.config.*`, `biome.json`, `.prettierrc*`, `oxlint` |
| Python | `ruff.toml`, `[tool.ruff]`, `.flake8`, `[tool.black]`, `.pylintrc`, `isort` |
| Go | `.golangci.yml`, `gofmt`, `staticcheck` |
| Java/Kotlin | `checkstyle.xml`, `spotless`, `ktlint`, `.editorconfig` |
| Swift | `.swiftlint.yml`, `.swiftformat` |
| Ruby | `.rubocop.yml` |
| C# | `.editorconfig`, `dotnet format`, StyleCop |
| Rust | `rustfmt.toml`, `clippy` |
| Infra | `tflint` (`.tflint.hcl`), `terraform fmt`, `hadolint` (`.hadolint.yaml`), `yamllint`, `helm lint`, `actionlint` |
| Docs | `markdownlint`, `vale`, `lychee` (liens morts) |

### Analyse statique / typage (C2)
| Stack | Fichiers / outils |
|---|---|
| JS/TS | `tsconfig.json` (`strict`), `tsc --noEmit`, `typescript-eslint` type-aware |
| Python | `mypy.ini`, `[tool.mypy]`, `pyright`, `pyrightconfig.json` |
| Java/Kotlin | SpotBugs, PMD, Error Prone, detekt |
| Multi | `sonar-project.properties`, `.semgrep.yml`, CodeQL (`github/codeql-action`), DeepSource, Qodana |
| Infra | `terraform validate`, checkov (`.checkov.yml`), tfsec, `trivy config`, kics, kube-linter, kubeconform |

### Tests unitaires (C3)
| Stack | Fichiers / outils |
|---|---|
| JS/TS | `jest.config.*`, `vitest.config.*`, `*.test.ts`, `*.spec.ts`, `__tests__/`, `mocha`, `node:test` |
| Python | `pytest.ini`, `[tool.pytest]`, `conftest.py`, `tests/`, `unittest` |
| Go | `*_test.go` |
| Java/Kotlin | `src/test/`, JUnit, Kotest, Mockito |
| Swift | `*Tests/`, XCTest, Swift Testing (`@Test`) |
| Ruby | `spec/`, RSpec, Minitest |
| C# | `*.Tests.csproj`, xUnit, NUnit |
| Rust | `#[cfg(test)]`, `tests/` |
| Infra | `terraform test` (`*.tftest.hcl`), terratest (`*_test.go` dans `test/`), CDK assertions, Pulumi unit tests |
| Couverture | `coverageThreshold`, `--cov-fail-under`, `[tool.coverage.report] fail_under`, JaCoCo rules, `codecov.yml`, `.nycrc` |

### Smoke tests (C4)
Scripts `smoke*`, `healthcheck*`, tags `@smoke` / `-m smoke`, jobs CI `post-deploy`, `curl -f .../health`, Playwright projet `smoke`, `k6` scénario court, Datadog/Checkly synthetics en code.

### Tests fonctionnels / E2E (C5)
Playwright (`playwright.config.*`), Cypress (`cypress.config.*`, `cypress/`), WebdriverIO, Selenium, TestCafe, Cucumber/Gherkin (`*.feature`), XCUITest (`*UITests/`), Espresso (`androidTest/`), Maestro (`.maestro/`), Detox, Appium, Postman/Newman (`*.postman_collection.json`), Bruno (`bruno/`), Karate, REST Assured, Hurl (`*.hurl`).

### Contract testing (C6)
Pact (`pacts/`, `@pact-foundation/pact`, `pact-python`, `au.com.dius.pact`), Spring Cloud Contract, specs `openapi.*`/`swagger.*`/`asyncapi.*`/`*.graphql`, Spectral (`.spectral.yaml`), oasdiff, openapi-diff, graphql-inspector, Schemathesis, Dredd, Buf (`buf.yaml` + `buf breaking` pour protobuf).

### Tests d'intégration (C7)
Testcontainers, `docker-compose.test.yml`, LocalStack, WireMock, MockServer, Microcks, dossiers `integration/`, `it/`, `src/integrationTest/`, marqueurs `@pytest.mark.integration`, `@Tag("integration")`.

### Infra spécifique (C8)
`terraform plan` en CI (Atlantis `atlantis.yaml`, `hashicorp/setup-terraform`, Spacelift, env0), `cdk diff`, `pulumi preview`, conftest (`policy/*.rego`), Sentinel, infracost, trivy image, grype, Docker Scout.

---

## 3. Fitness functions (D)
| Rôle | Outils |
|---|---|
| Architecture / dépendances | ArchUnit, jMolecules, Konsist, NetArchTest, ArchUnitNET, dependency-cruiser (`.dependency-cruiser.js`), eslint-plugin-boundaries, eslint-plugin-import `no-restricted-paths`, Nx `enforce-module-boundaries`, import-linter (`.importlinter`), pytestarch, deptrac, go-arch-lint |
| Performance | Lighthouse CI (`lighthouserc.*`), size-limit (`.size-limit.*`), bundlesize, k6 (`thresholds`), Gatling, Artillery, `pytest-benchmark`, `go test -bench` + benchstat |
| Qualité | Sonar quality gate, Codecov status checks, radon/xenon, eslint `complexity`/`max-lines` |
| Mutation | Stryker (`stryker.conf.*`), PIT (`pitest`), mutmut, cosmic-ray, cargo-mutants, Muter (Swift) |
| Accessibilité | axe-core, `@axe-core/playwright`, pa11y (`.pa11yci`), jest-axe |
| Dépendances | `renovate.json`, `.github/dependabot.yml`, license-checker, FOSSA, `cargo deny` |

---

## 4. Câblage (E)
| Rôle | Fichiers |
|---|---|
| Hooks locaux | `.pre-commit-config.yaml`, `.husky/`, `lefthook.yml`, `lint-staged` dans `package.json`, `.githooks/` |
| CI | `.github/workflows/*.yml`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`, `.circleci/config.yml`, `.buildkite/`, `bitrise.yml`, `codemagic.yaml`, Xcode Cloud (`ci_scripts/`) |
| Non bloquant | `continue-on-error: true`, `allow_failure: true`, `|| true` dans une étape |
| Hooks Claude Code | `.claude/settings.json` → `hooks.PostToolUse`, `hooks.Stop`, `hooks.PreToolUse` |
| Point d'entrée | `Makefile`, `justfile`, `Taskfile.yml`, scripts `package.json` (`check`, `validate`, `verify`, `ci`), `tox.ini`, `noxfile.py` |
