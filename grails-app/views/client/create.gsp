<html>
<head>
    <meta name="layout" content="main"/>
    <title><g:message code="client.nouveau"/></title>
</head>
<body>
<h1><g:message code="client.nouveau"/></h1>
<g:form action="save">
    <g:render template="form" model="[client: client]"/>
    <g:submitButton class="btn btn-primary" name="creer" value="${message(code: 'bouton.creer')}"/>
    <g:link class="btn btn-link" action="index"><g:message code="bouton.annuler"/></g:link>
</g:form>
</body>
</html>
