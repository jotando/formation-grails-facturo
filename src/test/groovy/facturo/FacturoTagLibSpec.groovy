package facturo

import grails.testing.web.taglib.TagLibUnitTest
import spock.lang.Specification

class FacturoTagLibSpec extends Specification implements TagLibUnitTest<FacturoTagLib> {

    void "montant au format français"() {
        expect: 'espaces normalisés pour ne pas dépendre du type d’espace insécable'
        applyTemplate('<fac:montant valeur="${v}"/>', [v: 1234.5G]).replaceAll(/[\s\u00A0\u202F]/, ' ') == '1 234,50 €'
    }

    void "statut échappé et traduit"() {
        given:
        messageSource.addMessage('statut.EMISE', request.locale, 'Émise')

        expect:
        applyTemplate('<fac:statut valeur="${s}"/>', [s: StatutFacture.EMISE]) ==
                '<span class="badge badge-statut statut-emise">Émise</span>'
    }
}
