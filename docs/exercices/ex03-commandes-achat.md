# Exercice 3 — Saisir une commande d'achat

| | |
| --- | --- |
| Partie | **SANS IA** |
| Branche | `<login>/ex03-commandes-achat` |
| Durée indicative | 5 h |
| Notions | O3, S2, S3, S4, G3, C3 |
| Modèle dans le cours | module 3 ; `Facture`, `LigneFacture`, `FactureService`, `facture/_ligne.gsp` |

## Contexte

Un acheteur prépare une commande pour un fournisseur actif, ligne par ligne. Tant qu'elle est en `BROUILLON`, il peut ajouter et supprimer des lignes. L'envoi et la réception seront traités par procédure stockée à l'exercice 5 : **ne pas les coder ici**.

## Travail demandé

1. Domain classes `CommandeAchat` et `LigneCommandeAchat` sur les tables existantes, enum `StatutCommande` (`BROUILLON`, `ENVOYEE`, `RECUE`, `ANNULEE`). Le fournisseur est une référence simple ; les lignes sont une composition.
2. Un service `CommandeAchatService` transactionnel :
    - `creerBrouillon(fournisseurId)` : refuse un fournisseur inactif ;
    - `ajouterLigne(commandeId, produitId, quantite, prixAchatHt)` : si le produit est déjà dans la commande, **cumuler la quantité** sur la ligne existante au lieu d'en créer une seconde ;
    - `supprimerLigne(commandeId, ligneId)` ;
    - toute modification d'une commande non `BROUILLON` lève `CommandeNonModifiableException` (`RuntimeException`) ;
    - lectures en `readOnly`.
3. Le contrôleur et les vues : liste des commandes, création, fiche avec ses lignes affichées par un template `_ligne.gsp`, formulaire d'ajout limité aux produits **de ce fournisseur**.
4. Charger la fiche d'une commande sans N+1 (lignes et produits).
5. Tests Spock du service (`DataTest`) : création, cumul de quantité, refus sur commande envoyée, refus d'un fournisseur inactif.

## Critères d'acceptation

- [ ] La commande brouillon du jeu d'essai (id 1) affiche sa ligne Écrou M6.
- [ ] Ajouter deux fois le même produit donne une seule ligne avec la quantité cumulée.
- [ ] Sur une commande `ENVOYEE` (id 3), le formulaire d'ajout n'apparaît pas, et un `POST` forgé vers `ajouterLigne` est refusé avec un message.
- [ ] Une quantité nulle ou un prix négatif sont refusés avec un message, sans erreur 500.
- [ ] Supprimer une commande brouillon supprime ses lignes ; aucun fournisseur n'est supprimé.
- [ ] Les 4 tests Spock passent.

## Git

Au moins 6 commits ; le cumul de quantité dans un commit à part, avec son test.

## Pour aller plus loin

Proposer par défaut, dans le formulaire, le dernier prix d'achat payé pour ce produit chez ce fournisseur.
