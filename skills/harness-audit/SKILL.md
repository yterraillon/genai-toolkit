---
name: harness-audit
description: Audite le harness d'un repo (feedforward, feedback, tests, fitness functions) et produit un rapport de maturité par composant, en Markdown et en HTML
tags: harness, quality, testing, documentation, agents
allowed-tools: Read, Grep, Glob, Bash(git:*), Bash(gh:*)
---

# Harness Audit

> **Objectif** : évaluer le *harness* autour du code, c'est-à-dire tout ce qui guide un agent (ou un dev) **avant** qu'il écrive du code (**feedforward** : docs, contexte métier, conventions) et tout ce qui lui dit **après** s'il a eu raison (**feedback** : linters, analyse statique, tests, fitness functions, CI).
>
> **Mode** : audit **statique uniquement**. Tu lis le repo, tu n'exécutes **jamais** les commandes du projet (pas de `npm test`, `make`, `terraform`, etc.). Seules les commandes `git` et `gh` en lecture sont autorisées.

**Fichiers de référence** (à charger au moment indiqué) :
- `references/tool-signatures.md` : marqueurs de composants et signatures d'outils par stack — phase 1 et 2
- `references/checklist.md` : liste détaillée des contrôles, par axe — phase 2
- `references/report-template.html` : gabarit HTML du rapport — phase 4

---

## Phase 1 — Découverte des composants

1. Lister l'arborescence (`git ls-files`, Glob) en ignorant `node_modules`, `vendor`, `dist`, `build`, `.venv`, `Pods`, fichiers générés.
2. Identifier chaque composant à l'aide des marqueurs de `references/tool-signatures.md` § 1 et le classer : **web**, **api**, **backoffice**, **ios**, **android**, **infra**, **jobs/data**, **lib partagée**.
3. Noter pour chaque composant : chemin racine, type, stack (langage, framework, build system).
4. Repérer la CI (`.github/workflows`, `.gitlab-ci.yml`, `azure-pipelines.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`, `.circleci/`) : elle sert de preuve de « branchement » pour tous les axes.

Sortie : tableau des composants (réutilisé dans le rapport).

## Phase 2 — Contrôles par axe

Charger `references/checklist.md` et dérouler **tous** les contrôles, axe par axe :

| Axe | Sujet |
|---|---|
| A | Feedforward — `CLAUDE.md` et documentation (`docs/architecture.md`, `docs/architecture-decision-record.md`, `docs/architecture-diagram.md`, `docs/deployment.md`, `docs/ubiquitous-language.md`, `docs/development.md`) |
| B | Contexte métier (dans `CLAUDE.md` ou `docs/`) |
| C | Feedback — sensors par composant : lint, analyse statique, TU, smoke, fonctionnel/E2E, contract, intégration, sensors infra |
| D | Fitness functions |
| E | Câblage de la boucle de feedback (pre-commit, CI, checks requis, hooks Claude Code, point d'entrée unique) |
| F | Harness agent (`.claude/`, skills, commandes, subagents, MCP, playbooks) |
| G | Reproductibilité de l'environnement |
| H | Sensors runtime (observabilité) |
| I | Sécurité (contrôle léger, renvoi vers `safety-check` / `security-audit`) |

Pour l'axe C, construire la **matrice composants × sensors** : une ligne par composant, une colonne par sensor. Utiliser `references/tool-signatures.md` § 2 pour reconnaître les outils.

**Règles de preuve**
- Chaque statut s'appuie sur une preuve : `chemin` ou `chemin:ligne` (fichier de config, job CI, script).
- La présence d'un outil dans les dépendances **ne suffit pas** : chercher s'il est configuré (fichier de config), invoqué (script, Makefile) et branché (pre-commit, CI).
- Un dossier de tests vide ou ne contenant que des exemples générés compte comme `PARTIEL`.
- Ne jamais coller de secret : référencer le fichier et masquer la valeur.

## Phase 3 — Scoring

**Statut par contrôle**

| Statut | Signification |
|---|---|
| `PRÉSENT` | Existe, configuré, substantiel |
| `PARTIEL` | Existe mais incomplet, template vide, obsolète, ou non branché |
| `ABSENT` | Introuvable |
| `N/A` | Non pertinent pour ce composant — **toujours justifier** (ex. contract testing sans consommateur d'API) |
| `NON VÉRIFIABLE` | Impossible à établir statiquement (ex. checks requis sans accès `gh`) — dire pourquoi |

Pour tout `PARTIEL` ou `ABSENT` : une remédiation concrète (outil suggéré adapté à la stack, fichier à créer).

**Maturité par axe (0–3)**

| Niveau | Critère |
|---|---|
| 0 | Absent |
| 1 | Présent mais pas branché (config ou docs existent, rien ne l'exécute ou ne l'impose) |
| 2 | Branché en local (pre-commit, script) **ou** en CI |
| 3 | Bloquant en CI (ou imposé par hook) **et** documenté dans `CLAUDE.md` / `docs/development.md` |

Pour les axes A et B (documentation), interpréter ainsi : 1 = fichiers présents mais vides/template, 2 = substantiels, 3 = substantiels, à jour (pas de dérive détectée) et référencés depuis `CLAUDE.md`.

**Synthèse globale** : qualitative, sans moyenne. Mettre en avant l'axe le plus faible et le composant le moins couvert.

## Phase 4 — Rapport

Produire **deux fichiers** au contenu identique dans `.agentsworkspace/` (créer le dossier si absent), `AAAA-MM-JJ` = date du jour :

1. `harness-audit-AAAA-MM-JJ.md` — source de vérité, rédigée en premier.
2. `harness-audit-AAAA-MM-JJ.html` — généré à partir du `.md`, en partant de `references/report-template.html` : fichier autonome (CSS inline, aucune ressource externe), badges de statut colorés, matrice lisible, mode clair/sombre.

**Structure (identique dans les deux formats)**

1. **Résumé** — 5 lignes max : repo audité, date, composants détectés, axe le plus faible, top 3 des actions.
2. **Maturité par axe** — tableau `Axe | Niveau (0–3) | Commentaire`.
3. **Composants détectés** — tableau `Composant | Chemin | Type | Stack`.
4. **Matrice composants × sensors** — statuts uniquement (détails en section 5).
5. **Détail par axe** — pour chaque contrôle : `ID | Contrôle | Statut | Preuve | Remédiation`.
6. **Plan d'action priorisé**
   - *Quick wins* (< 1 jour)
   - *Moyen terme* (quelques jours)
   - *Structurant* (chantier d'équipe)

   Renvoyer vers les skills existants quand c'est pertinent : `setup-cicd` (lint/pre-commit/CI), `unit-test-expand` (couverture), `documentation-refactor` (docs), `safety-check` (secrets), `security-audit` (sécurité approfondie).
7. **Limites de l'audit** — ce qui n'a pas pu être vérifié statiquement.

## Règles

- Ne jamais exécuter les commandes du projet ; ne rien modifier en dehors des deux fichiers de rapport.
- Rester factuel : pas de statut sans preuve, pas d'outil inventé.
- Adapter les recommandations à la stack détectée (ne pas proposer Jest à un projet Swift).
- Rédiger le rapport en français.
- À la fin, afficher dans le terminal le résumé (section 1) et les chemins des deux fichiers.
