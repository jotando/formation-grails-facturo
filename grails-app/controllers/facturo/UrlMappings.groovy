package facturo

class UrlMappings {

    static mappings = {
        // URL lisibles (équivalent des @GetMapping de A1, mais centralisées)
        "/factures"(controller: 'facture', action: 'recherche')
        "/factures/recherche"(controller: 'facture', action: 'recherche')
        "/factures/$id"(controller: 'facture', action: 'show') {
            constraints { id matches: /\d+/ }
        }

        // Règle par convention : /<contrôleur>/<action>/<id>
        "/$controller/$action?/$id?(.$format)?" {
            constraints {
            }
        }

        "/"(controller: 'client', action: 'index')
        "500"(view: '/error')
        "404"(view: '/notFound')
    }
}
