<html>
<head>
    <meta name="layout" content="main"/>
    <title><g:message code="facture.recherche.titre"/></title>
</head>
<body>
<h1><g:message code="facture.recherche.titre"/></h1>
<g:form action="recherche" method="GET" class="form-inline mb-3">
    <g:select class="form-control mr-2" name="clientId" from="${clients}" optionKey="id" optionValue="raisonSociale"
              value="${cmd?.clientId}" noSelection="['': 'Tous les clients']"/>
    <g:select class="form-control mr-2" name="statut" from="${facturo.StatutFacture.values()}" value="${cmd?.statut}"
              valueMessagePrefix="statut" noSelection="['': 'Tous statuts']"/>
    <label class="mr-1" for="du">du</label>
    <g:field type="date" class="form-control mr-2" name="du" value="${formatDate(date: cmd?.du, format: 'yyyy-MM-dd')}"/>
    <label class="mr-1" for="au">au</label>
    <g:field type="date" class="form-control mr-2" name="au" value="${formatDate(date: cmd?.au, format: 'yyyy-MM-dd')}"/>
    <g:submitButton class="btn btn-primary" name="chercher" value="${message(code: 'bouton.rechercher')}"/>
</g:form>
<g:hasErrors bean="${cmd}">
    <div class="alert alert-warning"><g:eachError bean="${cmd}" var="err"><g:message error="${err}"/> </g:eachError></div>
</g:hasErrors>
<p class="text-muted">${total} facture(s)</p>
<g:render template="tableau" model="[factures: factures, triable: true]"/>
<div class="pagination"><g:paginate total="${total ?: 0}" params="${params}"/></div>
</body>
</html>
