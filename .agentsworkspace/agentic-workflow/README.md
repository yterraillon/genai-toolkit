# Workflow agentique : en pause

**Statut (2026-10-17)** : cadre mis de côté pour faciliter l'adoption. On livre d'abord les agents et skills **autonomes** (voir `agents/` et `skills/` à la racine du repo). On reprendra le cadre de workflow quand ces briques auront fait leurs preuves une par une.

## Contenu

| Fichier | Rôle |
|---|---|
| `plan.md` | Plan approuvé : review de l'approche, machine d'états, contrats, phases de livraison |
| `workflow.md` | Doc de référence du workflow (phase 1 écrite) |
| `templates/workflow.yml` | Config structurée par repo (risk_rules, reviewers par niveau, CI, Project, release) |
| `templates/CLAUDE.workflow-snippet.md` | Section à ajouter au CLAUDE.md des repos cibles |
| `skills-shared/` | Procédures communes : lecture de la config, upsert des commentaires marqués, labels, colonne du Project |
| `hooks/guard-git.ps1` | Hook PreToolUse (testé sur 11 cas) : bloque push vers main, force push, `gh pr merge`, `gh release`, édition de `.github/workflows` |
| `agents-models-matrix.md` | Matrice des agents au moment de la mise en pause |

## Ce qui reste à faire pour reprendre

1. Remettre le contrat d'étape (commentaire marqué + labels `wf:*`) dans les agents autonomes.
2. Remplacer la lecture du CLAUDE.md par `workflow.yml` pour les valeurs structurées (plancher de risque, reviewers par niveau).
3. Ajouter `review-triage` (consolidation + `--verify`), `decision-keeper` et `follow-up`.
4. Réintégrer le hook dans `scripts/install.ps1`. Il est utile même sans workflow : on peut le sortir en premier.
5. Repartir des phases 2 à 5 de `plan.md`, puis de l'orchestration.
