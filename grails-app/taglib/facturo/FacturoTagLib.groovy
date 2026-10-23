package facturo

/** Tags maison : <fac:montant valeur="..."/> et <fac:statut valeur="..."/>. */
class FacturoTagLib {

    static namespace = 'fac'
    static defaultEncodeAs = [taglib: 'raw']     // ces tags produisent du HTML : on échappe nous-mêmes les données

    /** Montant en euros au format français, ex. 1 234,50 €. */
    def montant = { attrs ->
        out << g.formatNumber(number: attrs.valeur ?: 0, type: 'currency', currencyCode: 'EUR', locale: Locale.FRANCE)
    }

    /** Badge coloré et traduit pour un statut (enum ou chaîne). */
    def statut = { attrs ->
        String code = attrs.valeur?.toString()
        if (!code) return
        out << "<span class=\"badge badge-statut statut-${code.toLowerCase().encodeAsHTML()}\">"
        out << g.message(code: "statut.${code}", default: code).encodeAsHTML()
        out << '</span>'
    }
}
