package facturo

import grails.gorm.transactions.Transactional
import groovy.sql.Sql

import java.sql.SQLException

/**
 * Service métier des factures.
 * Règle de partage : le service ORCHESTRE (transaction, contrôles d'entrée, traduction des erreurs),
 * la base CALCULE (fonctions, vue v_facture_totaux, procédure p_emettre_facture, triggers).
 */
@Transactional
class FactureService {

    /** Proxy transactionnel : groovy.sql.Sql utilise la MÊME connexion que la transaction Hibernate. */
    def dataSource

    static final List<String> CODES_EMISSION = ['FACTURE_INCONNUE', 'FACTURE_DEJA_EMISE', 'FACTURE_VIDE', 'STOCK_INSUFFISANT']
    static final List<String> TRIS_AUTORISES = ['numero', 'dateFacture', 'raisonSociale', 'statut', 'totalTtc']

    Facture creerBrouillon(Long clientId) {
        Client client = Client.get(clientId)
        if (!client?.actif) {
            throw new IllegalArgumentException("Client inconnu ou inactif : ${clientId}")
        }
        new Facture(client: client).save(failOnError: true)
    }

    LigneFacture ajouterLigne(Long factureId, Long produitId, Integer quantite) {
        Facture facture = chargerModifiable(factureId)
        Produit produit = Produit.get(produitId)
        if (!produit) {
            throw new IllegalArgumentException("Produit inconnu : ${produitId}")
        }
        def ligne = new LigneFacture(
                produit: produit,
                quantite: quantite,
                prixUnitaireHt: produit.prixUnitaireHt,
                tauxTva: produit.tauxTva,
                remisePct: facture.client.tauxRemise)
        facture.addToLignes(ligne)          // tient les deux côtés de la relation
        facture.save(failOnError: true)     // validation en cascade des lignes
        ligne
    }

    void supprimerLigne(Long factureId, Long ligneId) {
        Facture facture = chargerModifiable(factureId)
        LigneFacture ligne = facture.lignes.find { it.id == ligneId }
        if (ligne) {
            facture.removeFromLignes(ligne)  // all-delete-orphan : la ligne est supprimée au flush
            facture.save(failOnError: true)
        }
    }

    @Transactional(readOnly = true)
    boolean estModifiable(Long factureId) {
        Facture.get(factureId)?.modifiable ?: false
    }

    @Transactional(readOnly = true)
    Facture detail(Long id) {
        Facture.findById(id, [fetch: [lignes: 'join', client: 'join']])
    }

    /**
     * Recherche multicritère paginée. On interroge la VUE v_facture_totaux : les totaux et la raison
     * sociale arrivent avec la ligne, sans N+1. Le même code fonctionne sur Facture.where {}.
     */
    @Transactional(readOnly = true)
    Map rechercher(RechercheFactureCommand cmd, Map pagination) {
        Long cid = cmd.clientId
        StatutFacture st = cmd.statut
        Date du = cmd.du
        Date au = cmd.au

        def q = FactureTotaux.where {}
        if (cid) q = q.where { clientId == cid }
        if (st)  q = q.where { statut == st }
        if (du)  q = q.where { dateFacture >= du }
        if (au)  q = q.where { dateFacture <= au }

        Map p = new HashMap(pagination)
        if (!(p.sort in TRIS_AUTORISES)) p.sort = 'dateFacture'
        if (!(p.order in ['asc', 'desc'])) p.order = 'desc'

        [factures: q.list(p), total: q.count()]
    }

    /**
     * Émet la facture via la procédure stockée p_emettre_facture.
     * La procédure ne gère pas de transaction : c'est celle de ce service qui s'applique.
     * @return le numéro attribué par la base
     */
    String emettre(Long factureId) {
        Facture.withSession { it.flush() }           // la procédure lit la base, pas la session Hibernate
        String numero = null
        try {
            new Sql(dataSource).call('{call p_emettre_facture(?, ?)}', [factureId, Sql.VARCHAR]) { String n ->
                numero = n
            }
        } catch (SQLException e) {
            throw new EmissionImpossibleException(codeMetier(e), e)   // RuntimeException => rollback
        }
        Facture.get(factureId)?.refresh()             // l'entité en session est périmée
        numero
    }

    private Facture chargerModifiable(Long factureId) {
        Facture facture = Facture.get(factureId)
        if (!facture) {
            throw new IllegalArgumentException("Facture inconnue : ${factureId}")
        }
        if (!facture.modifiable) {
            throw new FactureNonModifiableException(factureId)
        }
        facture
    }

    static String codeMetier(SQLException e) {
        if (e.SQLState != '45000') return 'ERREUR_SQL'
        CODES_EMISSION.find { e.message?.contains(it) } ?: 'ERREUR_SQL'
    }
}
