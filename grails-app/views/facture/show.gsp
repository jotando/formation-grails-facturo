<html>
<head>
    <meta name="layout" content="main"/>
    <title>${facture.numero ?: 'Brouillon'}</title>
</head>
<body>
<h1>
    <g:message code="facture.titre" args="[facture.numero ?: '#' + facture.id]"/>
    <fac:statut valeur="${facture.statut}"/>
</h1>
<p>
    Client : <g:link controller="client" action="show" id="${facture.client.id}">${facture.client.raisonSociale}</g:link>
    · Date : <g:formatDate date="${facture.dateFacture}" format="dd/MM/yyyy"/>
    <g:if test="${facture.dateEmission}"> · Émise le <g:formatDate date="${facture.dateEmission}" format="dd/MM/yyyy HH:mm"/></g:if>
</p>

<table class="table table-sm">
    <thead><tr>
        <th>Réf.</th><th>Produit</th><th class="text-right">Qté</th><th class="text-right">PU HT</th>
        <th class="text-right">Remise</th><th class="text-right">TVA</th><th class="text-right">Montant HT</th><th class="text-right">Montant TTC</th><th></th>
    </tr></thead>
    <tbody>
    <g:render template="ligne" collection="${facture.lignes}" var="ligne" model="[modifiable: facture.modifiable]"/>
    </tbody>
    <tfoot>
    <tr><th colspan="6" class="text-right">Total HT</th><th class="text-right"><fac:montant valeur="${totaux?.totalHt}"/></th><th colspan="2"></th></tr>
    <tr><th colspan="6" class="text-right">TVA</th><th></th><th class="text-right"><fac:montant valeur="${totaux?.totalTva}"/></th><th></th></tr>
    <tr><th colspan="6" class="text-right">Total TTC</th><th></th><th class="text-right"><fac:montant valeur="${totaux?.totalTtc}"/></th><th></th></tr>
    </tfoot>
</table>

<g:if test="${facture.modifiable}">
    <g:form action="ajouterLigne" id="${facture.id}" class="form-inline mb-3">
        <g:select class="form-control mr-2" name="produitId" from="${produits}" optionKey="id" optionValue="${{ it.reference + ' — ' + it.libelle + ' (stock ' + it.stock + ')' }}"/>
        <g:field type="number" class="form-control mr-2" name="quantite" min="1" value="1" style="width:6rem"/>
        <g:submitButton class="btn btn-secondary" name="ajouter" value="${message(code: 'ligne.ajouter')}"/>
    </g:form>
    <g:form action="emettre" id="${facture.id}">
        <g:submitButton class="btn btn-primary" name="emettre" value="${message(code: 'facture.emettre')}"/>
    </g:form>
</g:if>
</body>
</html>
