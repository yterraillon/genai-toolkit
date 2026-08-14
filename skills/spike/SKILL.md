---
name: spike
description: Analyse une issue GitHub et rédige un plan d'implémentation, ou pose des questions si des infos manquent
allowed-tools: Bash(gh:*), Read, Grep, Glob
argument-hint: [repo] [issue-number]
---
spike org-name/repo-name issue-number
Tu analyses l'issue $2 du repo $1.

1. Récupère l'issue : `gh issue view $2 -R $1 --json title,body,comments,labels`
2. Explore le codebase pour identifier les fichiers et composants concernés.
3. Évalue si l'issue contient assez d'infos pour un plan actionnable
   (critères d'acceptation, comportement attendu, périmètre).

**Si l'issue est suffisamment claire :**
- Rédige un plan d'implémentation : découpage en étapes, fichiers touchés,
  risques, points de test.
- Poste-le : `gh issue comment $2 -R $1 --body "..."`
- Ajoute le label : `gh issue edit $2 -R $1 --add-label "spike-done"`

**Sinon :**
- Poste un commentaire listant les questions précises et bloquantes.
- Ajoute le label : `gh issue edit $2 -R $1 --add-label "spike-blocked"`

Ne modifie AUCUN fichier du repo. Analyse et commentaires uniquement.