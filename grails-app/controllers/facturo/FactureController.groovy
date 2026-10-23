package facturo

import grails.validation.ValidationException

import static org.springframework.http.HttpStatus.NOT_FOUND

class FactureController {

    FactureService factureService

    static allowedMethods = [save: 'POST', ajouterLigne: 'POST', supprimerLigne: 'POST', emettre: 'POST']

    def recherche(RechercheFactureCommand cmd) {
        params.max = Math.min(params.int('max') ?: 10, 100)        // toujours borner max
        Map pagination = [max   : params.max,
                          offset: params.int('offset') ?: 0,
                          sort  : params.sort ?: 'dateFacture',
                          order : params.order ?: 'desc']
        Map resultat = cmd.hasErrors() ? [factures: [], total: 0] : factureService.rechercher(cmd, pagination)
        resultat + [cmd: cmd, clients: Client.list()]
    }

    def show(Long id) {
        Facture facture = factureService.detail(id)
        if (!facture) {
            render status: NOT_FOUND, view: '/notFound'
            return
        }
        [facture : facture,
         totaux  : FactureTotaux.get(id),
         produits: facture.modifiable ? Produit.list() : []]
    }

    def create() {
        [clients: Client.findAllByActif(true)]
    }

    def save(Long clientId) {
        try {
            Facture facture = factureService.creerBrouillon(clientId)
            flash.message = message(code: 'facture.creee')
            redirect action: 'show', id: facture.id
        } catch (IllegalArgumentException e) {
            flash.erreur = message(code: 'facture.client.invalide')
            redirect action: 'create'
        }
    }

    def ajouterLigne(Long id, Long produitId, Integer quantite) {
        try {
            factureService.ajouterLigne(id, produitId, quantite)
            flash.message = message(code: 'ligne.ajoutee')
        } catch (ValidationException | IllegalArgumentException e) {
            flash.erreur = message(code: 'ligne.invalide')
        } catch (FactureNonModifiableException e) {
            flash.erreur = message(code: 'facture.non.modifiable', args: [id])
        }
        redirect action: 'show', id: id
    }

    def supprimerLigne(Long id, Long ligneId) {
        try {
            factureService.supprimerLigne(id, ligneId)
            flash.message = message(code: 'ligne.supprimee')
        } catch (FactureNonModifiableException e) {
            flash.erreur = message(code: 'facture.non.modifiable', args: [id])
        }
        redirect action: 'show', id: id
    }

    def emettre(Long id) {
        try {
            String numero = factureService.emettre(id)
            flash.message = message(code: 'facture.emise', args: [numero])
        } catch (EmissionImpossibleException e) {
            flash.erreur = message(code: "facture.emission.${e.code}")
        }
        redirect action: 'show', id: id
    }
}
