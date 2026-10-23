package facturo

import grails.testing.gorm.DataTest
import grails.testing.services.ServiceUnitTest
import spock.lang.Specification

import java.sql.SQLException

/**
 * Test unitaire du service avec GORM en mémoire.
 * Limite : les objets SQL (formula, vues, procédures, triggers) n'existent pas ici ;
 * ils se testent contre MariaDB (voir docs/exercices/ex08).
 */
class FactureServiceSpec extends Specification implements ServiceUnitTest<FactureService>, DataTest {

    Client client
    Produit produit

    void setupSpec() {
        mockDomains Client, Produit, Facture, LigneFacture
    }

    void setup() {
        client = new Client(code: 'ACME', raisonSociale: 'Acme', tauxRemise: 5).save(failOnError: true)
        produit = new Produit(reference: 'VIS', libelle: 'Vis', prixUnitaireHt: 12.90, tauxTva: 20, stock: 10).save(failOnError: true)
    }

    void "une ligne recopie prix, TVA et remise client"() {
        given:
        Facture f = service.creerBrouillon(client.id)

        when:
        LigneFacture l = service.ajouterLigne(f.id, produit.id, 3)

        then:
        l.prixUnitaireHt == 12.90
        l.tauxTva == 20
        l.remisePct == 5
        f.lignes.size() == 1
    }

    void "une facture émise n'est plus modifiable"() {
        given:
        Facture f = service.creerBrouillon(client.id)
        f.statut = StatutFacture.EMISE
        f.save(flush: true)

        when:
        service.ajouterLigne(f.id, produit.id, 1)

        then:
        thrown(FactureNonModifiableException)
    }

    void "traduction des erreurs SIGNAL de la procédure"() {
        expect:
        FactureService.codeMetier(new SQLException('(conn=5) FACTURE_VIDE', '45000')) == 'FACTURE_VIDE'
        FactureService.codeMetier(new SQLException('Deadlock', '40001')) == 'ERREUR_SQL'
    }
}
