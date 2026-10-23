-- =====================================================================
-- Facturo - objets de calcul de la partie VENTES (code de référence du module 5)
-- Ces objets servent de MODÈLE pour les exercices 4, 5, 7 et 8 (partie ACHATS).
-- DELIMITER est une commande du client mariadb : ce fichier doit être exécuté
-- par le client en ligne de commande (c'est le cas dans le conteneur Docker).
-- =====================================================================

DELIMITER //

-- 1. FONCTIONS ---------------------------------------------------------

-- Montant HT d'une ligne, remise déduite, arrondi au centime
CREATE OR REPLACE FUNCTION f_montant_ligne_ht(p_qte INT, p_pu DECIMAL(12,2), p_remise DECIMAL(5,2))
  RETURNS DECIMAL(12,2)
  DETERMINISTIC
  RETURN ROUND(p_qte * p_pu * (1 - COALESCE(p_remise, 0) / 100), 2) //

-- Montant TTC d'une ligne : la TVA est arrondie ligne par ligne
CREATE OR REPLACE FUNCTION f_montant_ligne_ttc(p_qte INT, p_pu DECIMAL(12,2), p_remise DECIMAL(5,2), p_tva DECIMAL(5,2))
  RETURNS DECIMAL(12,2)
  DETERMINISTIC
  RETURN ROUND(f_montant_ligne_ht(p_qte, p_pu, p_remise) * (1 + p_tva / 100), 2) //

-- Total TTC d'une facture
CREATE OR REPLACE FUNCTION f_total_facture_ttc(p_facture_id BIGINT)
  RETURNS DECIMAL(12,2)
  READS SQL DATA
BEGIN
  DECLARE v_total DECIMAL(12,2);
  SELECT COALESCE(SUM(f_montant_ligne_ttc(quantite, prix_unitaire_ht, remise_pct, taux_tva)), 0)
    INTO v_total
    FROM ligne_facture
   WHERE facture_id = p_facture_id;
  RETURN v_total;
END //

-- 2. VUE ---------------------------------------------------------------

CREATE OR REPLACE VIEW v_facture_totaux AS
SELECT f.id            AS facture_id,
       f.numero,
       f.statut,
       f.date_facture,
       c.id            AS client_id,
       c.raison_sociale,
       COUNT(l.id)     AS nb_lignes,
       COALESCE(SUM(f_montant_ligne_ht(l.quantite, l.prix_unitaire_ht, l.remise_pct)), 0)            AS total_ht,
       COALESCE(SUM(f_montant_ligne_ttc(l.quantite, l.prix_unitaire_ht, l.remise_pct, l.taux_tva)), 0) AS total_ttc
  FROM facture f
  JOIN client c             ON c.id = f.client_id
  LEFT JOIN ligne_facture l ON l.facture_id = f.id
 GROUP BY f.id, f.numero, f.statut, f.date_facture, c.id, c.raison_sociale //

-- 3. PROCÉDURE STOCKÉE -------------------------------------------------
-- Émet une facture : contrôles, numérotation, décrément du stock, changement de statut.
-- PAS de START TRANSACTION / COMMIT : la transaction appartient à l'appelant
-- (FactureService, annoté @Transactional). Une erreur SIGNAL fait annuler l'ensemble.

CREATE OR REPLACE PROCEDURE p_emettre_facture(IN p_facture_id BIGINT, OUT p_numero VARCHAR(20))
  MODIFIES SQL DATA
BEGIN
  DECLARE v_statut VARCHAR(10);
  DECLARE v_annee  INT DEFAULT YEAR(CURDATE());

  SELECT statut INTO v_statut FROM facture WHERE id = p_facture_id FOR UPDATE;

  IF v_statut IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_INCONNUE';
  END IF;
  IF v_statut <> 'BROUILLON' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_DEJA_EMISE';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM ligne_facture WHERE facture_id = p_facture_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_VIDE';
  END IF;
  IF EXISTS (SELECT 1
               FROM ligne_facture l
               JOIN produit p ON p.id = l.produit_id
              WHERE l.facture_id = p_facture_id
              GROUP BY p.id, p.stock
             HAVING SUM(l.quantite) > p.stock) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'STOCK_INSUFFISANT';
  END IF;

  -- verrou de ligne sur l'année : deux émissions simultanées ne peuvent pas obtenir le même numéro
  INSERT INTO sequence_facture (annee, dernier) VALUES (v_annee, 1)
    ON DUPLICATE KEY UPDATE dernier = dernier + 1;
  SELECT CONCAT('FAC-', v_annee, '-', LPAD(dernier, 5, '0')) INTO p_numero
    FROM sequence_facture WHERE annee = v_annee;

  UPDATE produit p
    JOIN (SELECT produit_id, SUM(quantite) AS qte
            FROM ligne_facture WHERE facture_id = p_facture_id
           GROUP BY produit_id) l ON l.produit_id = p.id
     SET p.stock = p.stock - l.qte,
         p.version = p.version + 1;

  UPDATE facture
     SET statut = 'EMISE', numero = p_numero, date_emission = NOW(), version = version + 1
   WHERE id = p_facture_id;
END //

-- 3 bis. PROCÉDURE QUI RENVOIE UN JEU DE RÉSULTATS ----------------------
-- MariaDB n'a pas de fonction « table » : pour un résultat paramétré, on utilise
-- une vue (filtrée par GORM) ou une procédure qui se termine par un SELECT.
-- Appel Grails : new Sql(dataSource).rows('{call p_releve_client(?, ?, ?)}', [clientId, du, au])

CREATE OR REPLACE PROCEDURE p_releve_client(IN p_client_id BIGINT, IN p_du DATE, IN p_au DATE)
  READS SQL DATA
BEGIN
  IF p_au < p_du THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PERIODE_INVALIDE';
  END IF;
  SELECT facture_id, numero, statut, date_facture, total_ht, total_ttc
    FROM v_facture_totaux
   WHERE client_id = p_client_id AND date_facture BETWEEN p_du AND p_au
   ORDER BY date_facture;
END //

-- 4. TRIGGERS ----------------------------------------------------------
-- Une facture qui n'est plus en brouillon est gelée, quel que soit le programme qui écrit.

CREATE OR REPLACE TRIGGER trg_ligne_facture_bi BEFORE INSERT ON ligne_facture FOR EACH ROW
BEGIN
  IF (SELECT statut FROM facture WHERE id = NEW.facture_id) <> 'BROUILLON' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_NON_MODIFIABLE';
  END IF;
END //

CREATE OR REPLACE TRIGGER trg_ligne_facture_bu BEFORE UPDATE ON ligne_facture FOR EACH ROW
BEGIN
  IF (SELECT statut FROM facture WHERE id = OLD.facture_id) <> 'BROUILLON' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_NON_MODIFIABLE';
  END IF;
END //

CREATE OR REPLACE TRIGGER trg_ligne_facture_bd BEFORE DELETE ON ligne_facture FOR EACH ROW
BEGIN
  IF (SELECT statut FROM facture WHERE id = OLD.facture_id) <> 'BROUILLON' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FACTURE_NON_MODIFIABLE';
  END IF;
END //

-- Audit des changements de statut : MODÈLE de l'exercice 7.
-- USER() = compte de connexion (facturo@...) ; CURRENT_USER() renverrait le DEFINER du trigger.
CREATE OR REPLACE TRIGGER trg_facture_au AFTER UPDATE ON facture FOR EACH ROW
BEGIN
  IF NOT (OLD.statut <=> NEW.statut) THEN
    INSERT INTO journal_audit (table_nom, ligne_id, action, ancienne_valeur, nouvelle_valeur, utilisateur_sql)
    VALUES ('facture', NEW.id, 'STATUT', OLD.statut, NEW.statut, USER());
  END IF;
END //

DELIMITER ;
