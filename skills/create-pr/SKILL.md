---
description: Évalue le niveau de risque des changements locaux, génère une description et crée la PR sur GitHub avec la CLI `gh`.
allowed-tools: Bash
---

# Skill : Création et Évaluation de Pull Request

Ton rôle est d'analyser le travail en cours, d'évaluer le niveau de risque de la PR, puis de la créer sur GitHub via la CLI `gh`.

## Étape 1 : Analyse des changements
1. Exécute `git status` et `git diff main...HEAD` (ou la branche par défaut) pour récupérer l'ensemble des modifications.
2. Si des fichiers non commités existent, préviens l'utilisateur avant d'aller plus loin.

## Étape 2 : Évaluation du niveau de risque
Analyse les fichiers impactés et le code pour attribuer un tag de risque :

* **`risk:low`** :
  * Fichiers de doc, CSS/Styling, fix mineur UI.
  * Pas de modification sur la logique métier, la DB ou les dépendances.
  * Tests unitaires ajoutés/mis à jour et passants.
* **`risk:medium`** :
  * Modification de fonctionnalités existantes sans breaking changes.
  * Ajout d'une nouvelle feature modérée.
  * Nouvelles dépendances mineures.
* **`risk:high`** :
  * Refactoring majeur ou breaking change.
  * Modifications touchant la sécurité, l'authentification, les paiements, la base de données (migrations) ou la CI/CD.
  * Suppression importante de code sans couverture de test.

## Étape 3 : Rédaction de la PR
Rédige un message clair et structuré contenant :
- **Résumé des changements** (Bullets points).
- **Motivation / Problème résolu**.
- **Justification du niveau de risque** (Explique brièvement pourquoi tu as choisi `risk:low`, `medium` ou `high`).

## Étape 4 : Validation utilisateur (Sécurité)
Affiche le résumé de ton évaluation :
- Titre proposé
- Niveau de risque (`risk:X`)
- Description de la PR
Demande à l'utilisateur de valider avant d'exécuter la création sur GitHub.

## Étape 5 : Exécution de la commande GitHub CLI
Une fois validé, pousse la branche si nécessaire (`git push -u origin HEAD`) et exécute la commande `gh` :

```bash
gh pr create \
  --title "..." \
  --body "..." \
  --label "risk:high"  # Remplacer par le tag approprié (low, medium, high)