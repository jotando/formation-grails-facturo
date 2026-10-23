# Exercice 2 — Saisir, modifier et désactiver un fournisseur

| | |
| --- | --- |
| Partie | **SANS IA** |
| Branche | `<login>/ex02-saisie-fournisseur` (depuis `etu-<login>`, ex01 fusionné) |
| Durée indicative | 4 h |
| Notions | O2, S1, S4, C2, C3, G2, G3 |
| Modèle dans le cours | module 2 ; `ClientService` (Data Service), `client/_form.gsp`, `RemiseCommand` |

## Contexte

Les acheteurs doivent créer et modifier des fournisseurs. Un fournisseur n'est jamais supprimé : il est désactivé, avec un motif obligatoire.

## Travail demandé

1. Contraintes de `Fournisseur` :
    - `code` : 3 à 20 caractères, majuscules, chiffres et tirets, unique ;
    - `siret` : exactement 14 chiffres **et** clé de Luhn valide (validateur personnalisé), unique ;
    - `email` : optionnel, valide ;
    - `delaiLivraisonJours` : entre 1 et 90 ;
    - `actif` et `motifDesactivation` non liables depuis le formulaire de saisie.
2. Créer le Data Service `FournisseurService` (`get`, `list`, `save`).
3. Ajouter les actions `create`, `save`, `edit`, `update` avec Post-Redirect-Get, messages `flash`, réaffichage du formulaire en erreur, verrouillage optimiste (champ `version`).
4. Partager le formulaire entre création et modification par un template `_form.gsp`.
5. Désactivation : un command object `DesactivationCommand` (`fournisseurId`, `motif` de 10 à 200 caractères). L'action `desactiver` n'accepte que `POST`.
6. Messages d'erreur en français pour chaque contrainte (clés `fournisseur.<propriété>.<contrainte>`), y compris le cas du champ vide.
7. Tests Spock :
    - le validateur SIRET (au moins 4 cas valides et 4 invalides, avec `@Unroll`) ;
    - les contraintes de `DesactivationCommand`.

## Critères d'acceptation

- [ ] Créer un fournisseur avec le SIRET `54756834567144` (mauvaise clé) affiche « SIRET invalide » et conserve les autres champs saisis.
- [ ] Créer un fournisseur avec un code ou un SIRET déjà utilisé affiche un message d'unicité explicite.
- [ ] Une modification concurrente (deux onglets) est détectée et signalée, sans écraser l'autre saisie.
- [ ] Un champ `actif=false` ajouté à la main dans la requête de modification est ignoré.
- [ ] Désactiver sans motif ou avec un motif trop court est refusé ; un fournisseur désactivé disparaît de la liste.
- [ ] Les tests Spock passent et couvrent les cas listés.

## Git

Au moins 6 commits. Écrire les tests du validateur **avant** le validateur (commit `test(ex02): …` puis `feat(ex02): …`) est valorisé.

## Pour aller plus loin

Afficher les erreurs à côté de chaque champ (classe `is-invalid` de Bootstrap) plutôt qu'en liste.
