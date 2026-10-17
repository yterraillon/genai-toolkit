# genai-toolkit
Toolkit for GenAI assistants

## Installation

```powershell
./scripts/install.ps1     # copie agents/ et skills/ dans ~/.claude
```

## Agents et skills de dev

Chaque brique s'utilise seule. Voir `agents-models-matrix.md` pour les modèles.

| Étape | Commande | Agents utilisés |
|---|---|---|
| Spike d'une issue | `/spike <issue>` | spike |
| Plan d'implémentation | `/implementation-plan <issue>` | implementation-plan, architect |
| Développement | « lance l'agent dev sur l'issue 42 » | dev |
| Création de PR + risque | `/create-pr` | — |
| Revue selon le risque | `/review-pr <pr>` | code-reviewer ×1 à 3, architect, ci-watcher, change-explainer (high) |
| Suivi de la CI | « lance ci-watcher sur la PR 12 » | ci-watcher |
| Suivi de release preview | « lance release-watcher sur le dernier merge » | release-watcher |

### Ce que les agents lisent dans le CLAUDE.md du repo

Les agents sont génériques. Pour qu'ils s'adaptent à un repo, son `CLAUDE.md` gagne à indiquer :
- les commandes de **build, test et lint** ;
- les **zones sensibles** et leur niveau de risque minimal (par ex. `Migrations/` → high) ;
- les **reviewers spécialisés** propres au repo, et quand les lancer ;
- les noms des **workflows GitHub Actions** de CI, de release preview et de smoke test ;
- le **GitHub Project** et sa colonne de dev, s'il y en a un ;
- l'architecture, les bounded contexts et les conventions.

Ajoutez `.agent-reports/` au `.gitignore` (pages HTML générées pour les PR high risk).

### Workflow orchestré

Le cadre de workflow complet (machine d'états, contrats d'étapes, hook de sécurité) est en pause dans `.agentsworkspace/agentic-workflow/`.
