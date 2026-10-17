# Matrice des agents

Agents livrés dans `agents/`. Le modèle est fixé dans le frontmatter de chaque agent par un alias (`opus`, `sonnet`, `haiku`), qui pointe vers la dernière version. La version complète, avec le cadre de workflow, est dans `.agentsworkspace/agentic-workflow/agents-models-matrix.md`.

| Agent | Rôle | Modèle | Effort | Écrit ? |
|---|---|---|---|---|
| spike | Analyse du besoin d'une issue (options, risques, questions) → commentaire sur l'issue | Opus 5.5 | high | commentaire GH |
| implementation-plan | Contre-expertise de la spike, plan d'implémentation découpé | Opus 5.5 | high | non (rendu à l'appelant) |
| architect | Mode plan : valide le plan. Mode diff : conformité du diff à l'architecture et au plan | Opus 5.5 | high | non |
| dev | Implémentation du plan ou des corrections, tests, validation locale, push de la branche | Sonnet 5.5 | medium | code + branche |
| code-reviewer | Revue avec un focus : correctness, tests, security, perf | Sonnet 5.5 | high | non |
| ci-watcher | Suit la CI d'une PR ; diagnostic des échecs | Haiku 4.5 | low | non |
| change-explainer | Page HTML d'explication pour les PR high risk | Sonnet 5.5 | medium | `.agent-reports/` |
| release-watcher | Suit la release preview et les smoke tests (GHA) ; PR de revert si rouge | Sonnet 5.5 | medium | branche + PR de revert |

Agents propres à un repo (par ex. `tenant-isolation`, `migration-reviewer`) : à définir dans `<repo>/.claude/agents/` et à déclarer dans le `CLAUDE.md` du repo pour que `/review-pr` les lance.
