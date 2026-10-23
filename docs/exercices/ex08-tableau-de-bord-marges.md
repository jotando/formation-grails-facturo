# Exercice 8 — Intégration : tableau de bord des marges

| | |
| --- | --- |
| Partie | **AVEC IA** (journal obligatoire) |
| Branche | `<login>/ex08-tableau-de-bord` |
| Durée indicative | 6 h |
| Notions | toutes : B1–B4, O1–O4, S1–S4, C1–C4, G1–G4 (mise en commun) |
| Modèle dans le cours | séance 5.6 (arbre de décision, atelier remise fidélité) |

## Contexte

La direction veut, pour une période choisie, la marge par produit : chiffre d'affaires HT vendu, coût d'achat, marge et taux de marge, avec les produits à marge négative signalés. Vous choisissez où vit chaque morceau du calcul, et vous le justifiez.

## Définitions

- **CA HT vendu** : somme des montants HT des lignes de factures `EMISE` ou `PAYEE` dont la date est dans la période.
- **Coût d'achat moyen** d'un produit : moyenne des prix d'achat pondérée par les quantités reçues, sur les commandes `RECUE`. Inconnu si le produit n'a jamais été reçu : il est alors affiché « coût inconnu », jamais 0.
- **Marge HT** = CA HT vendu − quantité vendue × coût d'achat moyen.
- **Taux de marge** = marge HT / CA HT vendu.

## Travail demandé

1. Découper le besoin en morceaux et faire descendre chacun dans l'arbre de décision de la séance 5.6. Le tableau de décision est la **première** section de votre RENDU, rédigée avant le code (premier commit).
2. Écrire le SQL dans `src/main/sql/24_ex08_marges.sql`, avec ses tests `src/test/sql/test_24_ex08.sql` : jeu de données inséré dans la transaction de test, résultats attendus calculés à la main.
3. Un service `TableauDeBordService` : aucun calcul de montant en Groovy, seulement l'orchestration et la mise en forme.
4. Une page `/tableau-de-bord` : choix de la période, tableau des marges triable, top 5 des marges, alerte des marges négatives ; un template par bloc ; un nouveau tag `<fac:pourcentage>`.
5. Des tests Spock pour le contrôleur (période invalide) et les tags.

## Exigences IA

- Journal IA rempli. Section 4 : au moins une proposition de l'IA rejetée parce qu'elle contredisait l'arbre de décision (par exemple, une fonction qui lit des tables appelée ligne par ligne), avec votre raisonnement.

## Critères d'acceptation

Après `./outils/reinit-db.sh`, émettez la facture 1 depuis l'application, puis affichez l'année en cours :

- [ ] `PERC-18V` : CA HT 141,55 €, coût moyen 98,00 €, marge 43,55 €, taux 30,77 %.
- [ ] `VIS-M6-50` apparaît avec « coût inconnu ».
- [ ] Une période inversée affiche un message, sans erreur 500.
- [ ] La page s'affiche en un nombre de requêtes indépendant du nombre de produits (noter le nombre dans le RENDU).
- [ ] Le RENDU justifie chaque objet SQL par une question de l'arbre de décision.
- [ ] `./gradlew check` et `./outils/tests-sql.sh` passent.
