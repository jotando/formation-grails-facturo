-- =====================================================================
-- Tests SQL des objets de la partie VENTES : MODÈLE pour vos tests (exercices 4, 5, 7, 8).
-- Principe : chaque test est une assertion ; si elle est fausse, SIGNAL arrête le script.
-- Les assertions s'exécutent dans une transaction annulée à la fin : la base n'est pas modifiée.
-- ATTENTION : aucun ordre DDL (CREATE, DROP, ALTER) entre START TRANSACTION et ROLLBACK :
-- il validerait implicitement la transaction (même piège que START TRANSACTION dans une procédure).
-- =====================================================================
DROP PROCEDURE IF EXISTS assert_egal;
DELIMITER //
CREATE PROCEDURE assert_egal(IN p_nom VARCHAR(100), IN p_obtenu VARCHAR(200), IN p_attendu VARCHAR(200))
BEGIN
  IF NOT (p_obtenu <=> p_attendu) THEN
    SET @msg = LEFT(CONCAT(p_nom, ' : obtenu ', COALESCE(p_obtenu, 'NULL'), ', attendu ', COALESCE(p_attendu, 'NULL')), 128);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
  END IF;
END //
DELIMITER ;


-- Procédures d'aide : créées AVANT la transaction (DDL = commit implicite)
DROP TEMPORARY TABLE IF EXISTS t_erreur;
CREATE TEMPORARY TABLE t_erreur (msg VARCHAR(128));
DELIMITER //
CREATE OR REPLACE PROCEDURE tst_emettre(IN p_id BIGINT)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
  BEGIN
    GET DIAGNOSTICS CONDITION 1 @m = MESSAGE_TEXT;
    INSERT INTO t_erreur VALUES (@m);
  END;
  CALL p_emettre_facture(p_id, @n);
END //
DELIMITER ;
DELIMITER //
CREATE OR REPLACE PROCEDURE tst_ajout_ligne(IN p_id BIGINT)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
  BEGIN
    GET DIAGNOSTICS CONDITION 1 @m = MESSAGE_TEXT;
    INSERT INTO t_erreur VALUES (@m);
  END;
  INSERT INTO ligne_facture (facture_id, produit_id, quantite, prix_unitaire_ht, taux_tva) VALUES (p_id, 1, 1, 1, 20);
END //
DELIMITER ;

START TRANSACTION;

-- Fonctions : valeurs calculées à la main
CALL assert_egal('montant HT avec remise', f_montant_ligne_ht(3, 12.90, 5), '36.77');
CALL assert_egal('montant HT sans remise', f_montant_ligne_ht(2, 10.00, NULL), '20.00');
CALL assert_egal('montant TTC TVA 5,5', f_montant_ligne_ttc(1, 29.00, 10, 5.5), '27.54');
CALL assert_egal('total facture sans ligne', f_total_facture_ttc(-1), '0.00');

-- Vue : cohérence avec la fonction
CALL assert_egal('vue = fonction',
  (SELECT total_ttc FROM v_facture_totaux WHERE facture_id = 1), f_total_facture_ttc(1));

-- Procédure : cas d'erreur métier, attrapés pour vérifier le message
CALL tst_emettre(2);                                   -- facture déjà émise par le jeu d'essai
CALL assert_egal('ré-émission refusée', (SELECT msg FROM t_erreur LIMIT 1), 'FACTURE_DEJA_EMISE');

-- Procédure : cas nominal
CALL p_emettre_facture(1, @numero);
CALL assert_egal('statut après émission', (SELECT statut FROM facture WHERE id = 1), 'EMISE');
CALL assert_egal('numéro attribué', @numero LIKE CONCAT('FAC-', YEAR(CURDATE()), '-%'), '1');

-- Trigger : une facture émise est gelée
DELETE FROM t_erreur;
CALL tst_ajout_ligne(1);
CALL assert_egal('ligne refusée sur facture émise', (SELECT msg FROM t_erreur LIMIT 1), 'FACTURE_NON_MODIFIABLE');

-- Trigger d'audit
CALL assert_egal('audit du statut',
  (SELECT nouvelle_valeur FROM journal_audit WHERE table_nom = 'facture' AND ligne_id = 1 ORDER BY id DESC LIMIT 1), 'EMISE');

ROLLBACK;
DROP PROCEDURE IF EXISTS tst_emettre;
DROP PROCEDURE IF EXISTS tst_ajout_ligne;
DROP PROCEDURE IF EXISTS assert_egal;
SELECT 'test_01_routines_ventes : OK' AS resultat;
