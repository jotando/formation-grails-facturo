<%-- Une ligne de facture. Appelé par : <g:render template="ligne" collection="${...}" var="ligne"/> --%>
<tr>
    <td>${ligne.produit.reference}</td>
    <td>${ligne.produit.libelle}</td>
    <td class="text-right">${ligne.quantite}</td>
    <td class="text-right"><fac:montant valeur="${ligne.prixUnitaireHt}"/></td>
    <td class="text-right"><g:formatNumber number="${ligne.remisePct}" format="0.00"/> %</td>
    <td class="text-right"><g:formatNumber number="${ligne.tauxTva}" format="0.0"/> %</td>
    <td class="text-right"><fac:montant valeur="${ligne.montantHt}"/></td>
    <td class="text-right"><fac:montant valeur="${ligne.montantTtc}"/></td>
    <td>
        <g:if test="${modifiable}">
            <g:form action="supprimerLigne" id="${ligne.facture.id}" class="d-inline">
                <g:hiddenField name="ligneId" value="${ligne.id}"/>
                <button class="btn btn-sm btn-outline-danger" type="submit" title="Supprimer">✕</button>
            </g:form>
        </g:if>
    </td>
</tr>
