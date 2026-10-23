package facturo

import grails.validation.ValidationException

import static org.springframework.http.HttpStatus.NOT_FOUND

/** Contrôleur mince : liaison des paramètres, appel du service, choix de la réponse. */
class ClientController {

    ClientService clientService                    // injecté par son nom

    static allowedMethods = [save: 'POST', update: 'PUT']

    def index() {
        [clients: Client.findAllByActif(true)]     // dynamic finder ; vue : views/client/index.gsp
    }

    def show(Long id) {
        Client client = clientService.get(id)
        if (!client) {
            notFound()
            return
        }
        [client  : client,
         factures: FactureTotaux.findAllByClientId(client.id, [sort: 'dateFacture', order: 'desc'])]
    }

    def create() {
        [client: new Client(params)]
    }

    def save(Client client) {                      // params -> nouvel objet lié
        try {
            clientService.save(client)
        } catch (ValidationException e) {
            render view: 'create', model: [client: client]
            return
        }
        flash.message = message(code: 'client.cree', args: [client.code])
        redirect action: 'show', id: client.id
    }

    def edit(Long id) {
        Client client = clientService.get(id)
        if (!client) {
            notFound()
            return
        }
        [client: client]
    }

    def update(Client client) {                    // id présent -> instance chargée PUIS liée
        if (!client) {
            notFound()
            return
        }
        try {
            clientService.save(client)
        } catch (ValidationException e) {
            render view: 'edit', model: [client: client]
            return
        }
        flash.message = message(code: 'client.modifie', args: [client.code])
        redirect action: 'show', id: client.id
    }

    protected void notFound() {
        render status: NOT_FOUND, view: '/notFound'
    }
}
