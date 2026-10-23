# Exercice 5 — Envoyer et réceptionner une commande par procédures stockées

| | |
| --- | --- |
| Partie | **AVEC IA** (journal obligatoire) |
| Branche | `<login>/ex05-envoi-reception` |
| Durée indicative | 5 h |
| Notions | B3, S2, S3, C3, G2 |
| Modèle dans le cours | séance 5.4 ; `p_emettre_facture`, `FactureService.emettre`, `EmissionImpossibleException` |

## Contexte

L'envoi d'une commande lui attribue un numéro `CA-AAAA-NNNN` sans trou ni doublon, et une date de livraison prévue. Sa réception augmente le stock des produits. Ces deux opérations écrivent dans plusieurs tables, sous concurrence : elles sont confiées à la base.

## Travail demandé

1. Script `src/main/sql/21_ex05_envoi_reception.sql` :
    - une table `sequence_commande_achat (annee, dernier)`, **initialisée à partir des numéros déjà présents** dans `commande_achat` ;
    - `p_envoyer_commande(IN p_commande_id, OUT p_numero)` : refuse une commande inconnue, non brouillon, vide, ou dont le fournisseur est inactif ; attribue le numéro ; fixe `date_livraison_prevue` = aujourd'hui + délai du fournisseur ; passe à `ENVOYEE` ;
    - `p_receptionner_commande(IN p_commande_id, OUT p_nb_lignes)` : refuse une commande non `ENVOYEE` ; une ligne dont `quantite_recue` est vide est réputée reçue en totalité ; ajoute au stock les quantités reçues **en un seul `UPDATE`** ; passe à `RECUE` avec la date de réception ;
    - codes d'erreur par `SIGNAL SQLSTATE '45000'` : `COMMANDE_INCONNUE`, `COMMANDE_NON_BROUILLON`, `COMMANDE_VIDE`, `FOURNISSEUR_INACTIF`, `COMMANDE_NON_ENVOYEE` ;
    - procédures **participantes** : ni `START TRANSACTION` ni `COMMIT` ; `version = version + 1` sur chaque ligne modifiée.
2. `CommandeAchatService.envoyer(id)` et `receptionner(id)` : flush avant, `Sql.call`, refresh après, traduction en `OperationCommandeException(code)`.
3. Boutons « Envoyer » et « Réceptionner » sur la fiche, visibles selon le statut ; message i18n pour chaque code d'erreur.
4. `src/test/sql/test_21_ex05.sql` : cas nominal et chaque code d'erreur, plus une réception partielle.

## Exigences IA

- Remplir `JOURNAL_IA.md` pendant le travail.
- Au moins un prompt où vous demandez à l'IA de **relire** votre procédure au regard des règles de la séance 5.4, et votre analyse de sa réponse.
- Au moins une erreur de l'IA détectée et corrigée, documentée dans le journal (section 4).

## Critères d'acceptation

Après `./outils/reinit-db.sh` :

- [ ] Envoyer la commande 1 lui attribue `CA-<année>-0005` et une date prévue à J+5 (Visserie Lyonnaise).
- [ ] Réceptionner la commande 3 fait passer le stock de `CABLE-2.5` de 23 à 33 et celui de `DISJ-16A` de 70 à 110.
- [ ] Chaque code d'erreur s'affiche en message lisible, sans erreur 500 ; après une erreur, rien n'a été modifié en base.
- [ ] Une erreur levée après un `save()` Grails dans la même transaction annule aussi ce `save()` (à démontrer dans un test ou dans le RENDU).
- [ ] `./outils/tests-sql.sh` passe.

## Git

Au moins 6 commits, chacun avec `Assisted-by:` quand l'IA y a contribué.
