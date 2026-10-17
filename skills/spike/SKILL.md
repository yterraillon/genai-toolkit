---
name: spike
description: Lance l'agent spike sur une issue GitHub (analyse du besoin, options, risques, questions bloquantes), qui publie la spike en commentaire de l'issue
argument-hint: [issue-number] [owner/repo optionnel]
---

Lance l'agent `spike` sur l'issue `$1` du repo `$2` (si `$2` est vide : le repo courant, `gh repo view --json nameWithOwner`).

Une fois l'agent terminé, affiche à l'utilisateur :
- le lien du commentaire publié ;
- la recommandation en une phrase ;
- les questions bloquantes, s'il y en a.

S'il n'y a pas de question bloquante, propose de lancer `/implementation-plan $1`.
