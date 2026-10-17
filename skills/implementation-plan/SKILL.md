---
name: implementation-plan
description: Produit le plan d'implémentation d'une issue à partir de sa spike, le fait relire par l'agent architect, le soumet à l'utilisateur puis le publie sur l'issue après validation
argument-hint: [issue-number] [owner/repo optionnel]
---

# Plan d'implémentation

Issue `$1`, repo `$2` (si `$2` est vide : le repo courant, `gh repo view --json nameWithOwner`).

## Étape 1 : rédaction
Lance l'agent `implementation-plan` sur l'issue.

## Étape 2 : revue architecturale
Lance l'agent `architect` en mode `plan` sur le plan obtenu.
- Verdict `approve` : passe à l'étape 3.
- Verdict `approve-with-changes` ou `reject` : relance `implementation-plan` en lui passant les points de l'architect. **Un seul tour** : si l'architect rejette encore, présente les deux points de vue à l'utilisateur à l'étape 3.

## Étape 3 : validation utilisateur
Présente à l'utilisateur :
- le plan complet ;
- le verdict de l'architect et ses points non résolus ;
- les « points à valider » du plan.

Demande son go. S'il demande des modifications, intègre-les (directement ou en relançant l'agent) et redemande. Ne publie rien sans go explicite.

## Étape 4 : publication
Publie le plan validé en commentaire de l'issue, avec le corps écrit dans un fichier temporaire :
```bash
gh issue comment $1 -R <repo> --body-file <fichier>
```
Commence le commentaire par `## Plan d'implémentation`. Ajoute en fin de commentaire une section « Revue architecturale » qui reprend le verdict.

Affiche le lien du commentaire et propose de lancer l'agent `dev` sur l'issue.
