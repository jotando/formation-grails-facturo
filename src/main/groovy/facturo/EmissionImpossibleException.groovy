package facturo

import groovy.transform.CompileStatic

/**
 * Traduction métier d'une erreur SIGNAL SQLSTATE '45000' levée par p_emettre_facture.
 * code : FACTURE_INCONNUE, FACTURE_DEJA_EMISE, FACTURE_VIDE, STOCK_INSUFFISANT ou ERREUR_SQL.
 */
@CompileStatic
class EmissionImpossibleException extends RuntimeException {
    final String code

    EmissionImpossibleException(String code, Throwable cause) {
        super("Émission impossible : ${code}".toString(), cause)
        this.code = code
    }
}
