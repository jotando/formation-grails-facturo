# Exercice 6 — Rechercher les commandes

| | |
| --- | --- |
| Partie | **AVEC IA** (journal obligatoire) |
| Branche | `<login>/ex06-recherche-commandes` |
| Durée indicative | 4 h |
| Notions | O4, B2, C1, C2, G2, S4 |
| Modèle dans le cours | module 4 et séance 5.3 ; `RechercheFactureCommand`, `FactureService.rechercher`, `facture/recherche.gsp` |

## Contexte

Les acheteurs cherchent les commandes par fournisseur, statut, période et montant, et surtout celles **en retard** : envoyées, avec une date de livraison prévue dépassée.

## Travail demandé

1. Ajouter à `v_commande_totaux` une colonne `en_retard` calculée par `CASE WHEN` (commit séparé, dans le script de l'exercice 4), et la propriété correspondante dans `CommandeTotaux`.
2. Command object `RechercheCommandeCommand` : fournisseur, statut, période sur la date de commande (`@BindingFormat`), montant HT minimum (≥ 0), case « en retard seulement » ; fin de période postérieure au début.
3. Recherche par `where` composé sur `CommandeTotaux`, paginée (10 par page, `max` borné à 50) et triable par numéro, date, fournisseur, total ; **liste blanche** des colonnes de tri.
4. URL `/achats/commandes` et `/achats/commandes/recherche` ; formulaire en `GET` pour que l'URL d'une recherche soit partageable.
5. Badge « en retard » sur les lignes concernées.
6. Tests Spock du contrôleur (`ControllerUnitTest`) : `max` borné, tri inconnu ignoré, période inversée refusée.

## Exigences IA

- Journal IA rempli ; au moins un prompt de génération de tests, et la liste des cas que vous avez ajoutés ou retirés par rapport à la proposition de l'IA.

## Critères d'acceptation

Après `./outils/reinit-db.sh` :

- [ ] « En retard seulement » renvoie exactement `CA-<année>-0002`.
- [ ] La recherche « statut ENVOYEE, montant ≥ 500 € » renvoie `CA-<année>-0002` (806,00 € HT) et `CA-<année>-0003` (720,00 € HT).
- [ ] `?max=100000` affiche au plus 50 lignes ; `?sort=fournisseur_id;drop` ne provoque pas d'erreur.
- [ ] La page 2 conserve tous les critères de recherche.
- [ ] Une seule requête de lecture pour la liste, plus une pour le total (vérifier avec `logSql`).
