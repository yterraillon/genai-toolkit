# Playbook

## Définition 

Un playbook = de la connaissance procédurale structurée qu'un agent peut découvrir et exécuter.

Ex : 
```
PLAYBOOK: Ajouter une feature flag

Objectif
Créer une feature flag correctement configurée pour un nouveau comportement.

Procédure
1. Identifier le service concerné.
2. Vérifier s'il existe déjà une convention de nommage.
3. Créer la flag via l'outil Feature Flag.
4. Ajouter la configuration dans le repository.
5. Ajouter les tests...
6. Commencer avec 1% du trafic.
7. Vérifier les métriques...
8. Augmenter progressivement à 10%, 50%, 100%.

Ne pas faire
- Ne jamais activer directement à 100%.
- Ne pas modifier telle configuration...
```

Et surtout, ce n'est pas nécessairement injecté dans le contexte de chaque requête.
L'agent peut découvrir :
« J'ai besoin du playbook feature-flags »
puis le charger au moment où il en a besoin.

## Exemple de linkedin

Ils ont constaté qu'exposer énormément de tools directement au LLM dégrade ses performances.
ils donnent essentiellement 3 meta-tools :

```
             ┌─────────────────┐
             │      Agent      │
             └────────┬────────┘
                      │
              ┌───────▼────────┐
              │      Search    │
              │  "de quoi ai-je│
              │    besoin ?"   │
              └───────┬────────┘
                      │
              ┌───────▼────────┐
              │   Get Schema   │
              │ "comment ça    │
              │    marche ?"   │
              └───────┬────────┘
                      │
              ┌───────▼────────┐
              │    Execute     │
              │ "fais-le"      │
              └────────────────┘
```

Donc l'agent cherche d'abord ce dont il a besoin, récupère la description détaillée, puis l'exécute.

C'est une sorte de lazy loading des capacités.