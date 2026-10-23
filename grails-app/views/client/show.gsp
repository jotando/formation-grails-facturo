<html>
<head>
    <meta name="layout" content="main"/>
    <title>${client.code}</title>
</head>
<body>
<h1>${client.raisonSociale} <small class="text-muted">${client.code}</small></h1>
<dl class="row">
    <dt class="col-sm-3">E-mail</dt><dd class="col-sm-9">${client.email ?: '—'}</dd>
    <dt class="col-sm-3">Remise</dt><dd class="col-sm-9"><g:formatNumber number="${client.tauxRemise}" format="0.00"/> %</dd>
    <dt class="col-sm-3">Actif</dt><dd class="col-sm-9">${client.actif ? 'Oui' : 'Non'}</dd>
    <dt class="col-sm-3">Créé le</dt><dd class="col-sm-9"><g:formatDate date="${client.dateCreated}" format="dd/MM/yyyy HH:mm"/></dd>
</dl>
<p>
    <g:link class="btn btn-secondary" action="edit" id="${client.id}"><g:message code="bouton.modifier"/></g:link>
    <g:link class="btn btn-primary" controller="facture" action="create" params="[clientId: client.id]"><g:message code="facture.nouvelle"/></g:link>
</p>
<h2 class="h4 mt-4">Factures</h2>
<g:render template="/facture/tableau" model="[factures: factures]"/>
</body>
</html>
