package facturo

/**
 * Domain class en LECTURE SEULE posée sur la vue SQL v_facture_totaux.
 * Équivalent A1 : @Entity @Immutable @Table(name = "v_facture_totaux").
 */
class FactureTotaux {

    String numero
    StatutFacture statut
    Date dateFacture
    Long clientId
    String raisonSociale
    Integer nbLignes
    BigDecimal totalHt
    BigDecimal totalTtc

    BigDecimal getTotalTva() { (totalTtc ?: 0) - (totalHt ?: 0) }

    static transients = ['totalTva']

    static constraints = {
        numero nullable: true
    }

    static mapping = {
        table 'v_facture_totaux'
        id column: 'facture_id', generator: 'assigned'
        version false                       // une vue n'a pas de colonne version
        dateFacture type: 'date'
        statut enumType: 'string'
    }

    def beforeInsert() { throw new UnsupportedOperationException('v_facture_totaux est une vue en lecture seule') }
    def beforeUpdate() { throw new UnsupportedOperationException('v_facture_totaux est une vue en lecture seule') }
    def beforeDelete() { throw new UnsupportedOperationException('v_facture_totaux est une vue en lecture seule') }
}
