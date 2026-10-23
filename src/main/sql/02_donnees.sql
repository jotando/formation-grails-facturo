-- =====================================================================
-- Facturo - jeu d'essai
-- =====================================================================
SET NAMES utf8mb4;

INSERT INTO client (code, raison_sociale, email, taux_remise, actif) VALUES
  ('ACME',    'Acme Industries',          'compta@acme.example.com',      5.00, TRUE),
  ('BOULON',  'Boulonnerie du Centre',    'achats@boulon.example.com',    0.00, TRUE),
  ('CIMENT',  'Ciments & Mortiers SA',    NULL,                      10.00, TRUE),
  ('DELTA-3', 'Delta Maintenance',        'contact@delta.example.com',    2.50, TRUE),
  ('ECLAIR',  'Éclairage Pro (inactif)',  'info@eclair.example.com',      0.00, FALSE);

-- SIRET valides au sens de la clé de Luhn (utile pour l'exercice 2)
INSERT INTO fournisseur (code, raison_sociale, siret, email, delai_livraison_jours) VALUES
  ('F-VISS',  'Visserie Lyonnaise',   '54756834567143', 'cde@visserie.example.com', 5),
  ('F-OUTIL', 'Outillage du Nord',    '13476182522257', 'cde@outillage.example.com', 10),
  ('F-ELEC',  'Électro Distribution', '54802041817978', NULL, 3);

INSERT INTO produit (reference, libelle, prix_unitaire_ht, taux_tva, stock, fournisseur_id) VALUES
  ('VIS-M6-50',   'Vis M6 x 50 (boîte de 100)',  12.90, 20.00, 120, 1),
  ('ECROU-M6',    'Écrou M6 (boîte de 100)',       6.40, 20.00, 200, 1),
  ('PERC-18V',    'Perceuse sans fil 18 V',      149.00, 20.00,  15, 2),
  ('FORET-SET',   'Coffret de 15 forets',         34.50, 20.00,  40, 2),
  ('CABLE-2.5',   'Câble 2,5 mm² (rouleau 100 m)', 89.00, 20.00,  25, 3),
  ('DISJ-16A',    'Disjoncteur 16 A',              8.75, 20.00,  80, 3),
  ('GUIDE-ELEC',  'Guide de l''installation électrique', 29.00, 5.50, 10, 3),
  ('GANTS-T9',    'Gants de protection T9',        4.20, 20.00,   0, 2);

-- Facture 1 : brouillon avec deux lignes
INSERT INTO facture (client_id, date_facture, statut) VALUES (1, CURDATE(), 'BROUILLON');
INSERT INTO ligne_facture (facture_id, produit_id, quantite, prix_unitaire_ht, taux_tva, remise_pct) VALUES
  (1, 1, 3, 12.90, 20.00, 5.00),
  (1, 3, 1, 149.00, 20.00, 5.00);

-- Facture 2 : émise par la procédure stockée (même chemin que l'application)
INSERT INTO facture (client_id, date_facture, statut) VALUES (3, CURDATE() - INTERVAL 10 DAY, 'BROUILLON');
INSERT INTO ligne_facture (facture_id, produit_id, quantite, prix_unitaire_ht, taux_tva, remise_pct) VALUES
  (2, 5, 2, 89.00, 20.00, 10.00),
  (2, 6, 10, 8.75, 20.00, 10.00),
  (2, 7, 1, 29.00, 5.50, 10.00);
CALL p_emettre_facture(2, @numero);

-- Commandes d'achat (exercices) : statuts variés pour la recherche de l'exercice 6
INSERT INTO commande_achat (numero, fournisseur_id, date_commande, date_livraison_prevue, statut) VALUES
  (NULL,           1, CURDATE(),                     NULL,                          'BROUILLON'),
  (CONCAT('CA-', YEAR(CURDATE()), '-0001'), 2, CURDATE() - INTERVAL 30 DAY,   CURDATE() - INTERVAL 20 DAY,   'RECUE'),
  (CONCAT('CA-', YEAR(CURDATE()), '-0002'), 3, CURDATE() - INTERVAL 12 DAY,   CURDATE() - INTERVAL 9 DAY,    'ENVOYEE'),
  (CONCAT('CA-', YEAR(CURDATE()), '-0003'), 1, CURDATE() - INTERVAL 5 DAY,    CURDATE(),                     'ENVOYEE'),
  (CONCAT('CA-', YEAR(CURDATE()), '-0004'), 2, CURDATE() - INTERVAL 60 DAY,   NULL,                          'ANNULEE');
INSERT INTO ligne_commande_achat (commande_achat_id, produit_id, quantite, prix_achat_ht, quantite_recue) VALUES
  (1, 2, 50, 3.10, NULL),
  (2, 3, 5, 98.00, 5),
  (2, 4, 10, 19.00, 10),
  (3, 5, 10, 61.00, NULL),
  (3, 6, 40, 4.90, NULL),
  (4, 1, 100, 7.20, NULL),
  (5, 8, 200, 1.80, NULL);
