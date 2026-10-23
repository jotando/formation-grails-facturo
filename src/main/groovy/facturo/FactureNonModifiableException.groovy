package facturo

import groovy.transform.CompileStatic

/** Levée quand on tente de modifier une facture qui n'est plus en brouillon. RuntimeException => rollback. */
@CompileStatic
class FactureNonModifiableException extends RuntimeException {
    final Long factureId

    FactureNonModifiableException(Long factureId) {
        super("La facture ${factureId} n'est plus modifiable".toString())
        this.factureId = factureId
    }
}
