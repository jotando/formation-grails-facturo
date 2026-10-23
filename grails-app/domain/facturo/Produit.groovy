package facturo

/**
 * Produit vendu. La colonne fournisseur_id existe en base mais n'est pas encore mappée :
 * c'est l'objet de l'exercice 1 (association Produit -> Fournisseur).
 */
class Produit {

    String reference
    String libelle
    BigDecimal prixUnitaireHt
    BigDecimal tauxTva = 20.0
    Integer stock = 0

    static constraints = {
        reference      blank: false, maxSize: 30, unique: true
        libelle        blank: false, maxSize: 120
        prixUnitaireHt min: 0.0, scale: 2
        tauxTva        min: 0.0, max: 100.0, scale: 2
        stock          min: 0, bindable: false     // le stock ne bouge que par procédure stockée
    }

    static mapping = {
        sort 'libelle'
    }

    String toString() { "${reference} - ${libelle}" }
}
