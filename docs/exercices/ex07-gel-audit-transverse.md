# Exercice 7 — Geler, auditer et factoriser

| | |
| --- | --- |
| Partie | **AVEC IA** (journal obligatoire) |
| Branche | `<login>/ex07-gel-audit` |
| Durée indicative | 5 h |
| Notions | B4, C4, G4, O1, G3 |
| Modèle dans le cours | séance 5.5 et module 6 ; `trg_ligne_facture_*`, `trg_facture_au`, `FactureVerrouInterceptor`, `FacturoTagLib` |

## Contexte

Une commande envoyée ne doit plus changer, y compris par un script SQL, **à une exception près** : la saisie des quantités reçues avant réception. Chaque changement de statut doit être tracé.

## Travail demandé

1. Script `src/main/sql/23_ex07_gel_audit.sql` :
    - contrainte déclarative : `quantite_recue` comprise entre 0 et `quantite` ;
    - triggers `BEFORE INSERT / UPDATE / DELETE` sur `ligne_commande_achat` : en `BROUILLON` tout est permis ; en `ENVOYEE` seule `quantite_recue` peut changer ; ensuite plus rien ;
    - trigger `AFTER UPDATE` sur `commande_achat` qui journalise tout changement de statut dans `journal_audit` avec le compte de connexion.
2. `CommandeVerrouInterceptor` : bloque les actions d'édition d'une commande non brouillon, avec un message i18n (rappel : pas de `message()` dans un intercepteur).
3. TagLib : `<fac:statut>` doit accepter aussi les statuts de commande ; nouveau tag `<fac:retard commande="${c}"/>`, testé en Spock.
4. Domain class `JournalAudit` en lecture seule et page `/achats/audit`, paginée, filtrable par table et par identifiant ; lien « Historique » depuis la fiche d'une commande.

## Exigences IA

- Journal IA rempli. Expliquez comment vous avez vérifié que la réception de l'exercice 5 fonctionne encore après l'ajout des triggers : c'est le piège principal de l'exercice.

## Critères d'acceptation

Après `./outils/reinit-db.sh` :

- [ ] `INSERT INTO ligne_commande_achat …` sur la commande 3 (envoyée), lancé depuis le client SQL, est refusé avec un code métier.
- [ ] Modifier `quantite_recue` de la commande 3 est accepté ; modifier sa `quantite` est refusé.
- [ ] Réceptionner la commande 3 (exercice 5) fonctionne toujours.
- [ ] Envoyer puis réceptionner la commande 1 produit 2 lignes d'audit, avec le compte `facturo`.
- [ ] Un `POST` forgé vers une action d'édition d'une commande envoyée est redirigé avec un message.
- [ ] Les tests SQL et Spock passent.

## Pour aller plus loin

Journaliser l'utilisateur applicatif et non seulement le compte SQL : positionner `@utilisateur_app` depuis le service, dans la même transaction, et le lire dans le trigger. Expliquer pourquoi le faire hors transaction serait faux avec un pool de connexions.
