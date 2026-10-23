-- =====================================================================
-- Facturo - schéma de la base (source de vérité : GORM est en dbCreate: none)
-- Exécuté automatiquement par le conteneur MariaDB à sa première création.
-- Les scripts sont exécutés par ordre alphabétique : 00_, 01_, 02_, puis 2x_ (exercices).
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- Partie VENTES (utilisée par les tutoriels, code de référence fourni)
-- ---------------------------------------------------------------------

CREATE TABLE client (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  version        BIGINT       NOT NULL DEFAULT 0,
  code           VARCHAR(20)  NOT NULL,
  raison_sociale VARCHAR(120) NOT NULL,
  email          VARCHAR(120),
  taux_remise    DECIMAL(5,2) NOT NULL DEFAULT 0,
  actif          BOOLEAN      NOT NULL DEFAULT TRUE,
  date_creation  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uk_client_code UNIQUE (code),
  CONSTRAINT ck_client_remise CHECK (taux_remise BETWEEN 0 AND 30)
) ENGINE = InnoDB;

CREATE TABLE fournisseur (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  version        BIGINT       NOT NULL DEFAULT 0,
  code           VARCHAR(20)  NOT NULL,
  raison_sociale VARCHAR(120) NOT NULL,
  siret          CHAR(14)     NOT NULL,
  email          VARCHAR(120),
  delai_livraison_jours INT   NOT NULL DEFAULT 7,
  actif          BOOLEAN      NOT NULL DEFAULT TRUE,
  motif_desactivation VARCHAR(200),
  date_creation  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uk_fournisseur_code UNIQUE (code),
  CONSTRAINT uk_fournisseur_siret UNIQUE (siret)
) ENGINE = InnoDB;

CREATE TABLE produit (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  version          BIGINT        NOT NULL DEFAULT 0,
  reference        VARCHAR(30)   NOT NULL,
  libelle          VARCHAR(120)  NOT NULL,
  prix_unitaire_ht DECIMAL(12,2) NOT NULL,
  taux_tva         DECIMAL(5,2)  NOT NULL DEFAULT 20.00,
  stock            INT           NOT NULL DEFAULT 0,
  fournisseur_id   BIGINT,
  CONSTRAINT uk_produit_reference UNIQUE (reference),
  CONSTRAINT fk_produit_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseur (id),
  CONSTRAINT ck_produit_stock CHECK (stock >= 0)
) ENGINE = InnoDB;

CREATE TABLE facture (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  version       BIGINT      NOT NULL DEFAULT 0,
  numero        VARCHAR(20),
  client_id     BIGINT      NOT NULL,
  date_facture  DATE        NOT NULL,
  statut        VARCHAR(10) NOT NULL DEFAULT 'BROUILLON',
  date_emission DATETIME,
  CONSTRAINT uk_facture_numero UNIQUE (numero),
  CONSTRAINT fk_facture_client FOREIGN KEY (client_id) REFERENCES client (id),
  CONSTRAINT ck_facture_statut CHECK (statut IN ('BROUILLON', 'EMISE', 'PAYEE', 'ANNULEE'))
) ENGINE = InnoDB;

CREATE TABLE ligne_facture (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  version          BIGINT        NOT NULL DEFAULT 0,
  facture_id       BIGINT        NOT NULL,
  produit_id       BIGINT        NOT NULL,
  quantite         INT           NOT NULL,
  prix_unitaire_ht DECIMAL(12,2) NOT NULL,
  taux_tva         DECIMAL(5,2)  NOT NULL,
  remise_pct       DECIMAL(5,2)  NOT NULL DEFAULT 0,
  CONSTRAINT fk_ligne_facture_facture FOREIGN KEY (facture_id) REFERENCES facture (id) ON DELETE CASCADE,
  CONSTRAINT fk_ligne_facture_produit FOREIGN KEY (produit_id) REFERENCES produit (id),
  CONSTRAINT ck_ligne_facture_qte CHECK (quantite > 0)
) ENGINE = InnoDB;

-- Compteur de numérotation des factures, une ligne par année
CREATE TABLE sequence_facture (
  annee   INT PRIMARY KEY,
  dernier INT NOT NULL
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Partie ACHATS (utilisée par les exercices : aucun code Grails fourni)
-- ---------------------------------------------------------------------

CREATE TABLE commande_achat (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  version         BIGINT      NOT NULL DEFAULT 0,
  numero          VARCHAR(20),
  fournisseur_id  BIGINT      NOT NULL,
  date_commande   DATE        NOT NULL,
  date_livraison_prevue DATE,
  statut          VARCHAR(12) NOT NULL DEFAULT 'BROUILLON',
  date_reception  DATETIME,
  CONSTRAINT uk_commande_achat_numero UNIQUE (numero),
  CONSTRAINT fk_commande_achat_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseur (id),
  CONSTRAINT ck_commande_achat_statut CHECK (statut IN ('BROUILLON', 'ENVOYEE', 'RECUE', 'ANNULEE'))
) ENGINE = InnoDB;

CREATE TABLE ligne_commande_achat (
  id                BIGINT AUTO_INCREMENT PRIMARY KEY,
  version           BIGINT        NOT NULL DEFAULT 0,
  commande_achat_id BIGINT        NOT NULL,
  produit_id        BIGINT        NOT NULL,
  quantite          INT           NOT NULL,
  prix_achat_ht     DECIMAL(12,2) NOT NULL,
  quantite_recue    INT,
  CONSTRAINT fk_lca_commande FOREIGN KEY (commande_achat_id) REFERENCES commande_achat (id) ON DELETE CASCADE,
  CONSTRAINT fk_lca_produit FOREIGN KEY (produit_id) REFERENCES produit (id),
  CONSTRAINT ck_lca_qte CHECK (quantite > 0)
) ENGINE = InnoDB;

-- Journal alimenté par triggers (exercice 7)
CREATE TABLE journal_audit (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_nom   VARCHAR(40)  NOT NULL,
  ligne_id    BIGINT       NOT NULL,
  action      VARCHAR(20)  NOT NULL,
  ancienne_valeur VARCHAR(200),
  nouvelle_valeur VARCHAR(200),
  utilisateur_sql VARCHAR(100) NOT NULL,
  date_action DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX ix_journal_table_ligne (table_nom, ligne_id)
) ENGINE = InnoDB;
