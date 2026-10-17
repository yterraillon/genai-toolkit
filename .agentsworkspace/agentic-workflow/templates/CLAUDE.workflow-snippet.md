## Workflow agentique

Ce repo utilise le workflow `/wf-*` de genai-toolkit (voir `docs/workflow.md` dans genai-toolkit).

- La configuration structurée (commandes, règles de risque, reviewers, CI, release) est dans `.claude/workflow.yml`. C'est la source de vérité : ne pas dupliquer ces valeurs ici.
- Les reviewers propres à ce repo sont dans `.claude/agents/`.

### Conventions à respecter par les agents
<!-- À compléter : architecture, bounded contexts, conventions de nommage, règles de tests,
     zones sensibles (multi-tenant, paiements…), ce qu'il ne faut jamais faire. -->
