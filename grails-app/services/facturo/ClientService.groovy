package facturo

import grails.gorm.services.Service

/**
 * GORM Data Service : GORM génère l'implémentation (transactionnelle) à la compilation.
 * C'est l'équivalent le plus proche d'un JpaRepository de Spring Data.
 */
@Service(Client)
interface ClientService {

    Client get(Serializable id)

    List<Client> list(Map args)

    Long count()

    /** Lève grails.validation.ValidationException si le client est invalide. */
    Client save(Client client)

    void delete(Serializable id)
}
