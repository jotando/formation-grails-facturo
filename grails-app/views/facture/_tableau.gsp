<%-- Liste de FactureTotaux (vue SQL). Utilisé par client/show et facture/recherche. --%>
<g:if test="${factures}">
    <table class="table table-sm">
        <thead><tr>
            <g:if test="${triable}">
                <g:sortableColumn property="numero" title="Numéro" params="${params}"/>
                <g:sortableColumn property="dateFacture" title="Date" params="${params}"/>
                <g:sortableColumn property="raisonSociale" title="Client" params="${params}"/>
                <g:sortableColumn property="statut" title="Statut" params="${params}"/>
                <g:sortableColumn property="totalTtc" title="Total TTC" params="${params}" class="text-right"/>
            </g:if>
            <g:else>
                <th>Numéro</th><th>Date</th><th>Client</th><th>Statut</th><th class="text-right">Total TTC</th>
            </g:else>
        </tr></thead>
        <tbody>
        <g:each in="${factures}" var="f">
            <tr>
                <td><g:link controller="facture" action="show" id="${f.id}">${f.numero ?: '(brouillon #' + f.id + ')'}</g:link></td>
                <td><g:formatDate date="${f.dateFacture}" format="dd/MM/yyyy"/></td>
                <td>${f.raisonSociale}</td>
                <td><fac:statut valeur="${f.statut}"/></td>
                <td class="text-right"><fac:montant valeur="${f.totalTtc}"/></td>
            </tr>
        </g:each>
        </tbody>
    </table>
</g:if>
<g:else><p class="text-muted"><g:message code="facture.aucune"/></p></g:else>
