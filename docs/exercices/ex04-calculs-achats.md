# Exercice 4 — Calculer les montants des commandes en base

| | |
| --- | --- |
| Partie | **SANS IA** |
| Branche | `<login>/ex04-calculs-achats` |
| Durée indicative | 4 h |
| Notions | B1, B2, O1, O4 |
| Modèle dans le cours | séances 5.1, 5.2, 5.3 ; `f_montant_ligne_*`, `v_facture_totaux`, `FactureTotaux`, `test_01_routines_ventes.sql` |

## Contexte

Les acheteurs veulent voir les montants HT, TVA et TTC de chaque ligne et de chaque commande, dans la fiche et dans la liste. La TVA d'achat est celle du produit. Ces calculs doivent être faits **par la base**.

## Travail demandé

1. Créer `src/main/sql/20_ex04_achats_calculs.sql` (rejouable : `CREATE OR REPLACE`) contenant :
    - une fonction pure `f_montant_achat_ht(quantite, prix_achat_ht)` ;
    - une fonction pure `f_montant_achat_ttc(quantite, prix_achat_ht, taux_tva)` qui réutilise la précédente ;
    - une vue `v_commande_totaux` : id de commande, numéro, statut, dates, fournisseur (id et raison sociale), nombre de lignes, total HT, total TTC. Une commande sans ligne apparaît à 0,00 €.
2. Exposer `montantHt` et `montantTtc` sur `LigneCommandeAchat` par `formula`.
3. Créer la domain class `CommandeTotaux` en lecture seule sur la vue ; la liste des commandes l'utilise.
4. Créer `src/test/sql/test_20_ex04.sql` sur le modèle de `test_01_routines_ventes.sql` : au moins 6 assertions, dont une commande sans ligne et une ligne à TVA 5,5 %.
5. Dans le RENDU : le résultat d'`EXPLAIN SELECT * FROM v_commande_totaux WHERE fournisseur_id = 2`, et votre lecture de ce plan en deux phrases.

## Critères d'acceptation

- [ ] La commande 2 du jeu d'essai affiche un total HT de 680,00 €.
- [ ] La liste des commandes affiche les totaux de chacune en une seule requête SQL (vérifier avec `logSql`).
- [ ] Toute tentative d'écriture sur `CommandeTotaux` lève une exception explicite.
- [ ] `./outils/reinit-db.sh` puis `./outils/tests-sql.sh` passent.
- [ ] Aucun calcul de montant en Groovy, ni dans les GSP (l'affichage formate, il ne calcule pas).

## Git

Au moins 5 commits ; le SQL et ses tests dans des commits distincts du code Grails.

## Pour aller plus loin

Ajouter à la vue une colonne `en_retard` (`CASE WHEN`) vraie pour une commande `ENVOYEE` dont la date de livraison prévue est passée. Elle servira à l'exercice 6.
