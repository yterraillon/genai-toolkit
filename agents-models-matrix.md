# Agents Matrix

| Agent | Rôle | Modèle | Alt-Modèle | Effort | Thinking |
|---|---|---|---|---|---|
| spike | Étude initiale, options, risques, commentaire issue → Ready | Fable 5.1 | Opus 5.5 | high | ~32k |
| plan | Contre-expertise de la spike, plan d'implémentation découpé | Opus 5.5 | — | high | ~16k |
| architect | Approbation du plan (bounded contexts, fitness functions), puis conformité du diff au plan | Fable 5.1 | Opus 5.5 | high | ~32k |
| decision-keeper | Persiste les décisions validées dans `DECISIONS.md` | Sonnet 5 | — | low | off |
| dev | Implémentation du plan + tests, validation locale auto | Sonnet 5 | — | medium | ~8k |
| create-pr | Titre conventional commit, description, liens issue | Haiku 4.5 | — | low | off |
| code-review | Qualité, tests, lisibilité, dette | Sonnet 5 | — | high | ~16k |
| tenant-isolation | Vérifie filtres tenant, requêtes EF, accès S3, fuites cross-tenant | Opus 5.5 | — | high | ~16k |
| migration-reviewer | Uniquement si le diff touche `Migrations/` : réversibilité, perte de données, locks | Sonnet 5 | — | high | ~16k |
| follow-up | Extrait les tâches restantes → nouvelles issues Backlog | Haiku 4.5 | — | low | off |
