package facturo

/**
 * Client facturé. Table existante "client" (src/main/sql/00_schema.sql).
 * Équivalent A1 : @Entity Client + ClientRepository (ici remplacé par ClientService, un GORM Data Service).
 */
class Client {

    String code
    String raisonSociale          // -> colonne raison_sociale (stratégie de nommage par défaut)
    String email
    BigDecimal tauxRemise = 0
    Boolean actif = true
    Date dateCreated              // nom réservé : rempli par GORM à l'insertion (autoTimestamp)

    static constraints = {
        code          blank: false, size: 3..20, matches: /[A-Z0-9-]+/, unique: true
        raisonSociale blank: false, maxSize: 120
        email         nullable: true, email: true, maxSize: 120
        tauxRemise    min: 0.0, max: 30.0, scale: 2
        dateCreated   nullable: true, bindable: false
    }

    static mapping = {
        table 'client'
        dateCreated column: 'date_creation'
        sort 'raisonSociale'
    }

    String toString() { "${code} - ${raisonSociale}" }
}
