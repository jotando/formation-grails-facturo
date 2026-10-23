<html>
<head>
    <meta name="layout" content="main"/>
    <title>${client.code}</title>
</head>
<body>
<h1><g:message code="client.modifier" args="[client.code]"/></h1>
<g:form action="update" id="${client.id}" method="PUT">
    <g:hiddenField name="version" value="${client.version}"/>
    <g:render template="form" model="[client: client]"/>
    <g:submitButton class="btn btn-primary" name="enregistrer" value="${message(code: 'bouton.enregistrer')}"/>
    <g:link class="btn btn-link" action="show" id="${client.id}"><g:message code="bouton.annuler"/></g:link>
</g:form>
</body>
</html>
