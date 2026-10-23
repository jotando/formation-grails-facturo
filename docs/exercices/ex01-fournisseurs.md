# Exercice 1 — Consulter les fournisseurs

| | |
| --- | --- |
| Partie | **SANS IA** |
| Branche | `<login>/ex01-fournisseurs` (depuis `etu-<login>`) |
| Durée indicative | 3 h |
| Notions | O1, O3, O4, C1, C3, G1, G2 (voir `docs/MATRICE_COUVERTURE.md`) |
| Modèle dans le cours | modules 1 et 3 ; code de référence `Client`, `ClientController`, `client/index.gsp` |

## Contexte

Les acheteurs veulent consulter les fournisseurs actifs et, pour chacun, les produits qu'il fournit. La table `fournisseur` et la colonne `produit.fournisseur_id` existent déjà (`src/main/sql/00_schema.sql`) ; aucun code Grails ne les utilise.

## Travail demandé

1. Créer la domain class `Fournisseur` mappée sur la table existante (toutes les colonnes ; `date_creation` alimentée par GORM).
2. Ajouter à `Produit` l'association vers `Fournisseur` (colonne `fournisseur_id`, nullable). Choisir entre référence simple et `belongsTo`, et justifier dans le RENDU.
3. Créer `FournisseurController` avec les actions `index` (fournisseurs actifs triés par raison sociale) et `show` (fiche + liste de ses produits avec stock).
4. Exposer les URL `/fournisseurs` et `/fournisseurs/<id>` dans `UrlMappings` ; une URL avec un id non numérique doit donner la page 404.
5. Écrire les vues `fournisseur/index.gsp` et `fournisseur/show.gsp` avec le layout `main` ; ajouter l'entrée « Fournisseurs » au menu.
6. Afficher sur la fiche fournisseur le nombre de produits en rupture (stock = 0), calculé par une requête GORM et non par une boucle dans la vue.
7. Externaliser tous les libellés dans `messages_fr.properties`.

## Critères d'acceptation

- [ ] `/fournisseurs` liste les 3 fournisseurs du jeu d'essai, triés par raison sociale.
- [ ] `/fournisseurs/3` affiche Électro Distribution et ses 3 produits.
- [ ] `/fournisseurs/abc` renvoie la page 404 de l'application.
- [ ] La fiche de Outillage du Nord indique 1 produit en rupture (Gants de protection T9).
- [ ] Supprimer un fournisseur ne doit pas pouvoir supprimer ses produits : le choix de l'étape 2 le garantit.
- [ ] Aucune requête par produit dans la boucle de la vue (vérifier avec `logSql: true`, noter le nombre de requêtes dans le RENDU).
- [ ] `./gradlew check` passe.

## Git

Au moins 5 commits, par exemple : mapping de la domain class ; association produit ; contrôleur et URL ; vues ; libellés ; RENDU.

## Pour aller plus loin

Ajouter sur la liste des produits (`/produit/index`) une colonne « Fournisseur » avec un lien vers sa fiche, sans provoquer de N+1.
