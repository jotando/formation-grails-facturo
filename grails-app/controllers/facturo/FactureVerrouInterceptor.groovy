package facturo

import org.springframework.context.MessageSource
import org.springframework.web.servlet.support.RequestContextUtils

/**
 * Interdit les actions d'édition sur une facture qui n'est plus en brouillon.
 * Défense en profondeur : interceptor (message propre) > service (exception) > trigger SQL.
 * Attention : un interceptor Grails 3.3 n'a PAS la méthode message() des contrôleurs ;
 * on passe par le MessageSource injecté.
 */
class FactureVerrouInterceptor {

    FactureService factureService
    MessageSource messageSource

    FactureVerrouInterceptor() {
        match(controller: 'facture', action: ~/(ajouterLigne|supprimerLigne)/)
    }

    boolean before() {
        Long id = params.long('id')
        if (id && !factureService.estModifiable(id)) {
            flash.erreur = messageSource.getMessage('facture.non.modifiable', [id] as Object[],
                    RequestContextUtils.getLocale(request))
            redirect controller: 'facture', action: 'show', id: id
            return false                              // l'action n'est pas exécutée
        }
        true
    }
}
