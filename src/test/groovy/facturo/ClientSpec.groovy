package facturo

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification
import spock.lang.Unroll

/** Test unitaire des contraintes : exécuté sans base (GORM en mémoire). Équivalent A1 : test Bean Validation. */
class ClientSpec extends Specification implements DomainUnitTest<Client> {

    @Unroll
    void "code '#code' valide : #attendu"() {
        expect:
        new Client(code: code, raisonSociale: 'X').validate(['code']) == attendu

        where:
        code          | attendu
        'ACME'        | true
        'DELTA-3'     | true
        'ab'          | false   // trop court + minuscules
        'acme'        | false   // minuscules
        ''            | false
        'A' * 21      | false   // trop long
    }

    void "la remise est bornée entre 0 et 30 %"() {
        expect:
        !new Client(code: 'TEST', raisonSociale: 'X', tauxRemise: 30.01).validate(['tauxRemise'])
        !new Client(code: 'TEST', raisonSociale: 'X', tauxRemise: -1).validate(['tauxRemise'])
        new Client(code: 'TEST', raisonSociale: 'X', tauxRemise: 12.5).validate(['tauxRemise'])
    }
}
