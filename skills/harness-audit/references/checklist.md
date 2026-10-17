# Checklist — Harness Audit

Chaque contrôle a un identifiant à reprendre dans le rapport. Pour chacun : **Quoi** vérifier, **Comment** l'analyser statiquement, **Critères** de statut.

---

## A. Feedforward — documentation

### A1 — Fichier d'instructions agent
**Quoi** : `CLAUDE.md` à la racine (équivalents acceptés en complément : `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/`, `.windsurfrules`).
**Comment** : lire le fichier et vérifier qu'il contient :
- les commandes pour installer, builder, lancer, linter, tester ;
- les conventions de code et d'architecture (ou un lien vers elles) ;
- des pointeurs vers `docs/` ;
- les interdits / zones sensibles (fichiers générés, migrations, secrets).
Vérifier que les chemins et commandes cités existent réellement (scripts dans `package.json`, cibles Makefile, dossiers).
**Critères** : `PRÉSENT` si tout est couvert et cohérent ; `PARTIEL` si incomplet, générique (copie de `/init` jamais retouchée), > ~500 lignes, ou s'il cite des chemins/commandes inexistants ; `ABSENT` sinon.

### A2 — `docs/architecture.md`
**Quoi** : vue d'ensemble des composants, responsabilités, flux de données, dépendances externes.
**Comment** : vérifier que les composants détectés en phase 1 y sont nommés.
**Critères** : `PARTIEL` si des composants détectés n'y figurent pas ou si le fichier est un template.

### A3 — `docs/architecture-decision-record.md`
**Quoi** : décisions d'architecture (contexte, décision, conséquences, statut). Accepter aussi un dossier `docs/adr/` ou `docs/decisions/`.
**Comment** : compter les décisions, vérifier le format (contexte / décision / conséquences) et la date de la plus récente.
**Critères** : `PARTIEL` si 0–1 décision ou aucune décision depuis > 12 mois alors que le code évolue.

### A4 — `docs/architecture-diagram.md`
**Quoi** : diagramme(s) versionné(s) en texte (Mermaid, PlantUML, C4, D2) de préférence à une image.
**Comment** : chercher les blocs ```` ```mermaid ```` / `@startuml` ou images liées.
**Critères** : `PARTIEL` si uniquement des images binaires (non diffables) ou si le diagramme ne reflète pas les composants détectés.

### A5 — `docs/deployment.md`
**Quoi** : environnements, procédure de déploiement, rollback, secrets/config (sans valeurs), pipeline.
**Comment** : croiser avec l'infra et la CI détectées.
**Critères** : `PARTIEL` si pas de procédure de rollback ou si incohérent avec la CI.

### A6 — `docs/ubiquitous-language.md`
**Quoi** : glossaire du domaine (terme, définition, synonymes interdits, contexte borné).
**Comment** : échantillonner 5–10 termes et les chercher dans le code (Grep) pour vérifier qu'ils y sont utilisés.
**Critères** : `PARTIEL` si glossaire minimal (< 5 termes) ou si les termes n'apparaissent pas dans le code.

### A7 — `docs/development.md`
**Quoi** : setup local, prérequis, lancement, tests, conventions de branche/commit, debugging.
**Comment** : vérifier que les commandes citées existent.
**Critères** : `PARTIEL` si incomplet ou commandes obsolètes.

### A8 — Dérive documentaire
**Quoi** : les docs suivent-elles le code ?
**Comment** : `git log -1 --format=%cs -- <doc>` vs `git log -1 --format=%cs -- <dossier de code concerné>` ; noter les écarts > 6 mois sur un code actif.
**Critères** : signaler chaque doc en dérive ; impacte le niveau de maturité de l'axe A (pas de niveau 3 si dérive).

### A9 — Instructions par composant (monorepo)
**Quoi** : `CLAUDE.md` imbriqués dans les sous-dossiers de composants complexes.
**Critères** : `N/A` si mono-composant ; `PARTIEL` si monorepo avec ≥ 3 composants et aucune instruction locale.

---

## B. Contexte métier

### B1 — Finalité du produit
**Quoi** : à quoi sert le produit, pour qui, quel problème il résout.
**Comment** : chercher dans `CLAUDE.md`, `README.md`, `docs/` (sections « Contexte », « Produit », « Domaine », « Business »).

### B2 — Utilisateurs et personas
**Quoi** : types d'utilisateurs, rôles, permissions métier.

### B3 — Règles métier
**Quoi** : invariants, règles de calcul, contraintes réglementaires, cas limites métier.
**Comment** : vérifier qu'au moins les règles critiques (paiement, droits, statuts, workflow) sont documentées.

### B4 — Parcours clés
**Quoi** : parcours utilisateurs principaux (ex. inscription, commande, paiement) — utiles pour cibler smoke et E2E.
**Comment** : croiser avec les tests fonctionnels (C5) : les parcours documentés sont-ils testés ?

### B5 — Cohérence langage ↔ code
**Quoi** : le vocabulaire métier (A6) est-il celui des noms de classes, tables, endpoints ?
**Critères** : `PARTIEL` si divergences fréquentes (ex. glossaire « Contrat », code « Agreement » et « Deal »).

**Critères axe B** : `PRÉSENT` si B1–B3 sont couverts de façon spécifique au domaine ; `PARTIEL` si générique ou dispersé ; `ABSENT` si aucun contexte métier.

---

## C. Feedback — sensors par composant

À évaluer **pour chaque composant** détecté. Remplir la matrice composants × sensors. Signatures d'outils : `tool-signatures.md` § 2.

### C1 — Lint / formatage
**Comment** : fichier de config + invocation (script, pre-commit, CI).
**Critères** : `PARTIEL` si configuré mais jamais invoqué, ou si des règles sont massivement désactivées (`eslint-disable` en masse, `# noqa` généralisés).

### C2 — Analyse statique / typage
**Comment** : typage strict (`"strict": true` dans `tsconfig.json`, `mypy --strict`, Swift/Kotlin natifs), outils SAST/qualité (Sonar, Semgrep, CodeQL, detekt), pour l'infra : `terraform validate`, checkov, tfsec, trivy config.
**Critères** : `PARTIEL` si typage non strict ou `any`/`type: ignore` omniprésents.

### C3 — Tests unitaires
**Comment** : framework configuré, dossier/fichiers de tests réels, ratio grossier fichiers de test / fichiers source, seuil de couverture configuré (`coverageThreshold`, `fail_under`, `jacoco` rules).
**Critères** : `PRÉSENT` = tests substantiels + seuil de couverture ; `PARTIEL` = tests présents sans seuil, ou très peu de tests.

### C4 — Smoke tests
**Quoi** : vérification rapide qu'un déploiement / build est vivant (healthcheck, page d'accueil, endpoint `/health`, lancement de l'app mobile).
**Comment** : scripts `smoke*`, tags `@smoke`, jobs CI post-déploiement, `curl` sur healthcheck dans la CI.

### C5 — Tests fonctionnels / E2E
**Comment** : Playwright, Cypress, Selenium, XCUITest, Espresso, Maestro, Detox, tests API de bout en bout (Postman/Newman, Bruno, Karate, REST Assured).
**Critères** : croiser avec B4 — `PARTIEL` si les parcours clés ne sont pas couverts.

### C6 — Contract testing
**Pertinence** : uniquement si le composant expose ou consomme une API utilisée par un autre composant / une autre équipe. Sinon `N/A` justifié.
**Comment** : Pact (fichiers `pacts/`, `@pact-foundation`), spec OpenAPI/AsyncAPI/GraphQL versionnée + validation (Spectral) + détection de breaking changes (oasdiff, openapi-diff, graphql-inspector), Schemathesis/Dredd, Spring Cloud Contract.
**Critères** : `PARTIEL` si spec présente mais ni validée ni comparée en CI.

### C7 — Tests d'intégration
**Pertinence** : si le composant dépend de systèmes externes (BDD, file de messages, cache, API tierce, cloud). Sinon `N/A`.
**Comment** : Testcontainers, `docker-compose.test.yml`, LocalStack, WireMock, base de test dédiée, dossiers `integration/`, `it/`.

### C8 — Sensors spécifiques infra (composants `infra`)
- `terraform fmt` / `validate` / tflint ;
- scan sécurité IaC (checkov, tfsec, trivy config, kics) ;
- `terraform plan` (ou équivalent CDK/Pulumi `diff`/`preview`) exécuté en CI sur les PR ;
- policy as code (conftest/OPA, Sentinel) ;
- validation Kubernetes/Helm (kubeconform, `helm lint`, kube-linter) ;
- Dockerfile (hadolint), scan d'image (trivy image, grype) ;
- tests d'infra (terratest, `terraform test`, CDK assertions) ;
- estimation de coût (infracost) — bonus.

### C9 — Sensors spécifiques mobile (composants `ios` / `android`)
- SwiftLint / ktlint / detekt, Android Lint ;
- tests UI (XCUITest, Espresso, Maestro) ;
- build CI (fastlane, Xcode Cloud, Bitrise, Gradle) ;
- tests de snapshot (swift-snapshot-testing, Paparazzi) — bonus.

---

## D. Fitness functions

Une fitness function est un contrôle **automatisé** qui protège une caractéristique d'architecture. Critère clé : **automatisée et bloquante** ; une métrique seulement affichée = `PARTIEL`.

| ID | Caractéristique | Exemples |
|---|---|---|
| D1 | Structure / dépendances | ArchUnit, NetArchTest, Konsist, dependency-cruiser, eslint-plugin-boundaries, Nx module boundaries, import-linter, deptrac, Swift package boundaries |
| D2 | Performance | Lighthouse CI budgets, k6/Gatling avec thresholds, size-limit / bundlesize, benchmarks avec seuils |
| D3 | Qualité de code | seuils de couverture bloquants, seuils de complexité (Sonar quality gate, radon, eslint `complexity`) |
| D4 | Robustesse des tests | mutation testing (Stryker, PIT, mutmut, cargo-mutants) |
| D5 | Accessibilité | axe-core, pa11y, Lighthouse a11y avec seuil |
| D6 | Dépendances | Renovate / Dependabot, licences (license-checker, FOSSA), audit des vulnérabilités bloquant |
| D7 | Contrats / compatibilité | détection de breaking changes d'API (voir C6), compatibilité de schéma BDD (migrations testées) |
| D8 | Infra / coûts | policies OPA, budgets infracost |

---

## E. Câblage de la boucle de feedback

### E1 — Hooks locaux
**Comment** : `.pre-commit-config.yaml`, `.husky/`, `lefthook.yml`, `.git/hooks` versionnés via script, `lint-staged`.
**Critères** : lister quels sensors (C1–C3) y sont branchés.

### E2 — CI
**Comment** : lire chaque workflow ; pour chaque sensor détecté en C, vérifier qu'un job l'exécute **sur les PR**. Repérer les jobs `continue-on-error: true` / `allow_failure: true` (= non bloquants).
**Critères** : `PARTIEL` si des sensors importants ne tournent pas en CI ou sont non bloquants.

### E3 — Checks requis / protection de branche
**Comment** : si `gh` disponible et authentifié : `gh api repos/{owner}/{repo}/branches/{default}/protection` (lecture seule). Sinon : `NON VÉRIFIABLE`.

### E4 — Hooks Claude Code
**Comment** : `.claude/settings.json` → `hooks` (ex. `PostToolUse` sur `Edit|Write` qui lance lint/format/typecheck, `Stop` qui lance les tests rapides).
**Critères** : `PRÉSENT` si au moins lint ou typecheck est déclenché automatiquement après édition.

### E5 — Point d'entrée unique
**Quoi** : une commande documentée pour lancer tous les checks (`make check`, `just verify`, `npm run validate`, `task ci`).
**Critères** : `PARTIEL` si la commande existe mais n'est pas documentée dans `CLAUDE.md` / `docs/development.md`.

### E6 — Vitesse perçue (indicateur statique)
**Comment** : repérer la séparation tests rapides / lents (tags, projets séparés, jobs distincts), le cache CI, la parallélisation. Pas de mesure réelle (audit statique).

---

## F. Harness agent

| ID | Contrôle |
|---|---|
| F1 | `.claude/settings.json` versionné : permissions (allow/deny) adaptées, deny sur les zones sensibles |
| F2 | Skills / commandes projet (`.claude/skills/`, `.claude/commands/`) pour les tâches récurrentes |
| F3 | Subagents projet (`.claude/agents/`) si pertinent |
| F4 | Config MCP (`.mcp.json`) documentée, sans secret en clair |
| F5 | Playbooks / runbooks découvrables par l'agent (ex. `playbooks/`, `docs/runbooks/`) |
| F6 | Fichiers générés / vendored clairement signalés (`.gitattributes linguist-generated`, mention dans `CLAUDE.md`) pour éviter que l'agent les modifie |

Ces contrôles sont des bonus de maturité : `ABSENT` n'est pas bloquant, mais à recommander.

---

## G. Reproductibilité

| ID | Contrôle |
|---|---|
| G1 | Lockfiles versionnés (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `poetry.lock`, `uv.lock`, `Cargo.lock`, `go.sum`, `Package.resolved`, `Podfile.lock`, `gradle.lockfile`, `.terraform.lock.hcl`) |
| G2 | Versions d'outils figées (`.nvmrc`, `.node-version`, `.tool-versions`, `.python-version`, `mise.toml`, `rust-toolchain.toml`, `.xcode-version`, `required_version` Terraform) |
| G3 | Environnement de dev conteneurisé (`.devcontainer/`, `docker-compose.yml` dev, Nix/devbox) |
| G4 | `.env.example` / template de config sans secret |
| G5 | Données de test : fixtures, factories, seeds, builders |

---

## H. Sensors runtime

| ID | Contrôle |
|---|---|
| H1 | Logs structurés (logger JSON configuré, niveaux) |
| H2 | Tracing / métriques (OpenTelemetry, Datadog, Prometheus) |
| H3 | Error tracking (Sentry, Crashlytics, Bugsnag) — en particulier pour web et mobile |
| H4 | Healthchecks / readiness exposés (et utilisés par le smoke test C4) |
| H5 | Feature flags (LaunchDarkly, Unleash, flagd, maison) pour limiter le rayon d'impact |
| H6 | Alerting / SLO déclarés en code (si visibles dans le repo) |

---

## I. Sécurité (contrôle léger)

| ID | Contrôle |
|---|---|
| I1 | Scan de secrets (gitleaks, trufflehog, detect-secrets) en pre-commit ou CI |
| I2 | SCA / audit de dépendances en CI (Dependabot alerts, `npm audit`, pip-audit, OWASP dependency-check, Snyk) |
| I3 | SAST en CI (CodeQL, Semgrep, Sonar) |

Pour un audit approfondi, renvoyer vers les skills `safety-check` et `security-audit`.
