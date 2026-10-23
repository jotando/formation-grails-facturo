package facturo

/**
 * Ligne de facture. Prix, TVA et remise sont recopiés au moment de l'ajout (historisation).
 * montantHt / montantTtc sont calculés PAR LA BASE (fonctions SQL) via "formula" : lecture seule.
 */
class LigneFacture {

    Produit produit
    Integer quantite
    BigDecimal prixUnitaireHt
    BigDecimal tauxTva
    BigDecimal remisePct = 0

    BigDecimal montantHt      // formula : jamais écrit
    BigDecimal montantTtc     // formula : jamais écrit

    static belongsTo = [facture: Facture]

    static constraints = {
        quantite       min: 1
        prixUnitaireHt min: 0.0, scale: 2
        tauxTva        min: 0.0, max: 100.0
        remisePct      min: 0.0, max: 100.0
        montantHt      nullable: true, bindable: false
        montantTtc     nullable: true, bindable: false
    }

    static mapping = {
        produit    fetch: 'join'
        montantHt  formula: 'f_montant_ligne_ht(quantite, prix_unitaire_ht, remise_pct)'
        montantTtc formula: 'f_montant_ligne_ttc(quantite, prix_unitaire_ht, remise_pct, taux_tva)'
    }
}
