package facturo

/**
 * Facture de vente.
 * - Client : simple référence (PAS de belongsTo : supprimer un client ne doit pas supprimer ses factures).
 * - Lignes : composition (LigneFacture belongsTo Facture), supprimées avec la facture.
 * - numero, statut, dateEmission : écrits uniquement par la procédure p_emettre_facture.
 */
class Facture {

    String numero
    Client client
    Date dateFacture = new Date()
    StatutFacture statut = StatutFacture.BROUILLON
    Date dateEmission

    static hasMany = [lignes: LigneFacture]

    static transients = ['modifiable']

    static constraints = {
        numero       nullable: true, unique: true, bindable: false
        statut       bindable: false
        dateEmission nullable: true, bindable: false
    }

    static mapping = {
        dateFacture type: 'date'
        statut enumType: 'string'
        lignes cascade: 'all-delete-orphan', sort: 'id'
    }

    boolean isModifiable() { statut == StatutFacture.BROUILLON }
}
