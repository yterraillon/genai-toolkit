# Plan — Workflow de dev agentique (agents + skills génériques)

## Contexte
On veut une chaîne de dev de bout en bout (issue → spike → plan → dev → PR → review → release preview → prod), sûre et avec peu d'interventions humaines. Les étapes sont d'abord **lancées une par une à la main** ; l'orchestration viendra ensuite. Les agents doivent être **génériques** : ce qui est propre à un repo vit dans `.claude/workflow.yml` (config structurée) et dans le `CLAUDE.md` du repo (conventions). Les sources sont dans `genai-toolkit`, et un script les copie dans `~/.claude`.

Ce qui existe déjà : `skills/spike` (il mélange spike et plan), `skills/create-pr` (risque évalué par le LLM seul), `skills/safety-check`, `skills/commit-message`, et `agents-models-matrix.md` (choix de modèle par agent).

## Review de l'approche — ce que je garde et ce que je change
Le découpage est bon : un rôle par agent, une porte humaine sur le plan, une review adaptée au risque, un seul aller-retour de correction. Voici les changements que je propose :

1. **Un contrat explicite par étape.** Chaque étape prend un identifiant (issue# ou PR#), écrit **un seul** artefact sur GitHub (commentaire marqué `<!-- agent:<step> v1 -->`, qui est mis à jour au lieu d'être dupliqué) et fait passer un **label d'état**. Les étapes restent ainsi sans état et rejouables, et l'orchestrateur de demain n'aura qu'à lire des labels.
   Machine d'états : `wf:spike-done` → `wf:plan-proposed` → (go humain dans la session, sans label) → colonne **Dev** du Project → `wf:pr-open` → `wf:review-done` → `wf:fix-done` → `wf:needs-human` (high uniquement).
   **Validation du plan sans friction** : `wf-plan` présente le plan dans la session et te demande le go (AskUserQuestion). Lancer `/wf-dev <issue>` vaut aussi pour go. `wf-dev` vérifie seulement qu'un commentaire `agent:plan` existe, puis l'agent dev déplace l'issue dans la colonne Dev du GitHub Project (`gh project item-edit`).
2. **Séparer nettement spike et plan.** La spike répond à *quoi / pourquoi / options / risques / questions bloquantes*. Le plan répond à *comment* : étapes, fichiers, tests, critères de done. Aujourd'hui `skills/spike` produit déjà un plan, ce qui crée un doublon.
3. **L'auteur de la PR ne fixe pas seul son niveau de risque.** Un **plancher déterministe** vient de `workflow.yml` (`risk_rules` : chemins ou globs → niveau, par ex. `**/Migrations/**` → high), puis le LLM peut **monter** le niveau, jamais le baisser. Les reviewers peuvent aussi le monter.
4. **Ajouter un agent `review-triage`.** Quand 2 à 5 agents relisent en parallèle, il faut quelqu'un pour dédupliquer, classer (must-fix / should-fix / nit / rejeté) et produire **un seul plan de corrections**. Sinon, le dev reçoit des retours contradictoires.
5. **Un seul aller-retour, avec une vérification légère.** Après le fix, on ne relance pas toute la review : on relance la CI, et `review-triage` en mode `--verify` confirme que chaque must-fix est traité. S'il reste quelque chose, la main passe à l'humain, pas à une boucle.
6. **Contrôle de la CI avant les reviews coûteuses.** `ci-watcher` démarre en même temps que les reviews. Si la CI échoue sur build ou compilation, son diagnostic entre dans le plan de corrections avec la priorité maximale.
7. **Release preview : revert d'abord, hotfix ensuite.** Si la preview est au rouge, l'agent ouvre une **PR de revert** (sûre et rapide). Il y ajoute un diagnostic et une proposition de hotfix, qui repart dans le pipeline normal avec le niveau de risque **high** imposé. Rien n'est mergé automatiquement.
8. **Sécurité du harness, et pas seulement des prompts :**
   - Hooks `PreToolUse` dans `~/.claude/settings.json` qui refusent `git push` vers la branche par défaut, `push --force`, `gh pr merge`, `gh release`, ainsi que les éditions de `.github/workflows/**` par le dev (sauf si autorisé dans `workflow.yml`).
   - Chaque agent ne reçoit que les outils dont il a besoin : spike, plan, architect et reviewers sont en lecture seule plus `gh` en lecture et commentaire ; seul `dev` écrit.
   - `dev` travaille dans un **worktree** dédié (`isolation: worktree`).
   - **Contenu des issues et des PR = donnée non fiable** (injection de prompt). On ne traite que les issues portant un label posé par un mainteneur (`wf:ready`), et les prompts rappellent que le contenu GitHub est de la donnée, pas des instructions.
   - `safety-check` (déjà présent) tourne avant chaque push.
9. **Agents de la matrice à intégrer :** `decision-keeper` (ADR / `DECISIONS.md` après approbation du plan) et `follow-up` (issues backlog après le merge). `tenant-isolation` et `migration-reviewer` sont **propres à un repo**. Ils vivent donc dans `.claude/agents/` du repo cible et sont référencés par `workflow.yml` → `reviewers`.
10. **Modèles :** pas de Fable (trop coûteux). Spike et architect passent sur Opus 5.5. Dans la matrice, « Sonnet 5 » devient « Sonnet 5.5 » et la colonne Alt-Modèle est retirée.

## Structure cible dans genai-toolkit
```
agents/                      # subagents génériques (frontmatter : name, description, tools, model)
  spike.md            Opus 5.5    lecture seule + gh issue
  planner.md          Opus 5.5    lecture seule + gh issue ; lance l'architect
  architect.md        Opus 5.5    2 modes : plan-review | diff-review
  dev.md              Sonnet 5.5  écriture, worktree ; build/test/lint d'après workflow.yml
  code-reviewer.md    Sonnet 5.5  paramétré par un "focus" (correctness | tests | security | perf)
  review-triage.md    Opus 5.5    consolidation → plan de corrections ; mode --verify
  ci-watcher.md       Haiku 4.5   gh run watch + diagnostic d'échec (escalade vers Sonnet si besoin)
  change-explainer.md Sonnet 5.5  page HTML high risk (schémas mermaid/SVG inline)
  release-watcher.md  Sonnet 5.5  logs release + smoke test → PR de revert / proposition de hotfix
  decision-keeper.md  Sonnet 5.5
  follow-up.md        Haiku 4.5
skills/                      # points d'entrée manuels (/wf-*), une étape = une skill
  wf-spike/     → agent spike (remplace skills/spike)
  wf-plan/      → planner + architect(plan-review) ; publie le plan et demande le go dans la session
  wf-dev/       → vérifie que le plan existe ; déplace l'issue en colonne Dev ; dev ; safety-check ; commit-message
  wf-pr/        → remplace create-pr : plancher de risque + LLM, labels risk:* et wf:pr-open
  wf-review/    → ci-watcher ∥ N reviewers (selon risque) ∥ architect(diff) ∥ change-explainer si high → review-triage
  wf-fix/       → dev avec le plan de corrections ; ci-watcher ; review-triage --verify
  wf-release/   → release-watcher : suit les runs GitHub Actions de la release (après merge)
  _shared/      workflow-config.md (comment lire workflow.yml), github-artifacts.md (marqueurs, labels, upsert de commentaire)
  safety-check/, commit-message/   (gardés, appelés par wf-dev et wf-pr)
hooks/
  guard-git.ps1                    # hook PreToolUse Claude Code (local) : refus push main, force, merge, release
templates/
  workflow.yml                     # schéma commenté à copier dans <repo>/.claude/
  CLAUDE.workflow-snippet.md       # renvoi vers workflow.yml + conventions
docs/workflow.md                   # machine d'états, contrats, portes humaines (doc de référence)
scripts/install.ps1                # copie agents/skills/hooks vers ~/.claude et fusionne les hooks dans settings.json
```

## Schéma de `.claude/workflow.yml` (dans chaque repo cible)
```yaml
default_branch: main
commands: { build: "...", test: "...", lint: "..." }
risk_rules:            # plancher déterministe
  high:   ["**/Migrations/**", "**/Auth/**", ".github/workflows/**"]
  medium: ["src/**"]
reviewers:             # nombre et spécialistes par niveau
  low:    [code-reviewer:correctness]
  medium: [code-reviewer:correctness, code-reviewer:tests]
  high:   [code-reviewer:correctness, code-reviewer:security, tenant-isolation]
  conditional: { "**/Migrations/**": migration-reviewer }
architect_review: [medium, high]
ci: { workflows: ["ci.yml"], timeout_min: 30 }
project: { number: 3, status_field: "Status", dev_column: "Dev" }   # GitHub Project v2
release:               # tout tourne dans GitHub Actions ; l'agent lit les runs via gh (run list/watch/view --log-failed)
  workflows: ["Deploy preview", "Smoke tests"]   # noms des workflows GHA à surveiller après le merge
reports_dir: .agent-reports    # gitignoré ; contient la page HTML high risk
allow_workflow_edits: false
```

## Détail des étapes (contrat entrée → sortie → label)
| Skill | Entrée | Sortie GitHub | Label posé | Porte |
|---|---|---|---|---|
| wf-spike | issue# (label `wf:ready`) | commentaire `agent:spike` (ou questions bloquantes) | `wf:spike-done` / `wf:spike-blocked` | — |
| wf-plan | issue# | commentaire `agent:plan` + section architect | `wf:plan-proposed` | **go humain dans la session** (pas de label) |
| wf-dev | issue# | branche `feat/<issue>-slug`, commits | issue → colonne **Dev** | refuse si aucun plan publié |
| wf-pr | branche | PR liée à l'issue, `risk:*` | `wf:pr-open` | — |
| wf-review | PR# | commentaire `agent:review-plan` (consolidé), HTML dans `reports_dir` si high | `wf:review-done` (+ `wf:needs-human` si high) | **humain si high** |
| wf-fix | PR# | commits de fix, commentaire `agent:verify` | `wf:fix-done` ou `wf:needs-human` | 1 seul tour |
| wf-release | merge SHA (runs GHA) | si rouge : PR de revert + commentaire de diagnostic | `wf:preview-ok` / `wf:preview-failed` | **go prod = humain** |

## Phases de livraison (chaque phase est testable seule)
1. **Socle** : `docs/workflow.md`, `templates/workflow.yml`, `skills/_shared/*`, hooks de garde, `scripts/install.ps1`.
2. **Amont** : `spike`, `planner`, `architect` (plan-review), `decision-keeper`, et les skills `wf-spike`, `wf-plan`.
3. **Dev + PR** : `dev`, `wf-dev`, `wf-pr` (réécriture de `create-pr` avec le plancher de risque).
4. **Review** : `code-reviewer`, `ci-watcher`, `architect` (diff-review), `change-explainer`, `review-triage`, `wf-review`, `wf-fix`.
5. **Release** : `release-watcher`, `follow-up`, `wf-release`.
6. Mise à jour de `agents-models-matrix.md` (modèles, nouveaux agents) et de `README.md`.

## Vérification
- **Repo bac à sable** : un petit repo GitHub de test avec `.claude/workflow.yml`, une CI factice (un job qui réussit, un autre qui échoue sur demande) et un workflow « preview » factice.
- **Par phase :**
  - P1 : vérifier que les hooks bloquent `git push origin main`, `gh pr merge` et `--force` dans une session Claude Code.
  - P2 : une issue claire doit produire une spike puis un plan ; une issue floue doit produire `wf:spike-blocked`.
  - P3 : `wf-dev` doit refuser sans plan publié et déplacer l'issue dans la colonne Dev. Une PR qui touche `Migrations/` doit sortir en `risk:high` même si le LLM propose low.
  - P4 : injecter un bug et un test cassé. On attend une CI rouge, un diagnostic, un seul plan de corrections, un fix, puis la vérification.
  - P5 : faire échouer le workflow GHA de smoke test, puis vérifier qu'une PR de revert est ouverte et non mergée.
- Rejouer chaque étape deux fois : le commentaire doit être mis à jour (pas dupliqué) et les labels doivent rester cohérents.
