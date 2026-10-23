package facturo

import grails.databinding.BindingFormat
import grails.validation.Validateable

/** Critères de recherche des factures (tous optionnels). Équivalent A1 : un DTO de formulaire. */
class RechercheFactureCommand implements Validateable {

    Long clientId
    StatutFacture statut

    @BindingFormat('yyyy-MM-dd')
    Date du

    @BindingFormat('yyyy-MM-dd')
    Date au

    static constraints = {
        clientId nullable: true
        statut   nullable: true
        du       nullable: true
        au       nullable: true, validator: { val, obj -> !val || !obj.du || !val.before(obj.du) ?: 'avant.du' }
    }
}
