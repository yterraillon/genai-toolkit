# Lire la configuration du workflow

Procédure commune à toutes les skills `/wf-*`. Ce fichier n'est pas une skill : les skills le lisent depuis `~/.claude/skills/_shared/workflow-config.md`.

## 1. Localiser le repo et la config

```bash
ROOT=$(git rev-parse --show-toplevel)
cat "$ROOT/.claude/workflow.yml"
gh repo view --json nameWithOwner --jq .nameWithOwner   # owner/repo pour les appels gh api
```

Si `.claude/workflow.yml` n'existe pas : **arrête-toi**. Indique à l'utilisateur de copier `templates/workflow.yml` de genai-toolkit dans `.claude/workflow.yml` et de l'adapter. N'invente pas de valeurs.

## 2. Valeurs par défaut

Seulement si la clé est absente :

| Clé | Défaut |
|---|---|
| `default_branch` | résultat de `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` |
| `reports_dir` | `.agent-reports` |
| `allow_workflow_edits` | `false` |
| `architect_review` | `["medium", "high"]` |
| `ci.timeout_min` | `30` |
| `release.timeout_min` | `45` |

Les clés sans défaut (`commands`, `risk_rules`, `reviewers`, `ci.workflows`, `project`, `release.workflows`) sont requises par les étapes qui les utilisent. Si l'une manque, l'étape s'arrête et le signale.

## 3. Conventions du repo

Lis aussi le `CLAUDE.md` du repo (racine et sous-dossiers concernés). Il porte les conventions d'architecture et de code, pas les valeurs de `workflow.yml`. En cas de conflit sur une valeur structurée, `workflow.yml` l'emporte.
